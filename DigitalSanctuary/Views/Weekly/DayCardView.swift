import SwiftUI

struct DayCardView: View {
    let date: Date
    let entry: MoodEntry?
    var onTap: (() -> Void)? = nil

    private var isToday: Bool { DateHelpers.isToday(date) }

    private var cardBackground: Color {
        if isToday { return .dsPrimaryContainer.opacity(0.45) }
        if entry != nil { return .dsSurfaceContainerLowest }
        return .dsSurfaceContainerLow
    }

    var body: some View {
        Button(action: { onTap?() }) {
            VStack(spacing: 10) {
                Text(DateHelpers.shortWeekdayName(for: date))
                    .font(.dsCaption)
                    .foregroundStyle(isToday ? Color.dsPrimaryDim : Color.dsOnSurfaceVariant)

                ZStack {
                    Circle()
                        .fill(Color.dsSurfaceContainerLow)
                        .frame(width: 52, height: 52)

                    if let entry = entry {
                        Text(entry.mood.emoji)
                            .font(.system(size: 26))
                    } else {
                        Circle()
                            .fill(Color.dsSurfaceContainerHigh)
                            .frame(width: 32, height: 32)
                    }
                }

                Text("\(DateHelpers.dayNumber(for: date))")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.dsOnSurface)

                if let entry = entry {
                    Text(entry.mood.label.uppercased())
                        .font(.dsCaption)
                        .foregroundStyle(Color.dsPrimaryDim)
                        .lineLimit(1)
                } else {
                    Text(" ")
                        .font(.dsCaption)
                }
            }
            .frame(width: 82)
            .padding(.vertical, 18)
            .background(cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 22))
        }
        .buttonStyle(.plain)
    }
}
