import SwiftUI

struct GameSelectionView: View {
    let game: GameKind

    @EnvironmentObject private var storage: GameStorage
    @State private var tier: ChallengeTier = .normal

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                DifficultyPickerCell(tier: $tier)

                AppSectionTitle(text: "Levels", topPadding: 4)

                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(0..<GameConstants.levelsPerGame, id: \.self) { level in
                        if storage.isLevelUnlocked(game: game, level: level) {
                            NavigationLink {
                                destination(for: level)
                            } label: {
                                LevelUnlockedCell(
                                    title: "Lv \(level + 1)",
                                    stars: storage.stars(for: game, level: level)
                                )
                            }
                            .buttonStyle(.plain)
                        } else {
                            LevelLockedCell(title: "Lv \(level + 1)")
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .padding(.bottom, 24)
        }
        .navigationTitle(game.displayTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func destination(for level: Int) -> some View {
        switch game {
        case .precisionDrop:
            PrecisionDropView(level: level, tier: tier)
        case .pathTracer:
            PathTracerView(level: level, tier: tier)
        case .stackRush:
            StackRushView(level: level, tier: tier)
        }
    }
}
