import SwiftUI

/// Tag displaying skill domain with icon and color.
struct DomainTag: View {
    let domain: SkillDomain
    var showIcon: Bool = true
    var style: TagStyle = .filled

    enum TagStyle {
        case filled, outlined
    }

    var body: some View {
        HStack(spacing: 4) {
            if showIcon {
                Image(systemName: domain.iconName)
                    .font(.caption2)
            }
            Text(domain.shortName)
                .font(.caption)
                .fontWeight(.medium)
        }
        .foregroundStyle(style == .filled ? .white : domain.color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background {
            if style == .filled {
                Capsule().fill(domain.color)
            } else {
                Capsule().stroke(domain.color, lineWidth: 1)
            }
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        ForEach(SkillDomain.allCases) { domain in
            HStack {
                DomainTag(domain: domain, style: .filled)
                DomainTag(domain: domain, style: .outlined)
            }
        }
    }
    .padding()
}
