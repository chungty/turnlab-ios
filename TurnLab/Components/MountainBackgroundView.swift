import SwiftUI

/// Gradient background with mountain-inspired aesthetics.
struct MountainBackgroundView: View {
    var style: BackgroundStyle = .day

    enum BackgroundStyle {
        case day, sunset, night
    }

    var body: some View {
        ZStack {
            // Base gradient
            gradient
                .ignoresSafeArea()

            // Mountain silhouette overlay (subtle)
            MountainSilhouette()
                .fill(Color.black.opacity(0.05))
                .ignoresSafeArea()
        }
    }

    private var gradient: LinearGradient {
        switch style {
        case .day:
            return TurnLabColors.mountainGradient
        case .sunset:
            return TurnLabColors.sunsetGradient
        case .night:
            return LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.1, blue: 0.2),
                    Color(red: 0.2, green: 0.2, blue: 0.3),
                    Color(red: 0.15, green: 0.15, blue: 0.25)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
}

/// Mountain silhouette shape
struct MountainSilhouette: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let width = rect.width
        let height = rect.height

        // Start at bottom left
        path.move(to: CGPoint(x: 0, y: height))

        // Draw mountain peaks
        path.addLine(to: CGPoint(x: width * 0.15, y: height * 0.7))
        path.addLine(to: CGPoint(x: width * 0.25, y: height * 0.8))
        path.addLine(to: CGPoint(x: width * 0.35, y: height * 0.55))
        path.addLine(to: CGPoint(x: width * 0.5, y: height * 0.65))
        path.addLine(to: CGPoint(x: width * 0.65, y: height * 0.45))
        path.addLine(to: CGPoint(x: width * 0.75, y: height * 0.6))
        path.addLine(to: CGPoint(x: width * 0.85, y: height * 0.5))
        path.addLine(to: CGPoint(x: width, y: height * 0.65))

        // Close at bottom right
        path.addLine(to: CGPoint(x: width, y: height))
        path.closeSubpath()

        return path
    }
}

#Preview {
    VStack {
        MountainBackgroundView(style: .day)
        MountainBackgroundView(style: .sunset)
        MountainBackgroundView(style: .night)
    }
}
