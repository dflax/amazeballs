//
//  ABWall.h
//  AmazeBalls
//
//  Created by Daniel Flax on 6/15/13.
//  Copyright (c) 2013 Piece of Cake Adventures, LLC. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface ABWall : SKSpriteNode

+ (instancetype)newWallAtLocation:(int)location withRotation:(CGFloat)rotation;

@end
