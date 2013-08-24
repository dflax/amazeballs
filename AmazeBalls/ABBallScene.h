//
//  ABBallScene.h
//  AmazeBalls
//
//  Created by Daniel Flax on 6/15/13.
//  Copyright (c) 2013 Piece of Cake Adventures, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>

// Set up the bit masks for each of the node types - to allow for collision detection and appropriate handling
static const uint32_t ballCategory =  0x1 << 0;
static const uint32_t wallCategory =  0x1 << 1;
static const uint32_t edgeCategory =  0x1 << 2;

@interface ABBallScene : SKScene <SKPhysicsContactDelegate>

- (void)updateWorldPhysicsSettings;

@end
