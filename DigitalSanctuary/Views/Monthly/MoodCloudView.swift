import SwiftUI

struct MoodCloudView: View {
    let entries: [MoodEntry]

    private var moodCounts: [(emoji: String, count: Int)] {
        var counts: [String: Int] = [:]
        for e in entries { counts[e.moodRaw, default: 0] += 1 }
        return counts
            .map { (emoji: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
            .prefix(4)
            .map { $0 }
    }

    private var maxCount: Int { moodCounts.first?.count ?? 1 }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Mood Landscape")
                .font(.dsSubtitle)
                .foregroundStyle(Color.dsOnSurface)

            if entries.isEmpty {
                Text("Log some entries to see your mood landscape here.")
                    .font(.dsBody)
                    .foregroundStyle(Color.dsOnSurfaceVariant)
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .sanctuaryCard()
            } else {
                let gridColumns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)
                LazyVGrid(columns: gridColumns, spacing: 12) {
                    ForEach(moodCounts, id: \.emoji) { item in
                        cloudChip(emoji: item.emoji, count: item.count)
                    }
                }
                .padding(20)
                .gradientCard(gradient: .dsMoodCloudGradient, cornerRadius: 28)
            }
        }
    }

    private func cloudChip(emoji: String, count: Int) -> some View {
        let ratio = Double(count) / Double(max(maxCount, 1))
        let emojiSize = 16 + (ratio * 18) // 16…34pt

        return VStack(spacing: 4) {
            Text(emoji)
                .font(.system(size: emojiSize))
            Text("\(count)x")
                .font(.dsCaption)
                .foregroundStyle(Color.dsOnPrimaryFixed.opacity(0.65))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(.white.opacity(0.22))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
