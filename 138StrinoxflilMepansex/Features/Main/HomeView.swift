import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var storage: GameStorage
    @Binding var selectedTab: MainTab

    private var greetingHeadline: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<22: return "Good evening"
        default: return "Welcome back"
        }
    }

    private var clearedStageCount: Int {
        var n = 0
        for game in GameKind.allCases {
            for level in 0..<GameConstants.levelsPerGame {
                if storage.stars(for: game, level: level) > 0 {
                    n += 1
                }
            }
        }
        return n
    }

    private var unlockedAchievementCount: Int {
        AchievementID.allCases.filter { $0.isUnlocked(using: storage) }.count
    }

    private var continueTarget: (game: GameKind, level: Int, tier: ChallengeTier)? {
        if storage.totalGamesPlayed == 0 {
            return (.precisionDrop, 0, .normal)
        }
        for game in GameKind.allCases {
            for level in 0..<GameConstants.levelsPerGame {
                guard storage.isLevelUnlocked(game: game, level: level) else { continue }
                if storage.stars(for: game, level: level) < 3 {
                    return (game, level, .normal)
                }
            }
        }
        return (.precisionDrop, 0, .normal)
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(greetingHeadline)
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.appTextPrimary)

                    Text("Your practice hub — quick stats, resume, and every activity.")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.appTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .appCellSurface(fillOpacity: 0.92, strokeOpacity: 0.26, elevation: .lifted)

                PlayHeroBanner()
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .appCellSurface(
                        cornerRadius: 16,
                        fillOpacity: 0.55,
                        strokeOpacity: 0.28,
                        elevation: .soft,
                        bottomShade: 0.82
                    )

                HStack(spacing: 10) {
                    HomeStatChip(
                        icon: "star.fill",
                        value: "\(storage.totalStarsEarned)",
                        label: "Stars"
                    )
                    HomeStatChip(
                        icon: "checkmark.circle.fill",
                        value: "\(clearedStageCount)",
                        label: "Clears"
                    )
                    HomeStatChip(
                        icon: "gamecontroller.fill",
                        value: "\(storage.totalGamesPlayed)",
                        label: "Runs"
                    )
                }

                if let target = continueTarget {
                    NavigationLink {
                        gameSessionView(game: target.game, level: target.level, tier: target.tier)
                    } label: {
                        HomeContinueCard(
                            gameTitle: target.game.displayTitle,
                            stageNumber: target.level + 1,
                            isFreshStart: storage.totalGamesPlayed == 0
                        )
                    }
                    .buttonStyle(.plain)
                }

                VStack(spacing: 10) {
                    HomeShortcutRow(
                        title: "Achievements",
                        subtitle: "\(unlockedAchievementCount) of \(AchievementID.allCases.count) unlocked",
                        symbol: "trophy.fill"
                    ) {
                        selectedTab = .achievements
                    }

                    HomeShortcutRow(
                        title: "Settings",
                        subtitle: "Stats, progress, and reset",
                        symbol: "gearshape.fill"
                    ) {
                        selectedTab = .settings
                    }
                }

                AppSectionTitle(text: "Activities", topPadding: 4)

                VStack(spacing: 14) {
                    ForEach(GameKind.allCases, id: \.self) { game in
                        NavigationLink {
                            GameSelectionView(game: game)
                        } label: {
                            PlayGameCardCell(game: game, starsEarned: storage.totalStars(for: game))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 110)
        }
        .scrollIndicators(.hidden)
        .toolbar(.hidden, for: .navigationBar)
    }

    @ViewBuilder
    private func gameSessionView(game: GameKind, level: Int, tier: ChallengeTier) -> some View {
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

// MARK: - Subviews

private struct HomeStatChip: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.appAccent)

            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(Color.appTextPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            Text(label)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.appTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .padding(.horizontal, 8)
        .appCellInset()
    }
}

private struct HomeContinueCard: View {
    let gameTitle: String
    let stageNumber: Int
    var isFreshStart: Bool

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.appPrimary.opacity(0.45),
                                Color.appAccent.opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color.appAccent.opacity(0.35), lineWidth: 1)
                    )
                    .frame(width: 52, height: 52)
                    .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 3)

                Image(systemName: isFreshStart ? "play.fill" : "arrow.forward.circle.fill")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(Color.appTextPrimary)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(isFreshStart ? "Start playing" : "Continue")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.appTextSecondary)

                Text("\(gameTitle) · Stage \(stageNumber)")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.appTextSecondary)
        }
        .padding(16)
        .appCellSurface(fillOpacity: 0.92, strokeOpacity: 0.35, elevation: .medium)
        .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private struct HomeShortcutRow: View {
    let title: String
    let subtitle: String
    let symbol: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: symbol)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color.appAccent)
                    .frame(width: 40, height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.appPrimary.opacity(0.32),
                                        Color.appAccent.opacity(0.18)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.appAccent.opacity(0.28), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.16), radius: 5, x: 0, y: 2)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.appTextPrimary)
                    Text(subtitle)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.appTextSecondary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.85)
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.appTextSecondary)
            }
            .padding(14)
            .appCellInset()
        }
        .buttonStyle(.pressableScale)
    }
}
