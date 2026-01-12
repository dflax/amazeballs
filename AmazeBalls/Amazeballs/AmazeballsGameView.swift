//
//  AmazeballsGameView.swift
//  Amazeballs
//
//  Created by Daniel Flax on 11/15/25.
//

import SwiftUI
import SpriteKit

/**
 * Main game view that combines the physics scene with UI controls
 * 
 * This view demonstrates how to integrate the BallPhysicsScene with
 * the rest of your Amazeballs app, including settings controls and
 * ball selection.
 */
struct AmazeballsGameView: View {
    
    // MARK: - Properties
    
    @Bindable var gameSettings = GameSettings.shared
    @State private var ballAssetManager = BallAssetManager.shared
    @State private var showingSettings = false
    @State private var showingBallSelection = false
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Physics Scene Background
            BallPhysicsView(gameSettings: gameSettings)
                .ignoresSafeArea()
            
            // UI Overlay
            VStack {
                // Top Controls
                topControlsOverlay
                
                Spacer()
                
                // Bottom Controls
                bottomControlsOverlay
            }
            .padding()
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showingBallSelection) {
            NavigationView {
                BallSelectionView(gameSettings: gameSettings)
            }
        }
    }
    
    // MARK: - UI Components
    
    /**
     * Top controls overlay with game information and settings
     */
    private var topControlsOverlay: some View {
        HStack {
            // Current ball indicator
            currentBallIndicator
            
            Spacer()
            
            // Settings button
            Button(action: { showingSettings = true }) {
                Image(systemName: "gearshape.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Color.black.opacity(0.3))
                    .clipShape(Circle())
            }
            .accessibilityLabel("Settings")
        }
    }
    
    /**
     * Current ball type indicator
     */
    private var currentBallIndicator: some View {
        HStack(spacing: 8) {
            // Ball image or icon
            if let ballType = gameSettings.selectedBallType {
                ballAssetManager.ballImageView(for: ballType)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 32, height: 32)
            } else {
                Image(systemName: "questionmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.white)
            }
            
            // Ball type text
            VStack(alignment: .leading, spacing: 2) {
                Text("Ball Type")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                
                Text(currentBallDisplayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
            }
        }
        .padding(12)
        .background(Color.black.opacity(0.3))
        .cornerRadius(12)
        .onTapGesture {
            showingBallSelection = true
        }
        .accessibilityLabel("Current ball type: \(currentBallDisplayName)")
        .accessibilityHint("Tap to change ball type")
    }
    
    /**
     * Bottom controls with physics settings
     */
    private var bottomControlsOverlay: some View {
        VStack(spacing: 16) {
            // Quick physics controls
            physicsControlsRow
            
            // Action buttons
            actionButtonsRow
        }
    }
    
    /**
     * Quick physics controls (gravity, bounciness, walls)
     */
    private var physicsControlsRow: some View {
        HStack(spacing: 20) {
            // Gravity control
            QuickSettingControl(
                icon: "arrow.down.circle.fill",
                label: "Gravity",
                value: gameSettings.gravityPercentage,
                range: 0...100,
                binding: $gameSettings.gravityPercentage
            )
            
            // Bounciness control
            QuickSettingControl(
                icon: "bounce.up.right",
                label: "Bounce",
                value: gameSettings.bouncinessPercentage,
                range: 0...100,
                binding: $gameSettings.bouncinessPercentage
            )
            
            // Walls toggle
            QuickToggleControl(
                icon: "square.3.layers.3d.top.filled",
                label: "Walls",
                isOn: $gameSettings.wallsEnabled
            )
            
            // Accelerometer toggle (only on supported platforms)
            if gameSettings.isAccelerometerSupported {
                QuickToggleControl(
                    icon: "gyroscope",
                    label: "Motion",
                    isOn: $gameSettings.accelerometerEnabled
                )
            }
        }
        .padding(16)
        .background(Color.black.opacity(0.3))
        .cornerRadius(16)
    }
    
    /**
     * Action buttons row
     */
    private var actionButtonsRow: some View {
        HStack(spacing: 16) {
            // Clear all balls button
            ActionButton(
                icon: "trash.fill",
                label: "Clear All",
                color: .red
            ) {
                clearAllBalls()
            }
            
            // Random ball button
            ActionButton(
                icon: "shuffle",
                label: "Random Ball",
                color: .blue
            ) {
                gameSettings.selectRandomBallType()
            }
            
            // Reset settings button
            ActionButton(
                icon: "arrow.counterclockwise",
                label: "Reset",
                color: .orange
            ) {
                gameSettings.reset()
            }
        }
    }
    
    // MARK: - Computed Properties
    
    /**
     * Display name for the current ball type
     */
    private var currentBallDisplayName: String {
        if let ballType = gameSettings.selectedBallType {
            return ballAssetManager.displayName(for: ballType)
        } else {
            return "Random"
        }
    }
    
    // MARK: - Actions
    
    /**
     * Clears all balls from the physics scene
     */
    private func clearAllBalls() {
        // This would need to be implemented by accessing the scene
        // For now, we'll trigger this through a notification or delegate pattern
        NotificationCenter.default.post(name: .clearAllBallsNotification, object: nil)
    }
}

// MARK: - Supporting Views

/**
 * Quick setting control with slider
 */
private struct QuickSettingControl: View {
    let icon: String
    let label: String
    let value: Double
    let range: ClosedRange<Double>
    let binding: Binding<Double>
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
            
            Slider(
                value: binding,
                in: range
            ) {
                Text(label)
            } minimumValueLabel: {
                Text("0")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.6))
            } maximumValueLabel: {
                Text("100")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.6))
            }
            .accentColor(.white)
            .frame(width: 60)
            
            Text("\(Int(value))")
                .font(.caption2)
                .foregroundColor(.white)
                .fontWeight(.medium)
        }
        .frame(width: 80)
    }
}

/**
 * Quick toggle control
 */
private struct QuickToggleControl: View {
    let icon: String
    let label: String
    let isOn: Binding<Bool>
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(isOn.wrappedValue ? .green : .white.opacity(0.5))
            
            Text(label)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
            
            Toggle("", isOn: isOn)
                .toggleStyle(SwitchToggleStyle(tint: .green))
                .scaleEffect(0.8)
        }
        .frame(width: 60)
    }
}

/**
 * Action button
 */
private struct ActionButton: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title2)
                
                Text(label)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(color.opacity(0.8))
            .cornerRadius(12)
        }
        .accessibilityLabel(label)
    }
}

// MARK: - Notifications

extension Notification.Name {
    static let clearAllBallsNotification = Notification.Name("clearAllBalls")
}

// MARK: - Preview

#Preview {
    AmazeballsGameView()
}