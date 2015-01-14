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
        
        var mapButton = SKButton(defaultButtonImage: "mapButton.png", activeButtonImage: "mapButtonPressed.png", buttonAction: showMap)
        mapButton.position = CGPoint(x: CGRectGetMidX(self.frame)-300, y: CGRectGetMidY(self.frame))
        self.addChild(mapButton)
        
    }
    
    func showMap()
    {
        var map = SKSpriteNode(imageNamed: "map1.png")
        map.zPosition = 10
        map.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        map.name = "map"
        var circle = CGRectMake(100.0, 100.0, 80.0, 80.0)
        var progress = SKShapeNode()
        self.addChild(map)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent)
    {
        if let map = self.childNodeWithName("map")
        {
            self.hideMap()
        }
    }
    
    func hideMap()
    {
        var map = self.childNodeWithName("map")
        map?.removeFromParent()
    }
    
    func moveToGameScene()
    {
        gameViewController1?.presentGameScene()
    }
    
    override func update(currentTime: NSTimeInterval)
    {
        
    }
}