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
    let brushCategory: UInt32 =  1 << 0
    let monsterCategory: UInt32 =  1 << 1
    let princessCategory: UInt32 =  1 << 2
    
    var zombies = NSMutableArray()
    var gameIsRunning = false
    var canPressButtons = true
    var zombieSpeed = 1.0
    var joystick = JCJoystick(controlRadius:50, baseRadius:68, baseColor:SKColor.blueColor(), joystickRadius:50, joystickColor:SKColor.redColor())
    var buttons = SKNode()
    var brushInWorld = false
    var windowIsOpen = false
    var zombiesKilled = 0
    var coins = 0
    var coinsLabel = SKLabelNode(fontNamed: "TimesNewRoman")
    var slider1: UISlider?
    var gameViewController1: GameViewController?
    var infBrushItem = Bool()
    var item2 = Bool()
    var wavesCompleted = NSInteger()
    var levelsCompletedLabel = SKLabelNode(fontNamed: "TimesNewRoman")
    var currentBrushes = NSMutableArray()
    var gamePaused = false
    var movedCoinsImage = false
    var storeButtons = NSMutableArray()
    var storeIsOpen = false
    var checkIsShowing = false
    
    deinit
    {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func didMoveToView(view: SKView)
    {
        var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(1, forKey: "Tutorial")
        
        if let backgroundNumber = defaults.objectForKey("background") as? NSInteger
        {
            if backgroundNumber == 2
            {
                let background = SKSpriteNode(imageNamed: "background2.png")
                background.zPosition = -2
                background.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
                self.addChild(background)
            }
        }
        else
        {
            let background = SKSpriteNode(imageNamed: "background.png")
            background.zPosition = -2
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
        
        if let itemsBoughtInStore = defaults.objectForKey("items") as? NSArray
        {
            if itemsBoughtInStore[0] as Bool == true
            {
                self.infBrushItem = 1
            }
            if itemsBoughtInStore[1] as Bool == true
            {
                self.item2 = 1
            }
        }
        
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
        
        let princess1 = Princess()
        princess1.position = CGPoint(x: CGRectGetMidX(self.frame)-300, y: CGRectGetMidY(self.frame))
        princess1.name = "princess"
        princess1.physicsBody = SKPhysicsBody(circleOfRadius:princess1.size.width/2)
        princess1.physicsBody?.dynamic = true
        princess1.physicsBody?.categoryBitMask = self.princessCategory
        princess1.physicsBody?.contactTestBitMask = self.monsterCategory
        princess1.physicsBody?.collisionBitMask = 0
        princess1.physicsBody?.usesPreciseCollisionDetection = true
        self.addChild(princess1)
        
        var pauseButton = SKButton(defaultButtonImage: "pause", activeButtonImage: "pause", buttonAction: pauseGame)
        pauseButton.position = CGPoint(x: CGRectGetMidX(self.frame)+400, y: CGRectGetMidY(self.frame)+100)
        pauseButton.name = "pauseButton"
        pauseButton.hidden = true
        pauseButton.userInteractionEnabled = false
        self.addChild(pauseButton)
        
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
        
        var storeButton = SKButton(defaultButtonImage: "storeButton", activeButtonImage: "storeButtonPressed", buttonAction: store)
        storeButton.position = CGPoint(x: CGRectGetMidX(self.frame)+300, y: CGRectGetMidY(self.frame)+200)
        storeButton.name = "store"
        self.buttons.addChild(storeButton)
        
        var settingsButton = SKButton(defaultButtonImage: "settingsButton", activeButtonImage: "settingsButtonPressed", buttonAction: settings)
        settingsButton.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame)+200)
        settingsButton.name = "settingsButton"
        self.buttons.addChild(settingsButton)
        
        self.addChild(self.buttons)
        
        var bar = SKShapeNode()
        bar.path = CGPathCreateWithRect(CGRectMake(32, 0, 960, 235), nil)
        bar.fillColor = SKColor.grayColor()
        bar.name = "bar"
        bar.position = CGPoint(x: 0, y: CGRectGetMidY(self.frame)+125)
        self.addChild(bar)
        
        self.slider1?.hidden = true
        self.slider1?.userInteractionEnabled = false
        self.slider1?.maximumValue = 9
        self.slider1?.minimumValue = 3
        
        self.coinsLabel.position = CGPoint(x: CGRectGetMidX(self.frame)+300, y: CGRectGetMidY(self.frame)+90)
        self.coinsLabel.fontColor = SKColor.redColor()
        self.addChild(self.coinsLabel)
        var coinsImage = SKSpriteNode(imageNamed: "coin.png")
        coinsImage.position = CGPoint(x: coinsImage.position.x-40, y: coinsImage.position.y+10)
        coinsImage.name = "coinsImage"
        self.coinsLabel.addChild(coinsImage)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"saveData", name: UIApplicationDidEnterBackgroundNotification, object: nil)
    }
    
    func runGame()
    {
        if let pauseButton = self.childNodeWithName("pauseButton")
        {
            pauseButton.hidden = false
            pauseButton.userInteractionEnabled = true
        }
        
        if let zombiesKilledLabel = self.childNodeWithName("zombiesKilledLabel")
        {
            zombiesKilledLabel.removeFromParent()
        }
        
        var zombiesToSpawn = self.slider1?.value
        
        var zombiesSpawned:Float = 0
        while zombiesSpawned != zombiesToSpawn
        {
            var zombie1 = genericZombie()
            var yPos = CGFloat((arc4random()%150)+150)
            var xPos = CGFloat((arc4random()%150)+150)
            var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
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
        if self.brushInWorld == false
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
            brush.physicsBody?.categoryBitMask = self.brushCategory
            brush.physicsBody?.contactTestBitMask = self.monsterCategory
            brush.physicsBody?.collisionBitMask = 0
            brush.physicsBody?.usesPreciseCollisionDetection = true
            self.currentBrushes.addObject(brush)
            var move = SKAction.moveToX(1000, duration: 1)
            var vanish = SKAction.removeFromParent()
            var removeBrush = SKAction.runBlock({
                self.currentBrushes.removeObject(brush)
            })
            var sequence = SKAction.sequence([move, vanish, removeBrush])
            brush.runAction(sequence)
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
    }
    
    func projectileDidCollideWithMonster(projectile: SKNode, monster: SKNode)
    {
        projectile.removeFromParent()
        var monsterSK = monster as genericZombie
        monsterSK.health--
        if monsterSK.health <= 0
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
        self.coins++
        
        var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(self.coins, forKey: "coins")
    }
    
    func monsterDidCollideWithPrincess(monster: SKNode, princess1: SKNode)
    {
        self.gameOver()
    }
    
    func gameOver()
    {
        var princess1 = self.childNodeWithName("princess")
        var hide = SKAction.fadeOutWithDuration(0)
        var show = SKAction.fadeInWithDuration(0)
        var wait = SKAction.waitForDuration(1)
        princess1?.runAction(SKAction.sequence([hide, wait, show, wait, hide, wait, show, wait, hide, wait, show, wait, hide]))
        
        for aZombie in self.zombies
        {
            aZombie.removeFromParent()
        }
        
        self.zombies.removeAllObjects()
        
        var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if let highScore = defaults.objectForKey("highScore") as? NSInteger
        {
            if highScore < self.zombiesKilled
            {
                defaults.setObject(self.zombiesKilled, forKey: "highScore")
                
                NSLog("New High Score: %i", self.zombiesKilled)
            }
            else
            {
                NSLog("High Score: %i", highScore)
            }
        }
        else
        {
            defaults.setObject(self.zombiesKilled, forKey: "highScore")
            NSLog("New High Score: %i", self.zombiesKilled)
        }
        
        var zombiesKilledLabel = SKLabelNode(fontNamed: "TimesNewRoman")
        zombiesKilledLabel.text = NSString(format: "Zombies Killed: %i", self.zombiesKilled)
        zombiesKilledLabel.name = "zombiesKilledLabel"
        zombiesKilledLabel.fontColor = SKColor.redColor()
        zombiesKilledLabel.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        self.addChild(zombiesKilledLabel)
        
        self.zombiesKilled = 0
        
        self.gameIsRunning = false
        self.canPressButtons = true
    }
    
    func settings()
    {
        self.windowIsOpen = true
        self.canPressButtons = false
        
        var settingsNode = SKNode()
        settingsNode.name = "settings"
        
        var backGround = SKShapeNode(circleOfRadius: 10)
        backGround.path = CGPathCreateWithRect(CGRectMake(32, 0, 960, 720), nil)
        backGround.fillColor = SKColor.grayColor()
        backGround.name = "bg"
        backGround.position = CGPoint(x: 0, y: 0)
        backGround.zPosition = 5
        settingsNode.addChild(backGround)
        
        self.slider1?.hidden = false
        self.slider1?.userInteractionEnabled = true
        
        var resetGameButton = SKButton(defaultButtonImage: "resetButton", activeButtonImage: "resetButtonPressed", buttonAction: resetGame)
        resetGameButton.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame)-200)
        resetGameButton.zPosition = 6
        settingsNode.addChild(resetGameButton)
        
        var saveGameButton = SKButton(defaultButtonImage: "saveButton", activeButtonImage: "saveButtonPressed", buttonAction: saveData)
        saveGameButton.position = CGPoint(x: CGRectGetMidX(self.frame)+200, y: CGRectGetMidY(self.frame)-200)
        saveGameButton.zPosition = 6
        settingsNode.addChild(saveGameButton)
        
        var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if let highScore = defaults.objectForKey("highScore") as? NSInteger
        {
            var highScoreLabel = SKLabelNode(fontNamed: "TimesNewRoman")
            highScoreLabel.fontColor = SKColor.orangeColor()
            highScoreLabel.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame)+200)
            highScoreLabel.zPosition = 6
            settingsNode.addChild(highScoreLabel)
            if highScore > 0
            {
                highScoreLabel.text = NSString(format: "High Score: %i", highScore)
            }
            else
            {
                highScoreLabel.text = NSString(format: "High Score: %i", self.zombiesKilled)
            }
        }
        
        self.levelsCompletedLabel.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame)+100)
        self.levelsCompletedLabel.fontColor = SKColor.blueColor()
        self.levelsCompletedLabel.zPosition = 6
        
        if let levels = defaults.objectForKey("levels") as? NSInteger
        {
            self.levelsCompletedLabel.text = NSString(format: "Levels Completed: %i", levels)
        }
        else
        {
            self.levelsCompletedLabel.text = "Levels Completed: 0"
        }
        self.addChild(self.levelsCompletedLabel)
        
        var currentScoreLabel = SKLabelNode(fontNamed: "TimesNewRoman")
        currentScoreLabel.fontColor = SKColor.redColor()
        currentScoreLabel.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame)+150)
        currentScoreLabel.zPosition = 6
        
        if self.zombiesKilled > 0
        {
            currentScoreLabel.text = NSString(format: "Curent Score: %i", self.zombiesKilled)
        }
        else
        {
            currentScoreLabel.text = "Current Score: 0"
        }
        settingsNode.addChild(currentScoreLabel)
        
        self.addChild(settingsNode)
    }
    
    func resetGame()
    {
        var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(0, forKey: "Tutorial")
        defaults.setObject(0, forKey: "highScore")
        defaults.setObject(0, forKey: "levels")
        defaults.setObject(0, forKey: "coins")
        defaults.setObject([false, false], forKey: "items")
        
        self.gameViewController1?.presentTitleScene()
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent)
    {
        var settingsNode = self.childNodeWithName("settings")
        if settingsNode != nil
        {
            hideSettings()
        }
        
        if self.gameIsRunning == false
        {
            if let zombiesKilledLabel = self.childNodeWithName("zombiesKilledLabel")
            {
                zombiesKilledLabel.removeFromParent()
            }
            
            if let princess1 = self.childNodeWithName("princess")
            {
                princess1.runAction(SKAction.fadeInWithDuration(0))
            }
        }
        
        if self.gamePaused == true
        {
            self.resumeGame()
        }
    }
    
    func hideSettings()
    {
        self.windowIsOpen = false
        self.canPressButtons = true
        
        var settingsNode = self.childNodeWithName("settings")
        settingsNode?.hidden = true
        settingsNode?.removeFromParent()
        
        self.levelsCompletedLabel.removeFromParent()
        
        self.slider1?.userInteractionEnabled = false
        self.slider1?.hidden = true
    }
    
    func store()
    {
        self.windowIsOpen = true
        self.storeIsOpen = true
        self.canPressButtons = false
        
        var storeNode = SKNode()
        storeNode.name = "store"
        
        var backGround = SKShapeNode(circleOfRadius: 10)
        backGround.path = CGPathCreateWithRect(CGRectMake(32, 0, 960, 720), nil)
        backGround.fillColor = SKColor.grayColor()
        backGround.name = "bg"
        backGround.position = CGPoint(x: 0, y: 0)
        backGround.zPosition = 5
        storeNode.addChild(backGround)
        
        var backButton = SKButton(defaultButtonImage: "backButton", activeButtonImage: "backButtonPressed", buttonAction: hideStore)
        backButton.position = CGPoint(x: CGRectGetMidX(self.frame)+400, y: CGRectGetMidX(self.frame)-140)
        backButton.zPosition = 6
        storeNode.addChild(backButton)
        
        var products = SKNode()
        products.name = "products"
        
        var infiniteBrush = SKSpriteNode(imageNamed: "infiniteBrush")
        infiniteBrush.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        infiniteBrush.name = "infiniteBrush"
        infiniteBrush.zPosition = 7
        products.addChild(infiniteBrush)
        var infiniteBrushLabel = SKLabelNode(fontNamed: "TimesNewRoman")
        infiniteBrushLabel.text = "Infinite Brush"
        infiniteBrushLabel.fontSize = 64
        infiniteBrushLabel.fontColor = SKColor.redColor()
        infiniteBrushLabel.position = CGPoint(x: infiniteBrushLabel.position.x, y: infiniteBrushLabel.position.y+50)
        infiniteBrush.addChild(infiniteBrushLabel)
        var infiniteBrushBuyButton = SKButton(defaultButtonImage: "buyButton", activeButtonImage: "buyButtonPressed", buttonAction: buyItemInfBrush)
        infiniteBrushBuyButton.position = CGPoint(x: infiniteBrushBuyButton.position.x, y: infiniteBrushBuyButton.position.y-200)
        infiniteBrushBuyButton.name = "infBrushButton"
        infiniteBrush.addChild(infiniteBrushBuyButton)
        self.storeButtons.addObject(infiniteBrushBuyButton)
        
        storeNode.addChild(products)
        self.addChild(storeNode)
    }
    
    func buyItemInfBrush()
    {
        if self.coins > 19
        {
            self.coins-=20
            self.infBrushItem = true
            self.brushInWorld = false
        }
    }
    
    func hideStore()
    {
        var storeNode = self.childNodeWithName("store")
        storeNode?.hidden = true
        storeNode?.removeFromParent()
        self.canPressButtons = true
        self.windowIsOpen = false
        self.storeIsOpen = false
        self.checkIsShowing = false
    }
    
    func saveData()
    {
        var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if let highScore = defaults.objectForKey("highScore") as? NSInteger
        {
            if self.gameIsRunning == true
            {
                var highScoreNew = highScore + self.zombiesKilled
                defaults.setObject(highScoreNew, forKey: "highScore")
            }
        }
        
        defaults.setObject(self.wavesCompleted, forKey: "levels")
        
        var tempArray = NSMutableArray()
        
        if self.infBrushItem == 1
        {
            tempArray[0] = true
        }
        else
        {
            tempArray[0] = false
        }
        
        if self.item2 == 1
        {
            tempArray[1] = true
        }
        else
        {
            tempArray[1] = false
        }
        
        defaults.setObject(tempArray, forKey: "items")
    }
    
    func pauseGame()
    {
        for aZombie in self.zombies
        {
            var aZombieSK = aZombie as SKSpriteNode
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
            var aBrushSK = aBrush as SKSpriteNode
            aBrushSK.removeAllActions()
        }
        
        self.joystick.userInteractionEnabled = false
        
        var resumeButton = SKSpriteNode(imageNamed: "resume")
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
            if aZombie as SKSpriteNode != self.childNodeWithName("ash")
            {
                var aZombieSK = aZombie as SKSpriteNode
                aZombieSK.runAction(SKAction.repeatActionForever(SKAction.moveByX(CGFloat(-zombieSpeed), y: 0, duration: 0.1)))
            }
        }
        
        for aBrush in self.currentBrushes
        {
            var aBrushSK = aBrush as SKSpriteNode
            var move = SKAction.moveToX(1000, duration: 1)
            var vanish = SKAction.removeFromParent()
            var removeBrush = SKAction.runBlock({
                self.currentBrushes.removeObject(aBrushSK)
            })
            var sequence = SKAction.sequence([move, vanish, removeBrush])
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
    }
    
    override func update(currentTime: NSTimeInterval)
    {
        var princess1 = self.childNodeWithName("princess") as SKSpriteNode
        var position1 = CGPoint(x: princess1.position.x, y: princess1.position.y+CGFloat(joystick.y*4))
        princess1.position = position1
        
        if self.windowIsOpen == false
        {
            if self.canPressButtons == false
            {
                self.buttons.hidden = true
                self.buttons.userInteractionEnabled = false
            }else{
                self.buttons.hidden = false
                self.buttons.userInteractionEnabled = true
            }
        }
        
        var zombiesAlive = 0
        for aZombie in self.zombies
        {
            if aZombie.name == "zombie"
            {
                zombiesAlive++
            }
        }
        
        self.coinsLabel.text = NSString(format: "%i", self.coins)
        
        if zombiesAlive == 0 && self.gameIsRunning == true
        {
            self.wavesCompleted++
            self.gameIsRunning = false
            self.canPressButtons = true
            for aZombie in self.zombies
            {
                self.zombies.removeObject(aZombie)
                aZombie.removeFromParent()
                
            }
        }
        
        if self.infBrushItem == false
        {
            var brush = self.childNodeWithName("brush")
            if brush != nil
            {
                self.brushInWorld = true
            }else{
                self.brushInWorld = false
            }
        }
        
        for aZombie in self.zombies
        {
            var wallEnd = self.childNodeWithName("wallEnd")
            if aZombie.position.x == wallEnd?.position.x
            {
                gameOver()
            }
        }
        
        if self.windowIsOpen == true
        {
            var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
            
            defaults.setObject(self.zombiesKilled, forKey: "highScore")
            
            var tempArray = NSMutableArray()
            
            if self.infBrushItem == 1
            {
                tempArray[0] = true
            }
            else
            {
                tempArray[0] = false
            }
            
            if self.item2 == 1
            {
                tempArray[1] = true
            }
            else
            {
                tempArray[1] = false
            }
            
            defaults.setObject(tempArray, forKey: "items")
            
            if self.storeIsOpen == true
            {
                if self.infBrushItem == true
                {
                    for aButton in self.storeButtons
                    {
                        aButton.removeFromParent()
                    }
                    
                    if self.checkIsShowing == false
                    {
                        var infBrushCheck = SKSpriteNode(imageNamed: "check.png")
                        infBrushCheck.zPosition = 8
                        infBrushCheck.name = "check"
                        infBrushCheck.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
                        var storeNode = self.childNodeWithName("store")
                        storeNode?.addChild(infBrushCheck)
                        self.checkIsShowing = true
                    }
                }
            }
        }
        
        if self.coins == 100
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
    }
}