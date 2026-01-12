//
//  AmazeballsApp.swift
//  Amazeballs
//
//  Created by Daniel Flax on 11/15/25.
//

import SwiftUI

/**
 * AmazeballsApp
 *
 * The main application entry point for the Amazeballs physics simulation app.
 * Provides a clean, modern iOS experience with full-screen ball physics,
 * intuitive touch controls, and persistent settings via UserDefaults and CloudKit.
 *
 * ## Features
 * - Full-screen physics simulation
 * - Interactive ball dropping with touch/tap
 * - Configurable physics settings
 * - Multiple ball types with visual selection
 * - Device motion support (iOS/iPadOS)
 * - UserDefaults for local persistence with CloudKit sync
 * - Platform-adaptive interface (iPhone vs iPad/macOS)
 * - Modern iOS design patterns
 *
 * ## Requirements
 * - iOS 26.0+ / iPadOS 26.0+ / macOS 26.0+
 * - iPhone, iPad, and Mac support
 * - Portrait and landscape orientations
 * - Dark mode optimized
 * - Optional iCloud account for cross-device sync
 *
 * ## Usage
 * Simply run the app and:
 * 1. On iPhone: Full-screen physics interface
 *    - Tap anywhere to drop balls
 *    - Use ball picker (top-left) to choose ball types
 *    - Use settings (top-right) to adjust physics
 *    - Enable device motion for tilt-based gravity
 * 2. On iPad: Navigation-based interface
 *    - Use sidebar to navigate to game and settings
 *    - Embedded physics simulation in detail view
 *    - Full data management capabilities
 * 3. On macOS: Native Mac app experience
 *    - Native window with standard macOS controls
 *    - Full menu bar integration with keyboard shortcuts
 *    - Click to drop balls with mouse/trackpad
 *    - Popover ball picker and native settings window
 */
@main
struct AmazeballsApp: App {
    
    // MARK: - Scene Configuration

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .onAppear {
                    configureApp()
                }
        }
        #if os(macOS)
        .defaultSize(width: 800, height: 600)
        .windowResizability(.contentSize)
        .windowToolbarStyle(.unified(showsTitle: true))
        #endif
        #if os(macOS)
        Settings {
            SettingsView()
                .preferredColorScheme(.dark)
        }
        #endif
    }
    
    // MARK: - App Configuration
    
    /**
     * Configures global app settings and appearance
     */
    private func configureApp() {
        // Ensure game settings are initialized
        _ = GameSettings.shared
        
        // Ensure ball asset manager is initialized
        _ = BallAssetManager.shared
        
        #if DEBUG
        print("AmazeballsApp: Initialized with debug configuration")
        #endif
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
