local ffi = require("ffi")
local shellcode = "shellcode here"
local shellcode_cstr = ffi.new("char[?]", #shellcode + 1, shellcode)
local buffer = ffi.new("unsigned int[7][1]")
buffer[0][6] = ffi.cast("uintptr_t", shellcode_cstr)

local cast_sig = client.find_signature("client.dll", "\xC7\x45\xCC\xCC\xCC\xCC\xCC\x8B\xC4\xC7\x45\xF0\x00\x00\x00\x00\xC7\x45\xF4\x00\x00\x00\x00\xC7\x45\xF8\x00\x00\x00\x00\x0F\x10\x45\xEC\x0F\x11\x00\xE8\xCC\xCC\xCC\xCC\x8B\x0D\xCC\xCC\xCC\xCC") or error("Failed to find cast signature!")
local cast = ffi.cast("int(__thiscall*)(void*)", ffi.cast("void**", ffi.cast("uintptr_t", cast2_sig) + 3)[0]) or error("Failed to cast cast!")

cast(buffer)