//
//  ViewController.swift
//  Duolingo
//
//  Created by Van Le Nguyen on 3/4/16.
//  Copyright © 2016 Van Le Nguyen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var sourceWordLabel: UILabel!
    @IBOutlet weak var gameBoardView: GameBoardView!
    
    private let dataSource = GameBoardDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        dataSource.fetchGameBoardData { [weak self] () -> Void in
            if let strongSelf = self {
                strongSelf.loadNextGameBoard()
            }
        }
    }
    
    private func loadNextGameBoard() -> Void {
        guard let gameBoard = dataSource.revealNextGame() else {
            return
        }
        
        sourceWordLabel.text = gameBoard.sourceWord
        
        guard let grid = gameBoard.characterGrid else {
            return
        }
        
        for row in grid {
            for character in row {
                let label = UILabel(frame: CGRectZero)
                label.text = character
                self.gameBoardView.addSubview(label)
            }
        }
        
        let gridSize: UInt = UInt(grid.count)
        self.layoutSubviewsInGameBoardView(gridDimension: [gridSize, gridSize])
    }
    
    private func layoutSubviewsInGameBoardView(gridDimension dimension: [UInt]) {
        let superViewDimension = self.gameBoardView.bounds.height
        let space: CGFloat = 1
        var xPos: CGFloat = space
        var yPos: CGFloat = space
        var currentRow: UInt = 0
        let viewDimension: CGFloat = (superViewDimension - CGFloat(dimension[0]+1) * space) / CGFloat(dimension[0])
        for (index, aView) in gameBoardView.subviews.enumerate() {
            if aView.isKindOfClass(UILabel) {
                let label = aView as! UILabel
                label.textAlignment = .Center
            }
            
            let coord = self.convert(index: UInt(index), toCoordinateInGridWithDimension: dimension)
            if coord.row == currentRow {
                aView.frame = CGRectMake(xPos, yPos, viewDimension, viewDimension)
                xPos += (viewDimension + space)
            } else {
                currentRow++
                xPos = space
                yPos += (viewDimension + space)
                aView.frame = CGRectMake(xPos, yPos, viewDimension, viewDimension)
                xPos += (viewDimension + space)
            }
        }
    }
    
    private func convert(index index: UInt, toCoordinateInGridWithDimension dimension: [UInt]) -> GridCoordinate {
        return GridCoordinate(row: index / dimension[0], col: index % dimension[1])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

