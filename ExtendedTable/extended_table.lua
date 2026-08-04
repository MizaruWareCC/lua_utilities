------------------------------------------------------------
-- table.lua
-- Made by https://github.com/MizaruWareCC
------------------------------------------------------------

--- @class Extended_table
local Extended_table = {}

Extended_table.__index = function (t, k)
    return rawget(t, k) or (rawget(Extended_table, k) or table[k])
end

Extended_table.__call = function(_, ...)
    return Extended_table.new(...)
end

local _NEWLINE = ",\n"

--- @param tbl? table
--- @return Extended_table
function Extended_table.new(tbl)
    tbl = tbl or {}
    local proxy = {}
    local mt = {
        __index = Extended_table.__index,
        __newindex = function(t, k, v)
            tbl[k] = v
        end,
        __pairs = function(t)
            return pairs(tbl)
        end,
    }
    return setmetatable(proxy, mt)
end

--- @param value any
--- @param recursive? boolean
--- @param seen? table | Extended_table
function Extended_table:contains(value, recursive, seen)
    seen = seen or Extended_table.new()
    for _, v in pairs(self) do
        if v == value then
            return true
        end
        if recursive and type(v) == "table" and not seen[v] then
            seen[v] = true
            if Extended_table.contains(v, value, true, seen) then
                return true
            end
        end
    end
    return false
end

--- @param out? table | Extended_table
--- @param seen? table | Extended_table
function Extended_table:deep_copy(out, seen)
    out = out or Extended_table.new()
    seen = seen or Extended_table.new()
    seen[self] = out

    for k, v in pairs(self) do
        if type(v) == "table" then
            if seen[v] then
                out[k] = seen[v]
            else
                local placeholder = Extended_table.new()
                out[k] = setmetatable(placeholder, getmetatable(v))
                seen[v] = out[k]
                Extended_table.deep_copy(v, out[k], seen)
            end
        else
            out[k] = v
        end
    end

    return setmetatable(out, getmetatable(self))
end

--- @param recursive? boolean
--- @param indent? string
--- @param seen? table | Extended_table
--- @param level? integer
function Extended_table:dump(recursive, indent, seen, level)
    indent = indent or "\t"
    recursive = recursive or false
    seen = seen or {}
    level = level or 1
    if level == 1 then seen[self] = true end

    local function quote_if_string(x)
        if type(x) == "string" then return '"' .. x .. '"' end
        return tostring(x)
    end

    local pad = string.rep(indent, level - 1)
    local keypad = string.rep(indent, level)
    local dump = "{\n"

    for k, v in pairs(self) do
        local keypart
        if type(k) == "string" then
            keypart = keypad .. '["' .. k .. '"] = '
        else
            keypart = keypad .. "[" .. tostring(k) .. "] = "
        end

        if type(v) == "table" then
            if seen[v] then
                dump = dump .. keypart .. "<cycle>" .. _NEWLINE
            elseif recursive then
                seen[v] = true
                dump = dump .. keypart .. Extended_table.dump(v, true, indent, seen, level + 1) .. _NEWLINE
            else
                dump = dump .. keypart .. "<table>" .. _NEWLINE
            end
        else
            dump = dump .. keypart .. quote_if_string(v) .. _NEWLINE
        end
    end

    dump = dump .. pad .. "}"
    return dump
end

--- @param with table | Extended_table
--- @param copy? boolean
--- @param on_conflict? function
function Extended_table:merge(with, copy, on_conflict)
    on_conflict = on_conflict or function(_, _) end

    if copy then
        local result = Extended_table.new()
        for k, v in pairs(self) do
            result[k] = v
        end
        for k, v in pairs(with) do
            if result[k] ~= nil and on_conflict(k, v) == -1 then
                return nil
            end
            result[k] = v
        end
        return result
    else
        for k, v in pairs(with) do
            if self[k] ~= nil and on_conflict(k, v) == -1 then
                return
            end
            self[k] = v
        end
        return self
    end
end

---@param filter? function
function Extended_table:recursive_copy(orig, filter, copies)
    copies = copies or {}

    if filter and not filter(orig) then
        return orig
    end

    local orig_type = type(orig)

    if orig_type ~= "table" then
        return orig
    end

    if copies[orig] then
        return copies[orig]
    end

    local copy = {}
    copies[orig] = copy

    for orig_key, orig_value in next, orig do
        local key_copy = self:recursive_copy(orig_key, filter, copies)
        local value_copy = self:recursive_copy(orig_value, filter, copies)
        copy[key_copy] = value_copy
    end

    setmetatable(copy, self:recursive_copy(getmetatable(orig), filter, copies))

    return copy
end

---@param filter? function
function Extended_table:shallow_copy(filter)
    local new = {}

    for k, v in pairs(self) do
        if filter then
            if filter(v) then new[k] = v end
        else
            new[k] = v
        end
    end

    return new
end

---@param remove boolean?
---@return any
function Extended_table:get_random(remove)
    local idx = math.random(0, #self)
    local item = self[idx]
    if remove then table.remove(self, idx) end
    return item
end

return Extended_table
