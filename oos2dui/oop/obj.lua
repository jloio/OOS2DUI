--[[
    CLASS obj
        To be used as a base class to inherit from.  
        Has commonly desired data fields and functions like name and to_hashcode().
]]

local map = require("oos2dui.map")
local oop = require(map.oop)
local super = nil
local class = oop.new(super)

--[[
    CONSTRUCTOR new
        Calls class:init().
        Called automatically when an instance is created.

    PARAM self_class (AUTOMATIC)
        The class that is calling.  Passed automatically if not provided.
    PARAM name (OPTIONAL)
        The name of this obj instance.

    RETURN null
]]
function class:new(self_class, name)
    class.init(self)
    self.name = name
end

--[[
    UTIL init
        Initializes the instance's data fields.
        Called automatically from the constructor.

    RETURN null
]]
function class:init()
    --[[
        This function will occaisonally initialize fields to nil, 
        which means they aren't initalized at all.
        This is for readability.
    ]]

    self.name = "obj"
    self.timestamp = os.time()

    self.hashcode = nil
end

--[[
    CALC to_hashcode
        Defines this instance's hashcode as its hashcode data field if it exists, or its name.

    RETURN number or string
        This instance's hashcode, to be used in hashtables.
]]
function class:to_hashcode()
    return self.hashcode or self.name
end

return class