//
//  GameViewController.swift
//  PrVZ Dev
//
//  Created by jackson on 9/15/14.
//  Copyright (c) 2014 jackson. All rights reserved.
//

import UIKit
import SpriteKit

extension SKNode {
    class func unarchiveFromFile(file : NSString) -> SKNode? {
        if let path = NSBundle.mainBundle().pathForResource(file, ofType: "sks") {
            var sceneData = NSData.dataWithContentsOfFile(path, options: .DataReadingMappedIfSafe, error: nil)
            var archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            var scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as SKNode
            archiver.finishDecoding()
            return scene
        }
        else
        {
            return nil
        }
    }
}

class GameViewController: UIViewController {
    @IBOutlet var slider : UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let scene = TitleScene.unarchiveFromFile("TitleScene") as? TitleScene {
            
            scene.gameViewController1 = self;
            
            // Configure the view.
            let skView = self.view as SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill
            
            scene.slider1 = slider
            
            skView.presentScene(scene)
        }
    }
    
    func presentTutorialScene()
    {
        if let scene = TutorialScene.unarchiveFromFile("TutorialScene") as? TutorialScene
        {
            scene.gameViewController1 = self
            // Configure the view.
            let skView = self.view as SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill
            
            scene.slider1 = slider
            
            skView.presentScene(scene)
        }
    }
    
    func presentGameScene()
    {
        if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene
        {
            // Configure the view.
            let skView = self.view as SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill
            
            scene.slider1 = slider
            
            skView.presentScene(scene)
        }
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.AllButUpsideDown.toRaw())
        } else {
            return Int(UIInterfaceOrientationMask.All.toRaw())
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
