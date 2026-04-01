local utils = require("utils.")

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