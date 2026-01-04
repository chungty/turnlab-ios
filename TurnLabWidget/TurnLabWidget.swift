import WidgetKit
import SwiftUI

/// Focus skill widget displaying current practice focus.
struct TurnLabWidget: Widget {
    let kind: String = "TurnLabWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FocusSkillProvider()) { entry in
            TurnLabWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Focus Skill")
        .description("Quick access to your current skill focus.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

/// Entry view that renders the appropriate size.
struct TurnLabWidgetEntryView: View {
    @Environment(\.widgetFamily) var widgetFamily
    let entry: FocusSkillEntry

    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Previews

#Preview(as: .systemSmall) {
    TurnLabWidget()
} timeline: {
    FocusSkillEntry.placeholder
}

#Preview(as: .systemMedium) {
    TurnLabWidget()
} timeline: {
    FocusSkillEntry.placeholder
}
