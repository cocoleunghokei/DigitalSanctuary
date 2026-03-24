import SwiftUI

struct CalendarGridView: View {
    let monthStart: Date
    let entries: [MoodEntry]
    var onDayTap: ((Date) -> Void)? = nil

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    private let weekdayLabels = ["M", "T", "W", "T", "F", "S", "S"]

    private var gridDays: [(date: Date, isCurrentMonth: Bool)] {
        DateHelpers.calendarGridDays(for: monthStart)
    }

    var body: some View {
        VStack(spacing: 4) {
            // Weekday header row
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(Array(weekdayLabels.enumerated()), id: \.offset) { _, label in
                    Text(label)
                        .font(.dsCaption)
                        .foregroundStyle(Color.dsOnSurfaceVariant)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 6)
                }
            }

            // Day cells
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(Array(gridDays.enumerated()), id: \.offset) { _, dayInfo in
                    dayCellView(date: dayInfo.date, isCurrentMonth: dayInfo.isCurrentMonth)
                }
            }
        }
    }

    @ViewBuilder
    private func dayCellView(date: Date, isCurrentMonth: Bool) -> some View {
        let entry = entries.first { DateHelpers.isSameDay($0.date, date) }
        let isToday = DateHelpers.isToday(date)

        Button {
            if isCurrentMonth { onDayTap?(date) }
        } label: {
            ZStack {
                if isToday {
                    Circle()
                        .fill(Color.dsPrimaryContainer)
                        .frame(width: 42, height: 42)
                }

                if let entry = entry {
                    Text(entry.mood.emoji)
                        .font(.system(size: 22))
                } else {
                    Circle()
                        .fill(isCurrentMonth
                              ? Color.dsSurfaceContainerLow
                              : Color.dsSurfaceContainerLow.opacity(0.3))
                        .frame(width: 28, height: 28)
                }
            }
            .frame(height: 46)
            .opacity(isCurrentMonth ? 1.0 : 0.3)
        }
        .buttonStyle(.plain)
        .disabled(!isCurrentMonth)
    }
}
