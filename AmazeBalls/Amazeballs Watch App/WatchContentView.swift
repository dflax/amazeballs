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
    @State private var lastTapTime = Date()
    @State private var tapCount = 0
    @State private var debugLines: [String] = []
    @State private var ballsCount: Int = 0
    
    @GestureState private var isPressing: Bool = false
    
    @State private var previewTimer: Timer? = nil
    @State private var previewStartDate: Date? = nil
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Main physics simulation (WatchSpriteKitSceneView)
            physicsSimulationView
            
            // Debug overlay (visible in DEBUG builds)
            #if DEBUG
            VStack { Spacer() }
                .overlay(alignment: .bottomLeading) {
                    WatchDebugOverlay(lines: debugLines, tapCount: tapCount, ballsCount: ballsCount)
                        .padding(6)
                }
            #endif
        }
        .sheet(isPresented: $showingQuickSettings) {
            WatchQuickSettingsView(crownControlsGravity: $crownControlsGravity)
                .environment(gameSettings)
        }
    }
    
    // MARK: - Physics Simulation View
    
    private var physicsSimulationView: some View {
        WatchSpriteKitSceneView() // wallsEnabled binding removed to match initializer; use environment or supported API
            .gesture(
                LongPressGesture(minimumDuration: 0.25, maximumDistance: 5)
                    .updating($isPressing) { value, state, _ in
                        state = value
                    }
                    .onChanged { _ in
                        // Begin preview at center
                        let center = CGPoint(x: WKInterfaceDevice.current().screenBounds.midX, y: WKInterfaceDevice.current().screenBounds.midY)
                        NotificationCenter.default.post(name: .watchBeginPreview, object: center)
                        // Start growth loop
                        startPreviewGrowthTimer()
                        #if DEBUG
                        print("WatchContentView: Long press began -> beginPreview + start timer")
                        #endif
                    }
                    .onEnded { _ in
                        stopPreviewGrowthTimer()
                        NotificationCenter.default.post(name: .watchCommitPreview, object: nil)
                        WKInterfaceDevice.current().play(.click)
                        #if DEBUG
                        print("WatchContentView: Long press ended -> commitPreview + stop timer")
                        #endif
                    }
            )
    }
    
    // MARK: - Interaction Handlers
    
    /**
     * Handles single tap gesture - drops a ball or toggles walls
     */
    private func handleSingleTap() {
        tapCount += 1
        log("Tap #\(tapCount)")
        
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
        
        log("Double-tap: Walls -> \(gameSettings.wallsEnabled ? "ON" : "OFF")")
        
        // Show visual feedback
        // NOTE: Showing wall toggle overlay removed per instructions
        
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
        // Haptic feedback
        WKInterfaceDevice.current().play(.click)
        // Update counters/logs (until SpriteKit scene integration on watch)
        ballsCount += 1
        log("Ball drop requested. total=\(ballsCount)")
        #if DEBUG
        print("WatchContentView: Ball dropped at center (overlay count=\(ballsCount))")
        #endif
    }
    
    /**
     * Appends a debug line to the in-app overlay (ring buffer)
     */
    private func log(_ message: String) {
        let line = message
        debugLines.append(line)
        if debugLines.count > 40 {
            debugLines.removeFirst(debugLines.count - 40)
        }
    }
    
    private func startPreviewGrowthTimer() {
        previewStartDate = Date()
        stopPreviewGrowthTimer()
        previewTimer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { _ in
            guard let start = previewStartDate else { return }
            let elapsed = Date().timeIntervalSince(start)
            let duration: TimeInterval = 2.0 // match phone growth duration
            let progress = max(0.0, min(1.0, elapsed / duration))
            NotificationCenter.default.post(name: .watchUpdatePreview, object: CGFloat(progress))
            if progress >= 1.0 {
                stopPreviewGrowthTimer()
            }
        }
        RunLoop.main.add(previewTimer!, forMode: .common)
    }

    private func stopPreviewGrowthTimer() {
        previewTimer?.invalidate()
        previewTimer = nil
        previewStartDate = nil
    }
}

/// Lightweight on-screen debug overlay for watchOS
private struct WatchDebugOverlay: View {
    let lines: [String]
    let tapCount: Int
    let ballsCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                Text("Taps: \(tapCount)")
                Text("Balls: \(ballsCount)")
            }
            .font(.system(size: 12, weight: .semibold))
            .padding(4)
            .background(.black.opacity(0.35), in: RoundedRectangle(cornerRadius: 6))
            ForEach(lines.suffix(5), id: \.self) { line in
                Text(line)
                    .font(.system(size: 10, weight: .regular, design: .monospaced))
                    .lineLimit(1)
            }
        }
        .foregroundStyle(.white)
        .padding(4)
        .background(.black.opacity(0.25), in: RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let watchBeginPreview = Notification.Name("watchBeginPreview")
    static let watchUpdatePreview = Notification.Name("watchUpdatePreview")
    static let watchCommitPreview = Notification.Name("watchCommitPreview")
}

// MARK: - Preview

#if DEBUG
#Preview {
    WatchContentView()
        .environment(GameSettings.shared)
}
#endif

