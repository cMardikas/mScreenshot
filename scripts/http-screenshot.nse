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
Gets a screenshot from the host. Runs on any open TCP port that nmap's
service detection identifies as HTTP-based (http, https, http-proxy,
http-alt, wsdapi, ipp, soap, webdav, caldav) or that is SSL-tunneled.
Trusts -sV, so it works on non-standard ports (8080, 9090, 44444, ...)
as long as -sV ran successfully.
]]

author = "Ryan Wincey"
license = "GPLv2"

categories = {"default", "discovery", "safe"}

local shortport = require "shortport"
local stdnse = require "stdnse"

local script_path = string.sub(debug.getinfo(1).source, 2, (string.len("http-screenshot.nse") + 2) * -1)
stdnse.debug(1, "Script path: %s", script_path)

-- Screenshot output directory. Resolved from --script-args screenshot_dir=...
-- and normalized on first use in action(); falls back to script_path when not
-- provided (e.g. running the NSE by hand without mScreenshot).
local sep = package.config:sub(1,1)

local function ensure_trailing_sep(p)
    if not p or p == "" then return p end
    if p:sub(-1) ~= sep then return p .. sep end
    return p
end

local function ensure_dir(p)
    -- Create the directory if it doesn't exist. Cheap and portable.
    if sep == "\\" then
        os.execute('if not exist "' .. p .. '" mkdir "' .. p .. '"')
    else
        os.execute('mkdir -p "' .. p .. '" 2>/dev/null')
    end
end

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

-- Services nmap labels with a distinct name but which actually speak HTTP.
-- These don't start with "http" so they need an explicit allow entry.
local http_like_services = {
    wsdapi = true,
    ipp    = true,
    soap   = true,
    webdav = true,
    caldav = true,
}

local function looks_http(port)
    local name = (port.service or ""):lower()
    if name:find("http") then return true end
    if http_like_services[name] then return true end
    if port.version and port.version.service_tunnel == "ssl" then
        return true
    end
    return false
end

portrule = function(host, port)
    if port.protocol ~= "tcp" then return false end
    if port.state ~= "open" then return false end
    return looks_http(port)
end

local function shell_quote(s)
    if not s then return "''" end
    return "'" .. tostring(s):gsub("'", "'\\''") .. "'"
end

action = function(host, port)

    -- Resolve the output directory. Prefer the arg passed by mScreenshot
    -- (--script-args screenshot_dir=/abs/path); fall back to the script dir.
    local shots_dir = stdnse.get_script_args("screenshot_dir")
    if not shots_dir or shots_dir == "" then
        shots_dir = script_path
    end
    shots_dir = ensure_trailing_sep(shots_dir)
    ensure_dir(shots_dir)

    -- Pass the detected service name and TLS tunnel hint so screenshot.py
    -- can pick http vs https intelligently. Both are advisory; screenshot.py
    -- will fall back to probing if they're missing.
    local svc_name = ""
    if port.service then svc_name = tostring(port.service) end

    local tunnel = ""
    if port.version and port.version.service_tunnel then
        tunnel = tostring(port.version.service_tunnel)
    end

    local cmd = 'python3 "' .. script_path .. sep .. 'screenshot.py"'
        .. ' -u ' .. host.ip
        .. ' -p ' .. port.number
        .. ' -s ' .. shell_quote(svc_name)
        .. ' -t ' .. shell_quote(tunnel)
        .. ' -o "' .. shots_dir .. '"'

    stdnse.debug(1, "Running: %s", cmd)
    os.execute(cmd)

    local file_path = shots_dir .. host.ip .. '_' .. port.number .. '.png'

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
