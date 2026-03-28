import SwiftUI
import SwiftData

struct WeeklyView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var weekOffset = 0
    @State private var weekEntries: [MoodEntry] = []

    var onDayTap: ((Date) -> Void)? = nil
    var refreshTrigger: Int = 0

    private var days: [Date] {
        DateHelpers.daysInWeek(offset: weekOffset)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                headerSection
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)

                weekNavigator
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)

                dayStrip
                    .padding(.bottom, 28)

                WeeklySummaryCard(entries: weekEntries, weekOffset: weekOffset)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 28)

                ReflectionListView(
                    entries: weekEntries.filter { !$0.reflection.isEmpty },
                    onTap: onDayTap
                )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
            }
        }
        .background(Color.dsSurface.ignoresSafeArea())
        .onAppear { fetchEntries() }
        .onChange(of: weekOffset) { fetchEntries() }
        .onChange(of: refreshTrigger) { fetchEntries() }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Spacer().frame(height: 20)
            Text("Detailed Narrative")
                .font(.dsCaption)
                .foregroundStyle(Color.dsOnSurfaceVariant)
                .kerning(1.5)
            Text("Your Week in\nReflected Stillness.")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(Color.dsOnSurface)
                .lineSpacing(2)
        }
    }

    // MARK: - Week navigator

    private var weekNavigator: some View {
        HStack {
            Button { weekOffset -= 1 } label: {
                navChevron(systemName: "chevron.left", active: true)
            }

            Spacer()

            Text(DateHelpers.weekRangeString(offset: weekOffset))
                .font(.dsSubtitle)
                .foregroundStyle(Color.dsOnSurface)

            Spacer()

            Button { if weekOffset < 0 { weekOffset += 1 } } label: {
                navChevron(systemName: "chevron.right", active: weekOffset < 0)
            }
            .disabled(weekOffset >= 0)
        }
        .padding(.horizontal, 4)
    }

    private func navChevron(systemName: String, active: Bool) -> some View {
        Image(systemName: systemName)
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(active ? Color.dsPrimary : Color.dsOnSurfaceVariant.opacity(0.3))
            .frame(width: 40, height: 40)
            .background(Color.dsSurfaceContainerLow)
            .clipShape(Circle())
    }

    // MARK: - Day strip

    private var dayStrip: some View {
        HStack(spacing: 6) {
            ForEach(days, id: \.self) { day in
                DayCardView(
                    date: day,
                    entry: entry(for: day),
                    onTap: { onDayTap?(day) }
                )
            }
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Helpers

    private func entry(for date: Date) -> MoodEntry? {
        weekEntries.first { DateHelpers.isSameDay($0.date, date) }
    }

    private func fetchEntries() {
        let (start, end) = DateHelpers.weekRange(offset: weekOffset)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: end) ?? end
        let descriptor = FetchDescriptor<MoodEntry>(
            predicate: #Predicate { $0.date >= start && $0.date < endOfDay },
            sortBy: [SortDescriptor(\.date)]
        )
        weekEntries = (try? modelContext.fetch(descriptor)) ?? []
    }
}
