local test = {}

local map = require("oos2dui.map")
local obj = require(map.oop)

function test.init()
    --[[
        Create 3 classes, each inheriting from the last
    ]]

    local c1 = oop.new()
    local c2 = oop.new(c1)
    local c3 = oop.new(c2)

    --[[
        Create constructors, each calling the superclass's
    ]]

    print(c1, c2, c3)

    function c1:new(class, param)
        print(self, class, getmetatable(self))
        self.v1 = param
    end

    function c2:new(class, param)
        getmetatable(class).new(self, getmetatable(class), param)

        self.v2 = param
    end

    function c3:new(class, param)
        getmetatable(class).new(self, getmetatable(class), param)

        self.v3 = param
    end

    --[[
        Create a function for each class
    ]]

    function c1:f1(param)
        self.v1 = param
    end

    function c2:f2(param)
        self.v2 = param
    end

    function c3:f3(param)
        self.v3 = param
    end

    --[[
        Make classes accessible to other tests
    ]]

    test.c1 = c1
    test.c2 = c2
    test.c3 = c3
end

function test.inheritance()
    --[[
        Create instance for each 3 classes
        Test constructors
    ]]

    local o1 = test.c1(1)
    local o2 = test.c2(2)
    local o3 = test.c3(3)

    --[[
        Check constructors initialized data fields
    ]]

    assert(o1.v1 == 1, "o1 v1 constructor fail")

    assert(o2.v1 == 2, "o2 v1 constructor fail")
    assert(o2.v2 == 2, "o2 v2 constructor fail")

    assert(o3.v1 == 3, "o3 v1 constructor fail")
    assert(o3.v2 == 3, "o3 v2 constructor fail")
    assert(o3.v3 == 3, "o3 v3 constructor fail")

    --[[
        Check function access
    ]]

    assert(o2.f1, "o2 f1 access fail")

    assert(o3.f1, "o3 f1 access fail")
    assert(o3.f2, "o3 f2 access fail")
end

return test

--[[
    local oop_unit = require("tests.oop_unit")

    oop_unit.init()
    oop_unit.inheritance()
]]