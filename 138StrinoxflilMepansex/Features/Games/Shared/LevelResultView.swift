import SwiftUI

struct LevelResultView: View {
    let payload: LevelResultPayload
    let heading: String
    let detail: String
    let canGoNext: Bool
    let onNext: () -> Void
    let onRetry: () -> Void
    let onBack: () -> Void

    @State private var starsVisible = false
    @State private var bannerOffset: CGFloat = -220
    @State private var bannerShown = false

    var body: some View {
        ZStack(alignment: .top) {
            LayeredBackgroundView()

            VStack(spacing: 18) {
                Spacer(minLength: 12)

                VStack(spacing: 18) {
                    Text(heading)
                        .font(Font.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.appTextPrimary)
                        .multilineTextAlignment(.center)

                    Text(detail)
                        .font(Font.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.appTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)

                    HStack(spacing: 10) {
                        ForEach(0..<3, id: \.self) { index in
                            let earned = index < payload.stars
                            Group {
                                if earned {
                                    StarShape()
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color.appTextPrimary.opacity(0.95),
                                                    Color.appAccent,
                                                    Color.appPrimary.opacity(0.85)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                } else {
                                    StarShape()
                                        .fill(Color.appTextSecondary.opacity(0.35))
                                }
                            }
                            .frame(width: 44, height: 44)
                            .shadow(color: earned ? Color.appAccent.opacity(0.6) : .clear, radius: 12, y: 4)
                                .scaleEffect(starsVisible ? (earned ? 1 : 0.75) : 0.35)
                                .opacity(starsVisible ? 1 : 0.2)
                                .animation(
                                    .spring(response: 0.4, dampingFraction: 0.7)
                                        .delay(Double(index) * 0.15),
                                    value: starsVisible
                                )
                        }
                    }
                    .padding(.vertical, 8)

                    Text("Score \(payload.score)")
                        .font(Font.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.appTextPrimary)
                }
                .padding(16)
                .appCellSurface(fillOpacity: 0.9, strokeOpacity: 0.26, elevation: .lifted)
                .padding(.horizontal, 16)

                Spacer()

                VStack(spacing: 12) {
                    if canGoNext {
                        Button(action: onNext) {
                            ResultPrimaryButtonCell(title: "Next Level")
                        }
                        .buttonStyle(.pressableScale)
                    }

                    Button(action: onRetry) {
                        ResultSecondaryButtonCell(title: "Retry")
                    }
                    .buttonStyle(.pressableScale)

                    Button(action: onBack) {
                        ResultTertiaryButtonCell(title: "Back to Levels")
                    }
                    .buttonStyle(.pressableScale)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 18)
            }

            if let achievement = payload.newlyUnlockedAchievement, bannerShown {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Achievement Unlocked")
                        .font(Font.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.appTextSecondary)
                    Text(achievement.title)
                        .font(Font.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.appTextPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .appCellSurface(fillOpacity: 0.98, strokeOpacity: 0.38, elevation: .lifted)
                .padding(.horizontal, 16)
                .offset(y: bannerOffset)
            }
        }
        .onAppear {
            starsVisible = true
            if payload.newlyUnlockedAchievement != nil {
                bannerShown = true
                withAnimation(.easeInOut(duration: 0.3)) {
                    bannerOffset = 0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        bannerOffset = -220
                    }
                }
            }
        }
    }
}

private struct StarShape: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outer = min(rect.width, rect.height) / 2
        let inner = outer * 0.45
        var path = Path()
        let points = 5
        for index in 0..<(points * 2) {
            let angle = CGFloat(index) * .pi / CGFloat(points) - .pi / 2
            let radius = index.isMultiple(of: 2) ? outer : inner
            let point = CGPoint(
                x: center.x + CGFloat(cos(Double(angle))) * radius,
                y: center.y + CGFloat(sin(Double(angle))) * radius
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
}
