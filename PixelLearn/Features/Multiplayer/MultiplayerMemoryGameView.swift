import SwiftUI
import SwiftData

struct MultiplayerMemoryGameView: View {
    let cardCount: Int
    let emojiSet: EmojiSet
    let players: [PlayerConfig]

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]

    @State private var cards: [MemoryCard] = []
    @State private var flippedIndices: Set<Int> = []
    @State private var matchedIndices: Set<Int> = []
    @State private var isProcessing = false
    @State private var currentPlayerIndex = 0
    @State private var scores: [Int]
    @State private var showingResult = false

    private var pairCount: Int { cardCount / 2 }
    private var currentPlayer: PlayerConfig { players[currentPlayerIndex] }
    private var columnCount: Int { MemoryGameHelper.columnCount(for: cardCount) }
    private var columns: [GridItem] { MemoryGameHelper.gridColumns(for: cardCount) }
    private var rows: Int { (cardCount + columnCount - 1) / columnCount }

    init(cardCount: Int, emojiSet: EmojiSet = .mixed, players: [PlayerConfig]) {
        self.cardCount = cardCount
        self.emojiSet = emojiSet
        self.players = players
        _scores = State(initialValue: Array(repeating: 0, count: players.count))
    }

    var body: some View {
        ZStack {
            GradientBackground(colors: [.purple, .pink])

            VStack(spacing: 12) {
                scoreBoard
                currentPlayerIndicator

                if showingResult {
                    resultView
                } else {
                    gameGrid
                }
            }
            .padding()
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
            }
        }
        .onAppear {
            cards = MemoryGameHelper.createCards(pairCount: pairCount, emojiSet: emojiSet)
        }
        .supportedOrientations(.landscape)
    }

    private var scoreBoard: some View {
        CardSection {
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
                    .padding(.vertical, 6)
                    .background(currentPlayerIndex == index ? player.color.opacity(0.2) : Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
    }

    private var currentPlayerIndicator: some View {
        HStack {
            Circle()
                .fill(currentPlayer.color)
                .frame(width: 12, height: 12)

            Text("\(currentPlayer.name)'s Turn")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(currentPlayer.color)

            Spacer()

            Text("\(matchedIndices.count / 2)/\(pairCount)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 4)
    }

    private var gameGrid: some View {
        GeometryReader { geometry in
            let spacing: CGFloat = 12
            let availableWidth = max(0, geometry.size.width - (spacing * CGFloat(columnCount - 1)))
            let availableHeight = max(0, geometry.size.height - (spacing * CGFloat(rows - 1)))
            let cardSize = max(1, min(availableWidth / CGFloat(columnCount), availableHeight / CGFloat(rows)))

            LazyVGrid(columns: columns, spacing: spacing) {
                ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                    MemoryCardView(
                        card: card,
                        isFlipped: flippedIndices.contains(index) || matchedIndices.contains(index),
                        isMatched: matchedIndices.contains(index)
                    ) {
                        cardTapped(at: index)
                    }
                    .frame(width: cardSize, height: cardSize)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private var resultView: some View {
        VStack(spacing: 20) {
            Spacer()

            let maxScore = scores.max() ?? 0
            let winners = players.enumerated().filter { scores[$0.offset] == maxScore }

            Image(systemName: "trophy.fill")
                .font(.system(size: 60))
                .foregroundColor(.yellow)

            if winners.count == 1 {
                Text("\(winners[0].element.name) Wins!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(winners[0].element.color)
            } else {
                Text("It's a Tie!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
            }

            CardSection {
                VStack(spacing: 8) {
                    ForEach(Array(players.enumerated()), id: \.offset) { index, player in
                        HStack {
                            Circle()
                                .fill(player.color)
                                .frame(width: 16, height: 16)
                            Text(player.name)
                                .font(.subheadline)
                            Spacer()
                            Text("\(scores[index])")
                                .font(.headline)
                                .foregroundColor(player.color)
                        }
                    }
                }
            }

            Spacer()

            PrimaryButton(title: "Done", colors: [.purple, .pink]) {
                dismiss()
            }
        }
    }

    private func cardTapped(at index: Int) {
        guard !isProcessing,
              !flippedIndices.contains(index),
              !matchedIndices.contains(index),
              flippedIndices.count < 2 else { return }

        _ = withAnimation(.easeInOut(duration: 0.3)) {
            flippedIndices.insert(index)
        }

        if flippedIndices.count == 2 {
            isProcessing = true
            checkForMatch()
        }
    }

    private func checkForMatch() {
        let indices = Array(flippedIndices)
        let card1 = cards[indices[0]]
        let card2 = cards[indices[1]]

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if card1.symbol == card2.symbol {
                withAnimation {
                    matchedIndices.insert(indices[0])
                    matchedIndices.insert(indices[1])
                }

                scores[currentPlayerIndex] += 1

                if matchedIndices.count == cards.count {
                    awardWins()
                    showingResult = true
                }
            } else {
                currentPlayerIndex = (currentPlayerIndex + 1) % players.count
            }

            withAnimation(.easeInOut(duration: 0.3)) {
                flippedIndices.removeAll()
            }
            isProcessing = false
        }
    }

    private func awardWins() {
        let maxScore = scores.max() ?? 0
        let winnerIndices = scores.enumerated().filter { $0.element == maxScore }.map { $0.offset }

        // Only award win if there's a single winner (no ties)
        if winnerIndices.count == 1 {
            let winnerIndex = winnerIndices[0]
            let winnerPlayer = players[winnerIndex]

            // If winner has a profile, increment their wins
            if let profileId = winnerPlayer.profileId,
               let profile = profiles.first(where: { $0.id == profileId }) {
                profile.totalWins += 1
            }
        }
    }
}

#Preview {
    NavigationStack {
        MultiplayerMemoryGameView(
            cardCount: 16,
            players: [
                PlayerConfig(name: "Alice", level: 1, color: .blue, avatar: "person.fill", profileId: nil),
                PlayerConfig(name: "Bob", level: 1, color: .red, avatar: "person.fill", profileId: nil)
            ]
        )
    }
}
