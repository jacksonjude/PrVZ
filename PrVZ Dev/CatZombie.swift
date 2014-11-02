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
        var zombieTexture = SKTexture(imageNamed: "archerZombie.png")
        super.init(texture: zombieTexture)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}