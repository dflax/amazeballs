//
//  WatchContentView.swift
//  Amazeballs Watch App
//
//  Created by Daniel Flax on 11/17/25.
//

import SwiftUI

/**
 * WatchContentView
 *
 * The main content view for the Amazeballs watchOS app.
 * Displays the physics simulation with watch-optimized controls.
 *
 * ## Controls
 * - Single tap: Drop ball
 * - Double tap: Toggle walls
 * - Digital Crown: Adjust gravity or bounciness
 * - Long press: Show quick settings overlay
 *
 * ## Layout
 * - Full-screen physics simulation
 * - Minimal overlay indicators
 * - Crown control indicator
 * - Walls status indicator
 */
struct WatchContentView: View {
    
    // MARK: - Environment & State
    
    @EnvironmentObject private var gameSettings: GameSettings
    @AppStorage("watchCrownControlsGravity") private var crownControlsGravity = true
    
    @State private var showingQuickSettings = false
    @State private var lastTapTime = Date()
    @State private var tapCount = 0
    
    // Digital Crown tracking
    @State private var crownValue: Double = 0.0
    @State private var isAdjustingWithCrown = false
    
    // Animation states
    @State private var showingWallToggle = false
    @State private var showingCrownIndicator = false
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Main physics simulation (placeholder for now)
            physicsSimulationView
            
            // Overlay indicators
            overlayIndicators
            
            // Quick settings sheet
            .sheet(isPresented: $showingQuickSettings) {
                WatchQuickSettingsView(crownControlsGravity: $crownControlsGravity)
                    .environmentObject(gameSettings)
            }
        }
        .focusable(true)
        .digitalCrownRotation(
            $crownValue,
            from: crownControlsGravity ? 0.0 : 0.0,
            through: crownControlsGravity ? 2.0 : 1.0,
            by: 0.05,
            sensitivity: .medium,
            isContinuous: false,
            isHapticFeedbackEnabled: true
        )
        .onTapGesture(count: 1) {
            handleSingleTap()
        }
        .onLongPressGesture(minimumDuration: 1.0) {
            showingQuickSettings = true
        }
        .onChange(of: crownValue) { _, newValue in
            handleCrownValueChange(newValue)
        }
        .onAppear {
            initializeCrownValue()
        }
    }
    
    // MARK: - Physics Simulation View
    
    /**
     * Placeholder for the physics simulation
     * In a full implementation, this would contain SpriteKit or similar
     */
    private var physicsSimulationView: some View {
        Rectangle()
            .fill(.black)
            .overlay {
                // Simple visual feedback for demo purposes
                VStack {
                    Text("🏀")
                        .font(.system(size: 40))
                        .scaleEffect(gameSettings.ballSize)
                    
                    Spacer()
                    
                    Text("Tap to drop balls")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
    }
    
    // MARK: - Overlay Indicators
    
    /**
     * Status indicators overlaid on the physics simulation
     */
    private var overlayIndicators: some View {
        VStack {
            HStack {
                // Crown control indicator
                crownControlIndicator
                
                Spacer()
                
                // Walls status indicator
                wallsStatusIndicator
            }
            .padding(.horizontal, 8)
            .padding(.top, 4)
            
            Spacer()
            
            // Bottom status bar
            bottomStatusBar
        }
    }
    
    /**
     * Shows what the Digital Crown currently controls
     */
    private var crownControlIndicator: some View {
        HStack(spacing: 2) {
            Image(systemName: "crown.fill")
                .font(.caption2)
                .foregroundStyle(.orange)
            
            Text(crownControlsGravity ? "G" : "B")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(.regularMaterial, in: Capsule())
        .opacity(showingCrownIndicator ? 1.0 : 0.3)
        .scaleEffect(showingCrownIndicator ? 1.1 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: showingCrownIndicator)
    }
    
    /**
     * Shows current walls status
     */
    private var wallsStatusIndicator: some View {
        HStack(spacing: 2) {
            Image(systemName: gameSettings.wallsEnabled ? "rectangle" : "rectangle.dashed")
                .font(.caption2)
                .foregroundStyle(gameSettings.wallsEnabled ? .green : .gray)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(.regularMaterial, in: Capsule())
        .opacity(showingWallToggle ? 1.0 : 0.3)
        .scaleEffect(showingWallToggle ? 1.1 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: showingWallToggle)
    }
    
    /**
     * Bottom status bar with current values
     */
    private var bottomStatusBar: some View {
        HStack {
            // Gravity indicator
            HStack(spacing: 2) {
                Image(systemName: "arrow.down")
                    .font(.caption2)
                Text(String(format: "%.1f", gameSettings.gravity))
                    .font(.caption2)
                    .fontWeight(.medium)
            }
            .foregroundStyle(crownControlsGravity ? .orange : .secondary)
            
            Spacer()
            
            // Bounciness indicator
            HStack(spacing: 2) {
                Image(systemName: "arrow.up.bounce")
                    .font(.caption2)
                Text(String(format: "%.1f", gameSettings.bounciness))
                    .font(.caption2)
                    .fontWeight(.medium)
            }
            .foregroundStyle(!crownControlsGravity ? .orange : .secondary)
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 4)
        .background(.regularMaterial.opacity(0.8))
    }
    
    // MARK: - Interaction Handlers
    
    /**
     * Handles single tap gesture - drops a ball or toggles walls
     */
    private func handleSingleTap() {
        let now = Date()
        
        // Check for double-tap (within 0.3 seconds)
        if now.timeIntervalSince(lastTapTime) < 0.3 {
            // Double tap - toggle walls
            handleDoubleTap()
        } else {
            // Single tap - drop ball (in a real implementation)
            handleBallDrop()
        }
        
        lastTapTime = now
    }
    
    /**
     * Handles double-tap gesture - toggles walls
     */
    private func handleDoubleTap() {
        gameSettings.wallsEnabled.toggle()
        
        // Show visual feedback
        showingWallToggle = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            showingWallToggle = false
        }
        
        // Haptic feedback
        WKInterfaceDevice.current().play(.click)
        
        #if DEBUG
        print("WatchContentView: Walls toggled to \(gameSettings.wallsEnabled)")
        #endif
    }
    
    /**
     * Handles ball drop (placeholder for physics implementation)
     */
    private func handleBallDrop() {
        // In a real implementation, this would add a ball to the physics simulation
        
        // Haptic feedback
        WKInterfaceDevice.current().play(.click)
        
        #if DEBUG
        print("WatchContentView: Ball dropped at center")
        #endif
    }
    
    /**
     * Handles Digital Crown value changes
     */
    private func handleCrownValueChange(_ newValue: Double) {
        isAdjustingWithCrown = true
        
        if crownControlsGravity {
            gameSettings.gravity = newValue
        } else {
            gameSettings.bounciness = newValue
        }
        
        // Show crown indicator
        showingCrownIndicator = true
        
        // Hide indicator after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showingCrownIndicator = false
            isAdjustingWithCrown = false
        }
    }
    
    /**
     * Initializes the Digital Crown value based on current settings
     */
    private func initializeCrownValue() {
        if crownControlsGravity {
            crownValue = gameSettings.gravity
        } else {
            crownValue = gameSettings.bounciness
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    WatchContentView()
        .environmentObject(GameSettings.shared)
}
#endif