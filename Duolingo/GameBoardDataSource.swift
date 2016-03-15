//
//  GameBoardDataSource.swift
//  Duolingo
//
//  Created by Van Le Nguyen on 3/4/16.
//  Copyright © 2016 Van Le Nguyen. All rights reserved.
//

import UIKit

class GameBoardDataSource: GameBoardViewDataSource {
    private var gameBoardsQueue: Queue<GameBoard>?
    private(set) var currentGameBoard: GameBoard?
    private var url: NSURL?
    private var dataFromInternet: Bool?
    
    init?(withURL url: NSURL?, isFromInternet fromInternet: Bool) {
        guard let theURL = url else {
            return nil
        }
        
        self.dataFromInternet = fromInternet
        self.url = theURL
        self.gameBoardsQueue = Queue<GameBoard>()
    }
    
    func fetchGameBoardData (completionHandler: (() -> Void)?) {
        guard let fromInternet = dataFromInternet else {
            return
        }
        
        if (fromInternet) {
            self.loadDataFromInternet(completionHandler)
        } else {
            self.loadDataFromBundle(completionHandler)
        }
    }
    
    private func loadDataFromInternet(completionHandler: (() -> Void)?) {
        guard let theURL = url else {
            return
        }
        
        let urlRequest = NSURLRequest(URL: theURL)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(urlRequest) {
            [weak self] (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            if error == nil {
                guard let theData = data, strongSelf = self else {
                    return
                }
                
                strongSelf.deserializeThenQueueUp(withData: theData)
                
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
    
    private func loadDataFromBundle(completionHandler: (() -> Void)?) {
        guard let theURL = url,
            data = NSData(contentsOfURL: theURL) else {
            return
        }
        
        self.deserializeThenQueueUp(withData: data)
        
        guard let handler = completionHandler else {
            return
        }
        
        handler()
    }
    
    private func deserializeThenQueueUp(withData data: NSData) {
        guard let result = NSString(data: data, encoding: NSUTF8StringEncoding) else {
            return
        }
        
        let results = result.componentsSeparatedByString("\n")
        for jsonString in results {
            guard let gameData = jsonString.dataUsingEncoding(NSUTF8StringEncoding) else {
                continue
            }
            
            do {
                guard let dict = try NSJSONSerialization.JSONObjectWithData(gameData, options: .AllowFragments) as? NSDictionary else {
                    continue
                }
                
                guard let source = dict[JSONKeys.Word] as? String,
                    grid = dict[JSONKeys.CharacterGrid] as? [[String]],
                    locations = dict[JSONKeys.WordLocations]?.allKeys as? [String] else {
                        continue
                }
                
                guard let gameBoard = GameBoard(withSourceWord: source, characterGrid: grid, answerLocations: locations) else {
                    continue
                }
                
                self.gameBoardsQueue?.enqueue(gameBoard)
            } catch {
                continue
            }
        }
    }
    
    func revealNextGame() -> Void {
        self.currentGameBoard = gameBoardsQueue?.dequeue()
    }
    
    // MARK: GameBoardView's data source method
    
    func dimensionOfGrid() -> UInt? {
        return self.currentGameBoard?.gridSize
    }
    
}
