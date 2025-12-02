import Foundation

struct Question: Codable, Identifiable, Hashable {
    let id: UUID
    let subject: Subject
    let level: Int
    let text: String
    let options: [String]
    let correctIndex: Int
    let explanation: String?

    init(
        id: UUID = UUID(),
        subject: Subject,
        level: Int,
        text: String,
        options: [String],
        correctIndex: Int,
        explanation: String? = nil
    ) {
        self.id = id
        self.subject = subject
        self.level = level
        self.text = text
        self.options = options
        self.correctIndex = correctIndex
        self.explanation = explanation
    }

    var correctAnswer: String {
        options[correctIndex]
    }

    func isCorrect(_ answerIndex: Int) -> Bool {
        answerIndex == correctIndex
    }
}
