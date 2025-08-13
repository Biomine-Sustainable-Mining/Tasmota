# LwConfig.be - ESP32 Memory-Constrained Configuration Management
# Ultra-lightweight version for ESP32 constraints

# Global config storage - MINIMAL footprint
if !global.lw_cfg
  # Single array instead of complex objects: [cache_timeout, max_decoders, hash_check, debug, log_level]
  global.lw_cfg = [5000, 10, 1, 0, 2, 512]  # ~24 bytes vs 500+ bytes in object version
end

# Config indices - more memory efficient than string keys
var CFG_CACHE_TIMEOUT = 0    # [0] = cache timeout in ms
var CFG_MAX_DECODERS = 1     # [1] = max decoders to keep loaded  
var CFG_HASH_CHECK = 2       # [2] = 1=enabled, 0=disabled
var CFG_DEBUG = 3            # [3] = 1=enabled, 0=disabled
var CFG_LOG_LEVEL = 4        # [4] = 0=CRIT, 1=ERR, 2=WARN, 3=INFO, 4=DEBUG
var CFG_MAX_PAYLOAD = 5      # [5] = max payload size

# Validation limits - compile-time constants
var CACHE_MIN = 1000
var CACHE_MAX = 30000
var DECODER_MIN = 1
var DECODER_MAX = 20

# Simple config functions - NO classes to save memory
def get_lw_config(key, default_val)
  var cfg = global.lw_cfg
  
  if key == "cache_timeout_ms" return cfg[CFG_CACHE_TIMEOUT]
  elif key == "max_decoders" return cfg[CFG_MAX_DECODERS]  
  elif key == "hash_check_enabled" return cfg[CFG_HASH_CHECK] == 1
  elif key == "debug_enabled" return cfg[CFG_DEBUG] == 1
  elif key == "max_payload_size" return cfg[CFG_MAX_PAYLOAD]
  elif key == "log_level" 
    var levels = ["CRITICAL", "ERROR", "WARNING", "INFO", "DEBUG"]
    return levels[cfg[CFG_LOG_LEVEL]]
  else
    return default_val
  end
end

def set_lw_config(key, value)
  var cfg = global.lw_cfg
  
  if key == "cache_timeout_ms"
    if type(value) == 'int' && value >= CACHE_MIN && value <= CACHE_MAX
      cfg[CFG_CACHE_TIMEOUT] = value
      return true
    end
  elif key == "max_decoders"
    if type(value) == 'int' && value >= DECODER_MIN && value <= DECODER_MAX
      cfg[CFG_MAX_DECODERS] = value
      return true
    end
  elif key == "hash_check_enabled"
    cfg[CFG_HASH_CHECK] = value ? 1 : 0
    return true
  elif key == "debug_enabled"
    cfg[CFG_DEBUG] = value ? 1 : 0
    return true
  elif key == "log_level"
    var level_map = {"CRITICAL": 0, "ERROR": 1, "WARNING": 2, "INFO": 3, "DEBUG": 4}
    var level_num = level_map.find(value)
    if level_num != nil
      cfg[CFG_LOG_LEVEL] = level_num
      return true
    end
  end
  
  return false
end

# Commands for Tasmota integration - lightweight
def register_lw_config_commands()
  tasmota.add_cmd('LwConfigGet', 
    def(cmd, idx, payload)
      if payload == ""
        # Return all config as compact JSON
        return tasmota.resp_cmnd(format('{"cache_timeout_ms":%d,"max_decoders":%d,"hash_check":%s,"debug":%s,"log_level":"%s"}',
          global.lw_cfg[CFG_CACHE_TIMEOUT],
          global.lw_cfg[CFG_MAX_DECODERS], 
          global.lw_cfg[CFG_HASH_CHECK] == 1 ? "true" : "false",
          global.lw_cfg[CFG_DEBUG] == 1 ? "true" : "false",
          get_lw_config("log_level", "INFO")
        ))
      else
        # Return specific key
        var value = get_lw_config(payload, nil)
        if value != nil
          return tasmota.resp_cmnd(format('{"%s":"%s"}', payload, str(value)))
        end
        return tasmota.resp_cmnd_error()
      end
    end
  )
  
  tasmota.add_cmd('LwConfigSet',
    def(cmd, idx, payload)
      # Parse key=value format
      var eq_pos = string.find(payload, '=')
      if eq_pos < 0 return tasmota.resp_cmnd_error() end
      
      var key = payload[0..(eq_pos-1)]
      var value_str = payload[(eq_pos+1)..]
      
      # Convert value based on key
      var value
      if key == "cache_timeout_ms" || key == "max_decoders"
        value = int(value_str)
      elif key == "hash_check_enabled" || key == "debug_enabled"
        value = (value_str == "true" || value_str == "1")
      else
        value = value_str
      end
      
      if set_lw_config(key, value)
        return tasmota.resp_cmnd(format('{"%s":"%s"}', key, str(value)))
      end
      return tasmota.resp_cmnd_error()
    end
  )
end

# Initialize commands
register_lw_config_commands()

# Export key functions for compatibility
var lw_config = {
  'get': get_lw_config,
  'set': set_lw_config
}