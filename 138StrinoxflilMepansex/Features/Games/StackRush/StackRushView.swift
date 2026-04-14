import SwiftUI

struct StackRushView: View {
    @EnvironmentObject private var storage: GameStorage
    @Environment(\.dismiss) private var dismiss

    @StateObject private var viewModel: StackRushViewModel
    @State private var sessionStart = Date()
    @State private var showResult = false

    /// Vertical position of the active slab (normalized 0..1, top = small).
    @State private var activeBlockY: CGFloat = StackRushConstants.topSlideY
    @State private var isAnimatingFall = false

    init(level: Int, tier: ChallengeTier) {
        _viewModel = StateObject(wrappedValue: StackRushViewModel(level: level, tier: tier, storage: GameStorage.shared))
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

                    ZStack(alignment: .bottom) {
                        StackRushPlayfieldBackground()

                        ForEach(Array(viewModel.stack.enumerated()), id: \.offset) { index, layer in
                            let y = layerCenterY(index: index, height: height)
                            let slabKind: StackRushSlabKind = index == 0
                                ? .foundation
                                : .stacked(variant: index - 1)
                            StackRushSlab(
                                width: max(12, layer.width * width),
                                height: StackRushConstants.layerHeight,
                                kind: slabKind
                            )
                            .position(x: layer.center * width, y: y)
                        }

                        StackRushSlab(
                            width: max(12, viewModel.currentWidth * width),
                            height: StackRushConstants.layerHeight,
                            kind: .active
                        )
                        .position(
                            x: viewModel.slidePosition * width,
                            y: activeBlockY * height
                        )
                    }
                    .frame(width: width, height: height)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.appAccent.opacity(0.28), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.3), radius: 16, x: 0, y: 8)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        handleTap(fieldHeight: height)
                    }
                }
                .frame(height: 420)

                GameDualStatCell(
                    leadingTitle: "Score \(viewModel.score)",
                    trailingTitle: "Combo x\(viewModel.combo)"
                )

                GameHintCell(
                    text: "Tap to drop the slab. It falls onto the stack — align overlaps to climb higher.",
                    alignment: .leading
                )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Stack Rush")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            sessionStart = Date()
            activeBlockY = StackRushConstants.topSlideY
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
                    detail: payload.isWin ? "Your stack stayed sharp and steady." : "The next slab missed the edge.",
                    canGoNext: canGoNext(payload: payload),
                    onNext: {
                        showResult = false
                        viewModel.advanceToNextLevel()
                        activeBlockY = StackRushConstants.topSlideY
                    },
                    onRetry: {
                        showResult = false
                        viewModel.restartLevel()
                        activeBlockY = StackRushConstants.topSlideY
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

    private func layerCenterY(index: Int, height: CGFloat) -> CGFloat {
        let yNorm = StackRushConstants.bottomY - CGFloat(index) * StackRushConstants.layerSpacing
        return yNorm * height
    }

    private func handleTap(fieldHeight: CGFloat) {
        guard !isAnimatingFall else { return }
        guard viewModel.resultPayload == nil else { return }

        viewModel.beginDrop()
        guard viewModel.isDropping else { return }

        runFallAnimation(fieldHeight: fieldHeight)
    }

    private func runFallAnimation(fieldHeight: CGFloat) {
        guard !isAnimatingFall else { return }
        isAnimatingFall = true

        let landingIndex = viewModel.stack.count
        let landingYNorm = StackRushConstants.bottomY - CGFloat(landingIndex) * StackRushConstants.layerSpacing

        activeBlockY = StackRushConstants.topSlideY

        withAnimation(.spring(response: 0.55, dampingFraction: 0.82)) {
            activeBlockY = landingYNorm
        }

        let delay = 0.62
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            viewModel.finalizeDropAfterAnimation()
            isAnimatingFall = false
            activeBlockY = StackRushConstants.topSlideY
        }
    }

    private func canGoNext(payload: LevelResultPayload) -> Bool {
        guard payload.isWin else { return false }
        let next = viewModel.levelIndex + 1
        guard next < GameConstants.levelsPerGame else { return false }
        return storage.isLevelUnlocked(game: .stackRush, level: next)
    }
}

private enum StackRushConstants {
    /// Normalized Y of the sliding slab (near top of the field).
    static let topSlideY: CGFloat = 0.12
    /// Normalized Y of the bottom of the stack (center of base layer).
    static let bottomY: CGFloat = 0.9
    /// Vertical spacing between layer centers (normalized).
    static let layerSpacing: CGFloat = 0.052
    static let layerHeight: CGFloat = 18
}
