#coding:utf8
MAP = [
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
0, 0, 1, 1, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
0, 0, 0, 2, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 
0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
]
"""
MAP = [
0, 0, 0, 0, 0, 0, 0,  
0, 0, 1, 1, 0, 0, 0,  
0, 2, 0, 1, 0, 3, 0,  
0, 0, 1, 1, 0, 0, 0,  
0, 0, 0, 0, 0, 0, 0,  
0, 0, 0, 0, 0, 0, 0,  
0, 0, 0, 0, 0, 0, 0,  
]
"""



import heapq
import math
class World(object):
    def initBoard(self):
        #self.putStart(*self.startPoint)
        #self.putEnd(*self.endPoint)
        for i in xrange(0, len(MAP)):
            if MAP[i] == 1:
                self.putWall(i%self.cellNum+1, i/self.cellNum+1)
            elif MAP[i] == 2:
                self.putStart(i%self.cellNum+1, i/self.cellNum+1)
            elif MAP[i] == 3:
                self.putEnd(i%self.cellNum+1, i/self.cellNum+1)

    def __init__(self, start, end):
        #public
        self.startPoint = start
        self.endPoint = end

        self.cellSize = 50
        self.cellNum = 20
        #self.startPoint = None
        #self.endPoint = None
        self.initCell()

        #self.initBoard()
        #self.printBoard()
        #self.search()
        #print "result"
        #self.printBoard()
        #self.printClearBoard()


        #private    
    def initCell(self):
        self.cells = {}
        for x in xrange(0, self.cellNum+2):
            for y in xrange(0, self.cellNum+2):
                self.cells[(x, y)] = {'state':'Empt', 
                'fScore':None, 
                'gScore':None,
                'hScore':None,
                'parent':None
                }
        #4周有墙体
        for i in xrange(0, self.cellNum+2):
            self.cells[(0, i)] = {'state':'Wall',
                'fScore':None, 
                'gScore':None,
                'hScore':None,
                'parent':None
            }
            self.cells[(i, 0)] = {'state':'Wall',
                'fScore':None, 
                'gScore':None,
                'hScore':None,
                'parent':None
            }

            self.cells[(self.cellNum+1, i)] = {'state':'Wall',
                'fScore':None, 
                'gScore':None,
                'hScore':None,
                'parent':None
            }
            self.cells[(i, self.cellNum+1)] = {'state':'Wall',
                'fScore':None, 
                'gScore':None,
                'hScore':None,
                'parent':None
            }



    def putStart(self, x, y):
        self.startPoint = (x, y)
        self.cells[self.startPoint]['state'] = 'Start'
    def putEnd(self, x, y):
        self.endPoint = (x, y)
        self.cells[self.endPoint]['state'] = 'End'

    def putWall(self, x, y):
        #print "putWall", x, y
        self.cells[(x, y)]['state'] = 'Wall'

    def calcG(self, x, y):
        data = self.cells[(x, y)]
        parent = self.cells[(x, y)]['parent']
        difx = abs(parent[0]-x)
        dify = abs(parent[1]-y)
        if difx == 1 and dify == 1:
            dist = 14
        else:
            dist = 10
        data['gScore'] = self.cells[parent]['gScore']+dist
    def calcH(self, x, y):
        data = self.cells[(x, y)]
        data['hScore'] = (abs(self.endPoint[0]-x)+abs(self.endPoint[1]-y))*10
    def calcF(self, x, y):
        data = self.cells[(x, y)]
        data['fScore'] = data['gScore']+data['hScore']
        
    def pushQueue(self, x, y):
        fScore = self.cells[(x, y)]['fScore']
        heapq.heappush(self.openList, fScore)
        fDict = self.pqDict.setdefault(fScore, [])
        fDict.append((x, y))
        print "Queue"
        print self.openList
        print self.pqDict
        print self.closedList

    def search(self):
        self.openList = []
        self.pqDict = {}
        self.closedList = {}

        self.cells[(self.startPoint)]['gScore'] = 0
        self.calcH(*self.startPoint)
        self.calcF(*self.startPoint)
        self.pushQueue(*self.startPoint)

        

        find = False
        while len(self.openList) > 0 and not find:
            self.printBoard()
            find = False
            fScore = heapq.heappop(self.openList)
            possible = self.pqDict.get(fScore)
            if len(possible) > 0:
                x, y = possible.pop()
                if (x, y) == self.endPoint:
                    break
                neibors = [
                    (x-1, y-1),
                    (x, y-1),
                    (x+1, y-1),
                    (x+1, y),
                    (x+1, y+1),
                    (x, y+1),
                    (x-1, y+1),
                    (x-1, y)
                ]
                for n in neibors:
                    if self.cells[n]['state'] != 'Wall' and n not in self.closedList:
                            #检测是否已经在 openList 里面了
                            nS = self.cells[n]['fScore']
                            inOpen = False
                            if nS != None:
                                newPossible = self.pqDict.get(nS)
                                if newPossible != None:
                                    if newPossible.count(n) > 0:
                                        print "inOpen"
                                        inOpen = True
                            #已经在开放列表里面 检查是否更新
                            if inOpen:
                                oldParent = self.cells[n]['parent']
                                oldGScore = self.cells[n]['gScore']
                                oldHScore = self.cells[n]['hScore']
                                oldFScore = self.cells[n]['fScore']

                                self.cells[n]['parent'] = (x, y)
                                self.calcG(*n)
                                self.calcH(*n)
                                self.calcF(*n)
                                if self.cells[n]['fScore'] > oldFScore:
                                    print "fScore", self.cells[n]['fScore'], oldFScore
                                    self.cells[n]['parent'] = oldParent
                                    self.cells[n]['gScore'] = oldGScore
                                    self.cells[n]['hScore'] = oldHScore
                                    self.cells[n]['fScore'] = oldFScore
                                else:#删除旧的自己的优先级队列 重新压入优先级队列
                                    oldPossible = self.pqDict[oldFScore]
                                    oldPossible.remove(n)
                                    self.pushQueue(*n)
                                    
                            else:#没在开放列表里面
                                self.cells[n]['parent'] = (x, y)
                                self.calcG(*n)
                                self.calcH(*n)
                                self.calcF(*n)

                                self.pushQueue(*n)
                                #if n == self.endPoint:
                                #    find = True
                                #    break
                self.closedList[(x, y)] = 1

        path = [self.endPoint]
        parent = self.cells[self.endPoint]['parent']
        while parent != None:
            path.append(parent)
            if parent == self.startPoint:
                break
            self.cells[parent]['state'] = 'Path'
            parent = self.cells[parent]["parent"]

        print "path"
        print path
        print len(path)
        return path

    def clearWorld(self):
        pass
    def clearPath(self):
        pass
    
    def printBoard(self):
        print "cur Board"
        for j in xrange(0, self.cellNum+2):
            for i in xrange(0, self.cellNum+2):
                d = self.cells[(i, j)]
                print "%4s"%d['state'], 
            print 
            for i in xrange(0, self.cellNum+2):
                d = self.cells[(i, j)]
                print "%4s"%str(d['gScore']), 
            print
            for i in xrange(0, self.cellNum+2):
                d = self.cells[(i, j)]
                print "%4s"%str(d['hScore']), 
            print

            for i in xrange(0, self.cellNum+2):
                d = self.cells[(i, j)]
                print "%4s"%str(d['fScore']), 
            print

            for i in xrange(0, self.cellNum+2):
                d = self.cells[(i, j)]
                print "%4s"%str(d['parent']), 
            print
    def printClearBoard(self):
        print "clear Board"
        for j in xrange(0, self.cellNum+2):
            for i in xrange(0, self.cellNum+2):
                d = self.cells[(i, j)]
                if d['state'] == 'Empt':
                    print 'None',
                else:
                    print d['state'], 
            print 
        







def main():
    testCase = [
    [1, 5], [8, 5],
    [1, 5], [9, 5],
    [1, 5], [10, 5],
    [1, 5], [15, 5],
    ]
    for i in xrange(0, 1):
        start = testCase[i]
        end = testCase[i+1]
        print "testCase", i/2, start, end 
        w = World(start, end)
if __name__ == "__main__":
    main()

