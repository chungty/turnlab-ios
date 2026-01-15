import SwiftUI

/// Floating Action Button for accessing the AI Coach.
struct CoachFAB: View {
    @Binding var isPresented: Bool
    var pulse: Bool = true

    @State private var isPulsing = false

    var body: some View {
        Button {
            isPresented = true
        } label: {
            ZStack {
                // Pulse effect
                if pulse {
                    Circle()
                        .fill(Color.blue.opacity(0.3))
                        .frame(width: 64, height: 64)
                        .scaleEffect(isPulsing ? 1.2 : 1.0)
                        .opacity(isPulsing ? 0 : 0.5)
                        .animation(
                            .easeInOut(duration: 1.5)
                                .repeatForever(autoreverses: false),
                            value: isPulsing
                        )
                }

                // Main button
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.blue, Color.blue.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                    .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                    .overlay {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                    }
            }
        }
        .buttonStyle(.plain)
        .onAppear {
            if pulse {
                isPulsing = true
            }
        }
    }
}

/// Container view that adds the Coach FAB overlay to any view.
struct WithCoachFAB<Content: View>: View {
    @Binding var showCoach: Bool
    var showFAB: Bool = true
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .overlay(alignment: .bottomTrailing) {
                if showFAB {
                    CoachFAB(isPresented: $showCoach, pulse: false)
                        .padding(.trailing, 16)
                        .padding(.bottom, 16)
                }
            }
    }
}

// MARK: - Preview

#Preview("FAB") {
    ZStack {
        Color(.systemBackground)
        CoachFAB(isPresented: .constant(false))
    }
}

#Preview("With Content") {
    WithCoachFAB(showCoach: .constant(false)) {
        List {
            ForEach(0..<20) { i in
                Text("Item \(i)")
            }
        }
    }
}
