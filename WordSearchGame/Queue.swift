//
//  Queue.swift
//  Duolingo
//
//  Created by Van Le Nguyen on 3/4/16.
//  Copyright © 2016 Van Le Nguyen. All rights reserved.
//

import Foundation

struct Queue<Element> {
    private var items = [Element]()
    
    mutating func enqueue(item: Element) {
        items.append(item)
    }
    
    mutating func dequeue() -> Element? {
        if items.count > 0 {
            return items.removeFirst()
        } else {
            return nil
        }
    }
    
    mutating func peek() -> Element? {
        return items.first
    }
}