import SwiftUI

struct PrecisionDropView: View {
    @EnvironmentObject private var storage: GameStorage
    @Environment(\.dismiss) private var dismiss

    @StateObject private var viewModel: PrecisionDropViewModel
    @State private var sessionStart = Date()
    @State private var showResult = false

    init(level: Int, tier: ChallengeTier) {
        _viewModel = StateObject(wrappedValue: PrecisionDropViewModel(level: level, tier: tier, storage: GameStorage.shared))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                GameSessionHeaderCell(
                    stageLabel: "Stage \(viewModel.levelIndex + 1)",
                    tierLabel: viewModel.tier.label
                )

                GeometryReader { geo in
                    let width = geo.size.width
                    let height = geo.size.height

                    ZStack {
                        ForEach(Array(obstacleRects(in: CGSize(width: width, height: height)).enumerated()), id: \.offset) { _, rect in
                            Rectangle()
                                .fill(Color.appTextSecondary.opacity(0.35))
                                .frame(width: rect.width, height: rect.height)
                                .position(x: rect.midX, y: rect.midY)
                        }

                        targetBar(width: width, height: height)

                        if let ballY = viewModel.ballY {
                            let x = viewModel.dropX * width
                            let y = ballY * height
                            Circle()
                                .fill(Color.appPrimary)
                                .overlay {
                                    Circle().stroke(Color.appAccent, lineWidth: 2)
                                }
                                .frame(width: 22, height: 22)
                                .position(x: x, y: y)
                        }
                    }
                    .frame(width: width, height: height)
                    .appCellPlayfield()
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onEnded { value in
                                let nx = value.location.x / width
                                viewModel.tap(atNormalizedX: nx)
                            }
                    )
                }
                .frame(height: 420)

                GameHintCell(text: "Tap anywhere to release the sphere.")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Precision Drop")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            sessionStart = Date()
        }
        .onDisappear {
            let delta = Date().timeIntervalSince(sessionStart)
            storage.recordSessionDuration(delta)
        }
        .onChange(of: viewModel.resultPayload) { newValue in
            showResult = newValue != nil
        }
        .fullScreenCover(isPresented: $showResult) {
            if let payload = viewModel.resultPayload {
                LevelResultView(
                    payload: payload,
                    heading: payload.isWin ? "Stage Clear" : "Try Again",
                    detail: payload.isWin ? "Great timing on that landing." : "The obstacle or zone stopped you.",
                    canGoNext: canGoNext(payload: payload),
                    onNext: {
                        showResult = false
                        viewModel.advanceToNextLevel()
                    },
                    onRetry: {
                        showResult = false
                        viewModel.restartLevel()
                    },
                    onBack: {
                        showResult = false
                        dismiss()
                    }
                )
            } else {
                Color.clear
            }
        }
    }

    private func canGoNext(payload: LevelResultPayload) -> Bool {
        guard payload.isWin else { return false }
        let next = viewModel.levelIndex + 1
        guard next < GameConstants.levelsPerGame else { return false }
        return storage.isLevelUnlocked(game: .precisionDrop, level: next)
    }

    private func obstacleRects(in size: CGSize) -> [CGRect] {
        let specs = obstacleSpecsForLayout()
        var rects: [CGRect] = []
        for spec in specs {
            let y = spec.y * size.height
            let gapStart = spec.gapStart * size.width
            let gapEnd = spec.gapEnd * size.width
            rects.append(CGRect(x: 0, y: y - 5, width: gapStart, height: 10))
            rects.append(CGRect(x: gapEnd, y: y - 5, width: size.width - gapEnd, height: 10))
        }
        return rects
    }

    private func obstacleSpecsForLayout() -> [(y: CGFloat, gapStart: CGFloat, gapEnd: CGFloat)] {
        let tier = viewModel.tier
        let level = viewModel.levelIndex
        let gapHalf = Self.gapHalfWidthShared(tier: tier, level: level)
        let center: CGFloat = 0.5
        if level < 3 { return [] }
        if level < 6 {
            return [(y: 0.52, gapStart: center - gapHalf, gapEnd: center + gapHalf)]
        }
        return [
            (y: 0.4, gapStart: center - gapHalf * 0.95, gapEnd: center + gapHalf * 0.95),
            (y: 0.64, gapStart: center - gapHalf * 0.85, gapEnd: center + gapHalf * 0.85)
        ]
    }

    private static func gapHalfWidthShared(tier: ChallengeTier, level: Int) -> CGFloat {
        let base: CGFloat
        switch tier {
        case .easy: base = 0.14
        case .normal: base = 0.11
        case .hard: base = 0.09
        }
        return max(0.06, base - CGFloat(level) * 0.004)
    }

    private func targetBar(width: CGFloat, height: CGFloat) -> some View {
        let center = viewModel.targetCenter * width
        let bottomY = 0.86 * height
        let realHalf = realHalfPixels(for: width)

        return ZStack {
            if viewModel.tier == .hard {
                let leftWidth = max(0, center - realHalf - 16)
                if leftWidth > 0 {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.appPrimary.opacity(0.35))
                        .frame(width: leftWidth, height: 18)
                        .position(x: 16 + leftWidth / 2, y: bottomY - 10)
                }

                let rightWidth = max(0, width - center - realHalf - 16)
                if rightWidth > 0 {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.appPrimary.opacity(0.35))
                        .frame(width: rightWidth, height: 18)
                        .position(x: width - 16 - rightWidth / 2, y: bottomY - 10)
                }
            }

            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.appAccent.opacity(0.35))
                .frame(width: realHalf * 2, height: 18)
                .position(x: center, y: bottomY)
        }
        .frame(width: width, height: height, alignment: .bottom)
    }

    private func realHalfPixels(for width: CGFloat) -> CGFloat {
        let tier = viewModel.tier
        let half: CGFloat
        switch tier {
        case .easy: half = 0.15
        case .normal: half = 0.12
        case .hard: half = 0.075
        }
        return max(36, half * width)
    }
}
