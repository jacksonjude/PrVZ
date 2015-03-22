//
//  MultiplayerScene.swift
//  PrVZ
//
//  Created by jackson on 3/21/15.
//  Copyright (c) 2015 jackson. All rights reserved.
//

import Foundation
import GameKit
import Spritekit

class MultiplayerScene: SKScene, SKPhysicsContactDelegate
{
    let brushCategory: UInt32 =  1 << 0
    let monsterCategory: UInt32 =  1 << 1
    let princessCategory: UInt32 =  1 << 2
    let enemyProjectileCatagory: UInt32 =  1 << 3
    
    var princess1 = Princess()
    var joystick = JCJoystick(controlRadius:50, baseRadius:68, baseColor:SKColor.blueColor(), joystickRadius:50, joystickColor:SKColor.redColor())
    var buttons = SKNode()
    var zombiesToSpawnSlider: UISlider?
    var joystickSwitch: UISwitch?
    var zombieSpeedSlider: UISlider?
    var volumeSlider: UISlider?
    var gameViewController1: GameViewController?
    var wavesCompleted = 0
    var zombieSpeed = 1
    var zombies = NSMutableArray()
    var gameIsRunning = false
    var canPressButtons = true
    var princess2Display = Princess()
    var princessPostiton = CGPoint()
    var match: GKMatch?
    
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
        
        var Circle = SKShapeNode(circleOfRadius: 12)
        Circle.position = CGPointMake(0, 0)
        Circle.name = "defaultCircle"
        Circle.strokeColor = SKColor.blackColor()
        Circle.glowWidth = 5.0
        Circle.fillColor = SKColor.greenColor()
        self.princess1.addChild(Circle)
        
        
        self.princess2Display.position = CGPoint(x: CGRectGetMidX(self.frame)-300, y: CGRectGetMidY(self.frame))
        self.princess2Display.name = "princess2"
        self.addChild(self.princess2Display)
        
        self.princessPostiton = self.princess1.position
        
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
    
    func runGame()
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
        
    }
    
    func saveDataRecived(data: NSData!, fromMatch match: GKMatch!, fromPlayer playerID: String!)
    {
        var unarchiver = NSKeyedUnarchiver(forReadingWithData: data)
        var message: AnyObject? = unarchiver.decodeObjectForKey("message")
        var messageString = message as? NSString
        if (messageString == "princessMove")
        {
            var position : CGPoint = unarchiver.decodeCGPointForKey("position")
            self.princess2Display.position = position
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
    }
}