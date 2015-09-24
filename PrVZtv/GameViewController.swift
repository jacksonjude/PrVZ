//
//  GameViewController.swift
//  PrVZtv
//
//  Created by jackson on 9/18/15.
//  Copyright (c) 2015 jackson. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController
{
    var gameScene = SKScene(fileNamed: "GameScene") as? GameScene
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the view.
        let skView = self.view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        self.gameScene!.gameViewController1 = self
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        /* Set the scale mode to scale to fit the window */
        self.gameScene!.scaleMode = .AspectFill
        
        skView.presentScene(self.gameScene)        
    }
    
    override func motionEnded(motion: UIEventSubtype,
        withEvent event: UIEvent?)
    {
        if motion == .MotionShake
        {
            self.gameScene?.shakeMotion()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
}
