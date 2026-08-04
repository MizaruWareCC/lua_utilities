---@enum STREAMS
local STREAMS = {
    BaseStream = 1,
    STDOUT = 2,
    STDIN = 3,
    InputStream = 4,
    FStream = 5
}

local streams = require"streams"

local _ = streams._

local stdout = streams[STREAMS.STDOUT]
local stdin = streams[STREAMS.STDIN]

_(stdout << "Hello, world!\n") -- console: "Hello, world!"
local input = streams[STREAMS.InputStream].new()
_(stdin >> input) -- puts input into input.data
print(tostring(input)) -- translates to tostring(input.data)

local file = streams[STREAMS.FStream].new("stream.txt", "w")
assert(file, "Failed to open file to write")
_(file << "My stream\n")
file:destroy()
file = streams[STREAMS.FStream].new("stream.txt", "r")
assert(file, "Failed to open file to read")
_(file >> input)
_(stdout << tostring(input)) -- "My stream"
file:destroy()