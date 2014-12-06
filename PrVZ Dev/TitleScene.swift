//
//  TitleScene.swift
//  PrVZ Dev
//
//  Created by jackson on 9/21/14.
//  Copyright (c) 2014 jackson. All rights reserved.
//

import Foundation
import Spritekit

class TitleScene: SKScene
{
    let start = SKLabelNode(fontNamed: "TimesNewRoman")
    
    let wait = SKAction.waitForDuration(1.0)
    let hide = SKAction.hide()
    let unhide = SKAction.unhide()
    var gameViewController1: GameViewController?
    var slider: UISlider?
    var switch1: UISwitch?
    
    override func didMoveToView(view: SKView)
    {        
        start.text = "Start"
        start.name = "start"
        start.fontSize = 85
        start.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        
        let flash = SKAction.repeatActionForever(SKAction.sequence([hide, wait, unhide, wait]))
        start.runAction(flash)
        
        let background = SKSpriteNode(imageNamed: "background.png")
        background.zPosition = -2
        background.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        
        self.addChild(background)
        self.addChild(start)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent)
    {
        self.gameViewController1?.presentTutorialScene()
    }
    
    override func update(currentTime: CFTimeInterval)
    {
        
    }
}
