//
//  GameBoard.swift
//  Duolingo
//
//  Created by Van Le Nguyen on 3/4/16.
//  Copyright © 2016 Van Le Nguyen. All rights reserved.
//

import UIKit

class GameBoard: NSObject {
    private(set) var sourceWord: String?
    private(set) var characterGrid: [[String]]?
    
    init?(withSourceWord source: String?, characterGrid: [[String]]?) {
        super.init()
        
        guard let theSource = source, theCharacterGrid = characterGrid else {
            return nil
        }
        
        self.sourceWord = theSource
        self.characterGrid = theCharacterGrid
    }
}
