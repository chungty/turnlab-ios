import SwiftUI

/// Semantic color definitions for Turn Lab.
/// 80s neon aesthetic with high contrast for outdoor visibility.
enum TurnLabColors {
    // MARK: - Brand Colors (80s Neon Palette)
    static let primary = Color("Primary", bundle: .main)      // Electric Blue #00D4FF
    static let secondary = Color("Secondary", bundle: .main)  // Neon Pink #FF6B9D
    static let accent = Color("Accent", bundle: .main)        // Electric Blue

    // MARK: - 80s Neon Direct Colors
    static let neonPink = Color(red: 1.0, green: 0.42, blue: 0.616)      // #FF6B9D
    static let electricBlue = Color(red: 0.0, green: 0.831, blue: 1.0)   // #00D4FF
    static let sunsetOrange = Color(red: 1.0, green: 0.549, blue: 0.259) // #FF8C42
    static let sunsetYellow = Color(red: 1.0, green: 0.902, blue: 0.427) // #FFE66D
    static let deepPurple = Color(red: 0.482, green: 0.176, blue: 0.557) // #7B2D8E
    static let nightSky = Color(red: 0.102, green: 0.102, blue: 0.180)   // #1A1A2E

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

    // MARK: - Gradient Backgrounds (80s Aesthetic)

    /// Primary 80s sunset gradient - neon pink to orange to yellow
    static let sunsetGradient = LinearGradient(
        colors: [
            neonPink,
            sunsetOrange,
            sunsetYellow
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Aurora gradient - electric blue to deep purple
    static let auroraGradient = LinearGradient(
        colors: [
            electricBlue,
            deepPurple
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Night mountain gradient - for dark backgrounds
    static let mountainGradient = LinearGradient(
        colors: [
            nightSky,
            Color(red: 0.086, green: 0.129, blue: 0.243),  // #16213E
            Color(red: 0.059, green: 0.204, blue: 0.376)   // #0F3460
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    /// Snow/light gradient for content areas
    static let snowGradient = LinearGradient(
        colors: [
            Color.white,
            Color(white: 0.96),
            Color(white: 0.92)
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
