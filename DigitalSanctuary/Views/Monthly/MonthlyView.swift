import SwiftUI
import SwiftData

struct MonthlyView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var monthOffset = 0
    @State private var monthEntries: [MoodEntry] = []

    var onDayTap: ((Date) -> Void)? = nil

    private var monthStart: Date {
        let (start, _) = DateHelpers.monthRange(offset: monthOffset)
        return start
    }

    private var encouragingQuote: String? {
        QuoteProvider.quoteForMonth(monthEntries)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                headerSection
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)

                monthNavigator
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)

                CalendarGridView(
                    monthStart: monthStart,
                    entries: monthEntries,
                    onDayTap: onDayTap
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 28)

                MoodCloudView(entries: monthEntries)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)

                MonthlyTrendView(entries: monthEntries)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)

                if let quote = encouragingQuote {
                    quoteCard(quote)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                }

                Spacer(minLength: 100)
            }
        }
        .background(Color.dsSurface.ignoresSafeArea())
        .onAppear { fetchEntries() }
        .onChange(of: monthOffset) { fetchEntries() }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Spacer().frame(height: 60)
            Text("Your Journey")
                .font(.dsCaption)
                .foregroundStyle(Color.dsOnSurfaceVariant)
                .kerning(1.5)
            Text("Monthly\nOverview.")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(Color.dsOnSurface)
                .lineSpacing(2)
        }
    }

    // MARK: - Month navigator

    private var monthNavigator: some View {
        HStack {
            Button { monthOffset -= 1 } label: {
                navChevron(systemName: "chevron.left", active: true)
            }

            Spacer()

            Text(DateHelpers.monthYearString(for: monthStart))
                .font(.dsSubtitle)
                .foregroundStyle(Color.dsOnSurface)

            Spacer()

            Button { if monthOffset < 0 { monthOffset += 1 } } label: {
                navChevron(systemName: "chevron.right", active: monthOffset < 0)
            }
            .disabled(monthOffset >= 0)
        }
    }

    private func navChevron(systemName: String, active: Bool) -> some View {
        Image(systemName: systemName)
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(active ? Color.dsPrimary : Color.dsOnSurfaceVariant.opacity(0.3))
            .frame(width: 40, height: 40)
            .background(Color.dsSurfaceContainerLow)
            .clipShape(Circle())
    }

    // MARK: - Quote card

    private func quoteCard(_ quote: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "quote.bubble.fill")
                    .foregroundStyle(Color.dsPrimary)
                Text("A Gentle Reminder")
                    .font(.dsCaption)
                    .foregroundStyle(Color.dsPrimaryDim)
                    .kerning(1)
            }
            Text(quote)
                .font(.dsBody)
                .italic()
                .foregroundStyle(Color.dsOnSurface)
                .lineSpacing(6)
        }
        .padding(20)
        .sanctuaryCard(background: .dsPrimaryContainer.opacity(0.2), cornerRadius: 20)
    }

    // MARK: - Data

    private func fetchEntries() {
        let (start, end) = DateHelpers.monthRange(offset: monthOffset)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: end)!
        let descriptor = FetchDescriptor<MoodEntry>(
            predicate: #Predicate { $0.date >= start && $0.date < endOfDay },
            sortBy: [SortDescriptor(\.date)]
        )
        monthEntries = (try? modelContext.fetch(descriptor)) ?? []
    }
}
