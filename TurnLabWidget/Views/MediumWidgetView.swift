import SwiftUI
import WidgetKit

/// Medium widget view showing focus skill with next milestone or coach tip.
struct MediumWidgetView: View {
    let entry: FocusSkillEntry

    var body: some View {
        HStack(spacing: 16) {
            // Left side - skill info
            VStack(alignment: .leading, spacing: 8) {
                // Level badge
                HStack {
                    Image(systemName: entry.domainIcon)
                        .font(.caption)
                        .foregroundStyle(levelColor)

                    Text(entry.domain)
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text(entry.skillLevel)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(levelColor)
                        .clipShape(Capsule())
                }

                // Skill name
                Text(entry.skillName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(2)

                Spacer()

                // Progress bar
                VStack(alignment: .leading, spacing: 4) {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.3))

                            RoundedRectangle(cornerRadius: 4)
                                .fill(levelColor)
                                .frame(width: geometry.size.width * entry.progress)
                        }
                    }
                    .frame(height: 8)

                    Text("\(Int(entry.progress * 100))% complete")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            // Right side - coach tip (priority) or next milestone
            if let coachTip = entry.coachTip, !coachTip.isEmpty {
                // Show coach tip
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                            .font(.caption)
                            .foregroundStyle(.blue)

                        Text("Coach Says")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                    }

                    Text(coachTip)
                        .font(.caption)
                        .foregroundStyle(.primary)
                        .lineLimit(4)

                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else if let milestone = entry.nextMilestone {
                // Show next milestone
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "target")
                            .font(.caption)
                            .foregroundStyle(levelColor)

                        Text("Next Goal")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                    }

                    Text(milestone)
                        .font(.caption)
                        .foregroundStyle(.primary)
                        .lineLimit(4)

                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(levelColor.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding()
        .containerBackground(for: .widget) {
            Color(.systemBackground)
        }
    }

    private var levelColor: Color {
        switch entry.levelColor {
        case "green": return .green
        case "blue": return .blue
        case "red": return .red
        case "purple": return .purple
        default: return .gray
        }
    }
}

#Preview(as: .systemMedium) {
    TurnLabWidget()
} timeline: {
    FocusSkillEntry.placeholder
    FocusSkillEntry.empty
}
