//
//  GameSettings.swift
//  Amazeballs
//
//  Created by Daniel Flax on 11/15/25.
//

import Foundation
import Observation

/// A comprehensive settings model for the Amazeballs game that handles
/// physics parameters, platform-specific features, and CloudKit synchronization.
///
/// This class manages game settings across iOS, iPadOS, and macOS platforms,
/// automatically syncing changes via NSUbiquitousKeyValueStore for seamless
/// cross-device experiences.
@Observable
final class GameSettings {
    
    // MARK: - Physics Settings
    
    /// Controls the strength of gravity in the physics simulation
    /// - Range: 0.0 (no gravity) to 2.0 (double Earth gravity)
    /// - Default: 1.0 (Earth-like gravity)
    var gravity: Double = 1.0 {
        didSet {
            // Clamp to valid range - but avoid reassigning if already in didSet
            let clamped = max(0.0, min(2.0, gravity))
            if clamped != gravity {
                gravity = clamped
                return // Exit early, syncToCloud will be called by the recursive didSet
            }
            syncToCloud(key: Keys.gravity, value: gravity)
        }
    }
    
    /// Controls how bouncy the balls are when they collide
    /// - Range: 0.0 (no bounce) to 1.0 (perfect bounce)
    /// - Default: 0.8 (realistic bounce)
    var bounciness: Double = 0.8 {
        didSet {
            // Clamp to valid range - but avoid reassigning if already in didSet
            let clamped = max(0.0, min(1.0, bounciness))
            if clamped != bounciness {
                bounciness = clamped
                return // Exit early, syncToCloud will be called by the recursive didSet
            }
            syncToCloud(key: Keys.bounciness, value: bounciness)
        }
    }
    
    /// Controls the size multiplier for dropped balls
    /// - Range: 0.5 (half size) to 3.0 (triple size)
    /// - Default: 1.0 (standard size)
    var ballSize: Double = 1.0 {
        didSet {
            // Clamp to valid range - but avoid reassigning if already in didSet
            let clamped = max(0.5, min(3.0, ballSize))
            if clamped != ballSize {
                ballSize = clamped
                return // Exit early, syncToCloud will be called by the recursive didSet
            }
            syncToCloud(key: Keys.ballSize, value: ballSize)
        }
    }
    
    // MARK: - Game Features
    
    /// Whether invisible walls exist at screen edges to contain balls
    /// - Default: true (balls bounce off screen edges)
    var wallsEnabled: Bool = true {
        didSet {
            syncToCloud(key: Keys.wallsEnabled, value: wallsEnabled)
        }
    }
    
    /// Whether to use device motion to influence gravity direction
    /// - Available on: iOS, iPadOS
    /// - Default: false (use standard downward gravity)
    var accelerometerEnabled: Bool = false {
        didSet {
            // Only sync if platform supports accelerometer
            if isAccelerometerSupported {
                syncToCloud(key: Keys.accelerometerEnabled, value: accelerometerEnabled)
            }
        }
    }
    
    /// The specific ball type to spawn, or nil for random selection
    /// - nil: Random ball type each time
    /// - String: Specific ball type name (e.g., "basketball", "tennisball")
    var selectedBallType: String? = nil {
        didSet {
            syncToCloud(key: Keys.selectedBallType, value: selectedBallType)
        }
    }
    
    // MARK: - Platform Support
    
    /// Returns true if the current platform supports accelerometer input
    var isAccelerometerSupported: Bool {
        #if os(iOS) || os(iPadOS)
        return true
        #else
        return false
        #endif
    }
    
    /// Returns true if walls are supported on the current platform
    var areWallsSupported: Bool {
        // All platforms support walls
        return true
    }
    
    // MARK: - CloudKit Keys
    
    /// Flag to prevent syncing when applying external CloudKit changes
    private var isApplyingExternalChanges = false
    
    /// Keys used for NSUbiquitousKeyValueStore synchronization
    private enum Keys {
        static let gravity = "amazeballs.settings.gravity"
        static let bounciness = "amazeballs.settings.bounciness"
        static let ballSize = "amazeballs.settings.ballSize"
        static let wallsEnabled = "amazeballs.settings.wallsEnabled"
        static let accelerometerEnabled = "amazeballs.settings.accelerometerEnabled"
        static let selectedBallType = "amazeballs.settings.selectedBallType"
    }
    
    // MARK: - Initialization
    
    /// Shared singleton instance for app-wide settings access
    static let shared = GameSettings()
    
    /// Private initializer to enforce singleton pattern and load saved settings
    private init() {
        loadFromCloud()
        setupCloudKitObserver()
    }
    
    // MARK: - CloudKit Synchronization
    
    /// Loads settings from NSUbiquitousKeyValueStore
    private func loadFromCloud() {
        let store = NSUbiquitousKeyValueStore.default
        
        // Load physics settings
        if store.object(forKey: Keys.gravity) != nil {
            gravity = store.double(forKey: Keys.gravity)
        }
        
        if store.object(forKey: Keys.bounciness) != nil {
            bounciness = store.double(forKey: Keys.bounciness)
        }
        
        if store.object(forKey: Keys.ballSize) != nil {
            ballSize = store.double(forKey: Keys.ballSize)
        }
        
        // Load game features
        if store.object(forKey: Keys.wallsEnabled) != nil {
            wallsEnabled = store.bool(forKey: Keys.wallsEnabled)
        }
        
        // Only load accelerometer setting if platform supports it
        if isAccelerometerSupported && store.object(forKey: Keys.accelerometerEnabled) != nil {
            accelerometerEnabled = store.bool(forKey: Keys.accelerometerEnabled)
        }
        
        // Load ball type preference
        selectedBallType = store.string(forKey: Keys.selectedBallType)
    }
    
    /// Saves a value to NSUbiquitousKeyValueStore
    /// - Parameters:
    ///   - key: The key to store the value under
    ///   - value: The value to store
    private func syncToCloud<T>(key: String, value: T) {
        // Don't sync back to cloud when applying external changes
        guard !isApplyingExternalChanges else { return }
        
        let store = NSUbiquitousKeyValueStore.default
        
        switch value {
        case let doubleValue as Double:
            store.set(doubleValue, forKey: key)
        case let boolValue as Bool:
            store.set(boolValue, forKey: key)
        case let stringValue as String:
            store.set(stringValue, forKey: key)
        case let optionalString as String?:
            if let stringValue = optionalString {
                store.set(stringValue, forKey: key)
            } else {
                store.removeObject(forKey: key)
            }
        default:
            print("⚠️ GameSettings: Unsupported value type for CloudKit sync")
        }
        
        // Synchronize immediately for better user experience
        store.synchronize()
    }
    
    /// Sets up observation for external CloudKit changes
    private func setupCloudKitObserver() {
        NotificationCenter.default.addObserver(
            forName: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: NSUbiquitousKeyValueStore.default,
            queue: .main
        ) { [weak self] notification in
            self?.handleExternalCloudKitChanges(notification)
        }
    }
    
    /// Handles external changes from CloudKit (e.g., from other devices)
    /// - Parameter notification: The CloudKit change notification
    private func handleExternalCloudKitChanges(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let changedKeys = userInfo[NSUbiquitousKeyValueStoreChangedKeysKey] as? [String] else {
            return
        }
        
        let store = NSUbiquitousKeyValueStore.default
        
        // Temporarily disable syncing while applying external changes
        isApplyingExternalChanges = true
        defer { isApplyingExternalChanges = false }
        
        for key in changedKeys {
            switch key {
            case Keys.gravity:
                let newValue = store.double(forKey: key)
                let clamped = max(0.0, min(2.0, newValue))
                if clamped != gravity {
                    gravity = clamped
                }
                
            case Keys.bounciness:
                let newValue = store.double(forKey: key)
                let clamped = max(0.0, min(1.0, newValue))
                if clamped != bounciness {
                    bounciness = clamped
                }
                
            case Keys.ballSize:
                let newValue = store.double(forKey: key)
                let clamped = max(0.5, min(3.0, newValue))
                if clamped != ballSize {
                    ballSize = clamped
                }
                
            case Keys.wallsEnabled:
                let newValue = store.bool(forKey: key)
                if newValue != wallsEnabled {
                    wallsEnabled = newValue
                }
                
            case Keys.accelerometerEnabled:
                if isAccelerometerSupported {
                    let newValue = store.bool(forKey: key)
                    if newValue != accelerometerEnabled {
                        accelerometerEnabled = newValue
                    }
                }
                
            case Keys.selectedBallType:
                let newValue = store.string(forKey: key)
                if newValue != selectedBallType {
                    selectedBallType = newValue
                }
                
            default:
                break
            }
        }
    }
    
    // MARK: - Settings Management
    
    /// Resets all settings to their default values
    /// This will also sync the defaults to CloudKit
    func reset() {
        // Reset to defaults (this will trigger property observers)
        gravity = 1.0
        bounciness = 0.8
        ballSize = 1.0
        wallsEnabled = true
        accelerometerEnabled = false
        selectedBallType = nil
        
        print("🔄 GameSettings: All settings reset to defaults")
    }
    
    /// Validates that all current settings are within acceptable ranges
    /// - Returns: True if all settings are valid, false otherwise
    func validateSettings() -> Bool {
        let gravityValid = gravity >= 0.0 && gravity <= 2.0
        let bouncinessValid = bounciness >= 0.0 && bounciness <= 1.0
        let ballSizeValid = ballSize >= 0.5 && ballSize <= 3.0
        
        return gravityValid && bouncinessValid && ballSizeValid
    }
    
    /// Returns a dictionary representation of current settings for debugging
    /// - Returns: Dictionary containing all current setting values
    func debugDescription() -> [String: Any] {
        return [
            "gravity": gravity,
            "bounciness": bounciness,
            "ballSize": ballSize,
            "wallsEnabled": wallsEnabled,
            "accelerometerEnabled": accelerometerEnabled,
            "selectedBallType": selectedBallType ?? "random",
            "platform": currentPlatform(),
            "accelerometerSupported": isAccelerometerSupported,
            "wallsSupported": areWallsSupported
        ]
    }
    
    /// Returns the current platform name for debugging
    /// - Returns: String representation of the current platform
    private func currentPlatform() -> String {
        #if os(iOS)
        return "iOS"
        #elseif os(iPadOS)
        return "iPadOS"
        #elseif os(macOS)
        return "macOS"
        #elseif os(watchOS)
        return "watchOS"
        #elseif os(visionOS)
        return "visionOS"
        #else
        return "Unknown"
        #endif
    }
}

// MARK: - Convenience Extensions

extension GameSettings {
    /// Convenience computed property for UI binding to gravity percentage
    var gravityPercentage: Double {
        get { gravity * 50.0 } // Convert 0.0-2.0 to 0.0-100.0
        set { gravity = newValue / 50.0 } // Convert back to 0.0-2.0
    }
    
    /// Convenience computed property for UI binding to bounciness percentage
    var bouncinessPercentage: Double {
        get { bounciness * 100.0 } // Convert 0.0-1.0 to 0.0-100.0
        set { bounciness = newValue / 100.0 } // Convert back to 0.0-1.0
    }
    
    /// Convenience computed property for UI binding to ball size percentage
    var ballSizePercentage: Double {
        get { (ballSize - 0.5) * 40.0 } // Convert 0.5-3.0 to 0.0-100.0
        set { ballSize = (newValue / 40.0) + 0.5 } // Convert back to 0.5-3.0
    }
}
