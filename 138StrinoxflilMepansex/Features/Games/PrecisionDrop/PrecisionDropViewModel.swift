import Combine
import Foundation
import SwiftUI

final class PrecisionDropViewModel: ObservableObject {
    @Published private(set) var targetCenter: CGFloat = 0.5
    @Published private(set) var ballY: CGFloat?
    @Published private(set) var dropX: CGFloat = 0.5
    @Published private(set) var isDropping = false
    @Published private(set) var resultPayload: LevelResultPayload?

    @Published var levelIndex: Int

    let tier: ChallengeTier

    private let storage: GameStorage
    private var tick: AnyCancellable?
    private var phaseTime: CGFloat = 0
    private var dropProgress: CGFloat = 0
    private var lastBallY: CGFloat = PrecisionDropViewModel.topY

    init(level: Int, tier: ChallengeTier, storage: GameStorage) {
        self.levelIndex = level
        self.tier = tier
        self.storage = storage
        startLoop()
    }

    deinit {
        tick?.cancel()
    }

    func restartLevel() {
        resultPayload = nil
        isDropping = false
        ballY = nil
        phaseTime = 0
        dropProgress = 0
        lastBallY = Self.topY
        startLoop()
    }

    func advanceToNextLevel() {
        guard levelIndex + 1 < GameConstants.levelsPerGame else { return }
        let next = levelIndex + 1
        guard storage.isLevelUnlocked(game: .precisionDrop, level: next) else { return }
        levelIndex = next
        restartLevel()
    }

    func tap(atNormalizedX x: CGFloat) {
        guard resultPayload == nil, !isDropping else { return }
        dropX = min(1, max(0, x))
        isDropping = true
        dropProgress = 0
        lastBallY = Self.topY
        ballY = Self.topY
    }

    private func startLoop() {
        tick?.cancel()
        tick = Timer.publish(every: 1.0 / 60.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.step()
            }
    }

    private func step() {
        guard resultPayload == nil else { return }

        if !isDropping {
            phaseTime += 1.0 / 60.0
            let speed = Self.targetSpeed(tier: tier, level: levelIndex)
            let amplitude = Self.amplitude(tier: tier)
            targetCenter = 0.5 + CGFloat(sin(Double(phaseTime) * Double(speed))) * amplitude
            return
        }

        let duration = Self.dropDuration(tier: tier, level: levelIndex)
        dropProgress += (1.0 / 60.0) / duration
        let clamped = min(1, dropProgress)
        let newY = Self.topY + (Self.bottomY - Self.topY) * clamped

        if failsObstacleCrossing(from: lastBallY, to: newY, x: dropX) {
            completeRun(stars: 0, score: 0)
            return
        }

        lastBallY = newY
        ballY = newY

        if clamped >= 1 {
            resolveLanding()
        }
    }

    private func obstacleSpecs() -> [(y: CGFloat, gapStart: CGFloat, gapEnd: CGFloat)] {
        let gapHalf = Self.gapHalfWidth(tier: tier, level: levelIndex)
        let center: CGFloat = 0.5
        if levelIndex < 3 {
            return []
        }
        if levelIndex < 6 {
            return [(y: 0.52, gapStart: center - gapHalf, gapEnd: center + gapHalf)]
        }
        return [
            (y: 0.4, gapStart: center - gapHalf * 0.95, gapEnd: center + gapHalf * 0.95),
            (y: 0.64, gapStart: center - gapHalf * 0.85, gapEnd: center + gapHalf * 0.85)
        ]
    }

    private func failsObstacleCrossing(from y0: CGFloat, to y1: CGFloat, x: CGFloat) -> Bool {
        let minY = min(y0, y1)
        let maxY = max(y0, y1)
        for obs in obstacleSpecs() {
            if minY <= obs.y, obs.y <= maxY {
                if x < obs.gapStart || x > obs.gapEnd {
                    return true
                }
            }
        }
        return false
    }

    private func resolveLanding() {
        let x = dropX
        let center = targetCenter
        let realHalf = Self.realZoneHalfWidth(tier: tier)

        if tier == .hard {
            let inReal = abs(x - center) <= realHalf
            let inFake = isFakeBand(x: x, center: center, realHalf: realHalf)
            if inFake, !inReal {
                completeRun(stars: 0, score: 0)
                return
            }
            if !inReal {
                completeRun(stars: 0, score: 0)
                return
            }
        } else {
            guard abs(x - center) <= realHalf else {
                completeRun(stars: 0, score: 0)
                return
            }
        }

        let normalized = abs(x - center) / max(realHalf, 0.0001)
        let stars: Int
        if normalized < 0.35 {
            stars = 3
        } else if normalized < 0.68 {
            stars = 2
        } else {
            stars = 1
        }

        let score = stars * 140 + Int((1 - normalized) * 90)
        completeRun(stars: stars, score: score)
    }

    private func isFakeBand(x: CGFloat, center: CGFloat, realHalf: CGFloat) -> Bool {
        let leftRange = (center - 0.42)...(center - realHalf)
        let rightRange = (center + realHalf)...(center + 0.42)
        return leftRange.contains(x) || rightRange.contains(x)
    }

    private func completeRun(stars: Int, score: Int) {
        guard resultPayload == nil else { return }
        tick?.cancel()
        let payload = storage.applyLevelResult(
            game: .precisionDrop,
            level: levelIndex,
            starsEarned: stars,
            score: score,
            tier: tier
        )
        resultPayload = payload
        isDropping = false
        ballY = Self.bottomY
    }

    private static let topY: CGFloat = 0.12
    private static let bottomY: CGFloat = 0.86

    private static func targetSpeed(tier: ChallengeTier, level: Int) -> CGFloat {
        let base: CGFloat
        switch tier {
        case .easy: base = 0.72
        case .normal: base = 1.08
        case .hard: base = 1.45
        }
        return base + CGFloat(level) * 0.05
    }

    private static func amplitude(tier: ChallengeTier) -> CGFloat {
        switch tier {
        case .easy: return 0.32
        case .normal: return 0.34
        case .hard: return 0.36
        }
    }

    private static func dropDuration(tier: ChallengeTier, level: Int) -> CGFloat {
        let base: CGFloat
        switch tier {
        case .easy: base = 1.75
        case .normal: base = 1.4
        case .hard: base = 1.15
        }
        return max(0.65, base - CGFloat(level) * 0.025)
    }

    private static func gapHalfWidth(tier: ChallengeTier, level: Int) -> CGFloat {
        let base: CGFloat
        switch tier {
        case .easy: base = 0.14
        case .normal: base = 0.11
        case .hard: base = 0.09
        }
        return max(0.06, base - CGFloat(level) * 0.004)
    }

    private static func realZoneHalfWidth(tier: ChallengeTier) -> CGFloat {
        switch tier {
        case .easy: return 0.15
        case .normal: return 0.12
        case .hard: return 0.075
        }
    }
}
