//
//  GameViewController.swift
//  PrVZ Dev
//
//  Created by jackson on 9/15/14.
//  Copyright (c) 2014 jackson. All rights reserved.
//

import UIKit
import SpriteKit
import GameKit

extension SKNode {
    class func unarchiveFromFile(file : NSString) -> SKNode? {
        if let path = NSBundle.mainBundle().pathForResource(file, ofType: "sks") {
            var sceneData = NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe, error: nil)!
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

class GameViewController: UIViewController, GKGameCenterControllerDelegate {
    @IBOutlet var zombiesToSpawnSlider : UISlider!
    @IBOutlet var joystickSwitch : UISwitch!
    @IBOutlet var zombieSpeedSlider : UISlider!
    @IBOutlet var volumeSlider : UISlider!
    var gameCenterAchievements=[String:GKAchievement]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let scene = TitleScene.unarchiveFromFile("TitleScene") as? TitleScene {
            
            scene.gameViewController1 = self
            
            // Configure the view.
            let skView = self.view as SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill
            
            scene.slider = self.zombiesToSpawnSlider
            scene.slider?.hidden = true
            
            scene.switch1 = self.joystickSwitch
            scene.switch1?.hidden = true
            
            scene.slider2 = self.zombieSpeedSlider
            scene.slider2?.hidden = true
            
            scene.slider3 = self.volumeSlider
            scene.slider3?.hidden = true
            
            skView.presentScene(scene)
        }
        
        var localPlayer = GKLocalPlayer.localPlayer()
        localPlayer.authenticateHandler = {(viewController : UIViewController!, error : NSError!) -> Void in
            if ((viewController) != nil) {
                self.presentViewController(viewController, animated: true, completion: nil)
            }else{
                
                println((GKLocalPlayer.localPlayer().authenticated))
            }
        }
        
        self.gameCenterLoadAchievements()
    }
    
    func showLeaderboard()
    {
        var gcViewController: GKGameCenterViewController = GKGameCenterViewController()
        gcViewController.gameCenterDelegate = self
        
        gcViewController.viewState = GKGameCenterViewControllerState.Leaderboards
        
        gcViewController.leaderboardIdentifier = "zombiesKilled"
        
        self.showViewController(gcViewController, sender: self)
        self.navigationController?.pushViewController(gcViewController, animated: true)
    }
    
    func showAchievements()
    {
        var gcViewController: GKGameCenterViewController = GKGameCenterViewController()
        gcViewController.gameCenterDelegate = self
        
        gcViewController.viewState = GKGameCenterViewControllerState.Achievements
        
        self.showViewController(gcViewController, sender: self)
        self.navigationController?.pushViewController(gcViewController, animated: true)
    }
    
    func submitScore(score: NSInteger) {
        var leaderboardID = "zombiesKilled"
        var sScore = GKScore(leaderboardIdentifier: leaderboardID)
        sScore.value = Int64(score)
        
        let localPlayer: GKLocalPlayer = GKLocalPlayer.localPlayer()
        
        GKScore.reportScores([sScore], withCompletionHandler: { (error: NSError!) -> Void in
            if error != nil {
                println(error.localizedDescription)
            } else {
                println("Score submitted")
                
            }
        })
        
    }
    
    func gameCenterLoadAchievements(){
        // load all prev. achievements for GameCenter for the user to progress can be added
        var allAchievements=[GKAchievement]()
        
        GKAchievement.loadAchievementsWithCompletionHandler({ (allAchievements, error:NSError!) -> Void in
            if error != nil{
                println("Game Center: could not load achievements, error: \(error)")
            } else {
                if allAchievements != nil
                {
                    for anAchievement in allAchievements  {
                        if let oneAchievement = anAchievement as? GKAchievement {
                            self.gameCenterAchievements[oneAchievement.identifier]=oneAchievement}
                    }
                }
            }
        })
    }
    
    func gameCenterAddProgressToAnAchievement(progress:Double,achievementID:String) {
        var lookupAchievement:GKAchievement? = gameCenterAchievements[achievementID]
        
        println("\(progress)")
        
        if let achievement = lookupAchievement {
            // found the achievement with the given achievementID, check if it already 100% done
            if achievement.percentComplete != 100 {
                // set new progress
                achievement.percentComplete = progress
                if progress == 100.0  {achievement.showsCompletionBanner=true}  // show banner only if achievement is fully granted (progress is 100%)
                
                // try to report the progress to the Game Center
                GKAchievement.reportAchievements([achievement], withCompletionHandler:  {(var error:NSError!) -> Void in
                    if error != nil {
                        println("Couldn't save achievement (\(achievementID)) progress to \(progress) %")
                    }
                })
            }
            else {// achievemnt already granted, nothing to do
                println("DEBUG: Achievement (\(achievementID)) already granted")}
        } else { // never added  progress for this achievement, create achievement now, recall to add progress
            println("No achievement with ID (\(achievementID)) was found, no progress for this one was recoreded yet. Create achievement now.")
            gameCenterAchievements[achievementID] = GKAchievement(identifier: achievementID)
            // recursive recall this func now that the achievement exist
            gameCenterAddProgressToAnAchievement(progress, achievementID: achievementID)
        }
    }
    
    func gameCenterViewControllerDidFinish(gcViewController: GKGameCenterViewController!)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func presentTitleScene()
    {
        if let scene = TitleScene.unarchiveFromFile("TitleScene") as? TitleScene {
            
            scene.gameViewController1 = self
            
            // Configure the view.
            let skView = self.view as SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill
            
            scene.slider = self.zombiesToSpawnSlider
            scene.slider?.hidden = true
            
            scene.switch1 = self.joystickSwitch
            scene.switch1?.hidden = true
            
            scene.slider2 = self.zombieSpeedSlider
            scene.slider2?.hidden = true
            
            scene.slider3 = self.volumeSlider
            scene.slider3?.hidden = true
            
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
            
            scene.slider1 = self.zombiesToSpawnSlider
            scene.slider1?.hidden = true
            
            scene.switch1 = self.joystickSwitch
            scene.switch1?.hidden = true
            
            scene.slider2 = self.zombieSpeedSlider
            scene.slider2?.hidden = true
            
            scene.slider3 = self.volumeSlider
            scene.slider3?.hidden = true
            
            skView.presentScene(scene)
        }
    }
    
    func presentMenuScene()
    {
        if let scene = MenuScene.unarchiveFromFile("MenuScene") as? MenuScene
        {
            // Configure the view.
            let skView = self.view as SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill
            
            scene.gameViewController1 = self
            scene.volumeSlider = self.volumeSlider
            
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
            
            scene.zombiesToSpawnSlider = self.zombiesToSpawnSlider
            scene.joystickSwitch = self.joystickSwitch
            scene.zombieSpeedSlider = self.zombieSpeedSlider
            scene.volumeSlider = self.volumeSlider
            scene.volumeSlider?.hidden = true
            scene.gameViewController1 = self
            
            skView.presentScene(scene)
        }
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
        } else {
            return Int(UIInterfaceOrientationMask.All.rawValue)
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
