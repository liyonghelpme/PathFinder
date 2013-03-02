require "Class"
Ray = class()
function Ray:ctor(a, b, world)
    self.a = a
    self.b = b
    self.world = world
end
--  返回相交的所有网格
function Ray:checkCollision()
    self.checkedGrid = {}
    local x, y = self.a[1], self.a[2]
    local vector = {self.b[1]-self.a[1], self.b[2]-self.a[2]}
    local dx = 0
    local dy = 0
    if vector[1] > 0 then
        dx = 1
    elseif vector[1] < 0 then
        dx = -1
    end
    if vector[2] > 0 then
        dy = 1
    elseif vector[2] < 0 then
        dy = -1
    end

    local p0 = x*self.world.cellSize+self.world.cellSize/2
    local p1 = y*self.world.cellSize+self.world.cellSize/2

    local tar0 = x
    if dx > 0 then
        tar0 = tar0 + dx
    end
    local tar1 = y
    if dy > 0 then
        tar1 = tar1 + dy
    end

    tar0 = tar0*self.world.cellSize
    tar1 = tar1*self.world.cellSize

    table.insert(self.checkedGrid, {x, y})
    self.count = 0

    while (x ~= self.b[1] or y ~= self.b[2]) and self.count < 2*(math.abs(vector[1])+math.abs(vector[2]))  do
        self.count = self.count + 1

        -- 小心速度 = 0 的情况
        local t0, t1
        if vector[1] ~= 0 then
            t0 = math.abs((tar0-p0)/vector[1])
        else
            t0 = 9999999
        end
        if vector[2] ~= 0 then
            t1 = math.abs((tar1-p1)/vector[2])
        else
            t1 = 9999999
        end

        print("startGrid", x, y)
        print("dx, dy", dx, dy)
        print("p0 p1", p0, p1)
        print("tar", tar0, tar1)
        print("time", t0, t1)

        
        -- Y 方向先相交
        if t0 > t1 then
            x = x
            y = y + dy
            p0 = p0+t1*vector[1]
            p1 = tar1
        else
            x = x + dx
            y = y
            p0 = tar0
            p1 = p1+t0*vector[2]
        end
        tar0 = x
        tar1 = y
        if dx > 0 then
            tar0 = tar0 + dx
        end
        if dy > 0 then
            tar1 = tar1 + dy
        end
        tar0 = tar0*self.world.cellSize
        tar1 = tar1*self.world.cellSize

        table.insert(self.checkedGrid, {x, y})
        
        if self.world.cells[self.world:getKey(x, y)]['state'] == 'Wall' then
            return true
        end
    end
    return false
end



