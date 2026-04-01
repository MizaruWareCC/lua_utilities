local utils = require("utils.")

-- Extended table

local ext_t = utils.table.new()

ext_t["w"] = 100
---@diagnostic disable-next-line: inject-field
ext_t.sub = utils.table.new({
    Loop = true,
    [100] = 200
})
ext_t:dump(true)
--[[
{
        ["sub"] = {
                ["Loop"] = true,
                [100] = 200,
        },
        ["w"] = 100,
}
--]]


-- Streams

---@enum STREAMS
local STREAMS = {
    BaseStream = 1,
    STDOUT = 2,
    STDIN = 3,
    InputStream = 4,
    FStream = 5
}

local stdout = utils.streams[STREAMS.STDOUT]
local stdin = utils.streams[STREAMS.STDIN]

_(stdout << "Hello, world!\n") -- console: "Hello, world!"
local input = utils.streams[STREAMS.InputStream].new()
_(stdin >> input) -- puts input into input.data
print(tostring(input)) -- translates to tostring(input.data)

local file = utils.streams[STREAMS.FStream].new("stream.txt", "w")
assert(file, "Failed to open file to write")
_(file << "My stream\n")
file:destroy()
file = utils.streams[STREAMS.FStream].new("stream.txt", "r")
assert(file, "Failed to open file to read")
_(file >> input)
_(stdout << tostring(input)) -- "My stream"
file:destroy()

-- Debugger

-- debugger.lua
--- @enum LActions
local actions = {
    READ = 1,
    WRITE = 2,
    CALL = 3,
    HOOK_FUNCTION = 4
}

local debugger = utils.debugger.new()
debugger:set_custom_callback(function (args, callable_name, parent_name)
    print("Called " .. callable_name .. " from table " .. parent_name .. "; args ::= [", table.unpack(args), "]")
    -- can return false to prevent function from executing or return anything else/nothing to process
end)

debugger:run("print('Hiiii')")
--[[
Action READ at x.xxxxS: Reading from _ENV with key print, got data: function: <addr> (type: function)
Called print from table _ENV; args ::= [        Hiiii   ]
Hiiii
Action HOOK FUNCTION at 1.3710S: Hooked function print called on _ENV: args=[Hiiii] -> result=[] (OK)
DEBUGGER: finished executing code
]]--