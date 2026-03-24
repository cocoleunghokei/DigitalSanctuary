import Foundation
import SwiftData

@Model
final class MoodEntry {
    var id: UUID
    var date: Date
    var moodRaw: String
    var reflection: String
    @Attribute(.externalStorage) var photoData: [Data]

    var mood: MoodType {
        get { MoodType(rawValue: moodRaw) ?? .neutral }
        set { moodRaw = newValue.rawValue }
    }

    init(date: Date, mood: MoodType, reflection: String = "", photoData: [Data] = []) {
        self.id = UUID()
        self.date = Calendar.current.startOfDay(for: date)
        self.moodRaw = mood.rawValue
        self.reflection = reflection
        self.photoData = photoData
    }
}
