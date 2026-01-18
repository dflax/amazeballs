import SwiftUI
import SpriteKit
import Foundation

/**
 * WatchSpriteKitSceneView
 *
 * SwiftUI wrapper that hosts the WatchBallPhysicsScene and provides
 * simple tap-to-drop interaction for the watchOS app.
 */
struct WatchSpriteKitSceneView: View {

    // Scene instance stored in @State to persist across view updates
    @State private var scene: WatchBallPhysicsScene = {
        let s = WatchBallPhysicsScene(size: .zero)
        s.scaleMode = .resizeFill
        return s
    }()
    
    // Dummy binding to absorb Digital Crown input
    @State private var crownValue: Double = 0.0

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                SpriteView(scene: scene)
                    .ignoresSafeArea()
                    .focusable(false)
                    .digitalCrownRotation($crownValue, from: 0.0, through: 0.0, by: 0.0, sensitivity: .low, isContinuous: false, isHapticFeedbackEnabled: false)
                    .onAppear {
                        scene.size = proxy.size
                        #if DEBUG
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            scene.dumpSceneChildren(tag: "onAppear+1s")
                        }
                        #endif
                    }
                    .onReceive(NotificationCenter.default.publisher(for: .watchDropBall)) { note in
                        if let pt = note.object as? CGPoint {
                            scene.dropBall(at: pt)
                            #if DEBUG
                            print("WatchSpriteKitSceneView: Forwarded dropBall to scene at \(pt)")
                            #endif
                        } else {
                            let center = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2)
                            scene.dropBall(at: center)
                            #if DEBUG
                            print("WatchSpriteKitSceneView: Forwarded dropBall to scene at center \(center)")
                            #endif
                        }
                    }
                    .onReceive(NotificationCenter.default.publisher(for: .watchDumpNodes)) { _ in
                        #if DEBUG
                        scene.dumpSceneChildren(tag: "manual")
                        #endif
                    }
            }
            .focusable(false)
        }
        .focusable(false)
    }
}

extension Notification.Name {
    static let watchDumpNodes = Notification.Name("watchDumpNodes")
}
