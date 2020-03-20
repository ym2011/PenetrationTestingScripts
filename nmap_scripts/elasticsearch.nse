description = [[
Attempts to enumerate indices, plugins and cluster nodes on a target elasticsearch
exposing an unauthenticated HTTP port (default 9200/tcp) using the elasticsearch RESTful API.
Installation
$ git clone https://github.com/theMiddleBlue/nmap-elasticsearch-nse.git
$ cp nmap-elasticsearch-nse/elasticsearch.nse /usr/share/nmap/scripts/
$ nmap --script=elasticsearch <target>

]]

author = "theMiddle"

license = "Same as Nmap--See https://nmap.org/book/man-legal.html"

categories = {"discovery", "version"}

local http = require "http"
local string = require "string"
local json = require "json"

portrule = function(host, port)
  return port.protocol == "tcp" and port.state == "open"
end

action = function(host, port)
  local uri = "/"
  local response = http.get(host, port, uri)
  if ( response.status == 200 ) then
    if ( string.find(response.body, "You Know, for Search") ) then
      local out = "by theMiddle (Twitter: @Menin_TheMiddle)\r\n\r\n"
      out = out .. "found RESTful API\r\n"
      err, esjson = json.parse(response.body)

      out = out .. "version: ".. esjson['version']['number'] .."\r\n"

      if esjson['cluster_name'] then
        out = out .. "cluster name: " .. esjson['cluster_name'] .. "\r\n"
      end

      out = out .. "\r\nIndices found in /_cat/indices:\r\n"
      local resindices = http.get_url("http://"..host.ip..":"..port.number.."/_cat/indices?pri&v&h=health,index,docs.count")
      out = out .. resindices.body

      out = out .. "\r\nPlugins found in /_cat/plugins:\r\n"
      local resplugins = http.get_url("http://"..host.ip..":"..port.number.."/_cat/plugins")
      out = out .. resplugins.body

      out = out .. "\r\nNodes found in /_cat/nodes:\r\n"
      local resnodes = http.get_url("http://"..host.ip..":"..port.number.."/_cat/nodes")
      out = out .. resnodes.body

      out = out .. "\r\nNodes process:\r\n"
      local resprocess = http.get_url("http://"..host.ip..":"..port.number.."/_nodes/_all/process")
      err, psjson = json.parse(resprocess.body)

      for key,value in pairs(psjson['nodes']) do
        out = out .. " - Name: " .. value['name'] .. "\r\n"
        out = out .. " - Transport Address: " .. value['transport_address'] .. "\r\n"
        out = out .. " - Host: " .. value['host'] .. "\r\n"
        out = out .. " - IP: " .. value['ip'] .. "\r\n"
        out = out .. " - Version: " .. value['version'] .. "\r\n\r\n"
      end

      return out
    end
  end
end
