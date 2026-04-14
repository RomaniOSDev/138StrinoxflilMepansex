import Foundation

enum GameKind: String, CaseIterable, Codable, Hashable {
    case precisionDrop
    case pathTracer
    case stackRush

    var displayTitle: String {
        switch self {
        case .precisionDrop: return "Precision Drop"
        case .pathTracer: return "Path Tracer"
        case .stackRush: return "Stack Rush"
        }
    }

    var subtitle: String {
        switch self {
        case .precisionDrop: return "Drop on the moving zone. Timing is everything."
        case .pathTracer: return "Follow the glowing trail with steady focus."
        case .stackRush: return "Stop the block and build the tallest stack."
        }
    }
}

enum ChallengeTier: String, CaseIterable, Codable, Hashable {
    case easy
    case normal
    case hard

    var label: String {
        switch self {
        case .easy: return "Easy"
        case .normal: return "Normal"
        case .hard: return "Hard"
        }
    }
}

enum GameConstants {
    /// Stages per activity (grid on the stage picker).
    static let levelsPerGame = 24
}

enum AchievementID: String, CaseIterable, Identifiable {
    case firstWin
    case starGatherer
    case longHaul
    case dropVirtuoso
    case tracerBold
    case stackSurge
    case balancedGlory
    case fullConstellation

    var id: String { rawValue }

    var title: String {
        switch self {
        case .firstWin: return "First Win"
        case .starGatherer: return "Star Gatherer"
        case .longHaul: return "Long Haul"
        case .dropVirtuoso: return "Drop Virtuoso"
        case .tracerBold: return "Bold Tracer"
        case .stackSurge: return "Stack Surge"
        case .balancedGlory: return "Balanced Glory"
        case .fullConstellation: return "Full Constellation"
        }
    }

    var detail: String {
        switch self {
        case .firstWin: return "Finish any level once."
        case .starGatherer: return "Collect 40 total stars."
        case .longHaul: return "Play for 3 hours in total."
        case .dropVirtuoso: return "Earn 3 stars on the final Precision Drop stage."
        case .tracerBold: return "Clear any Path Tracer level on Hard."
        case .stackSurge: return "Reach a 5 combo in Stack Rush."
        case .balancedGlory: return "Earn at least 10 stars in each activity."
        case .fullConstellation: return "Earn 3 stars on every level in one activity."
        }
    }

    func isUnlocked(using storage: GameStorage) -> Bool {
        switch self {
        case .firstWin:
            return storage.totalGamesPlayed >= 1
        case .starGatherer:
            return storage.totalStarsEarned >= 40
        case .longHaul:
            return storage.totalPlayTimeSeconds >= 10_800
        case .dropVirtuoso:
            return storage.stars(for: .precisionDrop, level: GameConstants.levelsPerGame - 1) >= 3
        case .tracerBold:
            return storage.pathTracerHardClears >= 1
        case .stackSurge:
            return storage.stackRushMaxCombo >= 5
        case .balancedGlory:
            let games = GameKind.allCases
            return games.allSatisfy { storage.totalStars(for: $0) >= 10 }
        case .fullConstellation:
            return GameKind.allCases.contains { storage.hasPerfectClear(for: $0) }
        }
    }
}

struct LevelResultPayload: Equatable {
    let stars: Int
    let score: Int
    let isWin: Bool
    let newlyUnlockedAchievement: AchievementID?
}
