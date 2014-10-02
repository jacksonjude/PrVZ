//
//  zombie.swift
//  PrVZ Dev
//
//  Created by jackson on 9/23/14.
//  Copyright (c) 2014 jackson. All rights reserved.
//

import Foundation
import SpriteKit

class zombie: SKSpriteNode
{
    override init()
    {
        let zombieTexture = SKTexture(imageNamed: "zombie.png")
        var scaledSize = zombieTexture.size()
        scaledSize = CGSizeApplyAffineTransform(scaledSize, CGAffineTransformMakeScale(0.1, 0.1))
        super.init(texture: zombieTexture, color:nil, size: scaledSize)
    }

    required init(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}