description = [[
CVE api to fetch vuln in detected service

INSTALLATION

$ git clone https://github.com/arpitrohela/nmap_nse.git
$ cd nmap_nse/
$ sudo cp cve.nse /usr/share/nmap/scripts/
$ sudo nmap --script cve.nse 192.168.0.1 -p 80 -sV
]]
author = "Arpit Rohela"
license = "Same as Nmap--See http://nmap.org/book/man-legal.html"
categories = {"vuln"}

local http = require "http"

-- The Rule Section --
portrule = function(host, port)
    return port.state == "open"
end

-- The Action Section --
action = function(host, port)

    local uri = "/api/search/httpd"
    local response = http.get("cve.circl.lu", port, uri)
	
	if ( response.status == 200 ) then
        return response.body
--		and port.version.product--
--		and type(port.version.version)--
    end

end
