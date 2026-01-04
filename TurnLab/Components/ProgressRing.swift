import SwiftUI

/// Circular progress indicator with customizable appearance.
struct ProgressRing: View {
    let progress: Double
    var lineWidth: CGFloat = 8
    var size: CGFloat = 60
    var backgroundColor: Color = .gray.opacity(0.2)
    var foregroundColor: Color = .blue
    var showPercentage: Bool = true

    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(backgroundColor, lineWidth: lineWidth)

            // Progress ring
            Circle()
                .trim(from: 0, to: CGFloat(min(progress, 1.0)))
                .stroke(
                    foregroundColor,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.5), value: progress)

            // Percentage label
            if showPercentage {
                Text("\(Int(progress * 100))%")
                    .font(.system(size: size * 0.25, weight: .bold, design: .rounded))
                    .foregroundStyle(foregroundColor)
            }
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    VStack(spacing: 24) {
        ProgressRing(progress: 0.75)
        ProgressRing(progress: 0.45, foregroundColor: .orange)
        ProgressRing(progress: 0.20, size: 100, foregroundColor: .red)
    }
}
