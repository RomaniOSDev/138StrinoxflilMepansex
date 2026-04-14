import SwiftUI

struct MainTabView: View {
    @State private var tab: MainTab = .home

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch tab {
                case .home:
                    NavigationStack {
                        HomeView(selectedTab: $tab)
                    }
                case .achievements:
                    NavigationStack {
                        AchievementsView()
                    }
                case .settings:
                    NavigationStack {
                        SettingsView()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            CustomTabBar(selection: $tab)
        }
        .background(LayeredBackgroundView())
    }
}
