//
//  BallAssetManager+GameSettings.swift
//  Amazeballs
//
//  Created by Daniel Flax on 11/15/25.
//

import Foundation
import SwiftUI
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
/**
 * Extension to integrate BallAssetManager with GameSettings
 */
extension GameSettings {
    
    /// Returns the currently selected ball image, or nil if no ball is selected or if the selected ball doesn't exist
    #if os(macOS)
    var selectedBallImage: NSImage? {
        guard let ballType = selectedBallType else { return nil }
        return BallAssetManager.shared.ballImage(for: ballType)
    }
    #else
    var selectedBallImage: UIImage? {
        guard let ballType = selectedBallType else { return nil }
        return BallAssetManager.shared.ballImage(for: ballType)
    }
    #endif
    
    /// Returns the currently selected ball as a SwiftUI Image view
    var selectedBallImageView: Image {
        guard let ballType = selectedBallType else {
            return BallAssetManager.shared.randomBallImageView()
        }
        return BallAssetManager.shared.ballImageView(for: ballType)
    }
    
    /// Returns a random ball image (useful when selectedBallType is nil)
    #if os(macOS)
    var randomBallImage: NSImage? {
        guard let randomType = BallAssetManager.shared.randomBallType() else { return nil }
        return BallAssetManager.shared.ballImage(for: randomType)
    }
    #else
    var randomBallImage: UIImage? {
        guard let randomType = BallAssetManager.shared.randomBallType() else { return nil }
        return BallAssetManager.shared.ballImage(for: randomType)
    }
    #endif
    
    /// Returns all available ball types for UI selection
    var availableBallTypes: [String] {
        return BallAssetManager.shared.availableBallTypes
    }
    
    /// Returns display names for all available ball types
    var availableBallDisplayNames: [String: String] {
        return BallAssetManager.shared.ballTypesWithDisplayNames()
    }
    
    /// Validates that the currently selected ball type actually exists
    var isSelectedBallTypeValid: Bool {
        guard let ballType = selectedBallType else { return true } // nil is valid (means random)
        return BallAssetManager.shared.hasBallType(ballType)
    }
    
    /// Sets the selected ball type to a random available ball
    func selectRandomBallType() {
        selectedBallType = BallAssetManager.shared.randomBallType()
    }
    
    /// Clears the selected ball type (will use random balls)
    func clearSelectedBallType() {
        selectedBallType = nil
    }
    
    /// Returns the display name for the currently selected ball type
    var selectedBallDisplayName: String? {
        guard let ballType = selectedBallType else { return nil }
        return BallAssetManager.shared.displayName(for: ballType)
    }
}

/**
 * Extension to add ball-related validation to GameSettings
 */
extension GameSettings {
    
    /// Enhanced validation that includes ball type checking
    func validateSettingsWithBalls() -> Bool {
        // First run the existing validation
        guard validateSettings() else { return false }
        
        // Then validate the selected ball type
        return isSelectedBallTypeValid
    }
    
    /// Returns validation errors including ball-related issues
    func validationErrors() -> [String] {
        var errors: [String] = []
        
        // Check physics settings
        if gravity < 0.0 || gravity > 2.0 {
            errors.append("Gravity must be between 0.0 and 2.0 (current: \(gravity))")
        }
        
        if bounciness < 0.0 || bounciness > 1.0 {
            errors.append("Bounciness must be between 0.0 and 1.0 (current: \(bounciness))")
        }
        
        if ballSize < 0.5 || ballSize > 3.0 {
            errors.append("Ball size must be between 0.5 and 3.0 (current: \(ballSize))")
        }
        
        // Check ball type validation
        if !isSelectedBallTypeValid {
            errors.append("Selected ball type '\(selectedBallType ?? "nil")' is not available")
        }
        
        return errors
    }
}

/**
 * Extension for debug information
 */
extension GameSettings {
    
    /// Returns debug information including ball asset details
    func debugDescriptionWithBalls() -> [String: Any] {
        var debug = debugDescription()
        
        // Add ball-related debug info
        let ballManager = BallAssetManager.shared
        debug["ballAssets"] = ballManager.debugInfo()
        debug["selectedBallValid"] = isSelectedBallTypeValid
        debug["selectedBallDisplayName"] = selectedBallDisplayName
        
        return debug
    }
}
