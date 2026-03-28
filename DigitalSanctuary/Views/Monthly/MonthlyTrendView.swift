import SwiftUI

struct MonthlyTrendView: View {
    let entries: [MoodEntry]

    private var dominantEntry: (emoji: String, label: String)? {
        var counts: [String: Int] = [:]
        for e in entries { counts[e.moodRaw, default: 0] += 1 }
        guard let top = counts.max(by: { $0.value < $1.value }) else { return nil }
        let label = entries.first { $0.moodRaw == top.key }?.resolvedLabel ?? top.key
        return (emoji: top.key, label: label)
    }

    private var positivePercent: Int {
        guard !entries.isEmpty else { return 0 }
        let n = entries.filter { $0.resolvedIsPositive }.count
        return Int(Double(n) / Double(entries.count) * 100)
    }

    var body: some View {
        HStack(spacing: 10) {
            trendCard(
                value: dominantEntry?.emoji ?? "—",
                label: dominantEntry?.label ?? "None",
                sublabel: "Most felt"
            )
            trendCard(
                value: "\(entries.count)",
                label: "Logged",
                sublabel: "This month"
            )
            trendCard(
                value: "\(positivePercent)%",
                label: "Positive",
                sublabel: "Happy days"
            )
        }
    }

    private func trendCard(value: String, label: String, sublabel: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(Color.dsOnSurface)
                .lineLimit(1)
            Text(label)
                .font(.dsLabel)
                .foregroundStyle(Color.dsOnSurface)
                .lineLimit(1)
            Text(sublabel)
                .font(.dsCaption)
                .foregroundStyle(Color.dsOnSurfaceVariant)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .sanctuaryCard(cornerRadius: 20)
    }
}
