# LwWebUI.be - ESP32 Minimalist Web Interface
# Ultra-lightweight for ESP32 memory constraints

import webserver
import string

# Global state - minimal footprint
if !global.lw_webui_state
  global.lw_webui_state = [0, ""]  # [last_render_time, cached_content]
end

# Simple input validation - no classes
def validate_web_input(input, max_len)
  if !input return "" end
  var s = str(input)
  if s.size() > max_len s = s[0..max_len-1] end
  
  # Basic XSS prevention
  s = string.replace(s, '<', '&lt;')
  s = string.replace(s, '>', '&gt;') 
  s = string.replace(s, '"', '&quot;')
  s = string.replace(s, "'", '&#x27;')
  return s
end

def validate_appkey(key)
  if !key || key.size() != 32 return false end
  
  # Check hex characters only
  for i:0..key.size()-1
    var c = key[i]
    if !((c >= 48 && c <= 57) ||    # 0-9
         (c >= 65 && c <= 70) ||    # A-F  
         (c >= 97 && c <= 102))     # a-f
      return false
    end
  end
  return true
end

def validate_decoder_name(name)
  if !name || name.size() == 0 || name.size() > 50 return false end
  
  # Check for valid characters and .be extension
  if name.size() < 4 || name[-3..] != ".be" return false end
  
  for i:0..name.size()-1
    var c = name[i]
    if !((c >= 48 && c <= 57) ||    # 0-9
         (c >= 65 && c <= 90) ||    # A-Z
         (c >= 97 && c <= 122) ||   # a-z
         c == 45 || c == 46 || c == 95)  # - . _
      return false
    end
  end
  return true
end

# Get max nodes - cached for efficiency  
var cached_max_nodes = nil
def get_max_nodes()
  if !cached_max_nodes
    var enables = string.split(tasmota.cmd('LoRaWanNode', true).find('LoRaWanNode'), ',')
    cached_max_nodes = enables.size()
  end
  return cached_max_nodes
end

# Handle form submission - streamlined
def handle_lorawan_form()
  var node = int(webserver.arg('node'))
  if node < 1 || node > get_max_nodes()
    return "Invalid node number"
  end
  
  # Get form values
  var app_key = webserver.arg('ak')
  var device_name = webserver.arg('an') 
  var decoder = webserver.arg('dc')
  var enabled = webserver.has_arg('ce')
  
  # Validate inputs
  if !validate_appkey(app_key)
    return "Invalid application key format"
  end
  
  if decoder && decoder != "" && !validate_decoder_name(decoder)
    return "Invalid decoder file name"
  end
  
  device_name = validate_web_input(device_name, 50)
  
  # Apply configuration  
  try
    tasmota.cmd(format('LoRaWanAppKey%i %s', node, app_key), true)
    tasmota.cmd(format('LoRaWanDecoder%i %s', node, decoder ? decoder : '""'), true)
    tasmota.cmd(format('LoRaWanName%i %s', node, device_name ? device_name : '""'), true)
    tasmota.cmd(format('LoRaWanNode%i %s', node, enabled ? '1' : '0'), true)
    
    return format("Node %d configuration saved", node)
  except .. as e, m
    return format("Save failed: %s", m)
  end
end

# Generate minimal CSS - embedded
def generate_minimal_css()
  return '''<style>
.lw{max-width:800px;margin:0 auto;padding:10px}
.lw h2{color:var(--c_txt);margin:20px 0 10px 0}
.lw .tabs{display:flex;background:var(--c_frm);border-radius:8px 8px 0 0;margin:20px 0 0 0}
.lw .tab{flex:1;background:var(--c_tab);color:var(--c_tabtxt);border:none;padding:12px;cursor:pointer;font-size:14px}
.lw .tab:hover{background:var(--c_frm);color:var(--c_txt)}
.lw .tab.active{background:var(--c_frm);color:var(--c_txt);font-weight:bold}
.lw .form{background:var(--c_frm);padding:20px;border-radius:0 0 8px 8px;display:none}
.lw .form.active{display:block}
.lw label{display:block;margin:10px 0 5px 0;font-weight:bold}
.lw input[type="text"]{width:100%;padding:8px;border:1px solid var(--c_brd);border-radius:4px;background:var(--c_bg);color:var(--c_txt)}
.lw input[type="checkbox"]{margin-right:8px}
.lw .btn{background:var(--c_btn);color:var(--c_btntxt);border:none;padding:10px 20px;border-radius:4px;cursor:pointer;margin-top:15px}
.lw .btn:hover{opacity:0.9}
.lw .msg{padding:10px;margin:10px 0;border-radius:4px;background:var(--c_frm);border-left:4px solid var(--c_accent,#4CAF50)}
.lw .err{border-left-color:#f44336;background:rgba(244,67,54,0.1)}
</style>'''
end

# Generate JavaScript - minimal
def generate_minimal_js()
  var max_nodes = get_max_nodes()
  return format('''<script>
function selNode(n){
  var tabs=document.querySelectorAll('.tab');
  var forms=document.querySelectorAll('.form');
  tabs.forEach(function(t){t.classList.remove('active')});
  forms.forEach(function(f){f.classList.remove('active')});
  document.getElementById('t'+n).classList.add('active');
  document.getElementById('f'+n).classList.add('active');
}
function testDecoder(n){
  var decoder=document.getElementById('dc'+n).value;
  if(!decoder){alert('Enter decoder name first');return;}
  fetch('/cm?cmnd=LwDecoderLoad%%20'+encodeURIComponent(decoder))
    .then(function(r){return r.json()})
    .then(function(d){
      alert(d[decoder]==='Loaded'?'Decoder loaded successfully!':'Test failed: '+d[decoder]);
    })
    .catch(function(e){alert('Test failed: '+e.message)});
}
window.onload=function(){selNode(1)};
</script>''', max_nodes)
end

# Main page handler - streamlined
def page_lorawan()
  if !webserver.check_privileged_access() return nil end
  
  var message = ""
  var message_type = "msg"
  var current_node = 1
  
  # Handle form submission
  if webserver.has_arg('save')
    current_node = int(webserver.arg('node'))
    message = handle_lorawan_form()
    if string.find(message, "saved") >= 0
      message_type = "msg"
    else
      message_type = "err"
    end
  end
  
  webserver.content_start("LoRaWAN Configuration")
  webserver.content_send_style()
  webserver.content_send(generate_minimal_css())
  
  webserver.content_send('<div class="lw">')
  webserver.content_send('<h2>LoRaWAN End Device Configuration</h2>')
  
  # Show message if any
  if message != ""
    webserver.content_send(format('<div class="%s">%s</div>', message_type, validate_web_input(message, 200)))
  end
  
  # Get node configuration
  var max_nodes = get_max_nodes()
  var enables = string.split(tasmota.cmd('LoRaWanNode', true).find('LoRaWanNode'), ',')
  
  # Generate tabs
  webserver.content_send('<div class="tabs">')
  for i:1..max_nodes
    var active = (i == current_node) ? " active" : ""
    webserver.content_send(format('<button type="button" class="tab%s" id="t%d" onclick="selNode(%d)">Node %d</button>', 
                                 active, i, i, i))
  end
  webserver.content_send('</div>')
  
  # Generate forms
  for i:1..max_nodes
    var active = (i == current_node) ? " active" : ""
    var enabled = (enables[i-1][0] != '!') ? ' checked' : ''
    
    # Get current values
    var app_key = tasmota.cmd(format('LoRaWanAppKey%i', i), true).find(format('LoRaWanAppKey%i', i))
    var device_name = tasmota.cmd(format('LoRaWanName%i', i), true).find(format('LoRaWanName%i', i))  
    var decoder = tasmota.cmd(format('LoRaWanDecoder%i', i), true).find(format('LoRaWanDecoder%i', i))
    
    webserver.content_send(format('''
<div class="form%s" id="f%d">
  <form method="post">
    <label><input type="checkbox" name="ce"%s> Enabled</label>
    
    <label>Application Key (32 hex chars)</label>
    <input type="text" name="ak" value="%s" pattern="[A-Fa-f0-9]{32}" maxlength="32" required>
    
    <label>Device Name</label>
    <input type="text" name="an" value="%s" maxlength="50">
    
    <label>Decoder File (.be)</label>
    <input type="text" name="dc" id="dc%d" value="%s" pattern="[a-zA-Z0-9_\\-\\.]+\\.be$">
    
    <input type="hidden" name="node" value="%d">
    <button type="submit" name="save" class="btn">Save Configuration</button>
    <button type="button" class="btn" onclick="testDecoder(%d)">Test Decoder</button>
  </form>
</div>''', 
      active, i, enabled, 
      validate_web_input(app_key, 32), 
      validate_web_input(device_name, 50), 
      i, validate_web_input(decoder, 50), 
      i, i))
  end
  
  webserver.content_send('</div>')  # Close .lw
  webserver.content_send(generate_minimal_js())
  
  webserver.content_button(webserver.BUTTON_CONFIGURATION)
  webserver.content_stop()
end

# Status endpoint - minimal JSON
def ajax_status()
  if !webserver.check_privileged_access() return nil end
  
  var decoders = get_loaded_lw_decoders()
  var status = {
    'active_decoders': decoders.size(),
    'max_decoders': get_lw_config('max_decoders', 10),
    'timestamp': tasmota.rtc('local')
  }
  
  webserver.content_send('Content-Type: application/json\r\n\r\n')
  webserver.content_send(format('{"status":%s}', str(status)))
end

# Register web handlers - minimal setup
def register_lw_webui()
  # Main LoRaWAN config page
  webserver.on("/lrw", page_lorawan)
  
  # AJAX status endpoint  
  webserver.on("/lrw/status", ajax_status)
  
  # Add config button to main menu
  webserver.content_send("<p><form id=ac action='lrw' style='display: block;' method='get'><button>LoRaWAN</button></form></p>")
end

# Initialize web UI
register_lw_webui()

# Export for compatibility
var LwWebUIClass = {
  'page_lorawan': page_lorawan,
  'ajax_status': ajax_status
}