import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @State private var showingProfileSwitcher = false

    private var activeProfile: UserProfile {
        if let profile = profiles.first(where: { $0.isActive }) {
            return profile
        }
        if let profile = profiles.first {
            profile.isActive = true
            return profile
        }
        let newProfile = UserProfile(profileName: "Player 1")
        modelContext.insert(newProfile)
        return newProfile
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.purple.opacity(0.2), Color.blue.opacity(0.2)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                headerView
                statsCard
                Spacer()
                subjectsSection
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingProfileSwitcher) {
            ProfileSwitcherView(
                profiles: profiles,
                activeProfile: activeProfile,
                onSelect: switchToProfile,
                onAdd: addNewProfile,
                onDelete: deleteProfile,
                onRename: { profile, name in profile.name = name }
            )
        }
    }

    private var headerView: some View {
        VStack(spacing: 16) {
            Text("PixelLearn")
                .font(.system(size: 38, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.purple, .blue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            Button { showingProfileSwitcher = true } label: {
                HStack(spacing: 14) {
                    AvatarCircle(iconName: activeProfile.displayAvatarName, size: 56)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(activeProfile.name)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                        Text("Tap to switch profile")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(16)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(.plain)
        }
    }

    private var statsCard: some View {
        VStack(spacing: 16) {
            HStack(spacing: 24) {
                StatItem(icon: "checkmark.circle.fill", value: "\(activeProfile.totalCorrectAnswers)", label: "Correct", color: .green)
                Divider().frame(height: 50)
                StatItem(icon: "trophy.fill", value: "\(activeProfile.totalWins)", label: "Wins", color: .orange)
            }

            // Trophy display
            HStack(spacing: 20) {
                TrophyItem(emoji: "🥇", count: activeProfile.goldTrophies, label: "Gold")
                TrophyItem(emoji: "🥈", count: activeProfile.silverTrophies, label: "Silver")
                TrophyItem(emoji: "🥉", count: activeProfile.bronzeTrophies, label: "Bronze")
            }
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var subjectsSection: some View {
        VStack(spacing: 16) {
            ForEach(Subject.allCases) { subject in
                NavigationLink(destination: SubjectModeView(subject: subject)) {
                    SubjectRow(
                        subject: subject,
                        level: activeProfile.adventureLevel(for: subject),
                        isMemory: subject == .memory
                    )
                }
            }
        }
    }

    private func switchToProfile(_ profile: UserProfile) {
        profiles.forEach { $0.isActive = ($0.id == profile.id) }
    }

    private func addNewProfile() {
        modelContext.insert(UserProfile(profileName: "Player \(profiles.count + 1)", active: false))
    }

    private func deleteProfile(_ profile: UserProfile) {
        guard profiles.count > 1 else { return }
        let wasActive = profile.isActive
        modelContext.delete(profile)
        if wasActive, let first = profiles.first(where: { $0.id != profile.id }) {
            first.isActive = true
        }
    }
}

struct SubjectModeView: View {
    let subject: Subject

    @Query private var profiles: [UserProfile]

    private var activeProfile: UserProfile? {
        profiles.first(where: { $0.isActive }) ?? profiles.first
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: subject.gradientColors.map { $0.opacity(0.2) },
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Subject header
                VStack(spacing: 16) {
                    Image(systemName: subject.iconName)
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                        .frame(width: 100, height: 100)
                        .background(
                            LinearGradient(
                                colors: subject.gradientColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .shadow(color: subject.gradientColors[0].opacity(0.4), radius: 10, y: 5)

                    Text(subject.displayName)
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    if let profile = activeProfile {
                        if subject == .memory {
                            Text("\(min(profile.adventureLevel(for: subject) * 4, 64)) cards")
                                .font(.title3)
                                .foregroundColor(.secondary)
                        } else {
                            Text("Level \(profile.adventureLevel(for: subject))")
                                .font(.title3)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.top, 40)

                Spacer()

                // Mode buttons
                VStack(spacing: 20) {
                    Text("Choose Mode")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    NavigationLink(destination: soloDestination) {
                        ModeButton(
                            icon: "person.fill",
                            title: "Solo",
                            subtitle: "Play by yourself",
                            colors: subject.gradientColors
                        )
                    }

                    NavigationLink(destination: MultiplayerSetupView(preselectedSubject: subject)) {
                        ModeButton(
                            icon: "person.2.fill",
                            title: "Multiplayer",
                            subtitle: "2-4 players",
                            colors: [.green, .teal]
                        )
                    }
                }
                .padding(.horizontal, 20)

                Spacer()
            }
        }
        .navigationTitle(subject.displayName)
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var soloDestination: some View {
        if subject == .memory {
            SoloMemorySetupView()
        } else {
            QuizView(subject: subject)
        }
    }
}

struct SoloMemorySetupView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var cardCount: Int = 16
    @State private var selectedEmojiSet: EmojiSet = .fruits
    @State private var showingGame = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.purple.opacity(0.2), Color.pink.opacity(0.2)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                        .frame(width: 100, height: 100)
                        .background(
                            LinearGradient(
                                colors: [.purple, .pink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .shadow(color: .purple.opacity(0.4), radius: 10, y: 5)

                    Text("Memory Game")
                        .font(.title)
                        .fontWeight(.bold)
                }
                .padding(.top, 20)

                // Settings
                VStack(spacing: 20) {
                    // Card count
                    VStack(spacing: 8) {
                        HStack {
                            Text("Cards")
                                .font(.headline)
                            Spacer()
                            Text("\(cardCount)")
                                .font(.headline)
                                .foregroundColor(.purple)
                        }

                        Picker("Card Count", selection: $cardCount) {
                            Text("8").tag(8)
                            Text("16").tag(16)
                            Text("24").tag(24)
                            Text("32").tag(32)
                            Text("48").tag(48)
                            Text("64").tag(64)
                        }
                        .pickerStyle(.segmented)
                    }

                    // Emoji theme
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Emoji Theme")
                            .font(.headline)

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
                                        .background(selectedEmojiSet == emojiSet ? Color.purple.opacity(0.2) : Color.clear)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(selectedEmojiSet == emojiSet ? Color.purple : Color.gray.opacity(0.3), lineWidth: selectedEmojiSet == emojiSet ? 2 : 1)
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
                .padding(.horizontal)

                Spacer()

                // Start button
                Button {
                    showingGame = true
                } label: {
                    Text("Start Game")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [.purple, .pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: .purple.opacity(0.4), radius: 8, y: 4)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        .navigationTitle("Memory")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showingGame) {
            NavigationStack {
                MemoryGameView(cardCount: cardCount, emojiSet: selectedEmojiSet)
            }
        }
    }
}

struct ModeButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let colors: [Color]

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(
                    LinearGradient(
                        colors: colors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(color: colors[0].opacity(0.4), radius: 6, y: 3)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .padding(18)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
    }
}

struct SubjectRow: View {
    let subject: Subject
    let level: Int
    var isMemory: Bool = false

    private var cardCount: Int {
        min(level * 4, 64)
    }

    private var progressValue: Double {
        isMemory ? Double(cardCount) : Double(level)
    }

    private var progressTotal: Double {
        isMemory ? 64 : 65
    }

    private var subtitleText: String {
        isMemory ? "\(cardCount) cards" : "Level \(level)"
    }

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: subject.iconName)
                .font(.title)
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(
                    LinearGradient(
                        colors: subject.gradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(color: subject.gradientColors[0].opacity(0.4), radius: 6, y: 3)

            VStack(alignment: .leading, spacing: 6) {
                Text(subject.displayName)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                HStack(spacing: 10) {
                    Text(subtitleText)
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    ProgressView(value: progressValue, total: progressTotal)
                        .tint(subject.gradientColors[0])
                        .frame(width: 80)
                }
            }

            Spacer()

            Image(systemName: "play.circle.fill")
                .font(.largeTitle)
                .foregroundColor(subject.gradientColors[0])
        }
        .padding(18)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
    }
}

struct ProfileSwitcherView: View {
    let profiles: [UserProfile]
    let activeProfile: UserProfile
    let onSelect: (UserProfile) -> Void
    let onAdd: () -> Void
    let onDelete: (UserProfile) -> Void
    let onRename: (UserProfile, String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var editingProfile: UserProfile?
    @State private var editedName = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Text(profiles.count > 1 ? "Who's Playing?" : "Profile")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top)

                    // Show all profiles
                    ForEach(profiles, id: \.id) { profile in
                        ProfileRowCard(
                            profile: profile,
                            isActive: profile.id == activeProfile.id,
                            isEditing: editingProfile?.id == profile.id,
                            editedName: $editedName,
                            canDelete: profiles.count > 1,
                            onTap: {
                                if editingProfile == nil && profiles.count > 1 {
                                    onSelect(profile)
                                    dismiss()
                                }
                            },
                            onEdit: {
                                editingProfile = profile
                                editedName = profile.name
                            },
                            onSave: {
                                onRename(profile, editedName)
                                editingProfile = nil
                            },
                            onDelete: {
                                onDelete(profile)
                            }
                        )
                    }

                    // Add profile button
                    Button {
                        onAdd()
                    } label: {
                        HStack {
                            Image(systemName: "person.badge.plus")
                            Text("Add Profile")
                        }
                        .font(.headline)
                        .foregroundColor(.green)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.green.opacity(0.3), lineWidth: 1)
                        )
                    }
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ProfileRowCard: View {
    let profile: UserProfile
    let isActive: Bool
    let isEditing: Bool
    @Binding var editedName: String
    let canDelete: Bool
    let onTap: () -> Void
    let onEdit: () -> Void
    let onSave: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.pink, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                    .overlay(
                        Circle()
                            .stroke(isActive ? Color.green : Color.clear, lineWidth: 3)
                    )

                Image(systemName: profile.displayAvatarName)
                    .font(.title2)
                    .foregroundColor(.white)
            }
            .onTapGesture(perform: onTap)

            VStack(alignment: .leading, spacing: 4) {
                if isEditing {
                    TextField("Name", text: $editedName)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit(onSave)
                } else {
                    Text(profile.name)
                        .font(.headline)

                    if isActive {
                        Text("Currently active")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
            }

            Spacer()

            HStack(spacing: 12) {
                Button {
                    if isEditing {
                        onSave()
                    } else {
                        onEdit()
                    }
                } label: {
                    Image(systemName: isEditing ? "checkmark.circle.fill" : "pencil.circle.fill")
                        .font(.title2)
                        .foregroundColor(isEditing ? .green : .blue)
                }

                if canDelete && !isEditing {
                    Button(action: onDelete) {
                        Image(systemName: "trash.circle.fill")
                            .font(.title2)
                            .foregroundColor(.red.opacity(0.7))
                    }
                }
            }
        }
        .padding()
        .background(isActive ? Color.green.opacity(0.08) : Color.clear)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
    .modelContainer(for: UserProfile.self, inMemory: true)
}
