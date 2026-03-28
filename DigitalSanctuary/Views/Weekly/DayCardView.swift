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
            VStack(spacing: 6) {
                Text(DateHelpers.shortWeekdayName(for: date))
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(isToday ? Color.dsPrimaryDim : Color.dsOnSurfaceVariant)

                ZStack {
                    Circle()
                        .fill(Color.dsSurfaceContainerLow)
                        .frame(width: 38, height: 38)

                    if let entry = entry {
                        Text(entry.moodRaw)
                            .font(.system(size: 20))
                    } else {
                        Circle()
                            .fill(Color.dsSurfaceContainerHigh)
                            .frame(width: 22, height: 22)
                    }
                }

                Text("\(DateHelpers.dayNumber(for: date))")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.dsOnSurface)

                if let entry = entry {
                    Text(entry.resolvedLabel.uppercased())
                        .font(.system(size: 8, weight: .semibold))
                        .foregroundStyle(Color.dsPrimaryDim)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                } else {
                    Text(" ")
                        .font(.system(size: 8))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}
