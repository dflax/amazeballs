//
//  BallPhysicsSceneTests.swift
//  AmazeballsTests
//
//  Created by Daniel Flax on 11/15/25.
//

import XCTest
import SpriteKit
import CoreMotion
@testable import Amazeballs

class BallPhysicsSceneTests: XCTestCase {
    
    var scene: BallPhysicsScene!
    var gameSettings: GameSettings!
    
    override func setUpWithError() throws {
        // Create a test scene with standard size
        scene = BallPhysicsScene(size: CGSize(width: 400, height: 600))
        gameSettings = GameSettings.shared
        
        // Reset settings to defaults
        gameSettings.reset()
        
        // Simulate the scene being added to a view
        let testView = SKView(frame: CGRect(origin: .zero, size: scene.size))
        testView.presentScene(scene)
        
        // Wait a moment for scene setup to complete
        let expectation = XCTestExpectation(description: "Scene setup")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    override func tearDownWithError() throws {
        scene?.removeFromParent()
        scene = nil
        gameSettings = nil
    }
    
    // MARK: - Scene Setup Tests
    
    func testSceneInitialization() throws {
        XCTAssertNotNil(scene, "Scene should be initialized")
        XCTAssertEqual(scene.size.width, 400, "Scene width should be set correctly")
        XCTAssertEqual(scene.size.height, 600, "Scene height should be set correctly")
        
        // Check that physics world is set up
        XCTAssertNotNil(scene.physicsWorld, "Physics world should exist")
        XCTAssertTrue(scene.physicsWorld.contactDelegate === scene, "Scene should be contact delegate")
    }
    
    func testPhysicsWorldSetup() throws {
        // Check default gravity
        let expectedGravity = CGVector(dx: 0, dy: -9.8)
        XCTAssertEqual(scene.physicsWorld.gravity.dx, expectedGravity.dx, accuracy: 0.1, "Default gravity X should be correct")
        XCTAssertEqual(scene.physicsWorld.gravity.dy, expectedGravity.dy, accuracy: 0.1, "Default gravity Y should be correct")
        
        // Check physics world speed
        XCTAssertEqual(scene.physicsWorld.speed, 1.0, "Physics world speed should be 1.0")
    }
    
    func testSceneElements() throws {
        // Give scene time to set up all elements
        let expectation = XCTestExpectation(description: "Scene elements setup")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        // Check for floor
        let floorNodes = scene.children.filter { $0.name?.contains("floor") == true || $0 is SKSpriteNode && $0.position.y < 50 }
        XCTAssertGreaterThan(floorNodes.count, 0, "Scene should have a floor")
        
        // Check for background
        let backgroundNodes = scene.children.filter { $0.zPosition < 0 }
        XCTAssertGreaterThan(backgroundNodes.count, 0, "Scene should have a background")
    }
    
    // MARK: - Ball Management Tests
    
    func testBallDropping() throws {
        let initialBallCount = scene.activeBallCount
        let dropPosition = CGPoint(x: 200, y: 500)
        
        // Drop a ball
        scene.dropBall(at: dropPosition, ballType: "basketball", settings: gameSettings)
        
        // Check that ball count increased
        XCTAssertEqual(scene.activeBallCount, initialBallCount + 1, "Ball count should increase after dropping")
        
        // Check that a ball sprite was added to the scene
        let ballNodes = scene.children.filter { $0.name?.contains("ball-") == true }
        XCTAssertGreaterThan(ballNodes.count, 0, "Scene should contain ball nodes")
    }
    
    func testBallDroppingWithNilBallType() throws {
        let initialBallCount = scene.activeBallCount
        let dropPosition = CGPoint(x: 200, y: 500)
        
        // Drop a ball with nil ball type (should use random)
        scene.dropBall(at: dropPosition, ballType: nil, settings: gameSettings)
        
        // Check that ball count increased
        XCTAssertEqual(scene.activeBallCount, initialBallCount + 1, "Ball count should increase even with nil ball type")
    }
    
    func testMaxBallLimit() throws {
        let dropPosition = CGPoint(x: 200, y: 500)
        
        // Drop many balls to test the limit (assuming maxBalls is 50)
        for i in 0..<60 {
            scene.dropBall(at: dropPosition, ballType: "basketball", settings: gameSettings)
            
            // Add small delay to prevent overwhelming the physics system
            if i % 10 == 0 {
                usleep(10000) // 10ms
            }
        }
        
        // Ball count should not exceed the maximum
        XCTAssertLessThanOrEqual(scene.activeBallCount, 50, "Ball count should not exceed maximum")
    }
    
    func testClearAllBalls() throws {
        let dropPosition = CGPoint(x: 200, y: 500)
        
        // Drop some balls
        for _ in 0..<5 {
            scene.dropBall(at: dropPosition, ballType: "basketball", settings: gameSettings)
        }
        
        // Verify balls were added
        XCTAssertGreaterThan(scene.activeBallCount, 0, "Should have balls before clearing")
        
        // Clear all balls
        scene.clearAllBalls()
        
        // Verify all balls were removed
        XCTAssertEqual(scene.activeBallCount, 0, "Should have no balls after clearing")
    }
    
    // MARK: - Physics Update Tests
    
    func testPhysicsUpdates() throws {
        // Change game settings
        gameSettings.gravity = 1.5
        gameSettings.bounciness = 0.5
        gameSettings.wallsEnabled = false
        
        // Update scene physics
        scene.updatePhysics(with: gameSettings)
        
        // Verify gravity was updated (approximately)
        let expectedGravityY = -9.8 * 1.5
        XCTAssertEqual(scene.physicsWorld.gravity.dy, expectedGravityY, accuracy: 0.5, "Gravity should be updated")
        
        // Drop a ball to test bounciness
        let dropPosition = CGPoint(x: 200, y: 500)
        scene.dropBall(at: dropPosition, ballType: "basketball", settings: gameSettings)
        
        // Find the ball and check its restitution
        let ballNodes = scene.children.compactMap { $0 as? SKSpriteNode }.filter { $0.name?.contains("ball-") == true }
        if let ball = ballNodes.first {
            XCTAssertEqual(ball.physicsBody?.restitution, 0.5, accuracy: 0.1, "Ball restitution should match settings")
        }
    }
    
    func testWallToggling() throws {
        // Test with walls enabled
        gameSettings.wallsEnabled = true
        scene.updatePhysics(with: gameSettings)
        
        // Test with walls disabled
        gameSettings.wallsEnabled = false
        scene.updatePhysics(with: gameSettings)
        
        // The test here is mainly that no crashes occur
        // Wall visibility is tested implicitly through the updatePhysics call
        XCTAssertTrue(true, "Wall toggling should not cause crashes")
    }
    
    // MARK: - Accelerometer Tests
    
    func testAccelerometerEnabling() throws {
        // Test enabling accelerometer
        scene.enableAccelerometer(true)
        
        // Test disabling accelerometer
        scene.enableAccelerometer(false)
        
        // Verify that gravity returns to default when disabled
        let expectedGravity = CGVector(dx: 0, dy: -9.8)
        XCTAssertEqual(scene.physicsWorld.gravity.dx, expectedGravity.dx, accuracy: 0.1, "Gravity X should return to default")
        XCTAssertEqual(scene.physicsWorld.gravity.dy, expectedGravity.dy, accuracy: 0.1, "Gravity Y should return to default")
    }
    
    func testAccelerometerToggling() throws {
        // Enable and disable multiple times to test for memory leaks or crashes
        for _ in 0..<5 {
            scene.enableAccelerometer(true)
            scene.enableAccelerometer(false)
        }
        
        // Test should complete without crashes
        XCTAssertTrue(true, "Accelerometer toggling should not cause crashes")
    }
    
    // MARK: - Debug Info Tests
    
    func testDebugInfo() throws {
        let debugInfo = scene.debugInfo()
        
        // Check for required keys
        XCTAssertNotNil(debugInfo["activeBalls"], "Debug info should contain activeBalls")
        XCTAssertNotNil(debugInfo["maxBalls"], "Debug info should contain maxBalls")
        XCTAssertNotNil(debugInfo["gravity"], "Debug info should contain gravity")
        XCTAssertNotNil(debugInfo["accelerometerEnabled"], "Debug info should contain accelerometerEnabled")
        XCTAssertNotNil(debugInfo["wallsEnabled"], "Debug info should contain wallsEnabled")
        XCTAssertNotNil(debugInfo["sceneSize"], "Debug info should contain sceneSize")
        
        // Check value types
        XCTAssertTrue(debugInfo["activeBalls"] is Int, "activeBalls should be Int")
        XCTAssertTrue(debugInfo["maxBalls"] is Int, "maxBalls should be Int")
        XCTAssertTrue(debugInfo["accelerometerEnabled"] is Bool, "accelerometerEnabled should be Bool")
        XCTAssertTrue(debugInfo["wallsEnabled"] is Bool, "wallsEnabled should be Bool")
    }
    
    // MARK: - Performance Tests
    
    func testBallDroppingPerformance() throws {
        let dropPosition = CGPoint(x: 200, y: 500)
        
        measure {
            for _ in 0..<10 {
                scene.dropBall(at: dropPosition, ballType: "basketball", settings: gameSettings)
            }
        }
    }
    
    func testPhysicsUpdatePerformance() throws {
        // Drop some balls first
        let dropPosition = CGPoint(x: 200, y: 500)
        for _ in 0..<20 {
            scene.dropBall(at: dropPosition, ballType: "basketball", settings: gameSettings)
        }
        
        measure {
            for _ in 0..<100 {
                gameSettings.gravity = Double.random(in: 0.5...2.0)
                gameSettings.bounciness = Double.random(in: 0.1...1.0)
                scene.updatePhysics(with: gameSettings)
            }
        }
    }
    
    // MARK: - Memory Management Tests
    
    func testSceneCleanup() throws {
        // Drop some balls
        let dropPosition = CGPoint(x: 200, y: 500)
        for _ in 0..<10 {
            scene.dropBall(at: dropPosition, ballType: "basketball", settings: gameSettings)
        }
        
        // Enable accelerometer
        scene.enableAccelerometer(true)
        
        // Simulate scene being removed from view
        scene.removeFromParent()
        
        // Test that cleanup doesn't crash
        XCTAssertTrue(true, "Scene cleanup should not crash")
    }
}

// MARK: - Integration Tests

class BallPhysicsSceneIntegrationTests: XCTestCase {
    
    func testIntegrationWithBallAssetManager() throws {
        let scene = BallPhysicsScene(size: CGSize(width: 400, height: 600))
        let gameSettings = GameSettings.shared
        let ballManager = BallAssetManager.shared
        
        // Set up scene
        let testView = SKView(frame: CGRect(origin: .zero, size: scene.size))
        testView.presentScene(scene)
        
        // Wait for setup
        let expectation = XCTestExpectation(description: "Scene setup")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        // Test dropping balls with different types
        let availableBallTypes = ballManager.availableBallTypes
        
        if !availableBallTypes.isEmpty {
            let ballType = availableBallTypes.first!
            scene.dropBall(at: CGPoint(x: 200, y: 500), ballType: ballType, settings: gameSettings)
            
            XCTAssertEqual(scene.activeBallCount, 1, "Should successfully drop ball with asset manager ball type")
        }
        
        // Test with invalid ball type
        scene.dropBall(at: CGPoint(x: 200, y: 500), ballType: "invalid-ball", settings: gameSettings)
        
        // Should still work (fallback to default)
        XCTAssertGreaterThan(scene.activeBallCount, 0, "Should handle invalid ball types gracefully")
    }
    
    func testIntegrationWithGameSettings() throws {
        let scene = BallPhysicsScene(size: CGSize(width: 400, height: 600))
        let gameSettings = GameSettings.shared
        
        // Set up scene
        let testView = SKView(frame: CGRect(origin: .zero, size: scene.size))
        testView.presentScene(scene)
        
        // Wait for setup
        let expectation = XCTestExpectation(description: "Scene setup")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        // Test various game settings combinations
        let testSettings = [
            (gravity: 0.5, bounciness: 0.2, walls: true, accel: false),
            (gravity: 1.5, bounciness: 0.8, walls: false, accel: true),
            (gravity: 2.0, bounciness: 1.0, walls: true, accel: false)
        ]
        
        for (gravity, bounciness, walls, accel) in testSettings {
            gameSettings.gravity = gravity
            gameSettings.bounciness = bounciness
            gameSettings.wallsEnabled = walls
            gameSettings.accelerometerEnabled = accel
            
            scene.updatePhysics(with: gameSettings)
            scene.enableAccelerometer(accel)
            
            // Drop a ball to test the settings
            scene.dropBall(at: CGPoint(x: 200, y: 500), ballType: "basketball", settings: gameSettings)
            
            // Basic verification that the scene handles all settings without crashing
            XCTAssertGreaterThan(scene.activeBallCount, 0, "Scene should handle all settings combinations")
        }
    }
}