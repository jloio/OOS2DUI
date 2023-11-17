local test = {}

local map = require("oos2dui.map")
local ui = require(map.ui)

function test.print_children(parent)
    local curr = parent.head_child

    while curr do
        print(curr.name)
        curr = curr.next_sibling
    end
end

function test.PCR()
    --[[
        Create a parent and children, test add_child(), clear_parent(), remove_child(), refresh_z()
    ]]

    local parent = ui("parent")

    local c1 = ui("c1")
    c1.z = 1
    local c2 = ui("c2")
    c2.z = 2
    local c3 = ui("c3")
    c3.z = 3

    -- Add them out of order:
    parent:add_child(c2)
    parent:add_child(c3)
    parent:add_child(c1)

    --test.print_children(parent) -> c1, c2, c3
    assert(parent:get_child("c2") == c2, "parent get_child() fail")
    assert(parent.head_child == c1, "parent head_child fail")
    assert(parent.tail_child == c3, "parent tail_child fail")
    assert(c1.next_sibling == c2, "c1 next_sibling fail")
    assert(c3.prev_sibling == c2, "c3 prev_sibling fail")

    -- Add a fourth child, at the head of the list:
    local c4 = ui("c4")
    c4.z = 0
    parent:add_child(c4)
    --test.print_children(parent) -> c4, c1, c2, c3

    -- Change z and refresh:
    c4.z = 4
    c4:refresh_z()
    --test.print_children(parent) -> c1, c2, c3, c4
    assert(parent.tail_child == c4, "c4 refresh_z fail")
end

function test.SOSP()
    --[[
        This test needs to be improved. 
        Create a parent and child to test scale & offset size & position:
    ]]

    local parent = ui("parent")
    parent:set_size(0, 0, 100, 300)
    parent:set_position(0, 0, 500, 600)

    local child = ui("child")
    child:set_size(0.5, 0.1, 25, 50)
    child:set_position(0, 0.5, 0, 50)

    parent:add_child(child)
    parent:refresh()

    assert(child.w == 75, "SOS failed")
    assert(child.y == 650, "SOP failed")
end

return test