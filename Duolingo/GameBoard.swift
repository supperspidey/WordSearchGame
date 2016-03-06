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
    private(set) var answerLocations: [String]?
    private var checkList: [String: Bool]?
    
    init?(withSourceWord source: String?, characterGrid: [[String]]?, answerLocations: [String]?) {
        guard let theSource = source, theCharacterGrid = characterGrid, locations = answerLocations else {
            return nil
        }
        
        self.sourceWord = theSource
        self.characterGrid = theCharacterGrid
        self.gridSize = [UInt(theCharacterGrid.count), UInt(theCharacterGrid.count)]
        self.answerLocations = locations
        self.checkList = [String: Bool]()
    }
    
    func checkAnswer(withCoordinates coords: String?) -> Bool {
        guard let theCoords = coords, correctCoordsSet = self.answerLocations else {
            return false
        }
        
        for locations in correctCoordsSet {
            if theCoords == locations {
                self.checkList?[theCoords] = true
                return true
            }
        }
        
        return false
    }
    
    func isEvaluated(withCoordinates coords: String?) -> Bool? {
        guard let theCoords = coords, theCheckList = checkList else {
            return nil
        }
        
        guard let _ = theCheckList[theCoords] else {
            return false
        }
        
        return true
    }
    
    func isFinished() -> Bool {
        return self.answerLocations?.count == self.checkList?.count
    }
}
