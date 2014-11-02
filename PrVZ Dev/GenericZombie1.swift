//
//  zombie.swift
//  PrVZ Dev
//
//  Created by jackson on 9/23/14.
//  Copyright (c) 2014 jackson. All rights reserved.
//

import Foundation
import SpriteKit

class GenericZombie: SKSpriteNode
{
    var health: NSInteger = 1
    var princess: Princess!
    
    override init()
    {
        let zombieTexture = SKTexture(imageNamed: "zombie.png")
        var scaledSize = zombieTexture.size()
        scaledSize = CGSizeApplyAffineTransform(scaledSize, CGAffineTransformMakeScale(0.1, 0.1))
        
        self.princess = nil
        
        super.init(texture: zombieTexture, color:nil, size: scaledSize)
    }
    
    init(texture zombieTexture: SKTexture!)
    {
        var scaledSize = zombieTexture.size()
        scaledSize = CGSizeApplyAffineTransform(scaledSize, CGAffineTransformMakeScale(0.1, 0.1))
        
        self.princess = nil
        
        super.init(texture: zombieTexture, color:nil, size: scaledSize)
    }

    required init(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}