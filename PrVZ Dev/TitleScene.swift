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
    
    override func didMoveToView(view: SKView)
    {
        /* Setup your scene here */
        start.text = "Start"
        start.name = "start"
        start.fontSize = 85
        start.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        
        let flash = SKAction.repeatActionForever(SKAction.sequence([hide, wait, unhide, wait]))
        start.runAction(flash)
        
        let background = SKSpriteNode(imageNamed: "background.png");
        background.zPosition = -2
        background.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame));
        
        self.addChild(background)
        self.addChild(start)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent)
    {
        let tutorialScene = TutorialScene(size: self.size)
        
        let skView = self.view! as SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        
        tutorialScene.scaleMode = SKSceneScaleMode.AspectFill
        
        skView.presentScene(tutorialScene)
    }
    
    override func update(currentTime: CFTimeInterval)
    {
        /* Called before each frame is rendered */
    }
}
