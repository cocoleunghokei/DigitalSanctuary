import Foundation

enum MoodType: String, CaseIterable, Codable {
    case sad        = "😢"
    case neutral    = "😶"
    case happy      = "😊"
    case grounded   = "🌱"
    case frustrated = "😠"
    case anxious    = "😨"
    case fabulous   = "💅"

    var label: String {
        switch self {
        case .sad:        return "Sad"
        case .neutral:    return "Neutral"
        case .happy:      return "Happy"
        case .grounded:   return "Grounded"
        case .frustrated: return "Frustrated"
        case .anxious:    return "Anxious"
        case .fabulous:   return "Fabulous"
        }
    }

    var emoji: String { rawValue }

    var isLow: Bool {
        self == .sad || self == .anxious || self == .frustrated
    }

    var isPositive: Bool {
        self == .happy || self == .grounded || self == .fabulous
    }
}
