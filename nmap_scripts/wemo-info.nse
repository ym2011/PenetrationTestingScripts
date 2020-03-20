local nmap = require "nmap"
local http = require "http"
local stdnse = require "stdnse"
local string = require "string"
local shortport = require "shortport"

description = [[
The Belkin Wemo Switch is a network enabled power outlet. This scripts obtains
information from Belkin Wemo Switch including nearby wireless networks and the
current switch state (ON/OFF).

There is a separate NSE script that may be used for changing the switch state.
No authentication is required.

Valid on Belkin Wemo Switch version WeMo_WW_2.00.10966.PVT-OWRT-SNS on 6/24/17

References:
* http://websec.ca/blog/view/Belkin-Wemo-Switch-NMap-Scripts
* https://www.tripwire.com/state-of-security/featured/my-sector-story-root-shell-on-the-belkin-wemo-switch/
* https://www.exploitee.rs/index.php/Belkin_Wemo
]]

---
-- @usage nmap -p49152,49153,49154 --script wemo-info.nse <target>
--
-- @output
-- | wemo-info:
-- |   friendlyName: : Wemo Switch
-- |   deviceType: urn:Belkin:device:controllee:1
-- |   manufacturer: Belkin International Inc.
-- |   manufacturerURL: http://www.belkin.com
-- |   modelDescription: Belkin Plugin Socket 1.0
-- |   modelName: Socket
-- |   modelNumber: 1.0
-- |   modelURL: http://www.belkin.com/plugin/
-- |   serialNumber: 220333K0203A4E
-- |   UDN: uuid:Socket-1_0-220333K0203A4E
-- |   UPC: 123456789
-- |   macAddress: EC1A59EE48E3
-- |   firmwareVersion: WeMo_WW_2.00.10966.PVT-OWRT-SNS
-- |   iconVersion: 0|49154
-- |   binaryState: 1
-- |   Switch is currently turned: ON
-- |   Nearby wireless networks: Page:1/1/4$
-- | Visita Cozumel FTW|5|0|OPEN/NONE,
-- | PVGP-2|6|0|WPA1PSKWPA2PSK/TKIPAES,
-- | INFINITUM|8|65|WPA2PSK/AES,
-- |_INFINITUM|11|0|WPA1PSKWPA2PSK/TKIPAES,
--
-- @xmloutput
-- <elem key="deviceType">urn:Belkin:device:controllee:1</elem>
-- <elem key="manufacturer">Belkin International Inc.</elem>
-- <elem key="manufacturerURL">http://www.belkin.com</elem>
-- <elem key="modelDescription">Belkin Plugin Socket 1.0</elem>
-- <elem key="modelName">Socket</elem>
-- <elem key="modelNumber">1.0</elem>
-- <elem key="modelURL">http://www.belkin.com/plugin/</elem>
-- <elem key="serialNumber">220333K0203A4E</elem>
-- <elem key="UDN">uuid:Socket-1_0-220333K0203A4E</elem>
-- <elem key="UPC">123456789</elem>
-- <elem key="macAddress">EC1A59ED59C4</elem>
-- <elem key="firmwareVersion">WeMo_WW_2.00.10966.PVT-OWRT-SNS</elem>
-- <elem key="iconVersion">0|49153</elem>
-- <elem key="binaryState">1</elem>
-- <elem key="Switch is currently turned">ON</elem>
-- <elem key="Nearby wireless networks">Page:1/1/4$&#xa;Visita Cozumel FTW|5|0|OPEN/NONE,&#xa;PVGP-2|6|0|WPA1PSKWPA2PSK/TKIPAES,&#xa;INFINITUM|8|65|WPA2PSK/AES,&#xa;INFINITUM|11|0|WPA1PSKWPA2PSK/TKIPAES,&#xa;</elem>
---

author = "Pedro Joaquin <pjoaquin()websec.mx>"
license = "Same as Nmap--See https://nmap.org/book/man-legal.html"
categories = {"discover", "version", "safe"}

portrule = shortport.portnumber({49152,49153,49154})

local function GetInformation(host, port)
  local uri = '/setup.xml'
  local response = http.get(host, port, uri)

  if response['status-line'] and response['status-line']:match("200 OK") then
    --Verify parsing of XML from /setup.xml
    local deviceType = response['body']:match("<deviceType>([^<]*)</deviceType>")
    if not deviceType then
      stdnse.debug1("Problem with XML parsing")
      return nil,"Problem with XML parsing"
    end
	
    --Parse information from /setup.xml
    local output = stdnse.output_table()
    local keylist = {"friendlyName","deviceType","manufacturer","manufacturerURL","modelDescription", "modelName","modelName","modelNumber","modelURL","serialNumber","UDN","UPC","macAddress","firmwareVersion","iconVersion","binaryState"}
    for _,key in ipairs(keylist) do
      stdnse.debug1("Looking for : "..key)
      output[key] = response['body']:match("<"..key..">([^<]*)</"..key..">")
    end
	
    --Identify current Switch state
    local bstate="Switch is currently turned"
    if output["binaryState"] == "1" then
      output[bstate] = "ON"
    else
      output[bstate] = "OFF"
    end

    --Post request to obtain nearby wireless network information
    local req = '<?xml ?><s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><s:Body><u:GetApList xmlns:u="urn:Belkin:service:WiFiSetup1:1"></u:GetApList></s:Body></s:Envelope>'
    local path = "/upnp/control/WiFiSetup1"
	local options = {header={["SOAPACTION"]='"urn:Belkin:service:WiFiSetup1:1#GetApList"', ["Content-Type"]="text/xml"}}
	local result = http.post( host, port, path, options, nil, req)
	stdnse.debug1("Status-a : %s", result['status-line'] or "No Response")
    if result['status-line'] and result['status-line']:match("200 OK") then
	  output["Nearby wireless networks"] = result['body']:match("<ApList>([^<]*)</ApList>")
	else
	  stdnse.debug1("Status-b : %s", result['status-line'] or "No Response")
      return false, "Couldn't download file: " .. path
    end
	
    -- set the port version
    port.version.name = "http"
    port.version.name_confidence = 10
    port.version.product = output["modelDescription"] or nil
    port.version.version = output["firmwareVersion"] or nil
    port.version.devicetype = output["deviceType"] or nil
    table.insert(port.version.cpe, "cpe:/h:".. output["manufacturer"] .. ":" .. output["modelDescription"])

    nmap.set_port_version(host, port, "hardmatched")

    return output

  else
    stdnse.debug1("Could not open '%s'", uri)
    return false, "Could not open "..uri
  end
end

action = function(host,port)

  -- Identify servers that answer 200 to invalid HTTP requests and exit as these would invalidate the tests
  local status_404, result_404, _ = http.identify_404(host,port)
  if ( status_404 and result_404 == 200 ) then
    stdnse.debug1("Exiting due to ambiguous response from web server on %s:%s. All URIs return status 200.", host.ip, port.number)
    return nil
  end

  return GetInformation(host, port)
end
