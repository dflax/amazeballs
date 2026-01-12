//
//  SpriteKitSceneView.swift
//  Amazeballs
//
//  Created by Daniel Flax on 11/15/25.
//

import SwiftUI
import SpriteKit

// MARK: - Extensions

extension Notification.Name {
    static let tiltDidChange = Notification.Name("Amazeballs.tiltDidChange")
    static let resetTilt = Notification.Name("Amazeballs.resetTilt")
}

/**
 * SpriteKitSceneView
 *
 * A SwiftUI wrapper for BallPhysicsScene that provides seamless integration
 * with the Settings system and cross-platform gesture handling.
 *
 * ## Features
 * - Automatic scene lifecycle management
 * - Cross-platform gesture support (tap/click)
 * - Real-time settings synchronization
 * - Proper coordinate system conversion
 * - Memory-efficient scene updates
 * - Responsive layout adaptation
 *
 * ## Platform Support
 * - **iOS/iPadOS**: Touch gestures with tap locations
 * - **macOS**: Mouse click gestures with click locations
 * - **All platforms**: Automatic scene scaling and coordinate conversion
 *
 * ## Usage
 * ```swift
 * struct GameView: View {
 *     @State private var gameSettings = GameSettings.shared
 *
 *     var body: some View {
 *         SpriteKitSceneView(settings: gameSettings)
 *             .ignoresSafeArea()
 *     }
 * }
 * ```
 *
 * ## Tap/Click Behavior
 * - Converts SwiftUI coordinates to SpriteKit scene coordinates
 * - Drops balls using the selected ball type from Settings
 * - Falls back to random ball type if none selected
 * - Handles coordinate system differences between platforms
 */
struct SpriteKitSceneView: View {
    
    // MARK: - Properties
    
    /// Game settings that control physics and ball behavior
    @Bindable var settings: GameSettings
    
    /// The SpriteKit scene instance
    @State private var scene: BallPhysicsScene?
    
    /// Whether the scene has been properly initialized
    @State private var isSceneReady = false
    
    /// Current view size for coordinate conversion
    @State private var viewSize: CGSize = .zero

    #if os(macOS)
    /// Current visual tilt in degrees for macOS-only trackpad control (-30...30)
    @State private var tiltDegrees: Double = 0
    
    /// Scale factor to keep rotated content fully within the current view bounds
    private var tiltScale: Double {
        guard viewSize.width > 0, viewSize.height > 0 else { return 1.0 }
        let w = Double(viewSize.width)
        let h = Double(viewSize.height)
        let theta = abs(tiltDegrees) * .pi / 180.0
        let rotatedWidth = abs(w * cos(theta)) + abs(h * sin(theta))
        let rotatedHeight = abs(w * sin(theta)) + abs(h * cos(theta))
        let scaleX = w / max(rotatedWidth, 0.0001)
        let scaleY = h / max(rotatedHeight, 0.0001)
        return max(0.0, min(1.0, min(scaleX, scaleY)))
    }
    #endif

    /// Press-and-hold tracking
    @State private var pressStartTime: Date? = nil
    @State private var pressStartLocation: CGPoint? = nil

    /// Preview sizing progress (0...1) for press-and-hold mode
    @State private var previewProgress: Double = 0.0
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // SpriteKit Scene Container
                sceneContainer(geometry: geometry)
                
                // Loading overlay (shown while scene initializes)
                if !isSceneReady {
                    loadingOverlay
                }
            }
            .onAppear {
                setupScene(size: geometry.size)
            }
            .onChange(of: geometry.size) { _, newSize in
                handleSizeChange(newSize)
            }
            .onChange(of: settings.gravity) { _, _ in
                refreshScenePhysicsForTilt()
            }
            .onChange(of: settings.bounciness) { _, _ in
                refreshScenePhysicsForTilt()
            }
            .onChange(of: settings.wallsEnabled) { _, _ in
                refreshScenePhysicsForTilt()
            }
            .onChange(of: settings.accelerometerEnabled) { _, newValue in
                updateAccelerometer(enabled: newValue)
            }
        }
    }
    
    // MARK: - Scene Container
    
    /**
     * Creates the SpriteView container with appropriate gesture handling
     */
    @ViewBuilder
    private func sceneContainer(geometry: GeometryProxy) -> some View {
        if let scene = scene {
            #if os(macOS)
            TrackpadScrollContainer(onHorizontalScroll: { deltaX, modifiers in
                // Only handle when Option is pressed
                if modifiers.contains(.option) {
                    let sensitivity: Double = 0.1 // degrees per scroll delta unit
                    let proposed = tiltDegrees + Double(deltaX) * sensitivity
                    tiltDegrees = max(-25, min(25, proposed))
                    NotificationCenter.default.post(name: .tiltDidChange, object: nil, userInfo: ["angle": tiltDegrees])
                    refreshScenePhysicsForTilt()
                }
            }) {
                let baseView = SpriteView(scene: scene)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                    .background(Color.black)
                    .gesture(createTapGesture())
                    .onReceive(NotificationCenter.default.publisher(for: .clearAllBalls)) { _ in
                        clearAllBalls()
                    }
                    .onReceive(NotificationCenter.default.publisher(for: .resetTilt)) { _ in
                        tiltDegrees = 0
                        refreshScenePhysicsForTilt()
                        NotificationCenter.default.post(name: .tiltDidChange, object: nil, userInfo: ["angle": tiltDegrees])
                    }

                if abs(tiltDegrees) < 0.0001 {
                    baseView
                } else {
                    baseView
                        .rotationEffect(.degrees(tiltDegrees))
                        .scaleEffect(tiltScale)
                }
            }
            #else
            SpriteView(scene: scene)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
                .background(Color.black)
                .gesture(createTapGesture())
                .onReceive(NotificationCenter.default.publisher(for: .clearAllBalls)) { _ in
                    clearAllBalls()
                }
            #endif
        } else {
            // Placeholder while scene loads
            Rectangle()
                .fill(Color.black)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    /**
     * Loading overlay shown during scene initialization
     */
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.8)
            
            VStack(spacing: 16) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.2)
                
                Text("Loading Physics Scene...")
                    .font(.subheadline)
                    .foregroundColor(.white)
            }
        }
        .transition(.opacity)
    }
    
    // MARK: - Scene Management
    
    /**
     * Sets up the BallPhysicsScene with the provided size
     *
     * - Parameter size: The size of the view for scene initialization
     */
    private func setupScene(size: CGSize) {
        guard scene == nil else { return }
        
        // Store view size for coordinate conversion
        viewSize = size
        
        // Create scene with appropriate size
        let newScene = BallPhysicsScene(size: size)
        
        // Configure scene properties
        newScene.scaleMode = .aspectFill
        newScene.anchorPoint = CGPoint(x: 0, y: 0) // Bottom-left origin
        
        // Apply current settings
        newScene.updatePhysics(with: settings)
        newScene.enableAccelerometer(settings.accelerometerEnabled)
        
        // Set the scene and mark as ready
        scene = newScene
        
        // Small delay to ensure scene is fully initialized
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeIn(duration: 0.3)) {
                isSceneReady = true
            }
        }
        
        #if DEBUG
        print("SpriteKitSceneView: Scene initialized with size \(size)")
        #endif
    }
    
    /**
     * Handles view size changes (rotation, window resize, etc.)
     *
     * - Parameter newSize: The new size of the view
     */
    private func handleSizeChange(_ newSize: CGSize) {
        guard newSize != viewSize && newSize.width > 0 && newSize.height > 0 else { return }
        
        viewSize = newSize
        
        // Update scene size
        scene?.size = newSize
        
        #if DEBUG
        print("SpriteKitSceneView: Size changed to \(newSize)")
        #endif
    }
    
    /**
     * Updates scene physics based on current settings
     */
    private func updateScenePhysics() {
        guard let _ = scene, isSceneReady else { return }
        refreshScenePhysicsForTilt()
    }
    
    /**
     * Re-applies scene physics consistently, including walls, then applies appropriate gravity based on tilt (macOS only)
     */
    private func refreshScenePhysicsForTilt() {
        guard let scene = scene, isSceneReady else { return }
        // First, apply all standard physics updates (walls, restitution, etc.)
        scene.updatePhysics(with: settings)
        #if os(macOS)
        // Then apply gravity according to current tilt
        if abs(tiltDegrees) > 0.0001 {
            let radians = CGFloat(tiltDegrees * .pi / 180.0)
            let magnitude = CGFloat(settings.gravity)
            let dx = sin(radians) * magnitude
            let dy = -cos(radians) * magnitude
            scene.physicsWorld.gravity = CGVector(dx: dx, dy: dy)
        } else {
            // No tilt: use standard gravity from settings
            scene.physicsWorld.gravity = CGVector(dx: 0, dy: -CGFloat(settings.gravity))
        }
        #else
        // Non-macOS: standard update is sufficient
        #endif
        #if DEBUG
        #if os(macOS)
        print("SpriteKitSceneView: refreshScenePhysicsForTilt applied (tilt=\(tiltDegrees))")
        #else
        print("SpriteKitSceneView: refreshScenePhysicsForTilt applied (non-macOS)")
        #endif
        #endif
    }
    
    /**
     * Updates accelerometer state in the scene
     *
     * - Parameter enabled: Whether accelerometer should be enabled
     */
    private func updateAccelerometer(enabled: Bool) {
        guard let scene = scene, isSceneReady else { return }
        scene.enableAccelerometer(enabled)
        
        #if DEBUG
        print("SpriteKitSceneView: Accelerometer \(enabled ? "enabled" : "disabled")")
        #endif
    }
    
    /**
     * Clears all balls from the scene
     */
    private func clearAllBalls() {
        guard let scene = scene, isSceneReady else { return }
        scene.clearAllBalls()
        
        #if DEBUG
        print("SpriteKitSceneView: Cleared all balls")
        #endif
    }
    
    // MARK: - Gesture Handling
    
    /**
     * Creates the appropriate tap/click gesture for the current platform
     *
     * - Returns: A SwiftUI gesture that handles ball dropping
     */
    private func createTapGesture() -> some Gesture {
        #if os(macOS)
        return createMacOSClickGesture()
        #else
        return createTouchGesture()
        #endif
    }
    
    #if os(macOS)
    /**
     * Creates a click gesture optimized for macOS
     */
    private func createMacOSClickGesture() -> some Gesture {
        let gesture = DragGesture(minimumDistance: 0)
            .onChanged { value in
                if settings.ballSizeMode == .pressAndGrow {
                    if pressStartTime == nil {
                        pressStartTime = Date()
                        pressStartLocation = value.startLocation

                        if let scene = scene, isSceneReady {
                            let startPoint = convertToSceneCoordinates(value.startLocation)
                            let ballType = determineBallType()
                            scene.beginPreviewBall(at: startPoint, ballType: ballType, settings: settings)
                        }
                    }
                }
            }
            .onEnded { value in
                if settings.ballSizeMode == .pressAndGrow {
                    if let scene = scene, isSceneReady {
                        scene.commitPreviewBall(settings: settings)
                    }
                    pressStartTime = nil
                    pressStartLocation = nil
                } else {
                    handleGestureInput(at: value.location, pressDuration: nil)
                }
            }
        return gesture
    }
    #endif
    
    /**
     * Creates a tap gesture optimized for iOS/iPadOS
     */
    #if !os(macOS)
    private func createTouchGesture() -> some Gesture {
        let gesture = DragGesture(minimumDistance: 0)
            .onChanged { value in
                if settings.ballSizeMode == .pressAndGrow {
                    if pressStartTime == nil {
                        pressStartTime = Date()
                        pressStartLocation = value.startLocation

                        if let scene = scene, isSceneReady {
                            let startPoint = convertToSceneCoordinates(value.startLocation)
                            let ballType = determineBallType()
                            scene.beginPreviewBall(at: startPoint, ballType: ballType, settings: settings)
                        }
                    }
                }
            }
            .onEnded { value in
                if settings.ballSizeMode == .pressAndGrow {
                    if let scene = scene, isSceneReady {
                        scene.commitPreviewBall(settings: settings)
                    }
                    pressStartTime = nil
                    pressStartLocation = nil
                } else {
                    handleGestureInput(at: value.location, pressDuration: nil)
                }
            }
        return gesture
    }
    #endif
    
    /**
     * Handles gesture input (tap/click) at the specified location
     *
     * - Parameters:
     *   - location: The location of the gesture in SwiftUI coordinates
     *   - pressDuration: Optional duration of press-and-hold for size scaling
     */
    private func handleGestureInput(at location: CGPoint, pressDuration: TimeInterval?) {
        guard let scene = scene, isSceneReady else { return }
        
        // Convert SwiftUI coordinates to SpriteKit coordinates
        let sceneLocation = convertToSceneCoordinates(location)
        
        // Determine ball type to drop
        let ballType = determineBallType()
        
        // Compute optional size override for press-and-grow mode
        var sizeOverride: Double? = nil
        if settings.ballSizeMode == .pressAndGrow, let duration = pressDuration {
            let total = max(0.1, settings.pressAndGrowDuration)
            let progress = max(0.0, min(1.0, duration / total))
            let minSize = 0.5
            let maxSize = 3.0
            sizeOverride = minSize + (maxSize - minSize) * progress
        }
        
        // Drop the ball
        scene.dropBall(
            at: sceneLocation,
            ballType: ballType,
            settings: settings,
            sizeOverride: sizeOverride
        )
        
        #if DEBUG
        print("SpriteKitSceneView: Dropped \(ballType ?? "random") ball at \(sceneLocation) sizeOverride=\(sizeOverride?.description ?? "nil")")
        #endif
        
        // Provide haptic feedback on supported platforms
        #if os(iOS)
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        #endif
    }
    
    /**
     * Converts SwiftUI view coordinates to SpriteKit scene coordinates
     *
     * SwiftUI uses top-left origin (0,0), while SpriteKit uses bottom-left origin.
     * This method handles the coordinate system conversion.
     *
     * - Parameter viewLocation: The location in SwiftUI coordinates
     * - Returns: The corresponding location in SpriteKit coordinates
     */
    private func convertToSceneCoordinates(_ viewLocation: CGPoint) -> CGPoint {
        guard let scene = scene else { return viewLocation }
        
        // Convert from top-left origin (SwiftUI) to bottom-left origin (SpriteKit)
        return CGPoint(
            x: viewLocation.x,
            y: scene.size.height - viewLocation.y
        )
    }
    
    /**
     * Determines which ball type to drop based on current settings
     *
     * - Returns: The ball type to drop, or nil for random selection
     */
    private func determineBallType() -> String? {
        // Use selected ball type if available
        if let selectedType = settings.selectedBallType {
            // Verify the ball type is still valid (assets might have changed)
            if BallAssetManager.shared.hasBallType(selectedType) {
                return selectedType
            } else {
                #if DEBUG
                print("SpriteKitSceneView: Selected ball type '\(selectedType)' is no longer available, using random")
                #endif
            }
        }
        
        // Return nil for random selection
        return nil
    }
}

// MARK: - Extensions

extension SpriteKitSceneView {
    
    /**
     * Creates a SpriteKitSceneView with default settings
     *
     * Convenience initializer for quick setup during development or testing.
     *
     * - Returns: A SpriteKitSceneView configured with shared GameSettings
     */
    static func withDefaultSettings() -> SpriteKitSceneView {
        SpriteKitSceneView(settings: GameSettings.shared)
    }
}

// MARK: - Accessibility

extension SpriteKitSceneView {
    
    /**
     * Adds accessibility support to the scene view
     */
    private func accessibilityConfiguration() -> some View {
        self
            .accessibilityLabel("Ball Physics Scene")
            .accessibilityHint("Tap anywhere to drop a ball. Current ball type: \(settings.selectedBallType ?? "Random")")
            .accessibilityAddTraits(.allowsDirectInteraction)
    }
}

// MARK: - Debug Support

#if DEBUG
extension SpriteKitSceneView {
    
    /**
     * Debug overlay showing scene information
     */
    @ViewBuilder
    private var debugOverlay: some View {
        if let scene = scene, isSceneReady {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Scene: \(Int(scene.size.width))×\(Int(scene.size.height))")
                        Text("Balls: \(scene.activeBallCount)")
                        Text("Physics: \(settings.gravity, specifier: "%.1f")G, \(settings.bounciness, specifier: "%.1f")B")
                        Text("Features: \(settings.wallsEnabled ? "W" : "")|\(settings.accelerometerEnabled ? "A" : "")")
                    }
                    .font(.caption2)
                    .padding(8)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(8)
                    .foregroundColor(.white)
                }
                .padding()
            }
        }
    }
    
    /**
     * Adds debug overlay to the view (debug builds only)
     */
    func withDebugOverlay() -> some View {
        ZStack {
            self
            debugOverlay
        }
    }
}
#endif

#if os(macOS)
import AppKit

/// A container that hosts SwiftUI content and forwards trackpad scrollWheel events
private struct TrackpadScrollContainer<Content: View>: NSViewRepresentable {
    let onHorizontalScroll: (_ deltaX: CGFloat, _ modifiers: NSEvent.ModifierFlags) -> Void
    let content: Content

    init(onHorizontalScroll: @escaping (_ deltaX: CGFloat, _ modifiers: NSEvent.ModifierFlags) -> Void, @ViewBuilder content: () -> Content) {
        self.onHorizontalScroll = onHorizontalScroll
        self.content = content()
    }

    func makeNSView(context: Context) -> _ScrollingHostingView<Content> {
        let hosting = _ScrollingHostingView(rootView: content)
        hosting.wantsLayer = true
        hosting.onHorizontalScroll = { deltaX, modifiers in
            context.coordinator.onHorizontalScroll(deltaX, modifiers)
        }
        return hosting
    }

    func updateNSView(_ nsView: _ScrollingHostingView<Content>, context: Context) {
        nsView.rootView = content
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onHorizontalScroll: onHorizontalScroll)
    }

    final class Coordinator: NSObject {
        let onHorizontalScroll: (_ deltaX: CGFloat, _ modifiers: NSEvent.ModifierFlags) -> Void

        init(onHorizontalScroll: @escaping (_ deltaX: CGFloat, _ modifiers: NSEvent.ModifierFlags) -> Void) {
            self.onHorizontalScroll = onHorizontalScroll
            super.init()
        }
    }
}

/// A hosting view that forwards scrollWheel events to a callback
private final class _ScrollingHostingView<Content: View>: NSHostingView<Content> {
    var onHorizontalScroll: ((_ deltaX: CGFloat, _ modifiers: NSEvent.ModifierFlags) -> Void)?

    override func scrollWheel(with event: NSEvent) {
        super.scrollWheel(with: event)
        let deltaX = event.hasPreciseScrollingDeltas ? event.scrollingDeltaX : event.deltaX
        onHorizontalScroll?(deltaX, event.modifierFlags)
    }
}
#endif

// MARK: - Preview

#Preview("Default Settings") {
    SpriteKitSceneView.withDefaultSettings()
        .preferredColorScheme(.dark)
}

#Preview("Custom Settings") {
    SpriteKitSceneView(settings: {
        let settings = GameSettings.shared
        settings.gravity = 1.5
        settings.bounciness = 0.9
        settings.wallsEnabled = false
        return settings
    }())
    .preferredColorScheme(.dark)
}

#if DEBUG
#Preview("With Debug Overlay") {
    SpriteKitSceneView.withDefaultSettings()
        .withDebugOverlay()
        .preferredColorScheme(.dark)
}
#endif

