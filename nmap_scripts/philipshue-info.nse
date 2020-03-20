local nmap = require "nmap"
local http = require "http"
local stdnse = require "stdnse"
local string = require "string"
local shortport = require "shortport"
local json = require "json"

description = [[
The Philips Hue is a wireless lighting system. This script obtains
information from the web API of the Philips Hue Bridge. 

Tested on Philips Hue Bridge apiversion: 1.19.0 on 6/25/17.

References:
* http://websec.mx
* https://developers.meethue.com/philips-hue-api
]]

---
-- @usage nmap -p80 --script philipshue-info.nse <target>
--
-- @output
-- | phillipshue-info:
-- |   bridgeid: 001788FFFE2F3F58
-- |   swversion: 1705121051
-- |   replacesbridgeid:
-- |
-- |   datastoreversion: 61
-- |   factorynew: false
-- |   starterkitid:
-- |   apiversion: 1.19.0
-- |   modelid: BSB002
-- |   mac: 00:17:88:2f:3f:58
-- |_  name: Philips hue
--
-- @xmloutput
-- <elem key="bridgeid">001788FFFE2F3F58</elem>
-- <elem key="swversion">1705121051</elem>
-- <elem key="datastoreversion">61</elem>
-- <elem key="factorynew">false</elem>
-- <elem key="starterkitid"></elem>
-- <elem key="apiversion">1.19.0</elem>
-- <elem key="modelid">BSB002</elem>
-- <elem key="mac">00:17:88:2f:3f:58</elem>
-- <elem key="name">Philips hue</elem>
---

author = "Pedro Joaquin <pjoaquin()websec.mx>"
license = "Same as Nmap--See https://nmap.org/book/man-legal.html"
categories = {"discover", "version", "safe"}

portrule = shortport.portnumber(80)

local URI = '/api/config'

local function GetInformation(host, port)
  local response = http.get(host, port, URI)
  if response.body and response['body']:match("bridgeid") then
    local stat, output = json.parse(response.body)
    if stat then
	  return output

	else
	  errmsg = "Error parsing JSON from "..URI.." response: "..output
    end
  else
    errmsg = "No response or 'bridgeid' not found in response"
  end
    stdnse.debug1(errmsg)
    return nil, errmsg
end


action = function(host,port)
  return GetInformation(host, port)
end
