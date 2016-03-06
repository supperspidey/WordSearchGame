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
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    private let dataSource = GameBoardDataSource()
    private var currentGameBoard: GameBoard?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.gameBoardView.delegate = self
        
        self.activityIndicatorView.startAnimating()
        dataSource.fetchGameBoardData { [weak self] () -> Void in
            if let strongSelf = self {
                strongSelf.loadNextGameBoard()
                strongSelf.activityIndicatorView.stopAnimating()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        coordinator.animateAlongsideTransition({ (context: UIViewControllerTransitionCoordinatorContext) -> Void in
            guard let gridSize = self.currentGameBoard?.gridSize else {
                return
            }
            
            self.layoutSubviewsInGameBoardView(gridDimension: gridSize)
            }, completion: nil)
    }
    
    private func loadNextGameBoard() -> Void {
        guard let gameBoard = dataSource.revealNextGame() else {
            self.navigationController?.popViewControllerAnimated(true)
            return
        }
        
        self.gameBoardView.clearView()
        
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
        guard let visitedCoords = coords, gameBoard = self.currentGameBoard else {
            return
        }
        
        let coordsStr = self.generateString(fromCoordinates: visitedCoords)
        
        guard let evaluated = gameBoard.isEvaluated(withCoordinates: coordsStr) else {
            return
        }
        
        if evaluated {
            return
        } else {
            if gameBoard.checkAnswer(withCoordinates: coordsStr) {
                let realCoords = self.generateGridCoordinates(fromString: coordsStr)
                if gameBoard.isFinished() {
                    self.loadNextGameBoard()
                } else {
                    self.gameBoardView.remember(correctPath: realCoords)
                }
            } else {
                self.gameBoardView.unhighlightSelectedCharacters()
            }
        }
    }
    
    private func generateString(fromCoordinates coords: [GridCoordinate]) -> String {
        var string = ""
        for (i, coord) in coords.enumerate() {
            if i < coords.count - 1 {
                string += (String(coord.col) + "," + String(coord.row) + ",")
            } else {
                string += (String(coord.col) + "," + String(coord.row))
            }
        }
        
        return string
    }
    
    private func generateGridCoordinates(fromString coordsStr: String) -> [GridCoordinate] {
        let array = coordsStr.componentsSeparatedByString(",")
        var coords = [GridCoordinate]()
        for i in 0.stride(through: array.count-1, by: 2) {
            guard let row = UInt(array[i+1]), col = UInt(array[i]) else {
                continue
            }
            coords.append(GridCoordinate(row: row, col: col))
        }
        return coords
    }

}

