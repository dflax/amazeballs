//
//  SettingsViewController.swift
//  AmazeBalls
//
//  Created by Daniel Flax on 5/18/15.
//  Copyright (c) 2015 Daniel Flax. All rights reserved.
//

import UIKit
import SpriteKit

// Declare a delegate protocol to send back the settings values the user selects and to handle cancellation
protocol SettingsDelegateProtocol {
	func settingsViewController(viewController: SettingsViewController, cancelled: Bool)
	func settingsViewController(viewController: SettingsViewController, gravitySetting: Float, bouncySetting: Float, boundingWallSetting: Bool, accelerometerSetting: Bool, activeBall: Int)
}

class SettingsViewController:UIViewController, Printable {

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

//		gravitySlider.value    = CGFloat(userDefaults.floatForKey("gravityValue"))        ? [userDefaults floatForKey:@"gravityValue"] / -40.0 : -9.8 / -40.0;
//		bouncynessSlider.value = userDefaults.floatForKey("bouncyness")          ? [userDefaults floatForKey:@"bouncyness"]           :  0.5;
//		boundingSwitch.on      = userDefaults.boolForKey("boundingWallSetting")  ? [userDefaults boolForKey:@"boundingWallSetting"]   :  NO;
//		accelerometerSwitch.on = userDefaults.boolForKey("accelerometerSetting") ? [userDefaults boolForKey:@"accelerometerSetting"]  :  NO;
//		activeBall             = userDefaults.integerForKey("activeBall")        ? [userDefaults integerForKey:@"activeBall"]         :  2000;
//		
//		// Visually show which ball is currently active
//		UIButton * currentBall = (UIButton *)[self.view viewWithTag:_activeBall];
//		currentBall.layer.borderColor = [[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] CGColor];
//		currentBall.layer.borderWidth = 1.0;

		let grav = defaults.valueForKey("gravityValue") as! Float
println("grav: \(grav)")
		gravitySlider.value = defaults.valueForKey("gravityValue") as! Float
		bouncynessSlider.value = defaults.valueForKey("bouncyness") as! Float
		boundingSwitch.on = defaults.boolForKey("boundingWallSetting")
		accelerometerSwitch.on = defaults.boolForKey("accelerometerSetting")
		activeBall = defaults.integerForKey("activeBall")

		// Visually show which ball is currently active
		let currentBallButton = self.view.viewWithTag(activeBall) as! UIButton
		currentBallButton.layer.borderColor = UIColor(red: 0.0, green: 122.0 / 255.0, blue: 1.0, alpha: 1.0) as! CGColorRef
		currentBallButton.layer.borderWidth = 1.0
	}

	// If the user taps cancel, call the delegate method to cancel (dismissing the settings view controller)
	@IBAction func cancelSettingsView() {
		delegate?.settingsViewController(self, cancelled: true)
	}

	// If the user taps save, call the delegate method to save - with all of the widget values
	@IBAction func saveSetting() {
		delegate?.settingsViewController(self,
			gravitySetting: gravitySlider.value,
			bouncySetting: bouncynessSlider.value,
			boundingWallSetting: boundingSwitch.on,
			accelerometerSetting: accelerometerSwitch.on,
			activeBall: activeBall
		)
	}

	// When user taps on a ball type, clear all selections and update UI to demonstrate which one's been selected, also update the _activeBall value.
	@IBAction func selectBallType() {
		buttonAmazeBall.layer.borderWidth     = 0.0
		buttonBaseball.layer.borderWidth      = 0.0
		buttonBasketball.layer.borderWidth    = 0.0
		buttonFootball.layer.borderWidth      = 0.0
		buttonPumpkin.layer.borderWidth       = 0.0
		buttonSoccerBallOne.layer.borderWidth = 0.0
		buttonSoccerBallTwo.layer.borderWidth = 0.0
		buttonRandom.layer.borderWidth        = 0.0

		selectedBallButton.layer.borderColor = UIColor(red: 0.0, green: 122.0 / 255.0, blue: 1.0, alpha: 1.0) as! CGColorRef
		selectedBallButton.layer.borderWidth = 1.0

		activeBall = selectedBallButton.tag;
	}

}

