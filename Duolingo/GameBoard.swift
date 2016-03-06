//
//  GameBoard.swift
//  Duolingo
//
//  Created by Van Le Nguyen on 3/4/16.
//  Copyright © 2016 Van Le Nguyen. All rights reserved.
//

import UIKit

class GameBoard {
    private(set) var sourceWord: String?
    private(set) var characterGrid: [[String]]?
    private(set) var gridSize: [UInt]?
    private(set) var answerLocations: [[GridCoordinate]]?
    
    init?(withSourceWord source: String?, characterGrid: [[String]]?, answerLocations: [[GridCoordinate]]?) {
        guard let theSource = source, theCharacterGrid = characterGrid else {
            return nil
        }
        
        self.sourceWord = theSource
        self.characterGrid = theCharacterGrid
        self.gridSize = [UInt(theCharacterGrid.count), UInt(theCharacterGrid.count)]
        self.answerLocations = answerLocations
    }
    
    func checkAnswer(withCoordinates coords: [GridCoordinate]?) -> Bool {
        guard let theCoords = coords, correctCoordsSet = self.answerLocations else {
            return false
        }
        
        var potentialCorrectIndex = 0
        for (index, correctCoords) in correctCoordsSet.enumerate() {
            if theCoords.count == correctCoords.count {
                potentialCorrectIndex = index
                break
            }
        }
        
        for (index, coord) in theCoords.enumerate() {
            let correctCoord = correctCoordsSet[potentialCorrectIndex][index]
            if coord.col != correctCoord.col || coord.row != correctCoord.row {
                return false
            }
        }
        
        return true
    }
}
