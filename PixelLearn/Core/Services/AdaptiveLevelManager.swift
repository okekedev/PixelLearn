import Foundation

class AdaptiveLevelManager: ObservableObject {
    @Published private(set) var currentLevel: Int
    @Published private(set) var consecutiveCorrect: Int = 0

    let subject: Subject
    let minLevel: Int = 1
    let maxLevel: Int = 65
    let correctToLevelUp: Int = 2

    init(subject: Subject, startingLevel: Int) {
        self.subject = subject
        self.currentLevel = max(minLevel, min(maxLevel, startingLevel))
    }

    @discardableResult
    func recordAnswer(correct: Bool) -> LevelChangeResult {
        if correct {
            consecutiveCorrect += 1

            if consecutiveCorrect >= correctToLevelUp {
                return levelUp()
            }

            return .noChange(level: currentLevel, streak: consecutiveCorrect)
        } else {
            consecutiveCorrect = 0
            return levelDown()
        }
    }

    private func levelUp() -> LevelChangeResult {
        consecutiveCorrect = 0

        if currentLevel < maxLevel {
            let previousLevel = currentLevel
            currentLevel += 1
            return .leveledUp(from: previousLevel, to: currentLevel)
        }

        return .atMaxLevel(level: maxLevel)
    }

    private func levelDown() -> LevelChangeResult {
        if currentLevel > minLevel {
            let previousLevel = currentLevel
            currentLevel -= 1
            return .leveledDown(from: previousLevel, to: currentLevel)
        }

        return .atMinLevel(level: minLevel)
    }

    func reset(to level: Int) {
        currentLevel = max(minLevel, min(maxLevel, level))
        consecutiveCorrect = 0
    }
}

enum LevelChangeResult {
    case noChange(level: Int, streak: Int)
    case leveledUp(from: Int, to: Int)
    case leveledDown(from: Int, to: Int)
    case atMaxLevel(level: Int)
    case atMinLevel(level: Int)

    var currentLevel: Int {
        switch self {
        case .noChange(let level, _): return level
        case .leveledUp(_, let to): return to
        case .leveledDown(_, let to): return to
        case .atMaxLevel(let level): return level
        case .atMinLevel(let level): return level
        }
    }

    var didLevelChange: Bool {
        switch self {
        case .leveledUp, .leveledDown: return true
        default: return false
        }
    }

    var message: String? {
        switch self {
        case .leveledUp(_, let to):
            return "Level Up! Now at Level \(to)"
        case .leveledDown(_, let to):
            return "Level Down. Now at Level \(to)"
        case .atMaxLevel:
            return "Maximum Level Reached!"
        case .atMinLevel:
            return nil
        case .noChange(_, let streak):
            if streak > 0 {
                return "\(streak) in a row!"
            }
            return nil
        }
    }
}
