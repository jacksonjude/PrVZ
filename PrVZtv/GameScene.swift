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
import GameController

private var backgroundMusicPlayer: AVAudioPlayer!

class GameScene: SKScene, SKPhysicsContactDelegate
{
    let brushCategory: UInt32 =           1 << 0
    let monsterCategory: UInt32 =         1 << 1
    let princessCategory: UInt32 =        1 << 2
    let enemyProjectileCatagory: UInt32 = 1 << 3
    
    var princess1 = Princess()
    var princessHealth = Float()
    var zombies = Array<GenericZombie>()
    var gameIsRunning = false
    var canPressButtons = true
    var zombieSpeed: CGFloat = 1.0
    var joystickBool = true
    var buttons = SKNode()
    var brushInWorld = false
    var windowIsOpen = false
    var zombiesKilled = 0
    var coins = 0
    var coinsLabel = SKLabelNode(fontNamed: "TimesNewRoman")
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
    var justBoughtHealthPack = false
    var pets = NSMutableDictionary()
    var controller = GCController()
    var toggleTilt = false
    
    deinit
    {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func didMoveToView(view: SKView)
    {
        let keyStore = NSUbiquitousKeyValueStore.defaultStore()
        let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(1, forKey: "Tutorial")
        
        if let backgroundNumber = defaults.objectForKey("background") as? NSInteger
        {
            if backgroundNumber == 1
            {
                let background = SKSpriteNode(imageNamed: "backgroundg.png")
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
            let background = SKSpriteNode(imageNamed: "backgroundg.png")
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
                        if let percent = itemsBoughtInStore[3] as? Double
                        {
                            self.batteryPercent = percent
                        }
                    }
                }
            }
        }
        
        var restoreData = Bool()
        
        if let user = keyStore.dictionaryForKey("playerData")
        {
            let userDictionary = user as NSDictionary
            let userId = userDictionary.objectForKey("uuid") as? String
            if let installed = defaults.objectForKey("idInstalled") as? String
            {
                if userId != installed
                {
                    restoreData = true
                    NSLog("installed: %@", installed)
                    NSLog("userID: %@", userId!)
                }
                else
                {
                    restoreData = false
                    NSLog("userID: %@", userId!)
                    NSLog("installed: %@", installed)
                }
            }
            else
            {
                restoreData = true
            }
        }
        else
        {
            let userDictionary = NSMutableDictionary()
            let uuid = NSUUID().UUIDString
            userDictionary.setObject(uuid, forKey: "uuid")
            keyStore.setObject(userDictionary, forKey: "playerData")
            keyStore.synchronize()
            print("Added User")
            defaults.setValue(uuid, forKey: "idInstalled")
        }
        
        if restoreData == true
        {
            let alert = UIAlertController(title: "Save Found!", message: "App has found a save on this iCloud account. Would you like to restore it?", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: { (alertAction) -> Void in
                print("Restoring")
            }))
            gameViewController1!.presentViewController(alert, animated: true, completion: nil)
        }
        
        physicsWorld.gravity = CGVectorMake(0,0)
        self.physicsWorld.contactDelegate = self
        
        let wallEnd = SKShapeNode()
        let path = CGPathCreateMutable()
        CGPathAddRect(path, nil, CGRectMake(0, 0, 60, 3000))
        wallEnd.path = path
        wallEnd.fillColor = SKColor.grayColor()
        wallEnd.position = CGPoint(x: CGRectGetMidX(self.frame)-450, y: CGRectGetMidY(self.frame)-400)
        wallEnd.name = "wallEnd"
        self.addChild(wallEnd)
        
        self.princess1.position = CGPoint(x: CGRectGetMidX(self.frame)-300, y: CGRectGetMidY(self.frame))
        self.princess1.name = "princess"
        self.princess1.physicsBody = SKPhysicsBody(circleOfRadius:princess1.size.width/2)
        self.princess1.physicsBody?.dynamic = true
        self.princess1.physicsBody?.categoryBitMask = self.princessCategory
        self.princess1.physicsBody?.contactTestBitMask = self.monsterCategory
        self.princess1.physicsBody?.collisionBitMask = 0
        self.princess1.physicsBody?.usesPreciseCollisionDetection = true
        self.addChild(self.princess1)
        
        GCController.startWirelessControllerDiscoveryWithCompletionHandler { () -> Void in
            NSLog("Done with wireless discovery")
        }
        
        /*let bar = SKShapeNode()
        bar.path = CGPathCreateWithRect(CGRectMake(32, 0, 960, 235), nil)
        bar.fillColor = SKColor.grayColor()
        bar.name = "bar"
        bar.position = CGPoint(x: 0, y: CGRectGetMidY(self.frame)+125)
        bar.zPosition = -1
        self.addChild(bar)*/
        
        self.coinsLabel.position = CGPoint(x: CGRectGetMidX(self.frame)+300, y: CGRectGetMidY(self.frame)+90)
        self.coinsLabel.fontColor = SKColor.redColor()
        self.addChild(self.coinsLabel)
        let coinsImage = SKSpriteNode(imageNamed: "coin.png")
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
        else
        {
            defaults.setObject(0, forKey: "currentScore")
        }
        
        if let highScore = defaults.objectForKey("highScore") as? NSInteger
        {
            if let user = keyStore.dictionaryForKey("playerData")
            {
                let userDictionary = user as NSDictionary
                let userDictionaryMutable = userDictionary.mutableCopy() as! NSMutableDictionary
                userDictionaryMutable.setObject(highScore, forKey: "highScore")
                keyStore.setObject(userDictionaryMutable, forKey: "playerData")
                keyStore.synchronize()
            }
        }
        else
        {
            defaults.setObject(0, forKey: "highScore")
            
            if let user = keyStore.dictionaryForKey("playerData")
            {
                let userDictionary = user as NSDictionary
                let userDictionaryMutable = userDictionary.mutableCopy() as! NSMutableDictionary
                userDictionaryMutable.setObject(0, forKey: "highScore")
                keyStore.setObject(userDictionaryMutable, forKey: "playerData")
                keyStore.synchronize()
            }
        }
        
        if self.coins >= 100
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
        
        if self.coins >= 1000
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
        
        if self.coins >= 10000
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
        
        if let _ = defaults.objectForKey("petUUIDS") as? NSMutableArray
        {
            //petUUIDS Loading
        }
        else
        {
            defaults.setObject(NSMutableArray(), forKey: "petUUIDS")
        }
                
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"saveDataBackground", name: UIApplicationDidEnterBackgroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"saveDataBackground", name: UIApplicationWillTerminateNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"saveDataBackground", name: UIApplicationWillResignActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"didEnterFromBackground", name: UIApplicationWillEnterForegroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"changedValues", name: NSUbiquitousKeyValueStoreDidChangeExternallyNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserverForName(GCControllerDidConnectNotification, object: nil, queue: nil) { note in
            NSLog("GCControllerDidConnectNotification")
            self.controller = GCController.controllers().first!
            self.controller.playerIndex = GCControllerPlayerIndex(rawValue: 0)!
            
            //4
            if self.controller.microGamepad != nil
            {
                //5
                
                self.controller.microGamepad?.valueChangedHandler = { (gamepad, element) -> Void in
                    if element == self.controller.microGamepad?.buttonA
                    {
                        if self.gamePaused == false
                        {
                            self.addBrush()
                        }
                        else
                        {
                            self.calibratePrincess()
                        }
                    }
                    if element == self.controller.microGamepad?.buttonX && self.controller.microGamepad?.buttonX.pressed == false
                    {
                        if self.gameIsRunning == false
                        {
                            self.calibratePrincess()
                            self.runGame()
                        }
                        else
                        {
                            if self.gamePaused == true
                            {
                                self.resumeGame()
                            }
                            else
                            {
                                self.pauseGame()
                            }
                        }
                    }
                    if element == self.controller.microGamepad?.dpad && self.gamePaused == false && self.toggleTilt == false
                    {
                        if self.controller.microGamepad?.dpad.left.value > 0.0
                        {
                            self.princess1.position = CGPoint(x: self.princess1.position.x, y: self.princess1.position.y+CGFloat((self.controller.microGamepad?.dpad.left.value)!*5))
                        }
                        
                        if self.controller.microGamepad?.dpad.right.value > 0.0
                        {
                            self.princess1.position = CGPoint(x: self.princess1.position.x, y: self.princess1.position.y-CGFloat((self.controller.microGamepad?.dpad.right.value)!*5))
                        }
                    }
                }
                
                /*self.controller.microGamepad?.buttonX.pressedChangedHandler = { (button, value, pressed) -> Void in
                self.addBrush()
                }*/
                
            }
            
            self.controller.motion?.valueChangedHandler = { (motion) -> Void in
                if self.gamePaused == false && self.toggleTilt == true
                {
                    self.princess1.position = CGPoint(x: self.princess1.position.x, y: self.princess1.position.y-CGFloat(((self.controller.motion?.gravity.x)!)*12))
                    //NSLog("%d", (self.controller.motion?.gravity.x)!)
                }
            }
        }
        
        
        if let didComeBackFromBackground = defaults.objectForKey("didComeBackFromBackground") as? Bool
        {
            if didComeBackFromBackground == true
            {
                defaults.setObject(false, forKey: "didComeBackFromBackground")
                self.gameIsRunning = true
                self.canPressButtons = false
                if let zombiesData = defaults.objectForKey("zombies") as? NSData
                {
                    let zombiesUnarchived = NSKeyedUnarchiver.unarchiveObjectWithData(zombiesData) as! Array<GenericZombie>
                    self.zombies = zombiesUnarchived
                    
                    var prevoiusZombie = GenericZombie()
                    
                    for aZombie in zombies
                    {
                        if prevoiusZombie != aZombie
                        {
                            self.addChild(aZombie)
                        }
                        prevoiusZombie = aZombie
                    }
                }
                
                self.pauseGame()
            }
            else
            {
                self.setUpAudio()
                
                //self.runGame()
            }
        }
        else
        {
            self.setUpAudio()

            //self.runGame()
        }
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
                let healthGainedLabel = SKLabelNode(fontNamed: "TimesNewRoman")
                healthGainedLabel.text = "+0.5"
                healthGainedLabel.fontColor = SKColor.greenColor()
                healthGainedLabel.fontSize = 32
                healthGainedLabel.position = CGPoint(x: self.princess1.position.x, y: self.princess1.position.y+100)
                healthGainedLabel.runAction(SKAction.moveToY(healthGainedLabel.position.y+20, duration: 0.4))
                healthGainedLabel.runAction(SKAction.sequence([SKAction.fadeOutWithDuration(0.4), SKAction.runBlock({
                    healthGainedLabel.removeFromParent()
                })]))
                self.addChild(healthGainedLabel)
            }
            else
            {
                if self.healthLostInLastRound > 0
                {
                    let healthGainedLabel = SKLabelNode(fontNamed: "TimesNewRoman")
                    healthGainedLabel.text = NSString(format: "+0.25", self.healthLostInLastRound) as String
                    healthGainedLabel.fontColor = SKColor.greenColor()
                    healthGainedLabel.fontSize = 32
                    healthGainedLabel.position = CGPoint(x: self.princess1.position.x, y: self.princess1.position.y+75)
                    healthGainedLabel.runAction(SKAction.moveToY(healthGainedLabel.position.y+20, duration: 0.4))
                    healthGainedLabel.runAction(SKAction.sequence([SKAction.fadeOutWithDuration(0.4), SKAction.runBlock({
                        healthGainedLabel.removeFromParent()
                    })]))
                    self.addChild(healthGainedLabel)
                }
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
        
        let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if let volume = defaults.objectForKey("volume") as? Float
        {
            backgroundMusicPlayer.volume = volume / 10
            NSLog("Volume: %f", volume)
        }
        
        if let zombiesKilledLabel = self.childNodeWithName("zombiesKilledLabel")
        {
            zombiesKilledLabel.removeFromParent()
        }
        
        let zombiesToSpawn = 3
        
        var zombiesSpawned = 0
        while zombiesSpawned != zombiesToSpawn
        {
            if wavesCompleted >= 3
            {
                let spawnCat = CGFloat(arc4random()%3)
                if spawnCat == 2
                {
                    let cat1 = CatZombie()
                    let yPos = CGFloat((arc4random()%180)+100)
                    let xPos = CGFloat((arc4random()%180)+100)
                    cat1.name = "catZombie"
                    cat1.health = self.wavesCompleted / 4
                    cat1.physicsBody = SKPhysicsBody(circleOfRadius:cat1.size.width/2)
                    cat1.physicsBody?.dynamic = true
                    cat1.physicsBody?.categoryBitMask = self.monsterCategory
                    cat1.physicsBody?.contactTestBitMask = self.princessCategory
                    cat1.physicsBody?.collisionBitMask = 0
                    cat1.physicsBody?.usesPreciseCollisionDetection = true
                    cat1.position = CGPointMake(CGRectGetMidX(self.frame)+xPos, yPos)
                    let moveBy = SKAction.moveByX(CGFloat(-self.zombieSpeed), y: 0, duration: 0.1)
                    cat1.runAction(SKAction.repeatActionForever(moveBy))
                    let moveToPrincess = SKAction.moveToY(self.princess1.position.y, duration: 1)
                    let sequence = SKAction.sequence([moveToPrincess, SKAction.runBlock({
                        cat1.texture = SKTexture(imageNamed: "catOpen.png")
                    }), SKAction.waitForDuration(1),SKAction.runBlock({
                        let hairball = SKSpriteNode(imageNamed: "hairball.png")
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
                    self.zombies.insert(cat1, atIndex: self.zombies.count)
                    //self.zombies.addObject(cat1)
                }
                else
                {
                    let zombie1 = GenericZombie()
                    let yPos = CGFloat((arc4random()%150)+150)
                    let xPos = CGFloat((arc4random()%150)+150)
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
                    let moveBy = SKAction.moveByX(CGFloat(-self.zombieSpeed), y: 0, duration: 0.1)
                    zombie1.runAction(SKAction.repeatActionForever(moveBy))
                    self.zombies.insert(zombie1, atIndex: self.zombies.count)
                    //self.zombies.addObject(zombie1)
                }

            }
            else
            {
                let zombie1 = GenericZombie()
                let yPos = CGFloat((arc4random()%150)+150)
                let xPos = CGFloat((arc4random()%150)+150)
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
                let moveBy = SKAction.moveByX(CGFloat(-self.zombieSpeed), y: 0, duration: 0.1)
                zombie1.runAction(SKAction.repeatActionForever(moveBy))
                self.zombies.insert(zombie1, atIndex: self.zombies.count)
                //self.zombies.addObject(zombie1)
            }
            zombiesSpawned++
        }
        
        for aZombie in self.zombies
        {
            self.addChild(aZombie)
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
                if self.brushesInWorld <= 2
                {
                    self.brushesInWorld++
                    
                    NSLog("Brushes In World: %i", self.brushesInWorld)
                    
                    let brush = SKSpriteNode(imageNamed: "brush.png")
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
                    let move = SKAction.moveToX(1000, duration: 1)
                    let vanish = SKAction.removeFromParent()
                    let removeBrush = SKAction.runBlock({
                        self.currentBrushes.removeObject(brush)
                        self.brushesInWorld--
                    })
                    let sequence = SKAction.sequence([move, removeBrush, vanish])
                    brush.runAction(sequence)
                }
            }
            else
            {
                let brush = SKSpriteNode(imageNamed: "brush.png")
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
                let move = SKAction.moveToX(1000, duration: 1)
                let vanish = SKAction.removeFromParent()
                let removeBrush = SKAction.runBlock({
                    self.currentBrushes.removeObject(brush)
                })
                let sequence = SKAction.sequence([move, vanish, removeBrush])
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
            else
            {
                print("Error: firstbody.node = nil. firstbody.node = \(firstBody.node)")
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
        self.currentBrushes.removeObject(projectile)
        projectile.removeFromParent()
        self.brushesInWorld--
        let monsterSK = monster as! GenericZombie
        monsterSK.health--
        let healthLostLabel = SKLabelNode(fontNamed: "TimesNewRoman")
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
        let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
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
            let deadZombie = GenericZombie(texture: SKTexture(imageNamed: "ash.png"), size: CGSize(width: 1.0, height: 1.0))
            deadZombie.name = "ash"
            deadZombie.position = monster.position
            monster.removeFromParent()
            self.zombies.removeAtIndex(self.zombies.indexOf(monsterSK)!)
            //self.zombies.removeObject(monster)
            self.zombies.insert(deadZombie, atIndex: self.zombies.count)
            //self.zombies.addObject(deadZombie)
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
            let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
            if var highScore = defaults.objectForKey("highScore") as? NSInteger
            {
                if self.zombiesKilled > highScore
                {
                    highScore++
                }
                
                defaults.setObject(highScore, forKey: "highScore")
            }
            
            let chance = CGFloat(arc4random()%80)
            if chance == 0
            {
                let chance = CGFloat(arc4random()%1)
                let uuid = NSUUID().UUIDString
                switch chance
                {
                    case 0:
                        let petCat = NSMutableDictionary()
                        petCat.setObject(0, forKey: "type")
                        petCat.setObject(1, forKey: "level")
                        self.pets.setObject(petCat, forKey: uuid)
                    case 1:
                        let petDog = NSMutableDictionary()
                        petDog.setObject(1, forKey: "type")
                        petDog.setObject(1, forKey: "level")
                        self.pets.setObject(petDog, forKey: uuid)
                    default:
                        _ = "WHYAPPLE???? WHY????"
                }
                
                if let uuids = self.pets.objectForKey("petUUIDs") as? NSMutableArray
                {
                    uuids.addObject(uuid)
                    self.pets.setObject(uuids, forKey: "petUUIDs")
                }
            }
            
        }
        
        let chance = CGFloat(arc4random()%4)
        if chance == 0
        {
            self.coins++
        }
        
        defaults.setObject(self.coins, forKey: "coins")
        
        self.saveData()
    }
    
    func monsterDidCollideWithPrincess(monster: SKNode, princess1: SKNode)
    {
        self.princessHealth--
        self.healthLostInLastRound += 1.00
        
        let monsterSK = monster as! GenericZombie
        
        let deadZombie = GenericZombie(texture: SKTexture(imageNamed: "ash.png"), size: CGSize(width: 1.0, height: 1.0))
        deadZombie.name = "ash"
        deadZombie.position = monster.position
        monster.removeFromParent()
        self.zombies.removeAtIndex(self.zombies.indexOf(monsterSK)!)
        //self.zombies.removeObject(monster)
        self.zombies.insert(deadZombie, atIndex: self.zombies.count)
        //self.zombies.addObject(deadZombie)
        self.addChild(deadZombie)
        
        if princessHealth <= 0
        {
            let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
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
        let healthLostLabel = SKLabelNode(fontNamed: "TimesNewRoman")
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
            let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
            
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
            backgroundMusicPlayer = try? AVAudioPlayer(contentsOfURL: backgroundMusicURL!)
            backgroundMusicPlayer.numberOfLoops = -1
        }
    }
    
    func gameOver()
    {
        gameOverDidOccur = true
        
        let hide = SKAction.fadeOutWithDuration(0)
        let show = SKAction.fadeInWithDuration(0)
        let wait = SKAction.waitForDuration(1)
        let sequence = SKAction.sequence([hide, wait, show, wait, hide, wait, show, wait, hide, wait, show, wait, hide])
        self.princess1.runAction(SKAction.sequence([sequence, SKAction.runBlock({
            self.canPressButtons = true
            self.gameIsRunning = false
        })]))
        
        for aZombie in self.zombies
        {
            aZombie.removeFromParent()
        }
        
        self.zombies.removeAll()
        
        let zombiesKilledLabel = SKLabelNode(fontNamed: "TimesNewRoman")
        zombiesKilledLabel.name = "zombiesKilledLabel"
        zombiesKilledLabel.fontColor = SKColor.redColor()
        zombiesKilledLabel.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        self.addChild(zombiesKilledLabel)
        
        let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        zombiesKilledLabel.text = NSString(format: "Zombies Killed: %i", self.zombiesKilled) as String
        
        if let _ = defaults.objectForKey("currentScore")
        {
            defaults.setObject(0, forKey: "currentScore")
        }
        
        if let _ = defaults.objectForKey("levels")
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
        let background = SKSpriteNode(imageNamed: "backgroundg")
        background.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        background.zPosition = -2
        background.name = "background"
        self.addChild(background)
        
        self.zombiesKilled = 0
        
        self.healthPack = false
        self.checkIsShowing2 = false
    }
    
    func calibratePrincess()
    {
        self.princess1.position = CGPoint(x: CGRectGetMidX(self.frame)-300, y: CGRectGetMidY(self.frame)-100)
        self.brushInWorld = false
        self.brushesInWorld = 0
        self.toggleTilt = !self.toggleTilt
    }
    
    func resetGame()
    {
        let backGround2 = SKShapeNode(circleOfRadius: 10)
        backGround2.path = CGPathCreateWithRect(CGRectMake(CGRectGetMidX(self.frame)-300, CGRectGetMidY(self.frame)-200, 600, 400), nil)
        backGround2.fillColor = SKColor.grayColor()
        backGround2.name = "background2"
        backGround2.position = CGPoint(x: 0, y: 0)
        backGround2.zPosition = 10
        
        let textReset = SKLabelNode(fontNamed: "TimesNewRoman")
        textReset.fontColor = SKColor.redColor()
        textReset.fontSize = 64
        textReset.text = "Are you SURE"
        textReset.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame)+150)
        textReset.zPosition = 11
        backGround2.addChild(textReset)
        
        let textReset2 = SKLabelNode(fontNamed: "TimesNewRoman")
        textReset2.fontColor = SKColor.redColor()
        textReset2.fontSize = 64
        textReset2.text = "you want to reset?"
        textReset2.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame)+100)
        textReset2.zPosition = 11
        backGround2.addChild(textReset2)
        
        self.addChild(backGround2)
    }
    
    func resetYes()
    {
        let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(0, forKey: "Tutorial")
        defaults.setObject(0, forKey: "highScore")
        defaults.setObject(0, forKey: "levels")
        defaults.setObject(0, forKey: "coins")
        defaults.setObject([false, false], forKey: "items")
        defaults.setObject(1, forKey: "background")
        defaults.setObject(1, forKey: "health")
        defaults.setObject(0, forKey: "healthLost")
        defaults.setObject(0, forKey: "currentScore")
        
        //self.gameViewController1?.resetGameCenter()
                
        //self.gameViewController1?.presentTitleScene()
    }
    
    func resetNo()
    {
        let background2 = self.childNodeWithName("background2")
        background2?.removeFromParent()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        if self.gameIsRunning == false
        {
            if let zombiesKilledLabel = self.childNodeWithName("zombiesKilledLabel")
            {
                zombiesKilledLabel.removeFromParent()
            }
            
            princess1.runAction(SKAction.fadeInWithDuration(0))
        }
    }
    
    func showPetYard()
    {
        let petyard = SKNode()
        petyard.name = "petyard"
        
        let backGround = SKShapeNode(circleOfRadius: 10)
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
        let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        
        let defaultsGroup: NSUserDefaults = NSUserDefaults(suiteName: "group.com.jacksonjude.PrVZ")!
        
        defaults.setObject(self.coins, forKey: "coins")
        
        if let _ = defaults.objectForKey("currentScore") as? NSInteger
        {
            defaults.setObject(self.zombiesKilled, forKey: "currentScore")
        }
        
        defaults.setObject(self.wavesCompleted, forKey: "levels")
        
        let tempArray = NSMutableArray()
        
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
            defaultsGroup.setObject(highScore, forKey: "highScore")
        }
        if let levels = defaults.objectForKey("levels") as? NSInteger
        {
            defaultsGroup.setObject(levels, forKey: "levels")
        }
    }
    
    func saveDataBackground()
    {
        if self.gameIsRunning == true
        {
            for aZombie in self.zombies
            {
                aZombie.removeAllActions()
            }
            
            let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
            
            let zombieData = NSKeyedArchiver.archivedDataWithRootObject(self.zombies)
            defaults.setObject(zombieData, forKey: "zombies")
            
            defaults.setBool(true, forKey: "didComeBackFromBackground")
        }
        self.saveData()
    }
    
    func didEnterFromBackground()
    {
        let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        
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
                self.zombies.removeAll()
                
                if let zombiesData = defaults.objectForKey("zombies") as? NSData
                {
                    let zombiesUnarchived = NSKeyedUnarchiver.unarchiveObjectWithData(zombiesData) as! Array<GenericZombie>
                    self.zombies = zombiesUnarchived
                    
                    for aZombie in zombies
                    {
                        self.addChild(aZombie)
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
            aZombie.removeAllActions()
        }
        
        for aBrush in self.currentBrushes
        {
            let aBrushSK = aBrush as! SKSpriteNode
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
        
        let resumeButton = SKSpriteNode(imageNamed: "resume")
        resumeButton.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        resumeButton.name = "resumeButton"
        resumeButton.zPosition = 5
        self.addChild(resumeButton)
        
        self.gamePaused = true
        
        saveData()
    }
    
    func resumeGame()
    {
        for aZombie in self.zombies
        {
            if aZombie.name != "ash"
            {
                aZombie.runAction(SKAction.repeatActionForever(SKAction.moveByX(CGFloat(-self.zombieSpeed), y: 0, duration: 0.1)))
                if aZombie.name == "catZombie"
                {
                    let sequence = SKAction.sequence([SKAction.runBlock({
                        let hairball = SKSpriteNode(imageNamed: "hairball")
                        hairball.position = self.position
                        hairball.runAction(SKAction.repeatActionForever(SKAction.moveToX(-1000, duration: 2)))
                        hairball.name = "hairball"
                        hairball.physicsBody = SKPhysicsBody(circleOfRadius:hairball.size.width/2)
                        hairball.physicsBody?.dynamic = true
                        hairball.physicsBody?.categoryBitMask = self.enemyProjectileCatagory
                        hairball.physicsBody?.contactTestBitMask = self.princessCategory
                        hairball.physicsBody?.collisionBitMask = 0
                        hairball.physicsBody?.usesPreciseCollisionDetection = true
                        aZombie.addChild(hairball)
                    }), SKAction.waitForDuration(2), SKAction.runBlock({
                        NSLog("%f", self.princessHealth)
                    })])
                    aZombie.runAction(SKAction.waitForDuration(0.5))
                    aZombie.runAction(SKAction.repeatActionForever(sequence))
                }
            }
        }
        
        for aBrush in self.currentBrushes
        {
            let aBrushSK = aBrush as! SKSpriteNode
            let move = SKAction.moveToX(1000, duration: 1)
            let vanish = SKAction.removeFromParent()
            let removeBrush = SKAction.runBlock({
                self.currentBrushes.removeObject(aBrushSK)
            })
            let sequence = SKAction.sequence([move, vanish, removeBrush])
            aBrushSK.runAction(sequence)
        }
        
        if let resumeButton = self.childNodeWithName("resumeButton")
        {
            resumeButton.removeFromParent()
        }
        
        self.gamePaused = false
    }
    
    func changedValues()
    {
        print("Changes Found in iCloud")
        NSUbiquitousKeyValueStore.defaultStore().synchronize()
    }
    
    func shakeMotion()
    {
        NSLog("test")
    }
    
    override func update(currentTime: NSTimeInterval)
    {
        if self.windowIsOpen == false
        {
            if self.currentBrushes.count == 0
            {
                self.brushesInWorld = 0
            }
            
            if self.canPressButtons == true
            {
                if (self.buttons.hidden == true)
                {
                    self.buttons.hidden = false
                    for aButton in self.buttons.children
                    {
                        let aButtonSK = aButton 
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
                        let aButtonSK = aButton 
                        aButtonSK.userInteractionEnabled = false
                    }
                }
            }
            
            let healthLabelOLD = self.childNodeWithName("healthLabel")
            if healthLabelOLD != nil
            {
                let healthLabelSK = healthLabelOLD as! SKLabelNode
                healthLabelSK.text = NSString(format: "Health: %.2f", self.princessHealth) as String
                healthLabelSK.zPosition = 10
            }
            else
            {
                let healthLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
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
            let healthLabel = self.childNodeWithName("healthLabel")
            healthLabel?.zPosition = 0
            
            let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
            
            let tempArray = NSMutableArray()
            
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
                    let store = self.childNodeWithName("store")
                    let products = store?.childNodeWithName("products")
                    let infiniteBrush = products?.childNodeWithName("infiniteBrush")
                    let aButton = infiniteBrush?.childNodeWithName("infBrushButton")
                    aButton?.removeFromParent()
                    
                    if self.checkIsShowing == false
                    {
                        let infBrushCheck = SKSpriteNode(imageNamed: "check.png")
                        infBrushCheck.zPosition = 8
                        infBrushCheck.name = "checkInf"
                        infBrushCheck.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
                        let storeNode = self.childNodeWithName("store")
                        storeNode?.addChild(infBrushCheck)
                        self.checkIsShowing = true
                    }
                }
                if self.healthPack == true
                {
                    let store = self.childNodeWithName("store")
                    let products = store?.childNodeWithName("products")
                    let healthPack = products?.childNodeWithName("healthPack")
                    let aButton = healthPack?.childNodeWithName("HealthPackBuyButton")
                    aButton?.removeFromParent()
                    
                    if self.checkIsShowing2 == false
                    {
                        let healthPackCheck = SKSpriteNode(imageNamed: "check.png")
                        healthPackCheck.zPosition = 8
                        healthPackCheck.name = "checkHealth"
                        healthPackCheck.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
                        let storeNode = self.childNodeWithName("store")
                        storeNode?.addChild(healthPackCheck)
                        self.checkIsShowing2 = true
                    }
                }
                if self.battery == true
                {
                    let store = self.childNodeWithName("store")
                    let products = store?.childNodeWithName("products")
                    let healthPack = products?.childNodeWithName("battery")
                    let aButton = healthPack?.childNodeWithName("BatteryPackBuyButton")
                    aButton?.removeFromParent()
                    
                    if self.checkIsShowing3 == false
                    {
                        let batteryCheck = SKSpriteNode(imageNamed: "check.png")
                        batteryCheck.zPosition = 8
                        batteryCheck.name = "checkBattery"
                        batteryCheck.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
                        let storeNode = self.childNodeWithName("store")
                        storeNode?.addChild(batteryCheck)
                        self.checkIsShowing3 = true
                    }
                }
            }
            else
            {
                if let _ = self.childNodeWithName("settings")
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
                let range = NSRange(location: 0, length: 50)
                let gameOverRange = NSLocationInRange(Int(aZombie2.position.x), range)
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
            
            if zombiesAlive == 0 && princessHealth > 0
            {
                backgroundMusicPlayer.pause()
                
                if self.coins >= 100
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
                
                if self.coins >= 1000
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
                
                if self.coins >= 10000
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
                    self.zombies.removeAtIndex(self.zombies.indexOf(innerZombie)!)
                    //self.zombies.removeObject(innerZombie)
                    innerZombie.removeFromParent()
                    
                }
                
                let range = NSRange(location: 15, length: 14)
                let range2 = NSRange(location: 30, length: 14)
                let range3 = NSRange(location: 45, length: 14)
                let background2Bool = NSLocationInRange(self.wavesCompleted, range)
                if background2Bool
                {
                    let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
                    defaults.setObject(2, forKey: "background")
                    if let background = self.childNodeWithName("background")
                    {
                        background.removeFromParent()
                    }
                    let background2 = SKSpriteNode(imageNamed: "background2")
                    background2.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
                    background2.zPosition = -2
                    background2.name = "background"
                    self.addChild(background2)
                    
                    if self.wavesCompleted == 15
                    {
                        let gotBlowDryer = SKLabelNode(fontNamed: "TimesNewRoman")
                        gotBlowDryer.fontColor = SKColor.orangeColor()
                        gotBlowDryer.fontSize = 32
                        gotBlowDryer.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
                        gotBlowDryer.text = "Recived Blow Dryer!"
                        self.addChild(gotBlowDryer)
                        
                        gotBlowDryer.runAction(SKAction.moveToY(gotBlowDryer.position.y+40, duration: 3))
                        gotBlowDryer.runAction(SKAction.sequence([SKAction.fadeOutWithDuration(3), SKAction.runBlock({
                            gotBlowDryer.removeFromParent()
                        })]))
                        
                        /*var brushButton =*/
                    }
                }
                
                let background3Bool = NSLocationInRange(self.wavesCompleted, range2)
                if background3Bool
                {
                    let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
                    defaults.setObject(3, forKey: "background")
                    if let background = self.childNodeWithName("background")
                    {
                        background.removeFromParent()
                    }
                    let background3 = SKSpriteNode(imageNamed: "background3")
                    background3.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
                    background3.zPosition = -2
                    background3.name = "background"
                    self.addChild(background3)
                }
                
                let background4Bool = NSLocationInRange(self.wavesCompleted, range3)
                if background4Bool
                {
                    let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
                    defaults.setObject(4, forKey: "background")
                    if let background = self.childNodeWithName("background")
                    {
                        background.removeFromParent()
                    }
                    let background3 = SKSpriteNode(imageNamed: "background4")
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
                
                let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
                
                if let didComeBackFromBackground = defaults.objectForKey("didComeBackFromBackground") as? Bool
                {
                    if didComeBackFromBackground == false
                    {
                        self.runGame()
                    }
                }
                else
                {
                    self.runGame()
                }
            }
        }
        
        self.coinsLabel.text = NSString(format: "%i", self.coins) as String
        
        if self.infBrushItem == false
        {
            let brush = self.childNodeWithName("brush")
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