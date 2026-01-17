//
//  GameSettings.swift
//  Amazeballs
//
//  Created by Daniel Flax on 11/15/25.
//

import Foundation
import Observation
import CloudKit

/// A comprehensive settings model for the Amazeballs game that handles
/// physics parameters, platform-specific features, and persistent storage.
///
/// This class manages game settings across iOS, iPadOS, and macOS platforms,
/// using UserDefaults for reliable local persistence and NSUbiquitousKeyValueStore
/// for seamless cross-device CloudKit synchronization.
///
/// ## Storage Strategy
/// - **Primary**: UserDefaults for immediate, reliable local storage
/// - **Secondary**: NSUbiquitousKeyValueStore for cross-device sync
/// - **Fallback**: Built-in defaults if no stored values exist
@Observable
final class GameSettings {
    
    // MARK: - Physics Settings
    
    /// Controls the strength of gravity in the physics simulation
    /// - Range: 0.0 (no gravity) to 4.0 (4x Earth gravity)
    /// - Default: 1.0 (Earth-like gravity)
    var gravity: Double = 1.0 {
        didSet {
            // Clamp to valid range - but avoid reassigning if already in didSet
            let clamped = max(0.0, min(4.0, gravity)) // Convert 0.0-4.0 range
            if clamped != gravity {
                gravity = clamped
                return // Exit early, persistence will be called by the recursive didSet
            }
            persistValue(key: Keys.gravity, value: gravity)
        }
    }
    
    /// Controls how bouncy the balls are when they collide
    /// - Range: 0.0 (no bounce) to 1.3 (hyper-elastic)
    /// - Default: 0.8 (realistic bounce)
    var bounciness: Double = 0.8 {
        didSet {
            // Clamp to valid range - but avoid reassigning if already in didSet
            let clamped = max(0.0, min(1.3, bounciness))
            if clamped != bounciness {
                bounciness = clamped
                return // Exit early, persistence will be called by the recursive didSet
            }
            persistValue(key: Keys.bounciness, value: bounciness)
        }
    }
    
    /// Controls the size multiplier for dropped balls
    /// - Range: 0.5 (half size) to 5.0 (5x size)
    /// - Default: 1.0 (standard size)
    var ballSize: Double = 1.0 {
        didSet {
            // Clamp to valid range - but avoid reassigning if already in didSet
            let clamped = max(0.5, min(5.0, ballSize))
            if clamped != ballSize {
                ballSize = clamped
                return // Exit early, persistence will be called by the recursive didSet
            }
            persistValue(key: Keys.ballSize, value: ballSize)
        }
    }
    
    /// Whether to use randomized ball sizes instead of fixed size
    /// - Default: false (use fixed ballSize value)
    var randomBallSizeEnabled: Bool = false {
        didSet {
            persistValue(key: Keys.randomBallSizeEnabled, value: randomBallSizeEnabled)
        }
    }

    // MARK: - Ball Size Mode
    enum BallSizeMode: String {
        case fixed
        case random
        case pressAndGrow
    }

    /// Controls how ball size is chosen when spawning
    /// - fixed: use `ballSize`
    /// - random: random between min and max
    /// - pressAndGrow: grow from min to max based on press duration
    var ballSizeMode: BallSizeMode = .fixed {
        didSet {
            persistValue(key: Keys.ballSizeMode, value: ballSizeMode.rawValue)
        }
    }

    /// Internal tuning parameter for press-and-grow behavior (seconds to reach max)
    /// Not exposed in UI; tweak here while iterating.
    var pressAndGrowDuration: Double = 1.0
    
    // MARK: - Game Features
    
    /// Whether invisible walls exist at screen edges to contain balls
    /// - Default: true (balls bounce off screen edges)
    var wallsEnabled: Bool = true {
        didSet {
            persistValue(key: Keys.wallsEnabled, value: wallsEnabled)
        }
    }
    
    // MARK: - Audio Settings
    
    /// Master volume for all game sounds
    /// - Range: 0.0 (silent) to 1.0 (full volume)
    /// - Default: 0.7 (comfortable listening level)
    var masterVolume: Double = 0.7 {
        didSet {
            // Clamp to valid range
            let clamped = max(0.0, min(1.0, masterVolume))
            if clamped != masterVolume {
                masterVolume = clamped
                return
            }
            persistValue(key: Keys.masterVolume, value: masterVolume)
        }
    }
    
    /// Whether sound effects are enabled
    /// - Default: true (sound effects enabled)
    var soundEffectsEnabled: Bool = true {
        didSet {
            persistValue(key: Keys.soundEffectsEnabled, value: soundEffectsEnabled)
        }
    }
    
    /// Whether to use device motion to influence gravity direction
    /// - Available on: iOS, iPadOS
    /// - Default: false (use standard downward gravity)
    var accelerometerEnabled: Bool = false {
        didSet {
            // Only persist if platform supports accelerometer
            if isAccelerometerSupported {
                persistValue(key: Keys.accelerometerEnabled, value: accelerometerEnabled)
            }
        }
    }
    
    /// The specific ball type to spawn, or nil for random selection
    /// - nil: Random ball type each time
    /// - String: Specific ball type name (e.g., "basketball", "tennisball")
    var selectedBallType: String? = nil {
        didSet {
            persistValue(key: Keys.selectedBallType, value: selectedBallType)
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
    
    /// Returns the current CloudKit availability status
    var isCloudKitAvailable: Bool {
        return _isCloudKitAvailable
    }
    
    // MARK: - Persistence & Sync
    
    /// Flag to prevent syncing when applying external changes from CloudKit or UserDefaults
    private var isApplyingExternalChanges = false
    
    /// CloudKit availability status
    private var _isCloudKitAvailable = false
    
    /// Flag to track if CloudKit observer has been set up
    private var hasSetUpCloudKitObserver = false
    
    /// UserDefaults keys for local persistence
    private enum Keys {
        static let gravity = "amazeballs.settings.gravity"
        static let bounciness = "amazeballs.settings.bounciness"
        static let ballSize = "amazeballs.settings.ballSize"
        static let randomBallSizeEnabled = "amazeballs.settings.randomBallSizeEnabled"
        static let ballSizeMode = "amazeballs.settings.ballSizeMode"
        static let wallsEnabled = "amazeballs.settings.wallsEnabled"
        static let accelerometerEnabled = "amazeballs.settings.accelerometerEnabled"
        static let selectedBallType = "amazeballs.settings.selectedBallType"
        static let masterVolume = "amazeballs.settings.masterVolume"
        static let soundEffectsEnabled = "amazeballs.settings.soundEffectsEnabled"
        
        // Key to track if we've initialized from storage before
        static let hasLoadedFromStorage = "amazeballs.settings.hasLoadedFromStorage"
    }
    
    // MARK: - Initialization
    
    /// Shared singleton instance for app-wide settings access
    static let shared = GameSettings()
    
    /// Private initializer to enforce singleton pattern and load saved settings
    private init() {
        checkCloudKitAvailability()
        loadFromStorage()
        setupCloudKitObserver()
    }
    
    // MARK: - Persistent Storage
    
    /// Checks if CloudKit is available and properly configured
    private func checkCloudKitAvailability() {
        Task {
            await refreshCloudKitStatus()
        }
    }
    
    /// Refreshes the CloudKit availability status (can be called publicly)
    @MainActor
    func refreshCloudKitStatus() async {
        do {
            let container = CKContainer.default()
            let status = try await container.accountStatus()
            
            switch status {
            case .available:
                self._isCloudKitAvailable = true
                print("✅ GameSettings: CloudKit is available and user is signed in")
            case .noAccount:
                self._isCloudKitAvailable = false
                print("⚠️ GameSettings: CloudKit unavailable - user not signed into iCloud")
            case .restricted:
                self._isCloudKitAvailable = false
                print("⚠️ GameSettings: CloudKit restricted")
            case .couldNotDetermine:
                self._isCloudKitAvailable = false
                print("⚠️ GameSettings: CloudKit status could not be determined")
            case .temporarilyUnavailable:
                self._isCloudKitAvailable = false
                print("⚠️ GameSettings: CloudKit temporarily unavailable")
            @unknown default:
                self._isCloudKitAvailable = false
                print("⚠️ GameSettings: CloudKit unknown status")
            }
            
            // If CloudKit became available, try syncing and setup observer if needed
            if _isCloudKitAvailable {
                syncFromCloudKitIfAvailable()
                if !hasSetUpCloudKitObserver {
                    setupCloudKitObserver()
                }
            }
            
        } catch {
            self._isCloudKitAvailable = false
            print("❌ GameSettings: CloudKit error - \(error.localizedDescription)")
        }
    }
    
    /// Loads settings from local storage (UserDefaults) first, then tries CloudKit if available
    /// This provides immediate access to settings while allowing CloudKit sync when possible
    private func loadFromStorage() {
        // Always load from UserDefaults first for immediate access
        let defaults = UserDefaults.standard
        
        // Prevent triggering property observers during initial load
        isApplyingExternalChanges = true
        defer { isApplyingExternalChanges = false }
        
        // Load all settings from UserDefaults
        if defaults.object(forKey: Keys.gravity) != nil {
            gravity = defaults.double(forKey: Keys.gravity)
        }
        
        if defaults.object(forKey: Keys.bounciness) != nil {
            bounciness = defaults.double(forKey: Keys.bounciness)
        }
        
        if defaults.object(forKey: Keys.ballSize) != nil {
            ballSize = defaults.double(forKey: Keys.ballSize)
        }
        
        if defaults.object(forKey: Keys.randomBallSizeEnabled) != nil {
            randomBallSizeEnabled = defaults.bool(forKey: Keys.randomBallSizeEnabled)
        }
        
        if let modeString = defaults.string(forKey: Keys.ballSizeMode), let mode = BallSizeMode(rawValue: modeString) {
            ballSizeMode = mode
        }
        
        if defaults.object(forKey: Keys.wallsEnabled) != nil {
            wallsEnabled = defaults.bool(forKey: Keys.wallsEnabled)
        }
        
        // Only load accelerometer setting if platform supports it
        if isAccelerometerSupported && defaults.object(forKey: Keys.accelerometerEnabled) != nil {
            accelerometerEnabled = defaults.bool(forKey: Keys.accelerometerEnabled)
        }
        
        // Ball type preference
        selectedBallType = defaults.string(forKey: Keys.selectedBallType)
        
        // Audio settings
        if defaults.object(forKey: Keys.masterVolume) != nil {
            masterVolume = defaults.double(forKey: Keys.masterVolume)
        }
        
        if defaults.object(forKey: Keys.soundEffectsEnabled) != nil {
            soundEffectsEnabled = defaults.bool(forKey: Keys.soundEffectsEnabled)
        }
        
        // Mark that we've loaded from storage
        defaults.set(true, forKey: Keys.hasLoadedFromStorage)
        
        // Try to sync from CloudKit if available (after initial UserDefaults load)
        syncFromCloudKitIfAvailable()
        
        print("✅ GameSettings: Loaded settings from UserDefaults")
    }
    
    /// Attempts to sync settings from CloudKit if available, updating UserDefaults as backup
    private func syncFromCloudKitIfAvailable() {
        // Only try CloudKit if we think it might be available
        guard _isCloudKitAvailable else { 
            print("⚠️ GameSettings: Skipping CloudKit sync - not available")
            return 
        }
        
        let cloudStore = NSUbiquitousKeyValueStore.default
        let defaults = UserDefaults.standard
        
        // Prevent triggering property observers during sync
        isApplyingExternalChanges = true
        defer { isApplyingExternalChanges = false }
        
        print("🔄 GameSettings: Attempting CloudKit sync...")
        
        // For each setting, if CloudKit has a value, use it and update UserDefaults
        if let _ = cloudStore.object(forKey: Keys.gravity) {
            let cloudValue = cloudStore.double(forKey: Keys.gravity)
            let clamped = max(0.0, min(4.0, cloudValue)) // Changed max to 4.0
            gravity = clamped
            defaults.set(clamped, forKey: Keys.gravity)
        }
        
        if let _ = cloudStore.object(forKey: Keys.bounciness) {
            let cloudValue = cloudStore.double(forKey: Keys.bounciness)
            let clamped = max(0.0, min(1.3, cloudValue))
            bounciness = clamped
            defaults.set(clamped, forKey: Keys.bounciness)
        }
        
        if let _ = cloudStore.object(forKey: Keys.ballSize) {
            let cloudValue = cloudStore.double(forKey: Keys.ballSize)
            let clamped = max(0.5, min(5.0, cloudValue))
            ballSize = clamped
            defaults.set(clamped, forKey: Keys.ballSize)
        }
        
        if let _ = cloudStore.object(forKey: Keys.randomBallSizeEnabled) {
            let cloudValue = cloudStore.bool(forKey: Keys.randomBallSizeEnabled)
            randomBallSizeEnabled = cloudValue
            defaults.set(cloudValue, forKey: Keys.randomBallSizeEnabled)
        }
        
        if let modeString = cloudStore.string(forKey: Keys.ballSizeMode), let mode = BallSizeMode(rawValue: modeString) {
            ballSizeMode = mode
            defaults.set(modeString, forKey: Keys.ballSizeMode)
        }
        
        if let _ = cloudStore.object(forKey: Keys.wallsEnabled) {
            let cloudValue = cloudStore.bool(forKey: Keys.wallsEnabled)
            wallsEnabled = cloudValue
            defaults.set(cloudValue, forKey: Keys.wallsEnabled)
        }
        
        if isAccelerometerSupported, let _ = cloudStore.object(forKey: Keys.accelerometerEnabled) {
            let cloudValue = cloudStore.bool(forKey: Keys.accelerometerEnabled)
            accelerometerEnabled = cloudValue
            defaults.set(cloudValue, forKey: Keys.accelerometerEnabled)
        }
        
        if let cloudValue = cloudStore.string(forKey: Keys.selectedBallType) {
            selectedBallType = cloudValue
            defaults.set(cloudValue, forKey: Keys.selectedBallType)
        } else if cloudStore.object(forKey: Keys.selectedBallType) != nil {
            // CloudKit has nil value, so clear local too
            selectedBallType = nil
            defaults.removeObject(forKey: Keys.selectedBallType)
        }
        
        if let _ = cloudStore.object(forKey: Keys.masterVolume) {
            let cloudValue = cloudStore.double(forKey: Keys.masterVolume)
            let clamped = max(0.0, min(1.0, cloudValue))
            masterVolume = clamped
            defaults.set(clamped, forKey: Keys.masterVolume)
        }
        
        if let _ = cloudStore.object(forKey: Keys.soundEffectsEnabled) {
            let cloudValue = cloudStore.bool(forKey: Keys.soundEffectsEnabled)
            soundEffectsEnabled = cloudValue
            defaults.set(cloudValue, forKey: Keys.soundEffectsEnabled)
        }
    }
    
    /// Persists a setting value to UserDefaults (always) and CloudKit (when available)
    /// - Parameters:
    ///   - key: The key to store the value under
    ///   - value: The value to store
    private func persistValue<T>(key: String, value: T) {
        // Don't persist when applying external changes
        guard !isApplyingExternalChanges else { return }
        
        let defaults = UserDefaults.standard
        
        // Always save to UserDefaults for reliable local persistence
        switch value {
        case let doubleValue as Double:
            defaults.set(doubleValue, forKey: key)
        case let boolValue as Bool:
            defaults.set(boolValue, forKey: key)
        case let stringValue as String:
            defaults.set(stringValue, forKey: key)
        case let optionalString as String?:
            if let stringValue = optionalString {
                defaults.set(stringValue, forKey: key)
            } else {
                defaults.removeObject(forKey: key)
            }
        default:
            print("⚠️ GameSettings: Unsupported value type for persistence")
            return
        }
        
        // Also save to CloudKit if available
        if _isCloudKitAvailable {
            let cloudStore = NSUbiquitousKeyValueStore.default
            
            switch value {
            case let doubleValue as Double:
                cloudStore.set(doubleValue, forKey: key)
            case let boolValue as Bool:
                cloudStore.set(boolValue, forKey: key)
            case let stringValue as String:
                cloudStore.set(stringValue, forKey: key)
            case let optionalString as String?:
                if let stringValue = optionalString {
                    cloudStore.set(stringValue, forKey: key)
                } else {
                    cloudStore.removeObject(forKey: key)
                }
            default:
                break
            }
            
            // Synchronize CloudKit for cross-device sync (best effort)
            cloudStore.synchronize()
            
            #if DEBUG
            print("💾 GameSettings: Persisted \(key) = \(value) to both UserDefaults and CloudKit")
            #endif
        } else {
            #if DEBUG
            print("💾 GameSettings: Persisted \(key) = \(value) to UserDefaults only (CloudKit unavailable)")
            #endif
        }
    }
    
    // MARK: - CloudKit Cross-Device Sync
    
    /// Sets up observation for external CloudKit changes from other devices
    private func setupCloudKitObserver() {
        // Only set up CloudKit observer if it's available
        guard _isCloudKitAvailable else {
            print("⚠️ GameSettings: Skipping CloudKit observer setup - CloudKit unavailable")
            return
        }
        
        NotificationCenter.default.addObserver(
            forName: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: NSUbiquitousKeyValueStore.default,
            queue: .main
        ) { [weak self] notification in
            self?.handleExternalCloudKitChanges(notification)
        }
        
        print("✅ GameSettings: CloudKit observer set up successfully")
        hasSetUpCloudKitObserver = true
    }
    
    /// Handles external changes from CloudKit (e.g., from other devices)
    /// Updates local UserDefaults and property values to stay in sync
    /// - Parameter notification: The CloudKit change notification
    private func handleExternalCloudKitChanges(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let changedKeys = userInfo[NSUbiquitousKeyValueStoreChangedKeysKey] as? [String] else {
            return
        }
        
        let cloudStore = NSUbiquitousKeyValueStore.default
        let defaults = UserDefaults.standard
        
        // Temporarily disable persistence while applying external changes
        isApplyingExternalChanges = true
        defer { isApplyingExternalChanges = false }
        
        print("🔄 GameSettings: Received CloudKit sync for keys: \(changedKeys)")
        
        for key in changedKeys {
            switch key {
            case Keys.gravity:
                let newValue = cloudStore.double(forKey: key)
                let clamped = max(0.0, min(4.0, newValue)) // Changed max to 4.0
                if clamped != gravity {
                    gravity = clamped
                    defaults.set(clamped, forKey: key) // Update local cache
                }
                
            case Keys.bounciness:
                let newValue = cloudStore.double(forKey: key)
                let clamped = max(0.0, min(1.3, newValue))
                if clamped != bounciness {
                    bounciness = clamped
                    defaults.set(clamped, forKey: key)
                }
                
            case Keys.ballSize:
                let newValue = cloudStore.double(forKey: key)
                let clamped = max(0.5, min(5.0, newValue))
                if clamped != ballSize {
                    ballSize = clamped
                    defaults.set(clamped, forKey: key)
                }
                
            case Keys.randomBallSizeEnabled:
                let newValue = cloudStore.bool(forKey: key)
                if newValue != randomBallSizeEnabled {
                    randomBallSizeEnabled = newValue
                    defaults.set(newValue, forKey: key)
                }
            
            case Keys.ballSizeMode:
                if let modeString = cloudStore.string(forKey: key), let mode = BallSizeMode(rawValue: modeString) {
                    if mode != ballSizeMode {
                        ballSizeMode = mode
                        defaults.set(modeString, forKey: key)
                    }
                }
                
            case Keys.wallsEnabled:
                let newValue = cloudStore.bool(forKey: key)
                if newValue != wallsEnabled {
                    wallsEnabled = newValue
                    defaults.set(newValue, forKey: key)
                }
                
            case Keys.accelerometerEnabled:
                if isAccelerometerSupported {
                    let newValue = cloudStore.bool(forKey: key)
                    if newValue != accelerometerEnabled {
                        accelerometerEnabled = newValue
                        defaults.set(newValue, forKey: key)
                    }
                }
                
            case Keys.selectedBallType:
                let newValue = cloudStore.string(forKey: key)
                if newValue != selectedBallType {
                    selectedBallType = newValue
                    if let value = newValue {
                        defaults.set(value, forKey: key)
                    } else {
                        defaults.removeObject(forKey: key)
                    }
                }
                
            case Keys.masterVolume:
                let newValue = cloudStore.double(forKey: key)
                let clamped = max(0.0, min(1.0, newValue))
                if clamped != masterVolume {
                    masterVolume = clamped
                    defaults.set(clamped, forKey: key)
                }
                
            case Keys.soundEffectsEnabled:
                let newValue = cloudStore.bool(forKey: key)
                if newValue != soundEffectsEnabled {
                    soundEffectsEnabled = newValue
                    defaults.set(newValue, forKey: key)
                }
                
            default:
                break
            }
        }
    }
    
    // MARK: - Settings Management
    
    /// Resets all settings to their default values
    /// This will clear both local storage and CloudKit (if available), syncing defaults across all devices
    func reset() {
        // Clear from both UserDefaults and CloudKit
        clearAllStoredSettings()
        
        // Reset to defaults (this will trigger property observers and re-persist)
        gravity = 1.0
        bounciness = 0.8
        ballSize = 1.0
        randomBallSizeEnabled = false
        ballSizeMode = .fixed
        wallsEnabled = true
        accelerometerEnabled = false
        selectedBallType = nil
        masterVolume = 0.7
        soundEffectsEnabled = true
        
        print("🔄 GameSettings: All settings reset to defaults and synced")
    }
    
    /// Clears all stored settings from UserDefaults and CloudKit (if available)
    private func clearAllStoredSettings() {
        let defaults = UserDefaults.standard
        
        let allKeys = [
            Keys.gravity, Keys.bounciness, Keys.ballSize, Keys.randomBallSizeEnabled,
            Keys.ballSizeMode, Keys.wallsEnabled, Keys.accelerometerEnabled, Keys.selectedBallType,
            Keys.masterVolume, Keys.soundEffectsEnabled
        ]
        
        // Always clear from UserDefaults
        for key in allKeys {
            defaults.removeObject(forKey: key)
        }
        
        // Also clear from CloudKit if available
        if _isCloudKitAvailable {
            let cloudStore = NSUbiquitousKeyValueStore.default
            for key in allKeys {
                cloudStore.removeObject(forKey: key)
            }
            cloudStore.synchronize()
        }
    }
    
    /// Validates that all current settings are within acceptable ranges
    /// - Returns: True if all settings are valid, false otherwise
    func validateSettings() -> Bool {
        let gravityValid = gravity >= 0.0 && gravity <= 4.0 // changed max to 4.0
        let bouncinessValid = bounciness >= 0.0 && bounciness <= 1.3
        let ballSizeValid = ballSize >= 0.5 && ballSize <= 5.0
        
        return gravityValid && bouncinessValid && ballSizeValid
    }
    
    /// Returns the effective ball size to use for spawning balls
    /// - Returns: Either the fixed ballSize or a random size based on randomBallSizeEnabled or pressAndGrow mode
    func effectiveBallSize() -> Double {
        switch ballSizeMode {
        case .fixed:
            return ballSize
        case .random:
            return Double.random(in: 0.5...5.0)
        case .pressAndGrow:
            // For press-and-grow, size is computed from gesture; fall back to fixed if invoked here.
            return ballSize
        }
    }
    
    /// Returns a dictionary representation of current settings for debugging
    /// - Returns: Dictionary containing all current setting values
    func debugDescription() -> [String: Any] {
        return [
            "gravity": gravity,
            "bounciness": bounciness,
            "ballSize": ballSize,
            "randomBallSizeEnabled": randomBallSizeEnabled,
            "ballSizeMode": ballSizeMode.rawValue,
            "wallsEnabled": wallsEnabled,
            "accelerometerEnabled": accelerometerEnabled,
            "selectedBallType": selectedBallType ?? "random",
            "masterVolume": masterVolume,
            "soundEffectsEnabled": soundEffectsEnabled,
            "platform": currentPlatform(),
            "accelerometerSupported": isAccelerometerSupported,
            "wallsSupported": areWallsSupported,
            "hasLocalStorage": hasLocalStorageForAnyKey(),
            "hasCloudStorage": hasCloudStorageForAnyKey(),
            "isCloudKitAvailable": isCloudKitAvailable
        ]
    }
    
    /// Checks if any settings exist in UserDefaults
    /// - Returns: True if at least one setting is stored locally
    private func hasLocalStorageForAnyKey() -> Bool {
        let defaults = UserDefaults.standard
        let allKeys = [
            Keys.gravity, Keys.bounciness, Keys.ballSize, Keys.randomBallSizeEnabled,
            Keys.ballSizeMode, Keys.wallsEnabled, Keys.accelerometerEnabled, Keys.selectedBallType,
            Keys.masterVolume, Keys.soundEffectsEnabled
        ]
        
        return allKeys.contains { defaults.object(forKey: $0) != nil }
    }
    
    /// Checks if any settings exist in CloudKit (only if CloudKit is available)
    /// - Returns: True if at least one setting is stored in the cloud
    private func hasCloudStorageForAnyKey() -> Bool {
        guard _isCloudKitAvailable else { return false }
        
        let cloudStore = NSUbiquitousKeyValueStore.default
        let allKeys = [
            Keys.gravity, Keys.bounciness, Keys.ballSize, Keys.randomBallSizeEnabled,
            Keys.ballSizeMode, Keys.wallsEnabled, Keys.accelerometerEnabled, Keys.selectedBallType,
            Keys.masterVolume, Keys.soundEffectsEnabled
        ]
        
        return allKeys.contains { cloudStore.object(forKey: $0) != nil }
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
        get { gravity * 25.0 } // Convert 0.0-4.0 to 0.0-100.0
        set { gravity = newValue / 25.0 } // Convert back to 0.0-4.0
    }
    
    /// Convenience computed property for UI binding to bounciness percentage
    /// Note: 100% corresponds to 1.0 (standard max bounce),
    /// but actual bounciness can go up to 1.3 (130%) via advanced settings or watch controls.
    var bouncinessPercentage: Double {
        get { bounciness * 100.0 } // Convert 0.0-1.3 to 0.0-130.0
        set { bounciness = newValue / 100.0 } // Convert back to 0.0-1.3 (values > 100% possible)
    }
    
    /// Convenience computed property for UI binding to ball size percentage
    var ballSizePercentage: Double {
        get { (ballSize - 0.5) * (100.0 / 4.5) } // Convert 0.5-5.0 to 0.0-100.0
        set { ballSize = (newValue * 4.5 / 100.0) + 0.5 } // Convert back to 0.5-5.0
    }
    
    /// Convenience computed property for UI binding to master volume percentage
    var masterVolumePercentage: Double {
        get { masterVolume * 100.0 } // Convert 0.0-1.0 to 0.0-100.0
        set { masterVolume = newValue / 100.0 } // Convert back to 0.0-1.0
    }
}
