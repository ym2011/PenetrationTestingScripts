local comm = require "comm"
local string = require "string"
local table = require "table"
local shortport = require "shortport"
local nmap = require "nmap"
local stdnse = require "stdnse"
local U = require "lpeg-utility"
local http = require "http"
local snmp = require "snmp"
local sslcert = require "sslcert"
local tls = require "tls"
local url = require "url"
local json = require "json"

description = [[
Search SD-WAN products from SDWAN NewHope research project database by
- server name
- http titles
- snmp descriptions
- ssl certificates

The search database is based on census.md document with SD-WAN products search queries.
Also this script is based on:
- http-server-header NSE script by Daniel Miller
- http-title NSE script by Diman Todorov
- snmp-sysdescr NSE script by Thomas Buchanan
- ssl-cert NSE script by David Fifield

Installation 
$ git clone https://github.com/sdnewhop/sdwan-infiltrator
$ cd /sdwan-infiltrator/
$ sudo cp * /usr/share/nmap/scripts/
$ sudo nmap --script infiltrator --script-args infiltrator.version=true -sS -sU -p U:161,T:80,443,8008,8080,8443 <target> or -iL <targets.txt>
]]


-- 
-- @usage
-- nmap --script=infiltrator.nse -sS -sU -p U:161,T:80,443,8008,8080,8443 <target> or -iL <targets.txt>
-- 
-- @output
-- | infiltrator:
-- |   status: success
-- |   method: server
-- |   product: <product name>
-- |   host_addr: ...
-- |   host_port: 443
-- |_  version: ...
-- ...
-- | infiltrator:
-- |   status: success
-- |   method: title
-- |   product: <product name>
-- |   host_addr: ...
-- |   host_port: 443
-- |_  version: ...
-- ...
-- | infiltrator:
-- |   status: success
-- |   method: snmp
-- |   product: <product name>
-- |   host_addr: ...
-- |   host_port: 161
-- |_  version: ...
-- ...
-- | infiltrator:
-- |   status: success
-- |   method: SSL certificate
-- |   product: <product name>
-- |   host_addr: ...
-- |   host_port: 443
-- |_  version: ...


author = "sdnewhop"
license = "Same as Nmap--See https://nmap.org/book/man-legal.html"
categories = {"default", "discovery", "safe"}


portrule = shortport.portnumber({80, 161, 443, 8008, 8080, 8443}, {"tcp", "udp"}, {"open"})

SDWANS_BY_SSL_TABLE = {
  ["Cisco SD-WAN"] = {"Viptela Inc"},
  ["Versa Analytics"] = {"versa%-analytics"},
  ["Versa Director"] = {"director%-1", "versa%-director"},
  ["Riverbed SteelHead"] = {"Riverbed Technology"},
  ["Silver Peak Unity Orchestrator"] = {"Silverpeak GMS"},
  ["Silver Peak Unity EdgeConnect"] = {"silver%-peak", "Silver Peak Systems Inc"},
  ["CloudGenix SD-WAN"] = {"CloudGenix Inc."},
  ["Talari SD-WAN"] = {"Talari", "Talari Networks"},
  ["InfoVista SALSA"] = {"SALSA Portal"},
  ["Barracuda CloudGen Firewall"] = {"Barracuda CloudGen Firewall", "Barracuda Networks"},
  ["Viprinet Virtual VPN Hub"] = {"Viprinet"},
  ["Citrix Netscaler SD-WAN"] = {"Citrix Systems"},
  ["Fortinet FortiGate SD-WAN"] = {"FGT%-", "FortiGate"}
}

SDWANS_BY_SNMP_TABLE = {
    ["Fatpipe SYMPHONY SD-WAN"] = {"Linux Fatpipe"},
    ["Versa Analytics"] = {"Linux versa%-analytics"},
    ["Juniper Networks Contrail SD-WAN"] = {"Juniper Networks, Inc. srx"},
    ["Aryaka Network Access Point"] = {"Aryaka Networks Access Point"},
    ["Arista Networks EOS"] = {"Arista Networks EOS"},
    ["Viprinet Virtual VPN Hub"]= {"Viprinet VPN Router"}
}

SDWANS_BY_TITLE_TABLE = {
    ["VMWare NSX SD-WAN"] = {"VeloCloud", "VeloCloud Orchestrator"},
    ["TELoIP VINO SD-WAN"] = {"Teloip Orchestrator API"},
    ["Fatpipe SYMPHONY SD-WAN"] = {"WARP"},
    ["Cisco SD-WAN"] = {"Viptela vManage", "Cisco vManage"},
    ["Versa Flex VNF"] = {"Flex VNF"},
    ["Versa Director"] = {"Versa Director Login"},
    ["Riverbed SteelConnect"] = {"SteelConnect Manager", "Riverbed AWS Appliance"},
    ["Riverbed SteelHead"] = {"amnesiac Sign in"},
    ["Citrix NetScaler SD-WAN VPX"] = {"Citrix NetScaler SD%-WAN %- Login"},
    ["Citrix NetScaler SD-WAN Center"] = {"SD%-WAN Center | Login"},
    ["Citrix Netscaler SD-WAN"] = {"DC | Login"},
    ["Silver Peak Unity Orchestrator"] = {"Welcome to Unity Orchestrator"},
    ["Silver Peak Unity EdgeConnect"] = {"Silver Peak Appliance Management Console"},
    ["Ecessa WANworX SD-WAN"] = {"Ecessa"},
    ["Nuage Networks SD-WAN (VNS)"] = {"SD%-WAN Portal", "Architect", "VNS portal"}, 
    ["Juniper Networks Contrail SD-WAN"] = {"Log In %- Juniper Networks Web Management"},
    ["Talari SD-WAN"] = {"AWS"},
    ["Aryaka Network Access Point"] = {"Aryaka Networks", "Aryaka, Welcome"},
    ["InfoVista SALSA"] = {"SALSA Login"},
    ["Huawei SD-WAN"] = {"Agile Controller"},
    ["Sonus SBC Management Application"] = {"SBC Management Application"},
    ["Sonus SBC Edge"] = {"Sonus SBC Edge Web Interface"},
    ["Arista Networks EOS"] = {"Arista Networks EOS"},
    ["128 Technology Networking Platform"] = {"128T Networking Platform"},
    ["Gluware Control"] = {"Gluware Control"},
    ["Barracuda CloudGen Firewall"] = {"Barracuda CloudGen Firewall"},
    ["Viprinet Virtual VPN Hub"] = {"Viprinet %- AdminDesk %- Login"},
    ["Viprinet Traffic Tools"] = {"Viprinet traffic tools"},
    ["Cradlepoint SD-WAN"] = {"Login :: CR4250%-PoE", "Login :: AER2200%-600M"},
    ["Brain4Net Orchestrator"] = {"B4N ORC"},
    ["Fortinet FortiManager"] = {"FortiManager%-VM64"}
  }

SDWANS_BY_SERVER_TABLE = {
      ["Versa Director"] = {"Versa Director"},
      ["Versa Analytics"] = {"Versa%-Analytics%-Server"},
      ["Barracuda CloudGen Firewall"] = {"Barracuda CloudGen Firewall"},
      ["Viprinet Virtual VPN Hub"] = {"ViprinetHubReplacement", "Viprinet"}
  }

-------------------------------------------------------------------------------
-- version gathering block
-------------------------------------------------------------------------------

local function vbrain(host, port)
  local path = stdnse.get_script_args(SCRIPT_NAME .. ".path") or "/api/version"
  local response
  local output_info = {}
  local vsdwan = ""
  local urlp = path

  response = http.generic_request(host, port, "GET", path)

  if response.status == 301 or response.status == 302 then
    local url_parse_res = url.parse(response.header.location)
    urlp = url_parse_res.path
    stdnse.print_debug("Status code: " .. response.status)
    response = http.generic_request(host,port,"GET", urlp)
  end

  output_info = stdnse.output_table()

  if response == nil then
    return fail("Request failed")
  end

  local try_counter = 1

  while try_counter < 6 and response.status ~= 200 do
    response = http.generic_request(host, port, "GET", urlp) 

    found, matches = http.response_contains(response, '0;url%=(.*)"%/%>')

    if found == true then 
      local urltmp = url.parse(matches[1])
      urlp = urltmp.path
      response = http.generic_request(host, port, "GET", urlp)
      try_counter = 1
    end
    try_counter = try_counter + 1
  end

  if response.status == 200 then

    found, matches = http.response_contains(response, '"build":"(.+)",', false)
    if found == true then vsdwan = matches[1] else return nil end
    
    output_info.vsdwan_version = {}
    table.insert(output_info.vsdwan_version, "Brain4Net Orchestrator Version: " .. vsdwan)
  end

  return output_info, stdnse.format_output(true, output_info)
end

local function vcradlepoint(host, port)
  local path = stdnse.get_script_args(SCRIPT_NAME .. ".path") or "/login/?referer=/admin/"
  local response
  local output_info = {}
  local vsdwan = ""
  local urlp = path

  response = http.generic_request(host, port, "GET", path)

  if response.status == 301 or response.status == 302 then
    local url_parse_res = url.parse(response.header.location)
    urlp = url_parse_res.path
    stdnse.print_debug("Status code: " .. response.status)
    response = http.generic_request(host,port,"GET", urlp)
  end

  output_info = stdnse.output_table()

  if response == nil then
    return fail("Request failed")
  end

  local try_counter = 1

  while try_counter < 6 and response.status ~= 200 do
    response = http.generic_request(host, port, "GET", urlp) 
    try_counter = try_counter + 1
  end

  if response.status == 200 then
    found, matches = http.response_contains(response, "([0-9.]+[0-9]) .[a-zA-Z]+.[a-zA-Z]+.[0-9]+.[0-9]+:[0-9]+:[0-9]+", false)
    if found == true then vsdwan = matches[1] else return nil end
    
    output_info.vsdwan_version = {}
    table.insert(output_info.vsdwan_version, "Cradlepoint App Version: " .. vsdwan)
  end

  return output_info, stdnse.format_output(true, output_info)
end

local function vcitrix(host, port)
  local path = stdnse.get_script_args(SCRIPT_NAME .. ".path") or "/"
  local response
  local output_info = {}
  local vsdwan = ""
  local urlp = path
  response = http.generic_request(host, port, "GET", path)
  if response.status == 301 or response.status == 302 then
    local url_parse_res = url.parse(response.header.location)
    urlp = url_parse_res.path
    -- stdnse.print_debug("Status code: " .. response.status)
    response = http.generic_request(host,port,"GET", urlp)
  end

  output_info = stdnse.output_table()
  if response == nil then
    return fail("Request failed")
  end

  local try_counter = 1
  while try_counter < 30 and response.status ~= 200 do
    response = http.generic_request(host, port, "GET", urlp) 
    try_counter = try_counter + 1
  end

  if response.status == 200 then
    found, matches = http.response_contains(response, "css%?v%=([.0-9]+)", false)
    if found == true then vsdwan = matches[1] else return nil end
    output_info.vsdwan_version = {}
    table.insert(output_info.vsdwan_version, "Citrix NetScaler Version: " .. vsdwan)
  end

  return output_info, stdnse.format_output(true, output_info)

end


local function vfatpipe(host, port)
  local path = stdnse.get_script_args(SCRIPT_NAME .. ".path") or "/"
  local response
  local output_info = {}
  local vsdwan = ""
  local urlp = path

  response = http.generic_request(host, port, "GET", path)

  if response.status == 301 or response.status == 302 then
    local url_parse_res = url.parse(response.header.location)
    urlp = url_parse_res.path
    stdnse.print_debug("Status code: " .. response.status)
    response = http.generic_request(host,port,"GET", urlp)
  end

  output_info = stdnse.output_table()

  if response == nil then
    return fail("Request failed")
  end

  local try_counter = 1

  while try_counter < 6 and response.status ~= 200 do
    response = http.generic_request(host, port, "GET", urlp) 
    try_counter = try_counter + 1
  end

  if response.status == 200 then

    found, matches = http.response_contains(response, "<h5>([r.0-9]+)</h5>", false)
    if found == true then vsdwan = matches[1] else return nil end
    
    output_info.vsdwan_version = {}
    table.insert(output_info.vsdwan_version, "Fatpipe Version: " .. vsdwan)
  end

  return output_info, stdnse.format_output(true, output_info)

end


local function vnuage(host, port)
  local path = stdnse.get_script_args(SCRIPT_NAME .. ".path") or "/"
  local response
  local output_info = {}
  local vsdwan = ""
  local urlp = path

  response = http.generic_request(host, port, "GET", path)

  if response.status == 301 or response.status == 302 then
    local url_parse_res = url.parse(response.header.location)
    urlp = url_parse_res.path
    stdnse.print_debug("Status code: " .. response.status)
    response = http.generic_request(host,port,"GET", urlp)
  end

  output_info = stdnse.output_table()

  if response == nil then
    return fail("Request failed")
  end

  local try_counter = 1

  while try_counter < 6 and response.status ~= 200 do
    response = http.generic_request(host, port, "GET", urlp) 
    try_counter = try_counter + 1
  end

  if response.status == 200 then

    found, matches = http.response_contains(response, 'ng%-version="([.0-9]+)"', false)
    if found == true then vsdwan = matches[1] else return nil end
    
    output_info.vsdwan_version = {}
    table.insert(output_info.vsdwan_version, "Nuage Version: " .. vsdwan)
  end

  return output_info, stdnse.format_output(true, output_info)

end


local function vriverbed(host, port)
  local path = stdnse.get_script_args(SCRIPT_NAME .. ".path") or "/"
  local response
  local output_info = {}
  local vsdwan = ""
  local urlp = path

  response = http.generic_request(host, port, "GET", path)

  if response.status == 301 or response.status == 302 then
    local url_parse_res = url.parse(response.header.location)
    urlp = url_parse_res.path
    stdnse.print_debug("Status code: " .. response.status)
    response = http.generic_request(host,port,"GET", urlp)
  end

  output_info = stdnse.output_table()

  if response == nil then
    return fail("Request failed")
  end

  local try_counter = 1

  while try_counter < 6 and response.status ~= 200 do
    response = http.generic_request(host, port, "GET", urlp) 
    try_counter = try_counter + 1
  end

  if response.status == 200 then

    found, matches = http.response_contains(response, "web3 v([.0-9]+)", false)
    if found == true then vsdwan = matches[1] else return nil end
    
    output_info.vsdwan_version = {}
    table.insert(output_info.vsdwan_version, "Riverbed Version: " .. vsdwan)
  end

  return output_info, stdnse.format_output(true, output_info)

end


local function vsilverpeak(host, port)
  local path = stdnse.get_script_args(SCRIPT_NAME .. ".path") or "/"
  local response
  local output_info = {}
  local vsdwan = ""
  local urlp = path

  response = http.generic_request(host, port, "GET", path)

  output_info = stdnse.output_table()

  if response == nil then
    return fail("Request failed")
  end

  if response.status == 302 then

    found, matches = http.response_contains(response, "http.*/([.0-9]+)/", false)
    if found == true then vsdwan = matches[1] else return nil end
    
    output_info.vsdwan_version = {}
    table.insert(output_info.vsdwan_version, "SilverPeak Version: " .. vsdwan)
  end

  return output_info, stdnse.format_output(true, output_info)

end

local function vsilverpeak_login(host, port)
  local output_info = {}
  output_info.login = {}
  local monitor_check = "/rest/json/login?user=monitor&password=monitor"
  local admin_check = "/rest/json/login?user=admin&password=admin"

  local resp_monitor = http.get(host, port, monitor_check)
  if not resp_monitor.status then
    -- force check on 80 port if empty response from 443 (by default)
    resp_monitor = http.get(host, 80, monitor_check)
  end
  if resp_monitor.status == 200 then
    table.insert(output_info.login, "Authentication successful (monitor:monitor)")
  end

  local resp_admin = http.get(host, port, admin_check)
  if not resp_admin.status then
    -- force check on 80 port if empty response from 443 (by default)
    resp_admin = http.get(host, 80, admin_check)
  end
  if resp_admin.status == 200 then
    table.insert(output_info.login, "Authentication successful (admin:admin)")
  end

  if next(output_info.login) ~= nil then
    return output_info, stdnse.format_output(true, output_info)
  end
end


local function vsonus_edge(host, port)
  local path = stdnse.get_script_args(SCRIPT_NAME .. ".path") or "/cgi/index.php"
  local response
  local output_info = {}
  local vsdwan = ""
  local urlp = path

  response = http.generic_request(host, port, "GET", path)

  if response.status == 301 or response.status == 302 then
    local url_parse_res = url.parse(response.header.location)
    urlp = url_parse_res.path
    stdnse.print_debug("Status code: " .. response.status)
    response = http.generic_request(host,port,"GET", urlp)
  end

  output_info = stdnse.output_table()

  if response == nil then
    return fail("Request failed")
  end

  local try_counter = 1

  while try_counter < 6 and response.status ~= 200 do
    response = http.generic_request(host, port, "GET", urlp) 
    try_counter = try_counter + 1
  end

  if response.status == 200 then

    found, matches = http.response_contains(response, "/style/([.0-9]+)%-[0-9]+%_rel", false)
    if found == true then vsdwan = matches[1] else return nil end
    
    output_info.vsdwan_version = {}
    table.insert(output_info.vsdwan_version, "Sonus Edge Version: " .. vsdwan)
  end

  return output_info, stdnse.format_output(true, output_info)

end


local function vsonus_mgmt(host, port)
  local path = stdnse.get_script_args(SCRIPT_NAME .. ".path") or "/"
  local response
  local output_info = {}
  local vsdwan = ""
  local urlp = path

  response = http.generic_request(host, port, "GET", path)

  if response.status == 301 or response.status == 302 then
    local url_parse_res = url.parse(response.header.location)
    urlp = url_parse_res.path
    stdnse.print_debug("Status code: " .. response.status)
    response = http.generic_request(host,port,"GET", urlp)
  end

  output_info = stdnse.output_table()

  if response == nil then
    return fail("Request failed")
  end

  local try_counter = 1

  while try_counter < 6 and (response.status ~= 503 or response.status ~= 200) do
    response = http.generic_request(host, port, "GET", urlp) 
    try_counter = try_counter + 1
  end

  if response.status == 503 or response.status == 200 then

    found, matches = http.response_contains(response, "EMA ([.0-9]+)", false)
    if found == true then vsdwan = matches[1] else return nil end
    
    output_info.vsdwan_version = {}
    table.insert(output_info.vsdwan_version, "Sonus Mgmt App Version: " .. vsdwan)
  end

  return output_info, stdnse.format_output(true, output_info)

end


local function vtalari(host, port)
  local path = stdnse.get_script_args(SCRIPT_NAME .. ".path") or "/"
  local response
  local output_info = {}
  local vsdwan = ""
  local urlp = path

  response = http.generic_request(host, port, "GET", path)

  if response.status == 301 or response.status == 302 then
    local url_parse_res = url.parse(response.header.location)
    urlp = url_parse_res.path
    stdnse.print_debug("Status code: " .. response.status)
    response = http.generic_request(host,port,"GET", urlp)
  end

  output_info = stdnse.output_table()

  if response == nil then
    return fail("Request failed")
  end

  local try_counter = 1

  while try_counter < 6 and response.status ~= 200 do
    response = http.generic_request(host, port, "GET", urlp) 
    try_counter = try_counter + 1
  end

  if response.status == 200 then

    found, matches = http.response_contains(response, 'talari%.css%?([_.0-9A-Za-z]+)"', false)
    if found == true then vsdwan = matches[1] else return nil end
    
    output_info.vsdwan_version = {}
    table.insert(output_info.vsdwan_version, "Talari Version: " .. vsdwan)
  end

  return output_info, stdnse.format_output(true, output_info)

end


local function vversa_analytics(host, port)
  local path = stdnse.get_script_args(SCRIPT_NAME .. ".path") or "/versa/app/js/common/constants.js"
  local response
  local output_info = {}
  local vsdwan = ""
  local urlp = path

  response = http.generic_request(host, port, "GET", path)

  if response.status == 301 or response.status == 302 then
    local url_parse_res = url.parse(response.header.location)
    urlp = url_parse_res.path
    stdnse.print_debug("Status code: " .. response.status)
    response = http.generic_request(host,port,"GET", urlp)
  end

  output_info = stdnse.output_table()

  if response == nil then
    return fail("Request failed")
  end

  local try_counter = 1

  while try_counter < 6 and response.status ~= 200 do
    response = http.generic_request(host, port, "GET", urlp) 

    found, matches = http.response_contains(response, '0;url%=(.*)"%/%>')

    if found == true then 
      local urltmp = url.parse(matches[1])
      urlp = urltmp.path
      response = http.generic_request(host, port, "GET", urlp)
      try_counter = 1
    end
    try_counter = try_counter + 1
  end

  if response.status == 200 then

    found, matches = http.response_contains(response, "%/analytics%/([v.0-9]+)%/", false)
    if found == true then vsdwan = matches[1] else return nil end
    
    output_info.vsdwan_version = {}
    table.insert(output_info.vsdwan_version, "Versa Analytics Version: " .. vsdwan)
  end

  return output_info, stdnse.format_output(true, output_info)

end


local function vversa_flex(host, port)
  local path = stdnse.get_script_args(SCRIPT_NAME .. ".path") or "/scripts/main-layout/main-layout-controller.js"
  local response
  local output_info = {}
  local vsdwan = ""
  local urlp = path

  response = http.generic_request(host, port, "GET", path)

  if response.status == 301 or response.status == 302 then
    local url_parse_res = url.parse(response.header.location)
    urlp = url_parse_res.path
    stdnse.print_debug("Status code: " .. response.status)
    response = http.generic_request(host,port,"GET", urlp)
  end

  output_info = stdnse.output_table()

  if response == nil then
    return fail("Request failed")
  end

  local try_counter = 1

  while try_counter < 6 and response.status ~= 200 do
    response = http.generic_request(host, port, "GET", urlp) 
    try_counter = try_counter + 1
  end

  if response.status == 200 then

    found, matches = http.response_contains(response, '"versa%-flexvnf%-([.0-9%-a-zA-Z]+)', false)
    if found == true then vsdwan = matches[1] else return nil end
    
    output_info.vsdwan_version = {}
    table.insert(output_info.vsdwan_version, "Versa Flex Version: " .. vsdwan)
  end

  return output_info, stdnse.format_output(true, output_info)

end


local function vvmware_nsx(host, port)
  local path = stdnse.get_script_args(SCRIPT_NAME .. ".path") or "/"
  local response
  local output_info = {}
  local vsdwan = ""
  local urlp = path

  response = http.generic_request(host, port, "GET", path)

  if response.status == 301 or response.status == 302 then
    local url_parse_res = url.parse(response.header.location)
    urlp = url_parse_res.path
    stdnse.print_debug("Status code: " .. response.status)
    response = http.generic_request(host,port,"GET", urlp)
  end

  output_info = stdnse.output_table()

  if response == nil then
    return fail("Request failed")
  end

  local try_counter = 1

  while try_counter < 6 and response.status ~= 200 do
    response = http.generic_request(host, port, "GET", urlp) 
    try_counter = try_counter + 1
  end

  if response.status == 200 then

    found, matches = http.response_contains(response, "%/vco%-ui.([0-9.]+).", false)
    if found == true then vsdwan = matches[1] else return nil end
    
    output_info.vsdwan_version = {}
    table.insert(output_info.vsdwan_version, "VMware NSX Version: " .. vsdwan)
  end

  return output_info, stdnse.format_output(true, output_info)

end


local function fortinet(host, port)
  local resp_js_path, js_path, resp_js
  local conf_build, conf_model, conf_label
  local output_info = {}
  local version

  -- trigger 401 error to find path to js file with version
  resp_js_path = http.get(host, port, "/api")
  if not resp_js_path.body then
    return nil
  end

  -- search for js file that contains version
  js_path = string.match(resp_js_path.body:lower(), "<script src=\"(/%w+/fweb_all.js)")
  if not js_path then
    return nil
  end
  stdnse.print_debug("Found js path: " .. js_path)

  -- get founded js and grep for version
  resp_js = http.get(host, port, js_path)
  if not resp_js_path.body then
    return nil
  end
  stdnse.print_debug("Js - founded")

  -- parse versions
  conf_build = string.match(resp_js.body, "CONFIG_BUILD_NUMBER:(%d+)")
  conf_model = string.match(resp_js.body, "CONFIG_MODEL:\"([%w_]+)\"")
  conf_label = string.match(resp_js.body, "CONFIG_BUILD_LABEL:\"([%w_]+)\"")
  if (not conf_build) or (not conf_model) or (not conf_label) then
    return nil
  end

  output_info = stdnse.output_table()
  output_info.vsdwan_version = {}

  version = "build " .. conf_build .. ", model " .. conf_model .. " (" .. conf_label .. ")"
  table.insert(output_info.vsdwan_version, "Fortinet FortiGate Version: " .. version)
  return output_info, stdnse.format_output(true, output_info)
end


local function vversa_analytics_server(host, port)
  local path = stdnse.get_script_args(SCRIPT_NAME .. ".path") or "/versa/analytics/version"
  local response
  local output_info = {}
  local vsdwan = ""
  local urlp = path
  local auth_credentials = {}
  auth_credentials.username = 'vanclient'
  auth_credentials.password = '88347b9e8s6$90d9f31te366&d5be77'
  local options = {}
  options.auth = auth_credentials

  response = http.generic_request(host, port, "GET", path)

  if response.status == 301 or response.status == 302 then
    local url_parse_res = url.parse(response.header.location)
    urlp = url_parse_res.path
    stdnse.print_debug("Status code: " .. response.status)
    response = http.generic_request(host,port,"GET", urlp)
  end

  output_info = stdnse.output_table()
  if response == nil then
    return fail("Request failed")
  end

  local try_counter = 1
  while try_counter < 6 and response.status ~= 200 do
    response = http.generic_request(host, port, "GET", urlp)
    found, matches = http.response_contains(response, '0;url%=(.*)"%/%>')
    if found == true then
      local urltmp = url.parse(matches[1])
      urlp = urltmp.path
      response = http.generic_request(host, port, "GET", urlp)
      try_counter = 1
    end
    try_counter = try_counter + 1
  end

  if response.status == 200 then
    found, matches = http.response_contains(response, '"release":"([%w.]+)",', false)
    if found == true then vsdwan = matches[1] else return nil end
    output_info.vsdwan_version = {}
    table.insert(output_info.vsdwan_version, "Versa Analytics Server Version: " .. vsdwan)
  end

  response = http.generic_request(host, 5000, "GET", "/", options)
  if response.status == 200 and response.body ~= nil then
    output_info.additional_version = response.body
  end

  response = http.generic_request(host, 5000, "GET", "/analytics/system/info", options)
  if response.status == 200 and response.body ~= nil then
    status, json_repr = json.parse(response.body)
    if status == true then
      output_info.sys_info = json_repr
    end
  end

  response = http.generic_request(host, 5000, "GET", "/analytics/tools/status", options)
  if response.status == 200 and response.body ~= nil then
    status, json_repr = json.parse(response.body)
    if status == true then
      output_info.sys_status = json_repr
    end
  end

  return output_info, stdnse.format_output(true, output_info)

end


-------------------------------------------------------------------------------
-- version functions call table
-------------------------------------------------------------------------------

VERSION_CALL_TABLE = {
  ["Citrix NetScaler SD-WAN VPX"] = {version = vcitrix},
  ["Citrix NetScaler SD-WAN Center"] = {version = vcitrix},
  ["Citrix Netscaler SD-WAN"] = {version = vcitrix},
  ["Fatpipe SYMPHONY SD-WAN"] = {version = vfatpipe},
  ["Nuage Networks SD-WAN (VNS)"] = {version = vnuage},
  ["Riverbed SteelHead"] = {version = vriverbed},
  ["Riverbed SteelConnect"] = {version = vriverbed},
  ["Silver Peak Unity Orchestrator"] = {version = vsilverpeak},
  ["Silver Peak Unity EdgeConnect"] = {version = vsilverpeak},
  ["Silver Peak Unity EdgeConnect"] = {version = vsilverpeak_login},
  ["Sonus SBC Management Application"] = {version = vsonus_mgmt},
  ["Sonus SBC Edge"] = {version = vsonus_edge},
  ["Talari SD-WAN"] = {version = vtalari},
  ["Versa Analytics"] = {version = vversa_analytics},
  ["Versa Analytics"] = {version = vversa_analytics_server},
  ["Versa Flex VNF"] = {version = vversa_flex},
  ["VMWare NSX SD-WAN"] = {version = vvmware_nsx},
  ["Cradlepoint SD-WAN"] = {version = vcradlepoint},
  ["Brain4Net Orchestrator"] = {version = vbrain},
  ["Fortinet FortiGate SD-WAN"] = {version = fortinet}
}

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

local function get_version(product, host, port)
  local version = nil
  for version_product, _ in pairs(VERSION_CALL_TABLE) do
    -- check if product in version list
    if version_product == product then
        version = VERSION_CALL_TABLE[product].version(host, port)
        if version ~= nil then
          return version
        end
    end
  end
  return version
end

local function ssl_name_to_table(name)
  local output = {}
  for k, v in pairs(name) do
    if type(k) == "table" then
      k = stdnse.strjoin(".", k)
    end
    output[k] = v
  end
  return output
end


local function collect_results(status, method, product, addr, port, version)
  local output_tab = stdnse.output_table()
  output_tab.status = status
  output_tab.method = method
  output_tab.product = product
  output_tab.host_addr = addr
  output_tab.host_port = port
  if version ~= nil then
    if version['vsdwan_version'] ~= nil then
      parse = version['vsdwan_version'][1]
      output_tab.version = string.match(parse, ': (.*)')
    end
    if version['additional_version'] ~= nil then
      output_tab.additional_version = version['additional_version']
    end
    if version['sys_info'] ~= nil then
      output_tab.system_info = version['sys_info']
    end
    if version['sys_status'] ~= nil then
      output_tab.system_status = version['sys_status']
    end
    if version['login'] ~= nil then
      output_tab.login = version['login']
    end
  end
  return output_tab, stdnse.format_output(true, output_tab)
end


local function check_ssl(host, port, version_arg)
  if not (shortport.ssl(host, port) or sslcert.isPortSupported(port) or sslcert.getPrepareTLSWithoutReconnect(port)) then
    return nil
  end

  local cert_status, cert = sslcert.getCertificate(host, port)
  if not cert_status then
    return nil
  end
  
  ssl_subject = ssl_name_to_table(cert.subject)
  if not ssl_subject then
    return nil
  end 

  for product, titles in pairs(SDWANS_BY_SSL_TABLE) do
    for _, sd_wan_title in ipairs(titles) do
      for _, ssl_field in pairs(ssl_subject) do
        if string.match(ssl_field:lower(), sd_wan_title:lower()) then
          stdnse.print_debug("Matched SSL certificates: " .. ssl_field)
          local version = nil
          if version_arg then
            version = get_version(product, host, port)
          end
          return collect_results("success", "SSL certificate", product, host.ip, port.number, version)
        end
      end
    end
  end
end


local function check_snmp(host, port, version_arg)
  if not shortport.portnumber(161, "udp", {"open"}) then
    return nil
  end

  local snmpHelper = snmp.Helper:new(host, port)
  snmpHelper:connect()

  local status, response = snmpHelper:get({reqId=28428}, "1.3.6.1.2.1.1.1.0")
  if not status then
    return nil
  end

  nmap.set_port_state(host, port, "open")
  local result = response and response[1] and response[1][1]
  if not result then
    return nil
  end

  for product, titles in pairs(SDWANS_BY_SNMP_TABLE) do
    for _, sd_wan_title in ipairs(titles) do
      if string.match(result:lower(), sd_wan_title:lower()) then
        stdnse.print_debug("Matched SNMP banners: " .. product)
        -- override snmp port
        local version = nil
        if version_arg then
          if product == "Versa Analytics" then
            version = get_version(product, host, 8080)
          end
          if not version then
            version = get_version(product, host, 80)
          end
        end
        return collect_results("success", "snmp banner", product, host.ip, port.number, version)
      end
    end
  end
end


local function check_title(host, port, version_arg)
  if not shortport.http(host, port) then
    return nil
  end

  local resp = http.get(host, port, "/")
  found, matches = http.response_contains(resp, "top.location='(.+)';")
  if found == true then
    resp = http.get(host, port, matches[1])
  end

  -- make redirect if needed
  if resp.status == 301 or resp.status == 302 then
    local url_parsed = url.parse(resp.header.location)
    local redirect_path = url_parsed.path or "/"

    -- detect right port to redirect (by location parsing or by default scheme port)
    local existed_scheme = nil
    if url_parsed.scheme then
      existed_scheme = url.get_default_port(url_parsed.scheme)
    end
    local redirect_port = url_parsed.port or existed_scheme

    -- port of last hope (in a case when we can't parse port from location or scheme)
    if not redirect_port then
      redirect_port = 443
    end

    if url_parsed.host == host.targetname or url_parsed.host == (host.name ~= '' and host.name) or url_parsed.host == host.ip then
      stdnse.print_debug("Redirect: " .. host.ip .. " -> " .. url_parsed.scheme.. "://" .. url_parsed.authority .. url_parsed.path)
      resp = http.get(host.ip, redirect_port, redirect_path)
      -- redirect to the path from top.location in body (for example, Fortinet, etc.)
      found, matches = http.response_contains(resp, "top.location='(.+)';")
      if found == true then
        resp = http.get(host.ip, redirect_port, matches[1])
      end
    end
  end

  if not resp.body then
    return nil
  end

  local title = string.match(resp.body, "<[Tt][Ii][Tt][Ll][Ee][^>]*>([^<]*)</[Tt][Ii][Tt][Ll][Ee]>")
  if not title then
    return nil
  end
  stdnse.print_debug("Get title: " .. title)
  for product, titles in pairs(SDWANS_BY_TITLE_TABLE) do
    for _, sd_wan_title in ipairs(titles) do
      if string.match(title:lower(), sd_wan_title:lower()) then
        stdnse.print_debug("Matched titles: " .. title)
        local version = nil
        if version_arg then
          version = get_version(product, host, port)
        end
        return collect_results("success", "http-title", product, host.ip, port.number, version)
      end
    end
  end
end


local function check_server(host, port, version_arg)
  if not (shortport.http(host, port) and nmap.version_intensity() >= 7) then
    return nil
  end

  local responses = {}
  if port.version and port.version.service_fp then
    for _, p in ipairs({"GetRequest", "GenericLines", "HTTPOptions",
      "FourOhFourRequest", "NULL", "RTSPRequest", "Help", "SIPOptions"}) do
      responses[#responses+1] = U.get_response(port.version.service_fp, p)
    end
  end

  if #responses == 0 then
    local socket, result = comm.tryssl(host, port, "GET / HTTP/1.0\r\n\r\n")

    if not socket then
      return nil
    end

    socket:close()
    responses[1] = result
  end

  -- Also send a probe with host header if we can. IIS reported to send
  -- different Server headers depending on presence of Host header.
  local socket, result = comm.tryssl(host, port,
    ("GET / HTTP/1.1\r\nHost: %s\r\n\r\n"):format(stdnse.get_hostname(host)))
  if socket then
    socket:close()
    responses[#responses+1] = result
  end

  port.version = port.version or {}

  local headers = {}
  for _, result in ipairs(responses) do
    if string.match(result, "^HTTP/1.[01] %d%d%d") then
      port.version.service = "http"

      local http_server = string.match(result, "\n[Ss][Ee][Rr][Vv][Ee][Rr]:[ \t]*(.-)\r?\n")

      -- Avoid setting version info if -sV scan already got a match
      if port.version.product == nil and (port.version.name_confidence or 0) <= 3 then
        port.version.product = http_server
      end

      -- Setting "softmatched" allows the service fingerprint to be printed
      nmap.set_port_version(host, port, "softmatched")

      if http_server then
        headers[http_server] = true
      end
    end
  end

  for product, servers in pairs(SDWANS_BY_SERVER_TABLE) do
    for _, sd_wan_server in ipairs(servers) do
      for recv_server, _ in pairs(headers) do
        if string.match(recv_server:lower(), sd_wan_server:lower()) then
          stdnse.print_debug("Matched servers: " .. recv_server)
          local version = nil
          if version_arg then
            version = get_version(product, host, port)
          end
          return collect_results("success", "http-server", product, host.ip, port.number, version)
        end
      end
    end
  end
end 


local function check_fortinet(host, port, version_arg)
  if not shortport.http(host, port) then
    return nil
  end

  local resp = http.get(host, port, "/")
  local version = nil

  -- make redirect if needed
  if resp.status == 301 or resp.status == 302 then
    local url = url.parse( resp.header.location )
    if url.host == host.targetname or url.host == ( host.name ~= '' and host.name ) or url.host == host.ip then
      stdnse.print_debug("Redirect: " .. host.ip .. " -> " .. url.scheme.. "://" .. url.authority .. url.path)
      -- extract redirect port
      redir_port = string.match(url.authority, ":(%d+)")
      stdnse.print_debug("Redirect port is: " .. redir_port)
      stdnse.print_debug("Trying to get " .. host.ip .. " at " .. redir_port .. " port")
      -- get Fortinet login page at custom port
      resp = http.get(host.ip, tonumber(redir_port), "/login")
    end
  end

  if not resp.body then
    return nil
  end

  -- check if it Fortinet or not
  if not string.match(resp.body:lower(), "fortinet") then
    return nil
  end
  stdnse.print_debug("Found Fortinet SD-WAN")

  -- get version
  if version_arg then
    version = get_version("Fortinet FortiGate SD-WAN", host.ip, tonumber(redir_port))
  end
  return collect_results("success", "Fortinet Custom Method", "Fortinet FortiGate SD-WAN", host.ip, redir_port, version)
end


-- main function
action = function(host, port)
  version_arg = stdnse.get_script_args(SCRIPT_NAME..".version") or "false"
  if version_arg == "true" then
    version_arg = true
  else
    version_arg = false
  end

  -- check fortinet
  if (port.number == 8008) then
    local results = check_fortinet(host, port, version_arg)
    if results then
      return results
    end
  end

  -- get title and server from http/https
  if (port.number == 443 or port.number == 80 or port.number == 8080 or port.number == 8443) then
    local title_tab = check_title(host, port, version_arg)
    if title_tab then
      return title_tab
    end

    local server_tab = check_server(host, port, version_arg)
    if server_tab then
      return server_tab
    end

  -- check ssl cert from https
  if port.number == 443 then
    local ssl_tab = check_ssl(host, port, version_arg)
    if ssl_tab then
      return ssl_tab
    end
  end

  -- get snmp banner by 161 udp
  elseif port.number == 161 then
    local snmp_tab = check_snmp(host, port, version_arg)
    if snmp_tab then
      return snmp_tab
    end
  end
end