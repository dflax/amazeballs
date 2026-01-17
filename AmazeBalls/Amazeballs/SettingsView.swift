//
//  SettingsView.swift
//  Amazeballs
//
//  Created by Daniel Flax on 11/15/25.
//

import SwiftUI

/**
 * SettingsView
 *
 * A comprehensive cross-platform settings interface that adapts to iOS and macOS design patterns
 * while providing a consistent user experience for configuring ball physics and game features.
 *
 * ## Platform Adaptations
 * - **iOS**: List-based interface with sections and cards
 * - **macOS**: Form-based interface with proper alignment and spacing
 * - **Shared**: Real-time updates, accessibility, and visual feedback
 *
 * ## Features
 * - **Real-time physics updates**: Changes immediately affect the simulation
 * - **Platform-appropriate controls**: Native sliders, toggles, and buttons
 * - **Accessibility support**: VoiceOver labels, hints, and traits
 * - **Visual feedback**: Smooth animations and value formatting
 * - **Reset confirmation**: Alert dialog prevents accidental resets
 * - **CloudKit sync**: Automatic synchronization across all devices
 * - **Ball type selection**: Choose specific ball types or random selection
 * - **Platform capability detection**: Shows what's supported on current device
 *
 * ## Settings Controls
 * - **Gravity**: 0.0 - 4.0x with 1 decimal precision
 * - **Bounciness**: 0 - 130% with percentage display
 * - **Boundary Walls**: Toggle with clear on/off state
 * - **Device Motion**: Toggle with platform availability indication
 * - **Ball Type**: Picker for specific ball types or random selection
 * - **Reset**: Confirmation dialog with destructive styling
 */
struct SettingsView: View {
    
    // MARK: - Properties
    
    /// Game settings that control physics behavior and sync via CloudKit
    @Bindable private var settings = GameSettings.shared
    
    /// Controls the reset confirmation alert
    @State private var showingResetAlert = false
    
    /// Controls the ball picker sheet presentation
    @State private var showingBallPicker = false
    
    /// Environment value for dismissing sheets
    @Environment(\.dismiss) private var dismiss
    
    /// Accessibility setting for reduced motion
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    // MARK: - Body
    
    var body: some View {
        #if os(macOS)
        macOSSettingsView
        #else
        iOSSettingsView
        #endif
    }
    
    // MARK: - iOS Interface
    
    #if !os(macOS)
    /**
     * iOS-style settings interface using NavigationStack with sections
     */
    private var iOSSettingsView: some View {
        NavigationStack {
            List {
                physicsSettingsSection
                audioSettingsSection
                gameplaySettingsSection
                platformSupportSection
                debugInfoSection
                aboutSection
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .accessibilityLabel("Close settings")
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .alert("Reset Settings", isPresented: $showingResetAlert) {
            resetAlertButtons
        } message: {
            resetAlertMessage
        }
        .sheet(isPresented: $showingBallPicker) {
            BallPickerSheet(gameSettings: settings)
        }
    }
    #endif
    
    // MARK: - macOS Interface
    
    #if os(macOS)
    /**
     * macOS-style settings interface using Form with proper alignment
     */
    private var macOSSettingsView: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Amazeballs Settings")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Done") {
                    dismiss()
                }
                .keyboardShortcut(.return, modifiers: [])
                .accessibilityLabel("Close settings")
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(.regularMaterial)
            
            // Settings form
            Form {
                macOSPhysicsSection
                macOSAudioSection
                macOSGameplaySection
                macOSPlatformSection
                macOSActionsSection
            }
            .formStyle(.grouped)
            .scrollContentBackground(.hidden)
            .background(Color(NSColor.controlBackgroundColor))
        }
        .frame(width: 480, height: 520)
        .alert("Reset Settings", isPresented: $showingResetAlert) {
            resetAlertButtons
        } message: {
            resetAlertMessage
        }
        .sheet(isPresented: $showingBallPicker) {
            BallPickerSheet(gameSettings: settings)
        }
    }
    #endif
    
    // MARK: - Settings Sections (iOS)
    
    /**
     * Physics settings section for iOS
     */
    private var physicsSettingsSection: some View {
        Section {
            gravitySliderRow
            bouncinessSliderRow
            ballSizeSliderRow
            ballSizeModeRow
        } header: {
            sectionHeader("Physics", systemImage: "atom")
        } footer: {
            Text("Adjust how balls behave when they move and collide.")
                .accessibilityHidden(true)
        }
    }
    
    /**
     * Audio settings section for iOS
     */
    private var audioSettingsSection: some View {
        Section {
            masterVolumeSliderRow
            soundEffectsToggleRow
        } header: {
            sectionHeader("Audio", systemImage: "speaker.wave.2")
        } footer: {
            Text(audioSectionFooterText)
                .accessibilityHidden(true)
        }
    }
    
    /**
     * Gameplay settings section for iOS
     */
    private var gameplaySettingsSection: some View {
        Section {
            wallsToggleRow
            accelerometerToggleRow
            ballTypeSelectionRow
        } header: {
            sectionHeader("Gameplay", systemImage: "gamecontroller")
        } footer: {
            Text("Configure the physics environment and ball types.")
                .accessibilityHidden(true)
        }
    }
    
    /**
     * Platform support section for iOS
     */
    private var platformSupportSection: some View {
        Section {
            LabeledContent("Current Platform", value: currentPlatformName())
            
            Label("Accelerometer", systemImage: settings.isAccelerometerSupported ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(settings.isAccelerometerSupported ? .green : .red)
            
            Label("Screen Walls", systemImage: settings.areWallsSupported ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(settings.areWallsSupported ? .green : .red)
            
            Label("CloudKit Sync", systemImage: settings.isCloudKitAvailable ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(settings.isCloudKitAvailable ? .green : .orange)
            
            resetButton
        } header: {
            sectionHeader("Platform & Actions", systemImage: "gear")
        }
    }
    
    /**
     * Debug info section for iOS
     */
    private var debugInfoSection: some View {
        Section {
            DisclosureGroup("Current Settings") {
                let debugInfo = settings.debugDescription()
                ForEach(debugInfo.keys.sorted(), id: \.self) { key in
                    LabeledContent(key.capitalized, value: "\(debugInfo[key] ?? "nil")")
                        .font(.caption)
                }
            }
            
            Button("Validate Settings") {
                let isValid = settings.validateSettings()
                print("Settings validation: \(isValid ? "✅ Valid" : "❌ Invalid")")
            }
            .font(.caption)
            
            Button("Test CloudKit Status") {
                Task {
                    // Re-check CloudKit availability
                    await GameSettings.shared.refreshCloudKitStatus()
                }
            }
            .font(.caption)
            
            Button("Test Sound Effects") {
                testSoundEffects()
            }
            .font(.caption)
            .disabled(!settings.soundEffectsEnabled || settings.masterVolume == 0.0)
        } header: {
            sectionHeader("Debug Info", systemImage: "info.circle")
        }
    }
    
    /**
     * About section for iOS
     */
    private var aboutSection: some View {
        Section {
            HStack {
                Image(systemName: "info.circle")
                    .foregroundStyle(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("About Amazeballs")
                        .font(.headline)
                    
                    Text("Physics ball simulation with realistic interactions and cross-platform CloudKit sync")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            .padding(.vertical, 4)
        }
    }
    
    // MARK: - macOS Sections
    
    #if os(macOS)
    /**
     * Physics settings section for macOS
     */
    private var macOSPhysicsSection: some View {
        Section("Physics") {
            macOSGravityRow
            macOSBouncinessRow
            macOSBallSizeRow
            macOSBallSizeModeRow
        }
    }
    
    /**
     * Audio settings section for macOS
     */
    private var macOSAudioSection: some View {
        Section("Audio") {
            macOSMasterVolumeRow
            macOSSoundEffectsRow
        }
    }
    
    /**
     * Gameplay settings section for macOS
     */
    private var macOSGameplaySection: some View {
        Section("Gameplay") {
            macOSWallsRow
            macOSAccelerometerRow
            macOSBallTypeRow
        }
    }
    
    /**
     * Platform support section for macOS
     */
    private var macOSPlatformSection: some View {
        Section("Platform Support") {
            LabeledContent("Current Platform", value: currentPlatformName())
            
            Label("Accelerometer", systemImage: settings.isAccelerometerSupported ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(settings.isAccelerometerSupported ? .green : .red)
            
            Label("CloudKit Sync", systemImage: settings.isCloudKitAvailable ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(settings.isCloudKitAvailable ? .green : .orange)
        }
    }
    
    /**
     * Actions section for macOS
     */
    private var macOSActionsSection: some View {
        Section {
            HStack {
                Spacer()
                resetButton
            }
        }
    }
    #endif
    
    // MARK: - Control Rows
    
    /**
     * Gravity slider control
     */
    private var gravitySliderRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("Gravity", systemImage: "arrow.down.circle")
                    .foregroundStyle(.blue)
                
                Spacer()
                
                Text("\(settings.gravity, specifier: "%.1f")×")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .accessibilityLabel("Gravity: \(settings.gravity, specifier: "%.1f") times normal")
            }
            
            Slider(
                value: $settings.gravity,
                in: 0.0...4.0,
                step: 0.1
            ) {
                Text("Gravity")
            } minimumValueLabel: {
                Image(systemName: "arrow.up")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            } maximumValueLabel: {
                Image(systemName: "arrow.down")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .tint(.blue)
            .accessibilityLabel("Gravity slider")
            .accessibilityValue("\(settings.gravity, specifier: "%.1f") times normal gravity")
            .accessibilityHint("Adjust how fast balls fall")
        }
        .padding(.vertical, 4)
    }
    
    /**
     * Bounciness slider control
     */
    private var bouncinessSliderRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("Bounciness", systemImage: "arrow.up.bounce")
                    .foregroundStyle(.green)
                
                Spacer()
                
                Text("\(Int(settings.bounciness * 100))%")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .accessibilityLabel("Bounciness: \(Int(settings.bounciness * 100)) percent")
            }
            
            Slider(
                value: $settings.bounciness,
                in: 0.0...1.3,
                step: 0.1
            ) {
                Text("Bounciness")
            } minimumValueLabel: {
                Text("💤")
                    .font(.caption2)
            } maximumValueLabel: {
                Text("🏀")
                    .font(.caption2)
            }
            .tint(.green)
            .accessibilityLabel("Bounciness slider")
            .accessibilityValue("\(Int(settings.bounciness * 100)) percent")
            .accessibilityHint("Adjust how much balls bounce when they collide")
        }
        .padding(.vertical, 4)
    }
    
    /**
     * Ball size slider control
     */
    private var ballSizeSliderRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("Ball Size", systemImage: "circle.circle")
                    .foregroundStyle(.pink)
                
                Spacer()
                
                Text(sliderTrailingText)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(settings.ballSizeMode == .fixed ? .primary : .secondary)
                    .accessibilityLabel(sliderAccessibilityLabel)
            }
            
            Slider(
                value: $settings.ballSize,
                in: 0.5...5.0,
                step: 0.1
            ) {
                Text("Ball Size")
            } minimumValueLabel: {
                Text("●")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            } maximumValueLabel: {
                Text("●")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
            .tint(.pink)
            .disabled(settings.ballSizeMode != .fixed)
            .accessibilityLabel("Ball size slider")
            .accessibilityValue(settings.ballSizeMode == .fixed ? "\(settings.ballSize, specifier: "%.1f") times normal size" : "Disabled")
            .accessibilityHint(settings.ballSizeMode == .fixed ? "Adjust the size of dropped balls" : (settings.ballSizeMode == .random ? "Random ball size is enabled" : "Press and hold to grow balls"))
        }
        .padding(.vertical, 4)
    }
    
    /**
     * Ball size mode segmented picker row
     */
    private var ballSizeModeRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Ball Size Mode", systemImage: "dial.medium")
                .foregroundStyle(.pink)

            Picker("Ball Size Mode", selection: $settings.ballSizeMode) {
                Text("Fixed").tag(GameSettings.BallSizeMode.fixed)
                Text("Random").tag(GameSettings.BallSizeMode.random)
                Text("Press & Hold").tag(GameSettings.BallSizeMode.pressAndGrow)
            }
            .pickerStyle(.segmented)
            .accessibilityLabel("Ball size mode")

            // Contextual help text
            Group {
                switch settings.ballSizeMode {
                case .fixed:
                    Text("Use the slider to set a fixed size for all balls.")
                case .random:
                    Text("Each ball spawns with a random size between min and max.")
                case .pressAndGrow:
                    Text("Press and hold to grow the ball from min to max size.")
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - Audio Control Rows
    
    /**
     * Master volume slider control
     */
    private var masterVolumeSliderRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("Master Volume", systemImage: "speaker.wave.2")
                    .foregroundStyle(.blue)
                
                Spacer()
                
                Text("\(Int(settings.masterVolumePercentage))%")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .accessibilityLabel("Master volume: \(Int(settings.masterVolumePercentage)) percent")
            }
            
            Slider(
                value: $settings.masterVolumePercentage,
                in: 0.0...100.0,
                step: 5.0
            ) {
                Text("Master Volume")
            } minimumValueLabel: {
                Image(systemName: "speaker.slash")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            } maximumValueLabel: {
                Image(systemName: "speaker.wave.3")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .tint(.blue)
            .accessibilityLabel("Master volume slider")
            .accessibilityValue("\(Int(settings.masterVolumePercentage)) percent")
            .accessibilityHint("Adjust overall game audio volume")
        }
        .padding(.vertical, 4)
    }
    
    /**
     * Sound effects toggle control
     */
    private var soundEffectsToggleRow: some View {
        Toggle(isOn: $settings.soundEffectsEnabled.animation(reduceMotion ? nil : .easeInOut(duration: 0.2))) {
            Label {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Sound Effects")
                        .font(.body)
                    
                    Text("Ball collisions, bounces, and drops")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } icon: {
                Image(systemName: "waveform")
                    .foregroundStyle(.green)
            }
        }
        .tint(.green)
        .accessibilityLabel("Sound effects")
        .accessibilityValue(settings.soundEffectsEnabled ? "Enabled" : "Disabled")
        .accessibilityHint("Toggle collision and interaction sounds")
        .onChange(of: settings.soundEffectsEnabled) { _, newValue in
            // Update sound manager when settings change
            SoundManager.shared.updateAudioSettings()
            
            // Play a test sound when enabling
            if newValue && settings.masterVolume > 0.0 {
                SoundManager.shared.playBounceSound(soundName: "boing", intensity: 1.0)
            }
        }
    }
    
    /**
     * Walls toggle control
     */
    private var wallsToggleRow: some View {
        Toggle(isOn: $settings.wallsEnabled.animation(reduceMotion ? nil : .easeInOut(duration: 0.2))) {
            Label {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Screen Walls")
                        .font(.body)
                    
                    Text("Invisible walls keep balls on screen")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } icon: {
                Image(systemName: settings.wallsEnabled ? "square.3.layers.3d.top.filled" : "square.3.layers.3d")
                    .foregroundStyle(.orange)
            }
        }
        .tint(.orange)
        .accessibilityLabel("Screen walls")
        .accessibilityValue(settings.wallsEnabled ? "Enabled" : "Disabled")
        .accessibilityHint("Toggle invisible walls that keep balls on screen")
    }
    
    /**
     * Accelerometer toggle control
     */
    private var accelerometerToggleRow: some View {
        Toggle(isOn: $settings.accelerometerEnabled.animation(reduceMotion ? nil : .easeInOut(duration: 0.2))) {
            Label {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Device Motion")
                        .font(.body)
                    
                    Text(accelerometerDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } icon: {
                Image(systemName: "gyroscope")
                    .foregroundStyle(settings.isAccelerometerSupported ? .purple : .gray)
            }
        }
        .tint(.purple)
        .disabled(!settings.isAccelerometerSupported)
        .accessibilityLabel("Device motion")
        .accessibilityValue(settings.accelerometerEnabled ? "Enabled" : "Disabled")
        .accessibilityHint(settings.isAccelerometerSupported ? 
                          "Toggle device tilting to control gravity direction" : 
                          "Not available on this device")
    }
    
    /**
     * Ball type selection row with sheet presentation
     */
    private var ballTypeSelectionRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Ball Type", systemImage: "volleyball")
                .foregroundStyle(.mint)
            
            Button(action: { showingBallPicker = true }) {
                HStack {
                    // Current ball image or random icon
                    if let ballType = settings.selectedBallType {
                        BallAssetManager.shared.ballImageView(for: ballType)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                    } else {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                            .frame(width: 24, height: 24)
                    }
                    
                    // Ball name
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Current Selection")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        
                        Text(currentBallDisplayName)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
                .contentShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Ball type selection")
            .accessibilityValue(currentBallDisplayName)
            .accessibilityHint("Tap to choose a different ball type")
        }
        .padding(.vertical, 4)
    }
    
    /**
     * Reset button with destructive styling
     */
    private var resetButton: some View {
        Button(role: .destructive, action: { showingResetAlert = true }) {
            Label("Reset to Defaults", systemImage: "arrow.counterclockwise")
        }
        .accessibilityLabel("Reset all settings to defaults")
        .accessibilityHint("Shows confirmation dialog before resetting")
    }
    
    // MARK: - macOS Specific Rows
    
    #if os(macOS)
    /**
     * macOS-style gravity control
     */
    private var macOSGravityRow: some View {
        HStack(alignment: .center, spacing: 16) {
            Label("Gravity", systemImage: "arrow.down.circle")
                .foregroundStyle(.blue)
                .frame(width: 100, alignment: .leading)
            
            Slider(
                value: $settings.gravity,
                in: 0.0...4.0,
                step: 0.1
            ) {
                Text("Gravity")
            } minimumValueLabel: {
                Text("0")
                    .font(.caption)
            } maximumValueLabel: {
                Text("4")
                    .font(.caption)
            }
            .tint(.blue)
            
            Text("\(settings.gravity, specifier: "%.1f")×")
                .font(.body)
                .fontWeight(.medium)
                .frame(width: 50, alignment: .trailing)
                .accessibilityLabel("Gravity: \(settings.gravity, specifier: "%.1f") times normal")
        }
        .accessibilityElement(children: .combine)
    }
    
    /**
     * macOS-style bounciness control
     */
    private var macOSBouncinessRow: some View {
        HStack(alignment: .center, spacing: 16) {
            Label("Bounciness", systemImage: "arrow.up.bounce")
                .foregroundStyle(.green)
                .frame(width: 100, alignment: .leading)
            
            Slider(
                value: $settings.bounciness,
                in: 0.0...1.3,
                step: 0.1
            ) {
                Text("Bounciness")
            } minimumValueLabel: {
                Text("0%")
                    .font(.caption)
            } maximumValueLabel: {
                Text("100%")
                    .font(.caption)
            }
            .tint(.green)
            
            Text("\(Int(settings.bounciness * 100))%")
                .font(.body)
                .fontWeight(.medium)
                .frame(width: 50, alignment: .trailing)
                .accessibilityLabel("Bounciness: \(Int(settings.bounciness * 100)) percent")
        }
        .accessibilityElement(children: .combine)
    }
    
    /**
     * macOS-style ball size control
     */
    private var macOSBallSizeRow: some View {
        HStack(alignment: .center, spacing: 16) {
            Label("Ball Size", systemImage: "circle.circle")
                .foregroundStyle(.pink)
                .frame(width: 100, alignment: .leading)
            
            Slider(
                value: $settings.ballSize,
                in: 0.5...5.0,
                step: 0.1
            ) {
                Text("Ball Size")
            } minimumValueLabel: {
                Text("0.5×")
                    .font(.caption)
            } maximumValueLabel: {
                Text("5×")
                    .font(.caption)
            }
            .tint(.pink)
            .disabled(settings.ballSizeMode != .fixed)
            
            Text(sliderTrailingText)
                .font(.body)
                .fontWeight(.medium)
                .frame(width: 80, alignment: .trailing)
                .foregroundStyle(settings.ballSizeMode == .fixed ? .primary : .secondary)
                .accessibilityLabel(sliderAccessibilityLabel)
        }
        .accessibilityElement(children: .combine)
    }
    
    /**
     * macOS-style ball size mode picker control
     */
    private var macOSBallSizeModeRow: some View {
        HStack(alignment: .center, spacing: 16) {
            Label("Ball Size Mode", systemImage: "dial.medium")
                .foregroundStyle(.pink)
                .frame(width: 100, alignment: .leading)

            Picker("Ball Size Mode", selection: $settings.ballSizeMode) {
                Text("Fixed").tag(GameSettings.BallSizeMode.fixed)
                Text("Random").tag(GameSettings.BallSizeMode.random)
                Text("Press & Hold").tag(GameSettings.BallSizeMode.pressAndGrow)
            }
            .pickerStyle(.segmented)

            Spacer()
        }
        .accessibilityElement(children: .combine)
    }
    
    // MARK: - macOS Audio Controls
    
    /**
     * macOS-style master volume control
     */
    private var macOSMasterVolumeRow: some View {
        HStack(alignment: .center, spacing: 16) {
            Label("Master Volume", systemImage: "speaker.wave.2")
                .foregroundStyle(.blue)
                .frame(width: 100, alignment: .leading)
            
            Slider(
                value: $settings.masterVolumePercentage,
                in: 0.0...100.0,
                step: 5.0
            ) {
                Text("Master Volume")
            } minimumValueLabel: {
                Image(systemName: "speaker.slash")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } maximumValueLabel: {
                Image(systemName: "speaker.wave.3")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .tint(.blue)
            .disabled(!settings.soundEffectsEnabled && !settings.ambientSoundsEnabled)
            
            Text("\(Int(settings.masterVolumePercentage))%")
                .font(.body)
                .fontWeight(.medium)
                .frame(width: 50, alignment: .trailing)
                .accessibilityLabel("Master volume: \(Int(settings.masterVolumePercentage)) percent")
        }
        .accessibilityElement(children: .combine)
    }
    
    /**
     * macOS-style sound effects toggle
     */
    private var macOSSoundEffectsRow: some View {
        Toggle(isOn: $settings.soundEffectsEnabled) {
            Label("Sound Effects", systemImage: "waveform")
                .foregroundStyle(.green)
        }
        .tint(.green)
        .accessibilityLabel("Sound effects")
        .accessibilityValue(settings.soundEffectsEnabled ? "Enabled" : "Disabled")
        .help("Enable collision and interaction sounds")
        .onChange(of: settings.soundEffectsEnabled) { _, newValue in
            // Update sound manager when settings change
            SoundManager.shared.updateAudioSettings()
            
            // Play a test sound when enabling
            if newValue && settings.masterVolume > 0.0 {
                SoundManager.shared.playBounceSound(soundName: "boing", intensity: 1.0)
            }
        }
    }
    
    /**
     * macOS-style walls toggle
     */
    private var macOSWallsRow: some View {
        Toggle(isOn: $settings.wallsEnabled) {
            Label("Screen Walls", systemImage: settings.wallsEnabled ? "square.3.layers.3d.top.filled" : "square.3.layers.3d")
                .foregroundStyle(.orange)
        }
        .tint(.orange)
        .accessibilityLabel("Screen walls")
        .accessibilityValue(settings.wallsEnabled ? "Enabled" : "Disabled")
        .help("When enabled, invisible walls prevent balls from leaving the screen")
    }
    
    /**
     * macOS-style accelerometer toggle
     */
    private var macOSAccelerometerRow: some View {
        Toggle(isOn: $settings.accelerometerEnabled) {
            Label("Device Motion", systemImage: "gyroscope")
                .foregroundStyle(settings.isAccelerometerSupported ? .purple : .gray)
        }
        .tint(.purple)
        .disabled(!settings.isAccelerometerSupported)
        .accessibilityLabel("Device motion")
        .accessibilityValue(settings.accelerometerEnabled ? "Enabled" : "Disabled")
        .help(settings.isAccelerometerSupported ? 
              "Use device tilting to control gravity" : 
              "Motion sensors not available on this device")
    }
    
    /**
     * macOS-style ball type selection
     */
    private var macOSBallTypeRow: some View {
        HStack(alignment: .center, spacing: 16) {
            Label("Ball Type", systemImage: "volleyball")
                .foregroundStyle(.mint)
                .frame(width: 100, alignment: .leading)
            
            Button(action: { showingBallPicker = true }) {
                HStack(spacing: 12) {
                    // Current ball image or random icon
                    if let ballType = settings.selectedBallType {
                        BallAssetManager.shared.ballImageView(for: ballType)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                    } else {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .frame(width: 20, height: 20)
                    }
                    
                    Text(currentBallDisplayName)
                        .font(.body)
                    
                    Image(systemName: "chevron.right")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color(.controlBackgroundColor), in: RoundedRectangle(cornerRadius: 6))
                .contentShape(RoundedRectangle(cornerRadius: 6))
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
    }
    #endif
    
    // MARK: - Helper Views
    
    /**
     * Creates a section header with icon
     */
    private func sectionHeader(_ title: String, systemImage: String) -> some View {
        Label(title, systemImage: systemImage)
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundStyle(.primary)
    }
    
    /**
     * Reset alert buttons
     */
    private var resetAlertButtons: some View {
        Group {
            Button("Cancel", role: .cancel) { }
            
            Button("Reset", role: .destructive) {
                withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.3)) {
                    settings.reset()
                }
                
                // Provide haptic feedback on iOS
                #if os(iOS)
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
                #endif
            }
            .accessibilityLabel("Confirm reset to defaults")
        }
    }
    
    /**
     * Reset alert message
     */
    private var resetAlertMessage: some View {
        Text("This will restore all physics settings to their original values and sync the changes across all your devices. This action cannot be undone.")
    }
    
    // MARK: - Helper Methods
    
    /**
     * Returns the current platform name
     */
    private func currentPlatformName() -> String {
        #if os(iOS)
        return "iOS"
        #elseif os(iPadOS) 
        return "iPadOS"
        #elseif os(macOS)
        return "macOS"
        #elseif os(watchOS)
        return "watchOS"
        #elseif os(visionOS)
        return "visionOS"
        #else
        return "Unknown"
        #endif
    }
    
    /**
     * Platform-appropriate accelerometer description
     */
    private var accelerometerDescription: String {
        if settings.isAccelerometerSupported {
            return "Tilt device to control gravity direction"
        } else {
            return "Not available on this device"
        }
    }
    
    /**
     * Audio section footer text
     */
    private var audioSectionFooterText: String {
        if settings.masterVolume == 0.0 {
            return "All sounds are muted"
        } else if !settings.soundEffectsEnabled {
            return "Sound effects are disabled"
        } else {
            return "A subtle sound plays when you drop a ball"
        }
    }
    
    /**
     * Display name for current ball selection
     */
    private var currentBallDisplayName: String {
        if let ballType = settings.selectedBallType {
            return BallAssetManager.shared.displayName(for: ballType)
        } else {
            return "Random"
        }
    }
    
    /**
     * Test sound effects helper method
     */
    private func testSoundEffects() {
        Task {
            // Test bounce sounds with different intensities
            SoundManager.shared.playBounceSound(soundName: "boing", intensity: 1.0)
            
            // Wait a bit, then test with a different sound
            try? await Task.sleep(nanoseconds: 400_000_000) // 0.4 seconds
            SoundManager.shared.playBounceSound(soundName: "sports-ball", intensity: 0.8)
            
            // Wait a bit, then test with another sound
            try? await Task.sleep(nanoseconds: 400_000_000) // 0.4 seconds
            SoundManager.shared.playBounceSound(soundName: "rubber-ball", intensity: 0.6)
        }
    }
    
    // MARK: - New Helpers for Ball Size Mode
    
    private var sliderTrailingText: String {
        switch settings.ballSizeMode {
        case .fixed:
            return String(format: "%.1f×", settings.ballSize)
        case .random:
            return "Random"
        case .pressAndGrow:
            return "Press & Hold"
        }
    }

    private var sliderAccessibilityLabel: String {
        switch settings.ballSizeMode {
        case .fixed:
            return "Ball size: \(String(format: "%.1f", settings.ballSize)) times normal"
        case .random:
            return "Ball size: Random"
        case .pressAndGrow:
            return "Ball size: Press and hold to grow"
        }
    }
}

// MARK: - Preview

#Preview("iOS Settings") {
    SettingsView()
        .preferredColorScheme(.dark)
}

#Preview("macOS Settings") {
    SettingsView()
        .preferredColorScheme(.dark)
        .frame(width: 500, height: 600)
}

#Preview("iOS Settings - Light") {
    SettingsView()
        .preferredColorScheme(.light)
}

/**
 * Preview helper for testing different states
 */
#Preview("Settings with Custom Values") {
    SettingsView()
        .onAppear {
            let settings = GameSettings.shared
            settings.gravity = 1.5
            settings.bounciness = 0.3
            settings.wallsEnabled = false
            settings.accelerometerEnabled = true
            settings.selectedBallType = "Basketball"
        }
        .preferredColorScheme(.dark)
}

