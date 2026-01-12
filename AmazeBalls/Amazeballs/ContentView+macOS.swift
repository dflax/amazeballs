//
//  ContentView+macOS.swift
//  Amazeballs
//
//  Created by Daniel Flax on 11/15/25.
//

#if os(macOS)
import SwiftUI

/**
 * ContentView for macOS
 *
 * A native macOS version of the Amazeballs physics simulation that follows
 * macOS Human Interface Guidelines and provides a "Mac-assed Mac app" experience.
 *
 * ## Features
 * - Native macOS window with standard controls
 * - Click-to-drop ball physics simulation
 * - Keyboard shortcuts for all major actions
 * - Settings window with native macOS design
 * - Popover ball picker instead of sheets
 * - Proper mouse/trackpad gesture handling
 *
 * ## Keyboard Shortcuts (via toolbar and menu)
 * - **⌘W**: Toggle Walls
 * - **⌘,**: Settings Window (ball picker now accessible within settings)
 *
 * ## Menu Integration
 * Menu bar commands are implemented in `MacOSCommands.swift` and should be
 * added to the App file using `.commands { AmazeballsMacOSCommands() }`
 *
 * ## Menu Structure (when commands are added)
 * - File: New, Close, standard macOS file operations
 * - Edit: Standard edit menu including "Clear All Balls"
 * - View: Ball picker, walls toggle, accelerometer toggle, reset physics
 * - Window: Standard window menu
 * - Help: About Amazeballs
 */
struct MacOSMainView: View {
    @State private var gameSettings = GameSettings.shared
    @State private var ballAssetManager = BallAssetManager.shared
    
    // Window management
    @State private var windowTitle = "Amazeballs"
    @State private var isTiltActive: Bool = false
    
    var body: some View {
        ZStack {
            // Main physics scene
            physicsSceneView
            
            // Overlay controls (minimal for macOS)
            overlayControls
        }
        .frame(minWidth: 800, minHeight: 600)
        .navigationTitle(windowTitle)
        .toolbar {
            macOSToolbar
        }
        .onAppear {
            setupMacOSWindow()
            setupNotificationObservers()
            NotificationCenter.default.addObserver(forName: .tiltDidChange, object: nil, queue: .main) { note in
                if let angle = note.userInfo?["angle"] as? Double {
                    isTiltActive = abs(angle) > 0.0001
                }
            }
        }
        .onDisappear {
            removeNotificationObservers()
        }
    }
    
    // MARK: - Physics Scene
    
    /**
     * SpriteKit physics scene optimized for macOS
     */
    private var physicsSceneView: some View {
        SpriteKitSceneView(settings: gameSettings)
            .clipped()
            .accessibilityLabel("Physics simulation")
            .accessibilityHint("Click anywhere to drop a ball")
            .background(Color.black)
    }
    
    // MARK: - Overlay Controls
    
    /**
     * Minimal overlay controls for macOS (less intrusive than iOS)
     */
    private var overlayControls: some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                
                // Physics info panel
                physicsInfoPanel
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
    
    /**
     * Physics information panel
     */
    private var physicsInfoPanel: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Gravity")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text("\(gameSettings.gravity, specifier: "%.1f")x")
                    .font(.caption)
                    .fontWeight(.medium)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Bounce")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text("\(Int(gameSettings.bounciness * 100))%")
                    .font(.caption)
                    .fontWeight(.medium)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Walls")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(gameSettings.wallsEnabled ? "On" : "Off")
                    .font(.caption)
                    .fontWeight(.medium)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
    }
    
    // MARK: - Toolbar
    
    /**
     * Native macOS toolbar
     */
    private var macOSToolbar: some ToolbarContent {
        Group {
            ToolbarItem(id: "walls-toggle", placement: .primaryAction) {
                Button(action: toggleWalls) {
                    Label("Walls", systemImage: gameSettings.wallsEnabled ? "square.3.layers.3d.top.filled" : "square.3.layers.3d")
                }
                .keyboardShortcut("w", modifiers: .command)
                .help("Toggle boundary walls (⌘W)")
            }
            if isTiltActive {
                ToolbarItem(id: "reset-tilt", placement: .primaryAction) {
                    Button(action: {
                        NotificationCenter.default.post(name: .resetTilt, object: nil)
                    }) {
                        Label("Reset Tilt", systemImage: "macwindow")
                    }
                    .help("Reset tilt to 0°")
                }
            }
        }
    }
    
    // MARK: - Actions
    
    /**
     * Toggles boundary walls
     */
    private func toggleWalls() {
        withAnimation(.easeInOut(duration: 0.2)) {
            gameSettings.wallsEnabled.toggle()
        }
        
        // Update window title to show current state
        updateWindowTitle()
    }
    
    /**
     * Toggles accelerometer (disabled on macOS)
     */
    private func toggleAccelerometer() {
        // Accelerometer is not supported on macOS, but we keep the command for consistency
        // This will be disabled in the menu
        if gameSettings.isAccelerometerSupported {
            gameSettings.accelerometerEnabled.toggle()
        }
    }
    
    /**
     * Shows ball picker (now handled via settings)
     */
    private func showBallPicker() {
        // No-op: ball picker is accessed via SettingsView now
    }
    
    /**
     * Clears all balls from the scene
     */
    private func clearAllBalls() {
        NotificationCenter.default.post(name: .clearAllBalls, object: nil)
    }
    

    /**
     * Sets up macOS-specific window configuration
     */
    private func setupMacOSWindow() {
        updateWindowTitle()
        
        #if DEBUG
        print("ContentView+macOS: Window setup complete")
        #endif
    }
    
    /**
     * Updates window title with current settings
     */
    private func updateWindowTitle() {
        let wallStatus = gameSettings.wallsEnabled ? "Walls On" : "Walls Off"
        windowTitle = "Amazeballs - \(wallStatus)"
    }
    
    // MARK: - Notification Handling
    
    /**
     * Sets up notification observers for menu commands
     */
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            forName: .showBallPicker,
            object: nil,
            queue: .main
        ) { _ in
            showBallPicker()
        }
        
        NotificationCenter.default.addObserver(
            forName: .toggleWalls,
            object: nil,
            queue: .main
        ) { _ in
            toggleWalls()
        }
        
        NotificationCenter.default.addObserver(
            forName: .toggleAccelerometer,
            object: nil,
            queue: .main
        ) { _ in
            toggleAccelerometer()
        }
        
        NotificationCenter.default.addObserver(
            forName: .resetPhysics,
            object: nil,
            queue: .main
        ) { _ in
            gameSettings.reset()
            updateWindowTitle()
        }
    }
    
    /**
     * Removes notification observers
     */
    private func removeNotificationObservers() {
        NotificationCenter.default.removeObserver(self, name: .showBallPicker, object: nil)
        NotificationCenter.default.removeObserver(self, name: .toggleWalls, object: nil)
        NotificationCenter.default.removeObserver(self, name: .toggleAccelerometer, object: nil)
        NotificationCenter.default.removeObserver(self, name: .resetPhysics, object: nil)
        NotificationCenter.default.removeObserver(self, name: .tiltDidChange, object: nil)
    }
}

// MARK: - macOS Ball Picker Popover

/**
 * Ball picker designed as a native macOS popover
 */
private struct MacOSBallPicker: View {
    @Bindable var gameSettings: GameSettings
    let ballAssetManager: BallAssetManager
    @Environment(\.dismiss) private var dismiss
    
    private let columns = [
        GridItem(.adaptive(minimum: 80, maximum: 100), spacing: 12)
    ]
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            Text("Choose Ball Type")
                .font(.headline)
                .padding(.top, 8)
            
            // Ball grid
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    // Random option
                    MacOSBallCard(
                        ballType: nil,
                        displayName: "Random",
                        imageView: Image(systemName: "questionmark.circle"),
                        isSelected: gameSettings.selectedBallType == nil
                    ) {
                        selectBall(nil)
                    }
                    
                    // Available balls
                    ForEach(ballAssetManager.availableBallTypes, id: \.self) { ballType in
                        MacOSBallCard(
                            ballType: ballType,
                            displayName: ballAssetManager.displayName(for: ballType),
                            imageView: ballAssetManager.ballImageView(for: ballType),
                            isSelected: gameSettings.selectedBallType == ballType
                        ) {
                            selectBall(ballType)
                        }
                    }
                }
            }
            .frame(maxHeight: 200)
            
            // Close button
            HStack {
                Spacer()
                Button("Done") {
                    dismiss()
                }
                .keyboardShortcut(.return)
            }
            .padding(.bottom, 8)
        }
        .padding()
        .frame(width: 300)
    }
    
    private func selectBall(_ ballType: String?) {
        withAnimation(.easeInOut(duration: 0.1)) {
            gameSettings.selectedBallType = ballType
        }
        
        // Auto-dismiss after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            dismiss()
        }
    }
}

/**
 * Individual ball card for macOS popover
 */
private struct MacOSBallCard: View {
    let ballType: String?
    let displayName: String
    let imageView: Image
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 6) {
            imageView
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
            
            Text(displayName)
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(width: 80, height: 80)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? Color.accentColor.opacity(0.2) : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(
                    isSelected ? Color.accentColor : Color.clear,
                    lineWidth: 2
                )
        )
        .contentShape(RoundedRectangle(cornerRadius: 8))
        .onTapGesture { onTap() }
        .accessibilityLabel("\(displayName) ball")
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

#Preview {
    MacOSMainView()
        .frame(width: 900, height: 700)
}

#endif

