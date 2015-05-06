//
//  InterfaceController.swift
//  PrVZ WatchKit Extension
//
//  Created by jackson on 4/26/15.
//  Copyright (c) 2015 jackson. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    @IBOutlet weak var highScore: WKInterfaceLabel!
    @IBOutlet weak var titleType: WKInterfaceLabel!
    @IBOutlet weak var toggleButton: WKInterfaceButton!
    
    @IBOutlet weak var refreshButton: WKInterfaceButton!
    var toggleCurrent = true
    var highScoreLocal = "0E"
    var highScoreiCloud = "0E"
    var toggleUpdate = true
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        
        var defaultsGroup: NSUserDefaults = NSUserDefaults(suiteName: "group.com.jacksonjude.PrVZ")!
        if let highScore = defaultsGroup.objectForKey("highScore") as? NSInteger
        {
            self.highScore.setText(NSString(format: "High Score: %i", highScore) as String)
            self.highScoreLocal = NSString(format: "%i", highScore) as String
        }
        else
        {
            self.highScore.setText("High Score: 0E")
        }
        
        var keyStore = NSUbiquitousKeyValueStore.defaultStore()
        keyStore.synchronize()
        if let user = keyStore.dictionaryForKey("playerData")
        {
            var userDictionary = user as NSDictionary
            if let highScore = keyStore.objectForKey("highScore") as? NSInteger
            {
                self.highScore.setText(NSString(format: "High Score: %i", highScore) as String)
                self.highScoreiCloud = NSString(format: "%i", highScore) as String
            }
            else
            {
                self.highScore.setText("High Score: 0E")
            }
        }
        else
        {
            self.highScore.setText("High Score: 0E")
        }
        
        self.titleType.setText("Local Scores")
        self.toggleButton.setTitle("iCloud")
    }
    
    
    @IBAction func toggle()
    {
        if self.toggleCurrent == true
        {
            self.toggleCurrent = false
            self.toggleButton.setTitle("Local")
            self.titleType.setText("iCloud Scores")
            self.highScore.setText(NSString(format: "High Score: %@", self.highScoreiCloud) as String)
        }
        else
        {
            self.toggleCurrent = true
            self.toggleButton.setTitle("iCloud")
            self.titleType.setText("Local Scores")
            self.highScore.setText(NSString(format: "High Score: %@", self.highScoreLocal) as String)
        }
    }
    
    @IBAction func update()
    {
        if self.toggleCurrent == false
        {
            if self.toggleUpdate == true
            {
                var iCloudString = NSString(format: " High Score: %@ ", self.highScoreiCloud) as String
                self.highScore.setText(iCloudString)
                self.toggleUpdate = false
            }
            else
            {
                var iCloudString = NSString(format: "High Score: %@", self.highScoreiCloud) as String
                self.highScore.setText(iCloudString)
                self.toggleUpdate = true
            }
        }
        else
        {
            if self.toggleUpdate == true
            {
                var localString = NSString(format: " High Score: %@ ", self.highScoreLocal) as String
                self.highScore.setText(localString)
                self.toggleUpdate = false
            }
            else
            {
                var localString = NSString(format: "High Score: %@", self.highScoreLocal) as String
                self.highScore.setText(localString)
                self.toggleUpdate = true
            }
        }
    }
    

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    private func updateLabel()
    {
        highScore.setText("Hi")
    }
}
