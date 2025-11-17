//
//  MacOSCommands.swift
//  Amazeballs
//
//  Created by Daniel Flax on 11/15/25.
//

#if os(macOS)
import SwiftUI

/**
 * macOS-specific menu bar commands for the Amazeballs app
 * 
 * These commands should be added to your App file using the .commands modifier
 * on the WindowGroup, like this:
 * 
 * ```swift
 * WindowGroup {
 *     ContentView()
 * }
 * .commands {
 *     AmazeballsMacOSCommands()
 * }
 * ```
 */
struct AmazeballsMacOSCommands: Commands {
    var body: some Commands {
        // File Menu Commands
        CommandGroup(replacing: .newItem) {
            Button("New Window") {
                openNewWindow()
            }
            .keyboardShortcut("n", modifiers: .command)
        }
        
        // Edit Menu (standard, even if items are disabled)
        CommandGroup(after: .undoRedo) {
            Divider()
            
            Button("Clear All Balls") {
                clearAllBalls()
            }
            .keyboardShortcut(.delete, modifiers: .command)
        }
        
        // View Menu Commands
        CommandMenu("View") {
            Button("Show Ball Picker") {
                showBallPicker()
            }
            .keyboardShortcut("b", modifiers: .command)
            
            Divider()
            
            Button("Toggle Walls") {
                toggleWalls()
            }
            .keyboardShortcut("w", modifiers: .command)
            
            Button("Toggle Motion") {
                toggleAccelerometer()
            }
            .keyboardShortcut("a", modifiers: .command)
            
            Divider()
            
            Button("Reset Physics") {
                resetPhysics()
            }
            .keyboardShortcut("r", modifiers: [.command, .option])
        }
        
        // Help Menu Commands  
        CommandGroup(replacing: .help) {
            Button("About Amazeballs") {
                showAboutWindow()
            }
        }
    }
    
    // MARK: - Command Actions
    
    /**
     * Clears all balls from the scene
     */
    private func clearAllBalls() {
        NotificationCenter.default.post(name: .clearAllBalls, object: nil)
    }
    
    /**
     * Shows the ball picker
     */
    private func showBallPicker() {
        NotificationCenter.default.post(name: .showBallPicker, object: nil)
    }
    
    /**
     * Toggles boundary walls
     */
    private func toggleWalls() {
        NotificationCenter.default.post(name: .toggleWalls, object: nil)
    }
    
    /**
     * Toggles accelerometer (disabled on macOS)
     */
    private func toggleAccelerometer() {
        NotificationCenter.default.post(name: .toggleAccelerometer, object: nil)
    }
    
    /**
     * Resets physics settings
     */
    private func resetPhysics() {
        NotificationCenter.default.post(name: .resetPhysics, object: nil)
    }
    
    /**
     * Opens a new window (macOS multi-window support)
     */
    private func openNewWindow() {
        // This would require additional WindowGroup configuration in the App file
        // For now, we'll show an alert that this feature requires more setup
        let alert = NSAlert()
        alert.messageText = "New Window"
        alert.informativeText = "Multiple windows are not yet implemented in this version."
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    /**
     * Shows the About window
     */
    private func showAboutWindow() {
        let alert = NSAlert()
        alert.messageText = "About Amazeballs"
        alert.informativeText = """
            Amazeballs - Physics Ball Simulation
            
            A fun physics simulation where balls bounce around with realistic physics. 
            Tap or click to drop balls, adjust gravity and bounciness, and watch the chaos unfold!
            
            Features:
            • Realistic ball physics
            • Multiple ball types
            • Adjustable gravity and bounciness
            • Boundary walls
            • Cross-platform (iOS, iPadOS, macOS)
            
            Built with SwiftUI and SpriteKit
            """
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}

// MARK: - Notification Extensions

extension Notification.Name {
    static let showBallPicker = Notification.Name("showBallPicker")
    static let toggleWalls = Notification.Name("toggleWalls")
    static let toggleAccelerometer = Notification.Name("toggleAccelerometer") 
    static let resetPhysics = Notification.Name("resetPhysics")
}

#endif