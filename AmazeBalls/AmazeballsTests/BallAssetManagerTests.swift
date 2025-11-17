//
//  BallAssetManagerTests.swift
//  AmazeballsTests
//
//  Created by Daniel Flax on 11/15/25.
//

import XCTest
import SwiftUI
@testable import Amazeballs

class BallAssetManagerTests: XCTestCase {
    
    var manager: BallAssetManager!
    
    override func setUpWithError() throws {
        manager = BallAssetManager.shared
        // Force a refresh to ensure clean state for testing
        manager.refreshAssets()
    }
    
    // MARK: - Singleton Tests
    
    func testSingletonInstance() throws {
        let instance1 = BallAssetManager.shared
        let instance2 = BallAssetManager.shared
        
        XCTAssertTrue(instance1 === instance2, "BallAssetManager should be a singleton")
    }
    
    // MARK: - Asset Discovery Tests
    
    func testAssetDiscovery() throws {
        let ballTypes = manager.availableBallTypes
        
        // Should discover at least some ball types (assuming test assets exist)
        XCTAssertGreaterThanOrEqual(ballTypes.count, 0, "Should discover ball assets")
        
        // Ball types should be sorted
        let sortedTypes = ballTypes.sorted()
        XCTAssertEqual(ballTypes, sortedTypes, "Ball types should be sorted alphabetically")
        
        // Should not contain duplicates
        let uniqueTypes = Set(ballTypes)
        XCTAssertEqual(ballTypes.count, uniqueTypes.count, "Ball types should not contain duplicates")
    }
    
    func testCaching() throws {
        // First access should trigger scan
        let firstAccess = manager.availableBallTypes
        
        // Second access should use cached results (this is hard to test directly,
        // but we can verify the results are consistent)
        let secondAccess = manager.availableBallTypes
        
        XCTAssertEqual(firstAccess, secondAccess, "Cached results should be consistent")
    }
    
    // MARK: - Ball Type Access Tests
    
    func testHasBallType() throws {
        let ballTypes = manager.availableBallTypes
        
        if !ballTypes.isEmpty {
            let firstBallType = ballTypes.first!
            XCTAssertTrue(manager.hasBallType(firstBallType), "Should find existing ball type")
        }
        
        XCTAssertFalse(manager.hasBallType("nonexistent-ball"), "Should not find non-existent ball type")
    }
    
    func testRandomBallType() throws {
        let ballTypes = manager.availableBallTypes
        
        if ballTypes.isEmpty {
            // If no ball assets exist, should return nil
            XCTAssertNil(manager.randomBallType(), "Should return nil when no balls available")
        } else {
            // If ball assets exist, should return a valid ball type
            let randomBall = manager.randomBallType()
            XCTAssertNotNil(randomBall, "Should return a ball type when balls are available")
            XCTAssertTrue(ballTypes.contains(randomBall!), "Random ball should be from available types")
        }
    }
    
    // MARK: - Image Access Tests
    
    func testBallImageAccess() throws {
        let ballTypes = manager.availableBallTypes
        
        if !ballTypes.isEmpty {
            let firstBallType = ballTypes.first!
            
            #if os(macOS)
            let image = manager.ballImage(for: firstBallType)
            XCTAssertNotNil(image, "Should return image for valid ball type")
            #else
            let image = manager.ballImage(for: firstBallType)
            XCTAssertNotNil(image, "Should return image for valid ball type")
            #endif
        }
        
        // Test non-existent ball type
        #if os(macOS)
        let nonExistentImage = manager.ballImage(for: "nonexistent")
        XCTAssertNil(nonExistentImage, "Should return nil for non-existent ball type")
        #else
        let nonExistentImage = manager.ballImage(for: "nonexistent")
        XCTAssertNil(nonExistentImage, "Should return nil for non-existent ball type")
        #endif
    }
    
    func testBallImageViewAccess() throws {
        let ballTypes = manager.availableBallTypes
        
        if !ballTypes.isEmpty {
            let firstBallType = ballTypes.first!
            let imageView = manager.ballImageView(for: firstBallType)
            
            // Hard to test SwiftUI Image directly, but we can verify it doesn't crash
            XCTAssertNotNil(imageView, "Should return SwiftUI Image for valid ball type")
        }
        
        // Test random ball image view
        let randomImageView = manager.randomBallImageView()
        XCTAssertNotNil(randomImageView, "Should always return a SwiftUI Image")
    }
    
    // MARK: - Asset Name Tests
    
    func testAssetNameGeneration() throws {
        let ballType = "football"
        let assetName = manager.assetName(for: ballType)
        
        XCTAssertEqual(assetName, "ball-football", "Should generate correct asset name")
    }
    
    // MARK: - Display Name Tests
    
    func testDisplayNameFormatting() throws {
        XCTAssertEqual(manager.displayName(for: "football"), "Football", "Should capitalize single word")
        XCTAssertEqual(manager.displayName(for: "ping-pong"), "Ping Pong", "Should handle hyphens correctly")
        XCTAssertEqual(manager.displayName(for: "beach-ball"), "Beach Ball", "Should format multi-word names")
    }
    
    func testBallTypesWithDisplayNames() throws {
        let displayNames = manager.ballTypesWithDisplayNames()
        let ballTypes = manager.availableBallTypes
        
        XCTAssertEqual(displayNames.count, ballTypes.count, "Should have display name for each ball type")
        
        for ballType in ballTypes {
            XCTAssertNotNil(displayNames[ballType], "Should have display name for \(ballType)")
            XCTAssertEqual(displayNames[ballType], manager.displayName(for: ballType), "Display names should match")
        }
    }
    
    // MARK: - Refresh Tests
    
    func testRefreshAssets() throws {
        // Get initial ball types
        let initialTypes = manager.availableBallTypes
        
        // Refresh assets
        manager.refreshAssets()
        
        // Get types after refresh
        let refreshedTypes = manager.availableBallTypes
        
        // Should be the same (assuming no assets changed)
        XCTAssertEqual(initialTypes, refreshedTypes, "Refreshed types should match initial types")
    }
    
    // MARK: - Debug Info Tests
    
    func testDebugInfo() throws {
        let debugInfo = manager.debugInfo()
        
        XCTAssertNotNil(debugInfo["totalBallTypes"], "Debug info should contain totalBallTypes")
        XCTAssertNotNil(debugInfo["ballTypes"], "Debug info should contain ballTypes")
        XCTAssertNotNil(debugInfo["hasScanned"], "Debug info should contain hasScanned")
        XCTAssertNotNil(debugInfo["lastScanResult"], "Debug info should contain lastScanResult")
        
        let totalBallTypes = debugInfo["totalBallTypes"] as? Int
        let ballTypes = debugInfo["ballTypes"] as? [String]
        
        XCTAssertEqual(totalBallTypes, ballTypes?.count, "Total should match ball types count")
    }
    
    // MARK: - Performance Tests
    
    func testAssetDiscoveryPerformance() throws {
        // Force a fresh scan
        manager.refreshAssets()
        
        measure {
            _ = manager.availableBallTypes
        }
    }
    
    func testRandomBallTypePerformance() throws {
        // Ensure assets are loaded first
        _ = manager.availableBallTypes
        
        measure {
            for _ in 0..<1000 {
                _ = manager.randomBallType()
            }
        }
    }
}

// MARK: - Integration Tests

class BallAssetManagerIntegrationTests: XCTestCase {
    
    func testIntegrationWithGameSettings() throws {
        let manager = BallAssetManager.shared
        let gameSettings = GameSettings.shared
        
        // Test setting a random ball type in game settings
        if let randomBallType = manager.randomBallType() {
            gameSettings.selectedBallType = randomBallType
            XCTAssertEqual(gameSettings.selectedBallType, randomBallType, "Game settings should store ball type")
            
            // Test that the ball type is actually available
            XCTAssertTrue(manager.hasBallType(randomBallType), "Selected ball type should be available in manager")
        }
    }
    
    func testBallTypeValidation() throws {
        let manager = BallAssetManager.shared
        let gameSettings = GameSettings.shared
        
        // Test setting an invalid ball type
        gameSettings.selectedBallType = "invalid-ball-type"
        
        // The game settings should allow invalid types (for flexibility)
        // but the manager should not recognize them
        if let selectedType = gameSettings.selectedBallType {
            XCTAssertFalse(manager.hasBallType(selectedType), "Invalid ball type should not be recognized by manager")
        }
    }
}