import SwiftUI

// MARK: - Orientation Support

struct OrientationModifier: ViewModifier {
    let orientations: UIInterfaceOrientationMask

    func body(content: Content) -> some View {
        content
            .onAppear {
                AppDelegate.orientationLock = orientations
                if orientations == .landscape {
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                        windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .landscapeRight))
                    }
                }
            }
            .onDisappear {
                AppDelegate.orientationLock = .all
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
                }
            }
    }
}

extension View {
    func supportedOrientations(_ orientations: UIInterfaceOrientationMask) -> some View {
        modifier(OrientationModifier(orientations: orientations))
    }
}

// MARK: - Memory Game Components

struct MemoryCard: Identifiable {
    let id = UUID()
    let symbol: String
}

struct MemoryCardView: View {
    let card: MemoryCard
    let isFlipped: Bool
    let isMatched: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(cardBorder, lineWidth: isMatched ? 3 : 0)
                    )
                    .shadow(color: shadowColor, radius: isFlipped ? 4 : 2, y: isFlipped ? 2 : 1)

                if isFlipped || isMatched {
                    Text(card.symbol)
                        .font(.system(size: 32))
                        .scaleEffect(isMatched ? 1.1 : 1.0)
                } else {
                    Image(systemName: "sparkles")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.9))
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(isMatched)
        .scaleEffect(isMatched ? 0.95 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isFlipped)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isMatched)
    }

    private var cardBackground: some ShapeStyle {
        if isMatched {
            return AnyShapeStyle(Color.green.opacity(0.25))
        } else if isFlipped {
            return AnyShapeStyle(Color.white)
        } else {
            return AnyShapeStyle(
                LinearGradient(
                    colors: [.purple, .purple.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
    }

    private var cardBorder: Color {
        isMatched ? .green : .clear
    }

    private var shadowColor: Color {
        isMatched ? .green.opacity(0.3) : .black.opacity(0.15)
    }
}

// MARK: - Memory Game Helpers

enum EmojiSet: String, CaseIterable, Identifiable {
    case fruits = "Fruits"
    case animals = "Animals"
    case vehicles = "Vehicles"
    case nature = "Nature"
    case sports = "Sports"
    case food = "Food"
    case mixed = "Mixed"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .fruits: return "apple.logo"
        case .animals: return "pawprint.fill"
        case .vehicles: return "car.fill"
        case .nature: return "leaf.fill"
        case .sports: return "sportscourt.fill"
        case .food: return "fork.knife"
        case .mixed: return "sparkles"
        }
    }

    var symbols: [String] {
        switch self {
        case .fruits:
            return ["🍎", "🍊", "🍋", "🍇", "🍓", "🫐", "🍑", "🍒", "🍌", "🍉", "🥝", "🍍", "🥭", "🍐", "🍈", "🥥", "🍏", "🍅", "🥑", "🍆", "🥕", "🌽", "🥦", "🥬", "🥒", "🌶️", "🫑", "🧄", "🧅", "🥔", "🍠", "🥜"]
        case .animals:
            return ["🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐻", "🐼", "🐨", "🐯", "🦁", "🐮", "🐷", "🐸", "🐵", "🐔", "🐧", "🐦", "🐤", "🦆", "🦅", "🦉", "🦇", "🐺", "🐗", "🐴", "🦄", "🐝", "🐛", "🦋", "🐌", "🐞"]
        case .vehicles:
            return ["🚗", "🚕", "🚙", "🚌", "🚎", "🏎️", "🚓", "🚑", "🚒", "🚐", "🛻", "🚚", "🚛", "🚜", "🏍️", "🛵", "🚲", "🛴", "🚂", "🚃", "🚄", "🚅", "🚆", "🚇", "✈️", "🚀", "🛸", "🚁", "⛵", "🚤", "🛥️", "🚢"]
        case .nature:
            return ["🌸", "🌺", "🌻", "🌹", "🌷", "🌼", "💐", "🌾", "🌲", "🌳", "🌴", "🌵", "🍀", "🍁", "🍂", "🍃", "🌈", "☀️", "🌙", "⭐", "🌟", "❄️", "💧", "🔥", "🌊", "⚡", "🌪️", "🌤️", "⛅", "🌧️", "🌨️", "☁️"]
        case .sports:
            return ["⚽", "🏀", "🏈", "⚾", "🥎", "🎾", "🏐", "🏉", "🥏", "🎱", "🏓", "🏸", "🏒", "🏑", "🥍", "🏏", "🥅", "⛳", "🏹", "🎣", "🥊", "🥋", "🎽", "🛹", "🛼", "🛷", "⛸️", "🥌", "🎿", "🏂", "🏋️", "🤸"]
        case .food:
            return ["🍕", "🍔", "🍟", "🌭", "🥪", "🌮", "🌯", "🥙", "🧆", "🥚", "🍳", "🥘", "🍲", "🥣", "🥗", "🍿", "🧈", "🧀", "🥓", "🥩", "🍗", "🍖", "🦴", "🌰", "🍞", "🥐", "🥖", "🥨", "🥯", "🧇", "🥞", "🍩"]
        case .mixed:
            return ["🍎", "🍊", "🍋", "🍇", "🍓", "🫐", "🍑", "🍒",
                    "🌟", "🌙", "☀️", "🌈", "❄️", "🔥", "💧", "🌸",
                    "🦋", "🐝", "🐞", "🦊", "🐼", "🦁", "🐯", "🐸",
                    "🚀", "✈️", "🚗", "🚢", "🎈", "🎁", "🎨", "🎭"]
        }
    }
}

enum MemoryGameHelper {
    static let symbols = EmojiSet.mixed.symbols

    static func createCards(pairCount: Int, emojiSet: EmojiSet = .mixed) -> [MemoryCard] {
        let selectedSymbols = Array(emojiSet.symbols.prefix(pairCount))
        var cards: [MemoryCard] = []
        for symbol in selectedSymbols {
            cards.append(MemoryCard(symbol: symbol))
            cards.append(MemoryCard(symbol: symbol))
        }
        return cards.shuffled()
    }

    // Landscape-optimized column counts (more columns = wider layout)
    static func columnCount(for cardCount: Int) -> Int {
        switch cardCount {
        case 8: return 4      // 4x2
        case 16: return 8     // 8x2
        case 24: return 8     // 8x3
        case 32: return 8     // 8x4
        case 48: return 12    // 12x4
        case 64: return 16    // 16x4
        default: return 8
        }
    }

    static func gridColumns(for cardCount: Int) -> [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 12), count: columnCount(for: cardCount))
    }
}

// MARK: - Shared UI Components

struct GradientBackground: View {
    let colors: [Color]

    var body: some View {
        LinearGradient(
            colors: colors.map { $0.opacity(0.2) },
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

struct PrimaryButton: View {
    let title: String
    let colors: [Color]
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: colors,
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: colors[0].opacity(0.4), radius: 8, y: 4)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct CardSection<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Avatar Components

struct AvatarCircle: View {
    let iconName: String
    let size: CGFloat
    let colors: [Color]

    init(iconName: String, size: CGFloat = 70, colors: [Color] = [.pink, .purple]) {
        self.iconName = iconName
        self.size = size
        self.colors = colors
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: colors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)
                .shadow(color: colors[0].opacity(0.4), radius: size * 0.12, y: size * 0.05)

            Image(systemName: iconName)
                .font(.system(size: size * 0.45))
                .foregroundColor(.white)
        }
    }
}

// MARK: - Stats Components

struct StatItem: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)

            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

