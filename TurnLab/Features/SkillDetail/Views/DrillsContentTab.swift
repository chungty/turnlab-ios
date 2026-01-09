import SwiftUI

/// Drills tab content.
struct DrillsContentTab: View {
    let drills: [Drill]
    let checklists: [Checklist]

    var body: some View {
        if drills.isEmpty && checklists.isEmpty {
            EmptyStateView(
                icon: "list.bullet.clipboard",
                title: "No Drills Yet",
                message: "Practice drills are coming soon."
            )
        } else {
            VStack(spacing: TurnLabSpacing.md) {
                // Checklists first (for quick on-mountain reference)
                if !checklists.isEmpty {
                    VStack(alignment: .leading, spacing: TurnLabSpacing.xs) {
                        HStack {
                            Image(systemName: "checkmark.circle")
                                .foregroundStyle(Color.accentColor)
                            Text("Checklists")
                                .font(TurnLabTypography.headline)
                        }

                        ForEach(checklists) { checklist in
                            ChecklistCard(checklist: checklist)
                        }
                    }
                }

                // Drills
                if !drills.isEmpty {
                    VStack(alignment: .leading, spacing: TurnLabSpacing.xs) {
                        HStack {
                            Image(systemName: "figure.skiing.downhill")
                                .foregroundStyle(Color.accentColor)
                            Text("Practice Drills")
                                .font(TurnLabTypography.headline)
                        }

                        ForEach(drills) { drill in
                            DrillCard(drill: drill)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ScrollView {
        DrillsContentTab(
            drills: [
                Drill(
                    id: "1",
                    title: "Traverse and Turn",
                    overview: "Practice making turns from a traverse position.",
                    steps: [
                        Drill.DrillStep(order: 1, instruction: "Start in a traverse", focusPoint: "Feel the edges"),
                        Drill.DrillStep(order: 2, instruction: "Shift weight to downhill ski", focusPoint: nil),
                        Drill.DrillStep(order: 3, instruction: "Complete the turn", focusPoint: "Keep upper body quiet")
                    ],
                    difficulty: .medium,
                    recommendedTerrain: [.groomedBlue],
                    estimatedReps: "10 each way"
                )
            ],
            checklists: [
                Checklist(
                    id: "1",
                    title: "Pre-Run Focus",
                    items: [
                        Checklist.ChecklistItem(order: 1, text: "Athletic stance ready", isCritical: false),
                        Checklist.ChecklistItem(order: 2, text: "Weight centered", isCritical: true)
                    ],
                    purpose: .focusPoints
                )
            ]
        )
        .padding()
    }
}
