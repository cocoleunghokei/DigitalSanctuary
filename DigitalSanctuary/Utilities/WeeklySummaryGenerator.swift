import Foundation

struct WeeklySummaryGenerator {

    static func generate(entries: [MoodEntry], weekStart: Date) -> (headline: String, body: String) {
        guard !entries.isEmpty else {
            return (
                headline: "Nothing Yet",
                body: "Nothing logged yet this week. Open the app each day — even one emoji tells a story."
            )
        }

        var counts: [MoodType: Int] = [:]
        for entry in entries { counts[entry.mood, default: 0] += 1 }
        let dominant = counts.max(by: { $0.value < $1.value })?.key ?? .neutral
        let n = entries.count
        let dayWord = n == 1 ? "day" : "days"

        switch dominant {
        case .fabulous:
            return (
                headline: "Absolutely Fabulous ✨",
                body: "What a week! You were shining bright 💅 — \(n) \(dayWord) logged and pure fabulous energy all around. The world clearly felt your glow."
            )
        case .happy:
            return (
                headline: "Good Vibes Only 😊",
                body: "A genuinely lovely week. \(n) \(dayWord) captured with a smile — the kind of week you'll look back on fondly. Keep riding this wave."
            )
        case .grounded:
            return (
                headline: "Steady & Rooted 🌱",
                body: "A grounded week. \(n) \(dayWord) of showing up with quiet steadiness. That calm strength? That's your superpower."
            )
        case .neutral:
            return (
                headline: "Quietly Present 😶",
                body: "A calm, middle-of-the-road week. \(n) \(dayWord) checked in. Sometimes neutral is the most honest place to be — and that's perfectly okay."
            )
        case .sad:
            return (
                headline: "Carrying Something Heavy 💙",
                body: "This week held some weight. \(n) \(dayWord) logged with honesty and courage. The fact that you're here, tracking, means you're not giving up."
            )
        case .anxious:
            return (
                headline: "Riding the Waves 😨",
                body: "A tense week, but you showed up. \(n) \(dayWord) tracked — awareness is always the first step toward finding ease. You've got this."
            )
        case .frustrated:
            return (
                headline: "Feeling the Friction 😠",
                body: "Some friction this week. \(n) \(dayWord) documented with honesty. That energy means something matters deeply to you — let's channel it."
            )
        }
    }
}
