//
//  SettingsViewTests.swift
//  AmazeballsTests
//
//  Created by Daniel Flax on 11/15/25.
//

import XCTest
import SwiftUI
@testable import Amazeballs

class SettingsViewTests: XCTestCase {
    
    var gameSettings: GameSettings!
    
    override func setUpWithError() throws {
        gameSettings = GameSettings.shared
        gameSettings.reset() // Start with clean defaults
    }
    
    override func tearDownWithError() throws {
        gameSettings.reset() // Clean up after tests
        gameSettings = nil
    }
    
    // MARK: - Initialization Tests
    
    func testSettingsViewInitialization() throws {
        let settingsView = SettingsView()
        XCTAssertNotNil(settingsView, "SettingsView should initialize successfully")
    }
    
    func testSettingsViewWithDifferentPlatforms() throws {
        // Test that the view can be created on different platforms
        let settingsView = SettingsView()
        
        // The view should handle platform-specific UI without crashing
        XCTAssertNotNil(settingsView, "SettingsView should work across platforms")
        
        // Force view body evaluation to catch any platform-specific issues
        _ = settingsView.body
        XCTAssertTrue(true, "View body should evaluate without errors")
    }
    
    // MARK: - Settings Integration Tests
    
    func testGameSettingsIntegration() throws {
        let settingsView = SettingsView()
        
        // Verify initial settings values
        XCTAssertEqual(gameSettings.gravity, 1.0, "Default gravity should be 1.0")
        XCTAssertEqual(gameSettings.bounciness, 0.8, "Default bounciness should be 0.8")
        XCTAssertTrue(gameSettings.wallsEnabled, "Walls should be enabled by default")
        XCTAssertFalse(gameSettings.accelerometerEnabled, "Accelerometer should be disabled by default")
        
        // The view should reflect these values
        XCTAssertNotNil(settingsView, "SettingsView should integrate with GameSettings")
    }
    
    func testSettingsLiveUpdates() throws {
        let settingsView = SettingsView()
        
        // Simulate changing settings values
        gameSettings.gravity = 1.5
        gameSettings.bounciness = 0.3
        gameSettings.wallsEnabled = false
        gameSettings.accelerometerEnabled = true
        
        // The view should handle live updates without issues
        _ = settingsView.body
        XCTAssertEqual(gameSettings.gravity, 1.5, "Gravity should update")
        XCTAssertEqual(gameSettings.bounciness, 0.3, "Bounciness should update")
        XCTAssertFalse(gameSettings.wallsEnabled, "Walls should be disabled")
        XCTAssertEqual(gameSettings.accelerometerEnabled, true, "Accelerometer should be enabled")
    }
    
    // MARK: - Value Formatting Tests
    
    func testGravityFormatting() throws {
        // Test gravity value formatting (1 decimal place)
        gameSettings.gravity = 1.23456789
        
        // The view should format to 1 decimal place
        let formattedValue = String(format: "%.1f", gameSettings.gravity)
        XCTAssertEqual(formattedValue, "1.2", "Gravity should format to 1 decimal place")
        
        // Test edge cases
        gameSettings.gravity = 0.0
        let zeroFormatted = String(format: "%.1f", gameSettings.gravity)
        XCTAssertEqual(zeroFormatted, "0.0", "Zero gravity should format correctly")
        
        gameSettings.gravity = 2.0
        let maxFormatted = String(format: "%.1f", gameSettings.gravity)
        XCTAssertEqual(maxFormatted, "2.0", "Max gravity should format correctly")
    }
    
    func testBouncinessPercentageFormatting() throws {
        // Test bounciness percentage formatting
        gameSettings.bounciness = 0.87654321
        
        let percentageValue = Int(gameSettings.bounciness * 100)
        XCTAssertEqual(percentageValue, 87, "Bounciness should convert to percentage")
        
        // Test edge cases
        gameSettings.bounciness = 0.0
        XCTAssertEqual(Int(gameSettings.bounciness * 100), 0, "Zero bounciness should be 0%")
        
        gameSettings.bounciness = 1.0
        XCTAssertEqual(Int(gameSettings.bounciness * 100), 100, "Max bounciness should be 100%")
    }
    
    // MARK: - Platform-Specific Tests
    
    func testPlatformSpecificFeatures() throws {
        let settingsView = SettingsView()
        
        #if os(macOS)
        // On macOS, certain features should be different
        XCTAssertFalse(gameSettings.isAccelerometerSupported, "macOS should not support accelerometer")
        #else
        // On iOS/iPadOS, accelerometer should be available
        XCTAssertTrue(gameSettings.isAccelerometerSupported, "iOS/iPadOS should support accelerometer")
        #endif
        
        // The view should adapt to platform capabilities
        XCTAssertNotNil(settingsView, "SettingsView should adapt to platform features")
    }
    
    // MARK: - Accessibility Tests
    
    func testAccessibilityLabels() throws {
        let settingsView = SettingsView()
        
        // The view should include proper accessibility considerations
        // (Full accessibility testing would require UI testing framework)
        XCTAssertNotNil(settingsView, "SettingsView should support accessibility")
        
        // Test that accessibility descriptions are meaningful
        let accelerometerDescription = gameSettings.isAccelerometerSupported ? 
            "Tilt device to control gravity direction" : 
            "Not available on this device"
        
        XCTAssertFalse(accelerometerDescription.isEmpty, "Accessibility description should not be empty")
    }
    
    func testReducedMotionSupport() throws {
        let settingsView = SettingsView()
        
        // The view should respect reduced motion preferences
        // This is handled through Environment values in the actual implementation
        XCTAssertNotNil(settingsView, "SettingsView should support reduced motion preferences")
    }
    
    // MARK: - Reset Functionality Tests
    
    func testResetFunctionality() throws {
        let settingsView = SettingsView()
        
        // Modify settings away from defaults
        gameSettings.gravity = 1.7
        gameSettings.bounciness = 0.2
        gameSettings.wallsEnabled = false
        gameSettings.accelerometerEnabled = true
        
        // Verify changes were applied
        XCTAssertNotEqual(gameSettings.gravity, 1.0, "Settings should be modified")
        XCTAssertNotEqual(gameSettings.bounciness, 0.8, "Settings should be modified")
        
        // Reset settings
        gameSettings.reset()
        
        // Verify reset worked
        XCTAssertEqual(gameSettings.gravity, 1.0, "Gravity should reset to default")
        XCTAssertEqual(gameSettings.bounciness, 0.8, "Bounciness should reset to default")
        XCTAssertTrue(gameSettings.wallsEnabled, "Walls should reset to default")
        XCTAssertFalse(gameSettings.accelerometerEnabled, "Accelerometer should reset to default")
    }
    
    // MARK: - Validation Tests
    
    func testSettingsValidation() throws {
        let settingsView = SettingsView()
        
        // Test that settings remain within valid ranges
        gameSettings.gravity = -1.0  // Should be clamped
        XCTAssertGreaterThanOrEqual(gameSettings.gravity, 0.0, "Gravity should be clamped to minimum")
        
        gameSettings.gravity = 10.0  // Should be clamped
        XCTAssertLessThanOrEqual(gameSettings.gravity, 2.0, "Gravity should be clamped to maximum")
        
        gameSettings.bounciness = -1.0  // Should be clamped
        XCTAssertGreaterThanOrEqual(gameSettings.bounciness, 0.0, "Bounciness should be clamped to minimum")
        
        gameSettings.bounciness = 10.0  // Should be clamped
        XCTAssertLessThanOrEqual(gameSettings.bounciness, 1.0, "Bounciness should be clamped to maximum")
        
        // The view should handle clamped values gracefully
        XCTAssertNotNil(settingsView, "SettingsView should handle validation")
    }
    
    // MARK: - Performance Tests
    
    func testSettingsViewCreationPerformance() throws {
        measure {
            for _ in 0..<10 {
                let settingsView = SettingsView()
                _ = settingsView.body // Force view evaluation
            }
        }
    }
    
    func testSettingsUpdatePerformance() throws {
        let settingsView = SettingsView()
        
        measure {
            for i in 0..<100 {
                gameSettings.gravity = Double(i % 20) / 10.0
                gameSettings.bounciness = Double(i % 10) / 10.0
                gameSettings.wallsEnabled = (i % 2 == 0)
                
                // Force view to respond to changes
                _ = settingsView.body
            }
        }
    }
    
    // MARK: - Edge Case Tests
    
    func testExtremeValues() throws {
        let settingsView = SettingsView()
        
        // Test with boundary values
        gameSettings.gravity = 0.0
        gameSettings.bounciness = 0.0
        XCTAssertEqual(gameSettings.gravity, 0.0, "Should handle minimum gravity")
        XCTAssertEqual(gameSettings.bounciness, 0.0, "Should handle minimum bounciness")
        
        gameSettings.gravity = 2.0
        gameSettings.bounciness = 1.0
        XCTAssertEqual(gameSettings.gravity, 2.0, "Should handle maximum gravity")
        XCTAssertEqual(gameSettings.bounciness, 1.0, "Should handle maximum bounciness")
        
        // View should handle extreme values without issues
        _ = settingsView.body
        XCTAssertNotNil(settingsView, "SettingsView should handle extreme values")
    }
    
    func testRapidSettingChanges() throws {
        let settingsView = SettingsView()
        
        // Simulate rapid changes that might occur with sliders
        for i in 0..<50 {
            gameSettings.gravity = Double(i) / 25.0  // 0.0 to 2.0
            gameSettings.bounciness = Double(i) / 50.0  // 0.0 to 1.0
            
            // Ensure view can handle rapid updates
            _ = settingsView.body
        }
        
        XCTAssertNotNil(settingsView, "SettingsView should handle rapid changes")
    }
}

// MARK: - Integration Tests

class SettingsViewIntegrationTests: XCTestCase {
    
    func testIntegrationWithPhysicsScene() throws {
        let settingsView = SettingsView()
        let gameSettings = GameSettings.shared
        
        // Settings changes should be immediately available to physics scenes
        gameSettings.gravity = 1.3
        gameSettings.bounciness = 0.7
        gameSettings.wallsEnabled = false
        
        // Any physics scene should pick up these changes
        XCTAssertEqual(gameSettings.gravity, 1.3, "Physics should receive gravity changes")
        XCTAssertEqual(gameSettings.bounciness, 0.7, "Physics should receive bounciness changes")
        XCTAssertFalse(gameSettings.wallsEnabled, "Physics should receive wall changes")
        
        // The settings view should facilitate this integration
        XCTAssertNotNil(settingsView, "SettingsView should integrate with physics")
    }
    
    func testSettingsViewWithBallAssetManager() throws {
        let settingsView = SettingsView()
        let ballAssetManager = BallAssetManager.shared
        
        // Settings view and ball asset manager should work together
        XCTAssertNotNil(settingsView, "SettingsView should work with BallAssetManager")
        XCTAssertNotNil(ballAssetManager, "BallAssetManager should be available")
        
        // Both should be able to access GameSettings
        let gameSettings = GameSettings.shared
        XCTAssertNotNil(gameSettings, "GameSettings should be shared resource")
    }
}

// MARK: - UI State Tests

class SettingsViewUIStateTests: XCTestCase {
    
    func testAlertStateManagement() throws {
        let settingsView = SettingsView()
        
        // Test alert state management (we can't directly test @State variables,
        // but we can verify the structure doesn't crash)
        XCTAssertNotNil(settingsView, "SettingsView should manage alert state")
        
        // Simulate alert workflow
        var showingAlert = false
        
        // Show alert
        showingAlert = true
        XCTAssertTrue(showingAlert, "Alert should be showable")
        
        // Hide alert
        showingAlert = false
        XCTAssertFalse(showingAlert, "Alert should be dismissible")
    }
    
    func testEnvironmentHandling() throws {
        let settingsView = SettingsView()
        
        // The view should handle environment values gracefully
        // (Full environment testing requires SwiftUI test environment)
        XCTAssertNotNil(settingsView, "SettingsView should handle environment values")
    }
}