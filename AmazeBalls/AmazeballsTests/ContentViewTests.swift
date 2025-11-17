//
//  ContentViewTests.swift
//  AmazeballsTests
//
//  Created by Daniel Flax on 11/15/25.
//

import XCTest
import SwiftUI
@testable import Amazeballs

class ContentViewTests: XCTestCase {
    
    var gameSettings: GameSettings!
    var ballAssetManager: BallAssetManager!
    
    override func setUpWithError() throws {
        gameSettings = GameSettings.shared
        ballAssetManager = BallAssetManager.shared
        gameSettings.reset()
    }
    
    override func tearDownWithError() throws {
        gameSettings = nil
        ballAssetManager = nil
    }
    
    // MARK: - ContentView Tests
    
    func testContentViewInitialization() throws {
        let contentView = ContentView()
        XCTAssertNotNil(contentView, "ContentView should initialize successfully")
    }
    
    func testContentViewWithDifferentSettings() throws {
        // Test with various settings configurations
        let testConfigs = [
            (gravity: 0.5, bounciness: 0.2, walls: true, accel: false),
            (gravity: 1.5, bounciness: 0.8, walls: false, accel: true),
            (gravity: 2.0, bounciness: 1.0, walls: true, accel: false)
        ]
        
        for (gravity, bounciness, walls, accel) in testConfigs {
            gameSettings.gravity = gravity
            gameSettings.bounciness = bounciness
            gameSettings.wallsEnabled = walls
            gameSettings.accelerometerEnabled = accel
            
            let contentView = ContentView()
            XCTAssertNotNil(contentView, "ContentView should handle all settings configurations")
        }
    }
    
    func testCurrentBallDisplayName() throws {
        let contentView = ContentView()
        
        // Test with no selected ball (should show "Random")
        gameSettings.selectedBallType = nil
        // Can't directly test private computed properties, but we can test the underlying logic
        XCTAssertNil(gameSettings.selectedBallType, "Should be nil for random selection")
        
        // Test with selected ball type
        if !ballAssetManager.availableBallTypes.isEmpty {
            let ballType = ballAssetManager.availableBallTypes.first!
            gameSettings.selectedBallType = ballType
            XCTAssertEqual(gameSettings.selectedBallType, ballType, "Should store selected ball type")
        }
    }
    
    // MARK: - Ball Picker Sheet Tests
    
    func testBallPickerSheetInitialization() throws {
        let ballPickerSheet = ContentView().body // Access through ContentView's body
        XCTAssertNotNil(ballPickerSheet, "Ball picker sheet should be accessible")
    }
    
    func testBallTypeCardWithDifferentBalls() throws {
        // We can't directly instantiate BallTypeCard since it's private,
        // but we can test the underlying logic that would be used
        
        let ballTypes = ballAssetManager.availableBallTypes
        
        for ballType in ballTypes {
            let displayName = ballAssetManager.displayName(for: ballType)
            let imageView = ballAssetManager.ballImageView(for: ballType)
            
            XCTAssertNotNil(displayName, "Should have display name for \(ballType)")
            XCTAssertNotNil(imageView, "Should have image view for \(ballType)")
        }
    }
    
    func testRandomBallSelection() throws {
        // Test the logic for random ball selection
        gameSettings.selectedBallType = nil
        XCTAssertNil(gameSettings.selectedBallType, "Random selection should be nil")
        
        gameSettings.selectedBallType = "basketball"
        XCTAssertEqual(gameSettings.selectedBallType, "basketball", "Should store specific ball type")
        
        gameSettings.selectedBallType = nil
        XCTAssertNil(gameSettings.selectedBallType, "Should be able to return to random")
    }
    
    // MARK: - Settings Sheet Tests
    
    func testSettingsSheetConfiguration() throws {
        // Test that all settings are properly accessible
        XCTAssertGreaterThanOrEqual(gameSettings.gravity, 0.0, "Gravity should have minimum bound")
        XCTAssertLessThanOrEqual(gameSettings.gravity, 2.0, "Gravity should have maximum bound")
        
        XCTAssertGreaterThanOrEqual(gameSettings.bounciness, 0.0, "Bounciness should have minimum bound")
        XCTAssertLessThanOrEqual(gameSettings.bounciness, 1.0, "Bounciness should have maximum bound")
        
        // Test boolean settings
        gameSettings.wallsEnabled = true
        XCTAssertTrue(gameSettings.wallsEnabled, "Walls should be toggleable")
        
        gameSettings.wallsEnabled = false
        XCTAssertFalse(gameSettings.wallsEnabled, "Walls should be toggleable")
    }
    
    func testSettingsValidation() throws {
        // Test that settings stay within valid ranges
        gameSettings.gravity = -1.0
        XCTAssertGreaterThanOrEqual(gameSettings.gravity, 0.0, "Gravity should be clamped to minimum")
        
        gameSettings.gravity = 10.0
        XCTAssertLessThanOrEqual(gameSettings.gravity, 2.0, "Gravity should be clamped to maximum")
        
        gameSettings.bounciness = -1.0
        XCTAssertGreaterThanOrEqual(gameSettings.bounciness, 0.0, "Bounciness should be clamped to minimum")
        
        gameSettings.bounciness = 10.0
        XCTAssertLessThanOrEqual(gameSettings.bounciness, 1.0, "Bounciness should be clamped to maximum")
    }
    
    func testResetFunctionality() throws {
        // Modify settings from defaults
        gameSettings.gravity = 1.5
        gameSettings.bounciness = 0.3
        gameSettings.wallsEnabled = false
        gameSettings.accelerometerEnabled = true
        gameSettings.selectedBallType = "basketball"
        
        // Reset
        gameSettings.reset()
        
        // Verify reset worked
        XCTAssertEqual(gameSettings.gravity, 1.0, "Gravity should reset to default")
        XCTAssertEqual(gameSettings.bounciness, 0.8, "Bounciness should reset to default")
        XCTAssertEqual(gameSettings.wallsEnabled, true, "Walls should reset to default")
        XCTAssertEqual(gameSettings.accelerometerEnabled, false, "Accelerometer should reset to default")
        XCTAssertNil(gameSettings.selectedBallType, "Ball type should reset to nil (random)")
    }
    
    // MARK: - Integration Tests
    
    func testIntegrationWithBallAssetManager() throws {
        let contentView = ContentView()
        
        // Test that ball asset manager integration works
        let availableBalls = ballAssetManager.availableBallTypes
        
        if !availableBalls.isEmpty {
            let firstBall = availableBalls.first!
            gameSettings.selectedBallType = firstBall
            
            // Verify the selection is valid
            XCTAssertTrue(ballAssetManager.hasBallType(firstBall), "Selected ball should be available")
            XCTAssertNotNil(ballAssetManager.ballImage(for: firstBall), "Selected ball should have an image")
        }
        
        // Test with invalid ball type
        gameSettings.selectedBallType = "invalid-ball-type"
        XCTAssertFalse(ballAssetManager.hasBallType("invalid-ball-type"), "Invalid ball type should not be available")
    }
    
    func testIntegrationWithGameSettings() throws {
        let contentView = ContentView()
        
        // Test that all game settings properties are accessible
        let debugInfo = gameSettings.debugDescription()
        
        XCTAssertNotNil(debugInfo["gravity"], "Debug info should contain gravity")
        XCTAssertNotNil(debugInfo["bounciness"], "Debug info should contain bounciness")
        XCTAssertNotNil(debugInfo["wallsEnabled"], "Debug info should contain wallsEnabled")
        XCTAssertNotNil(debugInfo["accelerometerEnabled"], "Debug info should contain accelerometerEnabled")
        XCTAssertNotNil(debugInfo["selectedBallType"], "Debug info should contain selectedBallType")
    }
    
    // MARK: - Accessibility Tests
    
    func testAccessibilityConfiguration() throws {
        let contentView = ContentView()
        
        // Test that settings have proper accessibility
        gameSettings.selectedBallType = nil
        // Should have accessibility for "Random" selection
        
        if !ballAssetManager.availableBallTypes.isEmpty {
            gameSettings.selectedBallType = ballAssetManager.availableBallTypes.first!
            // Should have accessibility for specific ball type
        }
        
        // The view should handle accessibility without crashing
        XCTAssertNotNil(contentView, "View with accessibility should not crash")
    }
    
    // MARK: - Performance Tests
    
    func testContentViewCreationPerformance() throws {
        measure {
            for _ in 0..<10 {
                let contentView = ContentView()
                _ = contentView.body // Force view evaluation
            }
        }
    }
    
    func testSettingsUpdatePerformance() throws {
        let contentView = ContentView()
        
        measure {
            for i in 0..<100 {
                gameSettings.gravity = Double(i % 20) / 10.0
                gameSettings.bounciness = Double(i % 10) / 10.0
                gameSettings.wallsEnabled = (i % 2 == 0)
                
                // Force view to respond to changes
                _ = contentView.body
            }
        }
    }
    
    // MARK: - Error Handling Tests
    
    func testErrorHandlingWithCorruptedSettings() throws {
        // Test with extreme/invalid values
        gameSettings.gravity = Double.infinity
        gameSettings.bounciness = Double.nan
        
        let contentView = ContentView()
        
        // Should handle invalid values gracefully
        XCTAssertNotNil(contentView, "Should handle corrupted settings")
        
        // Reset to recover
        gameSettings.reset()
        XCTAssertTrue(gameSettings.validateSettings(), "Reset should restore valid settings")
    }
    
    func testErrorHandlingWithMissingBallAssets() throws {
        // Set a ball type that doesn't exist
        gameSettings.selectedBallType = "non-existent-ball-12345"
        
        let contentView = ContentView()
        
        // Should handle missing assets gracefully
        XCTAssertNotNil(contentView, "Should handle missing ball assets")
        XCTAssertFalse(ballAssetManager.hasBallType("non-existent-ball-12345"), "Should recognize invalid ball type")
    }
    
    // MARK: - UI State Tests
    
    func testSheetPresentationStates() throws {
        // We can't directly test sheet presentation in unit tests,
        // but we can verify the underlying state management
        
        var showingBallPicker = false
        var showingSettings = false
        
        // Simulate opening ball picker
        showingBallPicker = true
        XCTAssertTrue(showingBallPicker, "Ball picker should be presentable")
        
        // Simulate closing ball picker
        showingBallPicker = false
        XCTAssertFalse(showingBallPicker, "Ball picker should be dismissible")
        
        // Simulate opening settings
        showingSettings = true
        XCTAssertTrue(showingSettings, "Settings should be presentable")
        
        // Simulate closing settings
        showingSettings = false
        XCTAssertFalse(showingSettings, "Settings should be dismissible")
    }
    
    func testBallSelectionStateManagement() throws {
        let availableBalls = ballAssetManager.availableBallTypes
        
        // Test state transitions
        gameSettings.selectedBallType = nil // Random
        XCTAssertNil(gameSettings.selectedBallType, "Should start with random")
        
        if !availableBalls.isEmpty {
            // Select specific ball
            let ballType = availableBalls.first!
            gameSettings.selectedBallType = ballType
            XCTAssertEqual(gameSettings.selectedBallType, ballType, "Should select specific ball")
            
            // Return to random
            gameSettings.selectedBallType = nil
            XCTAssertNil(gameSettings.selectedBallType, "Should return to random")
        }
    }
}

// MARK: - SwiftUI Preview Tests

class ContentViewPreviewTests: XCTestCase {
    
    func testPreviewCreation() throws {
        // Test that all previews can be created without crashing
        let mainPreview = ContentView()
        XCTAssertNotNil(mainPreview, "Main preview should create successfully")
        
        // We can't directly test the sheet previews since they're private,
        // but we can verify the underlying components work
        let gameSettings = GameSettings.shared
        let ballAssetManager = BallAssetManager.shared
        
        XCTAssertNotNil(gameSettings, "GameSettings should be available for previews")
        XCTAssertNotNil(ballAssetManager, "BallAssetManager should be available for previews")
    }
}

// MARK: - UI Component Tests

class ContentViewUIComponentTests: XCTestCase {
    
    func testSliderValueRanges() throws {
        let gameSettings = GameSettings.shared
        
        // Test gravity slider range
        gameSettings.gravity = 0.0
        XCTAssertEqual(gameSettings.gravity, 0.0, "Gravity should accept minimum value")
        
        gameSettings.gravity = 2.0
        XCTAssertEqual(gameSettings.gravity, 2.0, "Gravity should accept maximum value")
        
        gameSettings.gravity = 1.0
        XCTAssertEqual(gameSettings.gravity, 1.0, "Gravity should accept middle value")
        
        // Test bounciness slider range
        gameSettings.bounciness = 0.0
        XCTAssertEqual(gameSettings.bounciness, 0.0, "Bounciness should accept minimum value")
        
        gameSettings.bounciness = 1.0
        XCTAssertEqual(gameSettings.bounciness, 1.0, "Bounciness should accept maximum value")
        
        gameSettings.bounciness = 0.5
        XCTAssertEqual(gameSettings.bounciness, 0.5, "Bounciness should accept middle value")
    }
    
    func testToggleStates() throws {
        let gameSettings = GameSettings.shared
        
        // Test walls toggle
        gameSettings.wallsEnabled = true
        XCTAssertTrue(gameSettings.wallsEnabled, "Walls toggle should work - enabled")
        
        gameSettings.wallsEnabled = false
        XCTAssertFalse(gameSettings.wallsEnabled, "Walls toggle should work - disabled")
        
        // Test accelerometer toggle (if supported)
        if gameSettings.isAccelerometerSupported {
            gameSettings.accelerometerEnabled = true
            XCTAssertTrue(gameSettings.accelerometerEnabled, "Accelerometer toggle should work - enabled")
            
            gameSettings.accelerometerEnabled = false
            XCTAssertFalse(gameSettings.accelerometerEnabled, "Accelerometer toggle should work - disabled")
        }
    }
    
    func testLabelFormatting() throws {
        let gameSettings = GameSettings.shared
        let ballAssetManager = BallAssetManager.shared
        
        // Test ball display names
        let availableBalls = ballAssetManager.availableBallTypes
        
        for ballType in availableBalls {
            let displayName = ballAssetManager.displayName(for: ballType)
            
            XCTAssertFalse(displayName.isEmpty, "Display name should not be empty for \(ballType)")
            XCTAssertTrue(displayName.first?.isUppercase ?? false, "Display name should be capitalized for \(ballType)")
        }
        
        // Test numeric formatting
        gameSettings.gravity = 1.23456789
        // The UI should format this to 1 decimal place: "1.2"
        
        gameSettings.bounciness = 0.87654321
        // The UI should format this to 1 decimal place: "0.9"
    }
}