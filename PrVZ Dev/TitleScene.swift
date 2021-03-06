//
//  TitleScene.swift
//  PrVZ Dev
//
//  Created by jackson on 9/21/14.
//  Copyright (c) 2014 jackson. All rights reserved.
//

import Foundation
import SpriteKit

class TitleScene: SKScene
{
    let start = SKLabelNode(fontNamed: "TimesNewRoman")
    
    let wait = SKAction.wait(forDuration: 1.0)
    let hide = SKAction.hide()
    let unhide = SKAction.unhide()
    var gameViewController1: GameViewController?
    var slider: UISlider?
    var switch1: UISwitch?
    var slider2: UISlider?
    var slider3: UISlider?
    var slider4: UISlider?
    
    override func didMove(to view: SKView)
    {        
        self.start.text = "Start"
        self.start.name = "start"
        self.start.fontSize = 85
        self.start.position = CGPoint(x:self.frame.midX, y:self.frame.midY)
        
        let flash = SKAction.repeatForever(SKAction.sequence([hide, wait, unhide, wait]))
        self.start.run(flash)
        
        let background = SKSpriteNode(imageNamed: "backgroundg.png")
        background.zPosition = -2
        background.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        
        self.addChild(background)
        self.addChild(self.start)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        self.gameViewController1?.presentTutorialScene()
    }
    
    override func update(_ currentTime: TimeInterval)
    {
        
    }
}
