import SwiftUI
import SpriteKit
import Foundation

/**
 * WatchSpriteKitSceneView
 *
 * SwiftUI wrapper that hosts the WatchBallPhysicsScene and exposes simple controls
 * for toggling walls and handling press-and-hold gestures.
 */
struct WatchSpriteKitSceneView: View {

    // Internal scene instance
    private let scene: WatchBallPhysicsScene = {
        let s = WatchBallPhysicsScene(size: .zero)
        s.scaleMode = .resizeFill
        return s
    }()

    var body: some View {
        GeometryReader { proxy in
            SpriteView(scene: scene)
                .ignoresSafeArea()
                .onAppear {
                    scene.size = proxy.size
                }
                .onReceive(NotificationCenter.default.publisher(for: .watchBeginPreview)) { note in
                    if let pt = note.object as? CGPoint {
                        scene.beginPreview(at: pt)
                        #if DEBUG
                        print("WatchSpriteKitSceneView: Forwarded beginPreview to scene at \(pt)")
                        #endif
                    } else {
                        let center = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2)
                        scene.beginPreview(at: center)
                        #if DEBUG
                        print("WatchSpriteKitSceneView: Forwarded beginPreview to scene at center \(center)")
                        #endif
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: .watchUpdatePreview)) { note in
                    if let progress = note.object as? CGFloat {
                        scene.updatePreview(progress: progress)
                        #if DEBUG
                        print("WatchSpriteKitSceneView: Forwarded updatePreview to scene progress=\(progress)")
                        #endif
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: .watchCommitPreview)) { _ in
                    scene.commitPreview()
                    #if DEBUG
                    print("WatchSpriteKitSceneView: Forwarded commitPreview to scene")
                    #endif
                }
        }
    }
}

