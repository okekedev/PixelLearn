import SwiftUI

struct MemoryGameView: View {
    let cardCount: Int
    let emojiSet: EmojiSet

    @Environment(\.dismiss) private var dismiss

    @State private var cards: [MemoryCard] = []
    @State private var flippedIndices: Set<Int> = []
    @State private var matchedIndices: Set<Int> = []
    @State private var isProcessing = false
    @State private var showingResult = false
    @State private var moves = 0

    private var pairCount: Int { cardCount / 2 }
    private var columnCount: Int { MemoryGameHelper.columnCount(for: cardCount) }
    private var columns: [GridItem] { MemoryGameHelper.gridColumns(for: cardCount) }
    private var rows: Int { (cardCount + columnCount - 1) / columnCount }

    init(cardCount: Int, emojiSet: EmojiSet = .mixed) {
        self.cardCount = cardCount
        self.emojiSet = emojiSet
    }

    var body: some View {
        ZStack {
            GradientBackground(colors: [.purple, .pink])

            VStack(spacing: 16) {
                headerView

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

    private var headerView: some View {
        CardSection {
            HStack {
                VStack(alignment: .leading) {
                    Text("\(cardCount) Cards")
                        .font(.headline)
                    Text("\(matchedIndices.count / 2)/\(pairCount) found")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text("\(moves) moves")
                    .font(.headline)
            }
        }
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
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "star.fill")
                .font(.system(size: 80))
                .foregroundColor(.yellow)

            Text("Complete!")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Finished in \(moves) moves")
                .font(.title2)
                .foregroundStyle(.secondary)

            Spacer()

            PrimaryButton(title: "Done", colors: [.purple, .pink]) {
                dismiss()
            }

            Spacer()
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
            moves += 1
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

                if matchedIndices.count == cards.count {
                    showingResult = true
                }
            }

            withAnimation(.easeInOut(duration: 0.3)) {
                flippedIndices.removeAll()
            }
            isProcessing = false
        }
    }
}

#Preview {
    NavigationStack {
        MemoryGameView(cardCount: 16, emojiSet: .animals)
    }
}
