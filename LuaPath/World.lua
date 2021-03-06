-- 参考实现 http://www.policyalmanac.org/games/aStarTutorial.htm
-- https://github.com/liyonghelpme/PathFinder

require "Class"
require "heapq"

World = class()

--[[
startPoint 搜索起点
endPoint 搜索终点
cellNum 地图cellNum*cellNum 大小   内部表示会在地图边界加上一圈墙体 因此实际大小是(cellNum+2)*(cellNum+2) 有效坐标范围1-cellNum 
cells 记录地图每个网格的状态 nil 空白区域 Wall 障碍物 Start 开始位置 End 结束位置 

coff 将x y 坐标转化成 单一的key的系数 x*coff+y = key 默认1000


w = World()
w:initCell()
w:putStart(x, y)
w:putEnd(x, y)
w:putWall(x, y)
path = w:search()


Body 对象在不断的更新状态update：
    空闲状态  没有下一个移动目标 则 调用World的findTarget 寻找攻击目标
    移动状态  有下一个移动目标 则 沿着路径获取下一个移动目标点， 到达目标之后，切换到下一个移动目标

World记录世界状态 cellNum cellSize:
    网格状态:
        边界 SOLID 
        墙体 Wall
        建筑物 Building
    findTarget:
        寻找建筑物， 如果路径上有Wall 则 cost = 50  这个值可以用来设定选择绕过墙体还是攻击墙体 50表示最多绕过5个格子
        设定目标结束后如果目标路径上是墙体则 路径只到第一个墙体就可以了， 士兵需要先摧毁第一个墙体，再重新开始寻找下一个攻击目标
]]--
function World:ctor(cellNum, coff)
    self.startPoint = nil
    self.endPoint = nil
    self.cellNum = cellNum
    if coff == nil then
        self.coff = 100000
    else
        self.coff = coff
    end
end
function World:getKey(x, y)
    return x*self.coff+y
end
-- 初始化cells 
-- 每次生成路径都会修改cells的属性
-- 因此在下次搜索结束之前应该清空cells状态 
-- g 从start位置到当前的位置的开销
-- h 启发从当前位置到目标位置的开销
-- f = g+h
function World:initCell()
    self.resources = {}
    self.buildings = {}
    self.cells = {}
    self.walls = {}
    self.path = {}
    for x = 1, self.cellNum, 1 do
        for y = 1, self.cellNum, 1 do
            self.cells[x*self.coff+y] = {state=nil, fScore=nil, gScore=nil, hScore=nil, parent=nil, hasWall=false}
        end
    end
    for i = 0, self.cellNum+1, 1 do
        self.cells[0*self.coff+i] = {state='SOLID', fScore=nil, gScore=nil, hScore=nil, parent=nil, hasWall=false}
        self.cells[i*self.coff+0] = {state='SOLID', fScore=nil, gScore=nil, hScore=nil, parent=nil, hasWall=false}
        self.cells[(self.cellNum+1)*self.coff+i] = {state='SOLID', fScore=nil, gScore=nil, hScore=nil, parent=nil, hasWall=false}
        self.cells[i*self.coff+(self.cellNum+1)] = {state='SOLID', fScore=nil, gScore=nil, hScore=nil, parent=nil, hasWall=false}
    end
end
function World:putStart(x, y)
    self.startPoint = {x, y}
    self.cells[self:getKey(x, y)]['state'] = 'Start'
end
function World:putEnd(x, y)
    self.endPoint = {x, y}
    self.cells[self:getKey(x, y)]['state'] = 'End'
end
function World:putResource(x, y)
    self.resources[self:getKey(x, y)] = true
    self.cells[self:getKey(x, y)]['state'] = 'Resource'
end
function World:putBuilding(x, y)
    self.buildings[self:getKey(x, y)] = true
    self.cells[self:getKey(x, y)]['state'] = 'Building'
end
-- 可能摧毁普通建筑 或者 资源建筑
function World:destroyBuilding(build)
    local x = build[1]
    local y = build[2]
    local k = self:getKey(x, y)
    self.cells[k]['state'] = nil
    self.buildings[k] = nil
    self.resources[k] = nil
end
-- 存在建筑物 或者墙体
function World:checkHasBuilding(build)
    local x = build[1]
    local y = build[2]
    local k = self:getKey(x, y)
    return self.cells[k]['state'] ~= nil
end

function World:putWall(x, y)
    print("putWall", x, y)
    self.cells[self:getKey(x, y)]['state'] = 'Wall'
    table.insert(self.walls, {x, y})
end
-- 临边10 斜边 14
function World:calcG(x, y)
    local data = self.cells[self:getKey(x, y)]
    local parent = data['parent']
    local difX = math.abs(math.floor(parent/self.coff)-x)
    local difY = math.abs(parent%self.coff-y)
    local dist = 10
    -- 绕过墙体的权值 5 个墙体
    if self.searchSoldierKind == 'Normal' or self.searchSoldierKind == 'Resource' then
        if data['state'] == 'Wall' then
            dist = 50
        elseif difX > 0 and difY > 0 then
            dist = 14
        end
    elseif self.searchSoldierKind == 'Bomb' then
        if difX > 0 and difY > 0 then
            dist = 14
        end
    end
    data['gScore'] = self.cells[parent]['gScore']+dist
end
function World:calcH(x, y)
    local data = self.cells[self:getKey(x, y)]
    if self.mode == 'Search' then
        data['hScore'] = (math.abs(self.endPoint[1]-x)+math.abs(self.endPoint[2]-y))*10
    elseif self.mode == 'FindTarget' then
        if self.searchSoldierKind == 'Resource' then --地精选择最靠经资源建筑的路径
            local minDistance = self.cellNum*2 --最远的距离
            for k, v in pairs(self.resources) do
                local rx, ry = self:getXY(k) 
                local dist = math.abs(rx-x)+math.abs(ry-y)
                if dist < minDistance then
                    minDistance = dist
                end
            end
            data['hScore'] = minDistance*10 
            -- 寻找资源的士兵应该要绕过路径上的资源建筑
            -- 最差的情况下 斜对角线 绕过去
            if self.cells[self:getKey(x, y)]['state'] == 'Building' then
                data['hScore'] = data['hScore'] + 30
            end
        else
            data['hScore'] = 0
        end
    else
        data['hScore'] = 0
    end
end
function World:calcF(x, y)
    local data = self.cells[self:getKey(x, y)]
    data['fScore'] = data['gScore']+data['hScore']
end
function World:pushQueue(x, y)
    local fScore = self.cells[self:getKey(x, y)]['fScore']
    heapq.heappush(self.openList, fScore)
    local fDict = self.pqDict[fScore]
    if fDict == nil then
        fDict = {}
    end
    table.insert(fDict, self:getKey(x, y))
    self.pqDict[fScore] = fDict
end

function World:checkNeibor(x, y)
    local neibors = {
        {x-1, y-1},
        {x, y-1},
        {x+1, y-1},
        {x+1, y},
        {x+1, y+1},
        {x, y+1},
        {x-1, y+1},
        {x-1, y}
    }
    local curPosHasWall = false
    local curKey = self:getKey(x, y)
    if self.cells[curKey]['hasWall'] or self.cells[curKey]['state'] == 'Wall' then
        curPosHasWall = true
    end
        
    for n, nv in ipairs(neibors) do
        local key = self:getKey(nv[1], nv[2]) 
        -- 墙体可以摧毁self.cells[key]['state'] ~= 'Wall' and 
        -- 边缘墙体完全不能穿透
        -- 该位置 之前没有遍历过
        if self.closedList[key] == nil and self.cells[key]['state'] ~= 'SOLID' then
            -- 检测是否已经在 openList 里面了
            local nS = self.cells[key]['fScore']
            local inOpen = false
            if nS ~= nil then
                local newPossible = self.pqDict[nS]
                if newPossible ~= nil then
                    for k, v in ipairs(newPossible) do
                        if v == key then
                            inOpen = true
                            break
                        end
                    end
                end
            end
            -- 已经在开放列表里面 检查是否更新
            if inOpen then
                local oldParent = self.cells[key]['parent']
                local oldGScore = self.cells[key]['gScore']
                local oldHScore = self.cells[key]['hScore']
                local oldFScore = self.cells[key]['fScore']
                local hasWall = self.cells[key]['hasWall']

                self.cells[key]['parent'] = self:getKey(x, y)
                self:calcG(nv[1], nv[2])

                -- 新路径比原路径花费高 gScore  
                if self.cells[key]['gScore'] > oldGScore then
                    self.cells[key]['parent'] = oldParent
                    self.cells[key]['gScore'] = oldGScore
                    self.cells[key]['hScore'] = oldHScore
                    self.cells[key]['fScore'] = oldFScore
                    self.cells[key]['hasWall'] = hasWall
                else -- 删除旧的自己的优先级队列 重新压入优先级队列
                    self:calcH(nv[1], nv[2])
                    self:calcF(nv[1], nv[2])
                    self.cells[key]['hasWall'] = curPosHasWall

                    local oldPossible = self.pqDict[oldFScore]
                    for k, v in ipairs(oldPossible) do
                        if v == key then
                            table.remove(oldPossible, k)
                            break
                        end
                    end
                    self:pushQueue(nv[1], nv[2])
                end
                    
            else --不在开放列表中 直接插入
                self.cells[key]['parent'] = self:getKey(x, y)
                self:calcG(nv[1], nv[2])
                self:calcH(nv[1], nv[2])
                self:calcF(nv[1], nv[2])
                self.cells[key]['hasWall'] = curPosHasWall

                self:pushQueue(nv[1], nv[2])
            end
        end
    end
    self.closedList[self:getKey(x, y)] = true
end
function World:getXY(pos)
    return math.floor(pos/self.coff), pos%self.coff
end

--返回到达第一个需要攻击的目标的路径 可能是墙体 或者建筑物
function World:findTarget(soldier)
    self.mode = "FindTarget"
    self.searchSoldierKind = soldier.kind
    return self:realMethod()
end

function World:bombFindBuilding(soldier)
    self.mode = "BombFindBuilding"
    self.searchSoldierKind = soldier.kind
    return self:realMethod()
end

function World:realMethod()
    self.openList = {}
    self.pqDict = {}
    self.closedList = {}

    self.cells[self:getKey(self.startPoint[1], self.startPoint[2])]['gScore'] = 0
    self:calcH(self.startPoint[1], self.startPoint[2])
    self:calcF(self.startPoint[1], self.startPoint[2])
    self:pushQueue(self.startPoint[1], self.startPoint[2])

    --获取openList 中第一个fScore
    while #(self.openList) > 0 do
        local fScore = heapq.heappop(self.openList)
        --print("listLen", #self.openList, fScore)
        local possible = self.pqDict[fScore]
        local bombFindBuilding = false
        if #(possible) > 0 then

            local point = table.remove(possible) --这里可以加入随机性 在多个可能的点中选择一个点 用于改善路径的效果 
            local x, y = self:getXY(point)
            local key = point
            if self.mode == 'Search' then
                if x == self.endPoint[1] and y == self.endPoint[2] then
                    break
                end
            elseif self.mode == 'FindTarget' then
                if self.searchSoldierKind == 'Resource' then
                    if self.cells[key]['state'] == 'Building' or self.cells[key]['state'] == 'Resource' then
                        self.endPoint = {x, y} --程序设定一个目的点
                        break
                    end
                elseif self.searchSoldierKind == 'Normal' then
                    if self.cells[key]['state'] == 'Building' or self.cells[key]['state'] == 'Resource' then
                        self.endPoint = {x, y} --程序设定一个目的点
                        break
                    end
                elseif self.searchSoldierKind == 'Bomb' then --对于炸弹人来讲 需要寻找一个路径上有墙体的目标建筑 self.cells[key]['state'] == 'Wall' or
                    if self.cells[key]['state'] == 'Building' or self.cells[key]['state'] == 'Resource' then
                        if self.cells[key]['hasWall'] == true then
                            self.endPoint = {x, y}
                            break
                        end
                        bombFindBuilding = true
                    end
                end
            --炸弹人 没有找到需要翻越城墙才能攻击的建筑物 那么就找最近的建筑攻击即可
            elseif self.mode == 'BombFindBuilding' then
                if self.cells[key]['state'] == 'Building' or self.cells[key]['state'] == 'Resource' then
                    self.endPoint = {x, y}
                    break
                end
            end
            --炸弹人 找到一个 目标但是 目标路径没有城墙
            --普通 士兵必须 拆掉城墙才可以 攻击 建筑目标 
            if not bombFindBuilding then
                self:checkNeibor(x, y)
            end
        end
    end
    -- 没有找到最近的目标
    if self.endPoint == nil then
        return {}
    end

    --包含从start到end的所有点
    local path = {self.endPoint}
    local parent = self.cells[self:getKey(self.endPoint[1], self.endPoint[2])]['parent']
    print("getPath", parent)
    --不能变更状态为PATH 如果是墙体的话
    while parent ~= nil do
        local x, y = self:getXY(parent)
        table.insert(path, {x, y})
        if x == self.startPoint[1] and y == self.startPoint[2] then
            break    
        end
        --[[
        else
            self.cells[parent]['state'] = 'Path'
        end
        ]]--
        parent = self.cells[parent]["parent"]
    end
    

    --返回的路径是拷贝的数据 防止world的数据污染
    --路径中如果有墙体则停止 首先摧毁墙体再继续移动
    local temp = {}
    for i = #path, 1, -1 do
        local key = self:getKey(path[i][1], path[i][2])
        local data = self.cells[key]
        if data['state'] == 'Wall' then
            table.insert(temp, path[i])
            print("Break Wall", path[i][1], path[i][2])
            table.insert(self.path, {path[i][1], path[i][2]})
            break
        else
            table.insert(temp, path[i])
            print(path[i][1], path[i][2])
            table.insert(self.path, {path[i][1], path[i][2]})
        end
    end

    return temp
end

function World:search()
    self.mode = "Search"
    return self:realMethod()
end

function World:printCell()
    print("cur Board")
    local d
    for j = 0, self.cellNum+1, 1 do 
        for i = 0, self.cellNum+1, 1 do
            d = self.cells[self:getKey(i, j)]
            if d['state'] == nil then
                d['state'] = 'None'
            end
            io.write(string.format("%4s ", d['state'])) 
        end
        print() 
        for i = 0, self.cellNum+1, 1 do
            d = self.cells[self:getKey(i, j)]
            if d['gScore'] == nil then
                d['gScore'] = 0
            end
            io.write(string.format("%4d ", d['gScore'])) 
        end
        print()
        for i = 0, self.cellNum+1, 1 do
            d = self.cells[self:getKey(i, j)]
            if d['hScore'] == nil then
                d['hScore'] = 0
            end
            io.write(string.format("%4d ", d['hScore'])) 
        end
        print()

        for i = 0, self.cellNum+1, 1 do
            d = self.cells[self:getKey(i, j)]
            if d['fScore'] == nil then
                d['fScore'] = 0
            end
            io.write(string.format("%4d ", d['fScore'])) 
        end
        print()

        for i = 0, self.cellNum+1, 1 do
            d = self.cells[self:getKey(i, j)]
            if d['parent'] == nil then
                io.write(string.format("%4s ", "Pare"))
            else
                io.write(string.format("%d,%d ", self:getXY(d['parent']))) 
            end
        end
        print()
    end
end
function World:clearWorld()
    if self.startPoint ~= nil then
        self.cells[self:getKey(self.startPoint[1], self.startPoint[2])]['state'] = nil
    end
    if self.endPoint ~= nil then
        self.cells[self:getKey(self.endPoint[1], self.endPoint[2])]['state'] = nil
    end
    --[[
    for k, v in ipairs(self.walls) do
        self.cells[self:getKey(v[1], v[2])]['state'] = nil
    end
    ]]--

    for k, v in ipairs(self.path) do
        self.cells[self:getKey(v[1], v[2])]['state'] = nil
    end
    self.startPoint = nil
    self.endPoint = nil
    --self.walls = {}
    self.path = {}
end


--[[Test Case
MAP = {
0, 0, 0, 0, 0, 0, 0,  
0, 0, 0, 1, 0, 0, 0,  
0, 2, 0, 1, 0, 3, 0,  
0, 0, 0, 1, 0, 0, 0,  
0, 0, 0, 0, 0, 0, 0,  
0, 0, 0, 0, 0, 0, 0,  
0, 0, 0, 0, 0, 0, 0,  
}

world = World.new(7)
world:initCell()
for k, v in ipairs(MAP) do
    if v == 1 then
        world:putWall((k-1)%world.cellNum+1, math.floor((k-1)/world.cellNum)+1)
    elseif v == 2 then
        world:putStart((k-1)%world.cellNum+1, math.floor((k-1)/world.cellNum)+1)
    elseif v == 3 then
        world:putEnd((k-1)%world.cellNum+1, math.floor((k-1)/world.cellNum)+1)
    end
end
world:search()
world:printCell()
]]--

