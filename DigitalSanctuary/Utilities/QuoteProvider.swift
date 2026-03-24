import Foundation

struct QuoteProvider {

    static let quotes: [String] = [
        "Even the heaviest clouds cannot hold rain forever.",
        "You are not your worst week.",
        "Showing up is enough. You showed up.",
        "Every feeling is a visitor — it came, and it will leave.",
        "Gentleness toward yourself is not weakness.",
        "The bravest thing you can do is keep going when it's hard.",
        "You don't have to feel okay to be okay.",
        "Rest is not the same as giving up.",
        "Small steps still move you forward.",
        "Your feelings are valid, every single one of them.",
        "It's okay to not be okay. Just don't stay there alone.",
        "The storm doesn't last. Neither does this moment.",
        "You've survived 100% of your hard days so far.",
        "Be as kind to yourself as you would be to a good friend.",
        "Growth isn't always visible from the inside.",
        "Some seasons are for healing, not blooming.",
        "Your worth isn't measured by your productivity.",
        "One breath at a time is enough.",
        "Hard feelings are not permanent addresses.",
        "You are allowed to take up space, even on heavy days."
    ]

    /// Returns a quote when more than 50% of logged entries are low-mood
    static func quoteForMonth(_ entries: [MoodEntry]) -> String? {
        guard !entries.isEmpty else { return nil }
        let lowCount = entries.filter { $0.mood.isLow }.count
        guard Double(lowCount) / Double(entries.count) > 0.5 else { return nil }
        return quotes.randomElement()
    }

    static func random() -> String {
        quotes.randomElement() ?? quotes[0]
    }
}
