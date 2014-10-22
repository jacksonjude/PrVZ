//
//  archerZombie.swift
//  PrVZ Dev
//
//  Created by jackson on 10/16/14.
//  Copyright (c) 2014 jackson. All rights reserved.
//

import Foundation
import SpriteKit

class archerZombie: genericZombie
{
    override init()
    {
        var zombieTexture = SKTexture(imageNamed: "archerZombie.png")
        super.init(texture: zombieTexture)
        self.fireArrow()
    }
    
    func fireArrow()
    {
        var fire = SKAction.runBlock {
            var arrow = SKSpriteNode(imageNamed: "arrow")
            arrow.position = self.position
            
            self.addChild(arrow)
            
        }
        var move = SKAction.moveByX(0, y: self.princess.position.y, duration: 1)
        var sequence = SKAction.sequence([move, fire])
        self.runAction(SKAction.repeatActionForever(sequence))
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}