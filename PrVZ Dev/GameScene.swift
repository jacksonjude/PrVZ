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
        
        if let coinsUser = defaults.objectForKey("coins") as? NSInteger
        {
            coins += coinsUser
        }
        
        if let itemsBoughtInStore = defaults.objectForKey("items") as? NSArray
        {
            if itemsBoughtInStore[0] as Bool == true
            {
                infBrushItem = 1
            }
            if itemsBoughtInStore[1] as Bool == true
            {
                item2 = 1
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
        
        joystick.position = CGPoint(x: CGRectGetMidX(self.frame)-400, y: CGRectGetMidY(self.frame)-200)
        joystick.name = "joystick"
        self.addChild(joystick)
        
        var startButton = SKButton(defaultButtonImage: "startButtonGame", activeButtonImage: "startButtonGamePressed", buttonAction: runGame)
        startButton.position = CGPoint(x: CGRectGetMidX(self.frame)-300, y: CGRectGetMidY(self.frame)+200)
        startButton.name = "start"
        buttons.addChild(startButton)
        
        var storeButton = SKButton(defaultButtonImage: "storeButton", activeButtonImage: "storeButtonPressed", buttonAction: store)
        storeButton.position = CGPoint(x: CGRectGetMidX(self.frame)+300, y: CGRectGetMidY(self.frame)+200)
        storeButton.name = "store"
        buttons.addChild(storeButton)
        
        var settingsButton = SKButton(defaultButtonImage: "settingsButton", activeButtonImage: "settingsButtonPressed", buttonAction: settings)
        settingsButton.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame)+200)
        settingsButton.name = "settingsButton"
        buttons.addChild(settingsButton)
        
        self.addChild(buttons)
        
        var bar = SKShapeNode()
        bar.path = CGPathCreateWithRect(CGRectMake(32, 0, 960, 235), nil)
        bar.fillColor = SKColor.grayColor()
        bar.name = "bar"
        bar.position = CGPoint(x: 0, y: CGRectGetMidY(self.frame)+125)
        self.addChild(bar)
        
        slider1?.hidden = true
        slider1?.userInteractionEnabled = false
        slider1?.maximumValue = 9
        slider1?.minimumValue = 3
        
        coinsLabel.position = CGPoint(x: CGRectGetMidX(self.frame)+300, y: CGRectGetMidY(self.frame)+90)
        coinsLabel.fontColor = SKColor.redColor()
        self.addChild(coinsLabel)
        var coinsImage = SKSpriteNode(imageNamed: "coin.png")
        coinsImage.position = CGPoint(x: coinsImage.position.x-30, y: coinsImage.position.y+10)
        coinsLabel.addChild(coinsImage)
        
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
        
        var zombiesToSpawn = slider1?.value
        
        var zombiesSpawned:Float = 0
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
        
        for aZombie in zombies
        {
            self.addChild(aZombie as SKNode)
        }
        
        gameIsRunning = true
        canPressButtons = false
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
            currentBrushes.addObject(brush)
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
        
        zombiesKilled++
        coins++
        
        var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(coins, forKey: "coins")
    }
    
    func monsterDidCollideWithPrincess(monster: SKNode, princess1: SKNode)
    {
        gameOver()
    }
    
    func gameOver()
    {
        var princess1 = self.childNodeWithName("princess")
        var hide = SKAction.fadeOutWithDuration(0)
        var show = SKAction.fadeInWithDuration(0)
        var wait = SKAction.waitForDuration(1)
        princess1?.runAction(SKAction.sequence([hide, wait, show, wait, hide, wait, show, wait, hide, wait, show, wait, hide]))
        
        for aZombie in zombies
        {
            aZombie.removeFromParent()
        }
        
        zombies.removeAllObjects()
        
        var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if let highScore = defaults.objectForKey("highScore") as? NSInteger
        {
            if highScore < zombiesKilled
            {
                defaults.setObject(zombiesKilled, forKey: "highScore")
                
                NSLog("New High Score: %i", zombiesKilled)
            }
            else
            {
                NSLog("High Score: %i", highScore)
            }
        }
        else
        {
            defaults.setObject(zombiesKilled, forKey: "highScore")
            NSLog("New High Score: %i", zombiesKilled)
        }
        
        var zombiesKilledLabel = SKLabelNode(fontNamed: "TimesNewRoman")
        zombiesKilledLabel.text = NSString(format: "Zombies Killed: %i", zombiesKilled)
        zombiesKilledLabel.name = "zombiesKilledLabel"
        zombiesKilledLabel.fontColor = SKColor.redColor()
        zombiesKilledLabel.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        self.addChild(zombiesKilledLabel)
        
        zombiesKilled = 0
        
        gameIsRunning = false
        canPressButtons = true
    }
    
    func settings()
    {
        windowIsOpen = true
        canPressButtons = false
        
        var settingsNode = SKNode()
        settingsNode.name = "settings"
        
        var backGround = SKShapeNode(circleOfRadius: 10)
        backGround.path = CGPathCreateWithRect(CGRectMake(32, 0, 960, 720), nil)
        backGround.fillColor = SKColor.grayColor()
        backGround.name = "bg"
        backGround.position = CGPoint(x: 0, y: 0)
        backGround.zPosition = 5
        settingsNode.addChild(backGround)
        
        slider1?.hidden = false
        slider1?.userInteractionEnabled = true
        
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
                highScoreLabel.text = NSString(format: "High Score: %i", zombiesKilled)
            }
        }
        
        levelsCompletedLabel.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame)+100)
        levelsCompletedLabel.fontColor = SKColor.blueColor()
        levelsCompletedLabel.zPosition = 6
        
        if let levels = defaults.objectForKey("levels") as? NSInteger
        {
            levelsCompletedLabel.text = NSString(format: "Levels Completed: %i", levels)
        }
        else
        {
            levelsCompletedLabel.text = "Levels Completed: 0"
        }
        self.addChild(levelsCompletedLabel)
        
        var currentScoreLabel = SKLabelNode(fontNamed: "TimesNewRoman")
        currentScoreLabel.fontColor = SKColor.redColor()
        currentScoreLabel.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame)+150)
        currentScoreLabel.zPosition = 6
        
        if zombiesKilled > 0
        {
            currentScoreLabel.text = NSString(format: "Curent Score: %i", zombiesKilled)
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
        
        gameViewController1?.presentTitleScene()
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent)
    {
        var settingsNode = self.childNodeWithName("settings")
        if settingsNode != nil
        {
            hideSettings()
        }
        
        if gameIsRunning == false
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
        
        if gamePaused == true
        {
            resumeGame()
        }
    }
    
    func hideSettings()
    {
        windowIsOpen = false
        canPressButtons = true
        
        var settingsNode = self.childNodeWithName("settings")
        settingsNode?.hidden = true
        settingsNode?.removeFromParent()
        
        levelsCompletedLabel.removeFromParent()
        
        slider1?.userInteractionEnabled = false
        slider1?.hidden = true
    }
    
    func store()
    {
        windowIsOpen = true
        canPressButtons = false
        
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
        infiniteBrush.addChild(infiniteBrushBuyButton)
        
        storeNode.addChild(products)
        self.addChild(storeNode)
    }
    
    func buyItemInfBrush()
    {
        if coins > 4
        {
            coins-=5
            infBrushItem = true
            brushInWorld = false
        }
    }
    
    func hideStore()
    {
        var storeNode = self.childNodeWithName("store")
        storeNode?.hidden = true
        storeNode?.removeFromParent()
        canPressButtons = true
        windowIsOpen = false
    }
    
    func saveData()
    {
        var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if let highScore = defaults.objectForKey("highScore") as? NSInteger
        {
            if gameIsRunning == true
            {
                var highScoreNew = highScore + zombiesKilled
                defaults.setObject(highScoreNew, forKey: "highScore")
            }
        }
        
        var tempArray = NSMutableArray()
        
        if infBrushItem == 1
        {
            tempArray[0] = true
        }
        else
        {
            tempArray[0] = false
        }
        
        if item2 == 1
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
        for aZombie in zombies
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
        
        for aBrush in currentBrushes
        {
            var aBrushSK = aBrush as SKSpriteNode
            aBrushSK.removeAllActions()
        }
        
        joystick.userInteractionEnabled = false
        
        var resumeButton = SKSpriteNode(imageNamed: "resume")
        resumeButton.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        resumeButton.name = "resumeButton"
        self.addChild(resumeButton)
        
        gamePaused = true
        
        saveData()
    }
    
    func resumeGame()
    {
        for aZombie in zombies
        {
            if aZombie as SKSpriteNode != self.childNodeWithName("ash")
            {
                var aZombieSK = aZombie as SKSpriteNode
                aZombieSK.runAction(SKAction.repeatActionForever(SKAction.moveByX(CGFloat(-zombieSpeed), y: 0, duration: 0.1)))
            }
        }
        
        for aBrush in currentBrushes
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
        
        joystick.userInteractionEnabled = true
        
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
        
        if windowIsOpen == false
        {
            if canPressButtons == false
            {
                buttons.hidden = true
                buttons.userInteractionEnabled = false
            }else{
                buttons.hidden = false
                buttons.userInteractionEnabled = true
            }
        }
        
        var zombiesAlive = 0
        for aZombie in zombies
        {
            if aZombie.name == "zombie"
            {
                zombiesAlive++
            }
        }
        
        coinsLabel.text = NSString(format: "%i", coins)
        
        if zombiesAlive == 0 && gameIsRunning == true
        {
            wavesCompleted++
            gameIsRunning = false
            canPressButtons = true
            for aZombie in zombies
            {
                zombies.removeObject(aZombie)
                aZombie.removeFromParent()
                
            }
            var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
            if let levels = defaults.objectForKey("levels") as? NSInteger
            {
                var levelsNew = levels + wavesCompleted
                defaults.setObject(levelsNew, forKey: "levels")
                levelsCompletedLabel.text = NSString(format: "Levels completed: %i", levelsNew)
                if levelsNew == 1
                {
                    NSLog("%i level completed", levelsNew)
                }
                else
                {
                    NSLog("%i levels completed", levelsNew)
                }
            }
            else
            {
                defaults.setObject(1, forKey: "levels")
                levelsCompletedLabel.text = "1"
            }
            
        }
        
        if infBrushItem == false
        {
            var brush = self.childNodeWithName("brush")
            if brush != nil
            {
                brushInWorld = true
            }else{
                brushInWorld = false
            }
        }
        
        for aZombie in zombies
        {
            var wallEnd = self.childNodeWithName("wallEnd")
            if aZombie.position.x == wallEnd?.position.x
            {
                gameOver()
            }
        }
        
        if windowIsOpen == true
        {
            var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
            
            defaults.setObject(zombiesKilled, forKey: "highScore")
            
            var tempArray = NSMutableArray()
            
            if infBrushItem == 1
            {
                tempArray[0] = true
            }
            else
            {
                tempArray[0] = false
            }
            
            if item2 == 1
            {
                tempArray[1] = true
            }
            else
            {
                tempArray[1] = false
            }
            
            defaults.setObject(tempArray, forKey: "items")
        }
    }
}