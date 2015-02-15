//
//  GameScene.swift
//  PrVZ Dev
//
//  Created by jackson on 10/1/14.
//  Copyright (c) 2014 jackson. All rights reserved.
//

import Foundation
import Spritekit
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
    var buttons = SKNode()
    var brushInWorld = false
    var windowIsOpen = false
    var zombiesKilled = 0
    var coins = 0
    var coinsLabel = SKLabelNode(fontNamed: "TimesNewRoman")
    var zombiesToSpawnSlider: UISlider?
    var moreButtonsSwitch: UISwitch?
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
        
        if let itemsBoughtInStore = defaults.objectForKey("items") as? NSArray
        {
            if itemsBoughtInStore[0] as Bool == true
            {
                self.infBrushItem = true
            }
            if itemsBoughtInStore[1] as Bool == true
            {
                self.healthPack = true
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
        
        var mapButton = SKButton(defaultButtonImage: "mapButton", activeButtonImage: "mapButtonPressed", buttonAction: showMap)
        mapButton.position = CGPoint(x: CGRectGetMidX(self.frame)-300, y: CGRectGetMidY(self.frame)+50)
        mapButton.name = "mapButton"
        self.buttons.addChild(mapButton)
        mapButton.hidden = true
        mapButton.userInteractionEnabled = false
        
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
        
        self.moreButtonsSwitch?.hidden = true
        self.moreButtonsSwitch?.userInteractionEnabled = false
        
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
                defaults.setObject(0, forKey: "didComeBackFromBackground")
                self.gameIsRunning = true
                self.canPressButtons = false
                if let zombiesData = defaults.objectForKey("zombies") as? NSData
                {
                    let zombiesUnarchived = NSKeyedUnarchiver.unarchiveObjectWithData(zombiesData) as NSMutableArray
                    self.zombies = zombiesUnarchived
                    
                    for aZombie in zombies
                    {
                        var aZombieSK = aZombie as SKSpriteNode
                        self.addChild(aZombieSK)
                    }
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
        
        if let zombiesKilledLabel = self.childNodeWithName("zombiesKilledLabel")
        {
            zombiesKilledLabel.removeFromParent()
        }
        
        if self.zombieSpeedSlider == 1
        {
            var speedDivider = self.wavesCompleted / 4
            if speedDivider >= 1
            {
                self.zombieSpeed = CGFloat(arc4random()%2)
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
                    zombie1.princess = self.childNodeWithName("princess") as Princess
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
                zombie1.princess = self.childNodeWithName("princess") as Princess
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
            self.addChild(aZombie as SKNode)
        }
        
        self.gameIsRunning = true
        self.canPressButtons = false
    }
    
    func addBrush()
    {
        if self.brushInWorld == false
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
        var monsterSK = monster as GenericZombie
        monsterSK.health--
        var healthLostLabel = SKLabelNode(fontNamed: "TimesNewRoman")
        healthLostLabel.text = "-1"
        healthLostLabel.fontColor = SKColor.redColor()
        healthLostLabel.fontSize = 32
        if monster.name == "catZombie"
        {
            healthLostLabel.position = CGPoint(x: monster.position.x, y: monster.position.y+25)
        }
        else
        {
            healthLostLabel.position = CGPoint(x: monster.position.x, y: monster.position.y+75)
        }
        healthLostLabel.runAction(SKAction.moveToY(healthLostLabel.position.y+20, duration: 0.4))
        healthLostLabel.runAction(SKAction.sequence([SKAction.fadeOutWithDuration(0.4), SKAction.runBlock({
            healthLostLabel.removeFromParent()
        })]))
        self.addChild(healthLostLabel)
        if monsterSK.health < 1
        {
            var deadZombie = SKSpriteNode(imageNamed: "ash.png")
            deadZombie.name = "ash"
            deadZombie.position = monster.position
            monster.removeFromParent()
            self.zombies.removeObject(monster)
            self.zombies.addObject(deadZombie)
            self.addChild(deadZombie)
            
            self.zombiesKilled++
            var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
            if var highScore = defaults.objectForKey("highScore") as? NSInteger
            {
                if self.zombiesKilled > highScore
                {
                    highScore++
                }
                
                defaults.setObject(highScore, forKey: "highScore")
            }
        }
        self.coins++
        
        var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(self.coins, forKey: "coins")
    }
    
    func monsterDidCollideWithPrincess(monster: SKNode, princess1: SKNode)
    {
        self.princessHealth--
        self.healthLostInLastRound += 1.00
        if princessHealth <= 0
        {
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
        zombiesKilledLabel.text = NSString(format: "Zombies Killed: %i", self.zombiesKilled)
        
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
        
        self.moreButtonsSwitch?.hidden = false
        self.moreButtonsSwitch?.userInteractionEnabled = true
        
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
            
            highScoreLabel.text = NSString(format: "High Score: %i", highScore)
        }
        
        self.levelsCompletedLabel.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame)+100)
        self.levelsCompletedLabel.fontColor = SKColor.blueColor()
        self.levelsCompletedLabel.zPosition = 6
        
        if let levels = defaults.objectForKey("levels") as? NSInteger
        {
            self.levelsCompletedLabel.text = NSString(format: "Levels Completed: %i", levels)
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
        
        currentScoreLabel.text = NSString(format: "Curent Score: %i", self.zombiesKilled)
        
        settingsNode.addChild(currentScoreLabel)
        
        self.addChild(settingsNode)
    }
    
    func resetGame()
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
        
        self.gameViewController1?.presentTitleScene()
    }
    
    func presentMenuScene()
    {
        hideSettings()
        saveData()
        self.gameViewController1?.presentMenuScene()
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent)
    {
        var map = self.childNodeWithName("map")
        if map != nil
        {
            self.hideMap()
        }
        
        var settingsNode = self.childNodeWithName("settings")
        if settingsNode != nil
        {
            self.hideSettings()
        }
        
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
        
        self.moreButtonsSwitch?.hidden = true
        self.moreButtonsSwitch?.userInteractionEnabled = false
        
        self.zombieSpeedSlider?.hidden = true
        self.zombieSpeedSlider?.userInteractionEnabled = false
        
        if moreButtonsSwitch?.on == true
        {
            self.extraButtons(0)
        }
        else
        {
            self.extraButtons(1)
        }
    }
    
    func extraButtons(buttons: NSInteger)
    {
        var petyard = self.buttons.childNodeWithName("petyard")
        var mapButton = self.buttons.childNodeWithName("mapButton")
        
        if buttons == 0
        {
            petyard?.hidden = true
            petyard?.userInteractionEnabled = false
            mapButton?.hidden = true
            mapButton?.userInteractionEnabled = false
        }
        else
        {
            petyard?.hidden = false
            petyard?.userInteractionEnabled = true
            mapButton?.hidden = false
            mapButton?.userInteractionEnabled = true
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
        if self.coins > 19
        {
            self.coins-=20
            self.infBrushItem = true
            self.brushInWorld = false
        }
    }
    
    func buyItemHealthPack()
    {
        if self.coins > 49
        {
            self.coins-=50
            self.healthPack = true
            self.princessHealth+=1
        }
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
    }
    
    func showMap()
    {
        var map = SKSpriteNode(imageNamed: "map1.png")
        map.zPosition = 10
        map.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        map.name = "map"
        var circle = CGRectMake(100.0, 100.0, 80.0, 80.0)
        var progress = SKShapeNode()
        /*progress.path = UIBezierPath(ovalInRect: circle).CGPath
        progress.fillColor = SKColor.redColor()
        progress.lineWidth = 5
        progress.zPosition = 11
        var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if let background = defaults.objectForKey("background") as? NSInteger
        {
            if background == 1
            {
                progress.position = CGPoint(x: CGRectGetMidX(self.frame)-920, y: CGRectGetMidY(self.frame)-670)
            }
            if background == 2
            {
                progress.position = CGPoint(x: CGRectGetMidX(self.frame)-920, y: CGRectGetMidY(self.frame)-100)
            }
        }
        map.addChild(progress)*/
        //Will add later
        self.addChild(map)
        
        self.windowIsOpen = true
        self.canPressButtons = false
    }
    
    func hideMap()
    {
        var map = self.childNodeWithName("map")
        map?.removeFromParent()
        
        self.windowIsOpen = false
        self.canPressButtons = true
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
        defaults.setObject(tempArray, forKey: "items")
        
        defaults.setValue(self.princessHealth, forKey: "health")
        
        defaults.setObject(self.healthLostInLastRound, forKey: "healthLost")
    }
    
    func saveDataBackground()
    {
        if self.gameIsRunning == true
        {
            for aZombie in self.zombies
            {
                var aZombieSK = aZombie as SKSpriteNode
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
                    let zombiesUnarchived = NSKeyedUnarchiver.unarchiveObjectWithData(zombiesData) as NSMutableArray
                    self.zombies = zombiesUnarchived
                    
                    for aZombie in zombies
                    {
                        var aZombieSK = aZombie as SKSpriteNode
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
            var aZombieSK = aZombie as SKSpriteNode
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
            var aBrushSK = aBrush as SKSpriteNode
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
            if aZombie as SKSpriteNode != self.childNodeWithName("ash")
            {
                var aZombieSK = aZombie as SKSpriteNode
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
            var aBrushSK = aBrush as SKSpriteNode
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
        for aZombie2 in self.zombies
        {
            let aZombie2SK = aZombie2 as SKSpriteNode
            let range = NSRange(location: 0, length: 50)
            var gameOverRange = NSLocationInRange(Int(aZombie2SK.position.x), range)
            if gameOverRange
            {
                self.healthLostInLastRound += princessHealth
                self.princessHealth = 0.0
                self.gameOver()
            }
        }
        
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
                        let aButtonSK = aButton as SKNode
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
                        let aButtonSK = aButton as SKNode
                        aButtonSK.userInteractionEnabled = false
                    }
                }
            }
            
            var healthLabelOLD = self.childNodeWithName("healthLabel")
            if healthLabelOLD != nil
            {
                var healthLabelSK = healthLabelOLD as SKLabelNode
                healthLabelSK.text = NSString(format: "Health: %.2f", self.princessHealth)
                healthLabelSK.zPosition = 10
            }
            else
            {
                var healthLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
                healthLabel.fontSize = 48
                healthLabel.fontColor = SKColor.redColor()
                healthLabel.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame)-250)
                healthLabel.text = NSString(format: "Health: %f", self.princessHealth)
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
                    
                }
            }
        }
        
        if gameIsRunning == true
        {
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
                var range = NSRange(location: 4, length: 2)
                var range2 = NSRange(location: 7, length: 9999999999)
                var background2Bool = NSLocationInRange(wavesCompleted, range)
                if background2Bool
                {
                    var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
                    defaults.setObject(2, forKey: "background")
                    if let background = self.childNodeWithName("background")
                    {
                        background.removeFromParent()
                    }
                    if let background3 = self.childNodeWithName("background3")
                    {
                        background3.removeFromParent()
                    }
                    var background2 = SKSpriteNode(imageNamed: "background2")
                    background2.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
                    background2.zPosition = -2
                    background2.name = "background"
                    self.addChild(background2)
                }
                
                var background3Bool = NSLocationInRange(wavesCompleted, range2)
                if background3Bool
                {
                    var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
                    defaults.setObject(3, forKey: "background")
                    if let background2 = self.childNodeWithName("background2")
                    {
                        background2.removeFromParent()
                    }
                    if let background2 = self.childNodeWithName("background2")
                    {
                        background2.removeFromParent()
                    }
                    var background3 = SKSpriteNode(imageNamed: "background3")
                    background3.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
                    background3.zPosition = -2
                    background3.name = "background"
                    self.addChild(background3)
                }
                
                if self.princessHealth != 0
                {
                    canPressButtons = true
                }
                
                self.saveData()
            }
        }
        
        self.coinsLabel.text = NSString(format: "%i", self.coins)
        
        if self.infBrushItem == false
        {
            var brush = self.childNodeWithName("brush")
            if brush != nil
            {
                self.brushInWorld = true
            }else{
                self.brushInWorld = false
            }
        }
    }
}