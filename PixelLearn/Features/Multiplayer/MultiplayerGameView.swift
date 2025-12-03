import SwiftUI
import SwiftData

struct MultiplayerGameView: View {
    let players: [PlayerConfig]
    let subject: Subject

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @StateObject private var quizEngine = QuizEngine()

    @State private var currentPlayerIndex = 0
    @State private var scores: [Int]
    @State private var streaks: [Int]
    @State private var levels: [Int]
    @State private var questionNumber = 0
    @State private var selectedAnswer: Int?
    @State private var showingResult = false
    @State private var showingPassDevice = false
    @State private var showingFinalResult = false
    @State private var showingPodium = false
    @State private var timeRemaining = 10
    @State private var timerActive = false
    @State private var passCountdown = 3
    @State private var passTimer: Timer?

    private let totalQuestions = 10
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var currentPlayer: PlayerConfig { players[currentPlayerIndex] }

    init(players: [PlayerConfig], subject: Subject) {
        self.players = players
        self.subject = subject
        _scores = State(initialValue: Array(repeating: 0, count: players.count))
        _streaks = State(initialValue: Array(repeating: 0, count: players.count))
        _levels = State(initialValue: players.map { $0.level })
    }

    var body: some View {
        ZStack {
            GradientBackground(colors: [currentPlayer.color, currentPlayer.color])
                .animation(.easeInOut, value: currentPlayerIndex)

            VStack(spacing: 0) {
                scoreBoard

                progressIndicator

                timerView

                if showingPodium {
                    podiumOverlay
                } else if showingFinalResult {
                    finalResultView
                } else if showingPassDevice {
                    passDeviceView
                } else if let question = quizEngine.currentQuestion {
                    questionView(question)
                } else {
                    loadingView
                }
            }
        }
        .onReceive(timer) { _ in
            guard timerActive && !showingResult && !showingPassDevice && !showingFinalResult else { return }
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                handleTimeout()
            }
        }
        .onAppear {
            Task {
                await quizEngine.loadQuestion(for: subject, at: levels[currentPlayerIndex])
                timerActive = true
            }
        }
        .onDisappear {
            passTimer?.invalidate()
            passTimer = nil
        }
    }

    private var scoreBoard: some View {
        HStack(spacing: 4) {
            ForEach(Array(players.enumerated()), id: \.offset) { index, player in
                VStack(spacing: 2) {
                    Text(player.name)
                        .font(.caption2)
                        .lineLimit(1)
                    Text("\(scores[index])")
                        .font(.title3)
                        .fontWeight(.bold)
                }
                .foregroundColor(currentPlayerIndex == index ? player.color : .secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(currentPlayerIndex == index ? player.color.opacity(0.2) : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
    }

    private var progressIndicator: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                ForEach(0..<totalQuestions, id: \.self) { index in
                    Circle()
                        .fill(index < questionNumber ? Color.green : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }

            Text("Q\(questionNumber + 1)/\(totalQuestions) • Level \(levels[currentPlayerIndex])")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
    }

    private var timerView: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 6)
                .frame(width: 60, height: 60)

            Circle()
                .trim(from: 0, to: CGFloat(timeRemaining) / 10.0)
                .stroke(
                    timeRemaining <= 3 ? Color.red : Color.green,
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                .frame(width: 60, height: 60)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: timeRemaining)

            Text("\(timeRemaining)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(timeRemaining <= 3 ? .red : .primary)
        }
        .padding(.vertical, 8)
    }

    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading...")
                .padding(.top)
            Spacer()
        }
    }

    private func questionView(_ question: Question) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("\(currentPlayer.name)'s Turn")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(currentPlayer.color)

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
                        MultiplayerAnswerButton(
                            text: option,
                            isSelected: selectedAnswer == index,
                            showResult: showingResult,
                            isCorrect: question.correctIndex == index,
                            wasSelected: selectedAnswer == index,
                            playerColor: currentPlayer.color
                        ) {
                            if !showingResult {
                                selectAnswer(index)
                            }
                        }
                    }
                }

                Spacer(minLength: 50)
            }
            .padding()
        }
    }

    private var passDeviceView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.system(size: 60))
                .foregroundColor(currentPlayer.color)

            Text("Pass to \(currentPlayer.name)")
                .font(.title)
                .fontWeight(.bold)

            Text("Starting in \(passCountdown)...")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(currentPlayer.color)

            Spacer()
        }
        .onAppear {
            startPassCountdown()
        }
    }

    private func startPassCountdown() {
        passCountdown = 3
        passTimer?.invalidate()
        passTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if passCountdown > 1 {
                passCountdown -= 1
            } else {
                timer.invalidate()
                passTimer = nil
                showingPassDevice = false
                timeRemaining = 10
                timerActive = true
            }
        }
    }

    private var finalResultView: some View {
        VStack(spacing: 24) {
            Spacer()

            ProgressView()
                .scaleEffect(1.5)

            Text("Calculating Results...")
                .font(.headline)
                .foregroundColor(.white)

            Spacer()
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showingFinalResult = false
                showingPodium = true
            }
        }
    }

    private var podiumOverlay: some View {
        PodiumCelebrationView(
            results: players.enumerated().map { index, player in
                PodiumResult(
                    name: player.name,
                    score: scores[index],
                    color: player.color,
                    profileId: player.profileId
                )
            },
            onDismiss: {
                dismiss()
            }
        )
        .ignoresSafeArea()
    }

    private func selectAnswer(_ index: Int) {
        timerActive = false
        selectedAnswer = index

        guard let question = quizEngine.currentQuestion else { return }
        let isCorrect = question.isCorrect(index)

        processAnswer(isCorrect: isCorrect)
    }

    private func handleTimeout() {
        timerActive = false
        selectedAnswer = nil
        processAnswer(isCorrect: false)
    }

    private func processAnswer(isCorrect: Bool) {
        if isCorrect {
            scores[currentPlayerIndex] += 1
            streaks[currentPlayerIndex] += 1
            if streaks[currentPlayerIndex] >= 2 {
                levels[currentPlayerIndex] = min(65, levels[currentPlayerIndex] + 1)
                streaks[currentPlayerIndex] = 0
            }
        } else {
            streaks[currentPlayerIndex] = 0
            levels[currentPlayerIndex] = max(1, levels[currentPlayerIndex] - 1)
        }

        showingResult = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            moveToNext()
        }
    }

    private func moveToNext() {
        questionNumber += 1
        selectedAnswer = nil
        showingResult = false

        if questionNumber >= totalQuestions {
            awardWins()
            showingFinalResult = true
        } else {
            currentPlayerIndex = (currentPlayerIndex + 1) % players.count
            showingPassDevice = true
            timerActive = false

            Task {
                await quizEngine.loadQuestion(for: subject, at: levels[currentPlayerIndex])
            }
        }
    }

    private func awardWins() {
        // Sort players by score to determine placement
        let sortedPlayers = players.enumerated()
            .map { (index: $0.offset, player: $0.element, score: scores[$0.offset]) }
            .sorted { $0.score > $1.score }

        // Award trophies based on placement
        for (placement, playerData) in sortedPlayers.enumerated() {
            guard let profileId = playerData.player.profileId,
                  let profile = profiles.first(where: { $0.id == profileId }) else {
                continue
            }

            switch placement {
            case 0: // 1st place - Gold
                profile.goldTrophies += 1
                profile.totalWins += 1
            case 1: // 2nd place - Silver
                profile.silverTrophies += 1
            case 2: // 3rd place - Bronze
                profile.bronzeTrophies += 1
            default:
                break
            }
        }
    }
}

struct MultiplayerAnswerButton: View {
    let text: String
    let isSelected: Bool
    let showResult: Bool
    let isCorrect: Bool
    let wasSelected: Bool
    let playerColor: Color
    let action: () -> Void

    private var backgroundColor: Color {
        if showResult {
            if isCorrect { return .green.opacity(0.3) }
            else if wasSelected { return .red.opacity(0.3) }
        }
        return isSelected ? playerColor.opacity(0.2) : .clear
    }

    private var borderColor: Color {
        if showResult {
            if isCorrect { return .green }
            else if wasSelected { return .red }
        }
        return isSelected ? playerColor : .gray.opacity(0.3)
    }

    var body: some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .font(.body)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)

                Spacer()

                if showResult {
                    if isCorrect {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    } else if wasSelected {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                    }
                }
            }
            .padding()
            .background(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: 2)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .disabled(showResult)
    }
}

#Preview {
    MultiplayerGameView(
        players: [
            PlayerConfig(name: "Alice", level: 5, color: .blue, avatar: "person.fill", profileId: nil),
            PlayerConfig(name: "Bob", level: 3, color: .red, avatar: "person.fill", profileId: nil)
        ],
        subject: .math
    )
}
