//
//  DevelopmentScene.swift
//  PrVZ
//
//  Created by jackson on 6/4/15.
//  Copyright (c) 2015 jackson. All rights reserved.
//

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
import CoreMotion

class DevelopmentScene: SKScene, SKPhysicsContactDelegate
{
    let brushCategory: UInt32 =           1 << 0
    let monsterCategory: UInt32 =         1 << 1
    let princessCategory: UInt32 =        1 << 2
    let enemyProjectileCatagory: UInt32 = 1 << 3
    
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
    var coins = 10000
    var coinsLabel = SKLabelNode(fontNamed: "TimesNewRoman")
    var zombiesToSpawnSlider: UISlider?
    var joystickSwitch: UISwitch?
    var zombieSpeedSlider: UISlider?
    var volumeSlider: UISlider?
    var zombieHealthMultiplierSlider: UISlider?
    var gameViewController1: GameViewController?
    var infBrushItem = Bool()
    var healthPack = Bool()
    var battery = Bool()
    var wavesCompletedJustToShow = NSInteger()
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
    var batteryPercent = 0.00
    var savedOnOpeningWindow = false
    var brushesInWorld = 0
    var justBoughtHealthPack = false
    var pets = NSMutableDictionary()
    lazy var motionManager: CMMotionManager =
    {
        let motion = CMMotionManager()
        motion.accelerometerUpdateInterval = 1.0/10.0
        return motion
        }()
    
    override func didMoveToView(view: SKView)
    {
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
        
        let pauseButton = SKButton(defaultButtonImage: "pause", activeButtonImage: "pause", buttonAction: pauseGame)
        pauseButton.position = CGPoint(x: CGRectGetMidX(self.frame)+400, y: CGRectGetMidY(self.frame)+100)
        pauseButton.name = "pauseButton"
        pauseButton.hidden = true
        pauseButton.userInteractionEnabled = false
        self.addChild(pauseButton)
        
        let fireButton = SKButton(defaultButtonImage: "fireButton", activeButtonImage: "fireButtonPressed", buttonAction: self.addBrush)
        fireButton.position = CGPoint(x: CGRectGetMidX(self.frame)+400, y: CGRectGetMidY(self.frame)-200)
        fireButton.name = "fire"
        self.addChild(fireButton)
        
        self.joystick.position = CGPoint(x: CGRectGetMidX(self.frame)-400, y: CGRectGetMidY(self.frame)-200)
        self.joystick.name = "joystick"
        self.addChild(joystick)
        
        let startButton = SKButton(defaultButtonImage: "startButtonGame", activeButtonImage: "startButtonGamePressed", buttonAction: runGame)
        startButton.position = CGPoint(x: CGRectGetMidX(self.frame)-300, y: CGRectGetMidY(self.frame)+200)
        startButton.name = "start"
        self.buttons.addChild(startButton)
        
        let storeButton = SKButton(defaultButtonImage: "storeButton", activeButtonImage: "storeButtonPressed", buttonAction: store)
        storeButton.position = CGPoint(x: CGRectGetMidX(self.frame)+300, y: CGRectGetMidY(self.frame)+200)
        storeButton.name = "store"
        self.buttons.addChild(storeButton)
        
        let settingsButton = SKButton(defaultButtonImage: "settingsButton", activeButtonImage: "settingsButtonPressed", buttonAction: settings)
        settingsButton.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame)+200)
        settingsButton.name = "settingsButton"
        self.buttons.addChild(settingsButton)
        
        self.addChild(self.buttons)
        
        let bar = SKShapeNode()
        bar.path = CGPathCreateWithRect(CGRectMake(32, 0, 960, 235), nil)
        bar.fillColor = SKColor.grayColor()
        bar.name = "bar"
        bar.position = CGPoint(x: 0, y: CGRectGetMidY(self.frame)+125)
        bar.zPosition = -1
        self.addChild(bar)
        
        self.zombiesToSpawnSlider?.hidden = true
        self.zombiesToSpawnSlider?.userInteractionEnabled = false
        self.zombiesToSpawnSlider?.maximumValue = 20
        self.zombiesToSpawnSlider?.minimumValue = 3
        
        self.joystickSwitch?.hidden = true
        self.joystickSwitch?.userInteractionEnabled = false
        
        self.zombieSpeedSlider?.hidden = true
        self.zombieSpeedSlider?.userInteractionEnabled = false
        self.zombieSpeedSlider?.minimumValue = 1
        self.zombieSpeedSlider?.maximumValue = 10
        
        self.zombieHealthMultiplierSlider?.hidden = true
        self.zombieHealthMultiplierSlider?.userInteractionEnabled = false
        self.zombieHealthMultiplierSlider?.minimumValue = 1
        self.zombieHealthMultiplierSlider?.maximumValue = 5
        
        self.coinsLabel.position = CGPoint(x: CGRectGetMidX(self.frame)+300, y: CGRectGetMidY(self.frame)+90)
        self.coinsLabel.fontColor = SKColor.redColor()
        self.addChild(self.coinsLabel)
        let coinsImage = SKSpriteNode(imageNamed: "coin.png")
        coinsImage.position = CGPoint(x: coinsImage.position.x-40, y: coinsImage.position.y+10)
        coinsImage.name = "coinsImage"
        self.coinsLabel.addChild(coinsImage)
        
        coinsImage.position.x = coinsImage.position.x-60
    }
    
    func runGame()
    {
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
        
        if let zombiesKilledLabel = self.childNodeWithName("zombiesKilledLabel")
        {
            zombiesKilledLabel.removeFromParent()
        }
        
        let zombieSpeedToMakeAsACGFloat = self.zombieSpeedSlider?.value
        self.zombieSpeed = CGFloat(zombieSpeedToMakeAsACGFloat!)
        
        let numberOfZombiesToMakeAsAFloat = self.zombiesToSpawnSlider?.value
        let zombiesToSpawn = NSInteger(numberOfZombiesToMakeAsAFloat!)
        
        let zombieHealthMultiplier = NSInteger(self.zombieHealthMultiplierSlider!.value)
        
        let catWavesCompleted = self.wavesCompletedJustToShow / 4
        
        var zombiesSpawned = 0
        while zombiesSpawned != zombiesToSpawn
        {
            if wavesCompletedJustToShow >= 3
            {
                let spawnCat = CGFloat(arc4random()%3)
                if spawnCat == 2
                {
                    let cat1 = CatZombie()
                    let yPos = CGFloat((arc4random()%180)+100)
                    let xPos = CGFloat((arc4random()%180)+100)
                    cat1.name = "catZombie"
                    cat1.health = catWavesCompleted * zombieHealthMultiplier
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
                    self.zombies.addObject(cat1)
                }
                else
                {
                    let zombie1 = GenericZombie()
                    let yPos = CGFloat((arc4random()%150)+150)
                    let xPos = CGFloat((arc4random()%150)+150)
                    zombie1.health = self.wavesCompletedJustToShow * zombieHealthMultiplier
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
                    self.zombies.addObject(zombie1)
                }
                
            }
            else
            {
                let zombie1 = GenericZombie()
                let yPos = CGFloat((arc4random()%150)+150)
                let xPos = CGFloat((arc4random()%150)+150)
                zombie1.health = self.wavesCompletedJustToShow * zombieHealthMultiplier
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
        if monsterSK.health < 1
        {
            let deadZombie = SKSpriteNode(imageNamed: "ash.png")
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
    }
    
    func monsterDidCollideWithPrincess(monster: SKNode, princess1: SKNode)
    {
        self.princessHealth--
        self.healthLostInLastRound += 1.00
        
        let deadZombie = SKSpriteNode(imageNamed: "ash.png")
        deadZombie.name = "ash"
        deadZombie.position = monster.position
        monster.removeFromParent()
        self.zombies.removeObject(monster)
        self.zombies.addObject(deadZombie)
        self.addChild(deadZombie)
        
        if princessHealth <= 0
        {
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
            self.gameOver()
        }
        enemyProjectile.removeFromParent()
        NSLog("%f", self.princessHealth)
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
        
        self.zombies.removeAllObjects()
        
        let zombiesKilledLabel = SKLabelNode(fontNamed: "TimesNewRoman")
        zombiesKilledLabel.name = "zombiesKilledLabel"
        zombiesKilledLabel.fontColor = SKColor.redColor()
        zombiesKilledLabel.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        self.addChild(zombiesKilledLabel)
        
        self.zombiesKilled = 0
        
        self.healthPack = false
        self.checkIsShowing2 = false
    }
    
    func settings()
    {
        self.windowIsOpen = true
        self.canPressButtons = false
        
        let settingsNode = SKNode()
        settingsNode.name = "settings"
        
        let backGround = SKShapeNode(circleOfRadius: 10)
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
        
        self.zombieHealthMultiplierSlider?.hidden = false
        self.zombieHealthMultiplierSlider?.userInteractionEnabled = true
        
        let resetGameButton = SKButton(defaultButtonImage: "resetButton", activeButtonImage: "resetButtonPressed", buttonAction: resetGame)
        resetGameButton.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame)-200)
        resetGameButton.zPosition = 6
        settingsNode.addChild(resetGameButton)
        
        let saveGameButton = SKButton(defaultButtonImage: "saveButtonInactive", activeButtonImage: "saveButtonInactivePressed", buttonAction: saveData)
        saveGameButton.position = CGPoint(x: CGRectGetMidX(self.frame)+200, y: CGRectGetMidY(self.frame)-200)
        saveGameButton.zPosition = 6
        settingsNode.addChild(saveGameButton)
        
        let calibrate = SKButton(defaultButtonImage: "calibrate", activeButtonImage: "calibratePressed", buttonAction: calibratePrincess)
        calibrate.position = CGPoint(x: CGRectGetMidX(self.frame)-400, y: CGRectGetMidX(self.frame)-140)
        calibrate.zPosition = 6
        settingsNode.addChild(calibrate)
        
        let menuButton = SKButton(defaultButtonImage: "menuButton", activeButtonImage: "menuButtonPressed", buttonAction: presentMenuScene)
        menuButton.position = CGPoint(x: CGRectGetMidX(self.frame)-200, y: CGRectGetMidY(self.frame)-200)
        menuButton.zPosition = 6
        settingsNode.addChild(menuButton)
        
        self.levelsCompletedLabel.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame)+100)
        self.levelsCompletedLabel.fontColor = SKColor.blueColor()
        self.levelsCompletedLabel.zPosition = 6
        self.levelsCompletedLabel.text = NSString(format: "Levels Completed In Dev Mode: %i", self.wavesCompletedJustToShow) as String
        self.addChild(self.levelsCompletedLabel)
        
        let currentScoreLabel = SKLabelNode(fontNamed: "TimesNewRoman")
        currentScoreLabel.fontColor = SKColor.redColor()
        currentScoreLabel.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame)+150)
        currentScoreLabel.zPosition = 6
        currentScoreLabel.text = NSString(format: "Curent Score: %i", self.zombiesKilled) as String
        settingsNode.addChild(currentScoreLabel)
        
        let backbutton = addButton(CGPoint(x: 0, y: 0), type: "back", InMenu: "settings", WithAction: hideSettings, WithName: "backButton")
        settingsNode.addChild(backbutton)
        
        self.addChild(settingsNode)
    }
    
    func calibratePrincess()
    {
        self.princess1.position = CGPoint(x: CGRectGetMidX(self.frame)-300, y: CGRectGetMidY(self.frame)-100)
        self.brushInWorld = false
        self.brushesInWorld = 0
    }
    
    func addButton(pos: CGPoint, type: NSString, InMenu: NSString, WithAction: () -> Void, WithName: NSString) -> SKButton
    {
        var posOverride = CGPoint(x: 0, y: 0)
        if type == "back" && InMenu != "default"
        {
            posOverride = CGPoint(x: CGRectGetMidX(self.frame)+400, y: CGRectGetMidX(self.frame)-140)
        }
        
        let button = SKButton(defaultButtonImage: WithName as String, activeButtonImage: WithName as String + "Pressed", buttonAction: WithAction)
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
        let backGround2 = SKShapeNode(circleOfRadius: 10)
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
        
        let resetButton = self.addButton(CGPoint(x: CGRectGetMidX(self.frame)+200, y: CGRectGetMidY(self.frame)), type: "default", InMenu: "settings", WithAction: resetYes, WithName: "resetButton")
        backGround2.addChild(resetButton)
        
        let backButton = self.addButton(CGPoint(x: CGRectGetMidX(self.frame)-200, y: CGRectGetMidY(self.frame)), type: "back", InMenu: "settings", WithAction: resetNo, WithName: "backButton")
        backGround2.addChild(backButton)
        
        self.addChild(backGround2)
    }
    
    func resetYes()
    {
        self.gameViewController1!.reloadDevScene()
    }
    
    func resetNo()
    {
        let background2 = self.childNodeWithName("background2")
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
        
        if self.gamePaused == true
        {
            self.resumeGame()
        }
    }
    
    func hideSettings()
    {
        let settingsNode = self.childNodeWithName("settings")
        settingsNode?.hidden = true
        settingsNode?.removeFromParent()
        
        self.levelsCompletedLabel.removeFromParent()
        
        self.zombiesToSpawnSlider?.userInteractionEnabled = false
        self.zombiesToSpawnSlider?.hidden = true
        
        self.joystickSwitch?.hidden = true
        self.joystickSwitch?.userInteractionEnabled = false
        
        self.zombieSpeedSlider?.hidden = true
        self.zombieSpeedSlider?.userInteractionEnabled = false
        
        self.zombieHealthMultiplierSlider?.hidden = true
        self.zombieHealthMultiplierSlider?.userInteractionEnabled = false
        
        self.joystickCheck()
        
        self.savedOnOpeningWindow = false
        
        self.windowIsOpen = false
        self.canPressButtons = true
    }
    
    func joystickCheck()
    {
        if self.joystickSwitch?.on == true
        {
            self.motionManager.stopAccelerometerUpdates()
            
            self.joystick.hidden = false
            self.joystick.userInteractionEnabled = true
            
            self.joystickBool = true
        }
        else
        {
            self.joystick.hidden = true
            self.joystick.userInteractionEnabled = false
            
            self.motionManager.startAccelerometerUpdates()
            
            self.joystickBool = false
        }
    }
    
    func store()
    {
        self.windowIsOpen = true
        self.storeIsOpen = true
        self.canPressButtons = false
        
        let storeNode = SKNode()
        storeNode.name = "store"
        
        let backGround = SKShapeNode(circleOfRadius: 10)
        backGround.path = CGPathCreateWithRect(CGRectMake(32, 0, 960, 720), nil)
        backGround.fillColor = SKColor.grayColor()
        backGround.name = "bg"
        backGround.position = CGPoint(x: 0, y: 0)
        backGround.zPosition = 5
        storeNode.addChild(backGround)
        
        let backButton = SKButton(defaultButtonImage: "backButton", activeButtonImage: "backButtonPressed", buttonAction: hideStore)
        backButton.position = CGPoint(x: CGRectGetMidX(self.frame)+400, y: CGRectGetMidX(self.frame)-140)
        backButton.zPosition = 8
        storeNode.addChild(backButton)
        
        let leftScrollButton = SKButton(defaultButtonImage: "leftScrollButton", activeButtonImage: "leftScrollButtonPressed", buttonAction: leftScroll)
        leftScrollButton.position = CGPoint(x: CGRectGetMidX(self.frame)-300, y: backButton.position.y+200)
        leftScrollButton.zPosition = 8
        storeNode.addChild(leftScrollButton)
        
        let rightScrollButton = SKButton(defaultButtonImage: "rightScrollButton", activeButtonImage: "rightScrollButtonPressed", buttonAction: rightScroll)
        rightScrollButton.position = CGPoint(x: CGRectGetMidX(self.frame)+300, y: backButton.position.y+200)
        rightScrollButton.zPosition = 8
        storeNode.addChild(rightScrollButton)
        
        let products = SKNode()
        products.name = "products"
        
        let infiniteBrush = SKSpriteNode(imageNamed: "infiniteBrush")
        infiniteBrush.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        infiniteBrush.name = "infiniteBrush"
        infiniteBrush.zPosition = 7
        products.addChild(infiniteBrush)
        let infiniteBrushLabel = SKLabelNode(fontNamed: "TimesNewRoman")
        infiniteBrushLabel.text = "Infinite Brush"
        infiniteBrushLabel.fontSize = 64
        infiniteBrushLabel.fontColor = SKColor.redColor()
        infiniteBrushLabel.position = CGPoint(x: infiniteBrushLabel.position.x, y: infiniteBrushLabel.position.y+50)
        infiniteBrush.addChild(infiniteBrushLabel)
        let infiniteBrushBuyButton = SKButton(defaultButtonImage: "buyButton", activeButtonImage: "buyButtonPressed", buttonAction: buyItemInfBrush)
        infiniteBrushBuyButton.position = CGPoint(x: infiniteBrushBuyButton.position.x, y: infiniteBrushBuyButton.position.y-200)
        infiniteBrushBuyButton.name = "infBrushButton"
        infiniteBrush.addChild(infiniteBrushBuyButton)
        let coinsCost = SKLabelNode(fontNamed: "TimesNewRoman")
        coinsCost.text = "40"
        coinsCost.fontSize = 24
        coinsCost.fontColor = SKColor.orangeColor()
        coinsCost.position = CGPoint(x: infiniteBrushBuyButton.position.x-30, y: infiniteBrushBuyButton.position.y)
        coinsCost.zPosition = 8
        infiniteBrushBuyButton.addChild(coinsCost)
        
        self.storeButtons.addObject(infiniteBrushBuyButton)
        
        let healthPack = SKSpriteNode(imageNamed: "healthPack.png")
        healthPack.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        healthPack.name = "healthPack"
        healthPack.zPosition = 7
        products.addChild(healthPack)
        let HealthPackBuyButton = SKButton(defaultButtonImage: "buyButton", activeButtonImage: "buyButtonPressed", buttonAction: buyItemHealthPack)
        HealthPackBuyButton.position = CGPoint(x: HealthPackBuyButton.position.x, y: HealthPackBuyButton.position.y-200)
        HealthPackBuyButton.name = "HealthPackBuyButton"
        healthPack.addChild(HealthPackBuyButton)
        self.storeButtons.addObject(HealthPackBuyButton)
        
        let coinsCost2 = SKLabelNode(fontNamed: "TimesNewRoman")
        coinsCost2.text = "60"
        coinsCost2.fontSize = 24
        coinsCost2.fontColor = SKColor.orangeColor()
        coinsCost2.position = CGPoint(x: HealthPackBuyButton.position.x-30, y: HealthPackBuyButton.position.y)
        coinsCost2.zPosition = 8
        HealthPackBuyButton.addChild(coinsCost2)
        
        healthPack.hidden = true
        healthPack.userInteractionEnabled = false
        let button = healthPack.childNodeWithName("HealthPackBuyButton")
        button?.removeFromParent()
        
        let battery = SKSpriteNode(imageNamed: "battery")
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
        
        self.brushesInWorld = 0
    }
    
    func buyItemHealthPack()
    {
        if self.coins > 59
        {
            self.coins-=60
            self.healthPack = true
            self.princessHealth+=1
        }
        
        self.justBoughtHealthPack = true
    }
    
    func leftScroll()
    {
        let store = self.childNodeWithName("store")
        let products = store?.childNodeWithName("products")
        let infiniteBrush = products?.childNodeWithName("infiniteBrush")
        let healthPack = products?.childNodeWithName("healthPack")
        let checkHealth = store?.childNodeWithName("checkHealth")
        let checkInf = store?.childNodeWithName("checkInf")
        let battery = products?.childNodeWithName("battery")
        
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
        let store = self.childNodeWithName("store")
        let products = store?.childNodeWithName("products")
        let infiniteBrush = products?.childNodeWithName("infiniteBrush")
        let healthPack = products?.childNodeWithName("healthPack")
        let battery = products?.childNodeWithName("battery")
        let checkHealth = store?.childNodeWithName("checkHealth")
        let checkInf = store?.childNodeWithName("checkInf")
        
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
                
                let HealthPackBuyButton = SKButton(defaultButtonImage: "buyButton", activeButtonImage: "buyButtonPressed", buttonAction: buyItemHealthPack)
                HealthPackBuyButton.position = CGPoint(x: HealthPackBuyButton.position.x, y: HealthPackBuyButton.position.y-200)
                HealthPackBuyButton.name = "HealthPackBuyButton"
                healthPack?.addChild(HealthPackBuyButton)
                
                let healthPackLabel = SKLabelNode(fontNamed: "TimesNewRoman")
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
        let storeNode = self.childNodeWithName("store")
        storeNode?.hidden = true
        storeNode?.removeFromParent()
        
        self.scrolled = 0
        
        self.canPressButtons = true
        self.windowIsOpen = false
        self.storeIsOpen = false
        self.checkIsShowing = false
        self.checkIsShowing2 = false
        
        self.savedOnOpeningWindow = false
        
        if self.justBoughtHealthPack == true
        {
            let healthGainedLabel = SKLabelNode(fontNamed: "TimesNewRoman")
            healthGainedLabel.text = "+1"
            healthGainedLabel.fontColor = SKColor.greenColor()
            healthGainedLabel.fontSize = 32
            healthGainedLabel.position = CGPoint(x: self.princess1.position.x, y: self.princess1.position.y+75)
            healthGainedLabel.runAction(SKAction.moveToY(healthGainedLabel.position.y+20, duration: 1))
            healthGainedLabel.runAction(SKAction.sequence([SKAction.fadeOutWithDuration(1), SKAction.runBlock({
                healthGainedLabel.removeFromParent()
            })]))
            self.addChild(healthGainedLabel)
            self.justBoughtHealthPack = false
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
        //Nothin' Here! ;-)
    }
    
    func pauseGame()
    {
        for aZombie in self.zombies
        {
            let aZombieSK = aZombie as! SKSpriteNode
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
        
        self.joystick.userInteractionEnabled = false
        
        let resumeButton = SKSpriteNode(imageNamed: "resume")
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
                let aZombieSK = aZombie as! SKSpriteNode
                aZombieSK.runAction(SKAction.repeatActionForever(SKAction.moveByX(CGFloat(-self.zombieSpeed), y: 0, duration: 0.1)))
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
            let aBrushSK = aBrush as! SKSpriteNode
            let move = SKAction.moveToX(1000, duration: 1)
            let vanish = SKAction.removeFromParent()
            let removeBrush = SKAction.runBlock({
                self.currentBrushes.removeObject(aBrushSK)
            })
            let sequence = SKAction.sequence([move, vanish, removeBrush])
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
        if self.joystickBool == true
        {
            let position1 = CGPoint(x: princess1.position.x, y: princess1.position.y+CGFloat(joystick.y*4))
            self.princess1.position = position1
        }
        else
        {
            if self.motionManager.accelerometerData != nil
            {
                let xForce = self.motionManager.accelerometerData!.acceleration.x
                let position1 = CGPoint(x: princess1.position.x, y: princess1.position.y-CGFloat(xForce*8))
                self.princess1.position = position1
            }
        }
        
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
                let aZombie2SK = aZombie2 as! SKSpriteNode
                let range = NSRange(location: 0, length: 50)
                let gameOverRange = NSLocationInRange(Int(aZombie2SK.position.x), range)
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
                
                self.wavesCompletedJustToShow++
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
                if self.wavesCompletedJustToShow == 15
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
                
                if self.princessHealth != 0
                {
                    self.canPressButtons = true
                }
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