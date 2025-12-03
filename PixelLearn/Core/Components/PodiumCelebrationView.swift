import SwiftUI

struct PodiumResult: Identifiable {
    let id = UUID()
    let name: String
    let score: Int
    let color: Color
    let profileId: UUID?
    var place: Int = 0
}

struct PodiumCelebrationView: View {
    let results: [PodiumResult]
    let onDismiss: () -> Void

    @State private var showPodium = false
    @State private var showFirst = false
    @State private var showSecond = false
    @State private var showThird = false
    @State private var showConfetti = false
    @State private var showTrophies = false
    @State private var confettiPieces: [ConfettiPiece] = []

    private var sortedResults: [PodiumResult] {
        var sorted = results.sorted { $0.score > $1.score }
        for i in 0..<sorted.count {
            sorted[i].place = i + 1
        }
        return sorted
    }

    private var firstPlace: PodiumResult? { sortedResults.first }
    private var secondPlace: PodiumResult? { sortedResults.count > 1 ? sortedResults[1] : nil }
    private var thirdPlace: PodiumResult? { sortedResults.count > 2 ? sortedResults[2] : nil }

    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()

            // Confetti
            ForEach(confettiPieces) { piece in
                ConfettiView(piece: piece)
            }

            VStack(spacing: 20) {
                // Title
                Text("🎉 Results 🎉")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                    .scaleEffect(showPodium ? 1 : 0.5)
                    .opacity(showPodium ? 1 : 0)

                Spacer()

                // Podium
                HStack(alignment: .bottom, spacing: 8) {
                    // Second place (left)
                    if let second = secondPlace {
                        podiumSpot(result: second, height: 100, delay: 0.3)
                            .opacity(showSecond ? 1 : 0)
                            .offset(y: showSecond ? 0 : 50)
                    }

                    // First place (center)
                    if let first = firstPlace {
                        podiumSpot(result: first, height: 140, delay: 0.5)
                            .opacity(showFirst ? 1 : 0)
                            .offset(y: showFirst ? 0 : 50)
                    }

                    // Third place (right)
                    if let third = thirdPlace {
                        podiumSpot(result: third, height: 70, delay: 0.1)
                            .opacity(showThird ? 1 : 0)
                            .offset(y: showThird ? 0 : 50)
                    }
                }
                .padding(.horizontal, 20)

                // Trophy summary
                if showTrophies {
                    trophySummary
                        .transition(.scale.combined(with: .opacity))
                }

                Spacer()

                // Done button
                Button(action: onDismiss) {
                    Text("Done")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal, 40)
                .opacity(showTrophies ? 1 : 0)
            }
            .padding(.vertical, 40)
        }
        .onAppear {
            startAnimationSequence()
        }
    }

    private func podiumSpot(result: PodiumResult, height: CGFloat, delay: Double) -> some View {
        VStack(spacing: 8) {
            // Trophy icon
            trophyIcon(for: result.place)
                .font(.system(size: result.place == 1 ? 50 : 40))
                .shadow(color: trophyColor(for: result.place).opacity(0.8), radius: 10)

            // Player name
            Text(result.name)
                .font(.headline)
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            // Score
            Text("\(result.score)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)

            // Podium block
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        colors: [result.color, result.color.opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 90, height: height)
                .overlay(
                    Text("\(result.place)")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white.opacity(0.3))
                )
        }
    }

    private func trophyIcon(for place: Int) -> some View {
        Group {
            switch place {
            case 1:
                Text("🥇")
            case 2:
                Text("🥈")
            case 3:
                Text("🥉")
            default:
                Text("🏅")
            }
        }
    }

    private func trophyColor(for place: Int) -> Color {
        switch place {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return .blue
        }
    }

    private var trophySummary: some View {
        VStack(spacing: 12) {
            Text("Trophies Awarded")
                .font(.headline)
                .foregroundColor(.white.opacity(0.8))

            HStack(spacing: 30) {
                if firstPlace != nil {
                    VStack {
                        Text("🥇")
                            .font(.system(size: 30))
                        Text(firstPlace?.name ?? "")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                }
                if secondPlace != nil {
                    VStack {
                        Text("🥈")
                            .font(.system(size: 30))
                        Text(secondPlace?.name ?? "")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                }
                if thirdPlace != nil {
                    VStack {
                        Text("🥉")
                            .font(.system(size: 30))
                        Text(thirdPlace?.name ?? "")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func startAnimationSequence() {
        // Generate confetti pieces
        confettiPieces = (0..<50).map { _ in
            ConfettiPiece(
                color: [Color.red, .blue, .green, .yellow, .purple, .orange, .pink].randomElement()!,
                x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                delay: Double.random(in: 0...0.5)
            )
        }

        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            showPodium = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                showThird = true
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                showSecond = true
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                showFirst = true
            }
            showConfetti = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                showTrophies = true
            }
        }
    }
}

// MARK: - Confetti

struct ConfettiPiece: Identifiable {
    let id = UUID()
    let color: Color
    let x: CGFloat
    let delay: Double
}

struct ConfettiView: View {
    let piece: ConfettiPiece

    @State private var animate = false

    var body: some View {
        Rectangle()
            .fill(piece.color)
            .frame(width: 10, height: 10)
            .rotationEffect(.degrees(animate ? Double.random(in: 0...360) : 0))
            .position(
                x: piece.x + (animate ? CGFloat.random(in: -50...50) : 0),
                y: animate ? UIScreen.main.bounds.height + 50 : -50
            )
            .opacity(animate ? 0 : 1)
            .onAppear {
                withAnimation(
                    .easeIn(duration: Double.random(in: 2...4))
                    .delay(piece.delay)
                ) {
                    animate = true
                }
            }
    }
}

#Preview {
    PodiumCelebrationView(
        results: [
            PodiumResult(name: "Alice", score: 8, color: .blue, profileId: nil),
            PodiumResult(name: "Bob", score: 6, color: .red, profileId: nil),
            PodiumResult(name: "Charlie", score: 4, color: .green, profileId: nil)
        ],
        onDismiss: {}
    )
}
