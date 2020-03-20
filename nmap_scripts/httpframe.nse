local http = require "http"
local shortport = require "shortport"
local stdnse = require "stdnse"
local string = require "string"

description = [[
Stores the results of an HTTP(S) scan on a HTML page with JQuery. Shows IP, header,
realm and tries to identify if target is a router, camera or common web server.

Almacena los resultados de un barrido HTTP(S) en una página web con Frames y JQuery.
Muestra las direcciones IP, un mirror del contenido html, el contenido de la cabecera
www-authenticate. De acuerdo al header server o al contenido de la página que obtiene
muestra si es un router, cámara o firewall.

$ git clone https://github.com/hkm/nmap-nse-scripts.git

]]
author = {'Pedro Joaquin pjoaquin()websec.mx'}
license = "Same as Nmap--See http://nmap.org/book/man-legal.html"
categories = {"discovery"}

portrule = shortport.port_or_service({80, 443},
                {"http", "https"})

local function categoria(server)
  local modemlist =  {'Router', 'Modem','RomPager', 'DSL', 'Mbedthis','Mathopd','GoAhead','IOS','httpd','siyou server','lighttpd','login.lp','ADTRAN','Technicolor','url_filter_hint.asp','RouterOS'}
  for i=1, #modemlist do
    if string.find(server, modemlist[i]) then return "Router" end
  end

  local camlist =  {'dcs-lig-httpd', 'Camera', 'Avtech', 'Hikvision', 'iCanWebServer', 'Boa', 'AV-TECH','Cross Web Server','DCS-','netcam'}
  for i=1, #camlist do
    if string.find(server, camlist[i]) then return "Camera" end
  end

  local serverlist =  {'Apache', 'IIS'}
  for i=1, #serverlist do
    if string.find(server, serverlist[i]) then return "Server" end
  end

  return "Unknown"
end

local function siexiste(var1)
      if var1 == nil then 
        return ""
      else
        return var1
      end
end
  
local function savefile(name, content, mode)
  local file, err = io.open(name, mode)
    if ( file ) then
      file:write(content)
      file:close()
    else
      return "\n  ERROR: " .. file
    end
end

savefile('httpframe_log.html', '<HTML><TITLE>httpframe.nse v0.5</TITLE><FRAMESET rows="390,*"><frame src="httpframe_log/menu.htm"><frame name="main" src="about:blank"></FRAMESET></HTML>', 'w')
savefile("httpframe_log/menu.htm", '<html><head><link href="../httpframe_files/advancedtable.css" rel="stylesheet" type="text/css" /><script src="../httpframe_files/jquery.js" type="text/javascript" language="javascript"></script><script src="../httpframe_files/advancedtable.js" type="text/javascript" language="javascript"></script><script language="javascript" type="text/javascript">'..
	'$().ready(function() {'..
		'$("#searchtable").show();'..
		'$("#table1").advancedtable({rowsPerPage: 10000, searchField: "#search", loadElement: "#loader", searchCaseSensitive: false, ascImage: "../httpframe_files/images/up.png", descImage: "../httpframe_files/images/down.png",sortColumnDefault: 1, navigationLabel: "Paginas "});'..
	'});'..
'</script></head><body>','w')
  
savefile("httpframe_log/menu.htm", '<table width="100%" class="normal" id="searchtable" border="0" cellspacing="4" cellpadding="0" style="display:none;"><tr>'..
         '<td width="50%">Filter: <input name="search" type="text" id="search" style="display:none;" /></td>'..
         '<td width="33%"><div id="loader" style="display:none;"><img src="httpframe_files/images/loader.gif" alt="Loading..." /></div></td>'..
         '<td width="34%"><div style="float:right;padding:0"><a href=http://websec.mx><img src="../httpframe_files/images/logo.jpg" border=0></a></div></td>'..
       '</tr></table>', 'a+')
  
savefile("httpframe_log/menu.htm", '<table id="table1" class="advancedtable" width="100%"><thead><th>IP</th><th>mirror</th><th>status</th><th>size</th><th>device</th><th>server</th><th>www-authenticate header</th><tbody>','a+')
  
action = function(host, port)

  local query = http.get(host.ip, port, "/")

  local serverstring = " "

  if query.header['server'] ~= nil then serverstring = query.header['server'] end
  if query.header['www-authenticate'] ~= nil then serverstring = serverstring .. query.header['www-authenticate'] end
  if query.body ~= nil then savefile("httpframe_log/" .. host.ip .. ".html", query.body, 'w') end

 if query.status == 302 then 
   serverstring = serverstring .. query.header['location']
   savefile("httpframe_log/" .. host.ip .. ".html", "Location: "..query.header['location'], 'w')
 end

if query.body ~= nil then
  if string.find(query.body, ".location") then 
    serverstring=serverstring..query.body
   query.body="<textarea cols=100 rows=40>"..query.body.."</textarea>"
   savefile("httpframe_log/" .. host.ip .. ".html", query.body, 'w')
 end
end

if port.service == "https" then
  savefile("httpframe_log/menu.htm", '<tr class="'.. categoria(serverstring) ..'"><td width="10"><a href="'.. port.service ..'://' .. host.ip ..':' .. port.number ..'" target="main">'.. port.service ..'://' .. host.ip ..':' .. port.number ..'</a></td>', 'a+')
else
  savefile("httpframe_log/menu.htm", '<tr class="'.. categoria(serverstring) ..'"><td width="10"><a href="http://' .. host.ip ..':' .. port.number ..'" target="main">http://' .. host.ip ..':' .. port.number ..'</a></td>', 'a+')
end

  savefile("httpframe_log/menu.htm", '<td width="100"><a href="'.. host.ip .. '.html" target="main">[mirror]</a></td>', 'a+')
  savefile("httpframe_log/menu.htm", '<td width="100">['.. siexiste(query.status) ..']&nbsp;</td>', 'a+')
  savefile("httpframe_log/menu.htm", '<td width="100">'.. string.len(siexiste(query.body)) ..' B</td>', 'a+')
  savefile("httpframe_log/menu.htm", '<td width="120">'.. siexiste(categoria(serverstring)) ..' &nbsp;</td>', 'a+')
  savefile("httpframe_log/menu.htm", '<td width="220">'.. siexiste(query.header['server']) ..' &nbsp;</td>', 'a+')
  savefile("httpframe_log/menu.htm", '<td>'.. siexiste(query.header['www-authenticate']) ..' &nbsp;</td>', 'a+')

  return "Information added to httpframe_log.html "
end
