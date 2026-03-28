import SwiftUI
import SwiftData

@main
struct DigitalSanctuaryApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [MoodEntry.self, CustomMood.self, CommunityMessage.self])
    }
}
