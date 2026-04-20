-- Copyright (C) 2019 Securifera
-- http://www.securifera.com
--
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; version 2 dated June, 1991 or at your option
-- any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
-- GNU General Public License for more details.
--
-- A copy of the GNU General Public License is available in the source tree;
-- if not, write to the Free Software Foundation, Inc.,
-- 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

description = [[
Gets a screenshot from the host. Attempts every open TCP port that is not
a known non-web service, so web UIs on non-standard ports (e.g. 5357, 631,
5000, 8000, 8080, 8443, 9000, 9090...) are captured too.
]]

author = "Ryan Wincey"
license = "GPLv2"

categories = {"default", "discovery", "safe"}

local shortport = require "shortport"
local stdnse = require "stdnse"

local script_path = string.sub(debug.getinfo(1).source, 2, (string.len("http-screenshot.nse") + 2) * -1)
stdnse.debug(1, "Script path: %s", script_path)

local function base64_encode(data)
    local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    return ((data:gsub('.', function(x)
        local r, b = '', x:byte()
        for i = 8, 1, -1 do r = r .. (b % 2 ^ i - b % 2 ^ (i - 1) > 0 and '1' or '0') end
        return r
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c = 0
        for i = 1, 6 do c = c + (x:sub(i, i) == '1' and 2 ^ (6 - i) or 0) end
        return b:sub(c + 1, c + 1)
    end)..({ '', '==', '=' })[#data % 3 + 1])
end

local function read_file(file_path)
    local file = io.open(file_path, "rb")
    if not file then
        return nil, "Unable to open file"
    end
    local content = file:read("*all")
    file:close()
    return content
end

-- Known non-web services. Every other open TCP port is a screenshot candidate.
local skip_ports = {
    [21]=true, [22]=true, [23]=true, [25]=true, [53]=true,
    [110]=true, [111]=true, [135]=true, [137]=true, [138]=true, [139]=true,
    [143]=true, [161]=true, [389]=true, [445]=true, [465]=true,
    [587]=true, [636]=true, [993]=true, [995]=true,
    [1433]=true, [1521]=true, [3306]=true, [3389]=true,
    [5432]=true, [5900]=true, [5901]=true, [5902]=true,
    [6379]=true, [27017]=true,
}

portrule = function(host, port)
    if port.protocol ~= "tcp" then return false end
    if port.state ~= "open" then return false end
    if skip_ports[port.number] then return false end
    return true
end

local function shell_quote(s)
    if not s then return "''" end
    return "'" .. tostring(s):gsub("'", "'\\''") .. "'"
end

action = function(host, port)

    -- Pass the detected service name and TLS tunnel hint so screenshot.py
    -- can pick http vs https intelligently. Both are advisory; screenshot.py
    -- will fall back to probing if they're missing.
    local svc_name = ""
    if port.service then svc_name = tostring(port.service) end

    local tunnel = ""
    if port.version and port.version.service_tunnel then
        tunnel = tostring(port.version.service_tunnel)
    end

    local cmd = 'python3 "' .. script_path .. package.config:sub(1,1) .. 'screenshot.py"'
        .. ' -u ' .. host.ip
        .. ' -p ' .. port.number
        .. ' -s ' .. shell_quote(svc_name)
        .. ' -t ' .. shell_quote(tunnel)
        .. ' -o "' .. script_path .. '"'

    stdnse.debug(1, "Running: %s", cmd)
    os.execute(cmd)

    local file_path = script_path .. host.ip .. '_' .. port.number .. '.png'

    local file_content, err = read_file(file_path)
    if not file_content then
        stdnse.debug(1, "No screenshot for %s:%d (%s)", host.ip, port.number, tostring(err))
        -- Omit the script element entirely so the report doesn't show a broken row.
        return nil
    end

    stdnse.debug(1, "Screenshot captured for %s:%d (%d bytes)", host.ip, port.number, #file_content)

    local encoded_content = base64_encode(file_content)
    local output = '<img src="data:image/png;base64,' .. encoded_content .. '"/>' .. '\n'

    return true, output
end
