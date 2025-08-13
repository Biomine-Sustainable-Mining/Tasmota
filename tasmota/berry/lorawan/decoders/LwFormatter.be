# LwFormatter.be - ESP32 Ultra-Lightweight Formatter
# Minimal memory footprint for ESP32 constraints

import string

# Single global buffer - reused across all formatting operations
if !global.lw_fmt_buf
  global.lw_fmt_buf = bytes(1024)  # Fixed size buffer - no dynamic allocation
end

# Sensor format definitions - compact array format [unit, format, icon]
var SENSOR_FORMATS = {
  "volt":       ["V",   "%.1f", "&#x26A1;"],
  "milliamp":   ["mA",  "%.0f", "&#x1F50C;"],
  "power":      ["W",   "%.0f", "&#x1F4A1;"],
  "energy":     ["Wh",  "%.0f", "&#x1F9EE;"],
  "percentage": ["%",   "%.0f", "&#x1F4CA;"],
  "string":     [nil,   "%s",   nil],
  "temp":       ["°C",  "%.1f", "&#x1F321;"],
  "humidity":   ["%",   "%.0f", "&#x1F4A7;"]
}

# HTML escape - minimal implementation
def escape_html(in)
  if !in return "" end
  var s = str(in)
  s = string.replace(s, '&', '&amp;')
  s = string.replace(s, '<', '&lt;')  
  s = string.replace(s, '>', '&gt;')
  return s
end

# Battery indicator - simplified
def format_battery(voltage_mv, last_seen_fn)
  if voltage_mv >= 1000  # Mains powered or N/A
    return "&nbsp;"
  end
  
  var voltage_v = voltage_mv / 1000.0
  var percent = 0
  if voltage_v > 2.5
    percent = int((voltage_v - 2.5) * 166.67)  # (v-2.5)/0.6*100
    if percent > 100 percent = 100 end
  end
  
  var pixels = int(percent / 7.14)  # 100%/14px
  if pixels > 14 pixels = 14 end
  if pixels < 1 && percent > 0 pixels = 1 end
  
  return format("<i class=\"bt\" title=\"%.2fV (%s)\" style=\"--bl:%dpx\"></i>", 
                voltage_v, last_seen_fn ? last_seen_fn() : "", pixels)
end

# RSSI indicator - simplified
def format_rssi(rssi_dbm)
  if rssi_dbm >= 1000 return "&nbsp;" end
  if rssi_dbm < -132 rssi_dbm = -132 end
  
  var bars = 0
  if rssi_dbm >= -50 bars = 4
  elif rssi_dbm >= -70 bars = 3  
  elif rssi_dbm >= -85 bars = 2
  elif rssi_dbm >= -100 bars = 1
  end
  
  var html = format("<div title='RSSI %i dBm' class='si'>", rssi_dbm)
  for i:0..3
    var dim = (bars <= i) ? " o30" : ""
    html += format("<i class='b%d%s'></i>", i, dim)
  end
  html += "</div>"
  
  return html
end

# Time formatting - minimal
def format_time_since(timestamp)
  var since = tasmota.rtc('local') - timestamp
  if since > 86400
    return format("%dd", int(since / 86400))
  elif since > 3600  
    return format("%dh", int(since / 3600))
  else
    return format("%dm", int(since / 60))
  end
end

# Main formatter - single function, no classes
def create_lw_formatter()
  var fmt = {
    'buf': global.lw_fmt_buf
  }
  
  # Reset buffer
  fmt.buf.clear()
  
  # Add content method
  fmt.add = def(self, content)
    if content self.buf.fromstring(str(content)) end
    return self
  end
  
  # Add safe content method (HTML escaped)
  fmt.add_safe = def(self, content)
    if content self.buf.fromstring(escape_html(content)) end
    return self
  end
  
  # Get final content
  fmt.get_content = def(self)
    return self.buf.asstring()
  end
  
  # Reset for reuse
  fmt.reset_buffer = def(self)
    self.buf.clear()
    return self
  end
  
  # Device header
  fmt.format_device_header = def(self, name, tooltip, battery_mv, battery_time, rssi, last_seen)
    self.add(format("<tr class='htr'><td><b title='%s'>%s</b></td>", 
                   escape_html(tooltip), escape_html(name)))
    self.add("<td>")
    self.add(format_battery(battery_mv, def() return format_time_since(battery_time) end))
    self.add("</td><td>")
    self.add(format_rssi(rssi))
    self.add("</td><td>")
    self.add(format("&#x1F557;%s", format_time_since(last_seen)))
    self.add("</td></tr>")
    return self
  end
  
  # Start sensor line
  fmt.start_line = def(self)
    self.add("<tr class='htr'><td colspan='4'>&#9478;")
    return self
  end
  
  # End sensor line  
  fmt.end_line = def(self)
    self.add("{e}")
    return self
  end
  
  # Next line
  fmt.next_line = def(self)
    self.add("{e}<tr class='htr'><td colspan='4'>&#9478;")
    return self
  end
  
  # Add sensor value
  fmt.add_sensor = def(self, sensor_type, value, tooltip, custom_icon)
    var fmt_def = SENSOR_FORMATS.find(sensor_type)
    if !fmt_def fmt_def = SENSOR_FORMATS["string"] end
    
    if tooltip
      self.add(format("&nbsp;<div title='%s' class='si'>", escape_html(tooltip)))
    end
    
    # Icon
    if custom_icon
      self.add(format(" %s", custom_icon))
    elif fmt_def[2]
      self.add(format(" %s", fmt_def[2]))
    end
    
    # Value
    if fmt_def[1]
      if sensor_type == "string"
        self.add(format(fmt_def[1], escape_html(str(value))))
      else
        self.add(format(fmt_def[1], value))
      end
    else
      self.add_safe(str(value))
    end
    
    # Unit
    if fmt_def[0]
      self.add(fmt_def[0])
    end
    
    if tooltip
      self.add("</div>")
    end
    
    return self
  end
  
  # Generate minimal CSS
  fmt.generate_css = def(self)
    return "'<style>.htr{line-height:20px}.htr td:not(:first-child){width:20px;font-size:70%}.htr td:last-child{width:45px}.bt{margin-right:10px}.si{display:inline-flex;align-items:flex-end;height:15px;padding:0}.si i{width:3px;margin-right:1px;border-radius:3px;background-color:var(--c_txt)}.si .b0{height:25%}.si .b1{height:50%}.si .b2{height:75%}.si .b3{height:100%}.o30{opacity:.3}</style>'"
  end
  
  return fmt
end

# Legacy compatibility - minimal overhead
class LwSensorFormatter_cls
  var fmt
  
  def init()
    self.fmt = create_lw_formatter()
  end
  
  def start_line()
    self.fmt.start_line()
    return self
  end
  
  def end_line()
    self.fmt.end_line()
    return self
  end
  
  def next_line()
    self.fmt.next_line()
    return self
  end
  
  def add_sensor(sensor_type, value, tooltip, custom_icon)
    self.fmt.add_sensor(sensor_type, value, tooltip, custom_icon)
    return self
  end
  
  def get_msg()
    return self.fmt.get_content()
  end
end