//
//  archerZombie.swift
//  PrVZ Dev
//
//  Created by jackson on 10/16/14.
//  Copyright (c) 2014 jackson. All rights reserved.
//

import Foundation
import SpriteKit

class CatZombie: GenericZombie
{
    var hairballsSpawned = NSInteger()
    override init()
    {
        let zombieTexture = SKTexture(imageNamed: "cat.png")
        super.init(texture: zombieTexture, size: CGSize(width: 0.1, height: 0.1))
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}