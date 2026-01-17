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
/// This class provides a simple audio playback system for ball bounce sounds.
/// Different ball types play different sounds based on their physical properties.
@Observable
final class SoundManager {
    
    // MARK: - Audio Engine Components
    
    private let audioEngine = AVAudioEngine()
    private let mixer = AVAudioMixerNode()
    
    // MARK: - Audio Players Pool
    
    /// Pool of audio players for bounce sounds
    private var bouncePlayers: [AVAudioPlayerNode] = []
    
    // MARK: - Audio Buffers
    
    private var boingBuffer: AVAudioPCMBuffer?
    private var rubberBallBuffer: AVAudioPCMBuffer?
    private var sportsBallBuffer: AVAudioPCMBuffer?
    private var pingPongBallBuffer: AVAudioPCMBuffer?
    
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
        #if os(iOS) || os(iPadOS)
        do {
            let audioSession = AVAudioSession.sharedInstance()
            // Use .playback category so sounds play even when device is on silent
            // This is appropriate for games where sound is an important part of the experience
            try audioSession.setCategory(.playback, mode: .default, options: [])
            try audioSession.setActive(true)
        } catch {
            print("⚠️ SoundManager: Failed to configure audio session: \(error)")
        }
        #endif
    }
    
    /// Starts the audio engine if it's not already running
    private func startAudioEngine() {
        guard !audioEngine.isRunning else { return }
        
        do {
            try audioEngine.start()
        } catch {
            print("⚠️ SoundManager: Failed to start audio engine: \(error)")
        }
    }
    
    // MARK: - Audio File Loading
    
    /// Loads all audio files into memory for fast playback
    private func loadAudioFiles() {
        boingBuffer = loadAudioFile(named: "boing")
        rubberBallBuffer = loadAudioFile(named: "rubber-ball")
        sportsBallBuffer = loadAudioFile(named: "sports-ball")
        pingPongBallBuffer = loadAudioFile(named: "ping-pong-ball")
    }
    
    /// Loads a single audio file into an AVAudioPCMBuffer
    /// - Parameters:
    ///   - name: The name of the audio file (without extension)
    ///   - shouldLoop: Whether this audio should be prepared for looping
    /// - Returns: The loaded audio buffer, or nil if loading failed
    private func loadAudioFile(named name: String, shouldLoop: Bool = false) -> AVAudioPCMBuffer? {
        // Try multiple audio formats
        let extensions = ["wav", "m4a", "mp3", "aiff"]
        
        // Common format for all players (44.1kHz stereo)
        guard let commonFormat = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2) else {
            print("⚠️ SoundManager: Could not create common audio format")
            return nil
        }
        
        for ext in extensions {
            if let url = Bundle.main.url(forResource: name, withExtension: ext) {
                do {
                    let audioFile = try AVAudioFile(forReading: url)
                    let sourceFormat = audioFile.processingFormat
                    
                    // Create converter if formats don't match
                    guard let converter = AVAudioConverter(from: sourceFormat, to: commonFormat) else {
                        print("⚠️ SoundManager: Could not create converter for \(name)")
                        continue
                    }
                    
                    // Calculate the capacity needed for the converted buffer
                    let capacity = AVAudioFrameCount(Double(audioFile.length) * commonFormat.sampleRate / sourceFormat.sampleRate)
                    
                    guard let convertedBuffer = AVAudioPCMBuffer(pcmFormat: commonFormat, frameCapacity: capacity) else {
                        print("⚠️ SoundManager: Could not create converted buffer for \(name)")
                        continue
                    }
                    
                    // Read source buffer
                    guard let sourceBuffer = AVAudioPCMBuffer(pcmFormat: sourceFormat, frameCapacity: AVAudioFrameCount(audioFile.length)) else {
                        print("⚠️ SoundManager: Could not create source buffer for \(name)")
                        continue
                    }
                    
                    try audioFile.read(into: sourceBuffer)
                    sourceBuffer.frameLength = AVAudioFrameCount(audioFile.length)
                    
                    // Convert the audio
                    var error: NSError?
                    let inputBlock: AVAudioConverterInputBlock = { inNumPackets, outStatus in
                        outStatus.pointee = .haveData
                        return sourceBuffer
                    }
                    
                    converter.convert(to: convertedBuffer, error: &error, withInputFrom: inputBlock)
                    
                    if let error = error {
                        print("⚠️ SoundManager: Conversion error for \(name): \(error)")
                        continue
                    }
                    
                    print("✅ SoundManager: Loaded audio file \(name).\(ext)")
                    return convertedBuffer
                    
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
        // Create multiple players for bounce sounds (to handle multiple simultaneous bounces)
        bouncePlayers = createPlayerPool(size: 10)
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
        
        // Use a common format that all audio files should match
        // Standard format: 44.1kHz, stereo (or we can convert)
        let commonFormat = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2)
        audioEngine.connect(player, to: mixer, format: commonFormat)
        
        return player
    }
    
    // MARK: - Sound Playback Methods
    
    /// Plays a bounce sound based on ball type with intensity-based volume
    /// - Parameters:
    ///   - soundName: The sound identifier ("boing", "rubber-ball", "sports-ball", "ping-pong-ball")
    ///   - intensity: Impact intensity (0.0 to 1.0) affects volume
    func playBounceSound(soundName: String, intensity: Double = 1.0) {
        guard gameSettings.soundEffectsEnabled,
              gameSettings.masterVolume > 0.0 else {
            return
        }
        
        // Get the appropriate buffer for this sound
        let buffer: AVAudioPCMBuffer?
        switch soundName {
        case "boing":
            buffer = boingBuffer
        case "rubber-ball":
            buffer = rubberBallBuffer
        case "sports-ball":
            buffer = sportsBallBuffer
        case "ping-pong-ball":
            buffer = pingPongBallBuffer
        default:
            buffer = nil
        }
        
        guard let audioBuffer = buffer else { return }
        
        let player = getAvailablePlayer(from: bouncePlayers)
        
        // Calculate volume based on intensity and master volume
        // Use a minimum volume of 0.3 so even soft bounces are audible
        let minVolume: Float = 0.3
        let volume = Float(gameSettings.masterVolume) * (minVolume + Float(intensity) * (1.0 - minVolume))
        
        playSound(player: player, buffer: audioBuffer, volume: volume)
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
        // Make sure audio engine is running
        if !audioEngine.isRunning {
            startAudioEngine()
        }
        
        // Stop any currently playing sound on this player
        if player.isPlaying {
            player.stop()
        }
        
        // Set volume
        player.volume = volume
        
        // Schedule and play the buffer
        player.scheduleBuffer(buffer, at: nil, options: [])
        player.play()
    }
    
    // MARK: - Volume Control
    
    /// Updates all audio based on current game settings
    func updateAudioSettings() {
        // Audio settings are checked on each playback, so no action needed here
    }
    
    /// Stops all currently playing sounds
    func stopAllSounds() {
        for player in bouncePlayers {
            if player.isPlaying {
                player.stop()
            }
        }
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

// MARK: - Preview Support

#if DEBUG
extension SoundManager {
    /// Plays a test sound for debugging
    func playTestSound() {
        playBounceSound(soundName: "boing", intensity: 1.0)
    }
}
#endif
