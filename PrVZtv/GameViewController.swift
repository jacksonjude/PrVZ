//
//  GameViewController.swift
//  PrVZtv
//
//  Created by jackson on 9/18/15.
//  Copyright (c) 2015 jackson. All rights reserved.
//

import UIKit
import SpriteKit
import GameKit

class GameViewController: UIViewController, GKLocalPlayerListener, GKMatchDelegate
{
    var gameScene = SKScene(fileNamed: "GameScene") as? GameScene
    var gameCenterAchievements=[String:GKAchievement]()
    var gameCenterAchievementsReal=NSMutableArray()
    var gameCenter = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let localPlayer = GKLocalPlayer.localPlayer()
        localPlayer.authenticateHandler = {(viewController : UIViewController?, error : Error?) -> Void in
            if ((viewController) != nil) {
                self.present(viewController!, animated: true, completion: nil)
            }
            else
            {
                if GKLocalPlayer.localPlayer().isAuthenticated == true
                {
                    print((GKLocalPlayer.localPlayer().isAuthenticated))
                    GKLocalPlayer.localPlayer().register(self)
                    self.gameCenter = true
                }
                else
                {
                    self.gameCenter = false
                }
            }
        }
        
        self.gameCenterLoadAchievements()
        
        // Configure the view.
        let skView = self.view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        self.gameScene!.gameViewController1 = self
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        /* Set the scale mode to scale to fit the window */
        self.gameScene!.scaleMode = .aspectFill
        
        skView.presentScene(self.gameScene)        
    }
    
    func gameCenterLoadAchievements(){
        // load all prev. achievements for GameCenter for the user to progress can be added
        
        GKAchievement.loadAchievements(completionHandler: { (retrivedAllAchievements, error:Error?) -> Void in
            if error != nil{
                print("Game Center: could not load achievements, error: \(error)")
            } else {
                if retrivedAllAchievements != nil
                {
                    for anAchievement in retrivedAllAchievements!  {
                        if let oneAchievement = anAchievement as GKAchievement! {
                            self.gameCenterAchievements[oneAchievement.identifier!]=oneAchievement
                            self.gameCenterAchievementsReal.add(oneAchievement)
                        }
                    }
                }
            }
        })
    }
    
    func submitScore(_ score: NSInteger)
    {
        let leaderboardID = "zombiesKilled"
        let sScore = GKScore(leaderboardIdentifier: leaderboardID)
        sScore.value = Int64(score)
        
        GKScore.report([sScore], withCompletionHandler: { (error: Error?) -> Void in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                print("Score submitted")
            }
        })
    }
    
    func gameCenterAddProgressToAnAchievement(_ progress:Double,achievementID:String) {
        if gameCenter == true
        {
            let lookupAchievement:GKAchievement? = gameCenterAchievements[achievementID]
            
            if let achievement = lookupAchievement {
                // found the achievement with the given achievementID, check if it already 100% done
                if achievement.percentComplete < 100 {
                    // set new progress
                    achievement.percentComplete = progress
                    if progress == 100.0
                    {
                        achievement.showsCompletionBanner=true
                        
                    }  // show banner only if achievement is fully granted (progress is 100%)
                    
                    // try to report the progress to the Game Center
                    GKAchievement.report([achievement], withCompletionHandler:  {(error:Error?) -> Void in
                        if error != nil {
                            print("Couldn't save achievement (\(achievementID)) progress to \(progress) %")
                        }
                    })
                }
                else
                {// achievemnt already granted, nothing to do
                    print("DEBUG: Achievement (\(achievementID)) already granted")
                }
                print("Percent: \(achievement.percentComplete)")
            }
            else
            { // never added  progress for this achievement, create achievement now, recall to add progress
                print("No achievement with ID (\(achievementID)) was found, no progress for this one was recoreded yet. Create achievement now.")
                gameCenterAchievements[achievementID] = GKAchievement(identifier: achievementID)
                // recursive recall this func now that the achievement exist
                gameCenterAddProgressToAnAchievement(progress, achievementID: achievementID)
            }
        }
    }
    
    func gameCenterViewControllerDidFinish(_ gcViewController: GKGameCenterViewController)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func motionEnded(_ motion: UIEventSubtype,
        with event: UIEvent?)
    {
        if motion == .motionShake
        {
            self.gameScene?.shakeMotion()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
}
