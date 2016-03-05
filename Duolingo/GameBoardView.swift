//
//  GameBoardView.swift
//  Duolingo
//
//  Created by Van Le Nguyen on 3/4/16.
//  Copyright © 2016 Van Le Nguyen. All rights reserved.
//

import UIKit

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
                
                if coord.row == initialCoord.row {
                    view.backgroundColor = selectedColor
                } else if coord.col == initialCoord.col {
                    view.backgroundColor = selectedColor
                } else if abs(Int(coord.row) - Int(initialCoord.row)) == abs(Int(coord.col) - Int(initialCoord.col)) {
                    view.backgroundColor = selectedColor
                }
            }
        } else if panGesture.state == .Ended {
            self.delegate?.gameBoardViewDidFinishSelectingCharacters()
        }
    }
    
    func deselectAllCharacters() {
        for view in self.subviews {
            view.backgroundColor = unselectedColor
        }
    }
    
    func getGridCoordinate(ofSubview view: UIView?) -> GridCoordinate? {
        guard let theView = view else {
            return nil
        }
        
        guard let index = self.subviews.indexOf(theView) else {
            return nil
        }
        
        guard let theDelegate = delegate else {
            return nil
        }
        
        guard let gridDimension = theDelegate.dimensionOfGrid() else {
            return nil
        }
        
        return self.convert(index: UInt(index), toCoordinateInGridWithDimension: gridDimension)
    }
    
    private func convert(index index: UInt, toCoordinateInGridWithDimension dimension: [UInt]) -> GridCoordinate {
        return GridCoordinate(row: index / dimension[0], col: index % dimension[1])
    }
    
    override func didAddSubview(subview: UIView) {
        subview.userInteractionEnabled = true
        subview.backgroundColor = unselectedColor
    }
}
