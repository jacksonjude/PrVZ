//
//  SKButton.swift
//  PrVZ Dev
//
//  Created by jackson on 9/27/14.
//  Copyright (c) 2014 jackson. All rights reserved.
//

import SpriteKit

class SKButton: SKNode {
    var defaultButton: SKSpriteNode
    var activeButton: SKSpriteNode
    var action: () -> Void
    
    init(defaultButtonImage: String, activeButtonImage: String, buttonAction: () -> Void) {
        defaultButton = SKSpriteNode(imageNamed: defaultButtonImage)
        activeButton = SKSpriteNode(imageNamed: activeButtonImage)
        activeButton.hidden = true
        action = buttonAction
        
        super.init()
        
        userInteractionEnabled = true
        addChild(defaultButton)
        addChild(activeButton)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        activeButton.hidden = false
        defaultButton.hidden = true
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        var touch: UITouch = touches.allObjects[0] as UITouch
        var location: CGPoint = touch.locationInNode(self)
        
        if defaultButton.containsPoint(location) {
            activeButton.hidden = false
            defaultButton.hidden = true
        } else {
            activeButton.hidden = true
            defaultButton.hidden = false
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        var touch: UITouch = touches.allObjects[0] as UITouch
        var location: CGPoint = touch.locationInNode(self)
        
        if defaultButton.containsPoint(location) {
            action()
        }
        
        activeButton.hidden = true
        defaultButton.hidden = false
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
