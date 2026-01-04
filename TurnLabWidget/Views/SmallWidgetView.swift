import SwiftUI
import WidgetKit

/// Small widget view showing focus skill summary.
struct SmallWidgetView: View {
    let entry: FocusSkillEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Domain icon
            HStack {
                Image(systemName: entry.domainIcon)
                    .font(.caption)
                    .foregroundStyle(levelColor.opacity(0.8))

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

            Spacer()

            // Skill name
            Text(entry.skillName)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.primary)
                .lineLimit(2)

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.gray.opacity(0.3))

                    RoundedRectangle(cornerRadius: 3)
                        .fill(levelColor)
                        .frame(width: geometry.size.width * entry.progress)
                }
            }
            .frame(height: 6)

            // Progress percentage
            Text("\(Int(entry.progress * 100))% complete")
                .font(.caption2)
                .foregroundStyle(.secondary)
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

#Preview(as: .systemSmall) {
    TurnLabWidget()
} timeline: {
    FocusSkillEntry.placeholder
    FocusSkillEntry.empty
}
