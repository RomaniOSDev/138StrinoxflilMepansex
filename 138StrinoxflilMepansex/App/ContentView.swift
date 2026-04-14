import SwiftUI

struct ContentView: View {
    @ObservedObject private var storage = GameStorage.shared

    var body: some View {
        Group {
            if storage.hasSeenOnboarding {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .environmentObject(storage)
    }
}

#Preview {
    ContentView()
}
