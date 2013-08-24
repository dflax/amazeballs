//
//  ABWall.m
//  AmazeBalls
//
//  Created by Daniel Flax on 6/15/13.
//  Copyright (c) 2013 Piece of Cake Adventures, LLC. All rights reserved.
//

#import "ABWall.h"
#import "ABBallScene.h"

@implementation ABWall

// Create the wall - originally meant to have ability for a wall in multiple locations
// may enhance this at some point to actually provide multiple locations
+ (instancetype)newWallAtLocation:(int)location withRotation:(CGFloat)rotation {
	CGSize wallSize;
	CGPoint wallOrigin;
	if ([self isPad]) {
		wallSize = CGSizeMake(1004.0, 10.0);
		wallOrigin = CGPointMake(512.0, 30.0);
	} else {
		wallSize = CGSizeMake(548.0, 10.0);
		wallOrigin = CGPointMake(284.0, 30.0);
	}
	ABWall * wall = [[ABWall alloc] initWithColor:[SKColor redColor] size:wallSize];

	// Set the physics body properties for the wall
	wall.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(wall.frame.size.width, wall.frame.size.height)];
	wall.physicsBody.affectedByGravity = NO;
	wall.physicsBody.dynamic           = NO;

	wall.zRotation = rotation;
	wall.position = wallOrigin;

	// Set the category bit masks for collision, etc.
	wall.physicsBody.categoryBitMask    = wallCategory;
	wall.physicsBody.collisionBitMask   = wallCategory | wallCategory | edgeCategory;
	wall.physicsBody.contactTestBitMask = ballCategory | wallCategory | edgeCategory;

	return wall;
}

// Utility method to determine if working on an iPad or not
+ (BOOL)isPad {
#ifdef UI_USER_INTERFACE_IDIOM
	return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
#endif
	return NO;
}

@end
