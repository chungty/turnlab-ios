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

    // MARK: - Level Colors (Vibrant ski resort trail colors)
    static func levelColor(_ level: SkillLevel) -> Color {
        switch level {
        case .beginner: return Color(red: 0.2, green: 0.7, blue: 0.3) // Fresh green
        case .novice: return Color(red: 0.2, green: 0.5, blue: 0.85) // Bright blue
        case .intermediate: return Color(red: 0.95, green: 0.55, blue: 0.15) // Warm orange
        case .expert: return Color(red: 0.85, green: 0.2, blue: 0.25) // Bold red
        }
    }

    // MARK: - Level Gradients for immersive headers
    static func levelGradient(_ level: SkillLevel) -> LinearGradient {
        switch level {
        case .beginner:
            return LinearGradient(
                colors: [Color(red: 0.2, green: 0.6, blue: 0.3), Color(red: 0.3, green: 0.75, blue: 0.4)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .novice:
            return LinearGradient(
                colors: [Color(red: 0.15, green: 0.4, blue: 0.75), Color(red: 0.3, green: 0.6, blue: 0.9)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .intermediate:
            return LinearGradient(
                colors: [Color(red: 0.9, green: 0.45, blue: 0.1), Color(red: 0.95, green: 0.6, blue: 0.25)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .expert:
            return LinearGradient(
                colors: [Color(red: 0.75, green: 0.15, blue: 0.2), Color(red: 0.9, green: 0.25, blue: 0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
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
