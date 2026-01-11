//
//  WatchApp.swift
//  Amazeballs Watch App
//
//  Created by Daniel Flax on 11/17/25.
//

import SwiftUI

/**
 * WatchApp
 *
 * The main application entry point for the Amazeballs watchOS app.
 * Provides a simplified physics experience optimized for Apple Watch with
 * Digital Crown integration and simplified touch controls.
 *
 * ## watchOS Features
 * - Digital Crown control for gravity OR bounciness (user preference)
 * - Double-tap gesture to toggle walls on/off
 * - Single tap to drop balls
 * - Automatic ball type selection
 * - Shared settings sync with iPhone/iPad via CloudKit
 * - Optimized for 44mm watch display
 *
 * ## Simplified Feature Set
 * - Digital Crown adjusts either gravity (0.0-2.0) or bounciness (0.0-1.0)
 * - Wall toggle via double-tap anywhere on screen
 * - No ball type picker (uses shared selectedBallType or random)
 * - No audio controls (watch manages audio separately)
 * - Minimal UI optimized for glanceable interaction
 *
 * ## Requirements
 * - watchOS 11.0+
 * - Paired iPhone with Amazeballs app installed
 * - Optional iCloud account for settings sync
 *
 * ## Usage
 * 1. Single tap anywhere → drop a ball
 * 2. Rotate Digital Crown → adjust gravity or bounciness (toggle in settings)
 * 3. Double-tap anywhere → toggle walls on/off
 * 4. Settings sync automatically with paired iPhone
 */
@main
struct WatchApp: App {
    
    // MARK: - App State
    
    /// Shared game settings that sync with iPhone/iPad
    @State private var gameSettings = GameSettings.shared
    
    /// Watch-specific preference for what Digital Crown controls
    @AppStorage("watchCrownControlsGravity") private var crownControlsGravity = true
    
    // MARK: - Scene Configuration
    
    var body: some Scene {
        WindowGroup {
            WatchContentView()
                .environment(gameSettings)
                .onAppear {
                    configureWatchApp()
                }
        }
    }
    
    // MARK: - Watch Configuration
    
    /**
     * Configures watchOS-specific app settings
     */
    private func configureWatchApp() {
        // Ensure shared components are initialized
        _ = GameSettings.shared
        _ = BallAssetManager.shared
        
        // Set up watch-specific defaults if needed
        setupWatchDefaults()
        
        #if DEBUG
        print("WatchApp: Initialized with watchOS configuration")
        print("WatchApp: Crown controls gravity: \(crownControlsGravity)")
        print("WatchApp: Available ball types: \(BallAssetManager.shared.availableBallTypes.count)")
        print("WatchApp: Bundle ID: \(Bundle.main.bundleIdentifier ?? "unknown")")
        print("WatchApp: App version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "unknown")")
        #endif
    }
    
    /**
     * Sets up watch-specific default preferences
     */
    private func setupWatchDefaults() {
        // On Apple Watch, we might want different defaults for better visibility
        let settings = GameSettings.shared
        
        // Ensure walls are enabled by default on watch for better gameplay
        if !hasSetInitialWatchDefaults() {
            settings.wallsEnabled = true
            
            // Use a slightly larger ball size for better visibility on small screen
            if settings.ballSize < 1.2 {
                settings.ballSize = 1.2
            }
            
            // Mark that we've set initial defaults
            UserDefaults.standard.set(true, forKey: "watchAppInitialDefaultsSet")
        }
    }
    
    /**
     * Checks if we've already set initial watch-specific defaults
     */
    private func hasSetInitialWatchDefaults() -> Bool {
        return UserDefaults.standard.bool(forKey: "watchAppInitialDefaultsSet")
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    WatchContentView()
        .environment(GameSettings.shared)
}
#endif