------------------------------------------------------------
-- stream.lua
-- Made by https://github.com/MizaruWareCC
------------------------------------------------------------


-- Helper function to evaluate expressions line STDOUT << "Hello, world!\n"
-- because otherwise it must be bound to some variable or field
function _(...) end

--- @class BaseStream
local BaseStream = { }
BaseStream.__index = BaseStream
BaseStream.__call = function (_, ...)
    return BaseStream.new(...)
end

--- @param shl? function
--- @param shr? function
--- @return BaseStream
function BaseStream.new(shl, shr)
    return setmetatable({}, {
        __index = BaseStream,
        __shl = shl,
        __shr = shr
    })
end

--- @class InputStream
--- @field data any
--- @field mode integer
local InputStream = { }

--- @param data any
--- @param mode? integer
function InputStream.new(data, mode)
    -- mode 0 => default, 1 => opposite
    local obj = {data = data, mode = mode or 0}
    return setmetatable(obj, {
        __tostring = function (t) return tostring(t.data) end,
        __concat = function (left, right)
            return tostring(left) .. tostring(right)
        end,
        __index = function (_, k)
            return obj[k]
        end
    })
end

local STDOUT = BaseStream.new(function (_, right)
    io.write(right)
end, nil)

-- InputStream mode defaults to one line
local STDIN = BaseStream.new(nil, function (_, right)
    right.data = io.read(right.mode == 0 and "*l" or "*a")
end)

--- @class FStream
--- @field file file*
local FStream = { }
FStream.__index = FStream

--- @param source string
--- @param mode string
--- @return FStream | nil
function FStream.new(source, mode)
    local file = io.open(source, mode)
    if file then
        local obj = { file = file }
        return setmetatable(obj, {
            __index = FStream,
            __shl = function (_, right)
                file:write(tostring(right))
            end,
            __shr = function (_, right)
                -- Defaults to all file
                right.data = file:read(right.mode == 0 and "a" or "l")
            end
        })
    end
    return nil
end

function FStream:destroy()
    self.file:close()
    self = nil
end

return {BaseStream, STDOUT, STDIN, InputStream, FStream}