//
//  GameScene.swift
//  Amazeballs
//
//  Created by Daniel Flax on 5/19/15.
//  Copyright (c) 2015 Daniel Flax. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {

	override func didMoveToView(view: SKView) {
	}

	override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {

		for touch in (touches as! Set<UITouch>) {
            let location = touch.locationInNode(self)
            
            let sprite = SKSpriteNode(imageNamed:"Spaceship")
            
            sprite.xScale = 0.5
            sprite.yScale = 0.5
            sprite.position = location
            
            let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
            
            sprite.runAction(SKAction.repeatActionForever(action))
            
            self.addChild(sprite)
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
