import SwiftUI

enum MainTab: Int, CaseIterable {
    case home
    case achievements
    case settings

    var title: String {
        switch self {
        case .home: return "Home"
        case .achievements: return "Achievements"
        case .settings: return "Settings"
        }
    }

    var symbol: String {
        switch self {
        case .home: return "house.fill"
        case .achievements: return "star.circle.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

struct CustomTabBar: View {
    @Binding var selection: MainTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(MainTab.allCases, id: \.rawValue) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selection = tab
                    }
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: tab.symbol)
                            .font(.system(size: 22, weight: .semibold, design: .rounded))
                            .foregroundStyle(selection == tab ? Color.appPrimary : Color.appTextSecondary)

                        Text(tab.title)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(selection == tab ? Color.appPrimary : Color.appTextSecondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 8)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.pressableScale)
                .accessibilityLabel(Text(tab.title))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .appCellSurface(elevation: .lifted)
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
}
