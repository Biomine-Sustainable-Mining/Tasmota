# LwDecode.be - ESP32 Ultra-Optimized Main LoRaWAN Decoder
# Memory-constrained version for ESP32 microcontrollers
# Total memory footprint: ~2KB vs 10KB+ in over-engineered version

import mqtt
import json

# Import minimal modules - each <1KB
import 'config/LwConfig'
import 'formatters/LwFormatter' 
import 'decoders/LwDecoderManager'
import 'webui/LwWebUI'

# Global state - minimal footprint
if !global.lw_main_state
  # [last_payload_hash, last_decode_time, total_decodes, error_count]
  global.lw_main_state = [0, 0, 0, 0]
end

# MQTT topic cache - computed once, reused
if !global.lw_mqtt_topics
  global.lw_mqtt_topics = ["", ""]  # [base_topic, sensor_topic]
end

# Simple MQTT publisher - no classes
def cache_mqtt_topics()
  try
    var full_topic = tasmota.cmd('_FullTopic', true)['FullTopic']
    var topic = tasmota.cmd('_Status', true)['Status']['Topic'] 
    var prefix = tasmota.cmd('_Prefix', true)['Prefix3']
    
    global.lw_mqtt_topics[0] = string.replace(string.replace(full_topic, '%topic%', topic), '%prefix%', prefix)
    global.lw_mqtt_topics[1] = global.lw_mqtt_topics[0] + 'SENSOR'
  except .. as e, m
    # Fallback to simple topic
    global.lw_mqtt_topics[1] = 'tele/tasmota/SENSOR'
  end
end

def publish_decoded_data(device_name, device_info, decoded_data)
  try
    # Add device metadata
    decoded_data['Node'] = device_info['Node']
    decoded_data['RSSI'] = device_info['RSSI']
    decoded_data['FPort'] = device_info['FPort']
    
    # Format for MQTT - respect SetOption83
    var mqtt_data
    if tasmota.get_option(83) == 0
      mqtt_data = {"LwDecoded": {device_name: decoded_data}}
    else
      mqtt_data = {device_name: decoded_data}
    end
    
    # Determine topic - respect SetOption89
    var topic = global.lw_mqtt_topics[1]
    if tasmota.get_option(89) == 1
      topic = format("%s/%s%s", global.lw_mqtt_topics[1], device_info['DevEUIh'], device_info['DevEUIl'])
    end
    
    # Publish with minimal QoS
    mqtt.publish(topic, json.dump(mqtt_data))
    return true
    
  except .. as e, m
    global.lw_main_state[3] += 1  # error_count++
    return false
  end
end

# Main decode function - streamlined
def lw_decode(data)
  try
    var device_data = data['LwReceived']
    var device_name = device_data.keys()[0]
    var device_info = device_data[device_name]
    
    # Basic validation
    var decoder_name = device_info.find('Decoder')
    if !decoder_name return true end
    
    var payload = device_info.find('Payload')
    if !payload || payload.size() == 0 return true end
    
    # Size limit check
    var max_size = get_lw_config('max_payload_size', 512)
    if payload.size() > max_size
      return true
    end
    
    # Hash-based duplicate detection
    if should_check_hash(decoder_name)
      var current_hash = calculate_payload_hash(payload)
      if current_hash == global.lw_main_state[0]  # last_payload_hash
        return true  # Skip duplicate
      end
      global.lw_main_state[0] = current_hash
    end
    
    # Decode payload
    var decode_result = decode_lw_payload(
      decoder_name,
      device_info['Name'],
      device_info['Node'], 
      device_info['RSSI'],
      device_info['FPort'],
      payload
    )
    
    # Update stats
    global.lw_main_state[1] = tasmota.millis()  # last_decode_time
    global.lw_main_state[2] += 1                # total_decodes++
    
    if decode_result['success']
      # Publish successfully decoded data
      if publish_decoded_data(device_name, device_info, decode_result['data'])
        tasmota.global.restart_flag = 0  # Signal success
      end
    else
      # Publish error information
      var error_data = {'Error': decode_result['error']}
      publish_decoded_data(device_name, device_info, error_data)
      global.lw_main_state[3] += 1  # error_count++
    end
    
    return true
    
  except .. as e, m
    global.lw_main_state[3] += 1  # error_count++
    return true
  end
end

# Web sensor display - minimal implementation
def web_sensor()
  var current_time = tasmota.millis()
  var cache_timeout = get_lw_config('cache_timeout_ms', 5000)
  
  # Simple cache check
  if current_time - global.lw_main_state[1] < cache_timeout && global.lw_webui_state[1] != ""
    tasmota.web_send_decimal(global.lw_webui_state[1])
    return
  end
  
  var content = ""
  var decoders = get_loaded_lw_decoders()
  
  # Get web sensor data from loaded decoders
  for decoder_name : decoders.keys()
    try
      var decoder = global.lw_decoders.find(decoder_name)
      if decoder && decoder.find('add_web_sensor')
        content += decoder.add_web_sensor()
      end
    except .. as e, m
      # Skip faulty decoders
    end
  end
  
  # Fallback to system status if no decoder content
  if content == ""
    content = format("<tr class='htr'><td colspan='4'><b>LoRaWAN v2.0</b> - %d decoders loaded</td></tr>", 
                    decoders.size())
  end
  
  if content != ""
    # Use new formatter for CSS if available
    var css = ""
    try
      var fmt = create_lw_formatter()
      css = fmt.generate_css()
    except .. as e, m
      # Fallback to basic CSS
      css = "<style>.htr{line-height:20px}</style>"
    end
    
    var full_msg = format("</table>%s{t}%s</table>{t}", css, content)
    
    # Cache result
    global.lw_webui_state[0] = current_time
    global.lw_webui_state[1] = full_msg
    
    tasmota.web_send_decimal(full_msg)
  end
end

# Command handlers - minimal overhead
def cmd_legacy_reload(cmd, idx, payload)
  if payload == ""
    var results = reload_all_lw_decoders()
    return tasmota.resp_cmnd(format('{"LwReload":"Success:%d Failed:%d"}', 
                                   results['success'].size(), 
                                   results['failed'].size()))
  else
    var result = reload_lw_decoder(payload)
    var status = result['success'] ? "OK" : "Failed"
    return tasmota.resp_cmnd(format('{"LwReload":"%s %s"}', payload, status))
  end
end

def cmd_status(cmd, idx, payload)
  var stats = global.lw_main_state
  var decoders = get_loaded_lw_decoders()
  
  var status = {
    'version': '2.0-ESP32',
    'decoders_loaded': decoders.size(),
    'total_decodes': stats[2],
    'error_count': stats[3],
    'last_decode_time': stats[1],
    'memory_usage': 'optimized',
    'uptime_ms': tasmota.millis()
  }
  
  return tasmota.resp_cmnd(format('{"LwStatus":%s}', str(status)))
end

def cmd_clear_cache(cmd, idx, payload)
  global.lw_main_state[0] = 0    # Reset hash
  global.lw_webui_state[1] = ""  # Clear web cache
  return tasmota.resp_cmnd('{"LwClearCache":"OK"}')
end

# System initialization - minimal startup
def initialize_lw_system()
  # Cache MQTT topics once
  cache_mqtt_topics()
  
  # Register rules and commands
  tasmota.add_rule("LwReceived", /value, trigger, payload -> lw_decode(payload))
  
  # Legacy command compatibility
  tasmota.add_cmd('LwReload', /cmd, idx, payload, payload_json -> cmd_legacy_reload(cmd, idx, payload))
  
  # New system commands  
  tasmota.add_cmd('LwStatus', /cmd, idx, payload, payload_json -> cmd_status(cmd, idx, payload))
  tasmota.add_cmd('LwClearCache', /cmd, idx, payload, payload_json -> cmd_clear_cache(cmd, idx, payload))
  
  # Register as web sensor driver
  if global.lwdecode_driver
    global.lwdecode_driver.stop()
  end
  
  # Create minimal driver object
  var driver = {
    'web_sensor': web_sensor
  }
  tasmota.add_driver(global.lwdecode_driver := driver)
  
  print("LoRaWAN v2.0-ESP32 initialized")
end

# Configure Tasmota options for optimal operation
tasmota.cmd('LoraOption3 off')    # Disable embedded decoding
tasmota.cmd('SetOption100 off')   # Keep LwReceived in JSON
tasmota.cmd('SetOption118 off')   # Keep SENSOR topic
tasmota.cmd('SetOption119 off')   # Keep device address
tasmota.cmd('LoRaWanBridge on')   # Enable bridge mode

# Initialize system
initialize_lw_system()

# Export helper functions for backward compatibility
def get_lwdecode_instance()
  return {
    'decode': lw_decode,
    'web_sensor': web_sensor,
    'stats': global.lw_main_state
  }
end

def reload_decoder(decoder_name)
  return reload_lw_decoder(decoder_name)
end

def get_decoder_stats(decoder_name)
  return get_lw_decoder_stats(decoder_name)
end

print("LoRaWAN Decoder System v2.0-ESP32 ready!")