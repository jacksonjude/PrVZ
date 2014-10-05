//
//  GameScene.swift
//  PrVZ Dev
//
//  Created by jackson on 10/1/14.
//  Copyright (c) 2014 jackson. All rights reserved.
//

import Foundation
import Spritekit

class GameScene: SKScene, SKPhysicsContactDelegate
{
    var projectileCategory: UInt32 =  1 << 0
    var monsterCategory: UInt32 =  1 << 1
    var princessCategory: UInt32 =  1 << 2
    var wallCategory: UInt32 =  1 << 3
    
    var zombies = NSMutableArray()
    var gameIsRunning = false
    var canPressStart = true
    var canGoToStore = true
    var zombieSpeed = 1.0
    var joystick = JCJoystick(controlRadius:50, baseRadius:68, baseColor:SKColor.blueColor(), joystickRadius:50, joystickColor:SKColor.redColor())
    var buttons = SKNode()
    var brushInWorld = false
    
    override func didMoveToView(view: SKView)
    {
        let background = SKSpriteNode(imageNamed: "background.png");
        background.zPosition = -2
        background.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        self.addChild(background)
        
        physicsWorld.gravity = CGVectorMake(0,0)
        self.physicsWorld.contactDelegate = self
        
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
        
        let princess1 = princess()
        princess1.position = CGPoint(x: CGRectGetMidX(self.frame)-300, y: CGRectGetMidY(self.frame))
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
        buttons.addChild(fireButton)
        
        var startButton = SKButton(defaultButtonImage: "startButtonGame", activeButtonImage: "startButtonGamePressed", buttonAction: runGame)
        startButton.position = CGPoint(x: CGRectGetMidX(self.frame)-300, y: CGRectGetMidY(self.frame)+200)
        startButton.name = "start"
        buttons.addChild(startButton)
        
        joystick.position = CGPoint(x: CGRectGetMidX(self.frame)-400, y: CGRectGetMidY(self.frame)-200)
        joystick.name = "joystick"
        buttons.addChild(joystick)
        
        self.addChild(buttons)
    }
    
    func runGame()
    {
        var zombiesToSpawn = 3
        //Later Will add Slider
        
        var zombiesSpawned = 0
        while zombiesSpawned != zombiesToSpawn
        {
            var zombie1 = zombie()
            var yPos = CGFloat((arc4random()%150)+150)
            var xPos = CGFloat((arc4random()%150)+150)
            zombie1.position = CGPointMake(CGRectGetMidX(self.frame)+xPos, yPos)
            zombie1.name = "zombie"
            zombie1.physicsBody = SKPhysicsBody(circleOfRadius:zombie1.size.width/2)
            zombie1.physicsBody?.dynamic = true
            zombie1.physicsBody?.categoryBitMask = monsterCategory
            zombie1.physicsBody?.contactTestBitMask = princessCategory
            zombie1.physicsBody?.collisionBitMask = 0
            zombie1.physicsBody?.usesPreciseCollisionDetection = true
            var moveBy = SKAction.moveByX(CGFloat(-self.zombieSpeed), y: 0, duration: 0.1)
            zombie1.runAction(SKAction.repeatActionForever(moveBy))
            zombies.addObject(zombie1)
            zombiesSpawned++
        }
        
        for i in zombies
        {
            self.addChild(i as SKNode)
        }
        
        gameIsRunning = true
        canPressStart = false
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
            if firstBody.node != nil
            {
                self.projectileDidCollideWithMonster(firstBody.node!, monster: secondBody.node!)
            }
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
        zombies.removeObject(monster)
        zombies.addObject(deadZombie)
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
        //Game Over Code
    }
    
    func addBrush()
    {
        if brushInWorld == false
        {
            var brush = SKSpriteNode(imageNamed: "brush.png")
            brush.name = "brush"
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
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent)
    {
        
    }
    
    override func update(currentTime: NSTimeInterval)
    {
        var princess1 = self.childNodeWithName("princess") as SKSpriteNode
        var position1 = CGPoint(x: princess1.position.x, y: princess1.position.y+CGFloat(joystick.y*4))
        princess1.position = position1
        
        if canPressStart == false
        {
            var startButton = buttons.childNodeWithName("start")
            startButton?.hidden = true
            startButton?.userInteractionEnabled = false
        }else{
            var startButton = buttons.childNodeWithName("start")
            startButton?.hidden = false
            startButton?.userInteractionEnabled = true
        }
        
        var zombiesAlive = 0
        for i in zombies
        {
            if i.name == "zombie"
            {
                zombiesAlive++
            }
        }
        
        if zombiesAlive == 0 && gameIsRunning == true
        {
            gameIsRunning = false
            canPressStart = true
            canGoToStore = true
            for i in zombies
            {
                zombies.removeObject(i)
                i.removeFromParent()
            }
        }
        var brush = self.childNodeWithName("brush")
        if brush != nil
        {
            brushInWorld = true
        }else{
            brushInWorld = false
        }
    }
}