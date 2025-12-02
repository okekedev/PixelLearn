import SwiftUI
import SwiftData

struct PlayerConfig: Identifiable {
    let id = UUID()
    var name: String
    var level: Int
    var color: Color
    var avatar: String
    var profileId: UUID?
}

struct MultiplayerSetupView: View {
    @Query private var profiles: [UserProfile]

    var preselectedSubject: Subject?

    @State private var players: [PlayerConfig] = []
    @State private var selectedSubject: Subject = .math
    @State private var showingGame = false
    @State private var showingMemoryGame = false
    @State private var rulesExpanded = false

    // Memory game settings
    @State private var memoryCardCount: Int = 16
    @State private var selectedEmojiSet: EmojiSet = .fruits

    // Inline add player state
    @State private var guestName: String = ""
    @State private var guestLevel: Int = 1
    @State private var selectedAvatar: String = "person.fill"
    @State private var showingAvatarPicker = false

    private let playerColors: [Color] = [.blue, .red, .green, .orange]
    private let avatarOptions = ["person.fill", "star.fill", "heart.fill", "bolt.fill", "leaf.fill", "flame.fill", "moon.fill", "sun.max.fill", "cloud.fill", "snowflake", "bird.fill", "hare.fill", "tortoise.fill", "fish.fill", "pawprint.fill", "face.smiling.fill"]

    private var nextPlayerColor: Color {
        playerColors[players.count % playerColors.count]
    }

    private var availableProfiles: [UserProfile] {
        let addedProfileIds = Set(players.compactMap { $0.profileId })
        return profiles.filter { !addedProfileIds.contains($0.id) }
    }

    init(preselectedSubject: Subject? = nil) {
        self.preselectedSubject = preselectedSubject
        if let subject = preselectedSubject {
            _selectedSubject = State(initialValue: subject)
        }
    }

    private var themeColors: [Color] {
        selectedSubject.gradientColors
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: themeColors.map { $0.opacity(0.2) },
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .animation(.easeInOut, value: selectedSubject)

            ScrollView {
                VStack(spacing: 20) {
                    playersSection
                    if preselectedSubject == nil {
                        subjectSection
                    }
                    if selectedSubject == .memory {
                        memorySettingsSection
                    }
                    rulesSection
                    startButton
                }
                .padding()
            }
        }
        .navigationTitle(preselectedSubject.map { "\($0.displayName) - Multiplayer" } ?? "Multiplayer")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showingGame) {
            MultiplayerGameView(
                players: players,
                subject: selectedSubject
            )
        }
        .fullScreenCover(isPresented: $showingMemoryGame) {
            NavigationStack {
                MultiplayerMemoryGameView(
                    cardCount: memoryCardCount,
                    emojiSet: selectedEmojiSet,
                    players: players
                )
            }
        }
        .sheet(isPresented: $showingAvatarPicker) {
            AvatarPickerSheet(
                selectedAvatar: selectedAvatar,
                avatarOptions: avatarOptions,
                color: nextPlayerColor,
                onSelect: { avatar in
                    selectedAvatar = avatar
                    showingAvatarPicker = false
                }
            )
            .presentationDetents([.medium])
        }
    }

    private var playersSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Players")
                    .font(.headline)
                Spacer()
                Text("\(players.count)/\(Design.Game.maxPlayers)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            // Current players with level sliders
            if !players.isEmpty {
                ForEach(Array(players.enumerated()), id: \.element.id) { index, player in
                    PlayerRowWithSlider(
                        player: $players[index],
                        showLevel: selectedSubject != .memory,
                        onRemove: {
                            players.remove(at: index)
                        }
                    )
                }
            }

            // Inline add player section
            if players.count < Design.Game.maxPlayers {
                addPlayerSection
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var addPlayerSection: some View {
        VStack(spacing: 16) {
            // Divider if there are already players
            if !players.isEmpty {
                Divider()
                    .padding(.vertical, 4)
            }

            Text(players.isEmpty ? "Add at least 2 players" : "Add Player \(players.count + 1)")
                .font(.subheadline)
                .foregroundColor(.secondary)

            // Saved profiles (only show those not already added)
            if !availableProfiles.isEmpty {
                VStack(spacing: 8) {
                    ForEach(availableProfiles, id: \.id) { profile in
                        Button {
                            addProfile(profile)
                        } label: {
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [.pink, .purple],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 44, height: 44)

                                    Image(systemName: profile.displayAvatarName)
                                        .font(.title3)
                                        .foregroundColor(.white)
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(profile.name)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                    if selectedSubject != .memory {
                                        Text("Level \(profile.adventureLevel(for: selectedSubject))")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }

                                Spacer()

                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(themeColors[0])
                            }
                            .padding(12)
                            .background(themeColors[0].opacity(0.05))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(themeColors[0].opacity(0.2), lineWidth: 1)
                            )
                        }
                    }
                }
            }

            // Guest option
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    // Avatar button
                    Button {
                        showingAvatarPicker = true
                    } label: {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [nextPlayerColor, nextPlayerColor.opacity(0.7)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 50, height: 50)

                            Image(systemName: selectedAvatar)
                                .font(.title3)
                                .foregroundColor(.white)
                        }
                    }

                    // Name field
                    TextField("Guest name", text: $guestName)
                        .textFieldStyle(.roundedBorder)
                        .onAppear {
                            guestName = "Player \(players.count + 1)"
                        }
                        .onChange(of: players.count) { _, newCount in
                            if guestName.isEmpty || guestName.hasPrefix("Player ") {
                                guestName = "Player \(newCount + 1)"
                            }
                        }

                    // Add button
                    Button {
                        addGuest()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                            .foregroundColor(nextPlayerColor)
                    }
                }

                // Level slider for guest
                if selectedSubject != .memory {
                    VStack(spacing: 4) {
                        HStack {
                            Text("Starting Level")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(guestLevel)")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(nextPlayerColor)
                        }

                        Slider(value: Binding(
                            get: { Double(guestLevel) },
                            set: { guestLevel = Int($0) }
                        ), in: Double(Design.Game.minLevel)...Double(Design.Game.maxLevel), step: 1)
                        .tint(nextPlayerColor)
                    }
                }
            }
            .padding(12)
            .background(nextPlayerColor.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(nextPlayerColor.opacity(0.2), lineWidth: 1)
            )
        }
    }

    private func addProfile(_ profile: UserProfile) {
        let config = PlayerConfig(
            name: profile.name,
            level: profile.adventureLevel(for: selectedSubject),
            color: nextPlayerColor,
            avatar: profile.displayAvatarName,
            profileId: profile.id
        )
        players.append(config)
        resetGuestInputs()
    }

    private func addGuest() {
        let config = PlayerConfig(
            name: guestName.isEmpty ? "Player \(players.count + 1)" : guestName,
            level: guestLevel,
            color: nextPlayerColor,
            avatar: selectedAvatar,
            profileId: nil
        )
        players.append(config)
        resetGuestInputs()
    }

    private func resetGuestInputs() {
        guestName = "Player \(players.count + 1)"
        guestLevel = 1
        selectedAvatar = "person.fill"
    }

    private var subjectSection: some View {
        VStack(spacing: 16) {
            Text("Subject")
                .font(.headline)

            HStack(spacing: 12) {
                ForEach(Subject.allCases) { subject in
                    SubjectButton(
                        subject: subject,
                        isSelected: selectedSubject == subject
                    ) {
                        selectedSubject = subject
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var memorySettingsSection: some View {
        VStack(spacing: 16) {
            Text("Memory Settings")
                .font(.headline)

            // Card count selector
            VStack(spacing: 8) {
                HStack {
                    Text("Cards")
                        .font(.subheadline)
                    Spacer()
                    Text("\(memoryCardCount)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(themeColors[0])
                }

                Picker("Card Count", selection: $memoryCardCount) {
                    Text("8").tag(8)
                    Text("16").tag(16)
                    Text("24").tag(24)
                    Text("32").tag(32)
                    Text("48").tag(48)
                    Text("64").tag(64)
                }
                .pickerStyle(.segmented)
            }

            // Emoji set selector
            VStack(alignment: .leading, spacing: 8) {
                Text("Emoji Theme")
                    .font(.subheadline)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(EmojiSet.allCases) { emojiSet in
                            Button {
                                selectedEmojiSet = emojiSet
                            } label: {
                                VStack(spacing: 6) {
                                    Text(emojiSet.symbols.prefix(3).joined())
                                        .font(.title3)

                                    Text(emojiSet.rawValue)
                                        .font(.caption2)
                                        .fontWeight(.medium)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(selectedEmojiSet == emojiSet ? themeColors[0].opacity(0.2) : Color.clear)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(selectedEmojiSet == emojiSet ? themeColors[0] : Color.gray.opacity(0.3), lineWidth: selectedEmojiSet == emojiSet ? 2 : 1)
                                )
                            }
                            .foregroundColor(.primary)
                        }
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var rulesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    rulesExpanded.toggle()
                }
            } label: {
                HStack {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.blue)
                    Text("Rules")
                        .font(.headline)
                        .foregroundColor(.primary)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                        .rotationEffect(.degrees(rulesExpanded ? 90 : 0))
                }
            }

            if rulesExpanded {
                if selectedSubject == .memory {
                    VStack(alignment: .leading, spacing: 8) {
                        RuleRow(icon: "square.grid.2x2.fill", text: "\(memoryCardCount) cards to match", color: themeColors[0])
                        RuleRow(icon: "arrow.triangle.2.circlepath", text: "Players take turns flipping 2 cards", color: themeColors[0])
                        RuleRow(icon: "checkmark.circle.fill", text: "Match = keep going + 1 point", color: themeColors[0])
                        RuleRow(icon: "xmark.circle.fill", text: "No match = next player's turn", color: themeColors[0])
                        RuleRow(icon: "trophy.fill", text: "Most pairs wins!", color: themeColors[0])
                    }
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        RuleRow(icon: "clock.fill", text: "10 seconds to answer each question", color: themeColors[0])
                        RuleRow(icon: "arrow.triangle.2.circlepath", text: "Players take turns answering", color: themeColors[0])
                        RuleRow(icon: "arrow.up.circle.fill", text: "2 correct in a row = level up", color: themeColors[0])
                        RuleRow(icon: "arrow.down.circle.fill", text: "1 wrong = level down", color: themeColors[0])
                        RuleRow(icon: "flag.checkered", text: "10 questions total, highest score wins", color: themeColors[0])
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var startButton: some View {
        Button {
            if selectedSubject == .memory {
                showingMemoryGame = true
            } else {
                showingGame = true
            }
        } label: {
            Text("Start Game")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: players.count >= Design.Game.minPlayers ? themeColors : [.gray, .gray],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: Design.CornerRadius.button))
                .shadow(color: players.count >= Design.Game.minPlayers ? themeColors[0].opacity(0.4) : .clear, radius: 8, y: 4)
        }
        .disabled(players.count < Design.Game.minPlayers)
    }
}

struct PlayerRowWithSlider: View {
    @Binding var player: PlayerConfig
    let showLevel: Bool
    let onRemove: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [player.color, player.color.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)

                    Image(systemName: player.avatar)
                        .font(.title3)
                        .foregroundColor(.white)
                }

                Text(player.name)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                Button(action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
            }

            // Level slider
            if showLevel {
                VStack(spacing: 4) {
                    HStack {
                        Text("Level")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(player.level)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(player.color)
                    }

                    Slider(value: Binding(
                        get: { Double(player.level) },
                        set: { player.level = Int($0) }
                    ), in: Double(Design.Game.minLevel)...Double(Design.Game.maxLevel), step: 1)
                    .tint(player.color)
                }
            }
        }
        .padding(12)
        .background(player.color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct AvatarPickerSheet: View {
    let selectedAvatar: String
    let avatarOptions: [String]
    let color: Color
    let onSelect: (String) -> Void

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(avatarOptions, id: \.self) { avatar in
                        Button {
                            onSelect(avatar)
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(
                                        selectedAvatar == avatar
                                            ? LinearGradient(colors: [color, color.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                            : LinearGradient(colors: [.gray.opacity(0.2), .gray.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                    )
                                    .frame(width: 60, height: 60)

                                Image(systemName: avatar)
                                    .font(.title2)
                                    .foregroundColor(selectedAvatar == avatar ? .white : .primary)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Choose Icon")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct SubjectButton: View {
    let subject: Subject
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: subject.iconName)
                    .font(.title2)

                Text(subject.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(isSelected ? .white : .primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                isSelected
                    ? AnyShapeStyle(LinearGradient(colors: subject.gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                    : AnyShapeStyle(Color.clear)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

struct RuleRow: View {
    let icon: String
    let text: String
    var color: Color = .green

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)

            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    NavigationStack {
        MultiplayerSetupView()
    }
}
