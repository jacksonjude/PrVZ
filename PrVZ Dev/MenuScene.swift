//
//  MenuScene.swift
//  PrVZ Dev
//
//  Created by jackson on 12/7/14.
//  Copyright (c) 2014 jackson. All rights reserved.
//

import Spritekit
import GameKit

class MenuScene: SKScene
{
    var gameViewController1: GameViewController?
    var volumeSlider: UISlider?
    var zombiesKilled = NSInteger()
    let version = 1.0
    var volume = Float()
    var muted = false
    var volumeDisplay = Float()
    
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
        if let volumeDefaults = defaults.objectForKey("volume") as? Float
        {
            self.volume = volumeDefaults
            self.volumeDisplay = volumeDefaults
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
        
        var volumeSettingsButton = SKButton(defaultButtonImage: "volumeButton", activeButtonImage: "volumeButtonPressed", buttonAction: showVolumeSettings)
        volumeSettingsButton.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame)-200)
        self.addChild(volumeSettingsButton)
        
        volumeSlider?.hidden = true
        volumeSlider?.userInteractionEnabled = false
        volumeSlider?.maximumValue = 10
        volumeSlider?.minimumValue = 1
        volumeSlider?.setValue(self.volumeDisplay, animated: true)
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
        
        var zombiesKilledLabel = SKLabelNode(fontNamed: "TimesNewRoman")
        zombiesKilledLabel.fontColor = SKColor.blueColor()
        zombiesKilledLabel.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame)+30)
        zombiesKilledLabel.zPosition = 6
        
        if let normalZombiesKilled = defaults.objectForKey("zombiesKilled") as? NSInteger
        {
            zombiesKilledLabel.text = NSString(format: "You have killed %i Normal Zombies", normalZombiesKilled)
        }
        else
        {
            zombiesKilledLabel.text = "You have killed 0 Normal Zombies"
        }
        
        stats.addChild(zombiesKilledLabel)
        
        var zombiesDiedLabel = SKLabelNode(fontNamed: "TimesNewRoman")
        zombiesDiedLabel.fontColor = SKColor.redColor()
        zombiesDiedLabel.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame)+5)
        zombiesDiedLabel.zPosition = 6
        
        if let normalZombiesDied = defaults.objectForKey("zombiesDied") as? NSInteger
        {
            zombiesDiedLabel.text = NSString(format: "    You have been killed by %i Normal Zombies", normalZombiesDied)
        }
        else
        {
            zombiesDiedLabel.text = "    You have never been killed by a Normal Zombie"
        }
        
        stats.addChild(zombiesDiedLabel)
        
        var catZombiesKilledLabel = SKLabelNode(fontNamed: "TimesNewRoman")
        catZombiesKilledLabel.fontColor = SKColor.blueColor()
        catZombiesKilledLabel.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame)-30)
        catZombiesKilledLabel.zPosition = 6
        
        if let catZombiesKilled = defaults.objectForKey("catZombiesKilled") as? NSInteger
        {
            catZombiesKilledLabel.text = NSString(format: "You have killed %i Cat Zombies", catZombiesKilled)
        }
        else
        {
            catZombiesKilledLabel.text = "You have killed 0 Cat Zombies"
        }
        
        stats.addChild(catZombiesKilledLabel)
        
        var catZombiesDiedLabel = SKLabelNode(fontNamed: "TimesNewRoman")
        catZombiesDiedLabel.fontColor = SKColor.redColor()
        catZombiesDiedLabel.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame)-55)
        catZombiesDiedLabel.zPosition = 6
        
        if let catZombiesDied = defaults.objectForKey("catZombiesDied") as? NSInteger
        {
            catZombiesDiedLabel.text = NSString(format: "    You have been killed by %i Cat Zombies", catZombiesDied)
        }
        else
        {
            catZombiesDiedLabel.text = "    You have never been killed by a Cat Zombie"
        }
        
        stats.addChild(catZombiesDiedLabel)
        
        var version = SKLabelNode(fontNamed: "TimesNewRoman")
        version.fontColor = SKColor.greenColor()
        version.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame)-150)
        version.zPosition = 6
        version.text = NSString(format: "Version: %.2f", self.version)
        stats.addChild(version)
        
        var gameCenterButton = self.addButton(CGPoint(x: CGRectGetMidX(self.frame)+400, y: CGRectGetMidX(self.frame)), type: "back", InMenu: "settings", WithAction: openGameCenterLeaderboards, WithName: "Game-Center")
        stats.addChild(gameCenterButton)
        
        self.addChild(stats)
    }
    
    func openGameCenterLeaderboards()
    {
        gameViewController1?.showLeaderboard()
    }
    
    func addButton(pos: CGPoint, type: NSString, InMenu: NSString, WithAction: () -> Void, WithName: NSString) -> SKButton
    {
        var posOverride = CGPoint(x: 0, y: 0)
        if type == "back" && InMenu != "default"
        {
            posOverride = CGPoint(x: CGRectGetMidX(self.frame)+400, y: CGRectGetMidX(self.frame)-140)
        }
        
        var button = SKButton(defaultButtonImage: WithName, activeButtonImage: WithName + "Pressed", buttonAction: WithAction)
        if posOverride != CGPoint(x: 0, y: 0) && pos == CGPoint(x: 0, y: 0)
        {
            button.position = posOverride
        }
        else
        {
            button.position = pos
        }
        
        if InMenu == "settings" || InMenu == "store"
        {
            button.zPosition = 6
        }
        else
        {
            button.zPosition = 4
        }
        
        button.name = WithName
        
        return button
    }
    
    func showVolumeSettings()
    {
        var volumeSettings = SKNode()
        volumeSettings.name = "volumeSettings"
        
        var backGround = SKShapeNode(circleOfRadius: 10)
        backGround.path = CGPathCreateWithRect(CGRectMake(32, 0, 960, 720), nil)
        backGround.fillColor = SKColor.grayColor()
        backGround.name = "bg"
        backGround.position = CGPoint(x: 0, y: 0)
        backGround.zPosition = 5
        volumeSettings.addChild(backGround)
        
        volumeSlider?.hidden = false
        volumeSlider?.userInteractionEnabled = true
        volumeSlider?.setValue(self.volumeDisplay, animated: true)
        
        var muteButton = SKButton(defaultButtonImage: "mute", activeButtonImage: "mutePressed", buttonAction: mute)
        muteButton.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        muteButton.zPosition = 10
        volumeSettings.addChild(muteButton)
        
        var muteDisplay = SKLabelNode(fontNamed: "TimesNewRoman")
        muteDisplay.fontSize = 24
        muteDisplay.fontColor = SKColor.redColor()
        muteDisplay.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame)-100)
        muteDisplay.name = "muteDisplay"
        muteDisplay.zPosition = 10
        self.addChild(muteDisplay)
        
        self.addChild(volumeSettings)
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
        if let volumeSettings = self.childNodeWithName("volumeSettings")
        {
            self.hideVolumeSettings()
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
    
    func hideVolumeSettings()
    {
        var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if muted == false
        {
            defaults.setObject(volumeSlider?.value, forKey: "volume")
            var volumeTemp = volumeSlider?.value
            self.volumeDisplay = volumeTemp!
        }
        else
        {
            defaults.setObject(0, forKey: "volume")
            self.volumeDisplay = 0
        }
        let volumeSettings = self.childNodeWithName("volumeSettings")
        volumeSettings?.removeFromParent()
        let muteDisplay = self.childNodeWithName("muteDisplay")
        muteDisplay?.removeFromParent()
        volumeSlider?.hidden = true
        volumeSlider?.userInteractionEnabled = false
    }
    
    func moveToGameScene()
    {
        gameViewController1?.presentGameScene()
    }
    
    func mute()
    {
        if self.muted == false
        {
            self.muted = true
        }
        else
        {
            self.muted = false
        }
    }
    
    override func update(currentTime: NSTimeInterval)
    {
        if let volumeSettings = self.childNodeWithName("volumeSettings")
        {
            let muteDisplay = self.childNodeWithName("muteDisplay")
            var muteDisplaySK = muteDisplay as? SKLabelNode
            muteDisplaySK?.text = NSString(format: "Muted: %i", Int(self.muted))
            if self.muted == true
            {
                volumeSlider?.setValue(0, animated: true)
            }
        }
    }
}