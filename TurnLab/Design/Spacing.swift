import SwiftUI

/// Layout constants and spacing values.
/// Touch targets sized for glove-friendly interaction.
enum TurnLabSpacing {
    // MARK: - Base Spacing Scale
    static let xxxs: CGFloat = 2
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
    static let xxxl: CGFloat = 64

    // MARK: - Touch Targets (Apple HIG minimum: 44pt)
    static let touchTargetMinimum: CGFloat = 44
    static let touchTargetGloveFriendly: CGFloat = 56 // Larger for gloved fingers
    static let touchTargetLarge: CGFloat = 64

    // MARK: - Corner Radii
    static let cornerRadiusSmall: CGFloat = 8
    static let cornerRadiusMedium: CGFloat = 12
    static let cornerRadiusLarge: CGFloat = 16
    static let cornerRadiusXL: CGFloat = 24

    // MARK: - Card Dimensions
    static let cardPadding: CGFloat = md
    static let cardSpacing: CGFloat = sm
    static let cardMinHeight: CGFloat = 80

    // MARK: - Screen Margins
    static let screenHorizontalPadding: CGFloat = md
    static let screenVerticalPadding: CGFloat = lg

    // MARK: - Icon Sizes
    static let iconSmall: CGFloat = 16
    static let iconMedium: CGFloat = 24
    static let iconLarge: CGFloat = 32
    static let iconXL: CGFloat = 48
}

// MARK: - Layout Helper Views
struct GloveFriendlyButton<Label: View>: View {
    let action: () -> Void
    @ViewBuilder let label: () -> Label

    var body: some View {
        Button(action: action) {
            label()
                .frame(minWidth: TurnLabSpacing.touchTargetGloveFriendly,
                       minHeight: TurnLabSpacing.touchTargetGloveFriendly)
        }
    }
}

// MARK: - Padding Convenience
extension View {
    func cardPadding() -> some View {
        padding(TurnLabSpacing.cardPadding)
    }

    func screenPadding() -> some View {
        padding(.horizontal, TurnLabSpacing.screenHorizontalPadding)
            .padding(.vertical, TurnLabSpacing.screenVerticalPadding)
    }

    func sectionSpacing() -> some View {
        padding(.vertical, TurnLabSpacing.lg)
    }
}
