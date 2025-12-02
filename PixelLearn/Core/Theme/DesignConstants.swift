import SwiftUI

/// Standardized design constants for consistent UI throughout the app
enum Design {
    // MARK: - Corner Radius
    enum CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let extraLarge: CGFloat = 20
        static let card: CGFloat = 16
        static let button: CGFloat = 12
    }

    // MARK: - Padding
    enum Padding {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let extraLarge: CGFloat = 20
        static let section: CGFloat = 24
    }

    // MARK: - Spacing
    enum Spacing {
        static let small: CGFloat = 4
        static let medium: CGFloat = 8
        static let large: CGFloat = 12
        static let extraLarge: CGFloat = 16
        static let section: CGFloat = 20
        static let group: CGFloat = 24
    }

    // MARK: - Icon Sizes
    enum IconSize {
        static let small: CGFloat = 24
        static let medium: CGFloat = 44
        static let large: CGFloat = 56
        static let extraLarge: CGFloat = 100
    }

    // MARK: - Shadow
    enum Shadow {
        static let radius: CGFloat = 8
        static let y: CGFloat = 4
        static let opacity: Double = 0.4
    }

    // MARK: - Game Settings
    enum Game {
        static let validCardCounts = [8, 16, 24, 32, 48, 64]
        static let minPlayers = 2
        static let maxPlayers = 4
        static let minLevel = 1
        static let maxLevel = 65
    }
}
