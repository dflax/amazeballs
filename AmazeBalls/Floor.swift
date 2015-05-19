//
//  Floor.swift
//  AmazeBalls
//
//  Created by Daniel Flax on 5/19/15.
//  Copyright (c) 2015 Daniel Flax. All rights reserved.
//

import UIKit
import SpriteKit

class Floor: SKSpriteNode {

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	init() {
		let emptyTexture = SKTexture(imageNamed: "StarterNode")
		super.init(texture: emptyTexture, color: SKColor.clearColor(), size: emptyTexture.size())

		var wallSize: CGSize
		let wallOrigin = CGPoint(x: ScreenHeight / 2.0, y: 30.0)

		// Set the wall image name depending on device type
		var floorImageName: String = ""
		if (isPad) {
			wallSize = CGSize(width: 1004.0, height: 10.0)
			floorImageName = "floor_ipad"
		} else {

			// Use the right image for 3.5" vs. 4" iPhone / iPod Touch
			if (ScreenHeight > 500.0) {
				wallSize = CGSize(width: 548.0, height: 10.0)
				floorImageName = "floor_iphone4"
			} else {
				wallSize = CGSize(width: 460.0, height: 10.0)
				floorImageName = "floor_iphone35"
			}
		}

		// Set the actual texture for the object
		let texture = SKTexture(imageNamed: floorImageName)
		self.texture = texture
		self.size = wallSize

		// Set the physics body properties for the wall
		physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: self.size.width, height: self.size.height))
		physicsBody?.affectedByGravity = false
		physicsBody?.dynamic           = false

		position = wallOrigin

		// Set the category bit masks for collision, etc.
		physicsBody?.categoryBitMask    = CollisionCategories.Floor
		physicsBody?.contactTestBitMask = CollisionCategories.Ball
	}

}

