# LwDecoderManager.be - ESP32 Memory-Efficient Decoder Management
# Ultra-lightweight version respecting ESP32 memory constraints

import string

# Global decoder storage - minimal footprint
if !global.lw_decoders
  global.lw_decoders = {}      # {decoder_name: decoder_instance}
end

if !global.lw_decoder_stats  
  global.lw_decoder_stats = {} # {decoder_name: [load_time, use_count, error_count]}
end

if !global.lw_loading_locks
  global.lw_loading_locks = {} # Simple loading protection
end

# Validation constants - compile time
var MAX_DECODERS = 15         # Hard limit for ESP32
var MAX_DECODER_NAME = 50     # Max filename length
var DECODER_TIMEOUT = 2000    # 2 second timeout

# Simple validation functions - no classes
def validate_decoder_name(name)
  if !name || name.size() == 0 return false end
  if name.size() > MAX_DECODER_NAME return false end
  if string.find(name, '..') >= 0 return false end  # Path traversal
  if string.find(name, '/') >= 0 return false end   # Path chars
  if string.find(name, '\\') >= 0 return false end
  return true
end

# Decoder loading - minimal overhead
def load_lw_decoder(decoder_name, force_reload)
  if !validate_decoder_name(decoder_name)
    return {'success': false, 'error': 'Invalid decoder name'}
  end
  
  # Check loading lock
  if global.lw_loading_locks.find(decoder_name)
    return {'success': false, 'error': 'Decoder already loading'}
  end
  
  # Return existing if not force reload
  if !force_reload && global.lw_decoders.find(decoder_name)
    return {'success': true, 'cached': true}
  end
  
  # Check decoder limit
  if global.lw_decoders.size() >= lw_config.get_lw_config("max_decoders", MAX_DECODERS)
    lw_decoderman.evict_oldest_decoder()
  end
  
  # Lock loading
  global.lw_loading_locks[decoder_name] = true
  
  try
    # Remove old instance
    if force_reload && global.lw_decoders.find(decoder_name)
      global.lw_decoders.remove(decoder_name)
    end
    
    # Load decoder file
    var LwDeco = nil
    load(decoder_name)
    
    if !LwDeco
      global.lw_loading_locks.remove(decoder_name)
      log("LwD: Decoder did not set LwDeco variable",1)
      return {'success': false, 'error': 'Decoder did not set LwDeco variable'}
    end
    
    # Validate decoder interface
    if !LwDeco.find('decodeUplink') || type(LwDeco['decodeUplink']) != 'function'
      global.lw_loading_locks.remove(decoder_name)
      log("LwD: Missing decodeUplink function",1)
      return {'success': false, 'error': 'Missing decodeUplink function'}
    end
    
    # Store decoder
    global.lw_decoders[decoder_name] = LwDeco
    
    # Initialize stats: [load_time, use_count, error_count]
    global.lw_decoder_stats[decoder_name] = [tasmota.millis(), 0, 0]
    
    global.lw_loading_locks.remove(decoder_name)
    return {'success': true}
    
  except .. as e, m
    global.lw_loading_locks.remove(decoder_name)
    log(format("LwD: Load exception: %s", m),1)
    return {'success': false, 'error': format("Load exception: %s", m)}
  end
end

# Evict oldest decoder when at limit
def evict_oldest_decoder()
  var oldest_name = nil
  var oldest_time = tasmota.millis()
  
  for name : global.lw_decoder_stats.keys()
    var stats = global.lw_decoder_stats[name]
    if stats[0] < oldest_time  # load_time
      oldest_time = stats[0]
      oldest_name = name
    end
  end
  
  if oldest_name
    global.lw_decoders.remove(oldest_name)
    global.lw_decoder_stats.remove(oldest_name)
  end
end

# Decode payload - streamlined execution
def decode_lw_payload(decoder_name, device_name, node_id, rssi, fport, payload)
  log("LwD: decode_lw_payload() fired",1)
  var decoder = global.lw_decoders.find(decoder_name)
  if !decoder
    # Try to load decoder
    var load_result = load_lw_decoder(decoder_name, false)
    if !load_result['success']
      log("LwD: error:" + load_result['error'],1)
      return {'success': false, 'error': load_result['error']}
    end
    decoder = global.lw_decoders[decoder_name]
  end
  
  var stats = global.lw_decoder_stats.find(decoder_name)
  var start_time = tasmota.millis()
  
  try
    # Execute decoder with timeout protection
    var result = decoder.decodeUplink(device_name, node_id, rssi, fport, payload)
    var exec_time = tasmota.millis() - start_time
    
    if exec_time > DECODER_TIMEOUT
      if stats stats[2] += 1 end  # error_count++
      log(format("LwD: Timeout (%dms)", exec_time),1)
      return {'success': false, 'error': format("Timeout (%dms)", exec_time)}
    end
    
    # Update stats
    if stats
      stats[1] += 1  # use_count++
    end
    
    log("LwD: Packet decoded",1)
    return {'success': true, 'data': result, 'execution_time': exec_time}
    
  except .. as e, m
    var exec_time = tasmota.millis() - start_time
    if stats stats[2] += 1 end  # error_count++
    log(format("LwD: Decode error: %s", m),1)
    return {'success': false, 'error': format("Decode error: %s", m), 'execution_time': exec_time}
  end
end

# Hash checking utilities
def should_check_hash(decoder_name)
  # Try to get hashCheck from decoder, fallback to global config
  var decoder = global.lw_decoders.find(decoder_name)
  if decoder && decoder.find('hashCheck') != nil
    return decoder['hashCheck']
  end
  return lw_config.get_lw_config('hash_check_enabled', true)
end

def calculate_payload_hash(payload)
  var hash = 5381  # djb2 hash - fast and good for small data
  for i:0..payload.size()-1
    hash = ((hash << 5) + hash + payload[i]) & 0xFFFFFFFF
  end
  return hash
end

# Decoder management functions
def reload_lw_decoder(decoder_name)
  return lw_decoderman.load_lw_decoder(decoder_name, true)
end

def unload_lw_decoder(decoder_name)
  if global.lw_decoders.find(decoder_name)
    global.lw_decoders.remove(decoder_name)
    global.lw_decoder_stats.remove(decoder_name)
    return {'success': true}
  end
  return {'success': false, 'error': 'Decoder not loaded'}
end

def reload_all_lw_decoders()
  var results = {'success': [], 'failed': []}
  
  var decoder_names = []
  for name : global.lw_decoders.keys()
    decoder_names.push(name)
  end
  
  for name : decoder_names
    var result = reload_lw_decoder(name)
    if result['success']
      results['success'].push(name)
    else
      results['failed'].push({'name': name, 'error': result['error']})
    end
  end
  
  return results
end

def get_loaded_lw_decoders()
  var result = {}
  for name : global.lw_decoders.keys()
    var stats = global.lw_decoder_stats.find(name)
    if stats
      result[name] = {
        'name': name,
        'load_time': stats[0],
        'use_count': stats[1], 
        'error_count': stats[2],
        'loaded': true
      }
    else
      result[name] = {'name': name, 'loaded': true}
    end
  end
  return result
end

def get_lw_decoder_stats(decoder_name)
  var stats = global.lw_decoder_stats.find(decoder_name)
  if stats
    return {
      'name': decoder_name,
      'load_time': stats[0],
      'use_count': stats[1],
      'error_count': stats[2],
      'loaded': global.lw_decoders.find(decoder_name) != nil
    }
  end
  return nil
end

# Command registration for Tasmota
def register_lw_decoder_commands()
  tasmota.add_cmd('LwDecoderList',
    def(cmd, idx, payload)
      var decoders = get_loaded_lw_decoders()
      return tasmota.resp_cmnd(format('{"LwDecoders":%d,"Details":%s}', 
                                     decoders.size(), 
                                     str(decoders)))
    end
  )
  
  tasmota.add_cmd('LwDecoderLoad',
    def(cmd, idx, payload)
      if payload == "" return tasmota.resp_cmnd_error() end
      
      var result = load_lw_decoder(payload, false)
      if result['success']
        return tasmota.resp_cmnd(format('{"%s":"Loaded"}', payload))
      else
        return tasmota.resp_cmnd(format('{"%s":"Error: %s"}', payload, result['error']))
      end
    end
  )
  
  tasmota.add_cmd('LwDecoderReload',
    def(cmd, idx, payload)
      if payload == ""
        # Reload all
        var results = reload_all_lw_decoders()
        return tasmota.resp_cmnd(format('{"LwReloadAll":"Success:%d Failed:%d"}', 
                                       results['success'].size(), 
                                       results['failed'].size()))
      else
        # Reload specific
        var result = reload_lw_decoder(payload)
        var status = result['success'] ? "OK" : result['error']
        return tasmota.resp_cmnd(format('{"LwReload":"%s %s"}', payload, status))
      end
    end
  )
  
  tasmota.add_cmd('LwDecoderStats',
    def(cmd, idx, payload)
      if payload == ""
        # All stats
        var all_stats = {}
        for name : global.lw_decoders.keys()
          all_stats[name] = get_lw_decoder_stats(name)
        end
        return tasmota.resp_cmnd(format('{"LwDecoderStats":%s}', str(all_stats)))
      else
        # Specific decoder
        var stats = get_lw_decoder_stats(payload)
        if stats
          return tasmota.resp_cmnd(format('{"%s":%s}', payload, str(stats)))
        else
          return tasmota.resp_cmnd_error()
        end
      end
    end
  )
  
  tasmota.add_cmd('LwDecoderUnload',
    def(cmd, idx, payload)
      if payload == "" return tasmota.resp_cmnd_error() end
      
      var result = unload_lw_decoder(payload)
      if result['success']
        return tasmota.resp_cmnd(format('{"%s":"Unloaded"}', payload))
      else
        return tasmota.resp_cmnd(format('{"%s":"Error: %s"}', payload, result['error']))
      end
    end
  )
end

# Initialize commands
register_lw_decoder_commands()

# Cleanup expired locks periodically
def cleanup_lw_loading_locks()
  global.lw_loading_locks = {}  # Simple cleanup - just clear all
end

# Schedule cleanup every 5 minutes
tasmota.set_timer(300000, cleanup_lw_loading_locks)

# Export main functions for LwDecode main module
var LwDecoderManagerClass = {
  'load_decoder': load_lw_decoder,
  'decode_payload': decode_lw_payload,
  'should_check_hash': should_check_hash,
  'calculate_payload_hash': calculate_payload_hash,
  'get_loaded_decoders': get_loaded_lw_decoders,
  'reload_decoder': reload_lw_decoder,
  'reload_all_decoders': reload_all_lw_decoders
}