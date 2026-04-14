import Combine
import CoreGraphics
import Foundation

final class PathTracerViewModel: ObservableObject {
    @Published private(set) var finger: CGPoint?
    @Published private(set) var lives: Int
    @Published private(set) var progress: CGFloat = 0
    @Published private(set) var accuracyPercent: CGFloat = 100
    @Published private(set) var timeLeft: CGFloat?
    @Published private(set) var resultPayload: LevelResultPayload?

    @Published var levelIndex: Int

    let tier: ChallengeTier

    private let storage: GameStorage
    private var points: [CGPoint]
    private var tick: AnyCancellable?
    private var accuracySamples: [CGFloat] = []
    private var wasOffPath = false

    init(level: Int, tier: ChallengeTier, storage: GameStorage) {
        self.levelIndex = level
        self.tier = tier
        self.storage = storage
        self.points = PathTracerData.polyline(for: level)
        self.lives = Self.startingLives(tier: tier)
        if tier == .hard {
            self.timeLeft = Self.timeLimit(for: level)
        }
        startLoop()
    }

    deinit {
        tick?.cancel()
    }

    func restartLevel() {
        resultPayload = nil
        finger = nil
        progress = 0
        accuracySamples = []
        accuracyPercent = 100
        wasOffPath = false
        lives = Self.startingLives(tier: tier)
        timeLeft = tier == .hard ? Self.timeLimit(for: levelIndex) : nil
        points = PathTracerData.polyline(for: levelIndex)
        startLoop()
    }

    func advanceToNextLevel() {
        guard levelIndex + 1 < GameConstants.levelsPerGame else { return }
        let next = levelIndex + 1
        guard storage.isLevelUnlocked(game: .pathTracer, level: next) else { return }
        levelIndex = next
        restartLevel()
    }

    func updateFinger(normalized point: CGPoint) {
        guard resultPayload == nil else { return }
        finger = point

        let closest = PolylineGeometry.closestPoint(on: points, to: point)
        let threshold = Self.distanceThreshold(tier: tier)

        if closest.distance > threshold {
            if !wasOffPath {
                lives -= 1
                wasOffPath = true
            }
        } else {
            wasOffPath = false
        }

        progress = max(progress, closest.progress)

        let sample = max(0, 1 - closest.distance / max(threshold * 2.2, 0.0001))
        accuracySamples.append(sample)
        let avg = accuracySamples.reduce(0, +) / CGFloat(max(1, accuracySamples.count))
        accuracyPercent = min(100, max(0, avg * 100))

        if lives <= 0 {
            finishRun(stars: 0, score: 0)
            return
        }

        if progress >= 0.94 {
            let stars = Self.starRating(accuracyAverage: avg)
            let score = Int(avg * 220) + stars * 120
            finishRun(stars: stars, score: score)
        }
    }

    private func step() {
        guard resultPayload == nil else { return }

        if tier == .hard, var left = timeLeft {
            left -= 1.0 / 60.0
            timeLeft = max(0, left)
            if left <= 0 {
                finishRun(stars: 0, score: 0)
            }
        }
    }

    private func finishRun(stars: Int, score: Int) {
        guard resultPayload == nil else { return }
        tick?.cancel()
        let payload = storage.applyLevelResult(
            game: .pathTracer,
            level: levelIndex,
            starsEarned: stars,
            score: score,
            tier: tier
        )
        resultPayload = payload
    }

    private func startLoop() {
        tick?.cancel()
        tick = Timer.publish(every: 1.0 / 60.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.step()
            }
    }

    private static func startingLives(tier: ChallengeTier) -> Int {
        switch tier {
        case .easy: return 3
        case .normal: return 2
        case .hard: return 1
        }
    }

    private static func distanceThreshold(tier: ChallengeTier) -> CGFloat {
        switch tier {
        case .easy: return 0.07
        case .normal: return 0.052
        case .hard: return 0.034
        }
    }

    private static func timeLimit(for level: Int) -> CGFloat {
        max(10, 20 - CGFloat(level) * 0.6)
    }

    private static func starRating(accuracyAverage: CGFloat) -> Int {
        if accuracyAverage >= 0.9 {
            return 3
        }
        if accuracyAverage >= 0.78 {
            return 2
        }
        if accuracyAverage >= 0.62 {
            return 1
        }
        return 0
    }
}
