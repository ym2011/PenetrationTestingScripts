local nmap = require "nmap"
local http = require "http"
local stdnse = require "stdnse"
local string = require "string"
local shortport = require "shortport"

description = [[
Trane Tracer SC is an intelligent field panel for communicating with HVAC equipment controllers. According to Trane U.S. Inc., Tracer SC is deployed across several sectors including Commercial Facilities and others.

Contents of specific directories on the Tracer SC are exposed with the web server application to unauthenticated users.

Valid on Trane Tracer SC version 4.40.1211 and below. Tested on 7/3/17.

References:
* http://websec.mx

]]

---
-- @usage nmap -p80 --script trane-info.nse <target>
--
-- @output
-- | trane-info:
-- |   serverName: TracerSC
-- |   serverTime: 2017-07-03T21:01:02-04:00
-- |   serverBootTime: 2017-06-25T03:14:38-04:00
-- |   vendorName: Trane
-- |   productName: Tracer SC
-- |   productVersion: v4.40.1211 (release)
-- |   kernelVersion: 2.6.30_HwVer12AB-hydra
-- |   hardwareType: HwVer12AB
-- |   hardwareSerialNumber: E15A#####
-- |   1:equipmentUri: /equipment/generic/generic/##
-- |   1:displayName: BOILER ROOMS
-- |   1:deviceName: BOILER ROOMS
-- |   1:equipmentFamily: Generic
-- |   1:roleDocument: BOILER_ROOMS
-- |   1:isOffline: false
-- |   2:equipmentUri: /equipment/generic/generic/##
-- |   2:displayName: BOILER ROOMS
-- |   2:deviceName: BOILER ROOMS
-- |   2:equipmentFamily: Generic
-- |   2:roleDocument: BOILER_ROOMS
-- |   2:isOffline: false
-- |   3:equipmentUri: /equipment/generic/generic/##
-- |   3:displayName: EXHAUSTS 3 RM-6
-- |   3:deviceName: EXHAUSTS 3 RM-6
-- |   3:equipmentFamily: Generic
-- |   3:roleDocument: EXHAUSTS_3_RM-6
-- |   3:isOffline: false
--
-- @xmloutput
-- <elem key="serverName">TracerSC </elem>
-- <elem key="serverTime">2017-07-03T21:01:02-04:00 </elem>
-- <elem key="serverBootTime">2017-06-25T03:14:38-04:00 </elem>
-- <elem key="vendorName">Trane </elem>
-- <elem key="productName">Tracer SC </elem>
-- <elem key="productVersion">v4.40.1211 (release) </elem>
-- -- <elem key="kernelVersion">2.6.30_HwVer12AB-hydra </elem>
-- <elem key="hardwareType">HwVer12AB </elem>
-- <elem key="hardwareSerialNumber">E15A##### </elem>
-- <elem key="1:equipmentUri">/equipment/generic/generic/## </elem>
-- <elem key="1:displayName">BOILER ROOMS </elem>
-- <elem key="1:deviceName">BOILER ROOMS </elem>
-- <elem key="1:equipmentFamily">Generic </elem>
-- <elem key="1:roleDocument">BOILER_ROOMS </elem>
-- <elem key="1:isOffline">false </elem>
-- <elem key="2:equipmentUri">/equipment/generic/generic/## </elem>
-- <elem key="2:displayName">BOILER ROOMS </elem>
-- <elem key="2:deviceName">BOILER ROOMS </elem>
-- <elem key="2:equipmentFamily">Generic </elem>
-- <elem key="2:roleDocument">BOILER_ROOMS </elem>
-- <elem key="2:isOffline">false </elem>
-- <elem key="3:equipmentUri">/equipment/generic/generic/## </elem>
-- <elem key="3:displayName">EXHAUSTS 3 RM-6 </elem>
-- <elem key="3:deviceName">EXHAUSTS 3 RM-6 </elem>
-- <elem key="3:equipmentFamily">Generic </elem>
-- <elem key="3:roleDocument">EXHAUSTS_3_RM-6 </elem>
-- <elem key="3:isOffline">false </elem>
---

author = "Pedro Joaquin <pjoaquin()websec.mx>"
license = "Same as Nmap--See https://nmap.org/book/man-legal.html"
categories = {"discover", "version", "safe"}

portrule = shortport.portnumber({80})

	
local function GetInformation(host, port)
local output = stdnse.output_table()

  --Get information from /evox/about
  local uri = '/evox/about'
  local response = http.get(host, port, uri)
  if response['status-line'] and response['status-line']:match("200") then
    --Verify parsing of XML from /evox/about
    local deviceType = response['body']:match('serverName" val=([^<]*)/>')
    if not deviceType then
      stdnse.debug1("Problem with XML parsing of /evox/about")
      return nil,"Problem with XML parsing of /evox/about"
	end
	--Parse information from /evox/about
    local keylist = {"serverName","serverTime","serverBootTime","vendorName","productName","productVersion","kernelVersion","hardwareType","hardwareSerialNumber"}
    for _,key in ipairs(keylist) do
      stdnse.debug1("Looking for : "..key)
      output[key] = response['body']:match(key..'" val=([^<]*)/>')
	  stdnse.debug1("Found : "..output[key])
	  output[key] = output[key]:gsub('"', "")
    end

	
	
  --Get information from /evox/equipment/installedSummary
  local uri = '/evox/equipment/installedSummary'
  local response = http.get(host, port, uri)
  if response['status-line'] and response['status-line']:match("200") then
    --Verify parsing of XML from /evox/equipment/installedSummary
	local error = response['body']:match('Error code: 00017')
	if error then
	  stdnse.debug1("/evox/equipment/installedSummary is not available")
	end
    local equipmentUri = response['body']:match('equipmentUri" val=([^<]*)/>')
    if not equipmentUri then
      stdnse.debug1("Problem with XML parsing")
	end
  
    if not error then
	  --Parse information from /evox/equipment/installedSummary
      local keylist = {"equipmentUri","displayName","deviceName","equipmentFamily","roleDocument","isOffline"}

	  local _,lastequipmentUri = response['body']:find(".*equipmentUri")
	  stdnse.debug1("lastequipmentUri : "..lastequipmentUri)
	  local count = 1
	  local nextequipmentUri = 1
	  while nextequipmentUri < lastequipmentUri do
        for _,key in ipairs(keylist) do
          stdnse.debug1("Looking for : "..key)
          output[count..":"..key] = response['body']:match(key..'" val=([^<]*)/>',nextequipmentUri)
		  if output[count..":"..key] == nil then
		    output[count..":"..key] = "Not available"
		  else
		    output[count..":"..key] = output[count..":"..key]:gsub('"', "")
		    stdnse.debug1("Found : "..output[count..":"..key])
		  end
	    end
        _,nextequipmentUri = response['body']:find("equipmentUri",nextequipmentUri)
	    count = count + 1
	    stdnse.debug1("Count : "..count)
	  end
	end
  end
	
stdnse.debug1("status-line: "..response['status-line'])
	local error = response['status-line']:match('Error')
	if error then
      stdnse.debug1("Request returned a network error.")
	  return nil, "Request returned a network error."
	end
    -- Set the port version
    port.version.name = "http"
    port.version.name_confidence = 10
    port.version.product = output["productName"] 
    port.version.version = output["productVersion"] 
    port.version.devicetype = output["hardwareType"] 
   table.insert(port.version.cpe, "cpe:/h:".. output["vendorName"] .. ":" .. output["productName"])

    nmap.set_port_version(host, port, "hardmatched")
	return output
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