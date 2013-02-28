
cellSize = 10
cellNum = 80
function love.conf(t)
    print(t)
    t.screen.width = cellSize*(cellNum+2)
    t.screen.height = cellSize*(cellNum+2)
end
