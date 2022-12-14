local ffi = require("ffi")
ffi.cdef[[
	typedef void*(__thiscall* shell_execute_t)(void*, const char*, const char*);
]]

local class_ptr = ffi.typeof("void***")
local rawvguisystem = client.create_interface("vgui2.dll", "VGUI_System010") or error("VGUI_System010 wasn't found", 2)
local ivguisystem = ffi.cast(class_ptr, rawvguisystem) or error("rawvguisystem is nil", 2)
local shell_execute = ffi.cast("shell_execute_t", ivguisystem[0][3]) or error("shell_execute is nil", 2)

--ui.new_button("LUA", "B", "Open www.google.com", function()
	--shell_execute(ivguisystem, "open", "www.google.com")
--end

shell_execute(ivguisystem, "open", "info.lua")