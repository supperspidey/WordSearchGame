//
//  ViewController.swift
//  Duolingo
//
//  Created by Van Le Nguyen on 3/4/16.
//  Copyright © 2016 Van Le Nguyen. All rights reserved.
//

import UIKit

class ViewController: UIViewController, GameBoardViewDelegate {
    
    @IBOutlet weak var sourceWordLabel: UILabel!
    @IBOutlet weak var gameBoardView: GameBoardView!
    
    private let dataSource = GameBoardDataSource()
    private var currentGameBoard: GameBoard?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.gameBoardView.delegate = self
        
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
        
        for subview in self.gameBoardView.subviews {
            subview.removeFromSuperview()
        }
        
        sourceWordLabel.text = gameBoard.sourceWord
        self.currentGameBoard = gameBoard
        
        guard let grid = gameBoard.characterGrid, gridSize = gameBoard.gridSize else {
            return
        }
        
        for row in grid {
            for character in row {
                let label = UILabel(frame: CGRectZero)
                label.text = character
                self.gameBoardView.addSubview(label)
            }
        }
        
        self.layoutSubviewsInGameBoardView(gridDimension: gridSize)
    }
    
    private func layoutSubviewsInGameBoardView(gridDimension dimension: [UInt]) {
        let superViewDimension = self.gameBoardView.bounds.height
        let space: CGFloat = 1
        var xPos: CGFloat = space
        var yPos: CGFloat = space
        var currentRow: UInt = 0
        let viewDimension: CGFloat = (superViewDimension - CGFloat(dimension[0]+1) * space) / CGFloat(dimension[0])
        for aView in gameBoardView.subviews {
            if aView.isKindOfClass(UILabel) {
                let label = aView as! UILabel
                label.textAlignment = .Center
                guard let coord = gameBoardView.getGridCoordinate(ofSubview: aView) else {
                    continue
                }
                
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
    }
    
    func dimensionOfGrid() -> [UInt]? {
        return self.currentGameBoard?.gridSize
    }
    
    func gameBoardViewDidFinishSelectingCharacters(atCoordinates coords: [GridCoordinate]?) {
        self.gameBoardView.unhighlightAllCharacters()
        
        guard let visitedCoords = coords, gameBoard = self.currentGameBoard else {
            return
        }
        
        if gameBoard.checkAnswer(withCoordinates: visitedCoords) {
            self.loadNextGameBoard()
        } else {
            print("No!")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

