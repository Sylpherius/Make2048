//
//  Grid.swift
//  Make2048
//
//  Created by Alan on 6/29/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation

class Grid: CCNodeColor {
    let gridSize = 4
    let startTiles = 2
    
    var gridArray = [[Tile?]]()
    var noTile: Tile? = nil
    var columnWidth: CGFloat = 0
    var columnHeight: CGFloat = 0
    var tileMarginVertical: CGFloat = 0
    var tileMarginHorizontal: CGFloat = 0
    
    func indexValid(x: Int, y: Int) -> Bool {
        var indexValid = true
        indexValid = (x >= 0) && (y >= 0)
        if indexValid {
            indexValid = x < Int(gridArray.count)
            if indexValid {
                indexValid = y < Int(gridArray[x].count)
            }
        }
        return indexValid
    }
    func moveTile(tile: Tile, fromX: Int, fromY: Int, toX: Int, toY: Int) {
        gridArray[toX][toY] = gridArray[fromX][fromY]
        gridArray[fromX][fromY] = noTile
        var newPosition = positionForColumn(toX, row: toY)
        var moveTo = CCActionMoveTo(duration: 0.2, position: newPosition)
        tile.runAction(moveTo)
    }
    func move(direction: CGPoint) {
        // apply negative vector until reaching boundary, this way we get the tile that is the furthest away
        // bottom left corner
        var currentX = 0
        var currentY = 0
        // Move to relevant edge by applying direction until reaching border
        while indexValid(currentX, y: currentY) {
            var newX = currentX + Int(direction.x)
            var newY = currentY + Int(direction.y)
            if indexValid(newX, y: newY) {
                currentX = newX
                currentY = newY
            } else {
                break
            }
        }
        // store initial row value to reset after completing each column
        var initialY = currentY
        // define changing of x and y value (moving left, up, down or right?)
        var xChange = Int(-direction.x)
        var yChange = Int(-direction.y)
        if xChange == 0 {
            xChange = 1
        }
        if yChange == 0 {
            yChange = 1
        }
        // visit column for column
        while indexValid(currentX, y: currentY) {
            while indexValid(currentX, y: currentY) {
                // get tile at current index
                if let tile = gridArray[currentX][currentY] {
                    // if tile exists at index
                    var newX = currentX
                    var newY = currentY
                    // find the farthest position by iterating in direction of the vector until reaching boarding of
                    // grid or occupied cell
                    while indexValid(newX+Int(direction.x), y: newY+Int(direction.y)) {
                        newX += Int(direction.x)
                        newY += Int(direction.y)
                    }
                    if newX != currentX || newY != currentY {
                        moveTile(tile, fromX: currentX, fromY: currentY, toX: newX, toY: newY)
                    }
                }
                // move further in this column
                currentY += yChange
            }
            currentX += xChange
            currentY = initialY
        }
    }
    func swipeLeft() {
        move(CGPoint(x: -1, y: 0))
    }
    
    func swipeRight() {
        move(CGPoint(x: 1, y: 0))
    }
    
    func swipeUp() {
        move(CGPoint(x: 0, y: 1))
    }
    
    func swipeDown() {
        move(CGPoint(x: 0, y: -1))
    }
    func setupGestures() {
        var swipeLeft = UISwipeGestureRecognizer(target: self, action: "swipeLeft")
        swipeLeft.direction = .Left
        CCDirector.sharedDirector().view.addGestureRecognizer(swipeLeft)
        
        var swipeRight = UISwipeGestureRecognizer(target: self, action: "swipeRight")
        swipeRight.direction = .Right
        CCDirector.sharedDirector().view.addGestureRecognizer(swipeRight)
        
        var swipeUp = UISwipeGestureRecognizer(target: self, action: "swipeUp")
        swipeUp.direction = .Up
        CCDirector.sharedDirector().view.addGestureRecognizer(swipeUp)
        
        var swipeDown = UISwipeGestureRecognizer(target: self, action: "swipeDown")
        swipeDown.direction = .Down
        CCDirector.sharedDirector().view.addGestureRecognizer(swipeDown)
    }
    func spawnRandomTile() {
        var spawned = false
        while !spawned {
            let randomRow = Int(CCRANDOM_0_1() * Float(gridSize))
            let randomColumn = Int(CCRANDOM_0_1() * Float(gridSize))
            let positionFree = gridArray[randomColumn][randomRow] == noTile
            if positionFree {
                addTileAtColumn(randomColumn, row: randomRow)
                spawned = true
            }
        }
    }
    func spawnStartTiles() {
        for i in 0..<startTiles {
            spawnRandomTile()
        }
    }
    func addTileAtColumn(column: Int, row: Int) {
        var tile = CCBReader.load("Tile") as! Tile
        gridArray[column][row] = tile
        tile.scale = 0
        addChild(tile)
        tile.position = positionForColumn(column, row: row)
        var delay = CCActionDelay(duration: 0.3)
        var scaleUp = CCActionScaleTo(duration: 0.2, scale: 1)
        var sequence = CCActionSequence(array: [delay, scaleUp])
        tile.runAction(sequence)
    }
    func positionForColumn(column: Int, row: Int) -> CGPoint {
        var x = tileMarginHorizontal + CGFloat(column) * (tileMarginHorizontal + columnWidth)
        var y = tileMarginVertical + CGFloat(row) * (tileMarginVertical + columnHeight)
        return CGPoint(x: x, y: y)
    }
    func setupBackground() {
        var tile = CCBReader.load("Tile") as! Tile
        columnWidth = tile.contentSize.width
        columnHeight = tile.contentSize.height
        
        tileMarginHorizontal = (contentSize.width - (CGFloat(gridSize) * columnWidth)) / CGFloat(gridSize + 1)
        tileMarginVertical = (contentSize.height - (CGFloat(gridSize) * columnHeight)) / CGFloat(gridSize + 1)
        
        var x = tileMarginHorizontal
        var y = tileMarginVertical
        
        for i in 0..<gridSize {
            x = tileMarginHorizontal
            for j in 0..<gridSize {
                var backgroundTile = CCNodeColor.nodeWithColor(CCColor.grayColor())
                backgroundTile.contentSize = CGSize(width: columnWidth, height: columnHeight)
                backgroundTile.position = CGPoint(x: x, y: y)
                addChild(backgroundTile)
                x += columnWidth + tileMarginHorizontal
            }
            y += columnHeight + tileMarginVertical
        }
    }
    func didLoadFromCCB() {
        setupBackground()
        for i in 0..<gridSize {
            var column = [Tile?]()
            for j in 0..<gridSize {
                column.append(noTile)
            }
            gridArray.append(column)
        }
        
        spawnStartTiles()
        setupGestures()
    }
}