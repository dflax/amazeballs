//
//  SettingsViewController.swift
//  AmazeBalls
//
//  Created by Daniel Flax on 5/18/15.
//  Copyright (c) 2015 Daniel Flax. All rights reserved.
//

import UIKit

// Declare a delegate protocol to send back the settings values the user selects and to handle cancellation
protocol SettingsDelegateProtocol {
//	func SettingsViewController(settingsViewController: SettingsViewController, cancelled: Bool)
//	func SettingsViewController(settingsViewController: SettingsViewController, gravitySetting: CGFloat, bouncySetting: CGFloat, boundingWallSetting: Bool, accelerometerSetting: Bool, activeBall: Int)
}

class SettingsViewController: UIViewController, Printable {

	// UI Widgets to grab their values
	@IBOutlet weak var gravitySlider:       UISlider!
	@IBOutlet weak var bouncynessSlider:    UISlider!
	@IBOutlet weak var boundingSwitch:      UISwitch!
	@IBOutlet weak var accelerometerSwitch: UISwitch!

	// Buttons for ball type selections
	@IBOutlet weak var buttonAmazeBall:     UIButton!
	@IBOutlet weak var buttonBaseball:      UIButton!
	@IBOutlet weak var buttonBasketball:    UIButton!
	@IBOutlet weak var buttonFootball:      UIButton!
	@IBOutlet weak var buttonPumpkin:       UIButton!
	@IBOutlet weak var buttonSoccerBallOne: UIButton!
	@IBOutlet weak var buttonSoccerBallTwo: UIButton!
	@IBOutlet weak var buttonRandom:        UIButton!

	// Property to keep track of the active ball
	var activeBall: Int = 2000

	// Delegate to support Clown actions
	var delegate: SettingsDelegateProtocol?

	// Support the Printable protocol
	override var description: String {
		return "Swettings View Controller"
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}

	// When loading the view, retrieve the prevously set values for the settings and update the switches and sliders accordingly
	override func viewDidLoad() {
        super.viewDidLoad()

		// Set the initial state for the view's value controls
		let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
/*
		if let grav: Float = defaults.floatForKey("gravityValue") as? Float {
			gravitySlider.value = grav
		} else {
			gravitySlider.value = -9.8 / 40.0
		}
		if let bouncy: Float = defaults.floatForKey("bouncyness") as? Float {
			bouncynessSlider.value = bouncy
		} else {
			bouncynessSlider.value = 0.5
		}
		if let bSwitch: Bool = defaults.boolForKey("boundingWallSetting") as? Bool {
			boundingSwitch.on = bSwitch
		} else {
			boundingSwitch.on = false
		}
		if let accel: Bool = defaults.boolForKey("accelerometerSetting") as? Bool {
			accelerometerSwitch.on = accel
		} else {
			accelerometerSwitch.on = false
		}
		if let aBall: Int = defaults.integerForKey("activeBall") as? Int {
			activeBall = aBall
		} else {
			activeBall = 2000
		}
*/
		// Visually show which ball is currently active
		let currentBallButton = self.view.viewWithTag(activeBall) as! UIButton
		currentBallButton.layer.borderColor = UIColor(red: 0.0, green: 122.0 / 255.0, blue: 1.0, alpha: 1.0) as! CGColorRef
		currentBallButton.layer.borderWidth = 1.0
	}




	/*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}



/*


// If the user taps cancel, call the delegate method to cancel (dismissing the settings view controller)
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

// When user taps on a ball type, clear all selections and update UI to demonstrate which one's been
// selected, also update the _activeBall value.
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


*/