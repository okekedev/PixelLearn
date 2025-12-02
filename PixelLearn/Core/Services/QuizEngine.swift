import Foundation
import SwiftUI

@MainActor
class QuizEngine: ObservableObject {
    @Published var currentQuestion: Question?
    @Published var session: QuizSession?
    @Published var levelManager: AdaptiveLevelManager?
    @Published var isLoading = false
    @Published var lastResult: AnswerResult?
    @Published var showingResult = false
    @Published var loadError: String?

    private let questionBank = QuestionBankService.shared

    struct AnswerResult {
        let isCorrect: Bool
        let levelChange: LevelChangeResult
        let explanation: String?
        let correctAnswer: String
    }

    func startSession(subject: Subject, startingLevel: Int) async {
        isLoading = true
        levelManager = AdaptiveLevelManager(subject: subject, startingLevel: startingLevel)
        session = QuizSession(subject: subject, startLevel: startingLevel)
        await loadNextQuestion()
        isLoading = false
    }

    func loadNextQuestion() async {
        guard let levelManager = levelManager else { return }

        isLoading = true
        loadError = nil
        let question = await questionBank.getRandomQuestion(
            for: levelManager.subject,
            level: levelManager.currentLevel
        )
        currentQuestion = question
        if question == nil {
            loadError = "Unable to load question. Please try again."
        }
        isLoading = false
    }

    func loadQuestion(for subject: Subject, at level: Int) async {
        isLoading = true
        loadError = nil
        let question = await questionBank.getRandomQuestion(
            for: subject,
            level: level
        )
        currentQuestion = question
        if question == nil {
            loadError = "Unable to load question. Please try again."
        }
        isLoading = false
    }

    func submitAnswer(selectedIndex: Int, responseTimeMs: Int) async -> AnswerResult {
        guard let question = currentQuestion,
              let levelManager = levelManager,
              var session = session else {
            return AnswerResult(
                isCorrect: false,
                levelChange: .noChange(level: 1, streak: 0),
                explanation: nil,
                correctAnswer: ""
            )
        }

        let isCorrect = question.isCorrect(selectedIndex)

        let answeredQuestion = AnsweredQuestion(
            question: question,
            selectedIndex: selectedIndex,
            responseTimeMs: responseTimeMs
        )
        session.recordAnswer(answeredQuestion)

        let levelChange = levelManager.recordAnswer(correct: isCorrect)
        session.updateLevel(levelChange.currentLevel)

        self.session = session

        let result = AnswerResult(
            isCorrect: isCorrect,
            levelChange: levelChange,
            explanation: question.explanation,
            correctAnswer: question.correctAnswer
        )

        lastResult = result
        showingResult = true

        return result
    }

    func continueAfterResult() async {
        showingResult = false
        lastResult = nil
        await loadNextQuestion()
    }

    func endSession() -> QuizSession? {
        guard var session = session else { return nil }
        session.endSession()
        let finalSession = session

        self.session = nil
        self.currentQuestion = nil
        self.levelManager = nil
        self.lastResult = nil
        self.showingResult = false

        return finalSession
    }

    var progress: QuizProgress {
        guard let session = session else {
            return QuizProgress(
                questionsAnswered: 0,
                correctCount: 0,
                currentLevel: 1,
                startLevel: 1,
                streak: 0
            )
        }

        return QuizProgress(
            questionsAnswered: session.totalQuestions,
            correctCount: session.correctCount,
            currentLevel: levelManager?.currentLevel ?? session.currentLevel,
            startLevel: session.startLevel,
            streak: levelManager?.consecutiveCorrect ?? 0
        )
    }
}

struct QuizProgress {
    let questionsAnswered: Int
    let correctCount: Int
    let currentLevel: Int
    let startLevel: Int
    let streak: Int

    var accuracy: Double {
        guard questionsAnswered > 0 else { return 0 }
        return Double(correctCount) / Double(questionsAnswered)
    }

    var levelChange: Int {
        currentLevel - startLevel
    }
}
