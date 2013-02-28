require "World"
function love.update()
    
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
    world:initCell()
end

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
    xIndex = math.floor(xIndex/cellSize)
    yIndex = math.floor(yIndex/cellSize)

    if escape then
        beginDraw = false
        tempStart = nil
        tempEnd = nil
        world:clearWorld()
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
end
