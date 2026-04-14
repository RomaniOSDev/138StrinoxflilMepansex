import Combine
import Foundation

final class StackRushViewModel: ObservableObject {
    struct Layer: Equatable {
        let width: CGFloat
        let center: CGFloat
    }

    @Published private(set) var slidePosition: CGFloat = 0.5
    @Published private(set) var direction: CGFloat = 1
    @Published private(set) var stack: [Layer] = []
    @Published private(set) var currentWidth: CGFloat = 0.55
    @Published private(set) var score: Int = 0
    @Published private(set) var combo: Int = 0
    @Published private(set) var comboPeak: Int = 0
    @Published private(set) var resultPayload: LevelResultPayload?

    /// True while the slab is falling — horizontal motion is paused.
    @Published private(set) var isDropping: Bool = false

    @Published var levelIndex: Int

    let tier: ChallengeTier

    private let storage: GameStorage
    private var tick: AnyCancellable?
    private var placements: Int = 0
    private var overlaps: [CGFloat] = []
    private var shrink: CGFloat = 1.0

    private var frozenDropX: CGFloat = 0.5

    private var requiredPlacements: Int {
        5 + min(4, levelIndex / 2)
    }

    init(level: Int, tier: ChallengeTier, storage: GameStorage) {
        self.levelIndex = level
        self.tier = tier
        self.storage = storage
        resetBoard()
        startLoop()
    }

    deinit {
        tick?.cancel()
    }

    func restartLevel() {
        resultPayload = nil
        isDropping = false
        resetBoard()
        startLoop()
    }

    func advanceToNextLevel() {
        guard levelIndex + 1 < GameConstants.levelsPerGame else { return }
        let next = levelIndex + 1
        guard storage.isLevelUnlocked(game: .stackRush, level: next) else { return }
        levelIndex = next
        restartLevel()
    }

    /// Call when the user taps: start drop from current horizontal position (timer pauses).
    func beginDrop() {
        guard resultPayload == nil else { return }
        guard !isDropping else { return }
        guard stack.last != nil else { return }

        frozenDropX = slidePosition
        isDropping = true
        tick?.cancel()
    }

    /// Call after the fall animation finishes — applies overlap rules and prepares the next slab at the top.
    func finalizeDropAfterAnimation() {
        guard isDropping else { return }
        isDropping = false

        let x = frozenDropX
        guard let previous = stack.last else { return }

        let curLeft = x - currentWidth / 2
        let curRight = x + currentWidth / 2
        let prevLeft = previous.center - previous.width / 2
        let prevRight = previous.center + previous.width / 2

        let overlapLeft = max(curLeft, prevLeft)
        let overlapRight = min(curRight, prevRight)
        let overlap = overlapRight - overlapLeft

        if overlap <= 0.02 {
            finishRun(stars: 0, score: score, comboPeak: comboPeak)
            return
        }

        let overlapRatio = overlap / min(currentWidth, previous.width)
        overlaps.append(overlapRatio)

        let newWidth = overlap
        let newCenter = overlapLeft + overlap / 2

        stack.append(Layer(width: newWidth, center: newCenter))

        if overlapRatio > 0.82 {
            combo += 1
        } else {
            combo = 0
        }
        comboPeak = max(comboPeak, combo)

        score += Int(overlapRatio * 420) + combo * 45

        placements += 1

        if placements >= requiredPlacements {
            let avg = overlaps.reduce(0, +) / CGFloat(overlaps.count)
            let stars = Self.starRating(overlapAverage: avg)
            finishRun(stars: stars, score: score, comboPeak: comboPeak)
            return
        }

        shrink = tier == .hard ? max(0.58, 0.95 - CGFloat(levelIndex) * 0.035) : 1.0
        currentWidth = max(0.08, newWidth * shrink)

        let half = currentWidth / 2
        slidePosition = min(max(newCenter, half + 0.03), 1 - half - 0.03)
        direction *= -1

        startLoop()
    }

    private func resetBoard() {
        tick?.cancel()
        shrink = tier == .hard ? max(0.58, 0.95 - CGFloat(levelIndex) * 0.035) : 1.0
        stack = [Layer(width: 0.78, center: 0.5)]
        currentWidth = max(0.12, 0.78 * shrink * 0.92)
        slidePosition = 0.5
        direction = 1
        score = 0
        combo = 0
        comboPeak = 0
        placements = 0
        overlaps = []
        isDropping = false
    }

    private func step() {
        guard resultPayload == nil else { return }
        guard !isDropping else { return }
        let speed = Self.speed(tier: tier, level: levelIndex)
        slidePosition += direction * speed
        let half = currentWidth / 2
        if slidePosition + half > 0.97 {
            direction = -1
        }
        if slidePosition - half < 0.03 {
            direction = 1
        }
    }

    private func finishRun(stars: Int, score: Int, comboPeak: Int) {
        guard resultPayload == nil else { return }
        tick?.cancel()
        isDropping = false
        let payload = storage.applyLevelResult(
            game: .stackRush,
            level: levelIndex,
            starsEarned: stars,
            score: score,
            tier: tier,
            stackRushComboPeak: comboPeak
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

    private static func speed(tier: ChallengeTier, level: Int) -> CGFloat {
        let base: CGFloat
        switch tier {
        case .easy: base = 0.006
        case .normal: base = 0.009
        case .hard: base = 0.013
        }
        return base + CGFloat(level) * 0.0005
    }

    private static func starRating(overlapAverage: CGFloat) -> Int {
        if overlapAverage >= 0.9 {
            return 3
        }
        if overlapAverage >= 0.78 {
            return 2
        }
        if overlapAverage >= 0.62 {
            return 1
        }
        return 0
    }
}
