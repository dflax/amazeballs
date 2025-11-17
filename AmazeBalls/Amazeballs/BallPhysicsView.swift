//
//  BallPhysicsView.swift
//  Amazeballs
//
//  Created by Daniel Flax on 11/15/25.
//

import SwiftUI
import SpriteKit

/**
 * SwiftUI wrapper for BallPhysicsScene
 * 
 * Provides a SwiftUI-compatible interface for the SpriteKit ball physics scene,
 * with automatic integration with GameSettings and responsive layout.
 */
struct BallPhysicsView: View {
    
    // MARK: - Properties
    
    /// Game settings to observe for physics updates
    @Bindable var gameSettings: GameSettings
    
    /// The SpriteKit scene instance
    @State private var scene: BallPhysicsScene?
    
    /// Whether the scene is ready for interaction
    @State private var isSceneReady = false
    
    /// Current geometry size for scene setup
    @State private var currentGeometry: CGSize = .zero
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // SpriteKit Scene View
                if let scene = scene {
                    SpriteView(scene: scene)
                        .ignoresSafeArea()
                        .clipped()
                } else {
                    // Loading placeholder
                    Color.black
                        .overlay(
                            ProgressView("Loading Physics Scene...")
                                .foregroundColor(.white)
                        )
                }
                
                // Debug overlay (only in debug builds)
                #if DEBUG
                if isSceneReady, let scene = scene {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            DebugInfoView(scene: scene, gameSettings: gameSettings)
                                .padding()
                        }
                    }
                }
                #endif
            }
            .onAppear {
                currentGeometry = geometry.size
                setupScene()
            }
            .onChange(of: geometry.size) { _, newSize in
                currentGeometry = newSize
                if scene != nil {
                    setupScene() // Recreate scene with new size
                }
            }
        }
        .onAppear {
            if currentGeometry != .zero {
                setupScene()
            }
        }
        .onAppear {
            setupScene()
        }
        .onChange(of: gameSettings.gravity) { _, _ in
            updateScenePhysics()
        }
        .onChange(of: gameSettings.bounciness) { _, _ in
            updateScenePhysics()
        }
        .onChange(of: gameSettings.wallsEnabled) { _, _ in
            updateScenePhysics()
        }
        .onChange(of: gameSettings.accelerometerEnabled) { _, newValue in
            scene?.enableAccelerometer(newValue)
        }
        .onTapGesture { location in
            handleTap(at: location)
        }
    }
    
    // MARK: - Scene Management
    
    /**
     * Sets up the SpriteKit scene
     */
    private func setupScene() {
        // Create scene with appropriate size using current geometry
        let sceneSize = currentGeometry.width > 0 && currentGeometry.height > 0 
            ? currentGeometry 
            : CGSize(width: 400, height: 600) // Fallback size
        
        let newScene = BallPhysicsScene(size: sceneSize)
        
        // Configure scene
        newScene.scaleMode = .aspectFill
        
        // Apply current settings
        newScene.updatePhysics(with: gameSettings)
        newScene.enableAccelerometer(gameSettings.accelerometerEnabled)
        
        // Set scene
        scene = newScene
        isSceneReady = true
        
        #if DEBUG
        print("BallPhysicsView: Scene setup complete with size \(sceneSize)")
        #endif
    }
    
    /**
     * Updates scene physics based on current settings
     */
    private func updateScenePhysics() {
        guard let scene = scene else { return }
        scene.updatePhysics(with: gameSettings)
    }
    
    /**
     * Handles tap gestures to drop balls
     */
    private func handleTap(at location: CGPoint) {
        guard let scene = scene, isSceneReady else { return }
        
        // Convert SwiftUI coordinates to SpriteKit coordinates
        let sceneLocation = convertToSceneCoordinates(location)
        
        // Drop a ball at the tap location
        scene.dropBall(
            at: sceneLocation,
            ballType: gameSettings.selectedBallType,
            settings: gameSettings
        )
    }
    
    /**
     * Converts SwiftUI view coordinates to SpriteKit scene coordinates
     */
    private func convertToSceneCoordinates(_ viewLocation: CGPoint) -> CGPoint {
        guard let scene = scene else { return viewLocation }
        
        // SpriteKit uses bottom-left origin, SwiftUI uses top-left
        return CGPoint(
            x: viewLocation.x,
            y: scene.size.height - viewLocation.y
        )
    }
}

// MARK: - Debug Info View

#if DEBUG
/**
 * Debug information overlay for development
 */
private struct DebugInfoView: View {
    let scene: BallPhysicsScene
    let gameSettings: GameSettings
    
    @State private var debugInfo: [String: Any] = [:]
    @State private var updateTimer: Timer?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Debug Info")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Balls: \(scene.activeBallCount)")
                .font(.caption2)
                .foregroundColor(.white)
            
            Text("Gravity: \(gameSettings.gravity, specifier: "%.1f")")
                .font(.caption2)
                .foregroundColor(.white)
            
            Text("Bounciness: \(gameSettings.bounciness, specifier: "%.1f")")
                .font(.caption2)
                .foregroundColor(.white)
            
            Text("Walls: \(gameSettings.wallsEnabled ? "ON" : "OFF")")
                .font(.caption2)
                .foregroundColor(.white)
            
            Text("Accelerometer: \(gameSettings.accelerometerEnabled ? "ON" : "OFF")")
                .font(.caption2)
                .foregroundColor(.white)
        }
        .padding(8)
        .background(Color.black.opacity(0.7))
        .cornerRadius(8)
        .onAppear {
            startDebugTimer()
        }
        .onDisappear {
            stopDebugTimer()
        }
    }
    
    private func startDebugTimer() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            debugInfo = scene.debugInfo()
        }
    }
    
    private func stopDebugTimer() {
        updateTimer?.invalidate()
        updateTimer = nil
    }
}
#endif

// MARK: - Preview

#Preview {
    BallPhysicsView(gameSettings: GameSettings.shared)
        .preferredColorScheme(.dark)
}