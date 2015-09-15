//
//  princess.swift
//  PrVZ Dev
//
//  Created by jackson on 9/27/14.
//  Copyright (c) 2014 jackson. All rights reserved.
//

import Foundation
import SpriteKit

class Princess: SKSpriteNode
{
    init()
    {
        let princessTexture = SKTexture(imageNamed: "princess.png")
        super.init(texture: princessTexture, color: UIColor.clearColor(), size: princessTexture.size())
    }
    
    init(textureName: String)
    {
        let princessTexture = SKTexture(imageNamed: textureName)
        super.init(texture: princessTexture, color: UIColor.clearColor(), size: princessTexture.size())
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
}