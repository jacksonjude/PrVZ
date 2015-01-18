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
    var zombiesKilled = NSInteger()
    var version = 1.0
    
    override func didMoveToView(view: SKView)
    {
        var startGameButton = SKButton(defaultButtonImage: "startButtonGame.png", activeButtonImage: "startButtonGame.png", buttonAction: moveToGameScene)
        startGameButton.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        self.addChild(startGameButton)
        
        var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if let currentScore = defaults.objectForKey("currentScore") as? NSInteger
        {
            self.zombiesKilled = currentScore
        }
        
        var title = SKLabelNode(fontNamed: "TimesNewRoman")
        title.fontSize = 64
        title.fontColor = SKColor.redColor()
        title.text = "Menu"
        title.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame)+100)
        self.addChild(title)
        
        var mapButton = SKButton(defaultButtonImage: "mapButton.png", activeButtonImage: "mapButtonPressed.png", buttonAction: showMap)
        mapButton.position = CGPoint(x: CGRectGetMidX(self.frame)-300, y: CGRectGetMidY(self.frame))
        self.addChild(mapButton)
        
        var statsButton = SKButton(defaultButtonImage: "infoButton", activeButtonImage: "infoButtonPressed", buttonAction: stats)
        statsButton.position = CGPoint(x: CGRectGetMidX(self.frame)+300, y: CGRectGetMidY(self.frame))
        self.addChild(statsButton)
        
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
    
    func stats()
    {
        var stats = SKNode()
        stats.name = "stats"
        
        var backGround = SKShapeNode(circleOfRadius: 10)
        backGround.path = CGPathCreateWithRect(CGRectMake(32, 0, 960, 720), nil)
        backGround.fillColor = SKColor.grayColor()
        backGround.name = "bg"
        backGround.position = CGPoint(x: 0, y: 0)
        backGround.zPosition = 5
        stats.addChild(backGround)
        
        var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if let highScore = defaults.objectForKey("highScore") as? NSInteger
        {
            
            var highScoreLabel = SKLabelNode(fontNamed: "TimesNewRoman")
            highScoreLabel.fontColor = SKColor.orangeColor()
            highScoreLabel.name = "highScoreLabel"
            highScoreLabel.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame)+200)
            highScoreLabel.zPosition = 6
            stats.addChild(highScoreLabel)
            
            highScoreLabel.text = NSString(format: "High Score: %i", highScore)
        }
        
        var levelsCompletedLabel = SKLabelNode(fontNamed: "TimesNewRoman")
        
        levelsCompletedLabel.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame)+100)
        levelsCompletedLabel.fontColor = SKColor.blueColor()
        levelsCompletedLabel.zPosition = 6
        
        if let levels = defaults.objectForKey("levels") as? NSInteger
        {
            levelsCompletedLabel.text = NSString(format: "Levels Completed: %i", levels)
        }
        else
        {
            levelsCompletedLabel.text = "Levels Completed: 0"
        }
        stats.addChild(levelsCompletedLabel)
        
        var currentScoreLabel = SKLabelNode(fontNamed: "TimesNewRoman")
        currentScoreLabel.fontColor = SKColor.redColor()
        currentScoreLabel.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame)+150)
        currentScoreLabel.zPosition = 6
        
        currentScoreLabel.text = NSString(format: "Curent Score: %i", self.zombiesKilled)
        
        stats.addChild(currentScoreLabel)
        
        var version = SKLabelNode(fontNamed: "TimesNewRoman")
        version.fontColor = SKColor.greenColor()
        version.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame)-150)
        version.zPosition = 6
        version.text = NSString(format: "Version: %.2f", self.version)
        stats.addChild(version)
        
        self.addChild(stats)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent)
    {
        if let map = self.childNodeWithName("map")
        {
            self.hideMap()
        }
        if let stats = self.childNodeWithName("stats")
        {
            self.hideStats()
        }
    }
    
    func hideMap()
    {
        var map = self.childNodeWithName("map")
        map?.removeFromParent()
    }
    
    func hideStats()
    {
        var stats = self.childNodeWithName("stats")
        stats?.removeFromParent()
    }
    
    func moveToGameScene()
    {
        gameViewController1?.presentGameScene()
    }
    
    override func update(currentTime: NSTimeInterval)
    {
        
    }
}