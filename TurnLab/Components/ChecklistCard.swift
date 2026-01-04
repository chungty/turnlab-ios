import SwiftUI

/// Interactive checklist card for pre-run sequences.
struct ChecklistCard: View {
    let checklist: Checklist
    @State private var completedItems: Set<String> = []
    @State private var isExpanded = true

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            Button(action: { withAnimation { isExpanded.toggle() } }) {
                HStack {
                    Image(systemName: purposeIcon)
                        .foregroundStyle(Color.accentColor)

                    Text(checklist.title)
                        .font(TurnLabTypography.headline)
                        .foregroundStyle(TurnLabColors.textPrimary)

                    Spacer()

                    // Progress
                    Text("\(completedItems.count)/\(checklist.items.count)")
                        .font(.caption)
                        .foregroundStyle(TurnLabColors.textSecondary)

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundStyle(TurnLabColors.textTertiary)
                }
                .cardPadding()
            }
            .buttonStyle(.plain)

            // Items
            if isExpanded {
                VStack(alignment: .leading, spacing: TurnLabSpacing.xs) {
                    ForEach(checklist.items) { item in
                        ChecklistItemRow(
                            item: item,
                            isCompleted: completedItems.contains(item.id),
                            onToggle: { toggleItem(item) }
                        )
                    }
                }
                .padding(.horizontal, TurnLabSpacing.cardPadding)
                .padding(.bottom, TurnLabSpacing.cardPadding)
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: TurnLabSpacing.cornerRadiusMedium))
    }

    private var purposeIcon: String {
        switch checklist.purpose {
        case .preRun: return "checkmark.circle"
        case .warmUp: return "flame"
        case .focusPoints: return "eye"
        case .safety: return "exclamationmark.triangle"
        }
    }

    private func toggleItem(_ item: Checklist.ChecklistItem) {
        if completedItems.contains(item.id) {
            completedItems.remove(item.id)
        } else {
            completedItems.insert(item.id)
        }
    }
}

struct ChecklistItemRow: View {
    let item: Checklist.ChecklistItem
    let isCompleted: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(alignment: .top, spacing: TurnLabSpacing.sm) {
                // Checkbox
                Image(systemName: isCompleted ? "checkmark.square.fill" : "square")
                    .foregroundStyle(isCompleted ? Color.green : TurnLabColors.textTertiary)
                    .font(.title3)

                // Text
                Text(item.text)
                    .font(TurnLabTypography.body)
                    .foregroundStyle(isCompleted ? TurnLabColors.textTertiary : TurnLabColors.textPrimary)
                    .strikethrough(isCompleted)
                    .multilineTextAlignment(.leading)

                Spacer()

                // Critical indicator
                if item.isCritical {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundStyle(.orange)
                        .font(.caption)
                }
            }
            .padding(.vertical, TurnLabSpacing.xxs)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ChecklistCard(
        checklist: Checklist(
            id: "1",
            title: "Pre-Run Checklist",
            items: [
                Checklist.ChecklistItem(order: 1, text: "Check bindings are secure", isCritical: true),
                Checklist.ChecklistItem(order: 2, text: "Goggles clear and adjusted", isCritical: false),
                Checklist.ChecklistItem(order: 3, text: "Gloves on, poles ready", isCritical: false),
                Checklist.ChecklistItem(order: 4, text: "Scan the run for hazards", isCritical: true)
            ],
            purpose: .preRun
        )
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}
