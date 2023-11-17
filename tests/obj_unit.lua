local test = {}

local map = require("oos2dui.map")
local obj = require(map.obj)

function test.init()
    --[[
        Initialize three instances of obj
    ]]

    local o1 = obj("o1")
    local o2 = obj("o2")
    local o3 = obj("o3")

    --[[
        Make instances accessible to other tests
    ]]

    test.o1 = o1
    test.o2 = o2
    test.o3 = o3
end

function test.hashcode()
    --[[
        change name and hashcode data fields, and test to_hashcode function
    ]]

    local o1 = test.o1
    local o2 = test.o2
    local o3 = test.o3

    o1.name = "name"
    o1.hashcode = nil
    assert(o1:to_hashcode() == "name", "name to_hashcode fail")

    o1.hashcode = "hashcode" 
    assert(o1:to_hashcode() == "hashcode", "hashcode to_hashcode fail")
    
    --[[
        Test hashcode functionality by using it in a table
    ]]

    local t = {}

    local function t_insert(o)
        t[o:to_hashcode()] = o
    end

    o1.hashcode = "o1"
    o2.hashcode = "o2"
    o3.hashcode = "o3"

    t_insert(o1)
    t_insert(o2)
    t_insert(o3)

    assert(t["o1"] == o1, "o1 hashcode lookup fail")
    assert(t["o2"] == o2, "o2 hashcode lookup fail")
    assert(t["o3"] == o3, "o3 hashcode lookup fail")
end

function test.super_constructor()
    --[[
        Define new sublcass of obj
    ]]

    local super = obj
    local sub = require("oop.oop").new(super)
    function sub:new(class, name)
        super:new(class, name)
        --[[
            Alternatively, if super is not available:
            getmetatable(class).new(self, getmetatable(class), name)
        ]]
    end

    --[[
        Initialize subclass, test for change of name data field
    ]]

    local s1 = sub("s1")
    assert(s1.name == "s1", "super constructor call fail")
end

return test