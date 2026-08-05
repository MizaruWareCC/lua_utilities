---@class Class
---@field __type string
---@field is fun(Class, any): boolean
local Class;

-- Creating Class instance

Class = setmetatable({ }, {
	---@param type string
	---@param protected_members { string: any }
	__call = function(_, type, protected_members) -- Class(type_name)
		local real = setmetatable({ __type = type }, { __index = Class }) -- fields in real, base methods in Class
		protected_members = protected_members or { }
		for k, v in pairs(protected_members) do
			real[k] = v
		end
		local proxy = { }
		local metatable = {
			__index = function(_, k)
				return real[k]
			end,
			__newindex = function(_, k, v)
				if k:match("^__%w+") then return end -- protect any underscored private members from changes
				real[k] = v
			end
		}

		return setmetatable(proxy, metatable)
	end
})


-- Base methods for Classes

---@return boolean
function Class:is(v)
	if type(v) ~= "table" then return false end
	if v.__type == self.__type then return true else return false end
end

-- Helpers

---@param class Class
---@param type_name string
---@return boolean
local function check_type(class, type_name)
	return type(class) == "table" and class.__type == type_name
end


return {Class=Class, check_type=check_type}
