//
//  MultiplayerScene.swift
//  PrVZ
//
//  Created by jackson on 3/21/15.
//  Copyright (c) 2015 jackson. All rights reserved.
//

import Foundation
import GameKit
import SpriteKit

class MultiplayerScene: SKScene, SKPhysicsContactDelegate
{
    let brushCategory: UInt32 =  1 << 0
    let monsterCategory: UInt32 =  1 << 1
    let princessCategory: UInt32 =  1 << 2
    let enemyProjectileCatagory: UInt32 =  1 << 3
    let brushDisplayCategory: UInt32 =  1 << 4
    let princessDisplayCategory: UInt32 =  1 << 5
    
    var princess1 = Princess()
    var joystick = JCJoystick(controlRadius:50, baseRadius:68, baseColor:SKColor.blueColor(), joystickRadius:50, joystickColor:SKColor.redColor())
    var buttons = SKNode()
    var gameViewController1: GameViewController?
    var wavesCompleted = 0
    var zombieSpeed = 1
    var zombies = NSMutableArray()
    var gameIsRunning = false
    var canPressButtons = true
    var princess2Display = Princess(textureName: "princess2.png")
    var princessPostiton = CGPoint()
    var match: GKMatch?
    var princessHealth = 1.00
    var zombiesKilled = 0
    var recivedNumber : Int64 = 0
    var myNumber : Int64 = 0
    var princessDisplayHealth = 1.00
    var matchStart = false
    var host = true
    var zombiesToSpawnSlider: UISlider?
    var joystickSwitch: UISwitch?
    var zombieSpeedSlider: UISlider?
    
    override func didMoveToView(view: SKView)
    {
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
        
        self.princess1.position = CGPoint(x: CGRectGetMidX(self.frame)-300, y: CGRectGetMidY(self.frame))
        self.princess1.name = "princess"
        self.princess1.physicsBody = SKPhysicsBody(circleOfRadius:princess1.size.width/2)
        self.princess1.physicsBody?.dynamic = true
        self.princess1.physicsBody?.categoryBitMask = self.princessCategory
        self.princess1.physicsBody?.contactTestBitMask = self.monsterCategory
        self.princess1.physicsBody?.collisionBitMask = 0
        self.princess1.physicsBody?.usesPreciseCollisionDetection = true
        self.princess1.zPosition = 2
        self.addChild(self.princess1)
        
        self.princess2Display.position = CGPoint(x: CGRectGetMidX(self.frame)-300, y: CGRectGetMidY(self.frame))
        self.princess2Display.name = "princess2"
        self.princess1.physicsBody = SKPhysicsBody(circleOfRadius:princess1.size.width/2)
        self.princess1.physicsBody?.dynamic = true
        self.princess1.physicsBody?.categoryBitMask = self.princessDisplayCategory
        self.princess1.physicsBody?.contactTestBitMask = self.monsterCategory
        self.princess1.physicsBody?.collisionBitMask = 0
        self.princess1.physicsBody?.usesPreciseCollisionDetection = true
        self.addChild(self.princess2Display)
        
        self.princessPostiton = self.princess1.position
        
        var fireButton = SKButton(defaultButtonImage: "fireButton", activeButtonImage: "fireButtonPressed", buttonAction: self.addBrush)
        fireButton.position = CGPoint(x: CGRectGetMidX(self.frame)+400, y: CGRectGetMidY(self.frame)-200)
        fireButton.name = "fire"
        self.addChild(fireButton)
        
        self.joystick.position = CGPoint(x: CGRectGetMidX(self.frame)-400, y: CGRectGetMidY(self.frame)-200)
        self.joystick.name = "joystick"
        self.addChild(joystick)
        
        var startButton = SKButton(defaultButtonImage: "startButtonGame", activeButtonImage: "startButtonGamePressed", buttonAction: sendNumber)
        startButton.position = CGPoint(x: CGRectGetMidX(self.frame)-300, y: CGRectGetMidY(self.frame)+200)
        startButton.name = "start"
        self.buttons.addChild(startButton)
        
        var disconnectButton = SKButton(defaultButtonImage: "disconnectButton", activeButtonImage: "disconnectButtonPressed", buttonAction: disconnect)
        disconnectButton.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame)-200)
        self.buttons.addChild(disconnectButton)
        
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
    }
    
    func sendNumber()
    {
        self.myNumber = Int64(arc4random())
        var messageNumberData = NSMutableData()
        var archiver2 = NSKeyedArchiver(forWritingWithMutableData: messageNumberData)
        archiver2.encodeObject("randomNumber", forKey: "message")
        archiver2.encodeInt64(self.myNumber, forKey: "randomNumber")
        archiver2.finishEncoding()
        
        gameViewController1?.sendData(self.match, withData: messageNumberData)
    }
    
    func runGame()
    {
        if myNumber <= recivedNumber && host == true
        {
            let numberOfZombiesToMakeAsAFloat = self.zombiesToSpawnSlider?.value
            var zombiesToSpawn = NSInteger(numberOfZombiesToMakeAsAFloat!)
            
            var zombiesSpawned = 0
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
                        if self.recivedNumber >= self.myNumber
                        {
                            moveToPrincess = SKAction.moveToY(self.princess1.position.y, duration: 1)
                        }
                        else
                        {
                            moveToPrincess = SKAction.moveToY(self.princess2Display.position.y, duration: 1)
                        }
                        
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
            
            var zombiesToSend = NSMutableArray()
            
            for aZombieNot in self.zombies
            {
                var aZombie = aZombieNot as! GenericZombie
                var zombie = NSMutableDictionary()
                zombie.setObject(aZombie.health, forKey: "health")
                NSLog("  Health: %i", aZombie.health)
                zombie.setObject(aZombie.position.x, forKey: "posx")
                NSLog("  Posx: %f", Float(aZombie.position.x))
                zombie.setObject(aZombie.position.y, forKey: "posy")
                NSLog("  Posy: %f", Float(aZombie.position.y))
                zombie.setObject(aZombie.name!, forKey: "name")
                NSLog("  Name: %@", aZombie.name!)
                zombie.setObject(aZombie.uuid, forKey: "uuid")
                NSLog("  uuid: %@", aZombie.uuid)
                
                self.addChild(aZombie as SKNode)
                zombiesToSend.addObject(zombie)
            }
            
            var messageZombiesData = NSMutableData()
            var archiver = NSKeyedArchiver(forWritingWithMutableData: messageZombiesData)
            archiver.encodeObject("zombies", forKey: "message")
            archiver.encodeObject(zombiesToSend, forKey: "zombiesArray")
            archiver.finishEncoding()
            
            gameViewController1?.sendData(self.match, withData: messageZombiesData)
            self.gameIsRunning = true
        }
        else
        {
            NSLog("Not Host... Waiting for Zombies...")
        }
        
        self.canPressButtons = false
    }
    
    func addBrush()
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
        var move = SKAction.moveToX(1000, duration: 1)
        var vanish = SKAction.removeFromParent()
        var sequence = SKAction.sequence([move, vanish])
        brush.runAction(sequence)
        
        var messageDataBrush = NSMutableData()
        var archiver = NSKeyedArchiver(forWritingWithMutableData: messageDataBrush)
        
        archiver.encodeObject("brush", forKey: "message")
        archiver.encodeCGPoint(brush.position, forKey: "currentBrush")
        archiver.finishEncoding()
        
        gameViewController1?.sendData(self.match, withData: messageDataBrush)
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
        if ((secondBody.categoryBitMask & self.brushDisplayCategory) != 0 && (firstBody.categoryBitMask & self.monsterCategory) != 0)
        {
            if secondBody.node != nil
            {
                self.projectileDisplayDidCollideWithMonster(secondBody.node!, monster: firstBody.node!)
            }
        }
        if ((secondBody.categoryBitMask & self.princessDisplayCategory) != 0 && (firstBody.categoryBitMask & self.monsterCategory) != 0)
        {
            self.monsterDidCollideWithPrincessDisplay(firstBody.node!, princess1: secondBody.node!)
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
        }
        
        var messageDataZombie = NSMutableData()
        var archiver = NSKeyedArchiver(forWritingWithMutableData: messageDataZombie)
        archiver.encodeObject("zombieHealthChanged", forKey: "message")
        archiver.encodeObject(monsterSK.uuid, forKey: "zombieThatChanged")
        archiver.finishEncoding()
        
        gameViewController1?.sendData(self.match, withData: messageDataZombie)
    }
    
    func monsterDidCollideWithPrincess(monster: SKNode, princess1: SKNode)
    {
        self.princessHealth--
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
            princess1.removeFromParent()
            joystick.removeFromParent()
            if princessDisplayHealth <= 0
            {
                self.gameOver()
            }
        }
        enemyProjectile.removeFromParent()
        NSLog("%f", self.princessHealth)
    }
    
    func monsterDidCollideWithPrincessDisplay(monster: SKNode, princess1: SKNode)
    {
        self.princessHealth--
        if princessDisplayHealth <= 0
        {
            princess1.removeFromParent()
            if princessHealth <= 0
            {
                self.gameOver()
            }
        }
    }
    
    func enemyProjectileDidCollideWithPrincessDisplay(enemyProjectile: SKNode, princess1: SKNode)
    {
        self.princessDisplayHealth -= 0.25
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
        if princessDisplayHealth <= 0
        {
            princess2Display.removeFromParent()
            if princessHealth <= 0
            {
                self.gameOver()
            }
        }
        enemyProjectile.removeFromParent()
        NSLog("%f", self.princessDisplayHealth)
    }
    
    func gameOver()
    {
        self.gameIsRunning = false
        
        var zombiesKilledLabel = SKLabelNode(fontNamed: "TimesNewRoman")
        zombiesKilledLabel.name = "zombiesKilledLabel"
        zombiesKilledLabel.fontColor = SKColor.redColor()
        zombiesKilledLabel.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        self.addChild(zombiesKilledLabel)
        
        for zombie in self.zombies
        {
            zombie.removeFromParent()
            self.zombies.removeObject(zombie)
        }
    }
    
    func disconnect()
    {
        match?.disconnect()
        gameViewController1?.presentMenuScene()
    }
    
    func projectileDisplayDidCollideWithMonster(projectile: SKNode, monster: SKNode)
    {
        projectile.removeFromParent()
    }
    
    func saveDataRecived(data: NSData!, fromMatch match: GKMatch!, fromPlayer playerID: String!)
    {
        var unarchiver = NSKeyedUnarchiver(forReadingWithData: data)
        var message: AnyObject? = unarchiver.decodeObjectForKey("message")
        var messageString = message as? NSString
        if messageString == "princessMove"
        {
            var position : CGPoint = unarchiver.decodeCGPointForKey("position")
            self.princess2Display.position = position
        }
        if messageString == "brush"
        {
            var brushPos : CGPoint = unarchiver.decodeCGPointForKey("currentBrush")
            
            var brush = SKSpriteNode(imageNamed: "brush.png")
            brush.name = "brush"
            brush.position = brushPos
            self.addChild(brush)
            brush.runAction(SKAction.moveToX(1000, duration: 1))
            brush.runAction(SKAction.waitForDuration(1))
            brush.physicsBody = SKPhysicsBody(circleOfRadius:brush.size.width/2)
            brush.physicsBody?.dynamic = true
            brush.physicsBody?.categoryBitMask = self.brushDisplayCategory
            brush.physicsBody?.contactTestBitMask = self.monsterCategory
            brush.physicsBody?.collisionBitMask = 0
            brush.physicsBody?.usesPreciseCollisionDetection = true
            var move = SKAction.moveToX(1000, duration: 1)
            var vanish = SKAction.removeFromParent()
            var sequence = SKAction.sequence([move, vanish])
            brush.runAction(sequence)
        }
        if messageString == "randomNumber"
        {
            self.recivedNumber = unarchiver.decodeInt64ForKey("randomNumber")
            
            self.runGame()
        }
        if messageString == "zombies"
        {
            var host = false
            
            var zombiesArray: NSMutableArray = unarchiver.decodeObjectForKey("zombiesArray") as! NSMutableArray
            for aZombieNot in zombiesArray
            {
                var zombie = GenericZombie()
                
                let aZombie = aZombieNot as? NSDictionary
                
                let type = aZombie?.objectForKey("name") as? NSString
                if type == "zombie"
                {
                    zombie = GenericZombie()
                    var moveBy = SKAction.moveByX(CGFloat(-self.zombieSpeed), y: 0, duration: 0.1)
                    zombie.runAction(SKAction.repeatActionForever(moveBy))
                    zombie.name = "zombie"
                }
                if type == "catZombie"
                {
                    zombie = CatZombie()
                    var moveBy = SKAction.moveByX(CGFloat(-self.zombieSpeed), y: 0, duration: 0.1)
                    zombie.runAction(SKAction.repeatActionForever(moveBy))
                    
                    var moveToPrincess = SKAction.moveToY(self.princess1.position.y, duration: 1)
                    if self.recivedNumber < self.myNumber
                    {
                        moveToPrincess = SKAction.moveToY(self.princess1.position.y, duration: 1)
                    }
                    else
                    {
                        moveToPrincess = SKAction.moveToY(self.princess2Display.position.y, duration: 1)
                    }
                    
                    var sequence = SKAction.sequence([moveToPrincess, SKAction.runBlock({
                        zombie.texture = SKTexture(imageNamed: "catOpen.png")
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
                        zombie.addChild(hairball)
                    }), SKAction.waitForDuration(1), SKAction.runBlock({
                        zombie.texture = SKTexture(imageNamed: "cat.png")
                    }), SKAction.waitForDuration(1),SKAction.runBlock({
                        NSLog("%f", self.princess1.position.y)
                    })])
                    zombie.runAction(SKAction.repeatActionForever(sequence))
                    
                    zombie.name = "catZombie"
                }
                
                let posx = aZombie?.objectForKey("posx") as? Float
                let posy = aZombie?.objectForKey("posy") as? Float
                zombie.position.x = CGFloat(posx!)
                zombie.position.y = CGFloat(posy!)
                
                let uuid = aZombie?.objectForKey("uuid") as? NSString
                zombie.uuid = uuid! as String
                
                NSLog("  Recived: Health: %i", zombie.health)
                NSLog("  Recived: Posx: %f", Float(zombie.position.x))
                NSLog("  Recived: Posy: %f", Float(zombie.position.y))
                NSLog("  Recived: Name: %@", zombie.name!)
                NSLog("  Recived: uuid: %@", zombie.uuid)
                
                self.zombies.addObject(zombie)
                self.addChild(zombie)
                
                self.gameIsRunning = true
            }
        }
        if messageString == "zombieHealthChanged"
        {
            let zombieUUID: NSString = unarchiver.decodeObjectForKey("zombieThatChanged") as! NSString
            for aZombieNot in self.zombies
            {
                var aZombie = aZombieNot as? GenericZombie
                let uuid = aZombie?.uuid
                if uuid == zombieUUID
                {
                    aZombie?.health--
                    var healthLostLabel = SKLabelNode(fontNamed: "TimesNewRoman")
                    healthLostLabel.text = "-1"
                    healthLostLabel.fontColor = SKColor.redColor()
                    healthLostLabel.fontSize = 32
                    if aZombie?.name == "catZombie"
                    {
                        let pos1x = aZombie?.position.x
                        let pos1y = aZombie?.position.y
                        healthLostLabel.position = CGPoint(x: pos1y!, y: pos1y!+25)
                    }
                    if aZombie?.name == "zombie"
                    {
                        let pos1x = aZombie?.position.x
                        let pos1y = aZombie?.position.y
                        healthLostLabel.position = CGPoint(x: pos1x!, y: pos1y!+75)
                    }
                    healthLostLabel.runAction(SKAction.moveToY(healthLostLabel.position.y+20, duration: 0.4))
                    healthLostLabel.runAction(SKAction.sequence([SKAction.fadeOutWithDuration(0.4), SKAction.runBlock({
                        healthLostLabel.removeFromParent()
                    })]))
                    self.addChild(healthLostLabel)
                    if aZombie?.health < 1
                    {
                        var deadZombie = SKSpriteNode(imageNamed: "ash.png")
                        deadZombie.name = "ash"
                        let pos1 = aZombie?.position
                        deadZombie.position = pos1!
                        aZombie?.removeFromParent()
                        self.zombies.removeObject(aZombie!)
                        self.zombies.addObject(deadZombie)
                        self.addChild(deadZombie)
                        
                        self.zombiesKilled++
                    }
                }
            }
        }
    }
    
    override func update(currentTime: NSTimeInterval)
    {
        var position1 = CGPoint(x: princess1.position.x, y: princess1.position.y+CGFloat(joystick.y*4))
        self.princess1.position = position1
        
        if position1 != self.princessPostiton
        {
            var messageData = NSMutableData()
            var archiver = NSKeyedArchiver(forWritingWithMutableData: messageData)
            archiver.encodeObject("princessMove", forKey: "message")
            archiver.encodeCGPoint(position1, forKey: "position")
            archiver.finishEncoding()
            
            gameViewController1?.sendData(self.match, withData: messageData)
            
            self.princessPostiton = position1
            
            NSLog("sending princess position == %d, %d", position1.x, position1.y)
            println("Sending to match: \(self.match)")
        }
        
        if (self.myNumber == 0)
        {
            self.sendNumber()
        }
        
        for aZombie2 in self.zombies
        {
            let aZombie2SK = aZombie2 as! SKSpriteNode
            let range = NSRange(location: 0, length: 50)
            var gameOverRange = NSLocationInRange(Int(aZombie2SK.position.x), range)
            if gameOverRange
            {
                self.princessHealth = 0.0
                self.princessDisplayHealth = 0.0
                
                self.princess1.removeFromParent()
                self.princess2Display.removeFromParent()
                
                self.gameOver()
                break
            }
        }
        
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
            
            self.runGame()
        }
    }
}