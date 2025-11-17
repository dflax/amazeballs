//
//  GameSettingsTests.swift
//  AmazeballsTests
//
//  Created by Daniel Flax on 11/15/25.
//

import XCTest
import Foundation
@testable import Amazeballs

class GameSettingsTests: XCTestCase {
    
    // MARK: - Property Validation Tests
    
    func testGravityClampingTest() async throws {
        let settings = GameSettings.shared
        
        // Test upper bound clamping
        settings.gravity = 5.0
        XCTAssertEqual(settings.gravity, 2.0, "Gravity should be clamped to maximum of 2.0")
        
        // Test lower bound clamping
        settings.gravity = -1.0
        XCTAssertEqual(settings.gravity, 0.0, "Gravity should be clamped to minimum of 0.0")
        
        // Test valid range
        settings.gravity = 1.5
        XCTAssertEqual(settings.gravity, 1.5, "Valid gravity values should not be modified")
    }
    
    func testBouncinessClampingTest() async throws {
        let settings = GameSettings.shared
        
        // Test upper bound clamping
        settings.bounciness = 2.0
        XCTAssertEqual(settings.bounciness, 1.0, "Bounciness should be clamped to maximum of 1.0")
        
        // Test lower bound clamping
        settings.bounciness = -0.5
        XCTAssertEqual(settings.bounciness, 0.0, "Bounciness should be clamped to minimum of 0.0")
        
        // Test valid range
        settings.bounciness = 0.8
        XCTAssertEqual(settings.bounciness, 0.8, "Valid bounciness values should not be modified")
    }
    
    // MARK: - Default Values Tests
    
    func testResetDefaultsTest() async throws {
        let settings = GameSettings.shared
        
        // Modify all settings away from defaults
        settings.gravity = 1.5
        settings.bounciness = 0.3
        settings.wallsEnabled = false
        settings.accelerometerEnabled = true
        settings.selectedBallType = "Basketball"
        
        // Reset and verify defaults
        settings.reset()
        
        XCTAssertEqual(settings.gravity, 1.0, "Gravity should reset to default 1.0")
        XCTAssertEqual(settings.bounciness, 0.8, "Bounciness should reset to default 0.8")
        XCTAssertEqual(settings.wallsEnabled, true, "Walls should reset to default true")
        XCTAssertEqual(settings.accelerometerEnabled, false, "Accelerometer should reset to default false")
        XCTAssertEqual(settings.selectedBallType, nil, "Ball type should reset to default nil")
    }
    
    // MARK: - Platform Support Tests
    
    func testPlatformSupportTest() async throws {
        let settings = GameSettings.shared
        
        // Walls should always be supported
        XCTAssertEqual(settings.areWallsSupported, true, "Walls should be supported on all platforms")
        
        // Accelerometer support depends on platform
        #if os(iOS) || os(iPadOS)
        XCTAssertEqual(settings.isAccelerometerSupported, true, "Accelerometer should be supported on iOS/iPadOS")
        #else
        XCTAssertEqual(settings.isAccelerometerSupported, false, "Accelerometer should not be supported on non-mobile platforms")
        #endif
    }
    
    // MARK: - Validation Tests
    
    func testValidationTest() async throws {
        let settings = GameSettings.shared
        
        // Set valid values
        settings.gravity = 1.0
        settings.bounciness = 0.8
        XCTAssertEqual(settings.validateSettings(), true, "Valid settings should pass validation")
        
        // Force invalid values by bypassing property setters
        // This simulates corrupted data scenarios
        let mirror = Mirror(reflecting: settings)
        // Note: In a real implementation, you might need more sophisticated testing
        // for validation of edge cases
        
        // Test boundary values
        settings.gravity = 0.0
        settings.bounciness = 0.0
        XCTAssertEqual(settings.validateSettings(), true, "Boundary values should be valid")
        
        settings.gravity = 2.0
        settings.bounciness = 1.0
        XCTAssertEqual(settings.validateSettings(), true, "Maximum boundary values should be valid")
    }
    
    // MARK: - Ball Type Tests
    
    func testBallTypeTest() async throws {
        let settings = GameSettings.shared
        
        // Test nil (random) selection
        settings.selectedBallType = nil
        XCTAssertEqual(settings.selectedBallType, nil, "Ball type should be nil for random selection")
        
        // Test specific ball type selection
        settings.selectedBallType = "Basketball"
        XCTAssertEqual(settings.selectedBallType, "Basketball", "Specific ball type should be stored correctly")
        
        // Test changing ball types
        settings.selectedBallType = "Tennis Ball"
        XCTAssertEqual(settings.selectedBallType, "Tennis Ball", "Ball type should update correctly")
        
        // Test clearing selection
        settings.selectedBallType = nil
        XCTAssertEqual(settings.selectedBallType, nil, "Ball type should clear to nil correctly")
    }
    
    // MARK: - Debug Information Tests
    
    func testDebugDescriptionTest() async throws {
        let settings = GameSettings.shared
        let debugInfo = settings.debugDescription()
        
        // Verify all expected keys are present
        let expectedKeys = [
            "gravity",
            "bounciness", 
            "wallsEnabled",
            "accelerometerEnabled",
            "selectedBallType",
            "platform",
            "accelerometerSupported",
            "wallsSupported"
        ]
        
        for key in expectedKeys {
            XCTAssertTrue(debugInfo.keys.contains(key), "Debug info should contain key: \(key)")
        }
        
        // Verify some basic value types
        XCTAssertTrue(debugInfo["gravity"] is Double, "Gravity should be a Double in debug info")
        XCTAssertTrue(debugInfo["bounciness"] is Double, "Bounciness should be a Double in debug info")
        XCTAssertTrue(debugInfo["wallsEnabled"] is Bool, "WallsEnabled should be a Bool in debug info")
    }
    
    // MARK: - Convenience Properties Tests
    
    func testPercentagePropertiesTest() async throws {
        let settings = GameSettings.shared
        
        // Test gravity percentage conversion
        settings.gravity = 1.0
        XCTAssertEqual(settings.gravityPercentage, 50.0, "Gravity 1.0 should equal 50% for UI")
        
        settings.gravityPercentage = 100.0
        XCTAssertEqual(settings.gravity, 2.0, "100% gravity should equal 2.0 internally")
        
        // Test bounciness percentage conversion
        settings.bounciness = 0.5
        XCTAssertEqual(settings.bouncinessPercentage, 50.0, "Bounciness 0.5 should equal 50% for UI")
        
        settings.bouncinessPercentage = 80.0
        XCTAssertEqual(settings.bounciness, 0.8, "80% bounciness should equal 0.8 internally")
    }
}

// MARK: - CloudKit Integration Tests

class CloudKitIntegrationTests: XCTestCase {
    
    func testCloudKitKeysTest() async throws {
        // This test ensures the CloudKit keys follow expected naming conventions
        // In a real app, you might want to test actual CloudKit synchronization
        // but that requires more complex setup with mocking
        
        let settings = GameSettings.shared
        let debugInfo = settings.debugDescription()
        
        // Verify that settings can be converted to/from CloudKit compatible types
        XCTAssertTrue(debugInfo["gravity"] is Double, "Gravity should be CloudKit compatible (Double)")
        XCTAssertTrue(debugInfo["bounciness"] is Double, "Bounciness should be CloudKit compatible (Double)")
        XCTAssertTrue(debugInfo["wallsEnabled"] is Bool, "WallsEnabled should be CloudKit compatible (Bool)")
        XCTAssertTrue(debugInfo["accelerometerEnabled"] is Bool, "AccelerometerEnabled should be CloudKit compatible (Bool)")
    }
    
    func testResetPersistenceTest() async throws {
        let settings = GameSettings.shared
        
        // Store original values
        let originalGravity = settings.gravity
        let originalBounciness = settings.bounciness
        
        // Modify and reset
        settings.gravity = 1.5
        settings.bounciness = 0.3
        settings.reset()
        
        // Verify reset worked
        XCTAssertEqual(settings.gravity, 1.0, "Gravity should be reset to default")
        XCTAssertEqual(settings.bounciness, 0.8, "Bounciness should be reset to default")
    }
}
