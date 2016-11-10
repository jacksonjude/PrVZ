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
    var uuid = UUID().uuidString
    var princess: Princess!
    
    init()
    {
        let zombieTexture = SKTexture(imageNamed: "zombie.png")
        var scaledSize = zombieTexture.size()
        scaledSize = scaledSize.applying(CGAffineTransform(scaleX: 0.1, y: 0.1))
        
        self.princess = nil
        
        super.init(texture: zombieTexture, color: UIColor.clear, size: scaledSize)
    }
    
    init(texture zombieTexture: SKTexture?, size zombieSize: CGSize)
    {
        var scaledSize = zombieTexture!.size()
        scaledSize = scaledSize.applying(CGAffineTransform(scaleX: zombieSize.width, y: zombieSize.height))
        
        self.princess = nil
        
        super.init(texture: zombieTexture, color: UIColor.clear, size: scaledSize)
    }

    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        self.health = aDecoder.decodeInteger(forKey: "health")
    }
    
    override func encode(with aCoder: NSCoder)
    {
        super.encode(with: aCoder)
        
        aCoder.encode(self.health, forKey: "health")
    }
}
