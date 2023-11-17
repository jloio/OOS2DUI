--[[
    CLASS polygon (INHERITS ui)
        Uses features from ui class to draw polygons.
        Uses display.newPolygon()

]]

local map = require("oos2dui.map")
local oop = require(map.oop)
local super = require(map.ui)
local class = oop.new(super)

--[[
    HELPER rotate
        Calculates the x, y coordinates of the point made by (x1, y1) rotated around the point made by (x2, y2) r radians

    RETURN number, number
        The x, y coordinate of (x1, y1) rotated around (x2, y2) r radians    
]]
local function rotate(x1, y1, x2, y2, r)
    local sinr, cosr = math.sin(r), math.cos(r)
    local x = ((x1 - x2) * cosr) - ((y1 - y2) * sinr) + x2
    local y = ((x1 - x2) * sinr) + ((y1 - y2) * cosr) + y2
    
    return x, y
end

--[[
    CONSTRUCTOR new
        Calls super:new() (therefore super:init()) and self:init().
        Called automatically when an instance is created.

    PARAM self_class (AUTOMATIC)
        The class that is calling.  Passed automatically (if using colon) if not provided.
    PARAM name (OPTIONAL)
        The name of this obj instance.
    PARAM vertices (OPTIONAL)
        Either a table of vertices, or the number of vertices this polygon will have.        

    RETURN null
]]
function class:new(self_class, name, vertices)
    --[[
        Pass name to super:new()

        Alternatively, this could be
        getmetatable(class).new(self, getmetatable(class), name)
    --]]
    
    super.new(self, self_class, name)
    self:init()

    self:set_vertices(vertices)
end

--[[
    UTIL init OVERRIDE
        Initalizes polygon datafields.  See in-function comments.
        Called automatically from new().

    RETURN null
]]
function class:init()
    --[[
        Polygon
            polygon_x, polygon_y, and polygon_vertices are calculated values from refresh_polygon()
    ]]
    self.raw_vertices = nil
    self.vertices_default_rotation = 0

    self.polygon_x = 0
    self.polygon_y = 0
    self.polygon_vertices = {}    
end

--[[
    SETTER set_vertices
        Sets self.vertices based on the parameter.

    PARAMETER vertices
        Either a table (to be directly set as self.vertices) 
        or a number, signifying the number of vertices (used to calculate vertices)

    RETURN null
]]
function class:set_vertices(vertices)
    local new_vertices
    local min_x, max_x, min_y, max_y = 0, 0, 0, 0

    if type(vertices) == "table" then
        new_vertices = vertices

        for i = 1, #new_vertices, 2 do
            local x, y = new_vertices[i], new_vertices[i + 1]

            if i == 1 then
                min_x, max_x = x, x
                min_y, max_y = y, y
            else
                if x < min_x then min_x = x end
                if x > max_x then max_x = x end
                if y < min_y then min_y = y end
                if y > max_y then max_y = y end
            end
        end
    else
        --[[
            Preset for square and triangle
            otherwise generate vertices from unit circle.
        ]]
        if vertices == 4 then
            new_vertices = {
                -0.5, -0.5, 
                -0.5, 0.5,
                0.5,  0.5,
                0.5, -0.5}
        elseif vertices == 3 then
             new_vertices = {
                -0.5, -0.5,
                0.5, -0.5,
                0, 0.5
             }   
        else
            new_vertices = {}

            local angle = 360 / vertices
            for i = 1, vertices do
                local x = 0.5 * math.sin(math.rad(i * angle))
                local y = 0.5 * math.cos(math.rad(i * angle))
                
                if x <= 0.001 and x >= -0.001 then --rounding
                    x = 0
                end
                
                if y <= 0.001 and y >= -0.001 then --rounding
                    y = 0
                end

                if i == 1 then
                    min_x, max_x = x, x
                    min_y, max_y = y, y
                else
                    if x < min_x then min_x = x end
                    if x > max_x then max_x = x end
                    if y < min_y then min_y = y end
                    if y > max_y then max_y = y end
                end

                new_vertices[#new_vertices + 1] = x
                new_vertices[#new_vertices + 1] = y
            end

        end
    end

    --[[
        Average out the difference in max and min
    ]]

    for i = 1, #new_vertices, 2 do
        new_vertices[i] = new_vertices[i] - (max_x + min_x)/2
        new_vertices[i + 1] = new_vertices[i + 1] - (max_y + min_y)/2
    end

    self.vertices_min_x = min_x
    self.vertices_max_x = max_x
    self.vertices_min_y = min_y
    self.vertices_max_y = max_y

    self.raw_vertices = new_vertices
end

--[[
    UTIL refresh_polygon()
        Calculates polygon_x, polygon_y, polygon_vertices.

    RETURN null
]]
function class:refresh_polygon()
    --[[
        This function needs better comments!
    ]]

    local total_rotation = math.rad(self:get_total_rotation() + self.vertices_default_rotation)

    --[[
        Step 1: 
        Add position, size, and rotation to vertices.
    ]]

    local raw_vertices = self.raw_vertices
    local vertices = {}
    local min_x, max_x, min_y, max_y = 0, 0, 0, 0

    for i = 1, #raw_vertices, 2 do
        local x, y = raw_vertices[i], raw_vertices[i + 1]

        x = (x * self.w) + self.x
        y = (y * self.h) + self.y
        x, y = rotate(x, y, self.x, self.y, total_rotation)

        if i == 1 then
            min_x, max_x = x, x
            min_y, max_y = y, y
        else
            if x < min_x then min_x = x end
            if x > max_x then max_x = x end
            if y < min_y then min_y = y end
            if y > max_y then max_y = y end
        end

        vertices[i], vertices[i + 1] = x, y
    end

    --[[
        Step 2:
        Recenter the polygon, asymmetric polygons (like those with odd number of edges) will be off-center
        Define x, y
    ]]

	local center_x = (min_x + max_x)/2
	local center_y = (min_y + max_y)/2
	if math.abs(center_x) < 0.001 then center_x = 0 end
	if math.abs(center_y) < 0.001 then center_y = 0 end
    
    local dist_x = center_x - self.x
    local dist_y = center_y - self.y
    
    local x, y = self.x + dist_x, self.y + dist_y

    --[[
        Step 3:
        Rotate polygon around parent's anchor point by the parent's rotation
    ]]

    local parent_anchor_x, parent_anchor_y = 0.5, 0.5

    local curr_parent = self.parent
    while curr_parent do
        parent_anchor_x, parent_anchor_y = curr_parent.anchor_x_position, curr_parent.anchor_y_position
        x, y = rotate(x, y, parent_anchor_x + dist_x, parent_anchor_y + dist_y, math.rad(curr_parent.rotation))
        curr_parent = curr_parent.parent
    end

    --[[
        Step 4:
        Rotate polygon around anchor point by the polygon's rotation
    ]]

    if self.anchor_x ~= 0.5 or self.anchor_y ~= 0.5 then
        local anchor_x, anchor_y = self.anchor_x_position, self.anchor_y_position
        
        local curr_parent = self.parent
        while curr_parent do
            anchor_x, anchor_y = rotate(anchor_x, anchor_y, parent_anchor_x, parent_anchor_y, math.rad(curr_parent.rotation))
            curr_parent = curr_parent.parent
        end

        x, y = rotate(x, y, anchor_x + dist_x, anchor_y + dist_y, math.rad(self.rotation))

        for i = 1, #vertices, 2 do
            vertices[i] = vertices[i] - (self.x - x)
            vertices[i + 1] = vertices[i + 1] - (self.y - y)
        end
    end

    self.polygon_x = x
    self.polygon_y = y
    self.polygon_vertices = vertices

    self:refresh_polygon_children()
end

--[[
    UTIL refresh_children
        Calls refresh_polygon() on each child, from head to tail.
        Called automatically from refresh_polygon().

    RETURN null
]]
function class:refresh_polygon_children()
    local curr = self.head_child
    while curr do
        curr:refresh_polygon()
        curr = curr.next_sibling
    end  
end

--[[
    UTIL draw
        Uses calculated values from refresh_polygon and Solar2D's display library to draw a polygon.

    RETURN null
]]
function class:draw()
    self:erase()

    local drawing = display.newPolygon(self.polygon_x, self.polygon_y, self.polygon_vertices)
    drawing.fill = self.fill
    drawing.fill.rotation = self.fill_rotation
    drawing.alpha = self.alpha
    drawing.strokeWidth = self.border
    drawing:setStrokeColor(unpack(self.border_fill))

    if self.scene_index ~= 0 then
        display:getCurrentStage():insert(self.scene_index, drawing)
    end

    self.display_object = drawing

    self:draw_children()
end

--[[
    UTIL refresh_draw()
        Conveniently calls all refresh functions and draw().

    RETURN null
]]
function class:refresh_draw()
    self:refresh()
    self:refresh_polygon()
    self:draw()
end

--[[
    UTIL refresh_children
        Calls draw() on each child, from head to tail.
        Called automatically from draw().

    RETURN null
]]
function class:draw_children()
    local curr = self.head_child
    while curr do
        curr:draw()
        curr = curr.next_sibling
    end
end

return class