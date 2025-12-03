import Foundation
import SwiftUI

enum Subject: String, Codable, CaseIterable, Identifiable {
    case grammar = "Grammar"
    case memory = "Memory"
    case math = "Math"
    case spelling = "Spelling"

    var id: String { rawValue }

    var displayName: String { rawValue }

    var iconName: String {
        switch self {
        case .grammar: return "text.book.closed"
        case .memory: return "brain"
        case .math: return "function"
        case .spelling: return "character.cursor.ibeam"
        }
    }

    var gradientColors: [Color] {
        switch self {
        case .grammar: return [.blue, .indigo]
        case .memory: return [.purple, .pink]
        case .math: return [.orange, .red]
        case .spelling: return [.green, .teal]
        }
    }
}
