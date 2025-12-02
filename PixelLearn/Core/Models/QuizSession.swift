import Foundation

struct QuizSession: Identifiable {
    let id: UUID
    let subject: Subject
    let startLevel: Int
    var currentLevel: Int
    var questionsAnswered: [AnsweredQuestion]
    let startedAt: Date
    var endedAt: Date?

    init(
        id: UUID = UUID(),
        subject: Subject,
        startLevel: Int,
        startedAt: Date = Date()
    ) {
        self.id = id
        self.subject = subject
        self.startLevel = startLevel
        self.currentLevel = startLevel
        self.questionsAnswered = []
        self.startedAt = startedAt
    }

    var correctCount: Int {
        questionsAnswered.filter { $0.isCorrect }.count
    }

    var incorrectCount: Int {
        questionsAnswered.filter { !$0.isCorrect }.count
    }

    var totalQuestions: Int {
        questionsAnswered.count
    }

    var accuracy: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(correctCount) / Double(totalQuestions)
    }

    var levelChange: Int {
        currentLevel - startLevel
    }

    var isActive: Bool {
        endedAt == nil
    }

    mutating func recordAnswer(_ answer: AnsweredQuestion) {
        questionsAnswered.append(answer)
    }

    mutating func updateLevel(_ newLevel: Int) {
        currentLevel = max(1, min(65, newLevel))
    }

    mutating func endSession() {
        endedAt = Date()
    }
}

struct AnsweredQuestion: Identifiable {
    let id: UUID
    let question: Question
    let selectedIndex: Int
    let isCorrect: Bool
    let answeredAt: Date
    let responseTimeMs: Int

    init(
        id: UUID = UUID(),
        question: Question,
        selectedIndex: Int,
        answeredAt: Date = Date(),
        responseTimeMs: Int
    ) {
        self.id = id
        self.question = question
        self.selectedIndex = selectedIndex
        self.isCorrect = question.isCorrect(selectedIndex)
        self.answeredAt = answeredAt
        self.responseTimeMs = responseTimeMs
    }
}
