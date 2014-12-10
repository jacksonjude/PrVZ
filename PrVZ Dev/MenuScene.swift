//
//  MenuScene.swift
//  PrVZ Dev
//
//  Created by jackson on 12/7/14.
//  Copyright (c) 2014 jackson. All rights reserved.
//

import Spritekit

class MenuScene: SKScene
{
    var gameViewController1: GameViewController?
    
    override func didMoveToView(view: SKView)
    {
        var startGameButton = SKButton(defaultButtonImage: "startButtonGame.png", activeButtonImage: "startButtonGame.png", buttonAction: moveToGameScene)
        startGameButton.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        self.addChild(startGameButton)
        
        var title = SKLabelNode(fontNamed: "TimesNewRoman")
        title.fontSize = 64
        title.fontColor = SKColor.redColor()
        title.text = "Menu"
        title.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame)+100)
        self.addChild(title)
    }
    
    func moveToGameScene()
    {
        gameViewController1?.presentGameScene()
    }
    
    override func update(currentTime: NSTimeInterval)
    {
        
    }
}