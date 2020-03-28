//
//  SettingsViewController.swift
//  AmazeBalls
//
//  Created by Daniel Flax on 5/18/15.
//  Copyright (c) 2015 Daniel Flax. All rights reserved.
//
//                        The MIT License (MIT)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
// the Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import UIKit
import SpriteKit

// Declare a delegate protocol to send back the settings values the user selects and to handle cancellation
protocol SettingsDelegateProtocol {
	func settingsViewController(_ viewController: SettingsViewController, cancelled: Bool)
	func settingsViewController(_ viewController: SettingsViewController, gravitySetting: Float, bouncySetting: Float, boundingWallSetting: Bool, accelerometerSetting: Bool, activeBall: Int)
}

class SettingsViewController:UIViewController, CustomStringConvertible {

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

	// If the user taps cancel, call the delegate method to cancel (dismissing the settings view controller)
	@IBAction func cancelSettingsView() {
		delegate?.settingsViewController(self, cancelled: true)
	}

	// If the user taps save, call the delegate method to save - with all of the widget values
	@IBAction func saveSetting() {
		delegate?.settingsViewController(self, gravitySetting: gravitySlider.value, bouncySetting: bouncynessSlider.value, boundingWallSetting: boundingSwitch.isOn, accelerometerSetting: accelerometerSwitch.isOn, activeBall: activeBall)
	}

	// When user taps on a ball type, clear all selections and update UI to demonstrate which one's been selected, also update the _activeBall value.
	@IBAction func selectBallType(_ sender : AnyObject) {

		// Cast the sender as a Button
		let senderButton = sender as! UIButton

		buttonAmazeBall.layer.borderWidth     = 0.0
		buttonBaseball.layer.borderWidth      = 0.0
		buttonBasketball.layer.borderWidth    = 0.0
		buttonFootball.layer.borderWidth      = 0.0
		buttonPumpkin.layer.borderWidth       = 0.0
		buttonSoccerBallOne.layer.borderWidth = 0.0
		buttonSoccerBallTwo.layer.borderWidth = 0.0
		buttonRandom.layer.borderWidth        = 0.0

		senderButton.layer.borderColor = UIColor(red: 0.0, green: 122.0 / 255.0, blue: 1.0, alpha: 1.0).cgColor
		senderButton.layer.borderWidth = 1.0
		activeBall = sender.tag
	}

	// When loading the view, retrieve the prevously set values for the settings and update the switches and sliders accordingly
	override func viewDidLoad() {
		super.viewDidLoad()

		// Set the initial state for the view's value controls
		let defaults: UserDefaults = UserDefaults.standard

		gravitySlider.value    = defaults.value(forKey: "gravityValue") != nil ? abs(defaults.value(forKey: "gravityValue") as! Float) : 9.8
		bouncynessSlider.value = defaults.value(forKey: "bouncyness")   != nil ?     defaults.value(forKey: "bouncyness") as! Float    : 1.0

		boundingSwitch.isOn = defaults.value(forKey: "boundingWallSetting") != nil ? defaults.value(forKey: "boundingWallSetting") as! Bool : false
		accelerometerSwitch.isOn = defaults.value(forKey: "accelerometerSetting") != nil ? defaults.value(forKey: "accelerometerSetting") as! Bool : false
		activeBall = defaults.value(forKey: "activeBall") != nil ? defaults.value(forKey: "activeBall") as! Int : 2000
		activeBall = activeBall == 0 ? 2000 : activeBall

		// Visually show which ball is currently active
		let currentBallButton = self.view.viewWithTag(activeBall) as! UIButton

		currentBallButton.layer.borderColor = UIColor(red: 0.0, green: 122.0 / 255.0, blue: 1.0, alpha: 1.0).cgColor
		currentBallButton.layer.borderWidth = 1.0
		currentBallButton.layer.isHidden = false
	}
	
	
	
}

