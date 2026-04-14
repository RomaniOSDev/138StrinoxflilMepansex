import SwiftUI

// MARK: - Play tab

struct PlayGameCardCell: View {
    let game: GameKind
    let starsEarned: Int

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.appPrimary.opacity(0.42),
                                Color.appAccent.opacity(0.28)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.appTextPrimary.opacity(0.22),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 1
                    )
                GameKindGlyph(game: game)
            }
            .frame(width: 56, height: 56)
            .shadow(color: Color.black.opacity(0.22), radius: 8, x: 0, y: 4)

            VStack(alignment: .leading, spacing: 6) {
                Text(game.displayTitle)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)

                Text(game.subtitle)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.appTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(Color.appAccent)
                    Text("\(starsEarned) stars earned")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.appTextPrimary)
                }
                .padding(.top, 4)
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.appTextSecondary)
                .padding(.top, 4)
        }
        .padding(16)
        .appCellSurface(elevation: .medium)
        .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct GameKindGlyph: View {
    let game: GameKind

    var body: some View {
        Group {
            switch game {
            case .precisionDrop:
                ZStack {
                    Circle()
                        .stroke(Color.appPrimary, lineWidth: 3)
                        .frame(width: 26, height: 26)
                    Circle()
                        .fill(Color.appAccent)
                        .frame(width: 10, height: 10)
                }
            case .pathTracer:
                Path { path in
                    path.move(to: CGPoint(x: 10, y: 38))
                    path.addQuadCurve(to: CGPoint(x: 46, y: 10), control: CGPoint(x: 30, y: 46))
                }
                .stroke(Color.appPrimary, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .frame(width: 56, height: 56)
            case .stackRush:
                VStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.appAccent)
                        .frame(width: 34, height: 8)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.appPrimary)
                        .frame(width: 28, height: 8)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.appAccent.opacity(0.8))
                        .frame(width: 22, height: 8)
                }
            }
        }
    }
}

// MARK: - Level grid

struct LevelUnlockedCell: View {
    let title: String
    let stars: Int

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(Color.appTextPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { index in
                    Image(systemName: index < stars ? "star.fill" : "star")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(index < stars ? Color.appAccent : Color.appTextSecondary.opacity(0.5))
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .padding(.horizontal, 8)
        .appCellInset()
    }
}

struct LevelLockedCell: View {
    let title: String

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(Color.appTextSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Image(systemName: "lock.fill")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.appTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .padding(.horizontal, 8)
        .appCellMuted()
    }
}

// MARK: - Settings

struct SettingsStatCell: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.appTextPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Spacer()
            Text(value)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(Color.appAccent)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .appCellInset()
    }
}

struct SettingsGameProgressCell: View {
    let title: String
    let detail: String

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.appTextPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Spacer()
            Text(detail)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(Color.appTextSecondary)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .appCellInset()
    }
}

struct SettingsDangerActionCell: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .foregroundStyle(Color.appTextPrimary)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .appCellSurface(cornerRadius: 14, fillOpacity: 0.95, strokeOpacity: 0.65, elevation: .lifted)
    }
}

struct SettingsExternalLinkCell: View {
    let title: String
    let symbol: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: symbol)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.appAccent)
                    .frame(width: 28, alignment: .center)

                Text(title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.appTextPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.appTextSecondary)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 14)
            .appCellInset()
        }
        .buttonStyle(.pressableScale)
    }
}

// MARK: - Level result actions

struct ResultPrimaryButtonCell: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 17, weight: .bold, design: .rounded))
            .foregroundStyle(Color.appTextPrimary)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.appPrimary.opacity(1),
                                    Color.appPrimary.opacity(0.72),
                                    Color.appAccent.opacity(0.55)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.appTextPrimary.opacity(0.28),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.appAccent.opacity(0.35), lineWidth: 1)
            )
            .shadow(color: Color.appPrimary.opacity(0.45), radius: 10, x: 0, y: 5)
    }
}

struct ResultSecondaryButtonCell: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .foregroundStyle(Color.appTextPrimary)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .appCellSurface(cornerRadius: 14, fillOpacity: 0.95, strokeOpacity: 0.35, elevation: .medium)
    }
}

struct ResultTertiaryButtonCell: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .foregroundStyle(Color.appTextPrimary)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .appCellSurface(cornerRadius: 14, fillOpacity: 0.78, strokeOpacity: 0.18, elevation: .soft)
    }
}

// MARK: - Achievements

struct AchievementCardCell: View {
    let achievement: AchievementID
    let isUnlocked: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: isUnlocked
                                ? [
                                    Color.appSurface.opacity(0.72),
                                    Color.appAccent.opacity(0.42),
                                    Color.appPrimary.opacity(0.28)
                                ]
                                : [
                                    Color.appSurface.opacity(0.48),
                                    Color.appSurface.opacity(0.36)
                                ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.appTextPrimary.opacity(isUnlocked ? 0.12 : 0.05),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .center
                        )
                    )

                AchievementGlyph(symbol: achievement, active: isUnlocked)
                    .opacity(isUnlocked ? 1 : 0.35)
                    .scaleEffect(isUnlocked ? 1 : 0.95)
            }
            .frame(height: 96)
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.appAccent.opacity(isUnlocked ? 0.45 : 0.14), lineWidth: 1)
            )
            .shadow(
                color: isUnlocked ? Color.appAccent.opacity(0.28) : Color.clear,
                radius: isUnlocked ? 10 : 0,
                x: 0,
                y: isUnlocked ? 5 : 0
            )
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isUnlocked)

            Text(achievement.title)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(Color.appTextPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.7)

            Text(achievement.detail)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(Color.appTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .appCellOuterPad()
    }
}

private struct AchievementGlyph: View {
    let symbol: AchievementID
    let active: Bool

    var body: some View {
        ZStack {
            switch symbol {
            case .firstWin:
                Image(systemName: "flag.checkered")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(active ? Color.appPrimary : Color.appTextSecondary)
            case .starGatherer:
                Image(systemName: "sparkles")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(active ? Color.appAccent : Color.appTextSecondary)
            case .longHaul:
                Image(systemName: "hourglass")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(active ? Color.appPrimary : Color.appTextSecondary)
            case .dropVirtuoso:
                Circle()
                    .stroke(active ? Color.appPrimary : Color.appTextSecondary, lineWidth: 4)
                    .frame(width: 44, height: 44)
                    .overlay {
                        Circle()
                            .fill(active ? Color.appAccent : Color.appTextSecondary.opacity(0.4))
                            .frame(width: 12, height: 12)
                    }
            case .tracerBold:
                Path { path in
                    path.move(to: CGPoint(x: 10, y: 50))
                    path.addQuadCurve(to: CGPoint(x: 60, y: 10), control: CGPoint(x: 40, y: 55))
                }
                .stroke(active ? Color.appPrimary : Color.appTextSecondary, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .frame(width: 70, height: 60)
            case .stackSurge:
                VStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(active ? Color.appAccent : Color.appTextSecondary.opacity(0.5))
                        .frame(width: 44, height: 8)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(active ? Color.appPrimary : Color.appTextSecondary.opacity(0.5))
                        .frame(width: 36, height: 8)
                }
            case .balancedGlory:
                HStack(spacing: 6) {
                    ForEach(0..<3, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 3)
                            .fill(active ? Color.appAccent : Color.appTextSecondary.opacity(0.4))
                            .frame(width: 14, height: 22)
                    }
                }
            case .fullConstellation:
                Image(systemName: "star.leadinghalf.filled")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(active ? Color.appAccent : Color.appTextSecondary)
            }
        }
    }
}

// MARK: - Game session (header + hint)

struct GameSessionHeaderCell: View {
    let stageLabel: String
    let tierLabel: String
    var accentBanner: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(stageLabel)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.appTextSecondary)
                    Text(tierLabel)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.appTextPrimary)
                }
                Spacer()
            }
            if let accentBanner {
                Text(accentBanner)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.appAccent)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(14)
        .appCellSurface(fillOpacity: 0.88, strokeOpacity: 0.24, elevation: .medium)
    }
}

struct GameHintCell: View {
    let text: String
    var alignment: TextAlignment = .center

    private var frameAlignment: Alignment {
        switch alignment {
        case .leading: return .leading
        case .trailing: return .trailing
        default: return .center
        }
    }

    var body: some View {
        Text(text)
            .font(.system(size: 14, weight: .semibold, design: .rounded))
            .foregroundStyle(Color.appTextSecondary)
            .multilineTextAlignment(alignment)
            .frame(maxWidth: .infinity, alignment: frameAlignment)
            .padding(12)
            .appCellMuted(fillOpacity: 0.42, strokeOpacity: 0.15)
    }
}

struct GameDualStatCell: View {
    let leadingTitle: String
    let trailingTitle: String

    var body: some View {
        HStack {
            Text(leadingTitle)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(Color.appTextPrimary)
            Spacer()
            Text(trailingTitle)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(Color.appAccent)
        }
        .padding(12)
        .appCellSurface(fillOpacity: 0.85, strokeOpacity: 0.22, elevation: .soft)
    }
}

// MARK: - Onboarding

struct OnboardingPageCell<Illustration: View>: View {
    let illustration: Illustration
    let title: String
    let detail: String
    var pageIndex: Int = 1
    var totalPages: Int = 3
    var artScale: CGFloat = 1
    var artOpacity: Double = 1

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                Text("Step \(pageIndex) of \(totalPages)")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.appTextSecondary)
                    .textCase(.uppercase)
                    .tracking(0.6)

                Spacer(minLength: 0)

                Text(String(format: "%02d", pageIndex))
                    .font(.system(size: 13, weight: .bold, design: .rounded).monospacedDigit())
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.appAccent, Color.appPrimary.opacity(0.9)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
            .padding(.bottom, 14)

            illustration
                .frame(height: 228)
                .scaleEffect(artScale)
                .opacity(artOpacity)

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.clear,
                            Color.appAccent.opacity(0.35),
                            Color.clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 1)
                .padding(.vertical, 18)

            Text(title)
                .font(.system(size: 25, weight: .bold, design: .rounded))
                .foregroundStyle(Color.appTextPrimary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 8)

            Text(detail)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(Color.appTextSecondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .lineSpacing(3)
        }
        .padding(20)
        .appCellSurface(fillOpacity: 0.93, strokeOpacity: 0.28, elevation: .lifted)
    }
}

// MARK: - Game selection (difficulty)

struct DifficultyPickerCell: View {
    @Binding var tier: ChallengeTier

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            AppSectionTitle(text: "Choose difficulty", onLightSurface: true)
            Picker("Difficulty", selection: $tier) {
                ForEach(ChallengeTier.allCases, id: \.self) { value in
                    Text(value.label).tag(value)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding(14)
        .appCellSurface(fillOpacity: 0.88, strokeOpacity: 0.22, elevation: .medium)
    }
}
