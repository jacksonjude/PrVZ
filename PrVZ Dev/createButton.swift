//
//  createButton.swift
//  PrVZ Dev
//
//  Created by jackson on 9/19/14.
//  Copyright (c) 2014 jackson. All rights reserved.
//

import Foundation
import SpriteKit

class createButton
{
    class func addButton(buttonname: NSString, cords: CGPoint, image: SKTexture, size: CGSize) -> SKSpriteNode
    {
        let button = SKSpriteNode(texture: image)
        button.name = buttonname
        button.position = cords
        button.size = size
        
        return (button)
    }
}