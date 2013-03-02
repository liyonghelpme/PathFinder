require "World"
require "Ray"
require "Body"

--更新小孩的移动位置
function love.update()
    local dt = love.timer.getDelta()
    if tempBody ~= nil then
        tempBody:doMove(dt)
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
            end
        end
    end


end
function love.load()
    world = World.new(cellNum)
    world.cellSize = cellSize
    world:initCell()
end
--[[
首先确定世界的startPoint endPoint
接着搜索路径 path
设定Body 的起始点 和 终点 startPoint endPoint
设定Body的path  setPath  自动根据光线追踪的方法将路径转化成直线路径 保存在Body 的path属性里面
]]--
function love.draw()
    love.graphics.setBackgroundColor(128, 128, 128)
    love.graphics.print("hello world", 400, 300)

    love.graphics.setColor(0, 0, 0)
    for i = 0, cellNum+1, 1 do
        love.graphics.line(i*cellSize, 0, i*cellSize, (cellNum+2)*cellSize )
        love.graphics.line(0, i*cellSize, (cellNum+2)*cellSize, i*cellSize )
    end

    local xIndex, yIndex = love.mouse.getPosition()
    local leftClicked = love.mouse.isDown("l")
    local rightClicked = love.mouse.isDown("r")
    local ctrl = love.keyboard.isDown("lctrl") or love.keyboard.isDown("lctrl");
    local shift = love.keyboard.isDown("lshift") or love.keyboard.isDown("lshift");
    local enter = love.keyboard.isDown("return")
    local escape = love.keyboard.isDown("escape")
    local space = love.keyboard.isDown(" ")

    xIndex = math.floor(xIndex/cellSize)
    yIndex = math.floor(yIndex/cellSize)




    if escape then
        beginDraw = false
        tempStart = nil
        tempEnd = nil
        world:clearWorld()
    -- 开始绘制小球运动
    elseif space and tempBody == nil then
        tempBody = Body.new(world)
        tempBody:setStartEnd(world.startPoint, world.endPoint)
        tempBody:setPath(world.path)
    elseif xIndex >= 1 and xIndex <= cellNum and yIndex >= 1 and yIndex <= cellNum then
        if ctrl and leftClicked and tempStart == nil then
            print("start", xIndex, yIndex)
            tempStart = {xIndex, yIndex}
            world:putStart(xIndex, yIndex)
        elseif ctrl and rightClicked and tempEnd == nil then
            tempEnd = {xIndex, yIndex}
            world:putEnd(xIndex, yIndex)
        elseif shift and leftClicked and not beginDraw then
            world:putWall(xIndex, yIndex)
        elseif enter and tempStart and tempEnd and not beginDraw then
            beginDraw = true
            world:search()
        end
    end
    showWorld()

    if tempBody ~= nil then
        tempBody:draw()
    end

end

-- 绘制标准网格
-- 放置墙体
-- 回车确认
-- 移动鼠标 绘制 从中心点到鼠标所在网格的 rayTrace 网格
--[[
function love.draw()
    love.graphics.setBackgroundColor(128, 128, 128)

    love.graphics.setColor(0, 0, 0)
    for i = 0, cellNum+1, 1 do
        love.graphics.line(i*cellSize, 0, i*cellSize, (cellNum+2)*cellSize )
        love.graphics.line(0, i*cellSize, (cellNum+2)*cellSize, i*cellSize )
    end

    local xIndex, yIndex = love.mouse.getPosition()
    xIndex = math.floor(xIndex/cellSize)
    yIndex = math.floor(yIndex/cellSize)
    local ray = Ray.new({math.floor((cellNum+1)/2), math.floor((cellNum+1)/2)}, {xIndex, yIndex}, world)
    ray:checkCollision()
    
    for i = 1, #ray.checkedGrid, 1 do
        local x, y
        x = ray.checkedGrid[i][1]
        y = ray.checkedGrid[i][2]
        love.graphics.setColor(20, 20, 200)
        love.graphics.rectangle("line", x*cellSize, y*cellSize, cellSize, cellSize)
    end

    local lx0 = ray.a[1]*cellSize+cellSize/2
    local ly0 = ray.a[2]*cellSize+cellSize/2
    local lx1 = ray.b[1]*cellSize+cellSize/2
    local ly1 = ray.b[2]*cellSize+cellSize/2
    love.graphics.setColor(20, 200, 20)
    love.graphics.line(lx0, ly0, lx1, ly1)

    love.graphics.print(#ray.checkedGrid.." "..ray.count, 100, 100)
end
]]--
