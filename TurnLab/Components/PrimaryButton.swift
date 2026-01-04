import SwiftUI

/// Styled primary action button with glove-friendly touch target.
struct PrimaryButton: View {
    let title: String
    var icon: String?
    var style: ButtonStyle = .filled
    var isLoading: Bool = false
    var isDisabled: Bool = false
    let action: () -> Void

    enum ButtonStyle {
        case filled, outlined, text
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: TurnLabSpacing.xs) {
                if isLoading {
                    ProgressView()
                        .tint(style == .filled ? .white : Color.accentColor)
                } else {
                    if let icon {
                        Image(systemName: icon)
                    }
                    Text(title)
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: TurnLabSpacing.touchTargetGloveFriendly)
            .foregroundStyle(foregroundColor)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: TurnLabSpacing.cornerRadiusMedium))
        }
        .disabled(isDisabled || isLoading)
        .opacity(isDisabled ? 0.5 : 1)
    }

    @ViewBuilder
    private var background: some View {
        switch style {
        case .filled:
            Color.accentColor
        case .outlined:
            RoundedRectangle(cornerRadius: TurnLabSpacing.cornerRadiusMedium)
                .stroke(Color.accentColor, lineWidth: 2)
        case .text:
            Color.clear
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .filled: return .white
        case .outlined, .text: return .accentColor
        }
    }
}

/// Secondary action button
struct SecondaryButton: View {
    let title: String
    var icon: String?
    let action: () -> Void

    var body: some View {
        PrimaryButton(title: title, icon: icon, style: .outlined, action: action)
    }
}

/// Text-only button
struct TextButton: View {
    let title: String
    var icon: String?
    let action: () -> Void

    var body: some View {
        PrimaryButton(title: title, icon: icon, style: .text, action: action)
    }
}

#Preview {
    VStack(spacing: 16) {
        PrimaryButton(title: "Start Assessment", icon: "checkmark.circle") {}
        PrimaryButton(title: "Loading...", isLoading: true) {}
        SecondaryButton(title: "View Details", icon: "eye") {}
        TextButton(title: "Skip for now") {}
        PrimaryButton(title: "Disabled", isDisabled: true) {}
    }
    .padding()
}
