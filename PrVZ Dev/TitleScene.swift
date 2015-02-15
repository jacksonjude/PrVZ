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
    var slider2: UISlider?
    var slider3: UISlider?
    
    override func didMoveToView(view: SKView)
    {        
        self.start.text = "Start"
        self.start.name = "start"
        self.start.fontSize = 85
        self.start.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        
        let flash = SKAction.repeatActionForever(SKAction.sequence([hide, wait, unhide, wait]))
        self.start.runAction(flash)
        
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
