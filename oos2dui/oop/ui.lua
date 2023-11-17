--[[
    CLASS ui (INHERITS obj)
        To be used as a base class for ui implementations to inherit from.  
        Implements behavior like:
            parent<->child relationships
            scale + offset positioning and sizing
            storage for color data fields

]]

local map = require("oos2dui.map")
local oop = require(map.oop)
local super = require(map.obj)
local class = oop.new(super)

--[[
    CONSTRUCTOR new
        Calls super:new() (therefore super:init()) and self:init().
        Called automatically when an instance is created.

    PARAM class (AUTOMATIC)
        The class that is calling.  Passed automatically (if using colon) if not provided.
    PARAM self_class (OPTIONAL)
        The name of this obj instance.

    RETURN null
]]
function class:new(self_class, name, vertices)
    --[[
        Pass name to super constructor
    --]]
    
    super.new(self, self_class, name)
    class.init(self)
end

--[[
    UTIL init OVERRIDE
        Initalizes ui datafields.  See in-function comments.
        Called automatically from new().

    RETURN null
]]
function class:init()
    --[[
        Parent and Child (P&C)
    ]]

    self.parent = nil
    self.children = {} -- Hashtable!
    self.number_of_children = 0 -- No length operation for hashtables

    self.head_child = nil
    self.tail_child = nil

    self.next_sibling = nil
    self.prev_sibling = nil

    self.z = 0

    self.rotate_children = true

    --[[
        Position
            x, y, anchor_x_position, anchor_y_position are not options, but calculated values from refresh()
    ]]

    self.x = display.contentWidth/2
    self.y = display.contentHeight/2
    self.anchor_x_position = 0
    self.anchor_y_position = 0


    self.scale_x = 0.5
    self.scale_y = 0.5
    self.offset_x = 0
    self.offset_y = 0

    self.anchor_x = 0.5
    self.anchor_y = 0.5
    self.rotation = 0

    --[[
        Size
            w, h are not options, but calculated values from refresh()
    ]]

    self.w = 50
    self.h = 50

    self.scale_w = 0
    self.scale_h = 0
    self.offset_w = 50
    self.offset_h = 50
    self.scale = 1

    --[[
        Color
    ]]

    self.border = 0

    self.fill = {1}
    self.border_fill = {0.1, 0.2, 0.3}
    self.alpha = 1
    self.fill_rotation = 0

    --[[
        Display Object (from Solar2D)
    ]]
    self.scene_index = 0
    self.display_object = nil
end

--[[
    P&C add_child
        Creates a parental relationship between self and the parameter.

    PARAM child
        The ui to be added as a child.

    RETURN bool
        true if child was added.
]]
function class:add_child(child)
    local child_hashcode = child:to_hashcode()

    if child.parent == self then
        -- Already a child of self.
        return false
    end

    child:clear_parent()

    --[[
        Standard linked list addition behavior:
    ]]

    if self.number_of_children == 0 then
        self.head_child = child
        self.tail_child = child
    else 
        local prev
        local curr = self.head_child

        while curr and curr.z < child.z do
            prev = curr
            curr = curr.next_sibling
        end

        if prev then
            prev.next_sibling = child
            child.prev_sibling = prev
        else
            self.head_child = child
        end

        if curr then
            curr.prev_sibling = child
            child.next_sibling = curr
        else
            self.tail_child = child
        end        
    end

    child.parent = self
    self.children[child:to_hashcode()] = child -- Add the child via hashcode so it can be looked up O(1)
    self.number_of_children = self.number_of_children + 1

    return true
end

--[[
    P&C clear_parent
        Removes self's relationship with its parent, if it has one.
        Just calls the parent's remove_child() function.
    
    RETURN bool
        true if parent was cleared (reset to nil).
        false if self has no parent, or parent's remove_child() function failed.
]]
function class:clear_parent()
    if self.parent then
        return self.parent:remove_child(self)
    end

    return false
end

--[[
    P&C remove_child
        Removes self's parent<->child relationship with the parameter, if it has one.
    
    PARAM child
        The child to be removed as a child.

    RETURN bool
        true if the child was removed.
        false if the parameter was never a child.
]]
function class:remove_child(child)
    if child.parent ~= self then
        -- Not a parent of self.
        return false
    end

    --[[
        Standard linked list removal behavior:
    ]]

    local prev = child.prev_sibling
    local next = child.next_sibling

    if prev then
        prev.next_sibling = next
    else
        self.head_child = next
    end

    if next then
        next.prev_sibling = prev
    end

    child.prev_sibling = nil
    child.next_sibling = nil

    child.parent = nil
    self.children[child:to_hashcode()] = nil
    self.number_of_children = self.number_of_children - 1

    return true
end

--[[
    P&C refresh_z
        Ensures self is in the correct place in the sibling linked list.
        To be called after changing self.z.

    RETURN bool
        true if self was corrected.
        false if self has no parent, self was in the correct spot, or the re-addition to parent failed.
]]
function class:refresh_z()
    if not self.parent or self.parent.number_of_children == 1 then
        -- no parent or no reason to refresh
        return false
    end

    if (self.prev_sibling and self.prev_sibling.z <= self.z) or (self.next_sibling and self.next_sibling.z >= self.z) then
        -- self.z is between siblings
        return false 
    end

    local parent = self.parent
    if parent:remove_child(self) then
        return parent:add_child(self)
    end
        
    return false

    --[[
        Alternatively, self could be swapped with prev/next siblings until it lies in the correct spot
    ]]
end

--[[
    P&C get_child
        Returns the child associated with the given parameter as a hashcode.

    RETURN table
        null if no child with the given parameter as a hashcode exists.
]]
function class:get_child(hashcode)
    return self.children[hashcode]
end

--[[
    SETTER set_size
        Conveniently sets all four size data fields.

    PARAM scale_w
        The new value for self.scale_w
    PARAM scale_h
        The new value for self.scale_h
    PARAM offset_w
        The new value for self.offset_w
    PARAM offset_h
        The new value for self.offset_h
        
    RETURN null
]]
function class:set_size(scale_w, scale_h, offset_w, offset_h)
    self.scale_w = scale_w
    self.scale_h = scale_h
    self.offset_w = offset_w
    self.offset_h = offset_h
end

--[[
    SETTER set_position
        Conveniently sets all four position data fields.

    PARAM scale_x
        The new value for self.scale_x
    PARAM scale_y
        The new value for self.scale_y
    PARAM offset_x
        The new value for self.offset_x
    PARAM offset_y
        The new value for self.offset_y

    RETURN null
]]
function class:set_position(scale_x, scale_y, offset_x, offset_y)
    self.scale_x = scale_x
    self.scale_y = scale_y
    self.offset_x = offset_x
    self.offset_y = offset_y
end

--[[
    UTIL refresh
        Calculates w, h, x, y, anchor_x_position, anchor_y_position.
        Calls refresh_children() unless none of them have changed since last refresh() call.

    RETURN null
]]
function class:refresh()
    local parent_x = self.parent and self.parent.x or display.contentWidth / 2
    local parent_y = self.parent and self.parent.y or display.contentHeight / 2   
    local parent_w = self.parent and self.parent.w or display.contentWidth
    local parent_h = self.parent and self.parent.h or display.contentHeight    
    
    local w = (self.scale_w * parent_w + self.offset_w) * self.scale
    local h = (self.scale_h * parent_h + self.offset_h) * self.scale  
    local x = ((parent_x - parent_w / 2) + (parent_w * self.scale_x) + self.offset_x) + (0.5 - self.anchor_x) * self.w
    local y = ((parent_y - parent_h / 2) + (parent_h * self.scale_y) + self.offset_y) + (0.5 - self.anchor_y) * self.h
    local anchor_x_position = self.x - ((0.5 - self.anchor_x) * self.w)
    local anchor_y_position = self.y - ((0.5 - self.anchor_y) * self.h)
    
    if self.w == w and self.h == h and 
        self.x == x and self.y == y and 
        self.anchor_x_position == anchor_x_position and self.anchor_y_position == anchor_y_position then
        -- Nothing changed!  No need to refresh the children.
    else
        self.w = w
        self.h = h
        self.x = x
        self.y = y
        self.anchor_x_position = anchor_x_position
        self.anchor_y_position = anchor_y_position

        self:refresh_children()
    end
end

--[[
    UTIL refresh_children
        Calls refresh() on each child, from head to tail.
        Called automatically from refresh().

    RETURN null
]]
function class:refresh_children()
    local curr = self.head_child
    while curr do
        curr:refresh()
        curr = curr.next_sibling
    end  
end

--[[
    UTIL get_total_rotation
        Recursively calculates self.rotation + self.parent:get_total_rotation().

    RETURN number
        The total rotation, in degrees, of self.
]]
function class:get_total_rotation()
    if self.parent and self.parent.rotate_children then
        return self.rotation + self.parent:get_total_rotation()
    end

    return self.rotation
end

--[[
    UTIL erase
        Deletes the current display object and stores its scene index

    RETURN null
]]
function class:erase()
    if self.display_object then
        local scene = display.getCurrentStage()

        for i = 1, scene.numChildren do
            if scene[i] == self.display_object then
                self.scene_index = i
                break
            end
        end
    end

    display.remove(self.display_object)
    self.display_object = nil
end

return class