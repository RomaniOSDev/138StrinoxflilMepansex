import StoreKit
import SwiftUI
import UIKit

struct SettingsView: View {
    @EnvironmentObject private var storage: GameStorage
    @State private var showResetAlert = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                AppSectionTitle(text: "Statistics")

                VStack(spacing: 10) {
                    SettingsStatCell(title: "Games played", value: "\(storage.totalGamesPlayed)")
                    SettingsStatCell(title: "Total stars", value: "\(storage.totalStarsEarned)")
                    SettingsStatCell(title: "Time played", value: formattedTime(storage.totalPlayTimeSeconds))
                }

                AppSectionTitle(text: "Progress", topPadding: 8)

                VStack(spacing: 10) {
                    ForEach(GameKind.allCases, id: \.self) { game in
                        SettingsGameProgressCell(
                            title: game.displayTitle,
                            detail: bestLevelLabel(for: game)
                        )
                    }
                }

                AppSectionTitle(text: "Support & legal", topPadding: 8)

                VStack(spacing: 10) {
                    SettingsExternalLinkCell(title: "Rate us", symbol: "star.fill") {
                        rateApp()
                    }

                    SettingsExternalLinkCell(title: "Privacy policy", symbol: "lock.shield.fill") {
                        openPolicy()
                    }

                    SettingsExternalLinkCell(title: "Terms of use", symbol: "doc.text.fill") {
                        openTerms()
                    }
                }

                Button {
                    showResetAlert = true
                } label: {
                    SettingsDangerActionCell(title: "Reset All Progress")
                }
                .buttonStyle(.pressableScale)
                .padding(.top, 8)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .padding(.bottom, 110)
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Reset all progress?", isPresented: $showResetAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                storage.resetAllProgress()
            }
        } message: {
            Text("This removes stars, unlocks, and statistics from this device.")
        }
    }

    private func openPolicy() {
        if let url = AppExternalLink.privacyPolicy.url {
            UIApplication.shared.open(url)
        }
    }

    private func openTerms() {
        if let url = AppExternalLink.termsOfUse.url {
            UIApplication.shared.open(url)
        }
    }

    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }

    private func formattedTime(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        return "\(hours)h \(minutes)m"
    }

    private func bestLevelLabel(for game: GameKind) -> String {
        let best = storage.bestLevelIndex(for: game)
        if best < 0 {
            return "No clears yet"
        }
        return "Best stage \(best + 1)"
    }
}
