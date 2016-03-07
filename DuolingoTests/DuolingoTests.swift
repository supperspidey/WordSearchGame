//
//  DuolingoTests.swift
//  DuolingoTests
//
//  Created by Van Le Nguyen on 3/4/16.
//  Copyright © 2016 Van Le Nguyen. All rights reserved.
//

import XCTest
@testable import Duolingo

class DuolingoTests: XCTestCase {
    
    private var testBundle: NSBundle = NSBundle(forClass: DuolingoTests.self)
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
    }
    
    func testGameBoardWithoutSourceWord() {
        let gameBoard = GameBoard(withSourceWord: nil, characterGrid: [["Blah"]], answerLocations: ["1,2,3,4"])
        XCTAssertNil(gameBoard, "Test Failed: gameBoard without sourceWord should have been invalid.")
    }
    
    func testGameBoardWithoutGrid() {
        let gameBoard = GameBoard(withSourceWord: "blah", characterGrid: nil, answerLocations: ["1,2,3,4"])
        XCTAssertNil(gameBoard, "Test Failed: gameBoard without characterGrid should have been invalid.")
    }
    
    func testGameBoardWithoutAnswerLocations() {
        let gameBoard = GameBoard(withSourceWord: "blah", characterGrid: [["Blah"]], answerLocations: nil)
        XCTAssertNil(gameBoard, "Test Failed: gameBoard without answerLocations should have been invalid.")
    }
    
    func testGameBoardWithoutAnything() {
        let gameBoard = GameBoard(withSourceWord: nil, characterGrid: nil, answerLocations: nil)
        XCTAssertNil(gameBoard, "Test Failed: gameBoard without anything should have been invalid.")
    }
    
    func testGameBoardCheckingAnswerNil() {
        let gameBoard = GameBoard(
            withSourceWord: nil,
            characterGrid: nil,
            answerLocations: nil
        )
        
        let isCorrect = gameBoard?.checkAnswer(withCoordinates: ";klasdf,asdfo;asjdf;lajd;flk ;lasfdklw ")
        XCTAssertNil(isCorrect, "Test Failed: calling checkAnswer on a nil game board should have been invalid.")
    }
    
    func testGameBoardCheckingAnswerTrue() {
        guard let jsonObj = self.getJSONGraph(fromFileName: "Test1", ofType: "json") as? NSDictionary else {
            return
        }
        
        guard let source = jsonObj[JSONKeys.Word] as? String,
            grid = jsonObj[JSONKeys.CharacterGrid] as? [[String]],
            locations = jsonObj[JSONKeys.WordLocations]?.allKeys as? [String] else {
            return
        }
        
        guard let gameBoard = GameBoard(
            withSourceWord: source,
            characterGrid: grid,
            answerLocations: locations
            ) else {
            return
        }
        
        guard let isCorrect = gameBoard.checkAnswer(withCoordinates: "6,1,6,2,6,3,6,4,6,5,6,6") else {
            return
        }
        XCTAssertTrue(isCorrect, "Test Failed: correct path should have been checked as `true`.")
    }
    
    func testGameBoardCheckingAnswerFalse() {
        guard let jsonObj = self.getJSONGraph(fromFileName: "Test1", ofType: "json") as? NSDictionary else {
            return
        }
        
        guard let source = jsonObj[JSONKeys.Word] as? String,
            grid = jsonObj[JSONKeys.CharacterGrid] as? [[String]],
            locations = jsonObj[JSONKeys.WordLocations]?.allKeys as? [String] else {
                return
        }
        
        guard let gameBoard = GameBoard(
            withSourceWord: source,
            characterGrid: grid,
            answerLocations: locations
            ) else {
                return
        }
        
        guard let isCorrect = gameBoard.checkAnswer(withCoordinates: ";laksdfa;lksdf,asfl,asdf,mawelfw;of") else {
            return
        }
        XCTAssertFalse(isCorrect, "Test Failed: random string should have been checked as `false`.")
    }
    
    func testGameBoardEvaluationNil() {
        guard let jsonObj = self.getJSONGraph(fromFileName: "Test1", ofType: "json") as? NSDictionary else {
            return
        }
        
        guard let source = jsonObj[JSONKeys.Word] as? String,
            grid = jsonObj[JSONKeys.CharacterGrid] as? [[String]],
            locations = jsonObj[JSONKeys.WordLocations]?.allKeys as? [String] else {
                return
        }
        
        guard let gameBoard = GameBoard(
            withSourceWord: source,
            characterGrid: grid,
            answerLocations: locations
            ) else {
                return
        }
        
        let evaluated = gameBoard.isEvaluated(withCoordinates: nil)
        XCTAssertNil(evaluated, "Test Failed: isEvaluated method should have returned nil with nil path.")
    }
    
    func testGameBoardEvaluation() {
        let path = "6,1,6,2,6,3,6,4,6,5,6,6"
        guard let jsonObj = self.getJSONGraph(fromFileName: "Test1", ofType: "json") as? NSDictionary else {
            return
        }
        
        guard let source = jsonObj[JSONKeys.Word] as? String,
            grid = jsonObj[JSONKeys.CharacterGrid] as? [[String]],
            locations = jsonObj[JSONKeys.WordLocations]?.allKeys as? [String] else {
                return
        }
        
        guard let gameBoard = GameBoard(
            withSourceWord: source,
            characterGrid: grid,
            answerLocations: locations
            ) else {
                return
        }
        
        gameBoard.checkAnswer(withCoordinates: path)
        guard let evaluated = gameBoard.isEvaluated(withCoordinates: path) else {
            return
        }
        XCTAssertTrue(evaluated, "Test Failed: isEvaluated method should have returned `true` with correct path.")
    }
    
    func testGameBoardFinishedTrue() {
        guard let jsonObj = self.getJSONGraph(fromFileName: "Test2", ofType: "json") as? NSDictionary else {
            return
        }
        
        guard let source = jsonObj[JSONKeys.Word] as? String,
            grid = jsonObj[JSONKeys.CharacterGrid] as? [[String]],
            locations = jsonObj[JSONKeys.WordLocations]?.allKeys as? [String] else {
                return
        }
        
        guard let gameBoard = GameBoard(
            withSourceWord: source,
            characterGrid: grid,
            answerLocations: locations
            ) else {
                return
        }
        
        for (_, path) in locations.enumerate() {
            gameBoard.checkAnswer(withCoordinates: path)
        }
        
        XCTAssertTrue(gameBoard.isFinished(),
            "Test Failed: isFinished method should have returned `true` as all correct paths are found.")
    }
    
    func testGameBoardFinishedFalse() {
        guard let jsonObj = self.getJSONGraph(fromFileName: "Test2", ofType: "json") as? NSDictionary else {
            return
        }
        
        guard let source = jsonObj[JSONKeys.Word] as? String,
            grid = jsonObj[JSONKeys.CharacterGrid] as? [[String]],
            locations = jsonObj[JSONKeys.WordLocations]?.allKeys as? [String] else {
                return
        }
        
        guard let gameBoard = GameBoard(
            withSourceWord: source,
            characterGrid: grid,
            answerLocations: locations
            ) else {
                return
        }
        
        gameBoard.checkAnswer(withCoordinates: locations[0])
        
        XCTAssertFalse(gameBoard.isFinished(),
            "Test Failed: isFinished method should have returned `false` as all correct paths are not yet found.")
    }
    
    private func getJSONGraph(fromFileName name: String, ofType type: String) -> AnyObject? {
        guard let path = testBundle.pathForResource(name, ofType: type), data = NSData(contentsOfFile: path) else {
            return nil
        }
        
        do {
            return try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            return nil
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
}
