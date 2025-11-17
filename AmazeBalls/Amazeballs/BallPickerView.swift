//
//  BallPickerView.swift
//  Amazeballs
//
//  Created by Daniel Flax on 11/15/25.
//

import SwiftUI

/**
 * BallPickerView
 *
 * A reusable, cross-platform ball selection component that adapts to iOS, iPadOS, and macOS
 * with platform-appropriate layouts, interactions, and visual styling.
 *
 * ## Features
 * - **Cross-platform compatibility**: iOS, iPadOS, and macOS
 * - **Adaptive layout**: Different column counts based on platform and screen size
 * - **Platform-optimized interactions**: Touch on iOS/iPadOS, hover effects on macOS
 * - **Integrated with BallAssetManager**: Automatically discovers available balls
 * - **Settings integration**: Updates GameSettings.selectedBallType on selection
 * - **Accessibility support**: Full VoiceOver and keyboard navigation
 * - **Responsive design**: Adapts to different container sizes
 *
 * ## Platform Adaptations
 * - **iOS**: 3-4 columns, touch-optimized sizing, haptic feedback
 * - **iPadOS**: 5-6 columns, larger touch targets, split view compatibility
 * - **macOS**: 4-5 columns, hover effects, click interactions, keyboard navigation
 *
 * ## Layout
 * ```
 * ┌─────────────────────────────────┐
 * │  [Random]  [Ball1]  [Ball2]     │
 * │  [Ball3]   [Ball4]  [Ball5]     │
 * │  [Ball6]   [Ball7]  [Ball8]     │
 * └─────────────────────────────────┘
 * ```
 *
 * ## Usage
 * ```swift
 * BallPickerView(
 *     selectedBallType: $gameSettings.selectedBallType,
 *     onSelectionChange: { ballType in
 *         // Optional callback for selection changes
 *         print("Selected: \(ballType ?? "Random")")
 *     }
 * )
 * .frame(maxHeight: 300) // Optional height constraint
 * ```
 *
 * ## Accessibility
 * - VoiceOver labels for each ball type
 * - Selection state announcements
 * - Keyboard navigation support (macOS)
 * - Dynamic Type support (iOS/iPadOS)
 */
struct BallPickerView: View {
    
    // MARK: - Properties
    
    /// Binding to the currently selected ball type (nil = random)
    @Binding var selectedBallType: String?
    
    /// Optional callback when selection changes
    let onSelectionChange: ((String?) -> Void)?
    
    /// Ball asset manager for discovering available balls
    @State private var ballAssetManager = BallAssetManager.shared
    
    /// Current hover state for macOS (ball type being hovered)
    @State private var hoveredBallType: String? = nil
    
    // MARK: - Platform-Specific Configuration
    
    /// Grid columns adapted for each platform
    private var gridColumns: [GridItem] {
        let spacing: CGFloat = platformSpacing
        let minSize: CGFloat = platformMinItemSize
        let maxSize: CGFloat = platformMaxItemSize
        
        return [
            GridItem(.adaptive(minimum: minSize, maximum: maxSize), spacing: spacing)
        ]
    }
    
    /// Spacing between grid items based on platform
    private var platformSpacing: CGFloat {
        #if os(macOS)
        return 12
        #elseif os(iOS)
        return UIDevice.current.userInterfaceIdiom == .pad ? 16 : 12
        #else
        return 16
        #endif
    }
    
    /// Minimum item size based on platform
    private var platformMinItemSize: CGFloat {
        #if os(macOS)
        return 80
        #elseif os(iOS)
        return UIDevice.current.userInterfaceIdiom == .pad ? 100 : 85
        #else
        return 100
        #endif
    }
    
    /// Maximum item size based on platform
    private var platformMaxItemSize: CGFloat {
        #if os(macOS)
        return 110
        #elseif os(iOS)
        return UIDevice.current.userInterfaceIdiom == .pad ? 130 : 110
        #else
        return 130
        #endif
    }
    
    /// Item height based on platform
    private var itemHeight: CGFloat {
        #if os(macOS)
        return 100
        #elseif os(iOS)
        return UIDevice.current.userInterfaceIdiom == .pad ? 120 : 110
        #else
        return 120
        #endif
    }
    
    // MARK: - Initialization
    
    /**
     * Creates a ball picker view
     * 
     * - Parameters:
     *   - selectedBallType: Binding to the currently selected ball type
     *   - onSelectionChange: Optional callback when selection changes
     */
    init(
        selectedBallType: Binding<String?>,
        onSelectionChange: ((String?) -> Void)? = nil
    ) {
        self._selectedBallType = selectedBallType
        self.onSelectionChange = onSelectionChange
    }
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: gridColumns, spacing: platformSpacing) {
                // Random option (always first)
                randomBallCard
                
                // Available ball types
                ForEach(ballAssetManager.availableBallTypes, id: \.self) { ballType in
                    BallCard(
                        ballType: ballType,
                        displayName: ballAssetManager.displayName(for: ballType),
                        ballImageView: ballAssetManager.ballImageView(for: ballType),
                        isSelected: selectedBallType == ballType,
                        isHovered: hoveredBallType == ballType,
                        itemHeight: itemHeight
                    ) {
                        selectBall(ballType)
                    } onHover: { isHovering in
                        #if os(macOS)
                        hoveredBallType = isHovering ? ballType : nil
                        #endif
                    }
                }
            }
            .padding(platformSpacing)
        }
        .background(platformBackgroundColor)
        .accessibilityLabel("Ball type picker")
        .accessibilityHint("Choose a ball type or select random for variety")
    }
    
    // MARK: - Random Ball Card
    
    /**
     * Special card for the "Random" ball selection option
     */
    private var randomBallCard: some View {
        BallCard(
            ballType: nil,
            displayName: "Random",
            ballImageView: Image(systemName: "questionmark.circle.fill"),
            isSelected: selectedBallType == nil,
            isHovered: hoveredBallType == nil,
            itemHeight: itemHeight,
            isRandomOption: true
        ) {
            selectBall(nil)
        } onHover: { isHovering in
            #if os(macOS)
            hoveredBallType = isHovering ? nil : hoveredBallType
            #endif
        }
    }
    
    // MARK: - Platform Properties
    
    /**
     * Background color adapted for platform
     */
    private var platformBackgroundColor: Color {
        #if os(macOS)
        return Color(.controlBackgroundColor)
        #else
        return Color(.systemGroupedBackground)
        #endif
    }
    
    // MARK: - Actions
    
    /**
     * Handles ball selection with platform-appropriate feedback
     * 
     * - Parameter ballType: The selected ball type (nil for random)
     */
    private func selectBall(_ ballType: String?) {
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedBallType = ballType
        }
        
        // Platform-specific feedback
        providePlatformFeedback()
        
        // Notify callback
        onSelectionChange?(ballType)
        
        #if DEBUG
        print("BallPickerView: Selected ball type: \(ballType ?? "Random")")
        #endif
    }
    
    /**
     * Provides platform-appropriate feedback for selection
     */
    private func providePlatformFeedback() {
        #if os(iOS)
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        #elseif os(macOS)
        // macOS could use sound feedback here if desired
        // NSSound.beep()
        #endif
    }
}

// MARK: - Ball Card Component

/**
 * Individual ball selection card component
 */
private struct BallCard: View {
    
    // MARK: - Properties
    
    let ballType: String?
    let displayName: String
    let ballImageView: Image
    let isSelected: Bool
    let isHovered: Bool
    let itemHeight: CGFloat
    let isRandomOption: Bool
    let onTap: () -> Void
    let onHover: (Bool) -> Void
    
    // MARK: - Initialization
    
    init(
        ballType: String?,
        displayName: String,
        ballImageView: Image,
        isSelected: Bool,
        isHovered: Bool,
        itemHeight: CGFloat,
        isRandomOption: Bool = false,
        onTap: @escaping () -> Void,
        onHover: @escaping (Bool) -> Void
    ) {
        self.ballType = ballType
        self.displayName = displayName
        self.ballImageView = ballImageView
        self.isSelected = isSelected
        self.isHovered = isHovered
        self.itemHeight = itemHeight
        self.isRandomOption = isRandomOption
        self.onTap = onTap
        self.onHover = onHover
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: cardSpacing) {
            // Ball image
            ballImageView
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: imageSize, height: imageSize)
                .scaleEffect(selectionScale)
                .animation(.easeInOut(duration: 0.15), value: isSelected)
                .animation(.easeInOut(duration: 0.1), value: isHovered)
            
            // Ball name
            Text(displayName)
                .font(textFont)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundStyle(textColor)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .frame(height: itemHeight)
        .frame(maxWidth: .infinity)
        .background(backgroundView)
        .overlay(selectionOverlay)
        .contentShape(Rectangle())
        .onTapGesture { onTap() }
        .onHover { hovering in onHover(hovering) }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
        .accessibilityHint("Tap to select this ball type")
    }
    
    // MARK: - Computed Properties
    
    /**
     * Spacing between image and text based on platform
     */
    private var cardSpacing: CGFloat {
        #if os(macOS)
        return 8
        #else
        return 10
        #endif
    }
    
    /**
     * Image size based on item height
     */
    private var imageSize: CGFloat {
        itemHeight * 0.5
    }
    
    /**
     * Scale factor for selection animation
     */
    private var selectionScale: CGFloat {
        if isSelected {
            return 1.1
        } else if isHovered {
            return 1.05
        } else {
            return 1.0
        }
    }
    
    /**
     * Text font based on platform
     */
    private var textFont: Font {
        #if os(macOS)
        return .caption
        #elseif os(iOS)
        return UIDevice.current.userInterfaceIdiom == .pad ? .subheadline : .caption
        #else
        return .subheadline
        #endif
    }
    
    /**
     * Text color based on selection state
     */
    private var textColor: Color {
        if isSelected {
            return .primary
        } else if isHovered {
            return .primary
        } else {
            return .secondary
        }
    }
    
    /**
     * Background view with platform-appropriate styling
     */
    @ViewBuilder
    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(backgroundColor)
            .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: shadowOffset)
    }
    
    /**
     * Selection overlay with platform-appropriate styling
     */
    @ViewBuilder
    private var selectionOverlay: some View {
        if isRandomOption && isSelected {
            // Special gradient overlay for random option
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(
                    LinearGradient(
                        colors: [.blue, .purple, .pink],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
        } else {
            // Standard selection overlay
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(
                    isSelected ? Color.accentColor : (isHovered ? Color.accentColor.opacity(0.5) : Color.clear),
                    lineWidth: isSelected ? 2 : 1
                )
        }
    }
    
    /**
     * Corner radius based on platform
     */
    private var cornerRadius: CGFloat {
        #if os(macOS)
        return 8
        #else
        return 12
        #endif
    }
    
    /**
     * Background color based on state and platform
     */
    private var backgroundColor: Color {
        #if os(macOS)
        if isSelected {
            return Color.accentColor.opacity(0.15)
        } else if isHovered {
            return Color(.controlAccentColor).opacity(0.1)
        } else {
            return Color(.controlBackgroundColor)
        }
        #else
        if isSelected {
            return Color.accentColor.opacity(0.15)
        } else {
            return Color(.systemBackground)
        }
        #endif
    }
    
    /**
     * Shadow color for elevation effect
     */
    private var shadowColor: Color {
        #if os(macOS)
        return Color.black.opacity(isHovered ? 0.1 : 0.05)
        #else
        return Color.black.opacity(0.1)
        #endif
    }
    
    /**
     * Shadow radius for elevation effect
     */
    private var shadowRadius: CGFloat {
        #if os(macOS)
        return isHovered ? 4 : 2
        #else
        return 2
        #endif
    }
    
    /**
     * Shadow offset for elevation effect
     */
    private var shadowOffset: CGFloat {
        #if os(macOS)
        return isHovered ? 2 : 1
        #else
        return 1
        #endif
    }
    
    /**
     * Accessibility label for the card
     */
    private var accessibilityLabel: String {
        if isRandomOption {
            return "Random ball type"
        } else {
            return "\(displayName) ball"
        }
    }
}

// MARK: - Preview

#Preview("iOS") {
    NavigationView {
        BallPickerView(
            selectedBallType: .constant("basketball")
        ) { ballType in
            print("Selected: \(ballType ?? "Random")")
        }
        .navigationTitle("Choose Ball")
    }
}

#Preview("macOS") {
    BallPickerView(
        selectedBallType: .constant(nil)
    ) { ballType in
        print("Selected: \(ballType ?? "Random")")
    }
    .frame(width: 400, height: 300)
}

#Preview("iPad") {
    NavigationView {
        BallPickerView(
            selectedBallType: .constant("soccer")
        )
        .navigationTitle("Ball Selection")
    }
    .frame(width: 600, height: 400)
}