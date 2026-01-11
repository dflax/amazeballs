//
//  WatchQuickSettingsView.swift
//  Amazeballs Watch App
//
//  Created by Daniel Flax on 11/17/25.
//

import SwiftUI

/**
 * WatchQuickSettingsView
 *
 * A quick settings overlay for the watchOS app, accessible via long press.
 * Provides access to essential settings optimized for Apple Watch interaction.
 *
 * ## Features
 * - Toggle what Digital Crown controls (gravity vs bounciness)
 * - Quick reset to defaults
 * - Basic settings status
 * - Optimized for watch screen size
 */
struct WatchQuickSettingsView: View {
    
    // MARK: - Environment & Bindings
    
    @Environment(\.dismiss) private var dismiss
    @Environment(GameSettings.self) private var gameSettings
    
    @Binding var crownControlsGravity: Bool
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    
                    // Header
                    headerSection
                    
                    // Crown control setting
                    crownControlSection
                    
                    // Current values display
                    currentValuesSection
                    
                    // Quick actions
                    quickActionsSection
                    
                }
                .padding(.horizontal, 8)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Sections
    
    /**
     * Header with app status
     */
    private var headerSection: some View {
        VStack(spacing: 4) {
            Image(systemName: "crown.fill")
                .font(.title2)
                .foregroundStyle(.orange)
            
            Text("Quick Settings")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("Long press main screen to access")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.bottom, 8)
    }
    
    /**
     * Digital Crown control selection
     */
    private var crownControlSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "crown.fill")
                    .foregroundStyle(.orange)
                Text("Digital Crown Controls")
                    .font(.headline)
                    .fontWeight(.medium)
            }
            
            VStack(spacing: 6) {
                // Gravity option
                Button(action: {
                    crownControlsGravity = true
                    WKInterfaceDevice.current().play(.click)
                }) {
                    HStack {
                        Image(systemName: "arrow.down.circle.fill")
                            .foregroundStyle(crownControlsGravity ? .orange : .secondary)
                        
                        VStack(alignment: .leading) {
                            Text("Gravity")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text("0.0 - 2.0")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        if crownControlsGravity {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.orange)
                        }
                    }
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(crownControlsGravity ? .orange.opacity(0.1) : .clear)
                            .stroke(crownControlsGravity ? .orange : .clear, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                
                // Bounciness option
                Button(action: {
                    crownControlsGravity = false
                    WKInterfaceDevice.current().play(.click)
                }) {
                    HStack {
                        Image(systemName: "arrow.up.bounce.circle.fill")
                            .foregroundStyle(!crownControlsGravity ? .orange : .secondary)
                        
                        VStack(alignment: .leading) {
                            Text("Bounciness")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text("0.0 - 1.0")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        if !crownControlsGravity {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.orange)
                        }
                    }
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(!crownControlsGravity ? .orange.opacity(0.1) : .clear)
                            .stroke(!crownControlsGravity ? .orange : .clear, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    /**
     * Current values display
     */
    private var currentValuesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "gauge.medium")
                    .foregroundStyle(.blue)
                Text("Current Values")
                    .font(.headline)
                    .fontWeight(.medium)
            }
            
            HStack(spacing: 12) {
                // Gravity
                VStack {
                    Image(systemName: "arrow.down")
                        .font(.title3)
                        .foregroundStyle(.primary)
                    Text("Gravity")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(String(format: "%.1f", gameSettings.gravity))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                }
                .frame(maxWidth: .infinity)
                .padding(8)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
                
                // Bounciness
                VStack {
                    Image(systemName: "arrow.up.bounce")
                        .font(.title3)
                        .foregroundStyle(.primary)
                    Text("Bounce")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(String(format: "%.1f", gameSettings.bounciness))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                }
                .frame(maxWidth: .infinity)
                .padding(8)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
            }
            
            // Walls status
            HStack {
                Image(systemName: gameSettings.wallsEnabled ? "rectangle" : "rectangle.dashed")
                    .foregroundStyle(gameSettings.wallsEnabled ? .green : .gray)
                
                Text("Walls: \(gameSettings.wallsEnabled ? "ON" : "OFF")")
                    .font(.subheadline)
                    .foregroundStyle(gameSettings.wallsEnabled ? .green : .gray)
                
                Spacer()
                
                Text("Double-tap to toggle")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding(8)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
        }
    }
    
    /**
     * Quick action buttons
     */
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "bolt.fill")
                    .foregroundStyle(.yellow)
                Text("Quick Actions")
                    .font(.headline)
                    .fontWeight(.medium)
            }
            
            VStack(spacing: 6) {
                // Reset to defaults
                Button(action: resetToDefaults) {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                            .foregroundStyle(.orange)
                        Text("Reset to Defaults")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                    }
                    .padding(10)
                    .background(.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.orange, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                
                // Toggle walls
                Button(action: toggleWalls) {
                    HStack {
                        Image(systemName: gameSettings.wallsEnabled ? "rectangle.slash" : "rectangle")
                            .foregroundStyle(.blue)
                        Text(gameSettings.wallsEnabled ? "Disable Walls" : "Enable Walls")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                    }
                    .padding(10)
                    .background(.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.blue, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    // MARK: - Actions
    
    /**
     * Resets settings to default values
     */
    private func resetToDefaults() {
        gameSettings.gravity = 1.0
        gameSettings.bounciness = 0.8
        gameSettings.ballSize = 1.2 // Slightly larger for watch
        gameSettings.wallsEnabled = true
        
        // Haptic feedback
        WKInterfaceDevice.current().play(.success)
        
        #if DEBUG
        print("WatchQuickSettingsView: Reset to defaults")
        #endif
    }
    
    /**
     * Toggles walls on/off
     */
    private func toggleWalls() {
        gameSettings.wallsEnabled.toggle()
        
        // Haptic feedback
        WKInterfaceDevice.current().play(.click)
        
        #if DEBUG
        print("WatchQuickSettingsView: Walls toggled to \(gameSettings.wallsEnabled)")
        #endif
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    WatchQuickSettingsView(crownControlsGravity: .constant(true))
        .environment(GameSettings.shared)
}
#endif