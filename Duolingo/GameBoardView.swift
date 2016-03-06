//
//  GameBoardView.swift
//  Duolingo
//
//  Created by Van Le Nguyen on 3/4/16.
//  Copyright © 2016 Van Le Nguyen. All rights reserved.
//

import UIKit
import Foundation

struct GridCoordinate {
    let row: UInt
    let col: UInt
}

protocol GameBoardViewDelegate: class {
    func dimensionOfGrid() -> [UInt]?
    func gameBoardViewDidFinishSelectingCharacters() -> Void
}

class GameBoardView: UIView {
    
    private var selectedColor: UIColor
    private var unselectedColor: UIColor
    private var initialGridCoordinate: GridCoordinate?
    
    weak var delegate: GameBoardViewDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        self.selectedColor = UIColor.grayColor()
        self.unselectedColor = UIColor.whiteColor()
        
        super.init(coder: aDecoder)
    }
    
    @IBAction func handlePanGesture(panGesture: UIPanGestureRecognizer) {
        if panGesture.state == .Began {
            // Get the pivot coordinate
            guard let view = self.hitTest(panGesture.locationInView(self), withEvent: nil) else {
                return
            }

            if view.isKindOfClass(UILabel) {
                initialGridCoordinate = self.getGridCoordinate(ofSubview: view)
            }
        } else if panGesture.state == .Changed {
            guard let view = self.hitTest(panGesture.locationInView(self), withEvent: nil) else {
                return
            }
            
            if view.isKindOfClass(UILabel) {
                guard let coord = self.getGridCoordinate(ofSubview: view) else {
                    return
                }
                
                guard let initialCoord = self.initialGridCoordinate else {
                    return
                }
                
                self.highlightPath(initialCoordinate: initialCoord, finalCoordinate: coord)
            }
        } else if panGesture.state == .Ended {
            self.delegate?.gameBoardViewDidFinishSelectingCharacters()
        }
    }
    
    func unhighlightAllCharacters() {
        for view in self.subviews {
            view.backgroundColor = unselectedColor
        }
    }
    
    private func highlightPath(initialCoordinate initialCoord: GridCoordinate, finalCoordinate finalCoord: GridCoordinate) {
        // TODO: optimize this part. Save the path to an array, and only deselect views that are not in the path
        self.unhighlightAllCharacters()
        
        if finalCoord.row == initialCoord.row {
            var step = 0
            if Int(finalCoord.col) - Int(initialCoord.col) > 0 {
                step = 1
            } else {
                step = -1
            }
            
            for col in initialCoord.col.stride(through: finalCoord.col, by: step) {
                self.highlightCharacter(atCoordinate: GridCoordinate(row: initialCoord.row, col: col))
            }
        } else if finalCoord.col == initialCoord.col {
            var step = 0
            if Int(finalCoord.row) - Int(initialCoord.row) > 0 {
                step = 1
            } else {
                step = -1
            }
            
            for row in initialCoord.row.stride(through: finalCoord.row, by: step) {
                self.highlightCharacter(atCoordinate: GridCoordinate(row: row, col: initialCoord.col))
            }
        } else if abs(Int(finalCoord.row) - Int(initialCoord.row)) == abs(Int(finalCoord.col) - Int(initialCoord.col)) {
            var rowStep: Int = 0
            var colStep: Int = 0
            if Int(finalCoord.row) - Int(initialCoord.row) > 0 {
                rowStep = 1
            } else {
                rowStep = -1
            }
            
            if Int(finalCoord.col) - Int(initialCoord.col) > 0 {
                colStep = 1
            } else {
                colStep = -1
            }
            
            var row: UInt = initialCoord.row
            var col: UInt = initialCoord.col
            while row != finalCoord.row && col != finalCoord.col {
                self.highlightCharacter(atCoordinate: GridCoordinate(row: row, col: col))
                row = UInt(Int(row) + rowStep)
                col = UInt(Int(col) + colStep)
                
                if row == finalCoord.row && col == finalCoord.col {
                    self.highlightCharacter(atCoordinate: GridCoordinate(row: row, col: col))
                }
            }
        } else {
            return
        }
    }
    
    func getGridCoordinate(ofSubview view: UIView?) -> GridCoordinate? {
        guard let theView = view else {
            return nil
        }
        
        guard let index = self.subviews.indexOf(theView) else {
            return nil
        }
        
        guard let gridDimension = delegate?.dimensionOfGrid() else {
            return nil
        }
        
        return self.convert(index: UInt(index), toCoordinateInGridWithDimension: gridDimension)
    }
    
    private func convert(index index: UInt, toCoordinateInGridWithDimension dimension: [UInt]) -> GridCoordinate {
        return GridCoordinate(row: index / dimension[0], col: index % dimension[1])
    }
    
    private func viewAtGridCoordinate(coordinate coord: GridCoordinate) -> UIView? {
        guard let gridDimension = self.delegate?.dimensionOfGrid() else {
            return nil
        }
        
        let index = Int(coord.row * gridDimension[0] + coord.col)
        return self.subviews[index]
    }
    
    private func highlightCharacter(atCoordinate coord: GridCoordinate) {
        let view = self.viewAtGridCoordinate(coordinate: coord)
        view?.backgroundColor = self.selectedColor
    }
    
    override func didAddSubview(subview: UIView) {
        subview.userInteractionEnabled = true
        subview.backgroundColor = unselectedColor
    }
}
