//
//  MenuScene.swift
//  PrVZ Dev
//
//  Created by jackson on 12/7/14.
//  Copyright (c) 2014 jackson. All rights reserved.
//

import SpriteKit
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
    
    override func didMove(to view: SKView)
    {
        let background = SKSpriteNode(imageNamed: "background-dark.png")
        background.zPosition = -2
        background.name = "background"
        background.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        self.addChild(background)
        
        let startGameButton = SKButton(defaultButtonImage: "startButtonGame.png", activeButtonImage: "startButtonGame.png", buttonAction: moveToGameScene)
        startGameButton.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        self.addChild(startGameButton)
        
        /*var multiplayerButton = SKButton(defaultButtonImage: "multiplayerButton.png", activeButtonImage: "multiplayerButtonPressed.png", buttonAction: openGameCenterMatchMakingMultiplayer)
        multiplayerButton.position = CGPoint(x: CGRectGetMidX(self.frame)-300, y: CGRectGetMidY(self.frame)-200)
        self.addChild(multiplayerButton)*/
        //Removing Until Fixed
        
        let multiplayerButton = SKButton(defaultButtonImage: "multiplayerButton.png", activeButtonImage: "multiplayerButtonPressed.png", buttonAction: openGameCenterMatchMakingChallenge)
        multiplayerButton.position = CGPoint(x: self.frame.midX-300, y: self.frame.midY-200)
        self.addChild(multiplayerButton)
        
        let defaults: UserDefaults = UserDefaults.standard()
        if let currentScore = defaults.object(forKey: "currentScore") as? NSInteger
        {
            self.zombiesKilled = currentScore
        }
        if let volumeDefaults = defaults.object(forKey: "volume") as? Float
        {
            self.volume = volumeDefaults
            self.volumeDisplay = volumeDefaults
        }
        
        let title = SKLabelNode(fontNamed: "TimesNewRoman")
        title.fontSize = 64
        title.fontColor = SKColor.red()
        title.text = "Menu"
        title.position = CGPoint(x: self.frame.midX, y: self.frame.midY+100)
        self.addChild(title)
        
        let mapButton = SKButton(defaultButtonImage: "mapButton.png", activeButtonImage: "mapButtonPressed.png", buttonAction: showMap)
        mapButton.position = CGPoint(x: self.frame.midX-300, y: self.frame.midY)
        self.addChild(mapButton)
        
        let statsButton = SKButton(defaultButtonImage: "infoButton", activeButtonImage: "infoButtonPressed", buttonAction: stats)
        statsButton.position = CGPoint(x: self.frame.midX+300, y: self.frame.midY)
        self.addChild(statsButton)
        
        let volumeSettingsButton = SKButton(defaultButtonImage: "volumeButton", activeButtonImage: "volumeButtonPressed", buttonAction: showVolumeSettings)
        volumeSettingsButton.position = CGPoint(x: self.frame.midX, y: self.frame.midY-200)
        self.addChild(volumeSettingsButton)
        
        volumeSlider?.isHidden = true
        volumeSlider?.isUserInteractionEnabled = false
        volumeSlider?.maximumValue = 10
        volumeSlider?.minimumValue = 1
        volumeSlider?.setValue(self.volumeDisplay, animated: true)
        
        let developmentButton = SKButton(defaultButtonImage: "developmentButton", activeButtonImage: "developmentButtonPressed", buttonAction: showDevelopmentScene)
        developmentButton.position = CGPoint(x: self.frame.midX+300, y: self.frame.midY-200)
        self.addChild(developmentButton)
    }
    
    func showDevelopmentScene()
    {
        gameViewController1?.presentDevelopmentScene()
    }
    
    func showMap()
    {
        let map = SKSpriteNode(imageNamed: "map1.png")
        map.zPosition = 10
        map.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        map.name = "map"
        self.addChild(map)
    }
    
    func stats()
    {
        let stats = SKNode()
        stats.name = "stats"
        
        let backGround = SKShapeNode(circleOfRadius: 10)
        backGround.path = CGPath(rect: CGRect(x: 32, y: 0, width: 960, height: 720), transform: nil)
        backGround.fillColor = SKColor.gray()
        backGround.name = "bg"
        backGround.position = CGPoint(x: 0, y: 0)
        backGround.zPosition = 5
        stats.addChild(backGround)
        
        let defaults: UserDefaults = UserDefaults.standard()
        if let highScore = defaults.object(forKey: "highScore") as? NSInteger
        {
            
            let highScoreLabel = SKLabelNode(fontNamed: "TimesNewRoman")
            highScoreLabel.fontColor = SKColor.orange()
            highScoreLabel.name = "highScoreLabel"
            highScoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY+200)
            highScoreLabel.zPosition = 6
            stats.addChild(highScoreLabel)
            
            highScoreLabel.text = NSString(format: "High Score: %i", highScore) as String
        }
        
        let levelsCompletedLabel = SKLabelNode(fontNamed: "TimesNewRoman")
        
        levelsCompletedLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY+100)
        levelsCompletedLabel.fontColor = SKColor.blue()
        levelsCompletedLabel.zPosition = 6
        
        if let levels = defaults.object(forKey: "levels") as? NSInteger
        {
            levelsCompletedLabel.text = NSString(format: "Levels Completed: %i", levels) as String
        }
        else
        {
            levelsCompletedLabel.text = "Levels Completed: 0"
        }
        stats.addChild(levelsCompletedLabel)
        
        let currentScoreLabel = SKLabelNode(fontNamed: "TimesNewRoman")
        currentScoreLabel.fontColor = SKColor.red()
        currentScoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY+150)
        currentScoreLabel.zPosition = 6
        
        currentScoreLabel.text = NSString(format: "Curent Score: %i", self.zombiesKilled) as String
        
        stats.addChild(currentScoreLabel)
        
        let zombiesKilledLabel = SKLabelNode(fontNamed: "TimesNewRoman")
        zombiesKilledLabel.fontColor = SKColor.blue()
        zombiesKilledLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY+30)
        zombiesKilledLabel.zPosition = 6
        
        if let normalZombiesKilled = defaults.object(forKey: "zombieKills") as? NSInteger
        {
            zombiesKilledLabel.text = NSString(format: "You have killed %i Normal Zombies", normalZombiesKilled) as String
        }
        else
        {
            zombiesKilledLabel.text = "You have killed 0 Normal Zombies"
        }
        
        stats.addChild(zombiesKilledLabel)
        
        let zombiesDiedLabel = SKLabelNode(fontNamed: "TimesNewRoman")
        zombiesDiedLabel.fontColor = SKColor.red()
        zombiesDiedLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY+5)
        zombiesDiedLabel.zPosition = 6
        
        if let normalZombiesDied = defaults.object(forKey: "zombiesDied") as? NSInteger
        {
            zombiesDiedLabel.text = NSString(format: "    You have been killed by %i Normal Zombies", normalZombiesDied) as String
        }
        else
        {
            zombiesDiedLabel.text = "    You have never been killed by a Normal Zombie"
        }
        
        stats.addChild(zombiesDiedLabel)
        
        let catZombiesKilledLabel = SKLabelNode(fontNamed: "TimesNewRoman")
        catZombiesKilledLabel.fontColor = SKColor.blue()
        catZombiesKilledLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY-30)
        catZombiesKilledLabel.zPosition = 6
        
        if let catZombiesKilled = defaults.object(forKey: "catZombieKills") as? NSInteger
        {
            catZombiesKilledLabel.text = NSString(format: "You have killed %i Cat Zombies", catZombiesKilled) as String
        }
        else
        {
            catZombiesKilledLabel.text = "You have killed 0 Cat Zombies"
        }
        
        stats.addChild(catZombiesKilledLabel)
        
        let catZombiesDiedLabel = SKLabelNode(fontNamed: "TimesNewRoman")
        catZombiesDiedLabel.fontColor = SKColor.red()
        catZombiesDiedLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY-55)
        catZombiesDiedLabel.zPosition = 6
        
        if let catZombiesDied = defaults.object(forKey: "catZombiesDied") as? NSInteger
        {
            catZombiesDiedLabel.text = NSString(format: "    You have been killed by %i Cat Zombies", catZombiesDied) as String
        }
        else
        {
            catZombiesDiedLabel.text = "    You have never been killed by a Cat Zombie"
        }
        
        stats.addChild(catZombiesDiedLabel)
        
        let version = SKLabelNode(fontNamed: "TimesNewRoman")
        version.fontColor = SKColor.green()
        version.position = CGPoint(x: self.frame.midX, y: self.frame.midY-150)
        version.zPosition = 6
        version.text = NSString(format: "Version: %.2f", self.version) as String
        stats.addChild(version)
        
        let gameCenterButton = self.addButton(CGPoint(x: self.frame.midX+400, y: self.frame.midY+100), type: "back", InMenu: "settings", WithAction: openGameCenterLeaderboards, WithName: "Game-Center")
        stats.addChild(gameCenterButton)
        
        self.addChild(stats)
    }
    
    func openGameCenterLeaderboards()
    {
        self.gameViewController1!.showLeaderboard()
    }
    
    func openGameCenterMatchMakingMultiplayer()
    {
        self.gameViewController1!.findMatchForMultiplayer()
    }
    
    func openGameCenterMatchMakingChallenge()
    {
        self.gameViewController1!.findMatchForChallenge()
    }
    
    func addButton(_ pos: CGPoint, type: NSString, InMenu: NSString, WithAction: () -> Void, WithName: NSString) -> SKButton
    {
        var posOverride = CGPoint(x: 0, y: 0)
        if type == "back" && InMenu != "default"
        {
            posOverride = CGPoint(x: self.frame.midX+400, y: self.frame.midX-140)
        }
        
        let button = SKButton(defaultButtonImage: WithName as String, activeButtonImage: (WithName as String) + "Pressed", buttonAction: WithAction)
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
        
        button.name = WithName as String
        
        return button
    }
    
    func showVolumeSettings()
    {
        let volumeSettings = SKNode()
        volumeSettings.name = "volumeSettings"
        
        let backGround = SKShapeNode(circleOfRadius: 10)
        backGround.path = CGPath(rect: CGRect(x: 32, y: 0, width: 960, height: 720), transform: nil)
        backGround.fillColor = SKColor.gray()
        backGround.name = "bg"
        backGround.position = CGPoint(x: 0, y: 0)
        backGround.zPosition = 5
        volumeSettings.addChild(backGround)
        
        volumeSlider?.isHidden = false
        volumeSlider?.isUserInteractionEnabled = true
        volumeSlider?.setValue(self.volumeDisplay, animated: true)
        
        let muteButton = SKButton(defaultButtonImage: "mute", activeButtonImage: "mutePressed", buttonAction: mute)
        muteButton.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        muteButton.zPosition = 10
        volumeSettings.addChild(muteButton)
        
        let muteDisplay = SKLabelNode(fontNamed: "TimesNewRoman")
        muteDisplay.fontSize = 24
        muteDisplay.fontColor = SKColor.red()
        muteDisplay.position = CGPoint(x: self.frame.midX, y: self.frame.midY-100)
        muteDisplay.name = "muteDisplay"
        muteDisplay.zPosition = 10
        self.addChild(muteDisplay)
        
        self.addChild(volumeSettings)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        if let _ = self.childNode(withName: "map")
        {
            self.hideMap()
        }
        if let _ = self.childNode(withName: "stats")
        {
            self.hideStats()
        }
        if let _ = self.childNode(withName: "volumeSettings")
        {
            self.hideVolumeSettings()
        }
    }
    
    func hideMap()
    {
        let map = self.childNode(withName: "map")
        map?.removeFromParent()
    }
    
    func hideStats()
    {
        let stats = self.childNode(withName: "stats")
        stats?.removeFromParent()
    }
    
    func hideVolumeSettings()
    {
        let defaults: UserDefaults = UserDefaults.standard()
        if muted == false
        {
            defaults.set(volumeSlider?.value, forKey: "volume")
            let volumeTemp = volumeSlider?.value
            self.volumeDisplay = volumeTemp!
        }
        else
        {
            defaults.set(0, forKey: "volume")
            self.volumeDisplay = 0
        }
        let volumeSettings = self.childNode(withName: "volumeSettings")
        volumeSettings?.removeFromParent()
        let muteDisplay = self.childNode(withName: "muteDisplay")
        muteDisplay?.removeFromParent()
        volumeSlider?.isHidden = true
        volumeSlider?.isUserInteractionEnabled = false
    }
    
    func moveToGameScene()
    {
        gameViewController1?.presentGameScene()
    }
    
    func moveToMultiplayerScene()
    {
        gameViewController1?.presentMultiplayerScene()
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
    
    override func update(_ currentTime: TimeInterval)
    {
        if let _ = self.childNode(withName: "volumeSettings")
        {
            let muteDisplay = self.childNode(withName: "muteDisplay")
            let muteDisplaySK = muteDisplay as? SKLabelNode
            muteDisplaySK?.text = NSString(format: "Muted: %i", Int(self.muted)) as String
            if self.muted == true
            {
                volumeSlider?.setValue(0, animated: true)
            }
        }
    }
}
