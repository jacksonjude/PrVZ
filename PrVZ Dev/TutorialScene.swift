    //
//  TutorialScene.swift
//  PrVZ Dev
//
//  Created by jackson on 9/21/14.
//  Copyright (c) 2014 jackson. All rights reserved.
//

import Foundation
import Spritekit

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
    var joystick = JCJoystick(controlRadius:50, baseRadius:68, baseColor:SKColor.blueColor(), joystickRadius:50, joystickColor:SKColor.redColor())
    var gameViewController1: GameViewController?
    var slider1: UISlider?
    var switch1: UISwitch?
    
    override func didMoveToView(view: SKView)
    {
        var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if let doneWave = defaults.objectForKey("Tutorial") as? NSInteger
        {
            if doneWave == 1
            {
                gameViewController1?.presentMenuScene()
            }
        }
                
        let background = SKSpriteNode(imageNamed: "background.png")
        background.zPosition = -2
        background.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        self.addChild(background)
        
        let prince = SKSpriteNode(imageNamed: "prince.png")
        prince.position = CGPoint(x: CGRectGetMidX(self.frame)-300, y: CGRectGetMidY(self.frame))
        prince.name = "prince"
        self.addChild(prince)
        
        let bubble = SKSpriteNode(imageNamed: "speech.png")
        bubble.position = CGPoint(x: CGRectGetMidX(self.frame)-130, y: CGRectGetMidY(self.frame)+250)
        bubble.zPosition = -1
        bubble.hidden = true
        self.addChild(bubble)
        
        var color = SKColor.blackColor()
        text1.text = "Welcome. I am the King"
        text1.fontColor = color
        text1.position = CGPoint(x: CGRectGetMidX(self.frame)-130, y: CGRectGetMidY(self.frame)+250)
        
        text2.text = "Oh no! The Zombies are Attacking!"
        text2.zPosition = 1
        text2.fontColor = color
        text2.position = CGPoint(x: CGRectGetMidX(self.frame)-130, y: CGRectGetMidY(self.frame)+250)
        text2.hidden = true
        
        text3.text = "Quick, Use the fire button to fire!"
        text3.zPosition = 2
        text3.fontColor = color
        text3.position = CGPoint(x: CGRectGetMidX(self.frame)-130, y: CGRectGetMidY(self.frame)+250)
        text3.hidden = true
        
        text4.text = "That was a close one. Lets get started!"
        text4.zPosition = 3
        text4.fontColor = color
        text4.position = CGPoint(x: CGRectGetMidX(self.frame)-130, y: CGRectGetMidY(self.frame)+250)
        text4.hidden = true
        
        self.addChild(text1)
        self.addChild(text2)
        self.addChild(text3)
        self.addChild(text4)
    }
    
    func tutorialWave()
    {
        physicsWorld.gravity = CGVectorMake(0,0)
        
        var wallEnd = SKShapeNode()
        var path = CGPathCreateMutable()
        CGPathAddRect(path, nil, CGRectMake(0, 0, 60, 3000))
        wallEnd.path = path
        wallEnd.fillColor = SKColor.grayColor()
        wallEnd.position = CGPoint(x: CGRectGetMidX(self.frame)-450, y: CGRectGetMidY(self.frame)-400)
        wallEnd.name = "wallEnd"
        wallEnd.physicsBody = SKPhysicsBody(circleOfRadius:20/2)
        wallEnd.physicsBody?.dynamic = true
        wallEnd.physicsBody?.categoryBitMask = wallCategory
        wallEnd.physicsBody?.contactTestBitMask = monsterCategory
        wallEnd.physicsBody?.usesPreciseCollisionDetection = true
        self.addChild(wallEnd)
        
        var zombie1 = GenericZombie()
        zombie1.position = CGPointMake(CGRectGetMidX(self.frame)+300, CGRectGetMidY(self.frame))
        zombie1.zPosition = 2
        zombie1.name = "zombie"
        zombie1.physicsBody = SKPhysicsBody(circleOfRadius:zombie1.size.width/2)
        zombie1.physicsBody?.dynamic = true
        zombie1.physicsBody?.categoryBitMask = monsterCategory
        zombie1.physicsBody?.contactTestBitMask = princessCategory
        zombie1.physicsBody?.collisionBitMask = 0
        zombie1.physicsBody?.usesPreciseCollisionDetection = true
        self.addChild(zombie1)
        
        let princess1 = Princess()
        princess1.position = CGPoint(x: CGRectGetMidX(self.frame)-300, y: zombie1.position.y)
        princess1.name = "princess"
        princess1.physicsBody = SKPhysicsBody(circleOfRadius:princess1.size.width/2)
        princess1.physicsBody?.dynamic = true
        princess1.physicsBody?.categoryBitMask = princessCategory
        princess1.physicsBody?.contactTestBitMask = monsterCategory
        princess1.physicsBody?.collisionBitMask = 0
        princess1.physicsBody?.usesPreciseCollisionDetection = true
        self.addChild(princess1)
        
        var fireButton = SKButton(defaultButtonImage: "fireButton", activeButtonImage: "fireButtonPressed", buttonAction: self.addBrush)
        fireButton.position = CGPoint(x: CGRectGetMidX(self.frame)+400, y: CGRectGetMidY(self.frame)-200)
        fireButton.name = "fire"
        self.addChild(fireButton)
        
        var moveBy = SKAction.moveByX(CGFloat(-self.zombieSpeed), y: 0, duration: 0.1)
        zombie1.runAction(SKAction.repeatActionForever(moveBy))
        
        joystick.position = CGPoint(x: CGRectGetMidX(self.frame)-400, y: CGRectGetMidY(self.frame)-200)
        joystick.name = "joystick"
        self.addChild(joystick)
        
        gameIsRunning = true
        
        self.physicsWorld.contactDelegate = self
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
    
    func projectileDidCollideWithMonster(projectile: SKNode, monster: SKNode)
    {
        projectile.removeFromParent()
        var deadZombie = SKSpriteNode(imageNamed: "ash.png")
        deadZombie.name = "ash"
        deadZombie.position = monster.position
        monster.removeFromParent()
        self.addChild(deadZombie)
    }
    
    func monsterDidCollideWithPrincess(monster: SKNode, princess1: SKNode)
    {
        gameOver()
    }
    
    func monsterDidCollideWithWall(monster: SKNode, wall: SKNode)
    {
        gameOver()
    }
    
    func gameOver()
    {
        var zombie = self.childNodeWithName("zombie")
        var princess = self.childNodeWithName("princess")
        var wall = self.childNodeWithName("wallEnd")
        zombie?.removeFromParent()
        princess?.removeFromParent()
        wall?.removeFromParent()
        joystick.removeFromParent()
        
        gameIsRunning = false
        
        tutorialWave()
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent)
    {
        for touch: AnyObject in touches
        {
            if gameIsRunning == false
            {
                textCount++
                switch textCount
                    {
                case 1:
                    text2.hidden = false
                    text1.hidden = true
                    
                case 2:
                    text3.hidden = false
                    text2.hidden = true
                    
                case 3:
                    let prince = childNodeWithName("prince")
                    prince?.hidden = true
                    text3.hidden = true
                    tutorialWave()
                    
                case 4:
                    var princess1 = self.childNodeWithName("princess")
                    var zombie1 = self.childNodeWithName("ash")
                    var wall = self.childNodeWithName("wallEnd")
                    var fireButton = self.childNodeWithName("fire")
                    princess1?.hidden = true
                    zombie1?.hidden = true
                    wall?.hidden = true
                    fireButton?.hidden = true
                    joystick.hidden = true
                    
                    let prince = childNodeWithName("prince")
                    prince?.hidden = false
                    text4.hidden = false
                    text3.hidden == true
                    
                case 5:
                    var test = self.view?.window?.rootViewController
                    if test == self.gameViewController1
                    {
                        println("rootViewController == GameViewController")
                    }
                    
                    self.gameViewController1?.presentGameScene()
                    
                default:
                    let NOTHING = 0
                }
            }
        }
    }
    
    func addBrush()
    {
        var brush = SKSpriteNode(imageNamed: "brush.png")
        var princess1 = self.childNodeWithName("princess") as SKSpriteNode
        brush.position = CGPoint(x: princess1.position.x, y: princess1.position.y)
        self.addChild(brush)
        brush.runAction(SKAction.moveToX(1000, duration: 1))
        brush.runAction(SKAction.waitForDuration(1))
        brush.physicsBody = SKPhysicsBody(circleOfRadius:brush.size.width/2)
        brush.physicsBody?.dynamic = true
        brush.physicsBody?.categoryBitMask = projectileCategory
        brush.physicsBody?.contactTestBitMask = monsterCategory
        brush.physicsBody?.collisionBitMask = 0
        brush.physicsBody?.usesPreciseCollisionDetection = true
        var move = SKAction.moveToX(1000, duration: 1)
        var vanish = SKAction.removeFromParent()
        var sequence = SKAction.sequence([move, vanish])
        brush.runAction(sequence)
    }
    
    override func update(currentTime: NSTimeInterval)
    {
        if gameIsRunning == true
        {
            var princess1 = self.childNodeWithName("princess") as SKSpriteNode
            var position1 = CGPoint(x: princess1.position.x, y: princess1.position.y+CGFloat(joystick.y*4))
            princess1.position = position1
            
            var zombie1 = self.childNodeWithName("ash")
            if zombie1 != nil
            {
                gameIsRunning = false
            }
        }
    }
}