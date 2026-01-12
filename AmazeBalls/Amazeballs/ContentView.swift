//
//  ContentView.swift
//  Amazeballs
//
//  Created by Daniel Flax on 11/15/25.
//

import SwiftUI

/**
 * ContentView
 *
 * The main interface for the Amazeballs physics game that adapts to different platforms:
 * - On iPhone: Full-screen physics game interface
 * - On iPad/macOS: Navigation split view with sidebar and game area
 *
 * ## Features
 * - Platform-adaptive layout
 * - Full-screen physics simulation on iPhone
 * - Navigation-based interface on larger screens
 * - Modern iOS design patterns
 */
struct ContentView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @State private var showingSettings = false
    @State private var gameSettings = GameSettings.shared

    var body: some View {
        #if os(macOS)
        // macOS: Native Mac interface with menus, toolbar, and popovers
        macOSInterface
        #else
        // iOS/iPadOS: Use different layouts based on screen size
        if horizontalSizeClass == .compact {
            // iPhone: Full-screen game interface
            fullScreenGameInterface
        } else {
            // iPad: Navigation split view
            navigationSplitViewInterface
        }
        #endif
    }
    
    // MARK: - macOS Interface
    
    #if os(macOS)
    /**
     * Native macOS interface with proper menu bar integration
     */
    private var macOSInterface: some View {
        // Use the macOS-specific main view
        MacOSMainView()
    }
    #endif
    
    // MARK: - Full-Screen Game Interface (iPhone)
    
    /**
     * Full-screen physics game interface optimized for iPhone
     */
    private var fullScreenGameInterface: some View {
        ZStack {
            // Full-screen physics scene
            SpriteKitSceneView(settings: gameSettings)
                .ignoresSafeArea(.all)
                .accessibilityLabel("Physics simulation")
                .accessibilityHint("Tap anywhere to drop a ball")
            
            // Floating overlay controls
            overlayControls
        }
        .preferredColorScheme(.dark)
        #if os(iOS)
        .statusBarHidden()
        #endif
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }
    
    /**
     * Floating overlay controls for iPhone interface
     */
    private var overlayControls: some View {
        VStack {
            // Top controls
            HStack {
                Spacer()
                settingsButton
            }
            .padding(.horizontal, 20)
            .padding(.top, 50)
            
            Spacer()
        }
    }
    
    /**
     * Settings button for iPhone interface
     */
    private var settingsButton: some View {
        Button(action: { showingSettings = true }) {
            Image(systemName: "gearshape.fill")
                .font(.title2)
                .foregroundStyle(.primary)
                .frame(width: 44, height: 44)
                .background(.regularMaterial, in: Circle())
                .contentShape(Circle())
        }
        .accessibilityLabel("Settings")
        .accessibilityHint("Tap to open physics settings")
    }
    
    // MARK: - Navigation Split View Interface (iPad)
    
    /**
     * Navigation-based interface for iPad
     */
    private var navigationSplitViewInterface: some View {
        NavigationSplitView {
            List {
                // Game Section
                Section("Game") {
                    NavigationLink(destination: EmbeddedGameView(gameSettings: gameSettings)) {
                        Label("Play Amazeballs", systemImage: "play.circle.fill")
                    }
                    
                    NavigationLink(destination: SettingsView()) {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
                }
                
                // Quick Stats Section
                Section("Current Settings") {
                    HStack {
                        Label("Gravity", systemImage: "arrow.down")
                        Spacer()
                        Text("\(gameSettings.gravity, specifier: "%.1f")×")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Label("Bounciness", systemImage: "arrow.up.bounce")
                        Spacer()
                        Text("\(Int(gameSettings.bounciness * 100))%")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Label("Walls", systemImage: gameSettings.wallsEnabled ? "square.3.layers.3d.top.filled" : "square.3.layers.3d")
                        Spacer()
                        Text(gameSettings.wallsEnabled ? "Enabled" : "Disabled")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Label("Ball Type", systemImage: "volleyball.fill")
                        Spacer()
                        Text(gameSettings.selectedBallType ?? "Random")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            #if os(macOS)
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
            #endif
            .navigationTitle("Amazeballs")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingSettings = true }) {
                        Label("Settings", systemImage: "gearshape")
                    }
                }
            }
        } detail: {
            WelcomeView(gameSettings: gameSettings)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }
}

// MARK: - Welcome View

/**
 * Welcome view for iPad detail pane
 */
private struct WelcomeView: View {
    @Bindable var gameSettings: GameSettings
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // App Icon/Logo
            Image(systemName: "tennis.racket")
                .font(.system(size: 80))
                .foregroundStyle(.blue.gradient)
                .shadow(color: .blue.opacity(0.3), radius: 10)
            
            // Welcome Text
            VStack(spacing: 16) {
                Text("Welcome to Amazeballs!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("A physics-based ball simulation game")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // Quick Start Guide
            VStack(alignment: .leading, spacing: 12) {
                Text("Get Started:")
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                HStack(spacing: 12) {
                    Image(systemName: "1.circle.fill")
                        .foregroundStyle(.blue)
                        .font(.title3)
                    Text("Tap \"Play Amazeballs\" in the sidebar")
                }
                
                HStack(spacing: 12) {
                    Image(systemName: "2.circle.fill")
                        .foregroundStyle(.blue)
                        .font(.title3)
                    Text("Tap anywhere to drop balls")
                }
                
                HStack(spacing: 12) {
                    Image(systemName: "3.circle.fill")
                        .foregroundStyle(.blue)
                        .font(.title3)
                    Text("Adjust physics in Settings")
                }
            }
            .padding(20)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 12))
            
            // Current Settings Summary
            VStack(alignment: .leading, spacing: 8) {
                Text("Current Physics Settings:")
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                HStack {
                    Text("Gravity:")
                    Spacer()
                    Text("\(gameSettings.gravity, specifier: "%.1f")×")
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    Text("Bounciness:")
                    Spacer()
                    Text("\(Int(gameSettings.bounciness * 100))%")
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    Text("Walls:")
                    Spacer()
                    Text(gameSettings.wallsEnabled ? "Enabled" : "Disabled")
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    Text("Ball Type:")
                    Spacer()
                    Text(gameSettings.selectedBallType ?? "Random")
                        .foregroundStyle(.secondary)
                }
                
                if gameSettings.isAccelerometerSupported {
                    HStack {
                        Text("Device Motion:")
                        Spacer()
                        Text(gameSettings.accelerometerEnabled ? "Enabled" : "Disabled")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .font(.body)
            .padding(20)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 12))
            
            Spacer()
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(white: 0.95))
    }
}

// MARK: - Embedded Game View for Navigation Interface

/**
 * Game view embedded in navigation interface for iPad
 */
private struct EmbeddedGameView: View {
    @Bindable var gameSettings: GameSettings
    @State private var showingSettings = false
    
    var body: some View {
        ZStack {
            // Physics scene
            SpriteKitSceneView(settings: gameSettings)
                .ignoresSafeArea()
            
            // Toolbar overlay
            VStack {
                HStack {
                    Spacer()
                    
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gearshape.fill")
                            .font(.title3)
                            .foregroundStyle(.primary)
                            .frame(width: 44, height: 44)
                            .background(.regularMaterial, in: Circle())
                            .contentShape(Circle())
                    }
                    .accessibilityLabel("Settings")
                }
                .padding()
                
                Spacer()
            }
        }
        .navigationTitle("Play Amazeballs")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }
}

// MARK: - Preview

#Preview("ContentView") {
    ContentView()
        .preferredColorScheme(.dark)
}

#Preview("Welcome View") {
    WelcomeView(gameSettings: GameSettings.shared)
        .preferredColorScheme(.dark)
}
