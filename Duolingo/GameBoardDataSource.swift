//
//  GameBoardDataSource.swift
//  Duolingo
//
//  Created by Van Le Nguyen on 3/4/16.
//  Copyright © 2016 Van Le Nguyen. All rights reserved.
//

import UIKit

class GameBoardDataSource: NSObject {
    private var gameBoardsQueue: Queue<GameBoard>
    
    override init() {
        self.gameBoardsQueue = Queue<GameBoard>()
        
        super.init()
    }
    
    func fetchGameBoardData (completionHandler: (() -> Void)?) {
        guard let url = NSURL(string: "https://s3.amazonaws.com/duolingo-data/s3/js2/find_challenges.txt") else {
            return
        }
        
        let urlRequest = NSURLRequest(URL: url)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(urlRequest) {
            [weak self] (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            if error == nil {
                guard let theData = data else {
                    return
                }
                
                guard let result = NSString(data: theData, encoding: NSUTF8StringEncoding) else {
                    return
                }
                
                let results = result.componentsSeparatedByString("\n")
                for jsonString in results {
                    guard let gameData = jsonString.dataUsingEncoding(NSUTF8StringEncoding) else {
                        print("failure!")
                        continue
                    }
                    
                    do {
                        let json = try NSJSONSerialization.JSONObjectWithData(gameData, options: .AllowFragments) as? NSDictionary
                        
                        guard let dict = json else {
                            continue
                        }
                        
                        if let strongSelf = self {
                            guard let source = dict["word"] as? String, grid = dict["character_grid"] as? [[String]] else {
                                continue
                            }
                            
                            guard let gameBoard = GameBoard(withSourceWord: source, characterGrid: grid) else {
                                continue
                            }
                            
                            strongSelf.gameBoardsQueue.enqueue(gameBoard)
                        }
                    } catch {
                        continue
                    }
                }
                
                guard let handler = completionHandler else {
                    return
                }
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    handler()
                })
            }
        }
        task.resume()
    }
    
    func revealNextGame() -> GameBoard? {
        return gameBoardsQueue.dequeue()
    }
}
