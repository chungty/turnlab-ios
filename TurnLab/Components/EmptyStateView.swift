import SwiftUI

/// Empty state placeholder with icon, title, and optional action.
struct EmptyStateView: View {
    let icon: String
    let title: String
    var message: String?
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: TurnLabSpacing.lg) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 56))
                .foregroundStyle(TurnLabColors.textTertiary)

            // Text
            VStack(spacing: TurnLabSpacing.xs) {
                Text(title)
                    .font(TurnLabTypography.title3)
                    .foregroundStyle(TurnLabColors.textPrimary)
                    .multilineTextAlignment(.center)

                if let message {
                    Text(message)
                        .font(TurnLabTypography.body)
                        .foregroundStyle(TurnLabColors.textSecondary)
                        .multilineTextAlignment(.center)
                }
            }

            // Action button
            if let actionTitle, let action {
                PrimaryButton(title: actionTitle, action: action)
                    .frame(maxWidth: 200)
            }
        }
        .padding(TurnLabSpacing.xl)
    }
}

#Preview {
    VStack(spacing: 40) {
        EmptyStateView(
            icon: "magnifyingglass",
            title: "No Results",
            message: "Try adjusting your search or filters."
        )

        EmptyStateView(
            icon: "checkmark.circle",
            title: "All Caught Up!",
            message: "You've assessed all skills at this level.",
            actionTitle: "View Progress",
            action: {}
        )
    }
}
