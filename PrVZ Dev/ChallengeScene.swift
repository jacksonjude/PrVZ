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
    var joystick = JCJoystick(controlRadius:50, baseRadius:68, baseColor:SKColor.blue, joystickRadius:50, joystickColor:SKColor.red)
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
    
    override func didMove(to view: SKView)
    {
        let background = SKSpriteNode(imageNamed: "backgroundg.png")
        background.zPosition = -20
        background.name = "background"
        background.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        self.addChild(background)
        
        princess1.position = CGPoint(x: self.frame.midX-300, y: self.frame.midY)
        princess1.name = "princess"
        princess1.physicsBody = SKPhysicsBody(circleOfRadius:princess1.size.width/2)
        princess1.physicsBody?.isDynamic = true
        princess1.physicsBody?.categoryBitMask = self.princessCategory
        princess1.physicsBody?.contactTestBitMask = self.monsterCategory
        princess1.physicsBody?.collisionBitMask = 0
        princess1.physicsBody?.usesPreciseCollisionDetection = true
        self.addChild(princess1)
        
        physicsWorld.gravity = CGVector(dx: 0,dy: 0)
        self.physicsWorld.contactDelegate = self
        
        let fireButton = SKButton(defaultButtonImage: "fireButton", activeButtonImage: "fireButtonPressed", buttonAction: self.addBrush)
        fireButton.position = CGPoint(x: self.frame.midX+400, y: self.frame.midY-200)
        fireButton.name = "fire"
        self.addChild(fireButton)
        
        self.joystick?.position = CGPoint(x: self.frame.midX-400, y: self.frame.midY-200)
        self.joystick?.name = "joystick"
        self.addChild(joystick!)
        
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
        
        self.scoreLabel.position = CGPoint(x: self.frame.midX-300, y: self.frame.midY+200)
        self.scoreLabel.fontSize = 30
        self.scoreLabel.fontColor = SKColor.orange
        self.addChild(scoreLabel)
        
        self.scoreEnemyLabel.position = CGPoint(x: self.frame.midX+300, y: self.frame.midY+200)
        self.scoreEnemyLabel.fontSize = 30
        self.scoreEnemyLabel.fontColor = SKColor.red
        self.addChild(scoreEnemyLabel)
        
        self.runGame()
        
        self.gameIsRunning = true
    }
    
    func addBrush()
    {
        if self.brushesInWorld <= 2
        {
            self.brushesInWorld += 1
            
            NSLog("Brushes In World: %i", self.brushesInWorld)
            
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
            self.currentBrushes.add(brush)
            let move = SKAction.moveTo(x: 1000, duration: 1)
            let vanish = SKAction.removeFromParent()
            let removeBrush = SKAction.run({
                self.currentBrushes.remove(brush)
                self.brushesInWorld -= 1
            })
            let sequence = SKAction.sequence([move, removeBrush, vanish])
            brush.run(sequence)
        }
    }
    
    func runGame()
    {
        let zombiesToSpawn = 5
        var zombiesSpawned = 0
        
        let speedDivider = self.wavesCompleted / 8
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
                    
                    let moveToPrincess = SKAction.moveTo(y: self.princess1.position.y, duration: 1)
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
                    self.addChild(cat1)
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
                    self.addChild(zombie1)
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
                self.addChild(zombie1)
            }
            zombiesSpawned += 1
        }
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
    }
    
    func projectileDidCollideWithMonster(_ projectile: SKNode, monster: SKNode)
    {
        projectile.removeFromParent()
        self.brushesInWorld -= 1
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
            
            let sparkEmmitterPath:NSString = Bundle.main.path(forResource: "Smoke", ofType: "sks")! as NSString
            
            let sparkEmmiter = NSKeyedUnarchiver.unarchiveObject(withFile: sparkEmmitterPath as String) as! SKEmitterNode
            
            sparkEmmiter.position = CGPoint(x: 0, y: 0)
            sparkEmmiter.name = "sparkEmmitter"
            sparkEmmiter.zPosition = 1
            sparkEmmiter.targetNode = self
            sparkEmmiter.particleLifetime = 0.5
            sparkEmmiter.particleBirthRate = 5
            sparkEmmiter.numParticlesToEmit = 100
            
            deadZombie.addChild(sparkEmmiter)
            
            self.zombiesKilled += 1
            
            let messageNumberData = NSMutableData()
            let archiver = NSKeyedArchiver(forWritingWith: messageNumberData)
            archiver.encode("zombies", forKey: "message")
            archiver.encode(self.zombiesKilled, forKey: "zombies")
            archiver.finishEncoding()
            
            gameViewController1?.sendData(self.match, withData: messageNumberData as Data!)
            
            if self.zombiesKilled >= 100
            {
                let Win = SKLabelNode(fontNamed: "TimesNewRoman")
                Win.fontSize = 85
                Win.fontColor = SKColor.orange
                Win.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
                Win.text = "You Win! GG!"
                self.addChild(Win)
                
                let defaults: UserDefaults = UserDefaults.standard
                if var wins = defaults.object(forKey: "gamesWon") as? NSInteger
                {
                    wins += 1
                    self.gameViewController1?.submitWin(wins)
                    defaults.set(wins, forKey: "gamesWon")
                }
                else
                {
                    let wins = 1
                    self.gameViewController1?.submitWin(wins)
                    defaults.set(wins, forKey: "gamesWon")
                }
                
                self.showDisconnectButton()
            }
        }
    }
    
    func monsterDidCollideWithPrincess(_ monster: SKNode, princess1: SKNode)
    {
        self.princessHealth -= 1
        
        let deadZombie = SKSpriteNode(imageNamed: "ash.png")
        deadZombie.name = "ash"
        deadZombie.position = monster.position
        monster.removeFromParent()
        self.zombies.remove(monster)
        self.zombies.add(deadZombie)
        self.addChild(deadZombie)
        
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
            self.gameOver()
        }
        enemyProjectile.removeFromParent()
        NSLog("%f", self.princessHealth)
    }
    
    func gameOver()
    {
        let hide = SKAction.fadeOut(withDuration: 0)
        let show = SKAction.fadeIn(withDuration: 0)
        let wait = SKAction.wait(forDuration: 1)
        let sequence = SKAction.sequence([hide, wait, show, wait, hide, wait, show, wait, hide, wait, show, wait, hide])
        self.princess1.run(sequence)
        
        for aZombie in self.zombies
        {
            (aZombie as AnyObject).removeFromParent()
        }
        
        self.zombies.removeAllObjects()
        
        let messageNumberData = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: messageNumberData)
        archiver.encode("otherPlayerDied", forKey: "message")
        archiver.finishEncoding()
        
        self.gameViewController1?.sendData(self.match, withData: messageNumberData as Data!)
        
        let Lose = SKLabelNode(fontNamed: "TimesNewRoman")
        Lose.fontSize = 85
        Lose.fontColor = SKColor.red
        Lose.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        Lose.text = "You Lose! GG!"
        self.addChild(Lose)
        
        self.showDisconnectButton()
    }
    
    func saveDataRecived(_ data: Data!, fromMatch match: GKMatch!, fromPlayer playerID: String!)
    {
        let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
        let message: AnyObject? = unarchiver.decodeObject(forKey: "message") as AnyObject?
        let messageString = message as? NSString
        
        if messageString == "zombies"
        {
            let zombiesOtherKilled : NSInteger = unarchiver.decodeInteger(forKey: "zombies")
            self.scoreEnemyLabel.text = NSString(format: "Enemy Zombies: %i", zombiesOtherKilled) as String
            if zombiesOtherKilled >= 100
            {
                let Lose = SKLabelNode(fontNamed: "TimesNewRoman")
                Lose.fontSize = 85
                Lose.fontColor = SKColor.red
                Lose.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
                Lose.text = "You Lose! GG!"
                self.addChild(Lose)
                
                self.showDisconnectButton()
            }
        }
        
        if messageString == "otherPlayerDied"
        {
            let Win = SKLabelNode(fontNamed: "TimesNewRoman")
            Win.fontSize = 85
            Win.fontColor = SKColor.orange
            Win.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
            Win.text = "You Win! GG!"
            self.addChild(Win)
            
            let defaults: UserDefaults = UserDefaults.standard
            if var wins = defaults.object(forKey: "gamesWon") as? NSInteger
            {
                wins += 1
                self.gameViewController1?.submitWin(wins)
                defaults.set(wins, forKey: "gamesWon")
            }
            else
            {
                let wins = 1
                self.gameViewController1?.submitWin(wins)
                defaults.set(wins, forKey: "gamesWon")
            }
            
            self.showDisconnectButton()
        }
    }
    
    func showDisconnectButton()
    {
        self.gameIsRunning = false
        
        for zombie in self.zombies
        {
            (zombie as AnyObject).removeFromParent()
            self.zombies.remove(zombie)
        }
        
        let disconnectButton = SKButton(defaultButtonImage: "disconnectButton", activeButtonImage: "disconnectButtonPressed", buttonAction: disconnect)
        disconnectButton.position = CGPoint(x: self.frame.midX, y: self.frame.midY-200)
        self.addChild(disconnectButton)
    }
    
    func disconnect()
    {
        match?.disconnect()
        gameViewController1?.presentMenuScene()
    }
    
    override func update(_ currentTime: TimeInterval)
    {
        let position1 = CGPoint(x: princess1.position.x, y: princess1.position.y+CGFloat((joystick?.y)!*4))
        self.princess1.position = position1
        
        for aZombie2 in self.zombies
        {
            let aZombie2SK = aZombie2 as! SKSpriteNode
            let range = NSRange(location: 0, length: 50)
            let gameOverRange = NSLocationInRange(Int(aZombie2SK.position.x), range)
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
            if (aZombie as AnyObject).name == "zombie" || (aZombie as AnyObject).name == "catZombie"
            {
                zombiesAlive += 1
            }
        }
        
        if zombiesAlive == 0 && gameIsRunning == true
        {
            for zombie in self.zombies
            {
                (zombie as AnyObject).removeFromParent()
                self.zombies.remove(zombie)
            }
            
            self.wavesCompleted += 1
            
            self.runGame()
        }
    }
}
