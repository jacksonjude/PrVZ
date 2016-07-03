    //
//  TutorialScene.swift
//  PrVZ Dev
//
//  Created by jackson on 9/21/14.
//  Copyright (c) 2014 jackson. All rights reserved.
//

import Foundation
import SpriteKit

class TutorialScene: SKScene, SKPhysicsContactDelegate
{
    var projectileCategory: UInt32 =  1 << 0
    var monsterCategory: UInt32 =  1 << 1
    var princessCategory: UInt32 =  1 << 2
    var wallCategory: UInt32 =  1 << 3
    var textCount = 0
    var text1 = SKLabelNode(fontNamed: "TimesNewRoman")
    var text2 = SKLabelNode(fontNamed: "TimesNewRoman")
    var text3 = SKLabelNode(fontNamed: "TimesNewRoman")
    var text4 = SKLabelNode(fontNamed: "TimesNewRoman")
    var gameIsRunning = false
    var zombiesAlive = 0
    var zombieSpeed = 1.0
    var joystick = JCJoystick(controlRadius:50, baseRadius:68, baseColor:SKColor.blue(), joystickRadius:50, joystickColor:SKColor.red())
    var gameViewController1: GameViewController?
    
    override func didMove(to view: SKView)
    {
        let defaults: UserDefaults = UserDefaults.standard()
        if let doneWave = defaults.object(forKey: "Tutorial") as? NSInteger
        {
            if doneWave == 1
            {
                gameViewController1?.presentMenuScene()
            }
            else
            {
                defaults.set(0, forKey: "highScore")
            }
        }
        else
        {
            defaults.set(0, forKey: "highScore")
        }
                
        let background = SKSpriteNode(imageNamed: "backgroundg.png")
        background.zPosition = -2
        background.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        self.addChild(background)
        
        let prince = SKSpriteNode(imageNamed: "prince.png")
        prince.position = CGPoint(x: self.frame.midX-300, y: self.frame.midY)
        prince.name = "prince"
        self.addChild(prince)
        
        let bubble = SKSpriteNode(imageNamed: "speech.png")
        bubble.position = CGPoint(x: self.frame.midX-130, y: self.frame.midY+250)
        bubble.zPosition = -1
        bubble.isHidden = true
        self.addChild(bubble)
        
        let color = SKColor.black()
        text1.text = "Welcome. I am the King"
        text1.fontColor = color
        text1.position = CGPoint(x: self.frame.midX-130, y: self.frame.midY+250)
        
        text2.text = "Oh no! The Zombies are Attacking!"
        text2.zPosition = 1
        text2.fontColor = color
        text2.position = CGPoint(x: self.frame.midX-130, y: self.frame.midY+250)
        text2.isHidden = true
        
        text3.text = "Quick, Use the fire button to fire!"
        text3.zPosition = 2
        text3.fontColor = color
        text3.position = CGPoint(x: self.frame.midX-130, y: self.frame.midY+250)
        text3.isHidden = true
        
        text4.text = "That was a close one. Lets get started!"
        text4.zPosition = 3
        text4.fontColor = color
        text4.position = CGPoint(x: self.frame.midX-130, y: self.frame.midY+250)
        text4.isHidden = true
        
        self.addChild(text1)
        self.addChild(text2)
        self.addChild(text3)
        self.addChild(text4)
    }
    
    func tutorialWave()
    {
        physicsWorld.gravity = CGVector(dx: 0,dy: 0)
        
        let wallEnd = SKShapeNode()
        let path = CGMutablePath()
        path.addRect(nil, rect: CGRect(x: 0, y: 0, width: 60, height: 3000))
        wallEnd.path = path
        wallEnd.fillColor = SKColor.gray()
        wallEnd.position = CGPoint(x: self.frame.midX-450, y: self.frame.midY-400)
        wallEnd.name = "wallEnd"
        wallEnd.physicsBody = SKPhysicsBody(circleOfRadius:20/2)
        wallEnd.physicsBody?.isDynamic = true
        wallEnd.physicsBody?.categoryBitMask = wallCategory
        wallEnd.physicsBody?.contactTestBitMask = monsterCategory
        wallEnd.physicsBody?.usesPreciseCollisionDetection = true
        self.addChild(wallEnd)
        
        let zombie1 = GenericZombie()
        zombie1.position = CGPoint(x: self.frame.midX+300, y: self.frame.midY)
        zombie1.zPosition = 2
        zombie1.name = "zombie"
        zombie1.physicsBody = SKPhysicsBody(circleOfRadius:zombie1.size.width/2)
        zombie1.physicsBody?.isDynamic = true
        zombie1.physicsBody?.categoryBitMask = monsterCategory
        zombie1.physicsBody?.contactTestBitMask = princessCategory
        zombie1.physicsBody?.collisionBitMask = 0
        zombie1.physicsBody?.usesPreciseCollisionDetection = true
        self.addChild(zombie1)
        
        let princess1 = Princess()
        princess1.position = CGPoint(x: self.frame.midX-300, y: zombie1.position.y)
        princess1.name = "princess"
        princess1.physicsBody = SKPhysicsBody(circleOfRadius:princess1.size.width/2)
        princess1.physicsBody?.isDynamic = true
        princess1.physicsBody?.categoryBitMask = princessCategory
        princess1.physicsBody?.contactTestBitMask = monsterCategory
        princess1.physicsBody?.collisionBitMask = 0
        princess1.physicsBody?.usesPreciseCollisionDetection = true
        self.addChild(princess1)
        
        let fireButton = SKButton(defaultButtonImage: "fireButton", activeButtonImage: "fireButtonPressed", buttonAction: self.addBrush)
        fireButton.position = CGPoint(x: self.frame.midX+400, y: self.frame.midY-200)
        fireButton.name = "fire"
        self.addChild(fireButton)
        
        let moveBy = SKAction.moveBy(x: CGFloat(-self.zombieSpeed), y: 0, duration: 0.1)
        zombie1.run(SKAction.repeatForever(moveBy))
        
        self.joystick?.position = CGPoint(x: self.frame.midX-400, y: self.frame.midY-200)
        self.joystick?.name = "joystick"
        self.addChild(joystick!)
        
        self.gameIsRunning = true
        
        self.physicsWorld.contactDelegate = self
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
        
        if ((firstBody.categoryBitMask & projectileCategory) != 0 &&
            (secondBody.categoryBitMask & monsterCategory) != 0)
        {
            self.projectileDidCollideWithMonster(firstBody.node!, monster: secondBody.node!)
        }
        if ((firstBody.categoryBitMask & monsterCategory) != 0 &&
            (secondBody.categoryBitMask & princessCategory) != 0)
        {
            self.monsterDidCollideWithPrincess(firstBody.node!, princess1: secondBody.node!)
        }
        if ((firstBody.categoryBitMask & monsterCategory) != 0 &&
            (secondBody.categoryBitMask & wallCategory) != 0)
        {
            self.monsterDidCollideWithWall(firstBody.node!, wall: secondBody.node!)
        }
    }
    
    func projectileDidCollideWithMonster(_ projectile: SKNode, monster: SKNode)
    {
        projectile.removeFromParent()
        let deadZombie = SKSpriteNode(imageNamed: "ash.png")
        deadZombie.name = "ash"
        deadZombie.position = monster.position
        monster.removeFromParent()
        self.addChild(deadZombie)
        
        let textForInfo = SKLabelNode(fontNamed: "TimesNewRoman")
        textForInfo.text = "Touch Here to Continue"
        textForInfo.fontColor = SKColor.black()
        textForInfo.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        textForInfo.name = "textForInfo"
        self.addChild(textForInfo)
    }
    
    func monsterDidCollideWithPrincess(_ monster: SKNode, princess1: SKNode)
    {
        self.gameOver()
    }
    
    func monsterDidCollideWithWall(_ monster: SKNode, wall: SKNode)
    {
        self.gameOver()
    }
    
    func gameOver()
    {
        let zombie = self.childNode(withName: "zombie")
        let princess = self.childNode(withName: "princess")
        let wall = self.childNode(withName: "wallEnd")
        zombie?.removeFromParent()
        princess?.removeFromParent()
        wall?.removeFromParent()
        self.joystick?.removeFromParent()
        
        self.gameIsRunning = false
        
        self.tutorialWave()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        for _: AnyObject in touches
        {
            if self.gameIsRunning == false
            {
                textCount += 1
                switch textCount
                    {
                        case 1:
                            text2.isHidden = false
                            text1.isHidden = true
                            
                        case 2:
                            text3.isHidden = false
                            text2.isHidden = true
                            
                        case 3:
                            let prince = childNode(withName: "prince")
                            prince?.isHidden = true
                            text3.isHidden = true
                            tutorialWave()
                            
                        case 4:
                            let princess1 = self.childNode(withName: "princess")
                            let zombie1 = self.childNode(withName: "ash")
                            let wall = self.childNode(withName: "wallEnd")
                            let fireButton = self.childNode(withName: "fire")
                            princess1?.isHidden = true
                            zombie1?.isHidden = true
                            wall?.isHidden = true
                            fireButton?.isHidden = true
                            joystick?.isHidden = true
                            
                            let prince = childNode(withName: "prince")
                            prince?.isHidden = false
                            text4.isHidden = false
                            text3.isHidden = true
                            let textForInfo = self.childNode(withName: "textForInfo")
                            textForInfo?.isHidden = true
                            
                        case 5:
                            let test = self.view?.window?.rootViewController
                            if test == self.gameViewController1
                            {
                                print("rootViewController == GameViewController")
                            }
                            
                            self.gameViewController1?.presentGameScene()
                            
                        default:
                            _ = 0
                }
            }
        }
    }
    
    func addBrush()
    {
        let brush = SKSpriteNode(imageNamed: "brush.png")
        let princess1 = self.childNode(withName: "princess") as! SKSpriteNode
        brush.position = CGPoint(x: princess1.position.x, y: princess1.position.y)
        self.addChild(brush)
        brush.run(SKAction.moveTo(x: 1000, duration: 1))
        brush.run(SKAction.wait(forDuration: 1))
        brush.physicsBody = SKPhysicsBody(circleOfRadius:brush.size.width/2)
        brush.physicsBody?.isDynamic = true
        brush.physicsBody?.categoryBitMask = projectileCategory
        brush.physicsBody?.contactTestBitMask = monsterCategory
        brush.physicsBody?.collisionBitMask = 0
        brush.physicsBody?.usesPreciseCollisionDetection = true
        let move = SKAction.moveTo(x: 1000, duration: 1)
        let vanish = SKAction.removeFromParent()
        let sequence = SKAction.sequence([move, vanish])
        brush.run(sequence)
    }
    
    override func update(_ currentTime: TimeInterval)
    {
        if gameIsRunning == true
        {
            let princess1 = self.childNode(withName: "princess") as! SKSpriteNode
            let position1 = CGPoint(x: princess1.position.x, y: princess1.position.y+CGFloat((joystick?.y)!*4))
            princess1.position = position1
            
            let zombie1 = self.childNode(withName: "ash")
            if zombie1 != nil
            {
                gameIsRunning = false
            }
        }
    }
}
