local extended_table = require"extended_table"
local ext_t = extended_table.new()

ext_t["w"] = 100
---@diagnostic disable-next-line: inject-field
ext_t.sub = extended_table.new({
    Loop = true,
    [100] = 200
})
local copy = ext_t:deep_copy()


assert(ext_t:contains(100) == true)
assert(ext_t:contains(200, true) == true)


assert(copy:contains(100) == true)
assert(copy:contains(200, true) == true)