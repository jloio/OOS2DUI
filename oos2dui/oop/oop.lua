local oop = {}

--[[
function oop.new_con(super)
    local class = {}
    local super = super or {}

    class.__index = class
    
    local constructor = {
        __call = function(...)
            local instance = setmetatable({}, class)
            
            if instance.new then
                instance:new(...)
            end

            return instance
        end
    }
    
    constructor.__index = constructor

    setmetatable(constructor, super)
    setmetatable(class, constructor)
    
    return class
end
]]

function oop.new(super)
    local class = {}
    local super = super or {}

    super.__call = function(...)
        local instance = setmetatable({}, class)
        
        if instance.new then
            instance:new(...)
        end

        return instance
    end

    --[[super.__add = function(self, other)
        return self.v1 + other.v1
    end--]]

    class.__index = class

    setmetatable(class, super)
    
    return class
end

return oop