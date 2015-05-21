//
//  Floor.swift
//  AmazeBalls
//
//  Created by Daniel Flax on 5/18/15.
//  Copyright (c) 2015 Daniel Flax. All rights reserved.
//
//                        The MIT License (MIT)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
// the Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
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

		var floorSize: CGSize
		let floorOrigin = CGPoint(x: ScreenWidth / 2.0, y: 30.0)

		// Set the wall image name depending on device type
		var floorImageName: String = ""
		if (isPad) {
			floorSize = CGSize(width: 1004.0, height: 10.0)
			floorImageName = "floor_ipad"
		} else {

			// Use the right image for 3.5" vs. 4" iPhone / iPod Touch
			if (ScreenHeight > 500.0) {
				floorSize = CGSize(width: 548.0, height: 10.0)
				floorImageName = "floor_iphone4"
			} else {
				floorSize = CGSize(width: 460.0, height: 10.0)
				floorImageName = "floor_iphone35"
			}
		}

		// Set the actual texture for the object
		let texture = SKTexture(imageNamed: floorImageName)
		self.texture = texture
		self.size = floorSize

		// Set the physics body properties for the wall
		physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: self.size.width, height: self.size.height))
		physicsBody?.affectedByGravity = false
		physicsBody?.dynamic           = false

		position = floorOrigin

		// Set the category bit masks for collision, etc.
		physicsBody?.categoryBitMask    = CollisionCategories.Floor
		physicsBody?.contactTestBitMask = CollisionCategories.Ball
	}
}



