import SwiftUI
import SwiftData

struct QuizView: View {
    let subject: Subject

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @StateObject private var quizEngine = QuizEngine()

    @State private var selectedAnswer: Int?
    @State private var questionStartTime: Date = Date()

    private var userProfile: UserProfile? { profiles.first }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [subject.gradientColors[0].opacity(0.2), subject.gradientColors[1].opacity(0.2)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                progressHeader

                if quizEngine.isLoading {
                    loadingView
                } else if let error = quizEngine.loadError {
                    errorView(error)
                } else if let question = quizEngine.currentQuestion {
                    questionContent(question)
                }
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    endSession()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
            }
        }
        .task {
            let startLevel = userProfile?.adventureLevel(for: subject) ?? 1
            await quizEngine.startSession(subject: subject, startingLevel: startLevel)
            questionStartTime = Date()
        }
        .overlay {
            if quizEngine.showingResult, let result = quizEngine.lastResult {
                resultOverlay(result)
            }
        }
    }

    private var progressHeader: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Level \(quizEngine.progress.currentLevel)")
                        .font(.headline)
                        .foregroundColor(.primary)

                    if quizEngine.progress.streak > 0 {
                        Text("\(quizEngine.progress.streak) in a row!")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }

                Spacer()

                Text("\(quizEngine.progress.questionsAnswered) answered")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 16) {
                Label("\(quizEngine.progress.correctCount)", systemImage: "checkmark.circle.fill")
                    .foregroundColor(.green)

                Label("\(quizEngine.progress.questionsAnswered - quizEngine.progress.correctCount)", systemImage: "xmark.circle.fill")
                    .foregroundColor(.red)
            }
            .font(.subheadline)
        }
        .padding()
        .background(.ultraThinMaterial)
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)

            Text("Loading question...")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(.orange)

            Text(message)
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Button {
                Task {
                    let level = quizEngine.progress.currentLevel
                    await quizEngine.loadQuestion(for: subject, at: level)
                }
            } label: {
                Text("Try Again")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(subject.gradientColors[0])
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func questionContent(_ question: Question) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                Text(question.text)
                    .font(.title3)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                VStack(spacing: 12) {
                    ForEach(Array(question.options.enumerated()), id: \.offset) { index, option in
                        AnswerButton(
                            text: option,
                            isSelected: selectedAnswer == index,
                            state: answerState(for: index)
                        ) {
                            if !quizEngine.showingResult {
                                selectAnswer(index)
                            }
                        }
                    }
                }

                if selectedAnswer != nil && !quizEngine.showingResult {
                    Button {
                        Task {
                            await submitAnswer()
                        }
                    } label: {
                        Text("Submit")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: subject.gradientColors,
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }

                Spacer(minLength: 100)
            }
            .padding()
        }
    }

    private func answerState(for index: Int) -> AnswerButton.State {
        guard quizEngine.showingResult, let result = quizEngine.lastResult else {
            return .normal
        }

        if quizEngine.currentQuestion?.correctIndex == index {
            return .correct
        } else if selectedAnswer == index && !result.isCorrect {
            return .incorrect
        }

        return .normal
    }

    private func resultOverlay(_ result: QuizEngine.AnswerResult) -> some View {
        VStack(spacing: 20) {
            Spacer()

            VStack(spacing: 16) {
                Image(systemName: result.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(result.isCorrect ? .green : .red)

                Text(result.isCorrect ? "Correct!" : "Incorrect")
                    .font(.title)
                    .fontWeight(.bold)

                if let message = result.levelChange.message {
                    Text(message)
                        .font(.subheadline)
                        .foregroundColor(result.levelChange.didLevelChange ? .blue : .secondary)
                }

                if !result.isCorrect, let explanation = result.explanation {
                    VStack(spacing: 8) {
                        Text("Correct answer: \(result.correctAnswer)")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        Text(explanation)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                Button {
                    Task {
                        selectedAnswer = nil
                        await quizEngine.continueAfterResult()
                        questionStartTime = Date()
                    }
                } label: {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: subject.gradientColors,
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(24)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .padding()
        }
        .background(Color.black.opacity(0.3))
        .ignoresSafeArea()
    }

    private func selectAnswer(_ index: Int) {
        selectedAnswer = index
    }

    private func submitAnswer() async {
        guard let selectedAnswer = selectedAnswer else { return }

        let responseTime = Int(Date().timeIntervalSince(questionStartTime) * 1000)
        let result = await quizEngine.submitAnswer(
            selectedIndex: selectedAnswer,
            responseTimeMs: responseTime
        )

        if result.isCorrect {
            userProfile?.totalCorrectAnswers += 1
        }
        userProfile?.totalQuestionsAnswered += 1
    }

    private func endSession() {
        if let session = quizEngine.endSession() {
            userProfile?.setAdventureLevel(session.currentLevel, for: subject)
            userProfile?.lastPlayedAt = Date()
        }
        dismiss()
    }
}

struct AnswerButton: View {
    enum State {
        case normal, correct, incorrect
    }

    let text: String
    let isSelected: Bool
    let state: State
    let action: () -> Void

    private var backgroundColor: Color {
        switch state {
        case .correct: return .green.opacity(0.3)
        case .incorrect: return .red.opacity(0.3)
        case .normal: return isSelected ? .blue.opacity(0.2) : .clear
        }
    }

    private var borderColor: Color {
        switch state {
        case .correct: return .green
        case .incorrect: return .red
        case .normal: return isSelected ? .blue : .gray.opacity(0.3)
        }
    }

    var body: some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .font(.body)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)

                Spacer()

                if state == .correct {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else if state == .incorrect {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                }
            }
            .padding()
            .background(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: isSelected || state != .normal ? 2 : 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        QuizView(subject: .math)
    }
    .modelContainer(for: UserProfile.self, inMemory: true)
}
