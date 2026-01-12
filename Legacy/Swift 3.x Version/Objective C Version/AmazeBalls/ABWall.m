//
//  ABWall.m
//  AmazeBalls
//
//  Created by Daniel Flax on 6/15/13.
//  Copyright (c) 2013 Piece of Cake Adventures, LLC. All rights reserved.
//
//
// The MIT License (MIT)
//
// Copyright (c) 2013 Daniel Flax
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//


#import "ABWall.h"
#import "ABBallScene.h"

@implementation ABWall

// Create the wall
+ (instancetype)newWall {

	// Determine the device type to load the appropriate wall image
	CGSize wallSize;
	BOOL isPad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
	CGRect screenSize = [[UIScreen mainScreen] bounds];
	CGPoint wallOrigin = CGPointMake(screenSize.size.height / 2.0, 30.0);

	// Set the wall image name depending on device type
	NSString * floorImageName;
	if (isPad) {
		wallSize = CGSizeMake(1004.0, 10.0);
		floorImageName = @"floor_ipad";
	} else {

		// Use the right image for 3.5" vs. 4" iPhone / iPod Touch
		if (screenSize.size.height > 500.0) {
			wallSize = CGSizeMake(548.0, 10.0);
			floorImageName = @"floor_iphone4";
		} else {
			wallSize = CGSizeMake(460.0, 10.0);
			floorImageName = @"floor_iphone35";
		}
	}

	// Create the new wall object
	ABWall * wall = [[ABWall alloc] initWithImageNamed:floorImageName];

	// Set the physics body properties for the wall
	wall.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(wall.frame.size.width, wall.frame.size.height)];
	wall.physicsBody.affectedByGravity = NO;
	wall.physicsBody.dynamic           = NO;

	wall.position = wallOrigin;

	// Set the category bit masks for collision, etc.
	wall.physicsBody.categoryBitMask    = wallCategory;
	wall.physicsBody.collisionBitMask   = wallCategory | wallCategory | edgeCategory;
	wall.physicsBody.contactTestBitMask = ballCategory | wallCategory | edgeCategory;

	return wall;
}

@end
