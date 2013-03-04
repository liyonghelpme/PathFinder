require "World"
require "Ray"
require "Body"

-- 作为一个球体来绘制 并逐渐更新下一个位置
-- return true false 来表示是否移动到目的地
-- 怎么判断 牵引力 和 目标力？ 如何判定移动到了 目标位置？
local function updateBody(body, delta)
    local self = body

    if self.nextGrid ~= nil then
        if self.passTime >= self.totalTime then
            self.curGrid = self.nextGrid
            self.nextGrid = self.curGrid + 1
            if self.nextGrid > #self.path then --摧毁目标
                self.startPoint = self.path[self.curGrid]
                self.world:putStart(self.path[self.curGrid][1], self.path[self.curGrid][2])
                self.world:destroyBuilding(self.path[self.curGrid])
                self.nextGrid = nil
            else
                self:calculateVelocity()             
            end
        elseif self.nextGrid ~= nil then
            self.position[1] = self.position[1] + self.velocity[1]*delta
            self.position[2] = self.position[2] + self.velocity[2]*delta
            self.passTime = self.passTime + delta        
        end
    else
        --寻敌人模式
        if self.mode == 'FindTarget' then
            self.world:putStart(self.startPoint[1], self.startPoint[2])
            local path = self.world:findTarget(self)
            self.oldPath = path
            self:setPath(path)
        end
    end
end

--更新小孩的移动位置
function love.update()
    local dt = love.timer.getDelta()
    if beginDraw then
        for k, v in ipairs(bodys) do
            updateBody(v, dt)
        end
    end
end
local function showWorld()
    for j = 0, cellNum+1, 1 do
        for i = 0, cellNum+1, 1 do
            local d = world.cells[world:getKey(i, j)]
            local left = i*cellSize
            local top = j*cellSize
            if d['state'] == 'Start' then
                love.graphics.setColor(0, 204, 102)
                love.graphics.rectangle("fill", left, top, cellSize, cellSize)
            elseif d['state'] == 'End' then
                love.graphics.setColor(255, 44, 0)
                love.graphics.rectangle("fill", left, top, cellSize, cellSize)
            elseif d['state'] == 'Path' then
                love.graphics.setColor(255, 175, 0)
                love.graphics.rectangle("fill", left, top, cellSize, cellSize)
            elseif d['state'] == 'Wall' then
                love.graphics.setColor(0, 0, 0)
                love.graphics.rectangle("fill", left, top, cellSize, cellSize)
            elseif d['state'] == 'Building' then
                love.graphics.setColor(255, 44, 44)
                love.graphics.rectangle("fill", left, top, cellSize, cellSize)
            elseif d['state'] == 'SOLID' then
                love.graphics.setColor(20, 20, 255)
                love.graphics.rectangle("fill", left, top, cellSize, cellSize)
            elseif d['state'] == 'Resource' then
                love.graphics.setColor(255, 162, 0)
                love.graphics.rectangle("fill", left, top, cellSize, cellSize)
            end
        end
    end


end
function love.load()
    world = World.new(cellNum)
    world.cellSize = cellSize
    world:initCell()
end
local function drawBackground()
    love.graphics.setBackgroundColor(128, 128, 128)
    love.graphics.print("hello world", 400, 300)

    love.graphics.setColor(0, 0, 0)
    for i = 0, cellNum+1, 1 do
        love.graphics.line(i*cellSize, 0, i*cellSize, (cellNum+2)*cellSize )
        love.graphics.line(0, i*cellSize, (cellNum+2)*cellSize, i*cellSize )
    end
end

--[[
    设定世界的起始点
    设定城墙
    设定建筑物
    回车 产生新的士兵 设置士兵的起始点

    循环更新士兵状态：
        doMove 
            没有目标寻找下一个目标
            有目标 设定路径
            有路径沿着路径移动

]]--



local function showBody(body)
    local self = body
    if self.oldPath ~= nil then
        for i = 2, #self.oldPath-1, 1 do
            love.graphics.setColor(255, 175, 0)
            local left = self.oldPath[i][1]*self.world.cellSize
            local top = self.oldPath[i][2]*self.world.cellSize
            love.graphics.rectangle("fill", left, top, self.world.cellSize, self.world.cellSize)
        end
    end

    if self.position ~= nil then
        if self.kind == 'Normal' then
            love.graphics.setColor(205, 204, 102)
        elseif self.kind == 'Bomb' then
            love.graphics.setColor(255, 255, 20)
        elseif self.kind == 'Resource' then
            love.graphics.setColor(72, 191, 39)
        end
        love.graphics.circle("fill", self.position[1], self.position[2], self.world.cellSize/3)
    end
    if self.tarPos ~= nil then
        love.graphics.setColor(100, 0, 200)
        love.graphics.circle("fill", self.tarPos[1], self.tarPos[2], self.world.cellSize/3)
    end
    if self.velocity ~= nil then
        love.graphics.setColor(20, 200, 20)
        love.graphics.line(self.position[1], self.position[2], self.position[1]+self.velocity[1], self.position[2]+self.velocity[2])
    end

end
local function showBodys()
    for k, v in ipairs(bodys) do
        showBody(v)
    end
end


--[[
    建立世界
    world = World.new()  
    放置墙体
    world:putWall(x, y)
    放置建筑物
    world:putBuilding(x, y)
    放置资源建筑物
    world:putResource(x, y)


    生成士兵
    tempBody = Body.new(world, type) 士兵类型包括3中: Normal普通近战  Bomb 炸弹人  Resource 掠夺资源士兵
    设置士兵的位置
    tempBody:setStartEnd({x, y}, nil)

    士兵更新状态
    updateBody
    士兵处于空闲状态时:
        设定世界的搜索起点参数 
        self.world:putStart(self.startPoint[1], self.startPoint[2])
        开始搜索 世界返回搜索路径
        local path = self.world:findTarget(self)
        self.oldPath = path  oldPath 用于调试时绘制世界的返回的路径
        设定士兵的路径
        self:setPath(path)
    士兵处于移动状态时:
        按照得到的直线路径 self.path 逐点移动即可

]]--
soldiers = {}
bodys = {}
function love.draw()
    drawBackground()
    local xIndex, yIndex = love.mouse.getPosition()
    local leftClicked = love.mouse.isDown("l")
    local rightClicked = love.mouse.isDown("r")
    local ctrl = love.keyboard.isDown("lctrl") or love.keyboard.isDown("lctrl");
    local shift = love.keyboard.isDown("lshift") or love.keyboard.isDown("lshift");
    local enter = love.keyboard.isDown("return")
    local escape = love.keyboard.isDown("escape")
    local space = love.keyboard.isDown(" ")
    local alt = love.keyboard.isDown("lalt") or love.keyboard.isDown("ralt")
    local z = love.keyboard.isDown("z")

    xIndex = math.floor(xIndex/cellSize)
    yIndex = math.floor(yIndex/cellSize)
    
    if xIndex >= 1 and xIndex <= cellNum and yIndex >= 1 and yIndex <= cellNum then
        if z and leftClicked then
            world:putResource(xIndex, yIndex)
        elseif z and rightClicked then
            local tempBody = Body.new(world, 'Resource')
            tempBody:setStartEnd({xIndex, yIndex}, nil)
            table.insert(bodys, tempBody)
        elseif  shift and rightClicked then
            local tempBody = Body.new(world, "Bomb")
            tempBody:setStartEnd({xIndex, yIndex}, nil)
            table.insert(bodys, tempBody)
        elseif ctrl and leftClicked then
            print("start", xIndex, yIndex)
            local tempBody = Body.new(world, "Normal")
            tempBody:setStartEnd({xIndex, yIndex}, nil)
            table.insert(bodys, tempBody)
        elseif ctrl and rightClicked then
            world:putBuilding(xIndex, yIndex)
        elseif shift and leftClicked and not beginDraw then
            world:putWall(xIndex, yIndex)
        elseif enter and not beginDraw then
            beginDraw = true
        end

    end
    showWorld()
    showBodys()
end
