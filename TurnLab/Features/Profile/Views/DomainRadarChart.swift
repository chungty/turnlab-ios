import SwiftUI

/// Radar chart showing skill balance across domains.
struct DomainRadarChart: View {
    let domainProgress: [SkillDomain: Double]

    var body: some View {
        ContentCard(title: "Skill Balance", icon: "pentagon") {
            VStack(spacing: TurnLabSpacing.md) {
                // Radar chart visualization
                GeometryReader { geometry in
                    let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    let radius = min(geometry.size.width, geometry.size.height) / 2 - 30

                    ZStack {
                        // Background rings
                        ForEach([0.25, 0.5, 0.75, 1.0], id: \.self) { scale in
                            RadarPolygon(
                                sides: SkillDomain.allCases.count,
                                scale: scale
                            )
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            .frame(width: radius * 2, height: radius * 2)
                        }

                        // Data polygon
                        RadarDataPolygon(values: domainValues)
                            .fill(Color.accentColor.opacity(0.3))
                            .frame(width: radius * 2, height: radius * 2)

                        RadarDataPolygon(values: domainValues)
                            .stroke(Color.accentColor, lineWidth: 2)
                            .frame(width: radius * 2, height: radius * 2)

                        // Domain labels
                        ForEach(Array(SkillDomain.allCases.enumerated()), id: \.element) { index, domain in
                            let angle = angleForIndex(index, total: SkillDomain.allCases.count)
                            let labelRadius = radius + 20

                            VStack(spacing: 2) {
                                Image(systemName: domain.iconName)
                                    .font(.caption)
                                    .foregroundStyle(domain.color)
                                Text(domain.shortName)
                                    .font(.caption2)
                                    .foregroundStyle(TurnLabColors.textSecondary)
                            }
                            .position(
                                x: center.x + labelRadius * cos(angle),
                                y: center.y + labelRadius * sin(angle)
                            )
                        }
                    }
                }
                .frame(height: 200)

                // Legend
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: TurnLabSpacing.xs) {
                    ForEach(SkillDomain.allCases) { domain in
                        HStack(spacing: 4) {
                            Circle()
                                .fill(domain.color)
                                .frame(width: 8, height: 8)
                            Text(domain.shortName)
                                .font(.caption2)
                            Spacer()
                            Text("\(Int((domainProgress[domain] ?? 0) * 100))%")
                                .font(.caption2)
                                .foregroundStyle(TurnLabColors.textSecondary)
                        }
                    }
                }
            }
        }
    }

    private var domainValues: [Double] {
        SkillDomain.allCases.map { domainProgress[$0] ?? 0 }
    }

    private func angleForIndex(_ index: Int, total: Int) -> Double {
        let startAngle = -Double.pi / 2 // Start from top
        let angleIncrement = 2 * Double.pi / Double(total)
        return startAngle + angleIncrement * Double(index)
    }
}

struct RadarPolygon: Shape {
    let sides: Int
    let scale: Double

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2 * scale

        for i in 0..<sides {
            let angle = angleForIndex(i)
            let point = CGPoint(
                x: center.x + radius * cos(angle),
                y: center.y + radius * sin(angle)
            )
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        return path
    }

    private func angleForIndex(_ index: Int) -> Double {
        let startAngle = -Double.pi / 2
        let angleIncrement = 2 * Double.pi / Double(sides)
        return startAngle + angleIncrement * Double(index)
    }
}

struct RadarDataPolygon: Shape {
    let values: [Double]

    func path(in rect: CGRect) -> Path {
        guard !values.isEmpty else { return Path() }

        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let maxRadius = min(rect.width, rect.height) / 2

        for (index, value) in values.enumerated() {
            let angle = angleForIndex(index)
            let radius = maxRadius * value
            let point = CGPoint(
                x: center.x + radius * cos(angle),
                y: center.y + radius * sin(angle)
            )
            if index == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        return path
    }

    private func angleForIndex(_ index: Int) -> Double {
        let startAngle = -Double.pi / 2
        let angleIncrement = 2 * Double.pi / Double(values.count)
        return startAngle + angleIncrement * Double(index)
    }
}

#Preview {
    DomainRadarChart(
        domainProgress: [
            .balance: 0.8,
            .edgeControl: 0.6,
            .rotaryMovements: 0.7,
            .pressureManagement: 0.4,
            .terrainAdaptation: 0.5
        ]
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}
