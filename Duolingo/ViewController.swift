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
    
    func loadNextGameBoard() -> Void {
        guard let gameBoard = dataSource.revealNextGame() else {
            return
        }
        
        sourceWordLabel.text = gameBoard.sourceWord
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

