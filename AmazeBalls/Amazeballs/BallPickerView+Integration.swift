//
//  BallPickerView+Integration.swift
//  Amazeballs
//
//  Created by Daniel Flax on 11/15/25.
//

import SwiftUI

/**
 * Integration examples and wrapper views for BallPickerView
 *
 * This file demonstrates how to integrate the reusable BallPickerView
 * into different presentation contexts across iOS, iPadOS, and macOS.
 */

// MARK: - iOS Sheet Integration

/**
 * iOS-style sheet wrapper for ball selection
 */
struct BallPickerSheet: View {
    @Bindable var gameSettings: GameSettings
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Reusable ball picker
                BallPickerView(
                    selectedBallType: $gameSettings.selectedBallType
                ) { ballType in
                    // Handle selection change
                    print("Selected ball: \(ballType ?? "Random")")
                    
                    // Provide haptic feedback
                    #if os(iOS)
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                    #endif
                    
                    // Auto-dismiss after brief delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        dismiss()
                    }
                }
                .frame(maxHeight: .infinity)
            }
            .navigationTitle("Choose Ball")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: {
                    #if os(macOS)
                        .primaryAction
                    #else
                        .navigationBarTrailing
                    #endif
                }()) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        #if os(iOS)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        #endif
    }
}

// MARK: - macOS Popover Integration

/**
 * macOS-style popover wrapper for ball selection
 */
struct BallPickerPopover: View {
    @Bindable var gameSettings: GameSettings
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text("Choose Ball Type")
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            
            // Reusable ball picker
            BallPickerView(
                selectedBallType: $gameSettings.selectedBallType
            ) { ballType in
                // Handle selection change
                print("Selected ball: \(ballType ?? "Random")")
                
                // Auto-dismiss after brief delay for better UX
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    dismiss()
                }
            }
            .frame(maxHeight: 250)
            
            // Footer with done button
            HStack {
                Spacer()
                
                Button("Done") {
                    dismiss()
                }
                .keyboardShortcut(.return, modifiers: [])
            }
        }
        .padding()
        .frame(width: 320)
    }
}

// MARK: - Inline Integration

/**
 * Inline integration for settings views or embedded contexts
 */
struct InlineBallPicker: View {
    @Bindable var gameSettings: GameSettings
    let title: String
    let maxHeight: CGFloat?
    
    init(
        gameSettings: GameSettings,
        title: String = "Ball Type",
        maxHeight: CGFloat? = nil
    ) {
        self.gameSettings = gameSettings
        self.title = title
        self.maxHeight = maxHeight
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section header
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                // Current selection indicator
                if let selectedBall = gameSettings.selectedBallType {
                    Text(BallAssetManager.shared.displayName(for: selectedBall))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.secondary.opacity(0.1), in: Capsule())
                } else {
                    Text("Random")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.blue.opacity(0.1), in: Capsule())
                }
            }
            
            // Reusable ball picker
            BallPickerView(
                selectedBallType: $gameSettings.selectedBallType
            ) { ballType in
                print("Inline picker selected: \(ballType ?? "Random")")
                
                // Could trigger additional actions here
                // like updating other UI elements or saving preferences
            }
            .frame(maxHeight: maxHeight ?? 200)
        }
    }
}

// MARK: - Settings Integration

/**
 * Settings section that includes ball picker
 */
struct BallPickerSettingsSection: View {
    @Bindable var gameSettings: GameSettings
    
    var body: some View {
        Section {
            InlineBallPicker(
                gameSettings: gameSettings,
                title: "Ball Selection",
                maxHeight: 150
            )
        } header: {
            Text("Ball Type")
                .font(.subheadline)
                .fontWeight(.medium)
        } footer: {
            Text("Choose a specific ball type or select Random to use different balls each time.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Compact Integration

/**
 * Compact version suitable for limited space contexts
 */
struct CompactBallPicker: View {
    @Bindable var gameSettings: GameSettings
    @State private var showingFullPicker = false
    
    var body: some View {
        Button(action: { showingFullPicker = true }) {
            HStack(spacing: 8) {
                // Current ball image
                if let ballType = gameSettings.selectedBallType {
                    BallAssetManager.shared.ballImageView(for: ballType)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                } else {
                    Image(systemName: "questionmark.circle")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .frame(width: 24, height: 24)
                }
                
                // Current selection text
                VStack(alignment: .leading, spacing: 2) {
                    Text("Ball Type")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    
                    if let ballType = gameSettings.selectedBallType {
                        Text(BallAssetManager.shared.displayName(for: ballType))
                            .font(.caption)
                            .fontWeight(.medium)
                    } else {
                        Text("Random")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showingFullPicker) {
            BallPickerSheet(gameSettings: gameSettings)
        }
    }
}

// MARK: - Usage Examples

struct BallPickerIntegrationExamples: View {
    @State private var gameSettings = GameSettings.shared
    @State private var showingSheet = false
    @State private var showingPopover = false
    
    var body: some View {
        NavigationView {
            List {
                Section("Presentation Styles") {
                    Button("Show as Sheet (iOS)") {
                        showingSheet = true
                    }
                    
                    Button("Show as Popover (macOS)") {
                        showingPopover = true
                    }
                }
                
                Section("Inline Integration") {
                    InlineBallPicker(
                        gameSettings: gameSettings,
                        maxHeight: 120
                    )
                }
                
                Section("Compact Integration") {
                    CompactBallPicker(gameSettings: gameSettings)
                }
                
                BallPickerSettingsSection(gameSettings: gameSettings)
            }
            .navigationTitle("Ball Picker Examples")
        }
        .sheet(isPresented: $showingSheet) {
            BallPickerSheet(gameSettings: gameSettings)
        }
        .popover(isPresented: $showingPopover) {
            BallPickerPopover(gameSettings: gameSettings)
        }
    }
}

// MARK: - Preview

#Preview("Integration Examples") {
    BallPickerIntegrationExamples()
}

#Preview("iOS Sheet") {
    BallPickerSheet(gameSettings: GameSettings.shared)
}

#Preview("macOS Popover") {
    BallPickerPopover(gameSettings: GameSettings.shared)
        .frame(width: 350, height: 400)
}

#Preview("Inline Picker") {
    Form {
        BallPickerSettingsSection(gameSettings: GameSettings.shared)
    }
    .formStyle(.grouped)
}