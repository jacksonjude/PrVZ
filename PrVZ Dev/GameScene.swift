//
//  GameScene.swift
//  PrVZ Dev
//
//  Created by jackson on 10/1/14.
//  Copyright (c) 2014 jackson. All rights reserved.
//

import Foundation
import SpriteKit
import UIKit
import AVFoundation

private var backgroundMusicPlayer: AVAudioPlayer!

class GameScene: SKScene, SKPhysicsContactDelegate
{
    let brushCategory: UInt32 =  1 << 0
    let monsterCategory: UInt32 =  1 << 1
    let princessCategory: UInt32 =  1 << 2
    let enemyProjectileCatagory: UInt32 =  1 << 3
    
    var princess1 = Princess()
    var princessHealth = Float()
    var zombies = NSMutableArray()
    var gameIsRunning = false
    var canPressButtons = true
    var zombieSpeed: CGFloat = 1.0
    var joystick = JCJoystick(controlRadius:50, baseRadius:68, baseColor:SKColor.blueColor(), joystickRadius:50, joystickColor:SKColor.redColor())
    var joystickBool = true
    var buttons = SKNode()
    var brushInWorld = false
    var windowIsOpen = false
    var zombiesKilled = 0
    var coins = 0
    var coinsLabel = SKLabelNode(fontNamed: "TimesNewRoman")
    var zombiesToSpawnSlider: UISlider?
    var joystickSwitch: UISwitch?
    var zombieSpeedSlider: UISlider?
    var volumeSlider: UISlider?
    var gameViewController1: GameViewController?
    var infBrushItem = Bool()
    var healthPack = Bool()
    var battery = Bool()
    var wavesCompleted = NSInteger()
    var levelsCompletedLabel = SKLabelNode(fontNamed: "TimesNewRoman")
    var currentBrushes = NSMutableArray()
    var gamePaused = false
    var movedCoinsImage = false
    var storeButtons = NSMutableArray()
    var storeIsOpen = false
    var checkIsShowing = false
    var checkIsShowing2 = false
    var checkIsShowing3 = false
    var scrolled = 0
    var gameOverDidOccur = false
    var healthLostInLastRound = Float(0)
    let backgroundMusicSound = "background-music.wav"
    var achievementZombieFighter = false
    var achievementZombieSlayer = false
    var achievementZombieHunter = false
    var batteryPercent = 0.00
    var savedOnOpeningWindow = false
    var brushesInWorld = 0
    
    deinit
    {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func didMoveToView(view: SKView)
    {
        var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(1, forKey: "Tutorial")
        
        if let backgroundNumber = defaults.objectForKey("background") as? NSInteger
        {
            if backgroundNumber == 1
            {
                let background = SKSpriteNode(imageNamed: "background.png")
                background.zPosition = -2
                background.name = "background"
                background.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
                self.addChild(background)
            }
            if backgroundNumber == 2
            {
                let background = SKSpriteNode(imageNamed: "background2.png")
                background.zPosition = -2
                background.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
                self.addChild(background)
            }
            if backgroundNumber == 3
            {
                let background = SKSpriteNode(imageNamed: "background3.png")
                background.zPosition = -2
                background.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
                self.addChild(background)
            }
        }
        else
        {
            let background = SKSpriteNode(imageNamed: "background.png")
            background.zPosition = -2
            background.name = "background"
            background.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
            self.addChild(background)
        }
        
        if let levels = defaults.objectForKey("levels") as? NSInteger
        {
            if levels != 0
            {
                self.wavesCompleted = levels
            }
            else
            {
                self.wavesCompleted = 1
            }
        }
        else
        {
            self.wavesCompleted = 1
        }
        
        if let coinsUser = defaults.objectForKey("coins") as? NSInteger
        {
            self.coins += coinsUser
        }
        
        if let itemsBoughtInStore = defaults.objectForKey("items") as? NSMutableArray
        {
            if let item1 = itemsBoughtInStore[0] as? Bool
            {
                if item1 == true
                {
                    self.infBrushItem = true
                }
            }
            if let item2 = itemsBoughtInStore[1] as? Bool
            {
                if item2 == true
                {
                    self.healthPack = true
                }
            }
            if itemsBoughtInStore.count >= 3
            {
                if let item3 = itemsBoughtInStore[2] as? Bool
                {
                    if item3 == true
                    {
                        self.battery = true
                        if var percent = itemsBoughtInStore[3] as? Double
                        {
                            self.batteryPercent = percent
                        }
                    }
                }
            }
        }
        
        physicsWorld.gravity = CGVectorMake(0,0)
        self.physicsWorld.contactDelegate = self
        
        var wallEnd = SKShapeNode()
        var path = CGPathCreateMutable()
        CGPathAddRect(path, nil, CGRectMake(0, 0, 60, 3000))
        wallEnd.path = path
        wallEnd.fillColor = SKColor.grayColor()
        wallEnd.position = CGPoint(x: CGRectGetMidX(self.frame)-450, y: CGRectGetMidY(self.frame)-400)
        wallEnd.name = "wallEnd"
        self.addChild(wallEnd)
        
        princess1.position = CGPoint(x: CGRectGetMidX(self.frame)-300, y: CGRectGetMidY(self.frame))
        princess1.name = "princess"
        princess1.physicsBody = SKPhysicsBody(circleOfRadius:princess1.size.width/2)
        princess1.physicsBody?.dynamic = true
        princess1.physicsBody?.categoryBitMask = self.princessCategory
        princess1.physicsBody?.contactTestBitMask = self.monsterCategory
        princess1.physicsBody?.collisionBitMask = 0
        princess1.physicsBody?.usesPreciseCollisionDetection = true
        self.addChild(princess1)
        
        var pauseButton = SKButton(defaultButtonImage: "pause", activeButtonImage: "pause", buttonAction: pauseGame)
        pauseButton.position = CGPoint(x: CGRectGetMidX(self.frame)+400, y: CGRectGetMidY(self.frame)+100)
        pauseButton.name = "pauseButton"
        pauseButton.hidden = true
        pauseButton.userInteractionEnabled = false
        self.addChild(pauseButton)
        
        var fireButton = SKButton(defaultButtonImage: "fireButton", activeButtonImage: "fireButtonPressed", buttonAction: self.addBrush)
        fireButton.position = CGPoint(x: CGRectGetMidX(self.frame)+400, y: CGRectGetMidY(self.frame)-200)
        fireButton.name = "fire"
        self.addChild(fireButton)
        
        self.joystick.position = CGPoint(x: CGRectGetMidX(self.frame)-400, y: CGRectGetMidY(self.frame)-200)
        self.joystick.name = "joystick"
        self.addChild(joystick)
        
        var startButton = SKButton(defaultButtonImage: "startButtonGame", activeButtonImage: "startButtonGamePressed", buttonAction: runGame)
        startButton.position = CGPoint(x: CGRectGetMidX(self.frame)-300, y: CGRectGetMidY(self.frame)+200)
        startButton.name = "start"
        self.buttons.addChild(startButton)
        
        var storeButton = SKButton(defaultButtonImage: "storeButton", activeButtonImage: "storeButtonPressed", buttonAction: store)
        storeButton.position = CGPoint(x: CGRectGetMidX(self.frame)+300, y: CGRectGetMidY(self.frame)+200)
        storeButton.name = "store"
        self.buttons.addChild(storeButton)
        
        var settingsButton = SKButton(defaultButtonImage: "settingsButton", activeButtonImage: "settingsButtonPressed", buttonAction: settings)
        settingsButton.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame)+200)
        settingsButton.name = "settingsButton"
        self.buttons.addChild(settingsButton)
        
        self.addChild(self.buttons)
        
        var bar = SKShapeNode()
        bar.path = CGPathCreateWithRect(CGRectMake(32, 0, 960, 235), nil)
        bar.fillColor = SKColor.grayColor()
        bar.name = "bar"
        bar.position = CGPoint(x: 0, y: CGRectGetMidY(self.frame)+125)
        self.addChild(bar)
        
        self.zombiesToSpawnSlider?.hidden = true
        self.zombiesToSpawnSlider?.userInteractionEnabled = false
        self.zombiesToSpawnSlider?.maximumValue = 9
        self.zombiesToSpawnSlider?.minimumValue = 3
        
        self.joystickSwitch?.hidden = true
        self.joystickSwitch?.userInteractionEnabled = false
        
        self.zombieSpeedSlider?.hidden = true
        self.zombieSpeedSlider?.userInteractionEnabled = false
        self.zombieSpeedSlider?.minimumValue = 1
        self.zombieSpeedSlider?.maximumValue = 4
        
        self.coinsLabel.position = CGPoint(x: CGRectGetMidX(self.frame)+300, y: CGRectGetMidY(self.frame)+90)
        self.coinsLabel.fontColor = SKColor.redColor()
        self.addChild(self.coinsLabel)
        var coinsImage = SKSpriteNode(imageNamed: "coin.png")
        coinsImage.position = CGPoint(x: coinsImage.position.x-40, y: coinsImage.position.y+10)
        coinsImage.name = "coinsImage"
        self.coinsLabel.addChild(coinsImage)
        
        if let princessHealth1 = defaults.objectForKey("health") as? Float
        {
            self.princessHealth = princessHealth1
        }
        else
        {
            self.princessHealth = 1
        }
        
        if let healthLost = defaults.objectForKey("healthLost") as? Float
        {
            self.healthLostInLastRound = healthLost
        }
        
        if let currentScore = defaults.objectForKey("currentScore") as? NSInteger
        {
            self.zombiesKilled = currentScore
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"saveDataBackground", name: UIApplicationDidEnterBackgroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"saveDataBackground", name: UIApplicationWillTerminateNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"saveDataBackground", name: UIApplicationWillResignActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"didEnterFromBackground", name: UIApplicationDidBecomeActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"didEnterFrombackground", name: UIApplicationWillEnterForegroundNotification, object: nil)
        
        if let didComeBackFromBackground = defaults.objectForKey("didComeBackFromBackground") as? Bool
        {
            if didComeBackFromBackground == true
            {
                defaults.setObject(false, forKey: "didComeBackFromBackground")
                self.gameIsRunning = true
                self.canPressButtons = false
                if let zombiesData = defaults.objectForKey("zombies") as? NSData
                {
                    let zombiesUnarchived = NSKeyedUnarchiver.unarchiveObjectWithData(zombiesData) as! NSMutableArray
                    self.zombies = zombiesUnarchived
                    
                    for aZombie in zombies
                    {
                        var aZombieSK = aZombie as! SKSpriteNode
                        self.addChild(aZombieSK)
                    }
                }
                
                if self.zombieSpeedSlider?.value == 1
                {
                    var speedDivider = self.wavesCompleted / 8
                    if speedDivider >= 1
                    {
                        self.zombieSpeed = CGFloat(speedDivider)
                    }
                    else
                    {
                        self.zombieSpeed = 1
                    }
                }
                else
                {
                    let zombieSpeedToMakeAsACGFloat = self.zombieSpeedSlider?.value
                    self.zombieSpeed = CGFloat(zombieSpeedToMakeAsACGFloat!)
                }
                
                self.pauseGame()
            }
        }
        
        self.setUpAudio()
    }
    
    func runGame()
    {
        if (!backgroundMusicPlayer.playing)
        {
            backgroundMusicPlayer.play()
        }
        
        if self.gameOverDidOccur == true
        {
            self.princessHealth = 1
            self.gameOverDidOccur = false
        }
        else
        {
            if self.healthLostInLastRound > 0.5
            {
                self.princessHealth += 0.5
            }
            else
            {
                self.princessHealth += self.healthLostInLastRound
            }
        }
        
        self.healthLostInLastRound = 0
        
        self.princess1.runAction(SKAction.fadeInWithDuration(0))
        
        if let pauseButton = self.childNodeWithName("pauseButton")
        {
            pauseButton.hidden = false
            pauseButton.userInteractionEnabled = true
        }
        
        var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if let volume = defaults.objectForKey("volume") as? Float
        {
            backgroundMusicPlayer.volume = volume / 10
            NSLog("Volume: %f", volume)
        }
        
        if let zombiesKilledLabel = self.childNodeWithName("zombiesKilledLabel")
        {
            zombiesKilledLabel.removeFromParent()
        }
        
        if self.zombieSpeedSlider?.value == 1
        {
            var speedDivider = self.wavesCompleted / 8
            if speedDivider >= 1
            {
                self.zombieSpeed = CGFloat(speedDivider)
            }
            else
            {
                self.zombieSpeed = 1
            }
        }
        else
        {
            let zombieSpeedToMakeAsACGFloat = self.zombieSpeedSlider?.value
            self.zombieSpeed = CGFloat(zombieSpeedToMakeAsACGFloat!)
        }
        
        let numberOfZombiesToMakeAsAFloat = self.zombiesToSpawnSlider?.value
        var zombiesToSpawn = NSInteger(numberOfZombiesToMakeAsAFloat!)
        
        var zombiesSpawned = 0
        while zombiesSpawned != zombiesToSpawn
        {
            if wavesCompleted >= 3
            {
                var spawnCat = CGFloat(arc4random()%3)
                if spawnCat == 2
                {
                    var cat1 = CatZombie()
                    var yPos = CGFloat((arc4random()%150)+150)
                    var xPos = CGFloat((arc4random()%150)+150)
                    cat1.name = "catZombie"
                    cat1.health = self.wavesCompleted / 4
                    cat1.physicsBody = SKPhysicsBody(circleOfRadius:cat1.size.width/2)
                    cat1.physicsBody?.dynamic = true
                    cat1.physicsBody?.categoryBitMask = self.monsterCategory
                    cat1.physicsBody?.contactTestBitMask = self.princessCategory
                    cat1.physicsBody?.collisionBitMask = 0
                    cat1.physicsBody?.usesPreciseCollisionDetection = true
                    cat1.position = CGPointMake(CGRectGetMidX(self.frame)+xPos, yPos)
                    var moveBy = SKAction.moveByX(CGFloat(-self.zombieSpeed), y: 0, duration: 0.1)
                    cat1.runAction(SKAction.repeatActionForever(moveBy))
                    var moveToPrincess = SKAction.moveToY(self.princess1.position.y, duration: 1)
                    var sequence = SKAction.sequence([moveToPrincess, SKAction.runBlock({
                        cat1.texture = SKTexture(imageNamed: "catOpen.png")
                    }), SKAction.waitForDuration(1),SKAction.runBlock({
                        var hairball = SKSpriteNode(imageNamed: "hairball.png")
                        hairball.position = self.position
                        hairball.runAction(SKAction.repeatActionForever(SKAction.moveToX(-1000, duration: 2)))
                        hairball.name = "hairball"
                        hairball.physicsBody = SKPhysicsBody(circleOfRadius:hairball.size.width/2)
                        hairball.physicsBody?.dynamic = true
                        hairball.physicsBody?.categoryBitMask = self.enemyProjectileCatagory
                        hairball.physicsBody?.contactTestBitMask = self.princessCategory
                        hairball.physicsBody?.collisionBitMask = 0
                        hairball.physicsBody?.usesPreciseCollisionDetection = true
                        cat1.addChild(hairball)
                    }), SKAction.waitForDuration(1), SKAction.runBlock({
                        cat1.texture = SKTexture(imageNamed: "cat.png")
                    }), SKAction.waitForDuration(1),SKAction.runBlock({
                        NSLog("%f", self.princess1.position.y)
                    })])
                    cat1.runAction(SKAction.repeatActionForever(sequence))
                    self.zombies.addObject(cat1)
                }
                else
                {
                    var zombie1 = GenericZombie()
                    var yPos = CGFloat((arc4random()%150)+150)
                    var xPos = CGFloat((arc4random()%150)+150)
                    zombie1.health = self.wavesCompleted
                    zombie1.princess = self.childNodeWithName("princess") as! Princess
                    zombie1.position = CGPointMake(CGRectGetMidX(self.frame)+xPos, yPos)
                    zombie1.name = "zombie"
                    zombie1.physicsBody = SKPhysicsBody(circleOfRadius:zombie1.size.width/2)
                    zombie1.physicsBody?.dynamic = true
                    zombie1.physicsBody?.categoryBitMask = self.monsterCategory
                    zombie1.physicsBody?.contactTestBitMask = self.princessCategory
                    zombie1.physicsBody?.collisionBitMask = 0
                    zombie1.physicsBody?.usesPreciseCollisionDetection = true
                    var moveBy = SKAction.moveByX(CGFloat(-self.zombieSpeed), y: 0, duration: 0.1)
                    zombie1.runAction(SKAction.repeatActionForever(moveBy))
                    self.zombies.addObject(zombie1)
                }

            }
            else
            {
                var zombie1 = GenericZombie()
                var yPos = CGFloat((arc4random()%150)+150)
                var xPos = CGFloat((arc4random()%150)+150)
                zombie1.health = self.wavesCompleted
                zombie1.princess = self.childNodeWithName("princess") as! Princess
                zombie1.position = CGPointMake(CGRectGetMidX(self.frame)+xPos, yPos)
                zombie1.name = "zombie"
                zombie1.physicsBody = SKPhysicsBody(circleOfRadius:zombie1.size.width/2)
                zombie1.physicsBody?.dynamic = true
                zombie1.physicsBody?.categoryBitMask = self.monsterCategory
                zombie1.physicsBody?.contactTestBitMask = self.princessCategory
                zombie1.physicsBody?.collisionBitMask = 0
                zombie1.physicsBody?.usesPreciseCollisionDetection = true
                var moveBy = SKAction.moveByX(CGFloat(-self.zombieSpeed), y: 0, duration: 0.1)
                zombie1.runAction(SKAction.repeatActionForever(moveBy))
                self.zombies.addObject(zombie1)
            }
            zombiesSpawned++
        }
        
        for aZombie in self.zombies
        {
            self.addChild(aZombie as! SKNode)
        }
        
        self.gameIsRunning = true
        self.canPressButtons = false
    }
    
    func addBrush()
    {
        if self.brushInWorld == false
        {
            if self.infBrushItem == true
            {
                if self.brushesInWorld <= 3
                {
                    self.brushesInWorld++
                    
                    var brush = SKSpriteNode(imageNamed: "brush.png")
                    brush.name = "brush"
                    brush.position = CGPoint(x: self.princess1.position.x, y: self.princess1.position.y)
                    self.addChild(brush)
                    brush.runAction(SKAction.moveToX(1000, duration: 1))
                    brush.runAction(SKAction.waitForDuration(1))
                    brush.physicsBody = SKPhysicsBody(circleOfRadius:brush.size.width/2)
                    brush.physicsBody?.dynamic = true
                    brush.physicsBody?.categoryBitMask = self.brushCategory
                    brush.physicsBody?.contactTestBitMask = self.monsterCategory
                    brush.physicsBody?.collisionBitMask = 0
                    brush.physicsBody?.usesPreciseCollisionDetection = true
                    self.currentBrushes.addObject(brush)
                    var move = SKAction.moveToX(1000, duration: 1)
                    var vanish = SKAction.removeFromParent()
                    var removeBrush = SKAction.runBlock({
                        self.currentBrushes.removeObject(brush)
                    })
                    var sequence = SKAction.sequence([move, vanish, removeBrush])
                    brush.runAction(sequence)
                }
            }
            else
            {
                var brush = SKSpriteNode(imageNamed: "brush.png")
                brush.name = "brush"
                brush.position = CGPoint(x: self.princess1.position.x, y: self.princess1.position.y)
                self.addChild(brush)
                brush.runAction(SKAction.moveToX(1000, duration: 1))
                brush.runAction(SKAction.waitForDuration(1))
                brush.physicsBody = SKPhysicsBody(circleOfRadius:brush.size.width/2)
                brush.physicsBody?.dynamic = true
                brush.physicsBody?.categoryBitMask = self.brushCategory
                brush.physicsBody?.contactTestBitMask = self.monsterCategory
                brush.physicsBody?.collisionBitMask = 0
                brush.physicsBody?.usesPreciseCollisionDetection = true
                self.currentBrushes.addObject(brush)
                var move = SKAction.moveToX(1000, duration: 1)
                var vanish = SKAction.removeFromParent()
                var removeBrush = SKAction.runBlock({
                    self.currentBrushes.removeObject(brush)
                })
                var sequence = SKAction.sequence([move, vanish, removeBrush])
                brush.runAction(sequence)
            }
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact)
    {
        var firstBody = SKPhysicsBody()
        var secondBody = SKPhysicsBody()
        
        if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
        {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }
        else
        {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if ((firstBody.categoryBitMask & self.brushCategory) != 0 &&
            (secondBody.categoryBitMask & self.monsterCategory) != 0)
        {
            if firstBody.node != nil
            {
                self.projectileDidCollideWithMonster(firstBody.node!, monster: secondBody.node!)
            }
        }
        if ((firstBody.categoryBitMask & self.monsterCategory) != 0 &&
            (secondBody.categoryBitMask & self.princessCategory) != 0)
        {
            self.monsterDidCollideWithPrincess(firstBody.node!, princess1: secondBody.node!)
        }
        if ((secondBody.categoryBitMask & self.enemyProjectileCatagory) != 0 &&
        (firstBody.categoryBitMask & self.princessCategory) != 0)
        {
            self.enemyProjectileDidCollideWithPrincess(secondBody.node!, princess1: firstBody.node!)
        }
    }
    
    func projectileDidCollideWithMonster(projectile: SKNode, monster: SKNode)
    {
        projectile.removeFromParent()
        var monsterSK = monster as! GenericZombie
        monsterSK.health--
        var healthLostLabel = SKLabelNode(fontNamed: "TimesNewRoman")
        healthLostLabel.text = "-1"
        healthLostLabel.fontColor = SKColor.redColor()
        healthLostLabel.fontSize = 32
        if monster.name == "catZombie"
        {
            healthLostLabel.position = CGPoint(x: monster.position.x, y: monster.position.y+25)
        }
        if monster.name == "zombie"
        {
            healthLostLabel.position = CGPoint(x: monster.position.x, y: monster.position.y+75)
        }
        healthLostLabel.runAction(SKAction.moveToY(healthLostLabel.position.y+20, duration: 0.4))
        healthLostLabel.runAction(SKAction.sequence([SKAction.fadeOutWithDuration(0.4), SKAction.runBlock({
            healthLostLabel.removeFromParent()
        })]))
        self.addChild(healthLostLabel)
        var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if monsterSK.health < 1
        {
            if monsterSK.name == "catZombie"
            {
                if var zombieKills = defaults.objectForKey("catZombieKills") as? NSInteger
                {
                    zombieKills++
                    defaults.setObject(zombieKills, forKey: "catZombieKills")
                }
                else
                {
                    defaults.setObject(1, forKey: "catZombieKills")
                }
            }
            if monsterSK.name == "zombie"
            {
                if var zombieKills = defaults.objectForKey("zombieKills") as? NSInteger
                {
                    zombieKills++
                    defaults.setObject(zombieKills, forKey: "zombieKills")
                }
                else
                {
                    defaults.setObject(1, forKey: "zombieKills")
                }
            }
            var deadZombie = SKSpriteNode(imageNamed: "ash.png")
            deadZombie.name = "ash"
            deadZombie.position = monster.position
            monster.removeFromParent()
            self.zombies.removeObject(monster)
            self.zombies.addObject(deadZombie)
            self.addChild(deadZombie)
            
            let sparkEmmitterPath:NSString = NSBundle.mainBundle().pathForResource("Smoke", ofType: "sks")!
            
            let sparkEmmiter = NSKeyedUnarchiver.unarchiveObjectWithFile(sparkEmmitterPath as String) as! SKEmitterNode
            
            sparkEmmiter.position = CGPoint(x: 0, y: 0)
            sparkEmmiter.name = "sparkEmmitter"
            sparkEmmiter.zPosition = 1
            sparkEmmiter.targetNode = self
            sparkEmmiter.particleLifetime = 0.5
            sparkEmmiter.particleBirthRate = 5
            sparkEmmiter.numParticlesToEmit = 100
            
            deadZombie.addChild(sparkEmmiter)
            
            self.zombiesKilled++
            var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
            if var highScore = defaults.objectForKey("highScore") as? NSInteger
            {
                if self.zombiesKilled > highScore
                {
                    highScore++
                }
                
                defaults.setObject(highScore, forKey: "highScore")
                
                if let currentScoreCurrent = defaults.objectForKey("currentScore") as? NSInteger
                {
                    if currentScoreCurrent > highScore
                    {
                        gameViewController1?.submitScore(currentScoreCurrent)
                    }
                    else
                    {
                        gameViewController1?.submitScore(highScore)
                    }
                }
            }
        }
        self.coins++
        
        defaults.setObject(self.coins, forKey: "coins")
        
        self.saveData()
        
        if let currentScoreCurrent2 = defaults.objectForKey("currentScore") as? Double
        {
            if currentScoreCurrent2 <= 3
            {
                if self.achievementZombieFighter == false
                {
                    let progressDouble: Double = currentScoreCurrent2 / 0.03
                    self.gameViewController1?.gameCenterAddProgressToAnAchievement(progressDouble, achievementID: "zombieKill3")
                    if progressDouble >= 100
                    {
                        self.achievementZombieFighter = true
                    }
                }
            }
            if currentScoreCurrent2 <= 50
            {
                if self.achievementZombieSlayer == false
                {
                    let progressDouble2: Double = currentScoreCurrent2 / 0.5
                    self.gameViewController1?.gameCenterAddProgressToAnAchievement(progressDouble2, achievementID: "zombieKill50")
                    if progressDouble2 >= 100
                    {
                        self.achievementZombieSlayer = true
                    }
                }
            }
            if currentScoreCurrent2 <= 100
            {
                if self.achievementZombieHunter == false
                {
                    let progressDouble3: Double = currentScoreCurrent2 / 1
                    self.gameViewController1?.gameCenterAddProgressToAnAchievement(progressDouble3, achievementID: "zombieKill100")
                    if progressDouble3 >= 100
                    {
                        self.achievementZombieHunter = true
                    }
                }
            }
        }
    }
    
    func monsterDidCollideWithPrincess(monster: SKNode, princess1: SKNode)
    {
        self.princessHealth--
        self.healthLostInLastRound += 1.00
        
        var deadZombie = SKSpriteNode(imageNamed: "ash.png")
        deadZombie.name = "ash"
        deadZombie.position = monster.position
        monster.removeFromParent()
        self.zombies.removeObject(monster)
        self.zombies.addObject(deadZombie)
        self.addChild(deadZombie)
        
        if princessHealth <= 0
        {
            var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
            if monster.name == "zombie"
            {
                if var normalZombiesDied = defaults.objectForKey("zombiesDied") as? NSInteger
                {
                    defaults.setObject(normalZombiesDied++, forKey: "zombiesDied")
                }
                else
                {
                    defaults.setObject(1, forKey: "zombiesDied")
                }
            }
            if monster.name == "catZombie"
            {
                if var catZombiesDied = defaults.objectForKey("catZombiesDied") as? NSInteger
                {
                    defaults.setObject(catZombiesDied++, forKey: "catZombiesDied")
                }
                else
                {
                    defaults.setObject(1, forKey: "catZombiesDied")
                }
            }
            
            self.gameOver()
        }
    }
    
    func enemyProjectileDidCollideWithPrincess(enemyProjectile: SKNode, princess1: SKNode)
    {
        self.princessHealth -= 0.25
        self.healthLostInLastRound += 0.25
        var healthLostLabel = SKLabelNode(fontNamed: "TimesNewRoman")
        healthLostLabel.text = "-0.25"
        healthLostLabel.fontColor = SKColor.redColor()
        healthLostLabel.fontSize = 32
        healthLostLabel.position = CGPoint(x: princess1.position.x, y: princess1.position.y+100)
        healthLostLabel.runAction(SKAction.moveToY(healthLostLabel.position.y+20, duration: 0.4))
        healthLostLabel.runAction(SKAction.sequence([SKAction.fadeOutWithDuration(0.4), SKAction.runBlock({
            healthLostLabel.removeFromParent()
        })]))
        self.addChild(healthLostLabel)
        if princessHealth <= 0
        {
            var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
            
            if var catZombiesDied = defaults.objectForKey("catZombiesDied") as? NSInteger
            {
                defaults.setObject(catZombiesDied++, forKey: "catZombiesDied")
            }
            else
            {
                defaults.setObject(1, forKey: "catZombiesDied")
            }
            
            self.gameOver()
        }
        enemyProjectile.removeFromParent()
        NSLog("%f", self.princessHealth)
    }
    
    func setUpAudio()
    {
        if (backgroundMusicPlayer == nil) {
            let backgroundMusicURL = NSBundle.mainBundle().URLForResource(backgroundMusicSound, withExtension: nil)
            backgroundMusicPlayer = AVAudioPlayer(contentsOfURL: backgroundMusicURL, error:nil)
            backgroundMusicPlayer.numberOfLoops = -1
        }
    }
    
    func gameOver()
    {
        gameOverDidOccur = true
        
        var hide = SKAction.fadeOutWithDuration(0)
        var show = SKAction.fadeInWithDuration(0)
        var wait = SKAction.waitForDuration(1)
        var sequence = SKAction.sequence([hide, wait, show, wait, hide, wait, show, wait, hide, wait, show, wait, hide])
        self.princess1.runAction(SKAction.sequence([sequence, SKAction.runBlock({
            self.canPressButtons = true
            self.gameIsRunning = false
        })]))
        
        for aZombie in self.zombies
        {
            aZombie.removeFromParent()
        }
        
        self.zombies.removeAllObjects()
        
        var zombiesKilledLabel = SKLabelNode(fontNamed: "TimesNewRoman")
        zombiesKilledLabel.name = "zombiesKilledLabel"
        zombiesKilledLabel.fontColor = SKColor.redColor()
        zombiesKilledLabel.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        self.addChild(zombiesKilledLabel)
        
        var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        zombiesKilledLabel.text = NSString(format: "Zombies Killed: %i", self.zombiesKilled) as String
        
        if var currentScore = defaults.objectForKey("currentScore") as? NSInteger
        {
            defaults.setObject(0, forKey: "currentScore")
        }
        
        if var levels = defaults.objectForKey("levels") as? NSInteger
        {
            defaults.setObject(0, forKey: "levels")
            self.wavesCompleted = 0
        }
        
        defaults.setObject(1, forKey: "background")
        if let background2 = self.childNodeWithName("background2")
        {
            background2.removeFromParent()
        }
        if let background3 = self.childNodeWithName("background3")
        {
            background3.removeFromParent()
        }
        var background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        background.zPosition = -2
        background.name = "background"
        self.addChild(background)
        
        self.zombiesKilled = 0
        
        self.healthPack = false
        self.checkIsShowing2 = false
    }
    
    func settings()
    {
        self.windowIsOpen = true
        self.canPressButtons = false
        self.saveData()
        
        var settingsNode = SKNode()
        settingsNode.name = "settings"
        
        var backGround = SKShapeNode(circleOfRadius: 10)
        backGround.path = CGPathCreateWithRect(CGRectMake(32, 0, 960, 720), nil)
        backGround.fillColor = SKColor.grayColor()
        backGround.name = "bg"
        backGround.position = CGPoint(x: 0, y: 0)
        backGround.zPosition = 5
        settingsNode.addChild(backGround)
        
        self.zombiesToSpawnSlider?.hidden = false
        self.zombiesToSpawnSlider?.userInteractionEnabled = true
        
        self.joystickSwitch?.hidden = false
        self.joystickSwitch?.userInteractionEnabled = true
        
        self.zombieSpeedSlider?.hidden = false
        self.zombieSpeedSlider?.userInteractionEnabled = true
        
        var resetGameButton = SKButton(defaultButtonImage: "resetButton", activeButtonImage: "resetButtonPressed", buttonAction: resetGame)
        resetGameButton.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame)-200)
        resetGameButton.zPosition = 6
        settingsNode.addChild(resetGameButton)
        
        var saveGameButton = SKButton(defaultButtonImage: "saveButton", activeButtonImage: "saveButtonPressed", buttonAction: saveData)
        saveGameButton.position = CGPoint(x: CGRectGetMidX(self.frame)+200, y: CGRectGetMidY(self.frame)-200)
        saveGameButton.zPosition = 6
        settingsNode.addChild(saveGameButton)
        
        var menuButton = SKButton(defaultButtonImage: "menuButton", activeButtonImage: "menuButtonPressed", buttonAction: presentMenuScene)
        menuButton.position = CGPoint(x: CGRectGetMidX(self.frame)-200, y: CGRectGetMidY(self.frame)-200)
        menuButton.zPosition = 6
        settingsNode.addChild(menuButton)
        
        var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if let highScore = defaults.objectForKey("highScore") as? NSInteger
        {
            
            var highScoreLabel = SKLabelNode(fontNamed: "TimesNewRoman")
            highScoreLabel.fontColor = SKColor.orangeColor()
            highScoreLabel.name = "highScoreLabel"
            highScoreLabel.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame)+200)
            highScoreLabel.zPosition = 6
            settingsNode.addChild(highScoreLabel)
            
            highScoreLabel.text = NSString(format: "High Score: %i", highScore) as String
        }
        
        self.levelsCompletedLabel.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame)+100)
        self.levelsCompletedLabel.fontColor = SKColor.blueColor()
        self.levelsCompletedLabel.zPosition = 6
        
        if let levels = defaults.objectForKey("levels") as? NSInteger
        {
            self.levelsCompletedLabel.text = NSString(format: "Levels Completed: %i", levels) as String
        }
        else
        {
            self.levelsCompletedLabel.text = "Levels Completed: 0"
        }
        self.addChild(self.levelsCompletedLabel)
        
        var currentScoreLabel = SKLabelNode(fontNamed: "TimesNewRoman")
        currentScoreLabel.fontColor = SKColor.redColor()
        currentScoreLabel.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame)+150)
        currentScoreLabel.zPosition = 6
        currentScoreLabel.text = NSString(format: "Curent Score: %i", self.zombiesKilled) as String
        settingsNode.addChild(currentScoreLabel)
        
        var backbutton = addButton(CGPoint(x: 0, y: 0), type: "back", InMenu: "settings", WithAction: hideSettings, WithName: "backButton")
        settingsNode.addChild(backbutton)
        
        self.addChild(settingsNode)
    }
    
    func addButton(pos: CGPoint, type: NSString, InMenu: NSString, WithAction: () -> Void, WithName: NSString) -> SKButton
    {
        var posOverride = CGPoint(x: 0, y: 0)
        if type == "back" && InMenu != "default"
        {
            posOverride = CGPoint(x: CGRectGetMidX(self.frame)+400, y: CGRectGetMidX(self.frame)-140)
        }
        
        var button = SKButton(defaultButtonImage: WithName as String, activeButtonImage: WithName as String + "Pressed", buttonAction: WithAction)
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
    
    func resetGame()
    {
        var backGround2 = SKShapeNode(circleOfRadius: 10)
        backGround2.path = CGPathCreateWithRect(CGRectMake(CGRectGetMidX(self.frame)-300, CGRectGetMidY(self.frame)-200, 600, 400), nil)
        backGround2.fillColor = SKColor.grayColor()
        backGround2.name = "background2"
        backGround2.position = CGPoint(x: 0, y: 0)
        backGround2.zPosition = 10
        
        self.zombiesToSpawnSlider?.hidden = true
        self.zombiesToSpawnSlider?.userInteractionEnabled = false
        
        self.joystickSwitch?.hidden = true
        self.joystickSwitch?.userInteractionEnabled = false
        
        self.zombieSpeedSlider?.hidden = true
        self.zombieSpeedSlider?.userInteractionEnabled = false
        
        var textReset = SKLabelNode(fontNamed: "TimesNewRoman")
        textReset.fontColor = SKColor.redColor()
        textReset.fontSize = 64
        textReset.text = "Are you SURE"
        textReset.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame)+150)
        textReset.zPosition = 11
        backGround2.addChild(textReset)
        
        var textReset2 = SKLabelNode(fontNamed: "TimesNewRoman")
        textReset2.fontColor = SKColor.redColor()
        textReset2.fontSize = 64
        textReset2.text = "you want to reset?"
        textReset2.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame)+100)
        textReset2.zPosition = 11
        backGround2.addChild(textReset2)
        
        var resetButton = self.addButton(CGPoint(x: CGRectGetMidX(self.frame)+200, y: CGRectGetMidY(self.frame)), type: "default", InMenu: "settings", WithAction: resetYes, WithName: "resetButton")
        backGround2.addChild(resetButton)
        
        var backButton = self.addButton(CGPoint(x: CGRectGetMidX(self.frame)-200, y: CGRectGetMidY(self.frame)), type: "back", InMenu: "settings", WithAction: resetNo, WithName: "backButton")
        backGround2.addChild(backButton)
        
        self.addChild(backGround2)
    }
    
    func resetYes()
    {
        var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(0, forKey: "Tutorial")
        defaults.setObject(0, forKey: "highScore")
        defaults.setObject(0, forKey: "levels")
        defaults.setObject(0, forKey: "coins")
        defaults.setObject([false, false], forKey: "items")
        defaults.setObject(1, forKey: "background")
        defaults.setObject(1, forKey: "health")
        defaults.setObject(0, forKey: "healthLost")
        defaults.setObject(0, forKey: "currentScore")
        
        self.gameViewController1?.resetGameCenter()
                
        self.gameViewController1?.presentTitleScene()
    }
    
    func resetNo()
    {
        var background2 = self.childNodeWithName("background2")
        background2?.removeFromParent()
        
        self.zombiesToSpawnSlider?.hidden = false
        self.zombiesToSpawnSlider?.userInteractionEnabled = true
        
        self.joystickSwitch?.hidden = false
        self.joystickSwitch?.userInteractionEnabled = true
        
        self.zombieSpeedSlider?.hidden = false
        self.zombieSpeedSlider?.userInteractionEnabled = true
    }
    
    func presentMenuScene()
    {
        hideSettings()
        saveData()
        self.gameViewController1?.presentMenuScene()
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent)
    {
        if self.gameIsRunning == false
        {
            if let zombiesKilledLabel = self.childNodeWithName("zombiesKilledLabel")
            {
                zombiesKilledLabel.removeFromParent()
            }
            
            princess1.runAction(SKAction.fadeInWithDuration(0))
        }
        
        if self.gamePaused == true
        {
            self.resumeGame()
        }
    }
    
    func hideSettings()
    {
        self.windowIsOpen = false
        self.canPressButtons = true
        
        var settingsNode = self.childNodeWithName("settings")
        settingsNode?.hidden = true
        settingsNode?.removeFromParent()
        
        self.levelsCompletedLabel.removeFromParent()
        
        self.zombiesToSpawnSlider?.userInteractionEnabled = false
        self.zombiesToSpawnSlider?.hidden = true
        
        self.joystickSwitch?.hidden = true
        self.joystickSwitch?.userInteractionEnabled = false
        
        self.zombieSpeedSlider?.hidden = true
        self.zombieSpeedSlider?.userInteractionEnabled = false
        
        self.joystickCheck()
        
        self.savedOnOpeningWindow = false
    }
    
    func joystickCheck()
    {
        if self.joystickSwitch?.on == true
        {
            
            self.joystickBool = true
            //Adding Later
        }
        else
        {
            //self.joystick.removeFromParent()
            self.joystickBool = false
            //:-)
        }
    }
    
    func store()
    {
        self.windowIsOpen = true
        self.storeIsOpen = true
        self.canPressButtons = false
        
        var storeNode = SKNode()
        storeNode.name = "store"
        
        var backGround = SKShapeNode(circleOfRadius: 10)
        backGround.path = CGPathCreateWithRect(CGRectMake(32, 0, 960, 720), nil)
        backGround.fillColor = SKColor.grayColor()
        backGround.name = "bg"
        backGround.position = CGPoint(x: 0, y: 0)
        backGround.zPosition = 5
        storeNode.addChild(backGround)
        
        var backButton = SKButton(defaultButtonImage: "backButton", activeButtonImage: "backButtonPressed", buttonAction: hideStore)
        backButton.position = CGPoint(x: CGRectGetMidX(self.frame)+400, y: CGRectGetMidX(self.frame)-140)
        backButton.zPosition = 8
        storeNode.addChild(backButton)
        
        var leftScrollButton = SKButton(defaultButtonImage: "leftScrollButton", activeButtonImage: "leftScrollButtonPressed", buttonAction: leftScroll)
        leftScrollButton.position = CGPoint(x: CGRectGetMidX(self.frame)-300, y: backButton.position.y+200)
        leftScrollButton.zPosition = 8
        storeNode.addChild(leftScrollButton)
        
        var rightScrollButton = SKButton(defaultButtonImage: "rightScrollButton", activeButtonImage: "rightScrollButtonPressed", buttonAction: rightScroll)
        rightScrollButton.position = CGPoint(x: CGRectGetMidX(self.frame)+300, y: backButton.position.y+200)
        rightScrollButton.zPosition = 8
        storeNode.addChild(rightScrollButton)
        
        var products = SKNode()
        products.name = "products"
        
        var infiniteBrush = SKSpriteNode(imageNamed: "infiniteBrush")
        infiniteBrush.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        infiniteBrush.name = "infiniteBrush"
        infiniteBrush.zPosition = 7
        products.addChild(infiniteBrush)
            var infiniteBrushLabel = SKLabelNode(fontNamed: "TimesNewRoman")
            infiniteBrushLabel.text = "Infinite Brush"
            infiniteBrushLabel.fontSize = 64
            infiniteBrushLabel.fontColor = SKColor.redColor()
            infiniteBrushLabel.position = CGPoint(x: infiniteBrushLabel.position.x, y: infiniteBrushLabel.position.y+50)
            infiniteBrush.addChild(infiniteBrushLabel)
        var infiniteBrushBuyButton = SKButton(defaultButtonImage: "buyButton", activeButtonImage: "buyButtonPressed", buttonAction: buyItemInfBrush)
        infiniteBrushBuyButton.position = CGPoint(x: infiniteBrushBuyButton.position.x, y: infiniteBrushBuyButton.position.y-200)
        infiniteBrushBuyButton.name = "infBrushButton"
        infiniteBrush.addChild(infiniteBrushBuyButton)
            var coinsCost = SKLabelNode(fontNamed: "TimesNewRoman")
            coinsCost.text = "40"
            coinsCost.fontSize = 24
            coinsCost.fontColor = SKColor.orangeColor()
            coinsCost.position = CGPoint(x: infiniteBrushBuyButton.position.x-30, y: infiniteBrushBuyButton.position.y)
            coinsCost.zPosition = 8
            infiniteBrushBuyButton.addChild(coinsCost)
        
        self.storeButtons.addObject(infiniteBrushBuyButton)
        
        var healthPack = SKSpriteNode(imageNamed: "healthPack.png")
        healthPack.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        healthPack.name = "healthPack"
        healthPack.zPosition = 7
        products.addChild(healthPack)
        var HealthPackBuyButton = SKButton(defaultButtonImage: "buyButton", activeButtonImage: "buyButtonPressed", buttonAction: buyItemHealthPack)
        HealthPackBuyButton.position = CGPoint(x: HealthPackBuyButton.position.x, y: HealthPackBuyButton.position.y-200)
        HealthPackBuyButton.name = "HealthPackBuyButton"
        healthPack.addChild(HealthPackBuyButton)
        self.storeButtons.addObject(HealthPackBuyButton)
        
        var coinsCost2 = SKLabelNode(fontNamed: "TimesNewRoman")
        coinsCost2.text = "60"
        coinsCost2.fontSize = 24
        coinsCost2.fontColor = SKColor.orangeColor()
        coinsCost2.position = CGPoint(x: HealthPackBuyButton.position.x-30, y: HealthPackBuyButton.position.y)
        coinsCost2.zPosition = 8
        HealthPackBuyButton.addChild(coinsCost2)
        
        healthPack.hidden = true
        healthPack.userInteractionEnabled = false
        var button = healthPack.childNodeWithName("HealthPackBuyButton")
        button?.removeFromParent()
        
        var battery = SKSpriteNode(imageNamed: "battery")
        battery.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        battery.name = "battery"
        battery.zPosition = 7
        products.addChild(battery)
        
        battery.hidden = true
        battery.userInteractionEnabled = false
        
        storeNode.addChild(products)
        self.addChild(storeNode)
    }
    
    func buyItemInfBrush()
    {
        if self.coins > 39
        {
            self.coins-=40
            self.infBrushItem = true
            self.brushInWorld = false
        }
        
        let progressDouble: Double = 100
        self.gameViewController1?.gameCenterAddProgressToAnAchievement(progressDouble, achievementID: "buyItem")
    }
    
    func buyItemHealthPack()
    {
        if self.coins > 59
        {
            self.coins-=60
            self.healthPack = true
            self.princessHealth+=1
        }
        
        let progressDouble: Double = 100
        self.gameViewController1?.gameCenterAddProgressToAnAchievement(progressDouble, achievementID: "buyItem")
    }
    
    func leftScroll()
    {
        let store = self.childNodeWithName("store")
        let products = store?.childNodeWithName("products")
        let infiniteBrush = products?.childNodeWithName("infiniteBrush")
        let healthPack = products?.childNodeWithName("healthPack")
        let checkHealth = store?.childNodeWithName("checkHealth")
        let checkInf = store?.childNodeWithName("checkInf")
        var battery = products?.childNodeWithName("battery")
        
        if self.scrolled > 0
        {
            self.scrolled--
            
            if self.scrolled == 1
            {
                checkHealth?.hidden = false
                checkInf?.hidden = true
                infiniteBrush?.hidden = true
                infiniteBrush?.userInteractionEnabled = false
                healthPack?.hidden = false
                healthPack?.userInteractionEnabled = true
                battery?.hidden = true
                battery?.userInteractionEnabled = false
            }
            
            if self.scrolled == 0
            {
                checkHealth?.hidden = true
                checkInf?.hidden = false
                infiniteBrush?.hidden = false
                infiniteBrush?.userInteractionEnabled = true
                healthPack?.hidden = true
                healthPack?.userInteractionEnabled = false
                battery?.hidden = true
                battery?.userInteractionEnabled = false
                
                let button = healthPack?.childNodeWithName("HealthPackBuyButton")
                button?.removeFromParent()
            }
        }
    }
    
    func rightScroll()
    {
        var store = self.childNodeWithName("store")
        var products = store?.childNodeWithName("products")
        var infiniteBrush = products?.childNodeWithName("infiniteBrush")
        var healthPack = products?.childNodeWithName("healthPack")
        var battery = products?.childNodeWithName("battery")
        var checkHealth = store?.childNodeWithName("checkHealth")
        var checkInf = store?.childNodeWithName("checkInf")
        
        if self.scrolled < 2
        {
            self.scrolled++
            
            if self.scrolled == 1
            {
                checkHealth?.hidden = false
                checkInf?.hidden = true
                infiniteBrush?.hidden = true
                infiniteBrush?.userInteractionEnabled = false
                healthPack?.hidden = false
                healthPack?.userInteractionEnabled = true
                battery?.hidden = true
                battery?.userInteractionEnabled = false
                
                var HealthPackBuyButton = SKButton(defaultButtonImage: "buyButton", activeButtonImage: "buyButtonPressed", buttonAction: buyItemHealthPack)
                HealthPackBuyButton.position = CGPoint(x: HealthPackBuyButton.position.x, y: HealthPackBuyButton.position.y-200)
                HealthPackBuyButton.name = "HealthPackBuyButton"
                healthPack?.addChild(HealthPackBuyButton)
                
                var healthPackLabel = SKLabelNode(fontNamed: "TimesNewRoman")
                healthPackLabel.text = "Health Pack"
                healthPackLabel.fontSize = 64
                healthPackLabel.fontColor = SKColor.redColor()
                healthPackLabel.position = CGPoint(x: 0, y: 100)
                healthPack?.addChild(healthPackLabel)
            }
            
            if self.scrolled == 2
            {
                checkHealth?.hidden = true
                checkInf?.hidden = true
                infiniteBrush?.userInteractionEnabled = false
                infiniteBrush?.hidden = true
                healthPack?.userInteractionEnabled = false
                healthPack?.hidden = true
                
                battery?.userInteractionEnabled = true
                battery?.hidden = false
            }
        }
    }
    
    func hideStore()
    {
        var storeNode = self.childNodeWithName("store")
        storeNode?.hidden = true
        storeNode?.removeFromParent()
        
        self.scrolled = 0
        
        self.canPressButtons = true
        self.windowIsOpen = false
        self.storeIsOpen = false
        self.checkIsShowing = false
        self.checkIsShowing2 = false
        
        self.savedOnOpeningWindow = false
    }
    
    func showPetYard()
    {
        var petyard = SKNode()
        petyard.name = "petyard"
        
        var backGround = SKShapeNode(circleOfRadius: 10)
        backGround.path = CGPathCreateWithRect(CGRectMake(32, 0, 960, 720), nil)
        backGround.fillColor = SKColor.grayColor()
        backGround.name = "bg"
        backGround.position = CGPoint(x: 0, y: 0)
        backGround.zPosition = 5
        petyard.addChild(backGround)
        
        self.addChild(petyard)
    }
    
    func saveData()
    {
        var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        
        if let currentScore = defaults.objectForKey("currentScore") as? NSInteger
        {
            defaults.setObject(self.zombiesKilled, forKey: "currentScore")
        }
        
        defaults.setObject(self.wavesCompleted, forKey: "levels")
        
        var tempArray = NSMutableArray()
        
        if self.infBrushItem == true
        {
            tempArray[0] = true
        }
        else
        {
            tempArray[0] = false
        }
        
        if self.healthPack == true
        {
            tempArray[1] = true
        }
        else
        {
            tempArray[1] = false
        }
        
        if self.battery == true
        {
            tempArray[2] = true
            
            tempArray[3] = self.batteryPercent
        }
        else
        {
            tempArray[2] = false
        }
        defaults.setObject(tempArray, forKey: "items")
        
        defaults.setValue(self.princessHealth, forKey: "health")
        
        defaults.setObject(self.healthLostInLastRound, forKey: "healthLost")
        
        if let highScore = defaults.objectForKey("highScore") as? NSInteger
        {
            if let currentScoreCurrent = defaults.objectForKey("currentScore") as? NSInteger
            {
                if currentScoreCurrent > highScore
                {
                    gameViewController1?.submitScore(currentScoreCurrent)
                }
                else
                {
                    gameViewController1?.submitScore(highScore)
                }
            }
        }
    }
    
    func saveDataBackground()
    {
        if self.gameIsRunning == true
        {
            for aZombie in self.zombies
            {
                var aZombieSK = aZombie as! SKSpriteNode
                aZombieSK.removeAllActions()
            }
            
            var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
            
            let zombieData = NSKeyedArchiver.archivedDataWithRootObject(self.zombies)
            defaults.setObject(zombieData, forKey: "zombies")
            
            defaults.setBool(true, forKey: "didComeBackFromBackground")
        }
        self.saveData()
    }
    
    func didEnterFromBackground()
    {
        var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        
        if let didComeBackFromBackground = defaults.objectForKey("didComeBackFromBackground") as? Bool
        {
            if didComeBackFromBackground == true
            {
                defaults.setObject(false, forKey: "didComeBackFromBackground")
                
                self.gameIsRunning = true
                self.canPressButtons = false
                
                for aZombie in self.zombies
                {
                    aZombie.removeFromParent()
                }
                self.zombies.removeAllObjects()
                
                if let zombiesData = defaults.objectForKey("zombies") as? NSData
                {
                    let zombiesUnarchived = NSKeyedUnarchiver.unarchiveObjectWithData(zombiesData) as! NSMutableArray
                    self.zombies = zombiesUnarchived
                    
                    for aZombie in zombies
                    {
                        var aZombieSK = aZombie as! SKSpriteNode
                        self.addChild(aZombieSK)
                    }
                }
                
                if self.gamePaused != true
                {
                    self.pauseGame()
                }
            }
        }
    }
    
    func pauseGame()
    {
        for aZombie in self.zombies
        {
            var aZombieSK = aZombie as! SKSpriteNode
            aZombieSK.removeAllActions()
        }
        
        if let pauseButton = self.childNodeWithName("pauseButton")
        {
            pauseButton.hidden = true
            pauseButton.userInteractionEnabled = false
        }
        
        if let fireButton = self.childNodeWithName("fire")
        {
            fireButton.userInteractionEnabled = false
        }
        
        for aBrush in self.currentBrushes
        {
            var aBrushSK = aBrush as! SKSpriteNode
            aBrushSK.removeAllActions()
        }
        
        for aZombie in self.zombies
        {
            if aZombie.name == "catZombie"
            {
                if let hairball = aZombie.childNodeWithName("hairball")
                {
                    hairball.removeFromParent()
                }
            }
        }
        
        self.joystick.userInteractionEnabled = false
        
        var resumeButton = SKSpriteNode(imageNamed: "resume")
        resumeButton.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        resumeButton.name = "resumeButton"
        self.addChild(resumeButton)
        
        self.gamePaused = true
        
        saveData()
    }
    
    func resumeGame()
    {
        for aZombie in self.zombies
        {
            if aZombie as! SKSpriteNode != self.childNodeWithName("ash")
            {
                var aZombieSK = aZombie as! SKSpriteNode
                aZombieSK.runAction(SKAction.repeatActionForever(SKAction.moveByX(CGFloat(-self.zombieSpeed), y: 0, duration: 0.1)))
                if aZombie.name == "catZombie"
                {
                    var sequence = SKAction.sequence([SKAction.runBlock({
                        var hairball = SKSpriteNode(imageNamed: "hairball")
                        hairball.position = self.position
                        hairball.runAction(SKAction.repeatActionForever(SKAction.moveToX(-1000, duration: 2)))
                        hairball.name = "hairball"
                        hairball.physicsBody = SKPhysicsBody(circleOfRadius:hairball.size.width/2)
                        hairball.physicsBody?.dynamic = true
                        hairball.physicsBody?.categoryBitMask = self.enemyProjectileCatagory
                        hairball.physicsBody?.contactTestBitMask = self.princessCategory
                        hairball.physicsBody?.collisionBitMask = 0
                        hairball.physicsBody?.usesPreciseCollisionDetection = true
                        aZombieSK.addChild(hairball)
                    }), SKAction.waitForDuration(2), SKAction.runBlock({
                        NSLog("%f", self.princessHealth)
                    })])
                    aZombieSK.runAction(SKAction.waitForDuration(0.5))
                    aZombieSK.runAction(SKAction.repeatActionForever(sequence))
                }
            }
        }
        
        for aBrush in self.currentBrushes
        {
            var aBrushSK = aBrush as! SKSpriteNode
            var move = SKAction.moveToX(1000, duration: 1)
            var vanish = SKAction.removeFromParent()
            var removeBrush = SKAction.runBlock({
                self.currentBrushes.removeObject(aBrushSK)
            })
            var sequence = SKAction.sequence([move, vanish, removeBrush])
            aBrushSK.runAction(sequence)
        }
        
        self.joystick.userInteractionEnabled = true
        
        if let fireButton = self.childNodeWithName("fire")
        {
            fireButton.userInteractionEnabled = true
        }
        
        if let pauseButton = self.childNodeWithName("pauseButton")
        {
            pauseButton.hidden = false
            pauseButton.userInteractionEnabled = true
        }
        
        if let resumeButton = self.childNodeWithName("resumeButton")
        {
            resumeButton.removeFromParent()
        }
        
        self.gamePaused = false
    }
    
    override func update(currentTime: NSTimeInterval)
    {
        var position1 = CGPoint(x: princess1.position.x, y: princess1.position.y+CGFloat(joystick.y*4))
        self.princess1.position = position1
        
        if windowIsOpen == false
        {
            if self.canPressButtons == true
            {
                if (self.buttons.hidden == true)
                {
                    self.buttons.hidden = false
                    for aButton in self.buttons.children
                    {
                        let aButtonSK = aButton as! SKNode
                        aButtonSK.userInteractionEnabled = true
                    }
                }
            }
            else
            {
                if (self.buttons.hidden == false)
                {
                    self.buttons.hidden = true
                    for aButton in self.buttons.children
                    {
                        let aButtonSK = aButton as! SKNode
                        aButtonSK.userInteractionEnabled = false
                    }
                }
            }
            
            var healthLabelOLD = self.childNodeWithName("healthLabel")
            if healthLabelOLD != nil
            {
                var healthLabelSK = healthLabelOLD as! SKLabelNode
                healthLabelSK.text = NSString(format: "Health: %.2f", self.princessHealth) as String
                healthLabelSK.zPosition = 10
            }
            else
            {
                var healthLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
                healthLabel.fontSize = 48
                healthLabel.fontColor = SKColor.redColor()
                healthLabel.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame)-250)
                healthLabel.text = NSString(format: "Health: %f", self.princessHealth) as String
                healthLabel.name = "healthLabel"
                healthLabel.zPosition = 10
                self.addChild(healthLabel)
            }
        }
        else
        {
            var healthLabel = self.childNodeWithName("healthLabel")
            healthLabel?.zPosition = 0
            
            var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
            
            var tempArray = NSMutableArray()
            
            if self.infBrushItem == true
            {
                tempArray[0] = true
            }
            else
            {
                tempArray[0] = false
            }
            
            if self.healthPack  == true
            {
                tempArray[1] = true
            }
            else
            {
                tempArray[1] = false
            }
            
            if self.battery == true
            {
                tempArray[2] = true
                
                tempArray[3] = self.batteryPercent
            }
            else
            {
                tempArray[2] = false
            }
            
            defaults.setObject(tempArray, forKey: "items")
            
            if self.storeIsOpen == true
            {
                if self.infBrushItem == true
                {
                    var store = self.childNodeWithName("store")
                    var products = store?.childNodeWithName("products")
                    var infiniteBrush = products?.childNodeWithName("infiniteBrush")
                    var aButton = infiniteBrush?.childNodeWithName("infBrushButton")
                    aButton?.removeFromParent()
                    
                    if self.checkIsShowing == false
                    {
                        var infBrushCheck = SKSpriteNode(imageNamed: "check.png")
                        infBrushCheck.zPosition = 8
                        infBrushCheck.name = "checkInf"
                        infBrushCheck.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
                        var storeNode = self.childNodeWithName("store")
                        storeNode?.addChild(infBrushCheck)
                        self.checkIsShowing = true
                    }
                }
                if self.healthPack == true
                {
                    var store = self.childNodeWithName("store")
                    var products = store?.childNodeWithName("products")
                    var healthPack = products?.childNodeWithName("healthPack")
                    var aButton = healthPack?.childNodeWithName("HealthPackBuyButton")
                    aButton?.removeFromParent()
                    
                    if self.checkIsShowing2 == false
                    {
                        var healthPackCheck = SKSpriteNode(imageNamed: "check.png")
                        healthPackCheck.zPosition = 8
                        healthPackCheck.name = "checkHealth"
                        healthPackCheck.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
                        var storeNode = self.childNodeWithName("store")
                        storeNode?.addChild(healthPackCheck)
                        self.checkIsShowing2 = true
                    }
                }
                if self.battery == true
                {
                    var store = self.childNodeWithName("store")
                    var products = store?.childNodeWithName("products")
                    var healthPack = products?.childNodeWithName("battery")
                    var aButton = healthPack?.childNodeWithName("BatteryPackBuyButton")
                    aButton?.removeFromParent()
                    
                    if self.checkIsShowing3 == false
                    {
                        var batteryCheck = SKSpriteNode(imageNamed: "check.png")
                        batteryCheck.zPosition = 8
                        batteryCheck.name = "checkBattery"
                        batteryCheck.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
                        var storeNode = self.childNodeWithName("store")
                        storeNode?.addChild(batteryCheck)
                        self.checkIsShowing3 = true
                    }
                }
            }
            else
            {
                if let settingsNode = self.childNodeWithName("settings")
                {
                    //Nothing Here :-)
                }
            }
            
            self.savedOnOpeningWindow = true
        }
        
        if gameIsRunning == true
        {
            for aZombie2 in self.zombies
            {
                let aZombie2SK = aZombie2 as! SKSpriteNode
                let range = NSRange(location: 0, length: 50)
                var gameOverRange = NSLocationInRange(Int(aZombie2SK.position.x), range)
                if gameOverRange
                {
                    self.healthLostInLastRound += princessHealth
                    self.princessHealth = 0.0
                    self.gameOver()
                    break
                }
            }
            
            var zombiesAlive = 0
            for aZombie in self.zombies
            {
                if aZombie.name == "zombie"
                {
                    zombiesAlive++
                }
                if aZombie.name == "catZombie"
                {
                    zombiesAlive++
                }
            }
            
            if zombiesAlive == 0
            {
                backgroundMusicPlayer.pause()
                
                if self.coins <= 100
                {
                    if let coinsImage = self.coinsLabel.childNodeWithName("coinsImage")
                    {
                        if self.movedCoinsImage == false
                        {
                            coinsImage.position.x = coinsImage.position.x-20
                            self.movedCoinsImage = true
                        }
                    }
                }
                
                self.wavesCompleted++
                self.gameIsRunning = false
                
                if let pauseButton = self.childNodeWithName("pauseButton")
                {
                    pauseButton.hidden = true
                    pauseButton.userInteractionEnabled = false
                }
                
                for innerZombie in self.zombies
                {
                    self.zombies.removeObject(innerZombie)
                    innerZombie.removeFromParent()
                    
                }
                
                var range = NSRange(location: 15, length: 14)
                var range2 = NSRange(location: 30, length: 14)
                var range3 = NSRange(location: 45, length: 14)
                var background2Bool = NSLocationInRange(self.wavesCompleted, range)
                if background2Bool
                {
                    var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
                    defaults.setObject(2, forKey: "background")
                    if let background = self.childNodeWithName("background")
                    {
                        background.removeFromParent()
                    }
                    var background2 = SKSpriteNode(imageNamed: "background2")
                    background2.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
                    background2.zPosition = -2
                    background2.name = "background"
                    self.addChild(background2)
                }
                
                var background3Bool = NSLocationInRange(self.wavesCompleted, range2)
                if background3Bool
                {
                    var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
                    defaults.setObject(3, forKey: "background")
                    if let background = self.childNodeWithName("background")
                    {
                        background.removeFromParent()
                    }
                    var background3 = SKSpriteNode(imageNamed: "background3")
                    background3.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
                    background3.zPosition = -2
                    background3.name = "background"
                    self.addChild(background3)
                }
                
                var background4Bool = NSLocationInRange(self.wavesCompleted, range3)
                if background4Bool
                {
                    var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
                    defaults.setObject(4, forKey: "background")
                    if let background = self.childNodeWithName("background")
                    {
                        background.removeFromParent()
                    }
                    var background3 = SKSpriteNode(imageNamed: "background4")
                    background3.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
                    background3.zPosition = -2
                    background3.name = "background"
                    self.addChild(background3)
                }
                
                if self.princessHealth != 0
                {
                    self.canPressButtons = true
                }
                
                self.saveData()
            }
        }
        
        if gameIsRunning == false
        {
            if self.princessHealth <= 0
            {
                self.princessHealth = 1
            }
        }
        
        self.coinsLabel.text = NSString(format: "%i", self.coins) as String
        
        if self.infBrushItem == false
        {
            var brush = self.childNodeWithName("brush")
            if brush != nil
            {
                self.brushInWorld = true
            }
            else
            {
                self.brushInWorld = false
            }
        }
    }
}