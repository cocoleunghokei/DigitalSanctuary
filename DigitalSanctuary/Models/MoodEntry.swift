import Foundation
import SwiftData

@Model
final class MoodEntry {
    var id: UUID
    var date: Date
    var moodRaw: String
    var moodLabel: String = ""       // empty = use built-in MoodType label
    var moodIsPositive: Bool = false // only meaningful when moodLabel is non-empty
    var reflection: String
    @Attribute(.externalStorage) var photoData: [Data]

    // Legacy computed property — returns .neutral fallback for custom moods
    var mood: MoodType {
        get { MoodType(rawValue: moodRaw) ?? .neutral }
        set { moodRaw = newValue.rawValue }
    }

    /// Emoji for display — always use this instead of mood.emoji
    var resolvedEmoji: String { moodRaw }

    /// Human-readable label, works for both built-in and custom moods
    var resolvedLabel: String {
        moodLabel.isEmpty
            ? (MoodType(rawValue: moodRaw)?.label ?? moodRaw)
            : moodLabel
    }

    /// Sentiment flag, works for both built-in and custom moods
    var resolvedIsPositive: Bool {
        moodLabel.isEmpty
            ? (MoodType(rawValue: moodRaw)?.isPositive ?? false)
            : moodIsPositive
    }

    init(date: Date, mood: MoodType, reflection: String = "", photoData: [Data] = []) {
        self.id = UUID()
        self.date = Calendar.current.startOfDay(for: date)
        self.moodRaw = mood.rawValue
        self.moodLabel = ""
        self.moodIsPositive = false
        self.reflection = reflection
        self.photoData = photoData
    }
}
