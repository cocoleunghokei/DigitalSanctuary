import Foundation
import SwiftData

@Model
final class CommunityMessage {
    var id: UUID
    var text: String
    var author: String
    var likeCount: Int
    var isLikedByUser: Bool
    var moodTags: [String]      // emoji strings this message resonates with
    var isUserCreated: Bool
    var createdAt: Date

    init(text: String, author: String, likeCount: Int = 0,
         moodTags: [String] = [], isUserCreated: Bool = false) {
        self.id = UUID()
        self.text = text
        self.author = author
        self.likeCount = likeCount
        self.isLikedByUser = false
        self.moodTags = moodTags
        self.isUserCreated = isUserCreated
        self.createdAt = Date()
    }
}

// MARK: - Seed data

extension CommunityMessage {
    static let seeds: [(text: String, author: String, likes: Int, tags: [String])] = [
        (
            "You are not alone in this stillness. Even the quietest forest is full of growth.",
            "Anonymous Soul", 24, ["😶", "😔", "😢", "😌"]
        ),
        (
            "Deep breaths today. Tomorrow's light is already finding its way to you.",
            "A Traveler", 18, ["😰", "😨", "😩", "😢"]
        ),
        (
            "It is okay to just 'be' right now. You don't have to solve everything today.",
            "Silent Friend", 31, ["😶", "😔", "😫", "😩"]
        ),
        (
            "The fact that you showed up — even just to feel — means you are stronger than you think.",
            "A Fellow Wanderer", 42, ["😢", "😠", "😤", "😨"]
        ),
        (
            "Your joy is contagious. Keep shining exactly as you are.",
            "Sunbeam", 56, ["😊", "💅", "😄", "🌱"]
        ),
        (
            "Feeling frustrated means you care deeply. That fire is a gift — let it guide you.",
            "Ember", 13, ["😠", "😡", "😤", "🤬"]
        ),
        (
            "Anxiety is just excitement without a direction yet. You'll find yours.",
            "Grounded Oak", 27, ["😨", "😰", "😱", "😟"]
        ),
        (
            "You are growing even when you cannot see it. Roots go deep before the tree rises.",
            "The Gardener", 38, ["🌱", "😔", "😶", "😢"]
        ),
        (
            "What a week you are having. The world is brighter because you are in it.",
            "Kindred Spirit", 61, ["😊", "💅", "🌱", "😄"]
        ),
        (
            "Every feeling is valid. You do not need permission to feel exactly what you feel.",
            "Open Heart", 45, ["😢", "😠", "😨", "😩", "😶"]
        )
    ]
}
