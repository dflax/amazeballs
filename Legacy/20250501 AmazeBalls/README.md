Amazeballs

==========

Update April 1, 2025

Update to check for Vision Pro compatibility. All set.

==========

Update April 16, 2020

Will release this version. Inferior performance for the newer, more complicated ball shapes. The creation of the SKTextures is a challenge. Need to figure out how to use the SKTexture preload.

==========

Update: March 29, 2020

Updated with a bunch of additional ball images. Performance is lousy on selecting random balls. Need to figure out how to improve that performance.

==========

Update: March 28, 2020

So.... it turns out it's really difficult to convert a Swift 2.x project to a current version. I attempted to install older versions of XCode (8.3.3 and 10.1) to facilitate the conversion of the project targets, but that doesn't seem to have worked. So, given that this is a fairly simple project, I'm going to stash the legacy version of the project and build a new one from scratch.

New:
New graphics that are all PDF vector images. This should easily facilitate proper Auto-Layout, full screen behavior on all devices and sizes.


--Daniel Flax
March 28, 2020

==================


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

--==========--
May 21, 2015

Enhancement Ideas

Instead of using number 2000-2006 to represent the ball types, put in an enum to represent all of the ball types:
While the collision logic is in place to detect when balls collide and when they collide with the bounding wall, the app doesn't do anything interested with that collision.
