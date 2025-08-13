# Convert Legacy LoRaWAN Decoder to ESP32-Optimized Architecture

You are an embedded systems expert specializing in ESP32 microcontroller optimization. Convert the provided legacy LoRaWAN decoder to the new ESP32-optimized architecture with strict memory constraints.

## CRITICAL CONSTRAINTS
- **ESP32 Memory Limit**: Total heap usage <2KB per decoder
- **Array-based storage**: Use compact arrays instead of objects
- **Global persistence**: Data must survive decoder reloads
- **No dynamic allocation**: Minimize runtime memory allocation
- **Backward compatibility**: Must work with existing Tasmota commands

## CONVERSION TEMPLATE

```berry
# LoRaWAN Decoder for [DEVICE_NAME] - ESP32 Optimized
# Memory usage: ~[X] bytes per device vs [Y]+ in original version

import string

# Global storage (survives decoder reload) - MINIMAL footprint
if !global.[device_prefix]
  global.[device_prefix] = {}
end

class [DecoderClassName]
  # Metadata - minimal overhead
  static var metadata = {
    'name': '[DEVICE_NAME]',
    'version': '2.0',
    'hashCheck': true,
    'timeout': 1000
  }
  
  static def decodeUplink(Name, Node, RSSI, FPort, Bytes)
    var data = {"Device":"[DEVICE_DESCRIPTION]"}
    var valid = false
    var now = tasmota.rtc('local')
    
    # Get/create node data - COMPACT array storage
    # Define array indices: [name, sensor1, sensor2, ..., rssi, last_seen, cmd_init]
    var n = global.[device_prefix].find(Node)
    if !n
      global.[device_prefix][Node] = [Name, /* sensor values */, RSSI, now, false]
      n = global.[device_prefix][Node]
    else
      n[0] = Name    # Update name
      n[-3] = RSSI   # Update RSSI (3rd from end)
      n[-2] = now    # Update last seen (2nd from end)
    end
    
    # Parse payload - STREAMLINED (convert original parsing logic)
    # [ORIGINAL PARSING LOGIC CONVERTED TO DIRECT ARRAY UPDATES]
    
    # Initialize commands if needed
    if valid && !n[-1]  # cmd_init flag (last element)
      self._init_commands()
      n[-1] = true
    end
    
    return data
  end
  
  # Command initialization - LIGHTWEIGHT
  static def _init_commands()
    if !global.[device_prefix]_cmds_init
      # Add device-specific commands here
      global.[device_prefix]_cmds_init = true
    end
  end
  
  # Web display - COMPACT
  static def add_web_sensor()
    var msg = ""
    
    for node_id : global.[device_prefix].keys()
      var n = global.[device_prefix][node_id]
      var name = n[0]
      
      # Format device name
      if string.find(name, "[DEVICE_NAME]") > -1
        name = format("[DEVICE_NAME]-%i", node_id)
      end
      
      # Use formatter efficiently
      try
        var fmt = create_lw_formatter()
        msg += fmt.format_device_header(name, "[DEVICE_DESCRIPTION]", n[-4], n[-2], n[-3], n[-2])
        
        # Add sensor displays using array indices
        fmt.start_line()
        # [CONVERT ORIGINAL WEB DISPLAY LOGIC]
        fmt.end_line()
        
        msg += fmt.get_content()
        
      except .. as e, m
        # Fallback to legacy formatter
        msg += lwdecode.header(name, "[DEVICE_DESCRIPTION]", n[-4], n[-2], n[-3], n[-2])
        # [FALLBACK DISPLAY LOGIC]
      end
    end
    
    return msg
  end
end

LwDeco = [DecoderClassName]
```

## CONVERSION RULES

### 1. Memory Optimization
- **Replace objects with arrays**: `{key: value}` → `[value1, value2, ...]`
- **Use indices not keys**: `data.temperature` → `n[1]` 
- **Eliminate duplicate strings**: Store once, reference by index
- **Compact boolean storage**: Use 0/1 instead of true/false when possible

### 2. Data Structure Mapping
```berry
# BEFORE: Object-heavy storage
global.deviceNodes[Node] = [Name, Node, last_seen, battery_last_seen, 
                           battery, rssi, temp, humidity, /*...other sensors...*/]

# AFTER: Compact array (define clear indices)
# Array structure: [name, temp, humidity, battery, rssi, last_seen, cmd_init]
global.device[Node] = [Name, 0.0, 0.0, 1000, RSSI, now, false]
```

### 3. Parsing Logic
```berry
# BEFORE: Multiple variable assignments
var temp_int = ((Bytes[2] << 8) | Bytes[3]) / 100.0
data.insert("TempC_Internal", temp_int)

# AFTER: Direct array update
n[1] = ((Bytes[2] << 8) | Bytes[3]) / 100.0  # temp at index 1
data['TempC_Internal'] = n[1]
```

### 4. Web Display
```berry
# Use new formatter with fallback:
try
  var fmt = create_lw_formatter()
  fmt.add_sensor("temp", n[1], nil)  # Direct array access
except .. as e, m
  # Legacy fallback
  fmt = LwSensorFormatter_cls()
  fmt.add_sensor("temp", n[1], nil)
end
```

### 5. Command Integration
- **Lazy initialization**: Commands registered only once globally
- **Node validation**: Check if node exists before sending downlinks
- **Error handling**: Always return proper Tasmota responses

## VALIDATION CHECKLIST
- ✅ Total memory <2KB per device
- ✅ Array-based storage implemented
- ✅ Global persistence maintained
- ✅ Backward compatibility preserved
- ✅ Web display with fallback
- ✅ Command initialization optimized
- ✅ Error handling present
- ✅ Original functionality maintained

## OUTPUT REQUIREMENTS
1. **Complete working decoder** ready for ESP32 deployment
2. **Memory usage comment** at top with estimated bytes per device
3. **Clear array structure definition** in comments
4. **Fallback web display** for legacy compatibility
5. **Proper error handling** throughout

Convert the provided legacy decoder following these exact specifications. Focus on maximum memory efficiency while preserving all original functionality.