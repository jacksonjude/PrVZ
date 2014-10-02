//
//  GameScene.swift
//  PrVZ Dev
//
//  Created by jackson on 10/1/14.
//  Copyright (c) 2014 jackson. All rights reserved.
//

import Foundation
import Spritekit

class GameScene: SKScene
{
    override func didMoveToView(view: SKView)
    {
        var TESTNODECANDELETELATER = SKLabelNode(fontNamed: "TimesNewRoman")
        TESTNODECANDELETELATER.text = "V0.1 ALPHA WIP"
        TESTNODECANDELETELATER.fontSize = 64
        TESTNODECANDELETELATER.fontColor = SKColor.blackColor()
        TESTNODECANDELETELATER.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        self.addChild(TESTNODECANDELETELATER)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent)
    {
        
    }
    
    override func update(currentTime: NSTimeInterval)
    {
        
    }
}