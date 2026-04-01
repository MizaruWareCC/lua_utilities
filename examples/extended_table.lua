local utils = require("utils.")

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
local copy = ext_t:deep_copy() -- or ext_t:deep_copy(copy)
ext_t:contains(100) -- true
ext_t:contains(200, true) -- true