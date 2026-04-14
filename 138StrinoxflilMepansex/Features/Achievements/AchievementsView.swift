import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject private var storage: GameStorage

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(AchievementID.allCases) { achievement in
                    AchievementCardCell(
                        achievement: achievement,
                        isUnlocked: achievement.isUnlocked(using: storage)
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .padding(.bottom, 110)
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Achievements")
        .navigationBarTitleDisplayMode(.inline)
    }
}
