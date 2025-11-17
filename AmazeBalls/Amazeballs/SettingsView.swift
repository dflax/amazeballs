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
 * - **Gravity**: 0.0 - 2.0x with 1 decimal precision
 * - **Bounciness**: 0 - 100% with percentage display
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
        } header: {
            sectionHeader("Physics", systemImage: "atom")
        } footer: {
            Text("Adjust how balls behave when they move and collide.")
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
            
            Label {
                Text("Accelerometer")
            } icon: {
                Image(systemName: settings.isAccelerometerSupported ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(settings.isAccelerometerSupported ? .green : .red)
            }
            
            Label {
                Text("Screen Walls")
            } icon: {
                Image(systemName: settings.areWallsSupported ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(settings.areWallsSupported ? .green : .red)
            }
            
            Label {
                Text("CloudKit Sync")
            } icon: {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
            
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
                let debugInfo = settings.debugDescriptionWithBalls()
                ForEach(debugInfo.keys.sorted(), id: \.self) { key in
                    LabeledContent(key.capitalized, value: "\(debugInfo[key] ?? "nil")")
                        .font(.caption)
                }
            }
            
            Button("Validate Settings") {
                let isValid = settings.validateSettingsWithBalls()
                let errors = settings.validationErrors()
                print("Settings validation: \(isValid ? "✅ Valid" : "❌ Invalid")")
                if !errors.isEmpty {
                    print("Errors: \(errors)")
                }
            }
            .font(.caption)
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
            
            Label {
                Text("Accelerometer")
            } icon: {
                Image(systemName: settings.isAccelerometerSupported ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(settings.isAccelerometerSupported ? .green : .red)
            }
            
            Label {
                Text("CloudKit Sync")
            } icon: {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
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
                in: 0.0...2.0,
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
                in: 0.0...1.0,
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
                
                Text("\(settings.ballSize, specifier: "%.1f")×")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .accessibilityLabel("Ball size: \(settings.ballSize, specifier: "%.1f") times normal")
            }
            
            Slider(
                value: $settings.ballSize,
                in: 0.5...3.0,
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
            .accessibilityLabel("Ball size slider")
            .accessibilityValue("\(settings.ballSize, specifier: "%.1f") times normal size")
            .accessibilityHint("Adjust the size of dropped balls")
        }
        .padding(.vertical, 4)
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
     * Ball type selection row
     */
    private var ballTypeSelectionRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Ball Type", systemImage: "volleyball")
                .foregroundStyle(.mint)
            
            Picker("Ball Type", selection: $settings.selectedBallType) {
                Text("Random").tag(nil as String?)
                
                ForEach(settings.availableBallTypes, id: \.self) { ballType in
                    Text(settings.availableBallDisplayNames[ballType] ?? ballType)
                        .tag(ballType as String?)
                }
            }
            .pickerStyle(.menu)
            .accessibilityLabel("Ball type picker")
            .accessibilityValue(settings.selectedBallDisplayName ?? "Random")
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
                in: 0.0...2.0,
                step: 0.1
            ) {
                Text("Gravity")
            } minimumValueLabel: {
                Text("0")
                    .font(.caption)
            } maximumValueLabel: {
                Text("2")
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
                in: 0.0...1.0,
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
                in: 0.5...3.0,
                step: 0.1
            ) {
                Text("Ball Size")
            } minimumValueLabel: {
                Text("0.5×")
                    .font(.caption)
            } maximumValueLabel: {
                Text("3×")
                    .font(.caption)
            }
            .tint(.pink)
            
            Text("\(settings.ballSize, specifier: "%.1f")×")
                .font(.body)
                .fontWeight(.medium)
                .frame(width: 50, alignment: .trailing)
                .accessibilityLabel("Ball size: \(settings.ballSize, specifier: "%.1f") times normal")
        }
        .accessibilityElement(children: .combine)
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
     * macOS-style ball type picker
     */
    private var macOSBallTypeRow: some View {
        HStack(alignment: .center, spacing: 16) {
            Label("Ball Type", systemImage: "volleyball")
                .foregroundStyle(.mint)
                .frame(width: 100, alignment: .leading)
            
            Picker("Ball Type", selection: $settings.selectedBallType) {
                Text("Random").tag(nil as String?)
                
                ForEach(settings.availableBallTypes, id: \.self) { ballType in
                    Text(settings.availableBallDisplayNames[ballType] ?? ballType)
                        .tag(ballType as String?)
                }
            }
            .pickerStyle(.menu)
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
