//
//  ChallengeScene.swift
//  PrVZ
//
//  Created by jackson on 5/5/15.
//  Copyright (c) 2015 jackson. All rights reserved.
//

import Foundation
import SpriteKit
import GameKit

class ChallengeScene: SKScene, SKPhysicsContactDelegate {
    let brushCategory: UInt32 =           1 << 0
    let monsterCategory: UInt32 =         1 << 1
    let princessCategory: UInt32 =        1 << 2
    let enemyProjectileCatagory: UInt32 = 1 << 3
    
    var princess1 = Princess()
    var joystick = JCJoystick(controlRadius:50, baseRadius:68, baseColor:SKColor.blueColor(), joystickRadius:50, joystickColor:SKColor.redColor())
    var brushesInWorld = 0
    var currentBrushes = NSMutableArray()
    var zombies = NSMutableArray()
    var zombiesKilled = 0
    var princessHealth = 1.00
    var match: GKMatch?
    var gameIsRunning = false
    var wavesCompleted = 0
    var zombieSpeed: CGFloat = 1.0
    var gameViewController1: GameViewController?
    var scoreLabel = SKLabelNode(fontNamed: "TimesNewRoman")
    var scoreEnemyLabel = SKLabelNode(fontNamed: "TimesNewRoman")
    var zombiesToSpawnSlider: UISlider?
    var joystickSwitch: UISwitch?
    var zombieSpeedSlider: UISlider?
    
    override func didMoveToView(view: SKView)
    {
        let background = SKSpriteNode(imageNamed: "background.png")
        background.zPosition = -20
        background.name = "background"
        background.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        self.addChild(background)
        
        princess1.position = CGPoint(x: CGRectGetMidX(self.frame)-300, y: CGRectGetMidY(self.frame))
        princess1.name = "princess"
        princess1.physicsBody = SKPhysicsBody(circleOfRadius:princess1.size.width/2)
        princess1.physicsBody?.dynamic = true
        princess1.physicsBody?.categoryBitMask = self.princessCategory
        princess1.physicsBody?.contactTestBitMask = self.monsterCategory
        princess1.physicsBody?.collisionBitMask = 0
        princess1.physicsBody?.usesPreciseCollisionDetection = true
        self.addChild(princess1)
        
        physicsWorld.gravity = CGVectorMake(0,0)
        self.physicsWorld.contactDelegate = self
        
        var fireButton = SKButton(defaultButtonImage: "fireButton", activeButtonImage: "fireButtonPressed", buttonAction: self.addBrush)
        fireButton.position = CGPoint(x: CGRectGetMidX(self.frame)+400, y: CGRectGetMidY(self.frame)-200)
        fireButton.name = "fire"
        self.addChild(fireButton)
        
        self.joystick.position = CGPoint(x: CGRectGetMidX(self.frame)-400, y: CGRectGetMidY(self.frame)-200)
        self.joystick.name = "joystick"
        self.addChild(joystick)
        
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
        
        self.scoreLabel.position = CGPoint(x: CGRectGetMidX(self.frame)-300, y: CGRectGetMidY(self.frame)+200)
        self.scoreLabel.fontSize = 30
        self.scoreLabel.fontColor = SKColor.orangeColor()
        self.addChild(scoreLabel)
        
        self.scoreEnemyLabel.position = CGPoint(x: CGRectGetMidX(self.frame)+300, y: CGRectGetMidY(self.frame)+200)
        self.scoreEnemyLabel.fontSize = 30
        self.scoreEnemyLabel.fontColor = SKColor.redColor()
        self.addChild(scoreEnemyLabel)
        
        self.runGame()
        
        self.gameIsRunning = true
    }
    
    func addBrush()
    {
        if self.brushesInWorld <= 2
        {
            self.brushesInWorld++
            
            NSLog("Brushes In World: %i", self.brushesInWorld)
            
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
                self.brushesInWorld--
            })
            var sequence = SKAction.sequence([move, removeBrush, vanish])
            brush.runAction(sequence)
        }
    }
    
    func runGame()
    {
        var zombiesToSpawn = 5
        var zombiesSpawned = 0
        
        var speedDivider = self.wavesCompleted / 8
        if speedDivider >= 1
        {
            self.zombieSpeed = CGFloat(speedDivider)
        }
        else
        {
            self.zombieSpeed = 1
        }
        
        while zombiesSpawned != zombiesToSpawn
        {
            if self.wavesCompleted >= 3
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
                    self.addChild(cat1)
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
                    self.addChild(zombie1)
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
                self.addChild(zombie1)
            }
            zombiesSpawned++
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
        self.brushesInWorld--
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
            
            var messageNumberData = NSMutableData()
            var archiver = NSKeyedArchiver(forWritingWithMutableData: messageNumberData)
            archiver.encodeObject("zombies", forKey: "message")
            archiver.encodeInteger(self.zombiesKilled, forKey: "zombies")
            archiver.finishEncoding()
            
            gameViewController1?.sendData(self.match, withData: messageNumberData)
            
            if self.zombiesKilled >= 100
            {
                var Win = SKLabelNode(fontNamed: "TimesNewRoman")
                Win.fontSize = 85
                Win.fontColor = SKColor.orangeColor()
                Win.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
                Win.text = "You Win! GG!"
                self.addChild(Win)
                
                var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
                if var wins = defaults.objectForKey("gamesWon") as? NSInteger
                {
                    wins++
                    self.gameViewController1?.submitWin(wins)
                    defaults.setInteger(wins, forKey: "gamesWon")
                }
                else
                {
                    let wins = 1
                    self.gameViewController1?.submitWin(wins)
                    defaults.setInteger(wins, forKey: "gamesWon")
                }
                
                self.showDisconnectButton()
            }
        }
    }
    
    func monsterDidCollideWithPrincess(monster: SKNode, princess1: SKNode)
    {
        self.princessHealth--
        
        var deadZombie = SKSpriteNode(imageNamed: "ash.png")
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
    
    func gameOver()
    {
        var hide = SKAction.fadeOutWithDuration(0)
        var show = SKAction.fadeInWithDuration(0)
        var wait = SKAction.waitForDuration(1)
        var sequence = SKAction.sequence([hide, wait, show, wait, hide, wait, show, wait, hide, wait, show, wait, hide])
        self.princess1.runAction(sequence)
        
        for aZombie in self.zombies
        {
            aZombie.removeFromParent()
        }
        
        self.zombies.removeAllObjects()
        
        var messageNumberData = NSMutableData()
        var archiver = NSKeyedArchiver(forWritingWithMutableData: messageNumberData)
        archiver.encodeObject("otherPlayerDied", forKey: "message")
        archiver.finishEncoding()
        
        self.gameViewController1?.sendData(self.match, withData: messageNumberData)
        
        var Lose = SKLabelNode(fontNamed: "TimesNewRoman")
        Lose.fontSize = 85
        Lose.fontColor = SKColor.redColor()
        Lose.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        Lose.text = "You Lose! GG!"
        self.addChild(Lose)
        
        self.showDisconnectButton()
    }
    
    func saveDataRecived(data: NSData!, fromMatch match: GKMatch!, fromPlayer playerID: String!)
    {
        var unarchiver = NSKeyedUnarchiver(forReadingWithData: data)
        var message: AnyObject? = unarchiver.decodeObjectForKey("message")
        var messageString = message as? NSString
        
        if messageString == "zombies"
        {
            var zombiesOtherKilled : NSInteger = unarchiver.decodeIntegerForKey("zombies")
            self.scoreEnemyLabel.text = NSString(format: "Enemy Zombies: %i", zombiesOtherKilled) as String
            if zombiesOtherKilled >= 100
            {
                var Lose = SKLabelNode(fontNamed: "TimesNewRoman")
                Lose.fontSize = 85
                Lose.fontColor = SKColor.redColor()
                Lose.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
                Lose.text = "You Lose! GG!"
                self.addChild(Lose)
                
                self.showDisconnectButton()
            }
        }
        
        if messageString == "otherPlayerDied"
        {
            var Win = SKLabelNode(fontNamed: "TimesNewRoman")
            Win.fontSize = 85
            Win.fontColor = SKColor.orangeColor()
            Win.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
            Win.text = "You Win! GG!"
            self.addChild(Win)
            
            var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
            if var wins = defaults.objectForKey("gamesWon") as? NSInteger
            {
                wins++
                self.gameViewController1?.submitWin(wins)
                defaults.setInteger(wins, forKey: "gamesWon")
            }
            else
            {
                let wins = 1
                self.gameViewController1?.submitWin(wins)
                defaults.setInteger(wins, forKey: "gamesWon")
            }
            
            self.showDisconnectButton()
        }
    }
    
    func showDisconnectButton()
    {
        self.gameIsRunning = false
        
        for zombie in self.zombies
        {
            zombie.removeFromParent()
            self.zombies.removeObject(zombie)
        }
        
        var disconnectButton = SKButton(defaultButtonImage: "disconnectButton", activeButtonImage: "disconnectButtonPressed", buttonAction: disconnect)
        disconnectButton.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame)-200)
        self.addChild(disconnectButton)
    }
    
    func disconnect()
    {
        match?.disconnect()
        gameViewController1?.presentMenuScene()
    }
    
    override func update(currentTime: NSTimeInterval)
    {
        var position1 = CGPoint(x: princess1.position.x, y: princess1.position.y+CGFloat(joystick.y*4))
        self.princess1.position = position1
        
        for aZombie2 in self.zombies
        {
            let aZombie2SK = aZombie2 as! SKSpriteNode
            let range = NSRange(location: 0, length: 50)
            var gameOverRange = NSLocationInRange(Int(aZombie2SK.position.x), range)
            if gameOverRange
            {
                self.princessHealth = 0.0
                
                self.princess1.removeFromParent()
                
                self.gameOver()
                break
            }
        }
        
        self.scoreLabel.text = NSString(format: "Zombies You Killed: %i", self.zombiesKilled) as String
        
        var zombiesAlive = 0
        for aZombie in self.zombies
        {
            if aZombie.name == "zombie" || aZombie.name == "catZombie"
            {
                zombiesAlive++
            }
        }
        
        if zombiesAlive == 0 && gameIsRunning == true
        {
            for zombie in self.zombies
            {
                zombie.removeFromParent()
                self.zombies.removeObject(zombie)
            }
            
            self.wavesCompleted++
            
            self.runGame()
        }
    }
}