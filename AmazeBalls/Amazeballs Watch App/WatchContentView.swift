//
//  WatchContentView.swift
//  Amazeballs Watch App
//
//  Created by Daniel Flax on 11/17/25.
//

import SwiftUI
import WatchKit

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
    
    @Environment(GameSettings.self) private var gameSettings
    @AppStorage("watchCrownControlsGravity") private var crownControlsGravity = true
    
    @State private var showingQuickSettings = false
    @State private var tapCount = 0
    @State private var ballsCount: Int = 0
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Main physics simulation (WatchSpriteKitSceneView)
            physicsSimulationView
            
            // Debug overlay (visible in DEBUG builds)
            #if DEBUG
            Color.clear
                .overlay(alignment: .bottomLeading) {
                    WatchDebugOverlay(tapCount: tapCount, ballsCount: ballsCount)
                        .padding(6)
                }
                .allowsHitTesting(false)
                .focusable(false)
            #endif
        }
        .focusable(false)
        // TEMP: Quick settings disabled to test Digital Crown indicator
//        .sheet(isPresented: $showingQuickSettings) {
//            WatchQuickSettingsView(crownControlsGravity: $crownControlsGravity)
//                .environment(gameSettings)
//        }
    }
    
    // MARK: - Physics Simulation View
    
    private var physicsSimulationView: some View {
        WatchSpriteKitSceneView()
            .focusable(false)
            .onReceive(NotificationCenter.default.publisher(for: .watchBallDropped)) { note in
                // Update counter when scene confirms a ball was dropped
                // Scene sends the current ball count
                if let count = note.object as? Int {
                    ballsCount = count
                }
            }
            .onTapGesture {
                // Increment tap count
                tapCount += 1
                
                // Drop ball at center
                let center = CGPoint(x: WKInterfaceDevice.current().screenBounds.midX, y: WKInterfaceDevice.current().screenBounds.midY)
                NotificationCenter.default.post(name: .watchDropBall, object: center)
                
                // Haptic feedback
                WKInterfaceDevice.current().play(.click)
                
                #if DEBUG
                print("WatchContentView: Tap -> drop ball at center")
                #endif
            }
    }
    
    // MARK: - Interaction Handlers
}

/// Lightweight on-screen debug overlay for watchOS
private struct WatchDebugOverlay: View {
    let tapCount: Int
    let ballsCount: Int

    var body: some View {
        HStack(spacing: 8) {
            Text("Taps: \(tapCount)")
            Text("Balls: \(ballsCount)")
        }
        .font(.system(size: 12, weight: .semibold))
        .padding(6)
        .fixedSize()
        .foregroundStyle(.white)
        .background(.black.opacity(0.35), in: RoundedRectangle(cornerRadius: 6))
        .focusable(false)
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let watchDropBall = Notification.Name("watchDropBall")
    static let watchBallDropped = Notification.Name("watchBallDropped")
}

// MARK: - Preview

#if DEBUG
#Preview {
    WatchContentView()
        .environment(GameSettings.shared)
}
#endif

