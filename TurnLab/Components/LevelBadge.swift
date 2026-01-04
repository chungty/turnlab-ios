import SwiftUI

/// Badge displaying skill level with color coding.
struct LevelBadge: View {
    let level: SkillLevel
    var size: BadgeSize = .medium

    enum BadgeSize {
        case small, medium, large

        var fontSize: Font {
            switch self {
            case .small: return .caption2
            case .medium: return .caption
            case .large: return .callout
            }
        }

        var padding: EdgeInsets {
            switch self {
            case .small: return EdgeInsets(top: 2, leading: 6, bottom: 2, trailing: 6)
            case .medium: return EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)
            case .large: return EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)
            }
        }
    }

    var body: some View {
        Text(level.displayName)
            .font(size.fontSize)
            .fontWeight(.semibold)
            .foregroundStyle(.white)
            .padding(size.padding)
            .background(TurnLabColors.levelColor(level))
            .clipShape(Capsule())
    }
}

#Preview {
    VStack(spacing: 16) {
        LevelBadge(level: .beginner, size: .small)
        LevelBadge(level: .novice, size: .medium)
        LevelBadge(level: .intermediate, size: .large)
        LevelBadge(level: .expert)
    }
}
