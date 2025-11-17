//
//  BallAssetManager.swift
//  Amazeballs
//
//  Created by Daniel Flax on 11/15/25.
//

import Foundation
import SwiftUI

/**
 * BallAssetManager
 *
 * A singleton class that manages discovery and access to ball image assets in the "Balls" folder
 * within Assets.xcassets. This class automatically discovers available ball types and provides
 * convenient methods for accessing them.
 *
 * ## Asset Naming Convention
 *
 * Ball assets should follow the naming pattern: `ball-{type}`
 * Examples:
 * - `ball-football` for American football
 * - `ball-soccer` for soccer ball  
 * - `ball-basketball` for basketball
 * - `ball-tennis` for tennis ball
 * - `ball-bowling` for bowling ball
 * - `ball-golf` for golf ball
 * - `ball-volleyball` for volleyball
 * - `ball-ping-pong` for ping pong ball
 *
 * ## Usage
 *
 * ```swift
 * let manager = BallAssetManager.shared
 * 
 * // Get all available ball types
 * let ballTypes = manager.availableBallTypes
 * 
 * // Get a random ball type
 * let randomBall = manager.randomBallType()
 * 
 * // Get a specific ball image
 * let footballImage = manager.ballImage(for: "football")
 * ```
 *
 * ## Adding New Balls
 *
 * Simply drag new PDF or PNG images into the "Balls" folder in Assets.xcassets
 * following the naming convention above. The manager will automatically discover
 * them on next app launch.
 *
 * ## Using a Manifest (Recommended)
 * Create a file named `BallsManifest.json` in your app bundle with the structure:
 * {
 *   "assets": [
 *     "ball-amazeball",
 *     "ball-apple1",
 *     "ball-banana1"
 *   ]
 * }
 * Any entries starting with `ball-` will be discovered automatically. The manager will strip the `ball-` prefix to produce the ball type.
 */
@Observable
class BallAssetManager {
    
    // MARK: - Singleton
    
    static let shared = BallAssetManager()
    
    // MARK: - Properties
    
    /// Cached list of available ball types (without "ball-" prefix)
    private var cachedBallTypes: [String] = []
    
    /// Whether the asset discovery has been performed
    private var hasScannedAssets = false
    
    /// Optional manifest filename for listing ball asset names in the bundle
    private struct Manifest {
        static let fileName = "BallsManifest"
        static let fileExtension = "json"
        static let key = "assets" // JSON: { "assets": ["ball-xxx", ...] }
    }
    
    /// All available ball types discovered from assets
    var availableBallTypes: [String] {
        if !hasScannedAssets {
            scanForBallAssets()
        }
        return cachedBallTypes
    }
    
    // MARK: - Initialization
    
    private init() {
        // Private initializer for singleton pattern
    }
    
    // MARK: - Asset Discovery
    
    /**
     * Scans the Assets.xcassets for ball images in the "Balls" folder.
     * 
     * This method discovers all image assets that follow the naming convention
     * "ball-{type}" and caches them for quick access.
     */
    private func scanForBallAssets() {
        guard !hasScannedAssets else { return }

        var discoveredBalls: [String] = []

        // 1) Try to load from optional manifest in the bundle
        if let url = Bundle.main.url(forResource: Manifest.fileName, withExtension: Manifest.fileExtension) {
            do {
                let data = try Data(contentsOf: url)
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let assets = json[Manifest.key] as? [String] {
                    let filtered = assets
                        .filter { $0.hasPrefix("ball-") }
                        .map { String($0.dropFirst("ball-".count)) }
                    discoveredBalls.append(contentsOf: filtered)
                }
            } catch {
                #if DEBUG
                print("BallAssetManager: Failed to parse \(Manifest.fileName).\(Manifest.fileExtension): \(error)")
                #endif
            }
        }

        // 2) Fallback: if no manifest or empty, attempt a minimal heuristic
        if discoveredBalls.isEmpty {
            // Minimal seed list to probe common names; users should prefer the manifest for full coverage
            let seedTypes = [
                "basketball", "baseball", "soccer", "tennis", "golf", "bowling", "volleyball", "football",
                "hockeypuck", "eightball", "discoball"
            ]

            for t in seedTypes {
                let assetName = "ball-\(t)"
                #if os(macOS)
                if NSImage(named: assetName) != nil {
                    discoveredBalls.append(t)
                }
                #else
                if UIImage(named: assetName) != nil {
                    discoveredBalls.append(t)
                }
                #endif
            }
        }

        // Sort and cache
        cachedBallTypes = Array(Set(discoveredBalls)).sorted()
        hasScannedAssets = true

        #if DEBUG
        print("BallAssetManager: Discovered \(cachedBallTypes.count) ball types: \(cachedBallTypes)")
        #endif
    }
    
    // MARK: - Public Methods
    
    /**
     * Returns a random ball type from the available options.
     * 
     * - Returns: A random ball type string, or nil if no balls are available
     */
    func randomBallType() -> String? {
        let ballTypes = availableBallTypes
        guard !ballTypes.isEmpty else { return nil }
        return ballTypes.randomElement()
    }
    
    /**
     * Returns the image for a specific ball type.
     * 
     * - Parameter ballType: The ball type (without "ball-" prefix)
     * - Returns: The ball image, or nil if not found
     */
    #if os(macOS)
    func ballImage(for ballType: String) -> NSImage? {
        let assetName = "ball-\(ballType)"
        return NSImage(named: assetName)
    }
    #else
    func ballImage(for ballType: String) -> UIImage? {
        let assetName = "ball-\(ballType)"
        return UIImage(named: assetName)
    }
    #endif
    
    /**
     * Returns a SwiftUI Image view for a specific ball type.
     * 
     * - Parameter ballType: The ball type (without "ball-" prefix)
     * - Returns: A SwiftUI Image view
     */
    func ballImageView(for ballType: String) -> Image {
        let assetName = "ball-\(ballType)"
        return Image(assetName)
    }
    
    /**
     * Returns a SwiftUI Image view for a random ball type.
     * 
     * - Returns: A SwiftUI Image view for a random ball, or a system image if no balls available
     */
    func randomBallImageView() -> Image {
        guard let randomType = randomBallType() else {
            // Fallback to a system image if no ball assets are available
            return Image(systemName: "circle.fill")
        }
        return ballImageView(for: randomType)
    }
    
    /**
     * Checks if a specific ball type is available.
     * 
     * - Parameter ballType: The ball type to check (without "ball-" prefix)
     * - Returns: True if the ball type is available, false otherwise
     */
    func hasBallType(_ ballType: String) -> Bool {
        return availableBallTypes.contains(ballType)
    }
    
    /**
     * Forces a re-scan of available ball assets.
     * 
     * Use this method if you've added new ball assets at runtime and need
     * to refresh the cached list.
     */
    func refreshAssets() {
        hasScannedAssets = false
        cachedBallTypes.removeAll()
        _ = availableBallTypes // Trigger a new scan
    }
    
    /**
     * Returns the full asset name for a ball type.
     * 
     * - Parameter ballType: The ball type (without "ball-" prefix)
     * - Returns: The full asset name (with "ball-" prefix)
     */
    func assetName(for ballType: String) -> String {
        return "ball-\(ballType)"
    }
    
    // MARK: - Debug Information
    
    /**
     * Returns debug information about discovered ball assets.
     * 
     * - Returns: A dictionary containing debug information
     */
    func debugInfo() -> [String: Any] {
        return [
            "totalBallTypes": availableBallTypes.count,
            "ballTypes": availableBallTypes,
            "hasScanned": hasScannedAssets,
            "lastScanResult": cachedBallTypes
        ]
    }
}

// MARK: - Extensions

extension BallAssetManager {
    
    /**
     * Returns a user-friendly display name for a ball type.
     * 
     * Converts asset names like "ping-pong" to "Ping Pong" for UI display.
     * 
     * - Parameter ballType: The ball type (without "ball-" prefix)
     * - Returns: A formatted display name
     */
    func displayName(for ballType: String) -> String {
        return ballType
            .replacingOccurrences(of: "-", with: " ")
            .capitalized
    }
    
    /**
     * Returns all ball types with their display names.
     * 
     * - Returns: A dictionary mapping ball types to display names
     */
    func ballTypesWithDisplayNames() -> [String: String] {
        var result: [String: String] = [:]
        for ballType in availableBallTypes {
            result[ballType] = displayName(for: ballType)
        }
        return result
    }
}
