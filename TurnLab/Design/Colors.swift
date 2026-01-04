import SwiftUI

/// Semantic color definitions for Turn Lab.
/// Designed for high contrast outdoor visibility.
enum TurnLabColors {
    // MARK: - Brand Colors
    static let primary = Color("Primary", bundle: .main)
    static let secondary = Color("Secondary", bundle: .main)
    static let accent = Color("Accent", bundle: .main)

    // MARK: - Semantic Colors
    static let background = Color("Background", bundle: .main)
    static let surface = Color("Surface", bundle: .main)
    static let surfaceElevated = Color("SurfaceElevated", bundle: .main)

    // MARK: - Text Colors
    static let textPrimary = Color("TextPrimary", bundle: .main)
    static let textSecondary = Color("TextSecondary", bundle: .main)
    static let textTertiary = Color("TextTertiary", bundle: .main)
    static let textOnPrimary = Color("TextOnPrimary", bundle: .main)

    // MARK: - Status Colors
    static let success = Color.green
    static let warning = Color.orange
    static let error = Color.red
    static let info = Color.blue

    // MARK: - Level Colors
    static func levelColor(_ level: SkillLevel) -> Color {
        switch level {
        case .beginner: return .green
        case .novice: return .blue
        case .intermediate: return .orange
        case .expert: return .red
        }
    }

    // MARK: - Gradient Backgrounds
    static let mountainGradient = LinearGradient(
        colors: [
            Color(red: 0.15, green: 0.25, blue: 0.45),
            Color(red: 0.35, green: 0.55, blue: 0.75),
            Color(red: 0.85, green: 0.90, blue: 0.95)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static let sunsetGradient = LinearGradient(
        colors: [
            Color(red: 0.95, green: 0.55, blue: 0.35),
            Color(red: 0.85, green: 0.35, blue: 0.45),
            Color(red: 0.45, green: 0.25, blue: 0.55)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static let snowGradient = LinearGradient(
        colors: [
            Color.white,
            Color(white: 0.95),
            Color(white: 0.88)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
}

// MARK: - Color Extensions
extension Color {
    /// High contrast version for outdoor visibility
    var highContrast: Color {
        // In a full implementation, this would adjust based on accessibility settings
        self
    }
}

// MARK: - View Modifier for High Contrast Mode
struct HighContrastModifier: ViewModifier {
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor

    func body(content: Content) -> some View {
        content
    }
}

extension View {
    func adaptiveHighContrast() -> some View {
        modifier(HighContrastModifier())
    }
}
