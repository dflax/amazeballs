//
//  ABSettingsViewController.h
//  AmazeBalls
//
//  Created by Daniel Flax on 6/15/13.
//  Copyright (c) 2013 Piece of Cake Adventures, LLC. All rights reserved.
//
//
// ViewController for the Settings View. Defines the Outlets and Actions to
// handle the various settings switches. Also defines a delegate protocol to
// send back the resulting actions: cancel and save.
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


#import <UIKit/UIKit.h>
@class ABSettingsViewController;

// Declare a delegate protocol to send back the settings values the user selects
// and to handle cancellation
@protocol ABSettingsDelegate <NSObject>
- (void)ABSettingsViewController:(ABSettingsViewController *)settingsViewController didCancelSettings:(BOOL)cancelled;
- (void)ABSettingsViewController:(ABSettingsViewController *)settingsViewController
				  didSaveGravity:(CGFloat)gravitySetting
				   andBouncyness:(CGFloat)bouncySetting
				 andBoundingWall:(BOOL)boundingWallSetting
				andAccelerometer:(BOOL)accelerometerSetting
				   andActiveBall:(int)activeBall;
@end

@interface ABSettingsViewController : UIViewController

// UI Widgets to grab their values
@property (nonatomic, strong) IBOutlet UISlider * gravitySlider;
@property (nonatomic, strong) IBOutlet UISlider * bouncynessSlider;
@property (nonatomic, strong) IBOutlet UISwitch * boundingSwitch;
@property (nonatomic, strong) IBOutlet UISwitch * accelerometerSwitch;

// Buttons for ball type selections
@property (nonatomic, strong) IBOutlet UIButton * buttonAmazeBall;
@property (nonatomic, strong) IBOutlet UIButton * buttonBaseball;
@property (nonatomic, strong) IBOutlet UIButton * buttonBasketball;
@property (nonatomic, strong) IBOutlet UIButton * buttonFootball;
@property (nonatomic, strong) IBOutlet UIButton * buttonPumpkin;
@property (nonatomic, strong) IBOutlet UIButton * buttonSoccerBallOne;
@property (nonatomic, strong) IBOutlet UIButton * buttonSoccerBallTwo;
@property (nonatomic, strong) IBOutlet UIButton * buttonRandom;

@property (nonatomic, strong) id<ABSettingsDelegate> delegate;

// Actions for saving, cancelling and selecting one of the ball types
- (IBAction)cancelSettingsView:(id)sender;
- (IBAction)saveSettings:(id)sender;
- (IBAction)selectBallType:(id)sender;

@end
