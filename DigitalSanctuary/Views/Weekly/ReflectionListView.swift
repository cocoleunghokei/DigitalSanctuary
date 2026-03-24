import SwiftUI

struct ReflectionListView: View {
    let entries: [MoodEntry]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Daily Reflections")
                .font(.dsTitle)
                .foregroundStyle(Color.dsOnSurface)

            if entries.isEmpty {
                Text("Write a reflection in your daily entries to see them here.")
                    .font(.dsBody)
                    .foregroundStyle(Color.dsOnSurfaceVariant)
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .sanctuaryCard()
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(entries.sorted(by: { $0.date < $1.date }), id: \.id) { entry in
                        reflectionCard(entry)
                    }
                }
            }
        }
    }

    private func reflectionCard(_ entry: MoodEntry) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 12) {
                Text("\(DateHelpers.dayNumber(for: entry.date))")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.dsOnSurfaceVariant)
                    .frame(width: 40, height: 40)
                    .background(Color.dsSurfaceContainerLow)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(DateHelpers.fullDateString(for: entry.date))
                        .font(.dsLabel)
                        .foregroundStyle(Color.dsOnSurface)
                    Text(entry.mood.label.uppercased())
                        .font(.dsCaption)
                        .foregroundStyle(Color.dsPrimaryDim)
                        .kerning(0.8)
                }

                Spacer()

                Text(entry.mood.emoji)
                    .font(.system(size: 26))
            }

            if !entry.reflection.isEmpty {
                Text(entry.reflection)
                    .font(.dsBody)
                    .foregroundStyle(Color.dsOnSurfaceVariant)
                    .lineSpacing(5)
            }

            if !entry.photoData.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(entry.photoData.enumerated()), id: \.offset) { _, data in
                            if let img = UIImage(data: data) {
                                Image(uiImage: img)
                                    .resizable()
                                    .aspectRatio(1, contentMode: .fill)
                                    .frame(width: 68, height: 68)
                                    .clipped()
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color.dsSurfaceContainerLowest)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
