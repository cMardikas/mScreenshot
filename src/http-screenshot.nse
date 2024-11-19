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
Gets a screenshot from the host
]]

author = "Ryan Wincey"
license = "GPLv2"

categories = {"default", "discovery", "safe"}

-- Updated the NSE Script imports and variable declarations
local shortport = require "shortport"
local stdnse = require "stdnse"

local script_path = string.sub(debug.getinfo(1).source, 2, (string.len("http-screenshot.nse") + 2) * -1)
-- local script_path = debug.getinfo(1).source
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

-- Function to read the content of a file
local function read_file(file_path)
    local file = io.open(file_path, "rb") -- Open in binary mode
    if not file then
        return nil, "Unable to open file"
    end
    local content = file:read("*all")
    file:close()
    return content
end

portrule = shortport.http

action = function(host, port)
	
	-- Execute the shell command python screenshot.py 
	local cmd = 'python3 "' .. script_path .. package.config:sub(1,1) .. 'screenshot.py" -u ' .. host.ip .. " -p " .. port.number	
	local ret = os.execute(cmd)

		local file_path = script_path .. host.ip .. '_' .. port.number .. '.png'

		-- Read the file content
    		local file_content, err = read_file(file_path)
    		
		if not file_content then
        		return stdnse.format_output(false, "Error reading file: " .. err)
    		end
    
        	stdnse.print_debug(1, "File content length: %d", #file_content)

		-- Encode the file content to Base64 
		local encoded_content = base64_encode(file_content)
		stdnse.print_debug(1, "Encoded content length: %d", #encoded_content)
		stdnse.print_debug(1, "Encoded content (first 100 chars): %s", encoded_content:sub(1, 100))

    		-- Construct the output
    		local output = '<img src="data:image/png;base64,' .. encoded_content .. '"/>' .. '\n' 
    		
		return true,output
end
