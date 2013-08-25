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
	BOOL isPad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
	CGRect screenSize = [[UIScreen mainScreen] bounds];
	CGPoint wallOrigin = CGPointMake(screenSize.size.height / 2.0, 30.0);

	// Set the background Brick Wall image via a spritenode
	NSString * floorImageName;
	if (isPad) {
		wallSize = CGSizeMake(1004.0, 10.0);
		floorImageName = @"floor_ipad";
	} else {
		if (screenSize.size.height > 500.0) {
			wallSize = CGSizeMake(548.0, 10.0);
			floorImageName = @"floor_iphone4";
		} else {
			wallSize = CGSizeMake(460.0, 10.0);
			floorImageName = @"floor_iphone35";
		}
	}

	ABWall * wall = [[ABWall alloc] initWithImageNamed:floorImageName];

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

@end
