import SwiftUI

/// Badge displaying terrain context with ski run-style coloring.
/// Uses standard ski slope color coding: green (easy), blue (intermediate), black (expert).
struct TerrainBadge: View {
    let terrain: TerrainContext
    var showIcon: Bool = true
    var style: BadgeStyle = .filled
    var size: BadgeSize = .medium

    enum BadgeStyle {
        case filled, outlined, subtle
    }

    enum BadgeSize {
        case small, medium, large

        var fontSize: Font {
            switch self {
            case .small: return .caption2
            case .medium: return .caption
            case .large: return .subheadline
            }
        }

        var iconSize: Font {
            switch self {
            case .small: return .caption2
            case .medium: return .caption
            case .large: return .subheadline
            }
        }

        var horizontalPadding: CGFloat {
            switch self {
            case .small: return 6
            case .medium: return 10
            case .large: return 14
            }
        }

        var verticalPadding: CGFloat {
            switch self {
            case .small: return 3
            case .medium: return 5
            case .large: return 7
            }
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            if showIcon {
                Image(systemName: terrain.iconName)
                    .font(size.iconSize)
            }
            Text(terrain.shortName)
                .font(size.fontSize)
                .fontWeight(.medium)
        }
        .foregroundStyle(foregroundColor)
        .padding(.horizontal, size.horizontalPadding)
        .padding(.vertical, size.verticalPadding)
        .background {
            switch style {
            case .filled:
                Capsule().fill(terrainColor)
            case .outlined:
                Capsule().stroke(terrainColor, lineWidth: 1.5)
            case .subtle:
                Capsule().fill(terrainColor.opacity(0.15))
            }
        }
    }

    // MARK: - Computed Colors

    private var foregroundColor: Color {
        switch style {
        case .filled:
            return .white
        case .outlined, .subtle:
            return terrainColor
        }
    }

    /// Maps terrain context to standard ski slope colors.
    private var terrainColor: Color {
        switch terrain {
        case .groomedGreen:
            return Color(red: 0.2, green: 0.65, blue: 0.35)  // Green run
        case .groomedBlue:
            return Color(red: 0.2, green: 0.4, blue: 0.8)    // Blue run
        case .groomedBlack:
            return Color(red: 0.15, green: 0.15, blue: 0.15) // Black diamond
        case .bumps:
            return Color(red: 0.6, green: 0.4, blue: 0.2)    // Earthy brown
        case .powder:
            return Color(red: 0.5, green: 0.7, blue: 0.9)    // Light powder blue
        case .steeps:
            return Color(red: 0.7, green: 0.2, blue: 0.2)    // Warning red
        case .ice:
            return Color(red: 0.4, green: 0.6, blue: 0.7)    // Icy gray-blue
        case .crud:
            return Color(red: 0.5, green: 0.45, blue: 0.4)   // Mixed brown-gray
        }
    }
}

// MARK: - Convenience Initializers

extension TerrainBadge {
    /// Creates a badge showing full display name instead of short name.
    static func fullName(_ terrain: TerrainContext, style: BadgeStyle = .filled) -> some View {
        HStack(spacing: 4) {
            Image(systemName: terrain.iconName)
                .font(.caption)
            Text(terrain.displayName)
                .font(.caption)
                .fontWeight(.medium)
        }
        .foregroundStyle(style == .filled ? .white : terrainColorFor(terrain))
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background {
            if style == .filled {
                Capsule().fill(terrainColorFor(terrain))
            } else {
                Capsule().stroke(terrainColorFor(terrain), lineWidth: 1.5)
            }
        }
    }

    private static func terrainColorFor(_ terrain: TerrainContext) -> Color {
        switch terrain {
        case .groomedGreen:
            return Color(red: 0.2, green: 0.65, blue: 0.35)
        case .groomedBlue:
            return Color(red: 0.2, green: 0.4, blue: 0.8)
        case .groomedBlack:
            return Color(red: 0.15, green: 0.15, blue: 0.15)
        case .bumps:
            return Color(red: 0.6, green: 0.4, blue: 0.2)
        case .powder:
            return Color(red: 0.5, green: 0.7, blue: 0.9)
        case .steeps:
            return Color(red: 0.7, green: 0.2, blue: 0.2)
        case .ice:
            return Color(red: 0.4, green: 0.6, blue: 0.7)
        case .crud:
            return Color(red: 0.5, green: 0.45, blue: 0.4)
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        // All terrains with filled style
        Text("Filled Style").font(.headline)
        HStack(spacing: 8) {
            TerrainBadge(terrain: .groomedGreen)
            TerrainBadge(terrain: .groomedBlue)
            TerrainBadge(terrain: .groomedBlack)
        }

        // All terrains with outlined style
        Text("Outlined Style").font(.headline)
        HStack(spacing: 8) {
            TerrainBadge(terrain: .bumps, style: .outlined)
            TerrainBadge(terrain: .powder, style: .outlined)
            TerrainBadge(terrain: .steeps, style: .outlined)
        }

        // Subtle style
        Text("Subtle Style").font(.headline)
        HStack(spacing: 8) {
            TerrainBadge(terrain: .ice, style: .subtle)
            TerrainBadge(terrain: .crud, style: .subtle)
        }

        // Sizes
        Text("Sizes").font(.headline)
        HStack(spacing: 8) {
            TerrainBadge(terrain: .groomedBlue, size: .small)
            TerrainBadge(terrain: .groomedBlue, size: .medium)
            TerrainBadge(terrain: .groomedBlue, size: .large)
        }

        // Full name variant
        Text("Full Name").font(.headline)
        TerrainBadge.fullName(.groomedBlue)
    }
    .padding()
}
