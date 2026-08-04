local mod = require"classes"
local Class = mod.Class
local check_type = mod.check_type

-- Example of custom classes
---@alias MessageType "text_message" | "video_message"

---@class TextMessage:Class
---@field message string
---@field __id MessageType
local TextMessage = setmetatable({
}, {
	---@param message string
	---@return TextMessage
	__call = function(_, message)
		local text_msg = Class("text_message")
		text_msg.message = message
		return text_msg
	end
})

---@class VideoMessage:Class
---@field raw_bytes number[] -- bytes of video
---@field __id MessageType
local VideoMessage = setmetatable({
}, {
	---@param raw_bytes number[]
	---@return VideoMessage
	__call = function(_, raw_bytes)
		local text_msg = Class("video_message")
		text_msg.raw_bytes = raw_bytes
		return text_msg
	end
})


---@alias Message TextMessage | VideoMessage


---@type TextMessage
local tmsg = TextMessage("hello bob!")
---@type VideoMessage
local vmsg = VideoMessage({1, 2, 3, 4, 5})
---@type VideoMessage
local vmsg2 = VideoMessage({2, 3, 125, 1254, 123})
---@type Class
local imsg = Class("qwerty")

---@param message Message
---@return string
local function fmt_message(message)
	if check_type(message, "text_message") then
		return "[TEXT MESSAGE]: " .. message.message
	elseif check_type(message, "video_message") then
		return "[VIDEO MESSAGE]: [" .. table.concat(message.raw_bytes, ", ") .. "]"
	end
	error("Invalid message type (" .. tostring(message.__id) .. ")")
end

-- Tests
assert(fmt_message(vmsg) == "[VIDEO MESSAGE]: [1, 2, 3, 4, 5]")
assert(fmt_message(vmsg2) == "[VIDEO MESSAGE]: [2, 3, 125, 1254, 123]")
assert(fmt_message(tmsg) == "[TEXT MESSAGE]: hello bob!")

local s, _ = pcall(fmt_message, imsg)
assert(s == false)
