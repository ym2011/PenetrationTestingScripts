-- Head
-- Required NSE libraries

local stdnse = require "stdnse"
local string = require "string"
local table = require "table"
local http = require "http"
local json = require "json"

-- Input Arguments

local apipath = stdnse.get_script_args("freevulnsearch.apipath")
local notls = stdnse.get_script_args("freevulnsearch.notls")
local summary = stdnse.get_script_args("freevulnsearch.summary")
local xmlhtml = stdnse.get_script_args("freevulnsearch.xmlhtml")

description = [[

project ：https://github.com/OCSAF/freevulnsearch
This script [Version 1.1.8] allows you to automatically search for CVEs using the API of 
https://www.circl.lu/services/cve-search/ in connection with the found CPEs
using the parameter -sV in NMAP.

This script is part of the FreeOCSAF Project - https://freecybersecurity.org.
Use only with legal authorization and at your own risk! ANY LIABILITY WILL BE REJECTED!

Thanks to cve-search.org and circl.lu for the ingenious api 
and special thanks to the community for many useful ideas that speed up my coding!

Realized functions:
Version 1.0 - Contains the basic functions to quickly find relevant CVEs.
Version 1.0.1 - Includes EDB and MSF in output and minor changes.
Version 1.0.2 - Special CPE formatting and output optimization.
Version 1.0.3 - Small adjustments
Version 1.1 - Support your own cve-search api-link - https://<IP>/api/cvefor/
Version 1.1.1 - Adaptation to CVSS rating instead of OSSTMM - Input from the community, thanks
Version 1.1.2 - Special CPE formatting - Many thanks to Tore (cr33y) for testing.
Version 1.1.3b - Special CPE formatting - Many thanks to Tore (cr33y) for testing.
Version 1.1.4 - Optimization for OCSAF freevulnaudit.sh project.
Version 1.1.5 - Assignment to external category only
Version 1.1.6 - Adaptation API to http and tls as option
Version 1.1.6a - Adaptation API to tls and http as option
Version 1.1.7 - Optimized for nmap 7.80
Version 1.1.8 - Optimized for cve-search api

Future functions:
Version 1.2 - Shall contains optional sort by severity (CVSS)
Version 1.3 - Implementation of your useful ideas.

Usage:
nmap -sV --script freevulnsearch <target>

Output explanation:
CVE-Number	Rating	CVSS	EDB MSF CVE-Link

CVE-Number:
Common Vulnerabilities and Exposures

CVSS v3.0 Ratings:
Critical (CVSS 9.0 - 10.0)
High (CVSS 7.0 - 8.9)
Medium (CVSS 4.0 - 6.9)
Low (CVSS 0.1 - 3.9)
None (CVSS 0.0)

CVSS:
Common Vulnerability Scoring System with with the level of severty from 0.0 - 10.0

EDB:
There is an exploit in the Exploit-DB.com

MSF:
There is a module in the Metasploit Framework

CVE-Link:
Additional information on the vulnerability found.

]]

author = "Mathias Gut"

license = "Same as Nmap--See https://nmap.org/book/man-legal.html"

categories = {"safe", "vuln", "external"}

-- @usage
-- nmap -sV --script freevulnsearch [--script-args apipath=<url>] <target>
-- nmap -sV --script freevulnsearch [--script-args notls=yes] <target>
-- nmap -sV --script freevulnsearch [--script-args summary=yes] <target>
-- nmap -sV --script freevulnsearch [--script-args xmlhmtl=yes] <target>
--
-- @output
--
-- 22/tcp   open  ssh     OpenSSH 4.7p1 Debian 8ubuntu1 (protocol 2.0)
-- | freevulnsearch: 
-- |   CVE-2018-15473	Medium		5.0	EDB MSF	https://cve.circl.lu/cve/CVE-2018-15473
-- |   CVE-2017-15906	Medium		5.0		https://cve.circl.lu/cve/CVE-2017-15906
-- |   CVE-2016-10708	Medium		5.0		https://cve.circl.lu/cve/CVE-2016-10708
-- |   CVE-2010-4755	Medium		4.0		https://cve.circl.lu/cve/CVE-2010-4755
-- |   CVE-2010-4478	High		7.5		https://cve.circl.lu/cve/CVE-2010-4478
-- |   CVE-2008-5161	Low		2.6		https://cve.circl.lu/cve/CVE-2008-5161
-- |_  *CVE found with NMAP-CPE: (cpe:/a:openbsd:openssh:4.7p1)
--

-- Portrule

-- The table port.version contains the CPEs

portrule = function(host, port)
	local portv=port.version
	return portv ~= nil and portv.version ~= nil
end

-- Function to check if a version number exists at the CPE
function func_check_cpe(cpe)
	
	_, count = string.gsub(cpe, ":", " ")
    	if count >= 4 then
	    	return cpe
    	else
	    	return 0
    	end
end

-- Function to check for special CPE formatting.
function func_check_cpe_form(cpe)
	
	local cpe_form
	local sub_form1
	local sub_form2
	local sub_form3
	local cpe_front
	local cpe_version
    	
	_, count1 = string.gsub(cpe, ":httpfileserver:", " ")
	_, count2 = string.gsub(cpe, ".*:.*:.*:.*:.*-", " ")
	_, count3 = string.gsub(cpe, ".*:.*:.*:.*:.*_", " ")
	_, count4 = string.gsub(cpe, ".*:.*:.*:.*:.*%..*%.%d%a%d", " ")
	_, count5 = string.gsub(cpe, ".*:.*:.*:.*:.*%a%d", " ")
	_, count6 = string.gsub(cpe, ".*:.*:.*:.*:.*%d%a", " ")

	if count1 ~= 0 then
		cpe_form = string.gsub(cpe,"httpfileserver","http_file_server")
		return cpe_form
	elseif count2 ~= 0 then					-- (MySQL) 5.0.51a-3ubuntu5 -to- 5.0.51a
		sub_form1 = string.gsub(cpe,".*:",":")					
		cpe_version = string.gsub(sub_form1,"-.*","")
		cpe_front = string.gsub(cpe,cpe_version .. ".*","")
		cpe_form = cpe_front .. cpe_version
	    	return cpe_form
	elseif count3 ~= 0 then					-- (Exim smtpd) 4.90_1 -to- 4.90
		sub_form1 = string.gsub(cpe,".*:",":")					
		cpe_version = string.gsub(sub_form1,"_.*","")
		cpe_front = string.gsub(cpe,cpe_version .. ".*","")
		cpe_form = cpe_front .. cpe_version
	    	return cpe_form
	elseif count4 ~= 0 then					-- (OpenSSH) 6.6.1p1 -to- 6.6:p1
		sub_form1 = string.gsub(cpe,".*:",":")					
		sub_form2 = string.gsub(sub_form1,"%.%d%a%d.*","")
		sub_form3 = string.gsub(sub_form1,".*%.%d","")
		cpe_version = sub_form2 .. ":" .. sub_form3
		cpe_front = string.gsub(cpe,sub_form1,"")
		cpe_form = cpe_front .. cpe_version
		return cpe_form
    	elseif count5 ~= 0 then					-- (OpenSSH) 7.5p1 -to- 7.5:p1
		sub_form1 = string.gsub(cpe,".*:",":")
		sub_form2 = string.gsub(sub_form1,"%a.*","")
		sub_form3 = string.gsub(sub_form1,sub_form2,"")
		cpe_version = sub_form2 .. ":" .. sub_form3
		cpe_front = string.gsub(cpe,sub_form1,"")
		cpe_form = cpe_front .. cpe_version
		return cpe_form
	elseif count6 ~= 0 then					-- (ProFTPD) 1.3.5a -to- 1.3.5
		sub_form1 = string.gsub(cpe,".*:",":")
		sub_form2 = string.gsub(sub_form1,"%d.*","")
		cpe_version = string.gsub(sub_form1,sub_form2,"")
		cpe_front = string.gsub(cpe,sub_form1,"")
		cpe_form = cpe_front .. cpe_version
		return cpe_form
	else
		return 0
    	end
end
 
-- Function to check for known vulnerabilities without CVE
function func_check_known_vuln(cpe)
	
	local cpe_vuln
    	
		if cpe == "cpe:/a:vsftpd:vsftpd:2.3.4" then
			cpe_vuln = "EDB-ID-17491\t" .. "Critical\t" .. "None\t" .. "EDB MSF\t" .. "https://www.exploit-db.com/exploits/17491"
			return cpe_vuln
		else
			return 0
		end
end
 
-- Function to query CVEs via CPEs with API (circl.lu).
function func_check_cve(cpe)

	local url
	local option = {
	max_body_size=40000000,
	timeout=40000
	}
	local response
	local request
	local status
	local vulnerabilities
	
	if not apipath then
		if not notls then
			url = "https://cve.circl.lu/api/cvefor/"
		else
			url = "http://cve.circl.lu/api/cvefor/"
		end
	else
		url = apipath
	end

	request = url .. cpe

	response = http.get_url(request, option)
	
	status, vulnerabilities = json.parse(response.body)

	if status ~= true then
		return 1
	elseif type(next(vulnerabilities)) == "nil" then
		return 2
	elseif (status == true and vulnerabilities ~= "") then
		return func_output(vulnerabilities)
	else	
		return 2
	end
end

-- Function to generate the script output.
function func_output(vulnerabilities)
	
	local output_table = {}
	local input_table = {}
	local cve_url= "https://cve.circl.lu/cve/"
	local cve_value
	local cvss
	local cvss_value
	local cvss_rating
	local url_value
	local edb
	local msf
	local exploit
	local sum
	local cwe
	local xmlhtml_out
	local i
	local t
	
	if not xmlhtml then
		xmlhtml_out = ""
	else
		xmlhtml_out = " "
	end

	for i,t in ipairs(vulnerabilities) do
 		cve_value = t.id
		cvss = tonumber(t.cvss)
 		url_value = cve_url .. t.id
		if t.refmap then
			edb = t.refmap["exploit-db"]
			msf = t.refmap.metasploit
		end

		if not cvss then
			cvss_value = "None"
			cvss_rating = "None"
		else
 			cvss_value = cvss	
			cvss_rating = func_rating(cvss)
		end

		if not edb and not msf then
			exploit = ""
		elseif edb and not msf then
			exploit = "EDB"
		elseif not edb and msf then
			exploit = "MSF"
		elseif edb and msf then
			exploit = "EDB MSF"
		end

		if not summary then
			output_table = cve_value .. xmlhtml_out .. "\t" .. cvss_rating .. "\t" .. cvss_value .. "\t" .. exploit .. "\t" .. url_value
		else
			sum = t.summary
			
			if not t.cwe then
				output_table = cve_value .. xmlhtml_out .. "\t" .. cvss_rating .. "\t" .. cvss_value .. "\t" .. exploit .. "\t" .. url_value ..
				"\n  *SUMMARY: " .. sum .. "\n"
			else
				cwe = t.cwe
				output_table = cve_value .. xmlhtml_out .. "\t" .. cvss_rating .. "\t" .. cvss_value .. "\t" .. exploit .. "\t" .. url_value ..
				"\n  *CWE: " .. cwe ..
				"\n  *SUMMARY: " .. sum .. "\n"
			end
		end

		input_table[i] = output_table 	
	end
                       
	return input_table
end          

-- Function to assign CVSS values to CVSS V3.0 ratings
function func_rating(cvss)

	if (cvss == 0.0) then
		return "None\t"
	elseif (3.9 >= cvss and cvss >= 0.1) then
		return "Low\t"
	elseif (6.9 >= cvss and cvss >= 4.0) then
		return "Medium\t"
	elseif (8.9 >= cvss and cvss >= 7.0) then
		return "High\t"
	elseif (10.0 >= cvss and cvss >= 9.0) then
		return "Critical"
	end
end


-- Action
-- Main-Function
action = function(host, port)
    	
	local cpe=""
	local check
	local sort_values
	local form_cpe
	local known_vuln
	local i

	for i, cpe in ipairs(port.version.cpe) do
		check = func_check_cpe(cpe)
		if check ~= 0 then
			sort_values = func_check_cve(check)
			if sort_values == 1 then
				return "*Error with API query. API or network possibly not available."
			elseif sort_values == 2 then
				form_cpe = func_check_cpe_form(check)
				if form_cpe == 0 then
					known_vuln = func_check_known_vuln(check)
					if known_vuln == 0 then
						return "\n  *No CVE found with NMAP-CPE: (" .. check .. ")" ..
						"\n  *Check other sources like https://www.exploit-db.com"
					else
						return "\n  " .. known_vuln .. "\n  *No CVE found with CPE: (" .. check .. ")"	
					end
				else
					sort_values = func_check_cve(form_cpe)
					if sort_values == 2 then
						return "\n  *No CVE found with NMAP-CPE: (" .. check .. ")" .. 
						"\n  *No CVE found with freevulnsearch function: (" .. form_cpe .. ")" ..
						"\n  *Check other sources like https://www.exploit-db.com"
					else
						table.sort(sort_values, function(a, b) return a>b end)
						table.insert(sort_values, "*No CVE found with NMAP-CPE: (" ..check .. ")")
						table.insert(sort_values, "*CVE found with freevulnsearch function: (" .. form_cpe .. ")")
						return sort_values
					end
				end
			else
				table.sort(sort_values, function(a, b) return a>b end)
				table.insert(sort_values, "*CVE found with NMAP-CPE: (" ..check .. ")")
				return sort_values
			end
		elseif check == 0 then
			return "\n  *Check unspecific version manually: (".. cpe .. ")"
		end
	end
end
