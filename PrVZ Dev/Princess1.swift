//
//  princess.swift
//  PrVZ Dev
//
//  Created by jackson on 9/27/14.
//  Copyright (c) 2014 jackson. All rights reserved.
//

import Foundation
import Spritekit

class Princess: SKSpriteNode
{
    override init()
    {
        let princessTexture = SKTexture(imageNamed: "princess.png")
        super.init(texture: princessTexture, color:nil, size: princessTexture.size())
    }
    
    required init(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}