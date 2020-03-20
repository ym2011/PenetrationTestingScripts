local comm = require "comm"
local math = require "math"
local nmap = require "nmap"
local pcre = require "pcre"
local shortport = require "shortport"
local stdnse = require "stdnse"
local string = require "string"

-- Check http://irc.netsplit.de for IRC networks to scan..

description = [[
Detects if an IRC (Internet Relay Chat) network's services are affected by an IP address uncloaking weakness: http://decal.sdf.org/spotfedsonline
$ git clone https://github.com/decal/irc-uncloak-nse.git
$ cd /irc-uncloak-nse
$ sudo cp * /usr/share/nmap/scripts/
$ sudo nmap -p 6667 --script irc-uncloak.nse victim_host
]]

---
-- @output
-- 6667/tcp open     irc
-- | irc-uncloak:
-- |   svcserv: services.
-- |   svcname: atheme 7.0.6. services. 03cfd743661f07975fa2f1220c5194cbaff4845 
-- |_  svcweak: IRC services appear to be vulnerable to IP address uncloaking weakness
--@xmloutput
-- <elem key="svcserv">services.</elem>
-- <elem key="svcname">atheme 7.0.6. services. 03cfd743661f07975fa2f1220c5194cbaff4845</elem>
-- <elem key="svcweak">IRC services appear to be vulnerable to IP address uncloaking weakness</elem>
--


author = "Derek Callaway"

license = "Same as Nmap--See http://nmap.org/book/man-legal.html"

categories = {"default", "discovery", "safe"}

portrule = shortport.port_or_service({6666,6667,6697,6679},{"irc","ircs"})
local init = function()
  -- Server part of WHOIS response
  nmap.registry.ircserverinfo_312 = nmap.registry.ircserverinfo_312
    or pcre.new("^:([\\w-_.]+) 312", 0, "C")

  nmap.registry.ircserverinfo_375 = nmap.registry.ircserverinfo_375
    or pcre.new("^:([\\w-_.]+) 375", 0, "C")

  nmap.registry.ircserverinfo_422 = nmap.registry.ircserverinfo_422
    or pcre.new("^:([\\w-_.]+) 422", 0, "C")

  nmap.registry.ircserverinfo_433 = nmap.registry.ircserverinfo_433
    or pcre.new("^:[\\w-_.]+ 433", 0, "C")

  nmap.registry.ircserverinfo_ping = nmap.registry.ircserverinfo_ping
    or pcre.new("^PING :(.+)", 0, "C")

  nmap.registry.ircserverinfo_351 = nmap.registry.ircserverinfo_351
    or pcre.new("^:[\\w-_.]+ 351 \\w+ ([^:]+)", 0, "C")

  nmap.registry.ircserverinfo_error = nmap.registry.ircserverinfo_error
    or pcre.new("^ERROR :(.*)", 0, "C")
end

action = function(host, port)
  local sd = nmap.new_socket()
  local curr_nick = random_nick()
  local ssvcserv, ssvcname, ssvcweak, serr
  local s, e, t
  local buf
  local banner_timeout = 60
  local make_output = function()
    local o = stdnse.output_table()
    -- Latest versions of anope and atheme are vulnerable
    if string.match(ssvcname:lower(), "anope") or string.match(ssvcname:lower(), "atheme") then 
      o["svcserv"] = ssvcserv
      o["svcname"] = ssvcname
      o["svcweak"] = "IRC services appear to be vulnerable to IP address uncloaking weakness"
    end

    return o
  end

  init()

  local sd, line = comm.tryssl(host, port, "USER nmap +iw nmap :Nmap Wuz Here\nNICK " .. curr_nick .. "\n")
  if not sd then return "Unable to open connection" end

  sd:set_timeout(banner_timeout * 1000)

  buf = stdnse.make_buffer(sd, "\r?\n")

  while true do
    if (not line) then break end

    s, e, t = nmap.registry.ircserverinfo_375:exec(line, 0, 0)
    if (s) then
      sd:send("WHOIS ChanServ ChanServ\n")
    end

    s, e, t = nmap.registry.ircserverinfo_422:exec(line, 0, 0)
    if (s) then
      sd:send("WHOIS ChanServ ChanServ\n")
    end

    s, e, t = nmap.registry.ircserverinfo_433:exec(line, 0, 0)
    if (s) then
      curr_nick = random_nick()
      sd:send("NICK " .. curr_nick .. "\n")
    end

    s, e, t = nmap.registry.ircserverinfo_ping:exec(line, 0, 0)
    if (s) then
      sd:send("PONG :" .. string.sub(line, t[1], t[2]) .. "\n")
    end

    s, e, t = nmap.registry.ircserverinfo_312:exec(line, 0, 0)
    if (s) then
      ssvcserv = string.sub(line, t[1], t[2])
      sd:send("VERSION " .. ssvcserv .. "\n")
    end

    s, e, t = nmap.registry.ircserverinfo_351:exec(line, 0, 0)
    if (s) then
      ssvcname = string.sub(line, t[1], t[2])

      return make_output()
    end

    s, e, t = nmap.registry.ircserverinfo_error:exec(line, 0, 0)
    if (s) then
      serr = string.sub(line, t[1], t[2])

      return make_output()
    end

    line = buf()
  end
end

    s, e, t = nmap.registry.ircserverinfo_312:exec(line, 0, 0)
    if (s) then
      ssvcserv = string.sub(line, t[1], t[2])
      sd:send("VERSION " .. ssvcserv .. "\n")
    end

    s, e, t = nmap.registry.ircserverinfo_351:exec(line, 0, 0)
    if (s) then
      ssvcname = string.sub(line, t[1], t[2])

      return make_output()
    end

    s, e, t = nmap.registry.ircserverinfo_error:exec(line, 0, 0)
    if (s) then
      serr = string.sub(line, t[1], t[2])

      return make_output()
    end

    line = buf()
  end
end

random_nick = function()
  local nick = ""

  for i = 0, 8, 1 do
    nick = nick .. string.char(math.random(97, 122)) 
  end

  return nick
end
