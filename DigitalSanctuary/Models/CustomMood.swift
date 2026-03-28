import Foundation
import SwiftData

@Model
final class CustomMood {
    var id: UUID
    var emoji: String
    var label: String
    var isPositive: Bool
    var createdAt: Date

    init(emoji: String, label: String, isPositive: Bool) {
        self.id = UUID()
        self.emoji = emoji
        self.label = label
        self.isPositive = isPositive
        self.createdAt = Date()
    }

    /// Infers positive/negative sentiment from an emoji using a lookup of known negative emojis.
    /// Defaults to positive for anything not in the list.
    static func inferIsPositive(for emoji: String) -> Bool {
        let negative: Set<String> = [
            "😢","😭","😠","😡","🤬","😤","😩","😫","😰","😨","😱",
            "😖","😣","😞","😔","😟","😕","🙁","☹️","😬","😥","😓",
            "💔","🫠","😵","🤒","🤕","😒","🙄","😧","😦","🥺",
            "😿","💀","☠️","👿","😈","🤢","🤮","🥵","🥶","😶","😑","😐"
        ]
        return !negative.contains(emoji)
    }
}
