import Foundation
import SwiftData

@Model
final class UserProfile {
    var id: UUID
    var profileName: String?
    var adventureLevelGrammar: Int
    var adventureLevelMemory: Int
    var adventureLevelMath: Int
    var totalCorrectAnswers: Int
    var totalQuestionsAnswered: Int
    var storedTotalWins: Int?
    var createdAt: Date
    var lastPlayedAt: Date
    var avatarName: String?
    var active: Bool?

    init(
        id: UUID = UUID(),
        profileName: String? = "Player",
        adventureLevelGrammar: Int = 1,
        adventureLevelMemory: Int = 1,
        adventureLevelMath: Int = 1,
        totalCorrectAnswers: Int = 0,
        totalQuestionsAnswered: Int = 0,
        storedTotalWins: Int? = 0,
        createdAt: Date = Date(),
        lastPlayedAt: Date = Date(),
        avatarName: String? = "person.fill",
        active: Bool? = true
    ) {
        self.id = id
        self.profileName = profileName
        self.adventureLevelGrammar = adventureLevelGrammar
        self.adventureLevelMemory = adventureLevelMemory
        self.adventureLevelMath = adventureLevelMath
        self.totalCorrectAnswers = totalCorrectAnswers
        self.totalQuestionsAnswered = totalQuestionsAnswered
        self.storedTotalWins = storedTotalWins
        self.createdAt = createdAt
        self.lastPlayedAt = lastPlayedAt
        self.avatarName = avatarName
        self.active = active
    }

    var name: String {
        get { profileName ?? "Player" }
        set { profileName = newValue }
    }

    var isActive: Bool {
        get { active ?? true }
        set { active = newValue }
    }

    var totalWins: Int {
        get { storedTotalWins ?? 0 }
        set { storedTotalWins = newValue }
    }

    var displayAvatarName: String {
        avatarName ?? "person.fill"
    }

    func adventureLevel(for subject: Subject) -> Int {
        switch subject {
        case .grammar: return adventureLevelGrammar
        case .memory: return adventureLevelMemory
        case .math: return adventureLevelMath
        }
    }

    func setAdventureLevel(_ level: Int, for subject: Subject) {
        let clampedLevel = max(Design.Game.minLevel, min(Design.Game.maxLevel, level))
        switch subject {
        case .grammar: adventureLevelGrammar = clampedLevel
        case .memory: adventureLevelMemory = clampedLevel
        case .math: adventureLevelMath = clampedLevel
        }
    }

    var overallAdventureLevel: Int {
        (adventureLevelGrammar + adventureLevelMemory + adventureLevelMath) / 3
    }

    var accuracy: Double {
        guard totalQuestionsAnswered > 0 else { return 0 }
        return Double(totalCorrectAnswers) / Double(totalQuestionsAnswered)
    }

    var highestLevelSubject: Subject {
        let levels = [
            (Subject.grammar, adventureLevelGrammar),
            (Subject.memory, adventureLevelMemory),
            (Subject.math, adventureLevelMath)
        ]
        return levels.max(by: { $0.1 < $1.1 })?.0 ?? .math
    }

    var highestLevel: Int {
        max(adventureLevelGrammar, adventureLevelMemory, adventureLevelMath)
    }

    static let availableAvatars: [String] = [
        "person.fill", "person.crop.circle.fill", "figure.stand", "figure.wave",
        "star.fill", "heart.fill", "bolt.fill", "flame.fill",
        "leaf.fill", "crown.fill", "moon.fill", "sun.max.fill",
        "cloud.fill", "snowflake", "sparkles", "wand.and.stars",
        "graduationcap.fill", "brain.head.profile", "book.fill", "pencil",
        "paintbrush.fill", "paintpalette.fill", "guitars.fill", "pianokeys",
        "football.fill", "basketball.fill", "tennisball.fill", "soccerball",
        "globe.americas.fill", "airplane", "car.fill", "bicycle",
        "hare.fill", "tortoise.fill", "bird.fill", "fish.fill",
        "pawprint.fill", "ant.fill", "ladybug.fill", "leaf.arrow.triangle.circlepath"
    ]
}
