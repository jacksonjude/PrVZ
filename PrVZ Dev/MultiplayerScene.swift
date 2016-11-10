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
    var joystick = JCJoystick(controlRadius:50, baseRadius:68, baseColor:SKColor.blue, joystickRadius:50, joystickColor:SKColor.red)
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
    
    override func didMove(to view: SKView)
    {
        physicsWorld.gravity = CGVector(dx: 0,dy: 0)
        self.physicsWorld.contactDelegate = self
        
        let wallEnd = SKShapeNode()
        let path = CGMutablePath()
        path.addRect(CGRect(x: 0, y: 0, width: 60, height: 3000))
        wallEnd.path = path
        wallEnd.fillColor = SKColor.gray
        wallEnd.position = CGPoint(x: self.frame.midX-450, y: self.frame.midY-400)
        wallEnd.name = "wallEnd"
        self.addChild(wallEnd)
        
        self.princess1.position = CGPoint(x: self.frame.midX-300, y: self.frame.midY)
        self.princess1.name = "princess"
        self.princess1.physicsBody = SKPhysicsBody(circleOfRadius:princess1.size.width/2)
        self.princess1.physicsBody?.isDynamic = true
        self.princess1.physicsBody?.categoryBitMask = self.princessCategory
        self.princess1.physicsBody?.contactTestBitMask = self.monsterCategory
        self.princess1.physicsBody?.collisionBitMask = 0
        self.princess1.physicsBody?.usesPreciseCollisionDetection = true
        self.princess1.zPosition = 2
        self.addChild(self.princess1)
        
        self.princess2Display.position = CGPoint(x: self.frame.midX-300, y: self.frame.midY)
        self.princess2Display.name = "princess2"
        self.princess1.physicsBody = SKPhysicsBody(circleOfRadius:princess1.size.width/2)
        self.princess1.physicsBody?.isDynamic = true
        self.princess1.physicsBody?.categoryBitMask = self.princessDisplayCategory
        self.princess1.physicsBody?.contactTestBitMask = self.monsterCategory
        self.princess1.physicsBody?.collisionBitMask = 0
        self.princess1.physicsBody?.usesPreciseCollisionDetection = true
        self.addChild(self.princess2Display)
        
        self.princessPostiton = self.princess1.position
        
        let fireButton = SKButton(defaultButtonImage: "fireButton", activeButtonImage: "fireButtonPressed", buttonAction: self.addBrush)
        fireButton.position = CGPoint(x: self.frame.midX+400, y: self.frame.midY-200)
        fireButton.name = "fire"
        self.addChild(fireButton)
        
        self.joystick?.position = CGPoint(x: self.frame.midX-400, y: self.frame.midY-200)
        self.joystick?.name = "joystick"
        self.addChild(joystick!)
        
        let startButton = SKButton(defaultButtonImage: "startButtonGame", activeButtonImage: "startButtonGamePressed", buttonAction: sendNumber)
        startButton.position = CGPoint(x: self.frame.midX-300, y: self.frame.midY+200)
        startButton.name = "start"
        self.buttons.addChild(startButton)
        
        let disconnectButton = SKButton(defaultButtonImage: "disconnectButton", activeButtonImage: "disconnectButtonPressed", buttonAction: disconnect)
        disconnectButton.position = CGPoint(x: self.frame.midX, y: self.frame.midY-200)
        self.buttons.addChild(disconnectButton)
        
        self.addChild(self.buttons)
        
        let bar = SKShapeNode()
        bar.path = CGPath(rect: CGRect(x: 32, y: 0, width: 960, height: 235), transform: nil)
        bar.fillColor = SKColor.gray
        bar.name = "bar"
        bar.position = CGPoint(x: 0, y: self.frame.midY+125)
        self.addChild(bar)
        
        self.zombiesToSpawnSlider?.isHidden = true
        self.zombiesToSpawnSlider?.isUserInteractionEnabled = false
        self.zombiesToSpawnSlider?.maximumValue = 9
        self.zombiesToSpawnSlider?.minimumValue = 3
        
        self.joystickSwitch?.isHidden = true
        self.joystickSwitch?.isUserInteractionEnabled = false
        
        self.zombieSpeedSlider?.isHidden = true
        self.zombieSpeedSlider?.isUserInteractionEnabled = false
        self.zombieSpeedSlider?.minimumValue = 1
        self.zombieSpeedSlider?.maximumValue = 4
    }
    
    func sendNumber()
    {
        self.myNumber = Int64(arc4random())
        let messageNumberData = NSMutableData()
        let archiver2 = NSKeyedArchiver(forWritingWith: messageNumberData)
        archiver2.encode("randomNumber", forKey: "message")
        archiver2.encode(self.myNumber, forKey: "randomNumber")
        archiver2.finishEncoding()
        
        gameViewController1?.sendData(self.match, withData: messageNumberData as Data!)
    }
    
    func runGame()
    {
        if myNumber <= recivedNumber && host == true
        {
            let numberOfZombiesToMakeAsAFloat = self.zombiesToSpawnSlider?.value
            let zombiesToSpawn = NSInteger(numberOfZombiesToMakeAsAFloat!)
            
            var zombiesSpawned = 0
            while zombiesSpawned != zombiesToSpawn
            {
                if self.wavesCompleted >= 3
                {
                    let spawnCat = CGFloat(arc4random()%3)
                    if spawnCat == 2
                    {
                        let cat1 = CatZombie()
                        let yPos = CGFloat((arc4random()%150)+150)
                        let xPos = CGFloat((arc4random()%150)+150)
                        cat1.name = "catZombie"
                        cat1.health = self.wavesCompleted / 4
                        cat1.physicsBody = SKPhysicsBody(circleOfRadius:cat1.size.width/2)
                        cat1.physicsBody?.isDynamic = true
                        cat1.physicsBody?.categoryBitMask = self.monsterCategory
                        cat1.physicsBody?.contactTestBitMask = self.princessCategory
                        cat1.physicsBody?.collisionBitMask = 0
                        cat1.physicsBody?.usesPreciseCollisionDetection = true
                        cat1.position = CGPoint(x: self.frame.midX+xPos, y: yPos)
                        let moveBy = SKAction.moveBy(x: CGFloat(-self.zombieSpeed), y: 0, duration: 0.1)
                        cat1.run(SKAction.repeatForever(moveBy))
                        
                        var moveToPrincess = SKAction.moveTo(y: self.princess1.position.y, duration: 1)
                        if self.recivedNumber >= self.myNumber
                        {
                            moveToPrincess = SKAction.moveTo(y: self.princess1.position.y, duration: 1)
                        }
                        else
                        {
                            moveToPrincess = SKAction.moveTo(y: self.princess2Display.position.y, duration: 1)
                        }
                        
                        let sequence = SKAction.sequence([moveToPrincess, SKAction.run({
                            cat1.texture = SKTexture(imageNamed: "catOpen.png")
                        }), SKAction.wait(forDuration: 1),SKAction.run({
                            let hairball = SKSpriteNode(imageNamed: "hairball.png")
                            hairball.position = self.position
                            hairball.run(SKAction.repeatForever(SKAction.moveTo(x: -1000, duration: 2)))
                            hairball.name = "hairball"
                            hairball.physicsBody = SKPhysicsBody(circleOfRadius:hairball.size.width/2)
                            hairball.physicsBody?.isDynamic = true
                            hairball.physicsBody?.categoryBitMask = self.enemyProjectileCatagory
                            hairball.physicsBody?.contactTestBitMask = self.princessCategory
                            hairball.physicsBody?.collisionBitMask = 0
                            hairball.physicsBody?.usesPreciseCollisionDetection = true
                            cat1.addChild(hairball)
                        }), SKAction.wait(forDuration: 1), SKAction.run({
                            cat1.texture = SKTexture(imageNamed: "cat.png")
                        }), SKAction.wait(forDuration: 1),SKAction.run({
                            NSLog("%f", self.princess1.position.y)
                        })])
                        cat1.run(SKAction.repeatForever(sequence))
                        self.zombies.add(cat1)
                    }
                    else
                    {
                        let zombie1 = GenericZombie()
                        let yPos = CGFloat((arc4random()%150)+150)
                        let xPos = CGFloat((arc4random()%150)+150)
                        zombie1.health = self.wavesCompleted
                        zombie1.princess = self.childNode(withName: "princess") as! Princess
                        zombie1.position = CGPoint(x: self.frame.midX+xPos, y: yPos)
                        zombie1.name = "zombie"
                        zombie1.physicsBody = SKPhysicsBody(circleOfRadius:zombie1.size.width/2)
                        zombie1.physicsBody?.isDynamic = true
                        zombie1.physicsBody?.categoryBitMask = self.monsterCategory
                        zombie1.physicsBody?.contactTestBitMask = self.princessCategory
                        zombie1.physicsBody?.collisionBitMask = 0
                        zombie1.physicsBody?.usesPreciseCollisionDetection = true
                        let moveBy = SKAction.moveBy(x: CGFloat(-self.zombieSpeed), y: 0, duration: 0.1)
                        zombie1.run(SKAction.repeatForever(moveBy))
                        self.zombies.add(zombie1)
                    }
                    
                }
                else
                {
                    let zombie1 = GenericZombie()
                    let yPos = CGFloat((arc4random()%150)+150)
                    let xPos = CGFloat((arc4random()%150)+150)
                    zombie1.health = self.wavesCompleted
                    zombie1.princess = self.childNode(withName: "princess") as! Princess
                    zombie1.position = CGPoint(x: self.frame.midX+xPos, y: yPos)
                    zombie1.name = "zombie"
                    zombie1.physicsBody = SKPhysicsBody(circleOfRadius:zombie1.size.width/2)
                    zombie1.physicsBody?.isDynamic = true
                    zombie1.physicsBody?.categoryBitMask = self.monsterCategory
                    zombie1.physicsBody?.contactTestBitMask = self.princessCategory
                    zombie1.physicsBody?.collisionBitMask = 0
                    zombie1.physicsBody?.usesPreciseCollisionDetection = true
                    let moveBy = SKAction.moveBy(x: CGFloat(-self.zombieSpeed), y: 0, duration: 0.1)
                    zombie1.run(SKAction.repeatForever(moveBy))
                    self.zombies.add(zombie1)
                }
                zombiesSpawned += 1
            }
            
            let zombiesToSend = NSMutableArray()
            
            for aZombieNot in self.zombies
            {
                let aZombie = aZombieNot as! GenericZombie
                let zombie = NSMutableDictionary()
                zombie.setObject(aZombie.health, forKey: "health" as NSCopying)
                NSLog("  Health: %i", aZombie.health)
                zombie.setObject(aZombie.position.x, forKey: "posx" as NSCopying)
                NSLog("  Posx: %f", Float(aZombie.position.x))
                zombie.setObject(aZombie.position.y, forKey: "posy" as NSCopying)
                NSLog("  Posy: %f", Float(aZombie.position.y))
                zombie.setObject(aZombie.name!, forKey: "name" as NSCopying)
                NSLog("  Name: %@", aZombie.name!)
                zombie.setObject(aZombie.uuid, forKey: "uuid" as NSCopying)
                NSLog("  uuid: %@", aZombie.uuid)
                
                self.addChild(aZombie as SKNode)
                zombiesToSend.add(zombie)
            }
            
            let messageZombiesData = NSMutableData()
            let archiver = NSKeyedArchiver(forWritingWith: messageZombiesData)
            archiver.encode("zombies", forKey: "message")
            archiver.encode(zombiesToSend, forKey: "zombiesArray")
            archiver.finishEncoding()
            
            gameViewController1?.sendData(self.match, withData: messageZombiesData as Data!)
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
        let brush = SKSpriteNode(imageNamed: "brush.png")
        brush.name = "brush"
        brush.position = CGPoint(x: self.princess1.position.x, y: self.princess1.position.y)
        self.addChild(brush)
        brush.run(SKAction.moveTo(x: 1000, duration: 1))
        brush.run(SKAction.wait(forDuration: 1))
        brush.physicsBody = SKPhysicsBody(circleOfRadius:brush.size.width/2)
        brush.physicsBody?.isDynamic = true
        brush.physicsBody?.categoryBitMask = self.brushCategory
        brush.physicsBody?.contactTestBitMask = self.monsterCategory
        brush.physicsBody?.collisionBitMask = 0
        brush.physicsBody?.usesPreciseCollisionDetection = true
        let move = SKAction.moveTo(x: 1000, duration: 1)
        let vanish = SKAction.removeFromParent()
        let sequence = SKAction.sequence([move, vanish])
        brush.run(sequence)
        
        let messageDataBrush = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: messageDataBrush)
        
        archiver.encode("brush", forKey: "message")
        archiver.encode(brush.position, forKey: "currentBrush")
        archiver.finishEncoding()
        
        gameViewController1?.sendData(self.match, withData: messageDataBrush as Data!)
    }
    
    func didBegin(_ contact: SKPhysicsContact)
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
    
    func projectileDidCollideWithMonster(_ projectile: SKNode, monster: SKNode)
    {
        projectile.removeFromParent()
        let monsterSK = monster as! GenericZombie
        monsterSK.health -= 1
        let healthLostLabel = SKLabelNode(fontNamed: "TimesNewRoman")
        healthLostLabel.text = "-1"
        healthLostLabel.fontColor = SKColor.red
        healthLostLabel.fontSize = 32
        if monster.name == "catZombie"
        {
            healthLostLabel.position = CGPoint(x: monster.position.x, y: monster.position.y+25)
        }
        if monster.name == "zombie"
        {
            healthLostLabel.position = CGPoint(x: monster.position.x, y: monster.position.y+75)
        }
        healthLostLabel.run(SKAction.moveTo(y: healthLostLabel.position.y+20, duration: 0.4))
        healthLostLabel.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0.4), SKAction.run({
            healthLostLabel.removeFromParent()
        })]))
        self.addChild(healthLostLabel)
        if monsterSK.health < 1
        {
            let deadZombie = SKSpriteNode(imageNamed: "ash.png")
            deadZombie.name = "ash"
            deadZombie.position = monster.position
            monster.removeFromParent()
            self.zombies.remove(monster)
            self.zombies.add(deadZombie)
            self.addChild(deadZombie)
            
            self.zombiesKilled += 1
        }
        
        let messageDataZombie = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: messageDataZombie)
        archiver.encode("zombieHealthChanged", forKey: "message")
        archiver.encode(monsterSK.uuid, forKey: "zombieThatChanged")
        archiver.finishEncoding()
        
        gameViewController1?.sendData(self.match, withData: messageDataZombie as Data!)
    }
    
    func monsterDidCollideWithPrincess(_ monster: SKNode, princess1: SKNode)
    {
        self.princessHealth -= 1
        if princessHealth <= 0
        {
            self.gameOver()
        }
    }
    
    func enemyProjectileDidCollideWithPrincess(_ enemyProjectile: SKNode, princess1: SKNode)
    {
        self.princessHealth -= 0.25
        let healthLostLabel = SKLabelNode(fontNamed: "TimesNewRoman")
        healthLostLabel.text = "-0.25"
        healthLostLabel.fontColor = SKColor.red
        healthLostLabel.fontSize = 32
        healthLostLabel.position = CGPoint(x: princess1.position.x, y: princess1.position.y+100)
        healthLostLabel.run(SKAction.moveTo(y: healthLostLabel.position.y+20, duration: 0.4))
        healthLostLabel.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0.4), SKAction.run({
            healthLostLabel.removeFromParent()
        })]))
        self.addChild(healthLostLabel)
        if princessHealth <= 0
        {
            princess1.removeFromParent()
            joystick?.removeFromParent()
            if princessDisplayHealth <= 0
            {
                self.gameOver()
            }
        }
        enemyProjectile.removeFromParent()
        NSLog("%f", self.princessHealth)
    }
    
    func monsterDidCollideWithPrincessDisplay(_ monster: SKNode, princess1: SKNode)
    {
        self.princessHealth -= 1
        if princessDisplayHealth <= 0
        {
            princess1.removeFromParent()
            if princessHealth <= 0
            {
                self.gameOver()
            }
        }
    }
    
    func enemyProjectileDidCollideWithPrincessDisplay(_ enemyProjectile: SKNode, princess1: SKNode)
    {
        self.princessDisplayHealth -= 0.25
        let healthLostLabel = SKLabelNode(fontNamed: "TimesNewRoman")
        healthLostLabel.text = "-0.25"
        healthLostLabel.fontColor = SKColor.red
        healthLostLabel.fontSize = 32
        healthLostLabel.position = CGPoint(x: princess1.position.x, y: princess1.position.y+100)
        healthLostLabel.run(SKAction.moveTo(y: healthLostLabel.position.y+20, duration: 0.4))
        healthLostLabel.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0.4), SKAction.run({
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
        
        let zombiesKilledLabel = SKLabelNode(fontNamed: "TimesNewRoman")
        zombiesKilledLabel.name = "zombiesKilledLabel"
        zombiesKilledLabel.fontColor = SKColor.red
        zombiesKilledLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        self.addChild(zombiesKilledLabel)
        
        for zombie in self.zombies
        {
            (zombie as! SKSpriteNode).removeFromParent()
            self.zombies.remove(zombie)
        }
    }
    
    func disconnect()
    {
        match?.disconnect()
        gameViewController1?.presentMenuScene()
    }
    
    func projectileDisplayDidCollideWithMonster(_ projectile: SKNode, monster: SKNode)
    {
        projectile.removeFromParent()
    }
    
    func saveDataRecived(_ data: Data!, fromMatch match: GKMatch!, fromPlayer playerID: String!)
    {
        let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
        let message: AnyObject? = unarchiver.decodeObject(forKey: "message") as AnyObject?
        let messageString = message as? NSString
        if messageString == "princessMove"
        {
            let position : CGPoint = unarchiver.decodeCGPoint(forKey: "position")
            self.princess2Display.position = position
        }
        if messageString == "brush"
        {
            let brushPos : CGPoint = unarchiver.decodeCGPoint(forKey: "currentBrush")
            
            let brush = SKSpriteNode(imageNamed: "brush.png")
            brush.name = "brush"
            brush.position = brushPos
            self.addChild(brush)
            brush.run(SKAction.moveTo(x: 1000, duration: 1))
            brush.run(SKAction.wait(forDuration: 1))
            brush.physicsBody = SKPhysicsBody(circleOfRadius:brush.size.width/2)
            brush.physicsBody?.isDynamic = true
            brush.physicsBody?.categoryBitMask = self.brushDisplayCategory
            brush.physicsBody?.contactTestBitMask = self.monsterCategory
            brush.physicsBody?.collisionBitMask = 0
            brush.physicsBody?.usesPreciseCollisionDetection = true
            let move = SKAction.moveTo(x: 1000, duration: 1)
            let vanish = SKAction.removeFromParent()
            let sequence = SKAction.sequence([move, vanish])
            brush.run(sequence)
        }
        if messageString == "randomNumber"
        {
            self.recivedNumber = unarchiver.decodeInt64(forKey: "randomNumber")
            
            self.runGame()
        }
        if messageString == "zombies"
        {
            self.host = false
            
            let zombiesArray: NSMutableArray = unarchiver.decodeObject(forKey: "zombiesArray") as! NSMutableArray
            for aZombieNot in zombiesArray
            {
                var zombie = GenericZombie()
                
                let aZombie = aZombieNot as? NSDictionary
                
                let type = aZombie?.object(forKey: "name") as? NSString
                if type == "zombie"
                {
                    zombie = GenericZombie()
                    let moveBy = SKAction.moveBy(x: CGFloat(-self.zombieSpeed), y: 0, duration: 0.1)
                    zombie.run(SKAction.repeatForever(moveBy))
                    zombie.name = "zombie"
                }
                if type == "catZombie"
                {
                    zombie = CatZombie()
                    let moveBy = SKAction.moveBy(x: CGFloat(-self.zombieSpeed), y: 0, duration: 0.1)
                    zombie.run(SKAction.repeatForever(moveBy))
                    
                    var moveToPrincess = SKAction.moveTo(y: self.princess1.position.y, duration: 1)
                    if self.recivedNumber < self.myNumber
                    {
                        moveToPrincess = SKAction.moveTo(y: self.princess1.position.y, duration: 1)
                    }
                    else
                    {
                        moveToPrincess = SKAction.moveTo(y: self.princess2Display.position.y, duration: 1)
                    }
                    
                    let sequence = SKAction.sequence([moveToPrincess, SKAction.run({
                        zombie.texture = SKTexture(imageNamed: "catOpen.png")
                    }), SKAction.wait(forDuration: 1),SKAction.run({
                        let hairball = SKSpriteNode(imageNamed: "hairball.png")
                        hairball.position = self.position
                        hairball.run(SKAction.repeatForever(SKAction.moveTo(x: -1000, duration: 2)))
                        hairball.name = "hairball"
                        hairball.physicsBody = SKPhysicsBody(circleOfRadius:hairball.size.width/2)
                        hairball.physicsBody?.isDynamic = true
                        hairball.physicsBody?.categoryBitMask = self.enemyProjectileCatagory
                        hairball.physicsBody?.contactTestBitMask = self.princessCategory
                        hairball.physicsBody?.collisionBitMask = 0
                        hairball.physicsBody?.usesPreciseCollisionDetection = true
                        zombie.addChild(hairball)
                    }), SKAction.wait(forDuration: 1), SKAction.run({
                        zombie.texture = SKTexture(imageNamed: "cat.png")
                    }), SKAction.wait(forDuration: 1),SKAction.run({
                        NSLog("%f", self.princess1.position.y)
                    })])
                    zombie.run(SKAction.repeatForever(sequence))
                    
                    zombie.name = "catZombie"
                }
                
                let posx = aZombie?.object(forKey: "posx") as? Float
                let posy = aZombie?.object(forKey: "posy") as? Float
                zombie.position.x = CGFloat(posx!)
                zombie.position.y = CGFloat(posy!)
                
                let uuid = aZombie?.object(forKey: "uuid") as? NSString
                zombie.uuid = uuid! as String
                
                NSLog("  Recived: Health: %i", zombie.health)
                NSLog("  Recived: Posx: %f", Float(zombie.position.x))
                NSLog("  Recived: Posy: %f", Float(zombie.position.y))
                NSLog("  Recived: Name: %@", zombie.name!)
                NSLog("  Recived: uuid: %@", zombie.uuid)
                
                self.zombies.add(zombie)
                self.addChild(zombie)
                
                self.gameIsRunning = true
            }
        }
        if messageString == "zombieHealthChanged"
        {
            let zombieUUID: NSString = unarchiver.decodeObject(forKey: "zombieThatChanged") as! NSString
            for aZombieNot in self.zombies
            {
                let aZombie = aZombieNot as? GenericZombie
                let uuid = aZombie?.uuid
                if uuid! == zombieUUID as String
                {
                    aZombie?.health -= 1
                    let healthLostLabel = SKLabelNode(fontNamed: "TimesNewRoman")
                    healthLostLabel.text = "-1"
                    healthLostLabel.fontColor = SKColor.red
                    healthLostLabel.fontSize = 32
                    if aZombie?.name == "catZombie"
                    {
                        let pos1x = aZombie?.position.x
                        let pos1y = aZombie?.position.y
                        healthLostLabel.position = CGPoint(x: pos1x!, y: pos1y!+25)
                    }
                    if aZombie?.name == "zombie"
                    {
                        let pos1x = aZombie?.position.x
                        let pos1y = aZombie?.position.y
                        healthLostLabel.position = CGPoint(x: pos1x!, y: pos1y!+75)
                    }
                    healthLostLabel.run(SKAction.moveTo(y: healthLostLabel.position.y+20, duration: 0.4))
                    healthLostLabel.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0.4), SKAction.run({
                        healthLostLabel.removeFromParent()
                    })]))
                    self.addChild(healthLostLabel)
                    if (aZombie?.health)! < 1
                    {
                        let deadZombie = SKSpriteNode(imageNamed: "ash.png")
                        deadZombie.name = "ash"
                        let pos1 = aZombie?.position
                        deadZombie.position = pos1!
                        aZombie?.removeFromParent()
                        self.zombies.remove(aZombie!)
                        self.zombies.add(deadZombie)
                        self.addChild(deadZombie)
                        
                        self.zombiesKilled += 1
                    }
                }
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval)
    {
        let position1 = CGPoint(x: princess1.position.x, y: princess1.position.y+CGFloat((joystick?.y)!*4))
        self.princess1.position = position1
        
        if position1 != self.princessPostiton
        {
            let messageData = NSMutableData()
            let archiver = NSKeyedArchiver(forWritingWith: messageData)
            archiver.encode("princessMove", forKey: "message")
            archiver.encode(position1, forKey: "position")
            archiver.finishEncoding()
            
            gameViewController1?.sendData(self.match, withData: messageData as Data!)
            
            self.princessPostiton = position1
            
            NSLog("sending princess position == %d, %d", position1.x, position1.y)
            print("Sending to match: \(self.match)")
        }
        
        if (self.myNumber == 0)
        {
            self.sendNumber()
        }
        
        for aZombie2 in self.zombies
        {
            let aZombie2SK = aZombie2 as! SKSpriteNode
            let range = NSRange(location: 0, length: 50)
            let gameOverRange = NSLocationInRange(Int(aZombie2SK.position.x), range)
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
            if (aZombie as! SKSpriteNode).name == "zombie" || (aZombie as! SKSpriteNode).name == "catZombie"
            {
                zombiesAlive += 1
            }
        }
        
        if zombiesAlive == 0 && gameIsRunning == true
        {
            for zombie in self.zombies
            {
                (zombie as! SKSpriteNode).removeFromParent()
                self.zombies.remove(zombie)
            }
            
            self.runGame()
        }
    }
}
