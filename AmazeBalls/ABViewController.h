//
//  ABViewController.h
//  AmazeBalls
//
//  Created by Daniel Flax on 6/15/13.
//  Copyright (c) 2013 Piece of Cake Adventures, LLC. All rights reserved.
//
// This is the main view controller for the app.
// The view controller conforms to the delegate protocol for the settings controller, so that when the user changes settings, those changes are sent here to the View Controller.
//
// The ViewController loads an SKScene for the app to be the main SpriteKit scene.

#import <UIKit/UIKit.h>
#import "ABSettingsViewController.h"
#import "ABBallScene.h"

@interface ABViewController : UIViewController <ABSettingsDelegate> {
	ABBallScene * ballScene;
}

@end

