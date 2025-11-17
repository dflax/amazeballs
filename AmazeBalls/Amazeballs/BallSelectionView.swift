//
//  BallSelectionView.swift
//  Amazeballs
//
//  Created by Daniel Flax on 11/15/25.
//

import SwiftUI

/**
 * A SwiftUI view for selecting ball types using the BallAssetManager
 */
struct BallSelectionView: View {
    @Bindable var gameSettings: GameSettings
    @State private var ballManager = BallAssetManager.shared
    
    private let columns = [
        GridItem(.adaptive(minimum: 80, maximum: 120), spacing: 16)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Ball Selection")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Choose your ball type, or leave unselected for random balls")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            // Current Selection Display
            if let selectedType = gameSettings.selectedBallType {
                HStack {
                    ballManager.ballImageView(for: selectedType)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Selected:")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(ballManager.displayName(for: selectedType))
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    
                    Spacer()
                    
                    Button("Clear Selection") {
                        gameSettings.clearSelectedBallType()
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
                .background(.quaternary)
                .cornerRadius(12)
            } else {
                HStack {
                    Image(systemName: "questionmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Random Balls")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text("A random ball will be used each time")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                }
                .padding()
                .background(.quaternary)
                .cornerRadius(12)
            }
            
            // Ball Selection Grid
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(ballManager.availableBallTypes, id: \.self) { ballType in
                        BallSelectionItem(
                            ballType: ballType,
                            isSelected: gameSettings.selectedBallType == ballType,
                            displayName: ballManager.displayName(for: ballType),
                            ballImageView: ballManager.ballImageView(for: ballType)
                        ) {
                            selectBall(ballType)
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
            
            if ballManager.availableBallTypes.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.title)
                        .foregroundStyle(.orange)
                    
                    Text("No Ball Assets Found")
                        .font(.headline)
                    
                    Text("Add ball images to the 'Balls' folder in Assets.xcassets following the naming convention: ball-{type}")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                }
                .padding()
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Ball Selection")
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
                Button("Random") {
                    gameSettings.selectRandomBallType()
                }
                .disabled(ballManager.availableBallTypes.isEmpty)
            }
        }
    }
    
    private func selectBall(_ ballType: String) {
        if gameSettings.selectedBallType == ballType {
            // Deselect if already selected
            gameSettings.clearSelectedBallType()
        } else {
            // Select the new ball type
            gameSettings.selectedBallType = ballType
        }
    }
}

/**
 * Individual ball selection item
 */
private struct BallSelectionItem: View {
    let ballType: String
    let isSelected: Bool
    let displayName: String
    let ballImageView: Image
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            ballImageView
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 60, height: 60)
                .scaleEffect(isSelected ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: isSelected)
            
            Text(displayName)
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(width: 80, height: 100)
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color.accentColor.opacity(0.2) : Color.clear)
                .stroke(
                    isSelected ? Color.accentColor : Color.clear,
                    lineWidth: 2
                )
        )
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
        .accessibilityLabel("\(displayName) ball")
        .accessibilityHint(isSelected ? "Currently selected. Tap to deselect." : "Tap to select this ball type")
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        BallSelectionView(gameSettings: GameSettings.shared)
    }
}