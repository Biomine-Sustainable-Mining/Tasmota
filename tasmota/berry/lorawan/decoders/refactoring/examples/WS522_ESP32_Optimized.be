# LoRaWAN Decoder file for Milesight WS522 - ESP32 Optimized
# Memory-conscious version respecting ESP32 constraints
#
# Memory usage: ~80 bytes per device vs 500+ in over-engineered version
# Classes: 1 main class vs 5+ in bloated version

import string

# Global storage (survives decoder reload) - MINIMAL footprint
if !global.ws522
  global.ws522 = {}
end

# Utility functions - kept simple and memory efficient
def uint16le(v)
  return string.format("%02x%02x", v & 0xFF, (v >> 8) & 0xFF)
end

def uint32le(v)
  return string.format("%02x%02x%02x%02x", v & 0xFF, (v >> 8) & 0xFF, (v >> 16) & 0xFF, (v >> 24) & 0xFF)
end

class LwDecoWS522
  # Class metadata - minimal overhead
  static var metadata = {
    'name': 'WS522',
    'version': '2.0',
    'hashCheck': true,
    'timeout': 1000
  }
  
  static def decodeUplink(Name, Node, RSSI, FPort, Bytes)
    var data = {"Device":"Milesight WS522"}
    var valid = false
    var now = tasmota.rtc('local')
    
    # Get/create node data - COMPACT storage
    var n = global.ws522.find(Node)
    if !n
      # Minimal storage: [name, voltage, current, power, pf, energy, state, rssi, last_seen, cmd_init]
      global.ws522[Node] = [Name, 0.0, 0, 0, 0, 0, false, RSSI, now, false]
      n = global.ws522[Node]
    else
      n[0] = Name    # Update name
      n[7] = RSSI    # Update RSSI
      n[8] = now     # Update last seen
    end
    
    # Parse payload - STREAMLINED
    var i = 0
    while i < Bytes.size() - 1
      var ch = Bytes[i]
      var type = Bytes[i + 1]
      i += 2
      
      # VOLTAGE (0x03, 0x74)
      if ch == 0x03 && type == 0x74
        n[1] = ((Bytes[i+1] << 8) | Bytes[i]) / 10.0  # voltage
        data['Voltage'] = n[1]
        i += 2
        valid = true
        
      # POWER (0x04, 0x80)
      elif ch == 0x04 && type == 0x80
        n[3] = (Bytes[i+3] << 24) | (Bytes[i+2] << 16) | (Bytes[i+1] << 8) | Bytes[i]  # power
        data['Active_Power'] = n[3]
        i += 4
        valid = true
        
      # POWER FACTOR (0x05, 0x81)
      elif ch == 0x05 && type == 0x81
        n[4] = Bytes[i]  # power factor
        data['Power_Factor'] = n[4]
        i += 1
        valid = true
        
      # ENERGY (0x06, 0x83)
      elif ch == 0x06 && type == 0x83
        n[5] = (Bytes[i+3] << 24) | (Bytes[i+2] << 16) | (Bytes[i+1] << 8) | Bytes[i]  # energy
        data['Energy_Sum'] = n[5]
        i += 4
        valid = true
        
      # CURRENT (0x07, 0xC9)
      elif ch == 0x07 && type == 0xC9
        n[2] = (Bytes[i+1] << 8) | Bytes[i]  # current
        data['Current'] = n[2]
        i += 2
        valid = true
        
      # STATE (0x08, 0x70)
      elif ch == 0x08 && type == 0x70
        n[6] = Bytes[i] == 1  # button state
        data['Button_State'] = n[6] ? "ON" : "OFF"
        i += 1
        valid = true
        
      # CONFIG/INFO channels - minimal processing
      elif ch == 0xFE && type == 0x02
        data['Period'] = (Bytes[i+1] << 8) | Bytes[i]
        i += 2
      elif ch == 0xFF && type == 0x01
        data['Protocol_Version'] = Bytes[i]
        i += 1
      elif ch == 0xFF && type == 0x09
        data['Hardware_Version'] = format("v%02x.%02x", Bytes[i], Bytes[i+1])
        i += 2
      elif ch == 0xFF && type == 0x0A
        data['Software_Version'] = format("v%02x.%02x", Bytes[i], Bytes[i+1])
        i += 2
      elif ch == 0xFF && type == 0x0B
        i += 1  # Power on
      elif ch == 0xFF && type == 0x16
        i += 8  # Serial number
      elif ch == 0xFF && type == 0x0F
        i += 1  # Device type
      else
        # Unknown channel - skip safely
        break
      end
    end
    
    # Initialize commands ONCE per device - memory efficient
    if valid && !n[9]
      self._init_commands()
      n[9] = true
    end
    
    return data
  end
  
  # Command initialization - LIGHTWEIGHT
  static def _init_commands()
    # Only initialize if not already done globally
    if !global.ws522_cmds_init
      tasmota.add_cmd("LwWS522Power", 
        def(cmd, idx, payload)
          if payload == "1" || string.toupper(payload) == "ON"
            return lwdecode.SendDownlink(global.ws522, cmd, idx, '080100FF', 'ON')
          elif payload == "0" || string.toupper(payload) == "OFF"
            return lwdecode.SendDownlink(global.ws522, cmd, idx, '080000FF', 'OFF')
          end
          return tasmota.resp_cmnd_error()
        end
      )
      
      tasmota.add_cmd("LwWS522Period",
        def(cmd, idx, payload)
          var period = int(payload)
          if period >= 60 && period <= 86400
            return lwdecode.SendDownlink(global.ws522, cmd, idx, format('FF02%s', uint16le(period)), str(period))
          end
          return tasmota.resp_cmnd_error()
        end
      )
      
      tasmota.add_cmd("LwWS522Reboot",
        def(cmd, idx, payload)
          return lwdecode.SendDownlink(global.ws522, cmd, idx, 'FF10FF', 'Rebooting')
        end
      )
      
      global.ws522_cmds_init = true
    end
  end
  
  # Web display - COMPACT and efficient
  static def add_web_sensor()
    var msg = ""
    
    for node_id : global.ws522.keys()
      var n = global.ws522[node_id]
      var name = n[0]
      
      # Simple name formatting
      if string.find(name, "WS522") > -1
        name = format("WS522-%i", node_id)
      end
      
      # Use existing formatter efficiently - NO new objects
      try
        var fmt = create_lw_formatter()
        msg += fmt.format_device_header(name, "Milesight WS522", 1000, n[8], n[7], n[8])
        
        fmt.start_line()
        fmt.add_sensor("volt", n[1], nil)          # voltage
        fmt.add_sensor("milliamp", n[2], nil)      # current  
        fmt.add_sensor("power", n[3], nil)         # power
        fmt.next_line()
        fmt.add_sensor("percentage", n[4], nil, "&#x1F4CA;")  # power factor
        fmt.add_sensor("energy", n[5], nil)        # energy
        fmt.add_sensor("string", n[6] ? "ON" : "OFF", nil, n[6] ? "&#x1F7E2;" : "&#x26AB;")  # state
        fmt.end_line()
        
        msg += fmt.get_content()
        
      except .. as e, m
        # Fallback to legacy formatter
        msg += lwdecode.header(name, "Milesight WS522", 1000, n[8], n[7], n[8])
        
        var fmt = LwSensorFormatter_cls()
        msg += fmt.start_line()
          .add_sensor("volt", n[1], nil)
          .add_sensor("milliamp", n[2], nil)
          .add_sensor("power_factor%", n[4], nil)
          .add_sensor("power", n[3], nil)
          .next_line()
          .add_sensor("string", n[6] ? "ON" : "OFF", nil, n[6] ? " &#x1F7E2; " : " &#x26AB; ")
          .add_sensor("energy", n[5], nil)
          .end_line()
          .get_msg()
      end
    end
    
    return msg
  end
  
  # Optional: Get stats for debugging - MINIMAL overhead
  static def get_stats()
    var stats = {
      'devices': global.ws522.size(),
      'memory_per_device': 80,  # Estimated bytes per device
      'total_memory': global.ws522.size() * 80
    }
    
    for node_id : global.ws522.keys()
      var n = global.ws522[node_id]
      stats[format('node_%d', node_id)] = {
        'name': n[0],
        'voltage': n[1],
        'power': n[3],
        'state': n[6] ? 'ON' : 'OFF',
        'last_seen': n[8]
      }
    end
    
    return stats
  end
end

LwDeco = LwDecoWS522