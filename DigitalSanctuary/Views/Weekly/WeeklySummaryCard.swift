import SwiftUI

struct WeeklySummaryCard: View {
    let entries: [MoodEntry]
    let weekOffset: Int

    private var summary: (headline: String, body: String) {
        let (start, _) = DateHelpers.weekRange(offset: weekOffset)
        return WeeklySummaryGenerator.generate(entries: entries, weekStart: start)
    }

    private var dominantEntry: (emoji: String, label: String)? {
        var counts: [String: Int] = [:]
        for e in entries { counts[e.moodRaw, default: 0] += 1 }
        guard let dominantRaw = counts.max(by: { $0.value < $1.value })?.key,
              let entry = entries.first(where: { $0.moodRaw == dominantRaw }) else { return nil }
        return (entry.moodRaw, entry.resolvedLabel)
    }

    var body: some View {
        VStack(spacing: 12) {
            // Gradient hero card
            ZStack(alignment: .bottomLeading) {
                Circle()
                    .fill(.white.opacity(0.18))
                    .frame(width: 180, height: 180)
                    .blur(radius: 50)
                    .offset(x: 140, y: -50)
                    .allowsHitTesting(false)

                VStack(alignment: .leading, spacing: 14) {
                    Text("Weekly Synthesis")
                        .font(.dsCaption)
                        .foregroundStyle(Color.dsOnPrimaryFixed.opacity(0.65))
                        .kerning(1.5)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(.white.opacity(0.25))
                        .clipShape(Capsule())

                    Text(summary.headline)
                        .font(.dsHero)
                        .foregroundStyle(Color.dsOnPrimaryFixed)
                        .lineLimit(2)

                    Text(summary.body)
                        .font(.dsBody)
                        .foregroundStyle(Color.dsOnPrimaryFixed.opacity(0.85))
                        .lineSpacing(5)
                }
                .padding(24)
            }
            .frame(maxWidth: .infinity, minHeight: 220)
            .gradientCard(gradient: .dsMoodCloudGradient, cornerRadius: 28)

            // Stat cards
            HStack(spacing: 12) {
                statCard(
                    icon: dominantEntry.map { AnyView(Text($0.emoji).font(.system(size: 32))) }
                        ?? AnyView(Image(systemName: "moon.zzz").font(.system(size: 26)).foregroundStyle(Color.dsPrimary)),
                    value: dominantEntry?.label ?? "—",
                    label: "Most felt"
                )
                statCard(
                    icon: AnyView(
                        Image(systemName: "calendar.badge.checkmark")
                            .font(.system(size: 26))
                            .foregroundStyle(Color.dsPrimary)
                    ),
                    value: "\(entries.count)/7",
                    label: "Days logged"
                )
            }
        }
    }

    private func statCard(icon: AnyView, value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            icon
            Text(value)
                .font(.dsTitle)
                .foregroundStyle(Color.dsOnSurface)
            Text(label)
                .font(.dsCaption)
                .foregroundStyle(Color.dsOnSurfaceVariant)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .sanctuaryCard(cornerRadius: 20)
    }
}
