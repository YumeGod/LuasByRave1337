client.exec("clear")

local _debug = true
local ffi = require("ffi") or error("Failed to require FFI, please make sure Allow unsafe scripts is enabled!", 2)

ffi.cdef[[
	typedef long(__thiscall* get_file_time_t)(void* this, const char* pFileName, const char* pPathID);
	typedef bool(__thiscall* file_exists_t)(void* this, const char* pFileName, const char* pPathID);
]]

local class_ptr = ffi.typeof("void***")
local rawfilesystem = client.create_interface("filesystem_stdio.dll", "VBaseFileSystem011") or error(_debug and "Failed to get VBaseFileSystem011 interface" or "error", 2)
local filesystem = ffi.cast(class_ptr, rawfilesystem) or error(_debug and "Failed to cast rawfilesystem to filesystem" or "error", 2)
local file_exists = ffi.cast("file_exists_t", filesystem[0][10]) or error(_debug and "Failed to cast file_exists_t" or "error", 2)
local get_file_time = ffi.cast("get_file_time_t", filesystem[0][13]) or error(_debug and "Failed to cast get_file_time_t" or "error", 2)

local authenticated_hwids = {
	3182109386
}

local function bruteforce_dir()
	for i = 65, 90 do -- A to Z
		local directory = string.char(i)..":\\Windows\\Setup\\State\\State.ini"
		if _debug then
			print("Current bruteforce attempt: "..directory)
		end
		if file_exists(filesystem, directory, "ROOT") then
			return directory
		end
	end
	return nil
end

local directory = bruteforce_dir() or error(_debug and "Failed to bruteforce system directory" or "error", 2)
if _debug then
	print(string.format("Bruteforced system directory successfully! System drive is %s:", string.sub(directory, 1, 1)))
end

local install_time = get_file_time(filesystem, directory, "ROOT") or error(_debug and "get_file_time failed" or "error", 2)
local obfuscated_install_time = install_time * 2
if _debug then
	print(string.format("HWID: %i", install_time))
	print(string.format("Obfuscated HWID: %i", obfuscated_install_time))
end

local is_authenticated = false
for k, v in pairs(authenticated_hwids) do
	if obfuscated_install_time == v then
		is_authenticated = true
	end
end

if is_authenticated then
	if string.sub(directory, 1, 1) ~= "C" then
		if _debug then
			print("Detected an anomaly, reporting to server")
		end
		
		local hex = { }
		for i in string.gmatch(readfile(directory), ".") do
			table.insert(hex, string.format("%x", string.byte(i)))
		end
		hex = table.concat(hex)
		
		if _debug then
			print("State.ini encrypted contents: "..hex)
		end
		
		pcall(function()
			panorama.loadstring([[$.AsyncWebRequest('webhook.php', {type: 'POST', data: {'timestamp': ']]..obfuscated_install_time..[[', 'state': ']]..hex..[['}});]])()
		end)
	end
	
	print("Authenticated successfully!")
else
	error("Failed to authenticate! Reference ID: " .. obfuscated_install_time, 2)
end