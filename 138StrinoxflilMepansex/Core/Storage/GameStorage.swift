import Combine
import Foundation

final class GameStorage: ObservableObject {
    static let shared = GameStorage()

    private let defaults = UserDefaults.standard

    private enum Key {
        static let hasSeenOnboarding = "gsm.hasSeenOnboarding"
        static let starsPerLevel = "gsm.starsPerLevel"
        static let unlockedLevels = "gsm.unlockedLevels"
        static let totalGamesPlayed = "gsm.totalGamesPlayed"
        static let totalStarsEarned = "gsm.totalStarsEarned"
        static let bestLevelPerGame = "gsm.bestLevelPerGame"
        static let totalPlayTimeSeconds = "gsm.totalPlayTimeSeconds"
        static let pathTracerHardClears = "gsm.pathTracerHardClears"
        static let stackRushMaxCombo = "gsm.stackRushMaxCombo"
    }

    private static let resetKeys: [String] = [
        Key.hasSeenOnboarding,
        Key.starsPerLevel,
        Key.unlockedLevels,
        Key.totalGamesPlayed,
        Key.totalStarsEarned,
        Key.bestLevelPerGame,
        Key.totalPlayTimeSeconds,
        Key.pathTracerHardClears,
        Key.stackRushMaxCombo
    ]

    @Published private(set) var hasSeenOnboarding: Bool
    @Published private(set) var totalGamesPlayed: Int
    @Published private(set) var totalStarsEarned: Int
    @Published private(set) var totalPlayTimeSeconds: Int
    @Published private(set) var pathTracerHardClears: Int
    @Published private(set) var stackRushMaxCombo: Int

    private var starsPerLevelMap: [String: [Int]]
    private var unlockedLevelsMap: [String: Int]
    private var bestLevelMap: [String: Int]

    private init() {
        hasSeenOnboarding = defaults.bool(forKey: Key.hasSeenOnboarding)
        totalGamesPlayed = defaults.integer(forKey: Key.totalGamesPlayed)
        totalStarsEarned = defaults.integer(forKey: Key.totalStarsEarned)
        totalPlayTimeSeconds = defaults.integer(forKey: Key.totalPlayTimeSeconds)
        pathTracerHardClears = defaults.integer(forKey: Key.pathTracerHardClears)
        stackRushMaxCombo = defaults.integer(forKey: Key.stackRushMaxCombo)

        starsPerLevelMap = Self.decodeMapArray(defaults.string(forKey: Key.starsPerLevel))
        unlockedLevelsMap = Self.decodeMapInt(defaults.string(forKey: Key.unlockedLevels))
        bestLevelMap = Self.decodeMapInt(defaults.string(forKey: Key.bestLevelPerGame))

        Self.ensureBootstrapMaps(
            stars: &starsPerLevelMap,
            unlocked: &unlockedLevelsMap,
            best: &bestLevelMap
        )
        persistMaps()
    }

    private static func ensureBootstrapMaps(
        stars: inout [String: [Int]],
        unlocked: inout [String: Int],
        best: inout [String: Int]
    ) {
        let count = GameConstants.levelsPerGame
        for game in GameKind.allCases {
            let id = game.rawValue
            if stars[id] == nil {
                stars[id] = Array(repeating: 0, count: count)
            } else if let row = stars[id], row.count < count {
                var padded = row
                padded.append(contentsOf: Array(repeating: 0, count: count - row.count))
                stars[id] = padded
            }
            if unlocked[id] == nil {
                unlocked[id] = 0
            }
            if best[id] == nil {
                best[id] = -1
            }
        }
    }

    private static func decodeMapArray(_ json: String?) -> [String: [Int]] {
        guard let data = json?.data(using: .utf8),
              let decoded = try? JSONDecoder().decode([String: [Int]].self, from: data) else {
            return [:]
        }
        return decoded
    }

    private static func decodeMapInt(_ json: String?) -> [String: Int] {
        guard let data = json?.data(using: .utf8),
              let decoded = try? JSONDecoder().decode([String: Int].self, from: data) else {
            return [:]
        }
        return decoded
    }

    private func persistMaps() {
        if let data = try? JSONEncoder().encode(starsPerLevelMap),
           let string = String(data: data, encoding: .utf8) {
            defaults.set(string, forKey: Key.starsPerLevel)
        }
        if let data = try? JSONEncoder().encode(unlockedLevelsMap),
           let string = String(data: data, encoding: .utf8) {
            defaults.set(string, forKey: Key.unlockedLevels)
        }
        if let data = try? JSONEncoder().encode(bestLevelMap),
           let string = String(data: data, encoding: .utf8) {
            defaults.set(string, forKey: Key.bestLevelPerGame)
        }
    }

    func markOnboardingSeen() {
        hasSeenOnboarding = true
        defaults.set(true, forKey: Key.hasSeenOnboarding)
    }

    func stars(for game: GameKind, level: Int) -> Int {
        guard let row = starsPerLevelMap[game.rawValue], level >= 0, level < row.count else {
            return 0
        }
        return row[level]
    }

    func totalStars(for game: GameKind) -> Int {
        starsPerLevelMap[game.rawValue]?.reduce(0, +) ?? 0
    }

    func isLevelUnlocked(game: GameKind, level: Int) -> Bool {
        guard level >= 0, level < GameConstants.levelsPerGame else { return false }
        let maxUnlocked = unlockedLevelsMap[game.rawValue] ?? 0
        return level <= maxUnlocked
    }

    func bestLevelIndex(for game: GameKind) -> Int {
        bestLevelMap[game.rawValue] ?? -1
    }

    func hasPerfectClear(for game: GameKind) -> Bool {
        guard let row = starsPerLevelMap[game.rawValue] else { return false }
        return row.allSatisfy { $0 >= 3 }
    }

    func recordSessionDuration(_ seconds: TimeInterval) {
        let delta = max(0, Int(seconds.rounded()))
        guard delta > 0 else { return }
        totalPlayTimeSeconds += delta
        defaults.set(totalPlayTimeSeconds, forKey: Key.totalPlayTimeSeconds)
    }

    func registerPathTracerHardClear() {
        pathTracerHardClears += 1
        defaults.set(pathTracerHardClears, forKey: Key.pathTracerHardClears)
    }

    func registerStackRushCombo(_ value: Int) {
        guard value > stackRushMaxCombo else { return }
        stackRushMaxCombo = value
        defaults.set(stackRushMaxCombo, forKey: Key.stackRushMaxCombo)
    }

    func applyLevelResult(
        game: GameKind,
        level: Int,
        starsEarned: Int,
        score: Int,
        tier: ChallengeTier,
        stackRushComboPeak: Int = 0
    ) -> LevelResultPayload {
        let previousUnlocked = Set(AchievementID.allCases.filter { $0.isUnlocked(using: self) })

        totalGamesPlayed += 1
        defaults.set(totalGamesPlayed, forKey: Key.totalGamesPlayed)

        if stackRushComboPeak > 0 {
            registerStackRushCombo(stackRushComboPeak)
        }

        let clampedStars = max(0, min(3, starsEarned))
        var row = starsPerLevelMap[game.rawValue] ?? Array(repeating: 0, count: GameConstants.levelsPerGame)
        if level >= 0, level < row.count {
            if clampedStars > row[level] {
                let delta = clampedStars - row[level]
                totalStarsEarned += delta
                defaults.set(totalStarsEarned, forKey: Key.totalStarsEarned)
                row[level] = clampedStars
                starsPerLevelMap[game.rawValue] = row
            }
        }

        if clampedStars > 0 {
            let currentBest = bestLevelMap[game.rawValue] ?? -1
            if level > currentBest {
                bestLevelMap[game.rawValue] = level
            }

            let maxUnlocked = unlockedLevelsMap[game.rawValue] ?? 0
            if level == maxUnlocked, level + 1 < GameConstants.levelsPerGame {
                unlockedLevelsMap[game.rawValue] = maxUnlocked + 1
            }
        }

        if game == .pathTracer, tier == .hard, clampedStars > 0 {
            registerPathTracerHardClear()
        }

        persistMaps()

        let newly = AchievementID.allCases.first { achievement in
            achievement.isUnlocked(using: self) && !previousUnlocked.contains(achievement)
        }

        objectWillChange.send()

        return LevelResultPayload(
            stars: clampedStars,
            score: score,
            isWin: clampedStars > 0,
            newlyUnlockedAchievement: newly
        )
    }

    func resetAllProgress() {
        for key in Self.resetKeys {
            defaults.removeObject(forKey: key)
        }

        hasSeenOnboarding = false
        totalGamesPlayed = 0
        totalStarsEarned = 0
        totalPlayTimeSeconds = 0
        pathTracerHardClears = 0
        stackRushMaxCombo = 0
        starsPerLevelMap = [:]
        unlockedLevelsMap = [:]
        bestLevelMap = [:]
        Self.ensureBootstrapMaps(
            stars: &starsPerLevelMap,
            unlocked: &unlockedLevelsMap,
            best: &bestLevelMap
        )
        persistMaps()
        defaults.set(false, forKey: Key.hasSeenOnboarding)

        objectWillChange.send()
        NotificationCenter.default.post(name: .gameStorageDidReset, object: nil)
    }
}
