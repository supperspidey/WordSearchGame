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

class GameBoardView: UIView {
    private var selectedColor: UIColor?
    private var unselectedColor: UIColor?
    
    required init?(coder aDecoder: NSCoder) {
        self.selectedColor = UIColor.grayColor()
        self.unselectedColor = UIColor.whiteColor()
        
        super.init(coder: aDecoder)
    }
    
    @IBAction func handlePanGesture(panGesture: UIPanGestureRecognizer) {
        if panGesture.state == .Changed {
            guard let view = self.hitTest(panGesture.locationInView(self), withEvent: nil) else {
                return
            }
            
            if view.isKindOfClass(UILabel) {
                let label = view as! UILabel
                label.backgroundColor = selectedColor
            }
        }
    }
    
    override func didAddSubview(subview: UIView) {
        subview.userInteractionEnabled = true
        subview.backgroundColor = unselectedColor
    }
}
