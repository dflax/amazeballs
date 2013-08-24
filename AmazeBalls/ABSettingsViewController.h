//
//  ABSettingsViewController.h
//  AmazeBalls
//
//  Created by Daniel Flax on 6/15/13.
//  Copyright (c) 2013 Piece of Cake Adventures, LLC. All rights reserved.
//
// ViewController for the Settings View. Defines the Outlets and Actions to handle the various
// settings switches. Also defines a delegate protocol to send back the resulting actions: cancel and save.

#import <UIKit/UIKit.h>
@class ABSettingsViewController;

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

@property (nonatomic, strong) IBOutlet UISlider * gravitySlider;
@property (nonatomic, strong) IBOutlet UISlider * bouncynessSlider;
@property (nonatomic, strong) IBOutlet UISwitch * boundingSwitch;
@property (nonatomic, strong) IBOutlet UISwitch * accelerometerSwitch;

// Buttons for ball types
@property (nonatomic, strong) IBOutlet UIButton * buttonAmazeBall;
@property (nonatomic, strong) IBOutlet UIButton * buttonBaseball;
@property (nonatomic, strong) IBOutlet UIButton * buttonBasketball;
@property (nonatomic, strong) IBOutlet UIButton * buttonFootball;
@property (nonatomic, strong) IBOutlet UIButton * buttonPumpkin;
@property (nonatomic, strong) IBOutlet UIButton * buttonSoccerBallOne;
@property (nonatomic, strong) IBOutlet UIButton * buttonSoccerBallTwo;
@property (nonatomic, strong) IBOutlet UIButton * buttonRandom;

@property (nonatomic, strong) id<ABSettingsDelegate> delegate;

- (IBAction)cancelSettingsView:(id)sender;
- (IBAction)saveSettings:(id)sender;
- (IBAction)selectBallType:(id)sender;

@end
