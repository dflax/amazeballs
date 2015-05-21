amazeballs
==========

Update: November 10, 2013
Test cases needed. Goal is to leverage XCtest class.

AmazeBalls iOS App

This is a simple example app to demonstrate some of the capabilities of SpriteKit.

Each time the user taps on the screen, a ball is placed at that position.

The user can change a variety of settings including:
	- gravity power
	- whether the device's accelerometer is taken into account
	- whether there's a bounding wall surrounding the screen
	- the amount of bouncyness each ball has when collisions take place
	- the type of ball to be used

By using Auto-Layout and appropriate constraints, a single Storyboard
can be used across iPad, iPod Touch and iPhone devices.

The app and it's code are released under the MIT Open Source License (see the included
license file).

Enjoy.


--Daniel Flax
August 25, 2013


Enhancement Ideas

Instead of using number 2000-2006 to represent the ball types, put in an enum to represent all of the ball types:
