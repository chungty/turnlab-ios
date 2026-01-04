import SwiftUI

/// Circular indicator showing skill rating status.
struct SkillProgressIndicator: View {
    let rating: Rating
    var size: CGFloat = 44

    var body: some View {
        ZStack {
            Circle()
                .fill(rating.color.opacity(0.15))

            Circle()
                .stroke(rating.color, lineWidth: 3)

            Image(systemName: rating.iconName)
                .font(.system(size: size * 0.4))
                .foregroundStyle(rating.color)
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    HStack(spacing: 16) {
        ForEach(Rating.allCases, id: \.self) { rating in
            VStack {
                SkillProgressIndicator(rating: rating)
                Text(rating.shortName)
                    .font(.caption2)
            }
        }
    }
    .padding()
}
