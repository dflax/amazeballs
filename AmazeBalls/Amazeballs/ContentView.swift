//
//  ContentView.swift
//  Amazeballs
//
//  Created by Daniel Flax on 11/15/25.
//

import SwiftUI
import SwiftData

/**
 * ContentView
 *
 * The main interface for the Amazeballs app that adapts to different platforms:
 * - On iPhone: Full-screen physics game interface
 * - On iPad/macOS: Navigation split view with sidebar and game area
 *
 * ## Features
 * - Platform-adaptive layout
 * - Full-screen physics simulation on iPhone
 * - Navigation-based interface on larger screens
 * - SwiftData integration for data management
 * - Modern iOS design patterns
 */
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Query private var items: [Item]
    
    @State private var showingSettings = false
    @State private var gameSettings = GameSettings.shared
    @State private var showingFullScreenGame = false

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
        .sheet(isPresented: $showingBallPicker) {
            BallPickerSheet(gameSettings: gameSettings)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }
    
    // State for full-screen interface
    @State private var showingBallPicker = false
    
    /**
     * Floating overlay controls for iPhone interface
     */
    private var overlayControls: some View {
        VStack {
            // Top controls
            HStack {
                ballPickerButton
                Spacer()
                settingsButton
            }
            .padding(.horizontal, 20)
            .padding(.top, 50)
            
            Spacer()
        }
    }
    
    /**
     * Ball picker button showing current selection
     */
    private var ballPickerButton: some View {
        Button(action: { showingBallPicker = true }) {
            HStack(spacing: 12) {
                // Ball image or random icon
                if let ballType = gameSettings.selectedBallType {
                    BallAssetManager.shared.ballImageView(for: ballType)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 32, height: 32)
                } else {
                    Image(systemName: "questionmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                        .frame(width: 32, height: 32)
                }
                
                // Ball name
                VStack(alignment: .leading, spacing: 2) {
                    Text("Ball")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    
                    Text(currentBallDisplayName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(1)
                }
                .foregroundStyle(.primary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
            .contentShape(RoundedRectangle(cornerRadius: 16))
        }
        .accessibilityLabel("Ball selection")
        .accessibilityValue(currentBallDisplayName)
        .accessibilityHint("Tap to choose a different ball type")
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
    
    /**
     * Display name for current ball selection
     */
    private var currentBallDisplayName: String {
        if let ballType = gameSettings.selectedBallType {
            return BallAssetManager.shared.displayName(for: ballType)
        } else {
            return "Random"
        }
    }
    
    // MARK: - Navigation Split View Interface (iPad/macOS)
    
    /**
     * Navigation-based interface for iPad and macOS
     */
    private var navigationSplitViewInterface: some View {
        NavigationSplitView {
            List {
                // Game Settings Section
                Section("Game") {
                    NavigationLink(destination: SettingsView()) {
                        Label("Settings", systemImage: "gearshape")
                    }
                    
                    NavigationLink(destination: EmbeddedGameView(gameSettings: gameSettings)) {
                        Label("Play Amazeballs", systemImage: "play.circle")
                    }
                }
                
                // Data Management Section  
                Section("Data") {
                    ForEach(items) { item in
                        NavigationLink {
                            Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
                        } label: {
                            Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
            }
#if os(macOS)
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
#endif
            .navigationTitle("Amazeballs")
            .toolbar {
#if os(iOS)
                ToolbarItem(placement: {
                    #if os(macOS)
                        .primaryAction
                    #else
                        .navigationBarTrailing
                    #endif
                }()) {
                    EditButton()
                }
#endif
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingSettings = true }) {
                        Label("Settings", systemImage: "gearshape")
                    }
                }
            }
        } detail: {
            VStack(spacing: 20) {
                Image(systemName: "tennis.racket")
                    .font(.system(size: 60))
                    .foregroundColor(.accentColor)
                
                Text("Welcome to Amazeballs!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Select an option from the sidebar to get started.")
                    .foregroundColor(.secondary)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Current Settings:")
                        .font(.headline)
                    
                    Text("Gravity: \(gameSettings.gravity, specifier: "%.1f")x")
                    Text("Bounciness: \(Int(gameSettings.bounciness * 100))%")
                    Text("Walls: \(gameSettings.wallsEnabled ? "Enabled" : "Disabled")")
                    
                    if gameSettings.isAccelerometerSupported {
                        Text("Motion: \(gameSettings.accelerometerEnabled ? "Enabled" : "Disabled")")
                    }
                    
                    Text("Ball Type: \(gameSettings.selectedBallType ?? "Random")")
                }
                .font(.caption)
                .foregroundColor(.secondary)
                .padding()
                .background {
                    #if os(macOS)
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(NSColor.controlBackgroundColor))
                    #else
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray6))
                    #endif
                }
            }
            .padding()
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }

    // MARK: - SwiftData Methods
    
    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

// MARK: - Embedded Game View for Navigation Interface

/**
 * Game view embedded in navigation interface for iPad/macOS
 */
private struct EmbeddedGameView: View {
    @Bindable var gameSettings: GameSettings
    @State private var showingBallPicker = false
    @State private var showingSettings = false
    
    var body: some View {
        ZStack {
            // Physics scene
            SpriteKitSceneView(settings: gameSettings)
                .ignoresSafeArea()
            
            // Toolbar overlay
            VStack {
                HStack {
                    Button(action: { showingBallPicker = true }) {
                        HStack(spacing: 8) {
                            if let ballType = gameSettings.selectedBallType {
                                BallAssetManager.shared.ballImageView(for: ballType)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 24)
                            } else {
                                Image(systemName: "questionmark.circle")
                                    .frame(width: 24, height: 24)
                            }
                            
                            Text(gameSettings.selectedBallType ?? "Random")
                                .font(.caption)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(.regularMaterial, in: Capsule())
                    }
                    
                    Spacer()
                    
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gearshape")
                            .frame(width: 32, height: 32)
                            .background(.regularMaterial, in: Circle())
                    }
                }
                .padding()
                
                Spacer()
            }
        }
        .navigationTitle("Play Amazeballs")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .sheet(isPresented: $showingBallPicker) {
            BallPickerSheet(gameSettings: gameSettings)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
