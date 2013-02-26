#coding:utf8
import pygame
import sys
from pygame.locals import *
import myPath

cellSize = 40
cellNum = 20

gray = (128, 128, 128)
black = (0, 0, 0)
green = (0, 204, 102)
red = (255, 44, 0)
orange = (255, 175, 0)


def blitBoard(screen, board):
    screen.blit(board, (0, 0))
    #pygame.display.flip()

def initGame():
    pygame.init()
def showBoard(world):
    size = cellSize*(cellNum+2)+2, cellSize*(cellNum+2)+2
    screen = pygame.display.set_mode(size)
    background = initBoard(screen)
    #blitBoard(screen, background)

    for j in xrange(0, w.cellNum+2):
        for i in xrange(0, w.cellNum+2):
            d = w.cells[(i, j)]
            left = i*cellSize
            top = j*cellSize
            #print left, top
            if d['state'] == 'Start':
                pygame.draw.rect(background, green, pygame.Rect(left, top, cellSize, cellSize), 0)
            elif d['state'] == 'End':
                pygame.draw.rect(background, red, pygame.Rect(left, top, cellSize, cellSize), 0)
            elif d['state'] == 'Path':
                pygame.draw.rect(background, orange, pygame.Rect(left, top, cellSize, cellSize), 0)
            elif d['state'] == 'Wall':
                pygame.draw.rect(background, black, pygame.Rect(left, top, cellSize, cellSize), 0)
    screen.blit(background, (0, 0))
    pygame.display.flip()

                

def initBoard(board):
    background = pygame.Surface(board.get_size())
    background = background.convert()
    background.fill(gray)
    for i in xrange(0, cellNum+2+1):
        pygame.draw.line(background, black, (i*cellSize, 0), (i*cellSize, (cellNum+2)*cellSize), 2)
        pygame.draw.line(background, black, (0, i*cellSize), ((cellNum+2)*cellSize, i*cellSize), 2)
    return background

initGame()

#w = myPath.World(None, None)
tempStart = None
tempEnd = None
beginDraw = False
w = myPath.World(None, None)
while True:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            sys.exit()
        key = pygame.key.get_pressed()
        leftClicked, middleClicked, rightClicked = pygame.mouse.get_pressed()
        ctrl = key[pygame.K_LCTRL] or key[pygame.K_RCTRL]
        shift = key[pygame.K_LSHIFT] or key[pygame.K_RSHIFT]
        enter = key[pygame.K_RETURN]
        x, y = pygame.mouse.get_pos()

        xIndex = x/cellSize
        yIndex = y/cellSize

        if (xIndex, yIndex) in w.cells:
            if ctrl and leftClicked and tempStart == None:
                tempStart = (xIndex, yIndex)
                w.putStart(xIndex, yIndex)
            elif ctrl and rightClicked and tempEnd == None:
                tempEnd = (xIndex, yIndex)
                w.putEnd(xIndex, yIndex)
            elif shift and leftClicked and not beginDraw:
                w.putWall(xIndex, yIndex)
            elif enter and tempStart and tempEnd and not beginDraw:
                beginDraw = True
                w.search()

    showBoard(w)
