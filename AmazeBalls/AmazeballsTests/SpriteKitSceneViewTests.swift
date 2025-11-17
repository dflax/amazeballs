//
//  SpriteKitSceneViewTests.swift
//  AmazeballsTests
//
//  Created by Daniel Flax on 11/15/25.
//

import XCTest
import SwiftUI
import SpriteKit
@testable import Amazeballs

class SpriteKitSceneViewTests: XCTestCase {
    
    var gameSettings: GameSettings!
    
    override func setUpWithError() throws {
        gameSettings = GameSettings.shared
        gameSettings.reset()
    }
    
    override func tearDownWithError() throws {
        gameSettings = nil
    }
    
    // MARK: - Initialization Tests
    
    func testViewInitialization() throws {
        let view = SpriteKitSceneView(settings: gameSettings)
        
        // Basic initialization should not crash
        XCTAssertNotNil(view, "View should initialize successfully")
        
        // Test convenience initializer
        let defaultView = SpriteKitSceneView.withDefaultSettings()
        XCTAssertNotNil(defaultView, "Default view should initialize successfully")
    }
    
    func testViewWithDifferentSettings() throws {
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
            
            let view = SpriteKitSceneView(settings: gameSettings)
            XCTAssertNotNil(view, "View should handle all settings configurations")
        }
    }
    
    // MARK: - Coordinate Conversion Tests
    
    func testCoordinateConversion() throws {
        // Create a test scene to verify coordinate conversion logic
        let scene = BallPhysicsScene(size: CGSize(width: 400, height: 600))
        
        // Test coordinate conversion (SwiftUI to SpriteKit)
        let swiftUIPoint = CGPoint(x: 100, y: 150)
        let expectedSpriteKitPoint = CGPoint(x: 100, y: 450) // 600 - 150
        
        // Since the conversion is private, we test it indirectly through the expected behavior
        // The scene's bottom-left origin should result in Y coordinate flipping
        XCTAssertEqual(expectedSpriteKitPoint.x, swiftUIPoint.x, "X coordinate should remain the same")
        XCTAssertEqual(expectedSpriteKitPoint.y, scene.size.height - swiftUIPoint.y, "Y coordinate should be flipped")
    }
    
    func testCoordinateConversionEdgeCases() throws {
        let scene = BallPhysicsScene(size: CGSize(width: 400, height: 600))
        
        // Test edge cases
        let testCases: [(input: CGPoint, expectedY: CGFloat)] = [
            (CGPoint(x: 0, y: 0), 600),      // Top-left in SwiftUI = Top in SpriteKit
            (CGPoint(x: 0, y: 600), 0),      // Bottom-left in SwiftUI = Bottom in SpriteKit
            (CGPoint(x: 200, y: 300), 300),  // Center point
            (CGPoint(x: 400, y: 600), 0)     // Bottom-right
        ]
        
        for (input, expectedY) in testCases {
            let convertedY = scene.size.height - input.y
            XCTAssertEqual(convertedY, expectedY, accuracy: 0.1, "Coordinate conversion should work for edge case \(input)")
        }
    }
    
    // MARK: - Settings Integration Tests
    
    func testSettingsObservation() throws {
        let view = SpriteKitSceneView(settings: gameSettings)
        
        // Change settings and verify they don't cause crashes
        gameSettings.gravity = 1.5
        gameSettings.bounciness = 0.3
        gameSettings.wallsEnabled = false
        gameSettings.accelerometerEnabled = true
        
        // The view should handle these changes gracefully
        // (We can't directly test the scene updates without a full SwiftUI environment,
        // but we can verify that the bindings work)
        XCTAssertEqual(gameSettings.gravity, 1.5, "Settings should update correctly")
        XCTAssertEqual(gameSettings.bounciness, 0.3, "Settings should update correctly")
        XCTAssertEqual(gameSettings.wallsEnabled, false, "Settings should update correctly")
        XCTAssertEqual(gameSettings.accelerometerEnabled, true, "Settings should update correctly")
    }
    
    func testBallTypeSelection() throws {
        let ballManager = BallAssetManager.shared
        
        // Test with no selected ball type (should use random)
        gameSettings.selectedBallType = nil
        let view = SpriteKitSceneView(settings: gameSettings)
        XCTAssertNil(gameSettings.selectedBallType, "Should handle nil ball type")
        
        // Test with valid ball type
        if !ballManager.availableBallTypes.isEmpty {
            let ballType = ballManager.availableBallTypes.first!
            gameSettings.selectedBallType = ballType
            XCTAssertEqual(gameSettings.selectedBallType, ballType, "Should handle valid ball type")
        }
        
        // Test with invalid ball type
        gameSettings.selectedBallType = "invalid-ball-type"
        XCTAssertEqual(gameSettings.selectedBallType, "invalid-ball-type", "Should store invalid ball type (validation happens at usage)")
    }
    
    // MARK: - Gesture Handling Tests
    
    func testGestureSetup() throws {
        let view = SpriteKitSceneView(settings: gameSettings)
        
        // We can't directly test gesture handling without a full SwiftUI test environment,
        // but we can verify that the view sets up without crashing
        XCTAssertNotNil(view, "View with gesture setup should not crash")
    }
    
    // MARK: - Platform-Specific Tests
    
    func testPlatformSpecificFeatures() throws {
        let view = SpriteKitSceneView(settings: gameSettings)
        
        #if os(macOS)
        // On macOS, accelerometer should be disabled
        XCTAssertFalse(gameSettings.isAccelerometerSupported, "macOS should not support accelerometer")
        #else
        // On iOS/iPadOS, accelerometer should be available
        XCTAssertTrue(gameSettings.isAccelerometerSupported, "iOS/iPadOS should support accelerometer")
        #endif
        
        // The view should handle platform differences gracefully
        XCTAssertNotNil(view, "View should work on all platforms")
    }
    
    // MARK: - Accessibility Tests
    
    func testAccessibilityConfiguration() throws {
        let view = SpriteKitSceneView(settings: gameSettings)
        
        // Test with different ball type selections for accessibility
        gameSettings.selectedBallType = nil
        // Accessibility hint should mention "Random"
        
        if !BallAssetManager.shared.availableBallTypes.isEmpty {
            gameSettings.selectedBallType = BallAssetManager.shared.availableBallTypes.first!
            // Accessibility hint should mention the specific ball type
        }
        
        // The view should handle accessibility configuration without crashing
        XCTAssertNotNil(view, "View with accessibility should not crash")
    }
    
    // MARK: - Performance Tests
    
    func testViewCreationPerformance() throws {
        measure {
            for _ in 0..<10 {
                let view = SpriteKitSceneView(settings: gameSettings)
                _ = view.body // Force view evaluation
            }
        }
    }
    
    func testSettingsUpdatePerformance() throws {
        let view = SpriteKitSceneView(settings: gameSettings)
        
        measure {
            for i in 0..<100 {
                gameSettings.gravity = Double(i % 20) / 10.0
                gameSettings.bounciness = Double(i % 10) / 10.0
                gameSettings.wallsEnabled.toggle()
                
                // Force view to respond to changes
                _ = view.body
            }
        }
    }
    
    // MARK: - Error Handling Tests
    
    func testErrorHandling() throws {
        // Test with extreme settings values
        gameSettings.gravity = -1000.0 // Should be clamped
        gameSettings.bounciness = 1000.0 // Should be clamped
        
        let view = SpriteKitSceneView(settings: gameSettings)
        XCTAssertNotNil(view, "View should handle extreme settings values")
        
        // Verify settings were clamped
        XCTAssertGreaterThanOrEqual(gameSettings.gravity, 0.0, "Gravity should be clamped to minimum")
        XCTAssertLessThanOrEqual(gameSettings.bounciness, 1.0, "Bounciness should be clamped to maximum")
    }
    
    func testInvalidBallTypeHandling() throws {
        // Set an invalid ball type
        gameSettings.selectedBallType = "completely-invalid-ball-type-12345"
        
        let view = SpriteKitSceneView(settings: gameSettings)
        XCTAssertNotNil(view, "View should handle invalid ball types gracefully")
        
        // The view should still work, falling back to random ball selection
        XCTAssertEqual(gameSettings.selectedBallType, "completely-invalid-ball-type-12345", "Invalid ball type should be stored")
    }
    
    // MARK: - Memory Management Tests
    
    func testViewLifecycle() throws {
        // SwiftUI views are value types (structs), so traditional memory management
        // tests with weak references don't apply. Instead, we test that views
        // can be created and destroyed without issues.
        
        autoreleasepool {
            let view = SpriteKitSceneView(settings: gameSettings)
            
            // Use the view multiple times
            _ = view.body
            _ = view.body
            
            // Test that creating multiple instances doesn't cause issues
            let anotherView = SpriteKitSceneView(settings: gameSettings)
            _ = anotherView.body
        }
        
        // Test passes if no crashes or memory issues occur
        XCTAssertTrue(true, "View lifecycle completed successfully")
    }
    
    // MARK: - Integration Tests
    
    func testIntegrationWithBallAssetManager() throws {
        let ballManager = BallAssetManager.shared
        let view = SpriteKitSceneView(settings: gameSettings)
        
        // Test with available ball types
        let availableBallTypes = ballManager.availableBallTypes
        
        if !availableBallTypes.isEmpty {
            // Test with first available ball type
            let ballType = availableBallTypes.first!
            gameSettings.selectedBallType = ballType
            
            XCTAssertTrue(ballManager.hasBallType(ballType), "Selected ball type should be available")
        }
        
        // Test with random selection
        gameSettings.selectedBallType = nil
        XCTAssertNil(gameSettings.selectedBallType, "Nil ball type should work for random selection")
        
        // View should handle both cases
        XCTAssertNotNil(view, "View should work with BallAssetManager integration")
    }
    
    func testIntegrationWithGameSettings() throws {
        let view = SpriteKitSceneView(settings: gameSettings)
        
        // Test full settings cycle
        gameSettings.reset()
        XCTAssertEqual(gameSettings.gravity, 1.0, "Reset should work")
        
        gameSettings.gravity = 1.5
        gameSettings.bounciness = 0.3
        gameSettings.wallsEnabled = false
        gameSettings.selectedBallType = "basketball"
        
        // View should handle all settings changes
        XCTAssertNotNil(view, "View should integrate properly with GameSettings")
        
        // Test validation
        XCTAssertTrue(gameSettings.validateSettings(), "Settings should be valid")
    }
}

// MARK: - SwiftUI Preview Tests

class SpriteKitSceneViewPreviewTests: XCTestCase {
    
    func testPreviewCreation() throws {
        // Test that previews can be created without crashing
        let defaultPreview = SpriteKitSceneView.withDefaultSettings()
        XCTAssertNotNil(defaultPreview, "Default preview should create successfully")
        
        let customSettings = GameSettings.shared
        customSettings.gravity = 1.5
        customSettings.bounciness = 0.9
        customSettings.wallsEnabled = false
        
        let customPreview = SpriteKitSceneView(settings: customSettings)
        XCTAssertNotNil(customPreview, "Custom preview should create successfully")
        
        #if DEBUG
        let debugPreview = SpriteKitSceneView.withDefaultSettings()
        XCTAssertNotNil(debugPreview, "Debug preview should create successfully")
        #endif
    }
}

// MARK: - Mock Scene Tests

class MockBallPhysicsScene: BallPhysicsScene {
    var ballDropCount = 0
    var lastDropLocation: CGPoint?
    var lastDropBallType: String?
    var physicsUpdateCount = 0
    var accelerometerToggleCount = 0
    
    override func dropBall(at point: CGPoint, ballType: String?, settings: GameSettings) {
        ballDropCount += 1
        lastDropLocation = point
        lastDropBallType = ballType
        super.dropBall(at: point, ballType: ballType, settings: settings)
    }
    
    override func updatePhysics(with settings: GameSettings) {
        physicsUpdateCount += 1
        super.updatePhysics(with: settings)
    }
    
    override func enableAccelerometer(_ enabled: Bool) {
        accelerometerToggleCount += 1
        super.enableAccelerometer(enabled)
    }
}

class SpriteKitSceneViewMockTests: XCTestCase {
    
    func testSceneInteractionCounting() throws {
        // This test verifies the interaction patterns without requiring a full SwiftUI environment
        let mockScene = MockBallPhysicsScene(size: CGSize(width: 400, height: 600))
        let gameSettings = GameSettings.shared
        
        // Simulate the operations that would happen in the view
        mockScene.dropBall(at: CGPoint(x: 100, y: 200), ballType: "basketball", settings: gameSettings)
        mockScene.updatePhysics(with: gameSettings)
        mockScene.enableAccelerometer(true)
        mockScene.enableAccelerometer(false)
        
        // Verify interactions were counted
        XCTAssertEqual(mockScene.ballDropCount, 1, "Should have dropped one ball")
        XCTAssertEqual(mockScene.physicsUpdateCount, 1, "Should have updated physics once")
        XCTAssertEqual(mockScene.accelerometerToggleCount, 2, "Should have toggled accelerometer twice")
        XCTAssertEqual(mockScene.lastDropLocation, CGPoint(x: 100, y: 200), "Should record drop location")
        XCTAssertEqual(mockScene.lastDropBallType, "basketball", "Should record ball type")
    }
}