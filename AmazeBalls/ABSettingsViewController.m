//
//  ABSettingsViewController.m
//  AmazeBalls
//
//  Created by Daniel Flax on 6/15/13.
//  Copyright (c) 2013 Piece of Cake Adventures, LLC. All rights reserved.
//

#import "ABSettingsViewController.h"
#import "ABViewController.h"

@interface ABSettingsViewController ()
@property int activeBall;
@end

@implementation ABSettingsViewController

// The default initializer
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
	}
	return self;
}

// When loading the view, retrieve the prevously set values for the settings and update the switches and sliders
- (void)viewDidLoad {
	[super viewDidLoad];

	// Set the initial state for the view's value controls
	NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];

	_gravitySlider.value    = [userDefaults floatForKey:@"gravityValue"]         ? [userDefaults floatForKey:@"gravityValue"] / -40.0 : -9.8 / -40.0;
	_bouncynessSlider.value = [userDefaults floatForKey:@"bouncyness"]           ? [userDefaults floatForKey:@"bouncyness"]           :  0.5;
	_boundingSwitch.on      = [userDefaults boolForKey:@"boundingWallSetting"]   ? [userDefaults boolForKey:@"boundingWallSetting"]          :  NO;
	_accelerometerSwitch.on = [userDefaults boolForKey:@"accelerometerSetting"]  ? [userDefaults boolForKey:@"accelerometerSetting"]          :  NO;

	// Grab the value for the active ball
	_activeBall = [userDefaults integerForKey:@"activeBall"]  ? [userDefaults integerForKey:@"activeBall"]          :  2000;
	UIButton * currentBall = (UIButton *)[self.view viewWithTag:_activeBall];
	currentBall.layer.borderColor = [[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] CGColor];
	currentBall.layer.borderWidth = 1.0;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

// If the user taps cancel, call the delegate method to cancel (dismiss the settings view controller)
- (IBAction)cancelSettingsView:(id)sender {
	[_delegate ABSettingsViewController:self didCancelSettings:YES];
}

// If the user taps save, call the delegate method to save - with all of the widget values
- (IBAction)saveSettings:(id)sender {
	[_delegate ABSettingsViewController:self
						 didSaveGravity:_gravitySlider.value
						  andBouncyness:_bouncynessSlider.value
						andBoundingWall:_boundingSwitch.on
					   andAccelerometer:_accelerometerSwitch.on
						  andActiveBall:_activeBall];
}

- (void)configureBallOptionButtons {
	NSLog(@"confiugring for ball: %d", _activeBall);

	// Select the button that's currently active

}

- (IBAction)selectBallType:(id)sender {
	_buttonAmazeBall.layer.borderWidth     = 0.0;
	_buttonBaseball.layer.borderWidth      = 0.0;
	_buttonBasketball.layer.borderWidth    = 0.0;
	_buttonFootball.layer.borderWidth      = 0.0;
	_buttonPumpkin.layer.borderWidth       = 0.0;
	_buttonSoccerBallOne.layer.borderWidth = 0.0;
	_buttonSoccerBallTwo.layer.borderWidth = 0.0;
	_buttonRandom.layer.borderWidth        = 0.0;

	UIButton * senderButton = (UIButton *)sender;

	senderButton.layer.borderColor = [[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] CGColor];
	senderButton.layer.borderWidth = 1.0;

	_activeBall = senderButton.tag;
}


@end
