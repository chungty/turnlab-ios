import SwiftUI

/// Selector for terrain context when assessing skills.
struct TerrainContextPicker: View {
    @Binding var selectedContext: TerrainContext
    let availableContexts: [TerrainContext]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: TurnLabSpacing.xs) {
                ForEach(availableContexts) { context in
                    TerrainContextButton(
                        context: context,
                        isSelected: selectedContext == context,
                        action: { selectedContext = context }
                    )
                }
            }
            .padding(.horizontal)
        }
    }
}

struct TerrainContextButton: View {
    let context: TerrainContext
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: context.iconName)
                Text(context.shortName)
            }
            .font(.subheadline)
            .fontWeight(isSelected ? .semibold : .regular)
            .foregroundStyle(isSelected ? .white : TurnLabColors.textPrimary)
            .padding(.horizontal, TurnLabSpacing.sm)
            .padding(.vertical, TurnLabSpacing.xs)
            .background {
                if isSelected {
                    Capsule().fill(Color.accentColor)
                } else {
                    Capsule().stroke(Color.gray.opacity(0.3), lineWidth: 1)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var context: TerrainContext = .groomedBlue

        var body: some View {
            TerrainContextPicker(
                selectedContext: $context,
                availableContexts: [.groomedGreen, .groomedBlue, .groomedBlack, .bumps]
            )
        }
    }

    return PreviewWrapper()
}
