//
//  NotificationNames.swift
//  Amazeballs
//
//  Created by Daniel Flax on 11/15/25.
//

import Foundation

/**
 * Centralized notification name definitions for the Amazeballs app
 * 
 * This file provides a single source of truth for all notification names
 * used throughout the app, preventing duplicate declarations and ensuring
 * consistency across different platform-specific implementations.
 * 
 * ## Usage
 * ```swift
 * // Posting a notification
 * NotificationCenter.default.post(name: .clearAllBalls, object: nil)
 * 
 * // Observing a notification
 * NotificationCenter.default.addObserver(
 *     forName: .clearAllBalls,
 *     object: nil,
 *     queue: .main
 * ) { _ in
 *     // Handle notification
 * }
 * ```
 */
extension Notification.Name {
    
    // MARK: - Game Actions
    
    /// Clears all balls from the physics scene
    static let clearAllBalls = Notification.Name("amazeballs.clearAllBalls")
    
    /// Shows the ball picker UI
    static let showBallPicker = Notification.Name("amazeballs.showBallPicker")
    
    // MARK: - Settings Actions
    
    /// Toggles the boundary walls on/off
    static let toggleWalls = Notification.Name("amazeballs.toggleWalls")
    
    /// Toggles accelerometer-based gravity (iOS/iPadOS only)
    static let toggleAccelerometer = Notification.Name("amazeballs.toggleAccelerometer")
    
    /// Resets all physics settings to defaults
    static let resetPhysics = Notification.Name("amazeballs.resetPhysics")
}
