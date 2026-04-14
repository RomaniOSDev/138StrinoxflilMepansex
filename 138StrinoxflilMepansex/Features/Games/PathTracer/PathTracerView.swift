import SwiftUI

struct PathTracerView: View {
    @EnvironmentObject private var storage: GameStorage
    @Environment(\.dismiss) private var dismiss

    @StateObject private var viewModel: PathTracerViewModel
    @State private var sessionStart = Date()
    @State private var showResult = false

    init(level: Int, tier: ChallengeTier) {
        _viewModel = StateObject(wrappedValue: PathTracerViewModel(level: level, tier: tier, storage: GameStorage.shared))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                GameSessionHeaderCell(
                    stageLabel: "Stage \(viewModel.levelIndex + 1)",
                    tierLabel: viewModel.tier.label,
                    accentBanner: pathTracerTimeBanner
                )

                GeometryReader { geo in
                    let width = geo.size.width
                    let height = geo.size.height

                    ZStack {
                        Path { path in
                            let pts = PathTracerData.polyline(for: viewModel.levelIndex)
                            guard let first = pts.first else { return }
                            path.move(to: CGPoint(x: first.x * width, y: first.y * height))
                            for point in pts.dropFirst() {
                                path.addLine(to: CGPoint(x: point.x * width, y: point.y * height))
                            }
                        }
                        .stroke(Color.appAccent.opacity(0.85), style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))

                        if let finger = viewModel.finger {
                            Circle()
                                .fill(Color.appPrimary)
                                .frame(width: 18, height: 18)
                                .position(x: finger.x * width, y: finger.y * height)
                        }
                    }
                    .frame(width: width, height: height)
                    .appCellPlayfield()
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let nx = value.location.x / width
                                let ny = value.location.y / height
                                viewModel.updateFinger(normalized: CGPoint(x: nx, y: ny))
                            }
                    )
                }
                .frame(height: 420)

                GameDualStatCell(
                    leadingTitle: "Lives: \(viewModel.lives)",
                    trailingTitle: "Accuracy: \(Int(viewModel.accuracyPercent))%"
                )

                GameHintCell(
                    text: "Drag along the bright path. Drift too far and you lose a life.",
                    alignment: .leading
                )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Path Tracer")
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
                    detail: payload.isWin ? "Smooth tracing with strong accuracy." : "Stay closer to the path next time.",
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

    private var pathTracerTimeBanner: String? {
        guard viewModel.tier == .hard, let time = viewModel.timeLeft else { return nil }
        return "Time left: \(Int(ceil(time)))s"
    }

    private func canGoNext(payload: LevelResultPayload) -> Bool {
        guard payload.isWin else { return false }
        let next = viewModel.levelIndex + 1
        guard next < GameConstants.levelsPerGame else { return false }
        return storage.isLevelUnlocked(game: .pathTracer, level: next)
    }
}
