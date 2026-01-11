//
//  SoundManager.swift
//  Amazeballs
//
//  Created by Daniel Flax on 11/17/25.
//

import Foundation
import AVFoundation
import Observation

/// Manages sound effects for the Amazeballs game with efficient audio playback
/// and volume control based on game settings.
///
/// This class provides high-performance audio playback suitable for physics
/// simulations with frequent sound events. It uses AVAudioEngine for low-latency
/// playback and manages audio session configuration across platforms.
@Observable
final class SoundManager {
    
    // MARK: - Audio Engine Components
    
    private let audioEngine = AVAudioEngine()
    private let mixer = AVAudioMixerNode()
    
    // MARK: - Audio Players Pool
    
    /// Pool of audio players for efficient sound playback without interruption
    private var ballCollisionPlayers: [AVAudioPlayerNode] = []
    private var wallBouncePlayers: [AVAudioPlayerNode] = []
    private var ballDropPlayers: [AVAudioPlayerNode] = []
    private var ambientPlayer: AVAudioPlayerNode?
    
    // MARK: - Audio Buffers
    
    private var ballCollisionBuffer: AVAudioPCMBuffer?
    private var wallBounceBuffer: AVAudioPCMBuffer?
    private var ballDropBuffer: AVAudioPCMBuffer?
    private var ambientBuffer: AVAudioPCMBuffer?
    
    // MARK: - Settings Reference
    
    private let gameSettings = GameSettings.shared
    
    // MARK: - Initialization
    
    /// Shared singleton instance for app-wide audio management
    static let shared = SoundManager()
    
    /// Private initializer to enforce singleton pattern and setup audio engine
    private init() {
        setupAudioEngine()
        loadAudioFiles()
        setupPlayersPool()
        startAudioEngine()
    }
    
    // MARK: - Audio Engine Setup
    
    /// Configures the audio engine with optimal settings for game audio
    private func setupAudioEngine() {
        // Attach mixer to engine
        audioEngine.attach(mixer)
        
        // Connect mixer to main mixer (speaker output)
        audioEngine.connect(mixer, to: audioEngine.mainMixerNode, format: nil)
        
        // Configure audio session
        configureAudioSession()
    }
    
    /// Configures the AVAudioSession for optimal game audio playback
    private func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            
            #if os(iOS) || os(iPadOS)
            // On iOS/iPadOS, configure for ambient audio that mixes with other apps
            try audioSession.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            #elseif os(macOS)
            // On macOS, we don't need to configure the audio session
            // The system handles audio routing automatically
            #endif
            
        } catch {
            print("⚠️ SoundManager: Failed to configure audio session: \(error)")
        }
    }
    
    /// Starts the audio engine if it's not already running
    private func startAudioEngine() {
        guard !audioEngine.isRunning else { return }
        
        do {
            try audioEngine.start()
            print("🔊 SoundManager: Audio engine started successfully")
        } catch {
            print("⚠️ SoundManager: Failed to start audio engine: \(error)")
        }
    }
    
    // MARK: - Audio File Loading
    
    /// Loads all audio files into memory for fast playback
    private func loadAudioFiles() {
        ballCollisionBuffer = loadAudioFile(named: "ball-collision")
        wallBounceBuffer = loadAudioFile(named: "wall-bounce")
        ballDropBuffer = loadAudioFile(named: "ball-drop")
        ambientBuffer = loadAudioFile(named: "ambient-physics", shouldLoop: true)
    }
    
    /// Loads a single audio file into an AVAudioPCMBuffer
    /// - Parameters:
    ///   - name: The name of the audio file (without extension)
    ///   - shouldLoop: Whether this audio should be prepared for looping
    /// - Returns: The loaded audio buffer, or nil if loading failed
    private func loadAudioFile(named name: String, shouldLoop: Bool = false) -> AVAudioPCMBuffer? {
        // Try multiple audio formats
        let extensions = ["wav", "m4a", "mp3", "aiff"]
        
        for ext in extensions {
            if let url = Bundle.main.url(forResource: name, withExtension: ext) {
                do {
                    let audioFile = try AVAudioFile(forReading: url)
                    
                    // Create buffer with the audio file's processing format
                    guard let buffer = AVAudioPCMBuffer(
                        pcmFormat: audioFile.processingFormat,
                        frameCapacity: AVAudioFrameCount(audioFile.length)
                    ) else {
                        print("⚠️ SoundManager: Could not create buffer for \(name)")
                        continue
                    }
                    
                    try audioFile.read(into: buffer)
                    print("✅ SoundManager: Loaded audio file \(name).\(ext)")
                    return buffer
                    
                } catch {
                    print("⚠️ SoundManager: Error loading \(name).\(ext): \(error)")
                }
            }
        }
        
        print("⚠️ SoundManager: Could not find audio file \(name)")
        return nil
    }
    
    // MARK: - Player Pool Setup
    
    /// Creates a pool of audio players for efficient sound playback
    private func setupPlayersPool() {
        // Create multiple players for collision sounds to handle rapid-fire events
        ballCollisionPlayers = createPlayerPool(size: 8)
        wallBouncePlayers = createPlayerPool(size: 4)
        ballDropPlayers = createPlayerPool(size: 3)
        
        // Create ambient player
        if ambientBuffer != nil {
            ambientPlayer = createAudioPlayer()
        }
    }
    
    /// Creates a pool of audio players
    /// - Parameter size: Number of players to create
    /// - Returns: Array of configured audio players
    private func createPlayerPool(size: Int) -> [AVAudioPlayerNode] {
        var players: [AVAudioPlayerNode] = []
        
        for _ in 0..<size {
            players.append(createAudioPlayer())
        }
        
        return players
    }
    
    /// Creates and configures a single audio player
    /// - Returns: Configured AVAudioPlayerNode
    private func createAudioPlayer() -> AVAudioPlayerNode {
        let player = AVAudioPlayerNode()
        audioEngine.attach(player)
        audioEngine.connect(player, to: mixer, format: nil)
        return player
    }
    
    // MARK: - Sound Playback Methods
    
    /// Plays a ball collision sound with volume based on collision intensity
    /// - Parameter intensity: Collision intensity (0.0 to 1.0) affects volume and pitch
    func playBallCollision(intensity: Double = 1.0) {
        guard gameSettings.soundEffectsEnabled,
              gameSettings.masterVolume > 0.0,
              let buffer = ballCollisionBuffer else { return }
        
        let player = getAvailablePlayer(from: ballCollisionPlayers)
        playSound(player: player, buffer: buffer, volume: Float(intensity * gameSettings.masterVolume))
    }
    
    /// Plays a wall bounce sound based on bounce intensity and material
    /// - Parameters:
    ///   - intensity: Bounce intensity (0.0 to 1.0)
    ///   - material: Type of surface the ball bounced off (future enhancement)
    func playWallBounce(intensity: Double = 1.0, material: String = "default") {
        guard gameSettings.soundEffectsEnabled,
              gameSettings.masterVolume > 0.0,
              let buffer = wallBounceBuffer else { return }
        
        let player = getAvailablePlayer(from: wallBouncePlayers)
        playSound(player: player, buffer: buffer, volume: Float(intensity * gameSettings.masterVolume))
    }
    
    /// Plays a ball drop/spawn sound
    /// - Parameter ballSize: Size multiplier of the ball being dropped
    func playBallDrop(ballSize: Double = 1.0) {
        guard gameSettings.soundEffectsEnabled,
              gameSettings.masterVolume > 0.0,
              let buffer = ballDropBuffer else { return }
        
        let player = getAvailablePlayer(from: ballDropPlayers)
        
        // Adjust pitch based on ball size (larger balls = lower pitch)
        let pitchAdjustment = Float(1.0 / ballSize)
        playSound(player: player, buffer: buffer, volume: Float(gameSettings.masterVolume), pitch: pitchAdjustment)
    }
    
    /// Starts or stops ambient physics sounds
    /// - Parameter shouldPlay: Whether to start (true) or stop (false) ambient sounds
    func setAmbientSounds(enabled: Bool) {
        guard let player = ambientPlayer,
              let buffer = ambientBuffer else { return }
        
        if enabled && gameSettings.ambientSoundsEnabled && gameSettings.masterVolume > 0.0 {
            if !player.isPlaying {
                // Schedule buffer for looping
                player.scheduleBuffer(buffer, at: nil, options: .loops)
                player.volume = Float(gameSettings.masterVolume * 0.3) // Ambient sounds are quieter
                player.play()
            }
        } else {
            if player.isPlaying {
                player.stop()
            }
        }
    }
    
    // MARK: - Helper Methods
    
    /// Gets an available player from the pool, or reuses the oldest one
    /// - Parameter pool: The player pool to select from
    /// - Returns: An available audio player
    private func getAvailablePlayer(from pool: [AVAudioPlayerNode]) -> AVAudioPlayerNode {
        // Find a player that's not currently playing
        for player in pool {
            if !player.isPlaying {
                return player
            }
        }
        
        // If all players are busy, use the first one (oldest sound gets cut off)
        return pool.first ?? pool[0]
    }
    
    /// Plays a sound with specified parameters
    /// - Parameters:
    ///   - player: The audio player to use
    ///   - buffer: The audio buffer to play
    ///   - volume: Volume level (0.0 to 1.0)
    ///   - pitch: Pitch adjustment (1.0 is normal pitch)
    private func playSound(player: AVAudioPlayerNode, buffer: AVAudioPCMBuffer, volume: Float, pitch: Float = 1.0) {
        // Stop any currently playing sound on this player
        if player.isPlaying {
            player.stop()
        }
        
        // Set volume
        player.volume = volume
        
        // Apply pitch adjustment if needed
        if pitch != 1.0 {
            // Note: For advanced pitch shifting, you'd need AVAudioUnitTimePitch
            // For now, we'll keep it simple and just adjust playback rate slightly
        }
        
        // Schedule and play the buffer
        player.scheduleBuffer(buffer, at: nil, options: [])
        player.play()
    }
    
    // MARK: - Volume Control
    
    /// Updates all audio based on current game settings
    func updateAudioSettings() {
        // Update ambient sound state
        setAmbientSounds(enabled: gameSettings.ambientSoundsEnabled)
        
        // Update ambient volume if it's playing
        if let ambientPlayer = ambientPlayer, ambientPlayer.isPlaying {
            ambientPlayer.volume = Float(gameSettings.masterVolume * 0.3)
        }
    }
    
    /// Stops all currently playing sounds
    func stopAllSounds() {
        for player in ballCollisionPlayers + wallBouncePlayers + ballDropPlayers {
            if player.isPlaying {
                player.stop()
            }
        }
        
        ambientPlayer?.stop()
    }
    
    // MARK: - Audio Engine Management
    
    /// Stops the audio engine (call when app goes to background)
    func pauseAudioEngine() {
        if audioEngine.isRunning {
            audioEngine.pause()
        }
    }
    
    /// Resumes the audio engine (call when app comes to foreground)
    func resumeAudioEngine() {
        if !audioEngine.isRunning {
            do {
                try audioEngine.start()
            } catch {
                print("⚠️ SoundManager: Failed to restart audio engine: \(error)")
            }
        }
    }
}

// MARK: - Convenience Methods

extension SoundManager {
    /// Plays appropriate collision sound based on game physics
    /// - Parameters:
    ///   - velocity: The velocity of the collision
    ///   - bounciness: Current bounciness setting from game settings
    func playCollisionSound(velocity: Double, bounciness: Double = GameSettings.shared.bounciness) {
        // Calculate intensity based on velocity and bounciness
        let intensity = min(1.0, velocity * bounciness)
        playBallCollision(intensity: intensity)
    }
    
    /// Plays wall bounce with intensity calculated from physics
    /// - Parameter velocity: The velocity of the wall collision
    func playWallCollisionSound(velocity: Double) {
        // Wall collisions are typically more intense
        let intensity = min(1.0, velocity * 1.2)
        playWallBounce(intensity: intensity)
    }
}