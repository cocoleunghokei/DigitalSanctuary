import Foundation

struct DateHelpers {

    static var calendar: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday = 2 // Monday
        return cal
    }()

    static func startOfDay(_ date: Date) -> Date {
        calendar.startOfDay(for: date)
    }

    // Returns (Monday, Sunday) of the week offset from today
    static func weekRange(offset: Int) -> (start: Date, end: Date) {
        let today = calendar.startOfDay(for: Date())
        let weekday = calendar.component(.weekday, from: today)
        // weekday: 1=Sun, 2=Mon…7=Sat  — days since Monday:
        let daysSinceMonday = (weekday - 2 + 7) % 7
        let thisMonday = calendar.date(byAdding: .day, value: -daysSinceMonday, to: today) ?? today
        let monday = calendar.date(byAdding: .weekOfYear, value: offset, to: thisMonday) ?? thisMonday
        let sunday = calendar.date(byAdding: .day, value: 6, to: monday) ?? monday
        return (monday, sunday)
    }

    // Returns array of 7 Dates for the week at offset
    static func daysInWeek(offset: Int) -> [Date] {
        let (start, _) = weekRange(offset: offset)
        return (0..<7).compactMap {
            calendar.date(byAdding: .day, value: $0, to: start)
        }
    }

    // Returns (first day, last day) of a month at offset from today
    static func monthRange(offset: Int) -> (start: Date, end: Date) {
        let now = Date()
        let target = calendar.date(byAdding: .month, value: offset, to: now) ?? now
        let comps = calendar.dateComponents([.year, .month], from: target)
        let start = calendar.date(from: comps) ?? now
        var endComps = DateComponents()
        endComps.month = 1
        endComps.day = -1
        let end = calendar.date(byAdding: endComps, to: start) ?? start
        return (start, end)
    }

    // Returns all (date, isCurrentMonth) cells for a calendar grid
    // including leading days from the previous month and trailing days to fill rows
    static func calendarGridDays(for monthStart: Date) -> [(date: Date, isCurrentMonth: Bool)] {
        let comps = calendar.dateComponents([.year, .month], from: monthStart)
        let firstDay = calendar.date(from: comps) ?? monthStart

        var endComps = DateComponents()
        endComps.month = 1
        endComps.day = -1
        let lastDay = calendar.date(byAdding: endComps, to: firstDay) ?? firstDay
        let totalDays = calendar.component(.day, from: lastDay)

        let firstWeekday = calendar.component(.weekday, from: firstDay)
        let leadingCount = (firstWeekday - 2 + 7) % 7

        var result: [(Date, Bool)] = []

        // Leading days from previous month
        if leadingCount > 0 {
            for i in (1...leadingCount).reversed() {
                if let d = calendar.date(byAdding: .day, value: -i, to: firstDay) {
                    result.append((d, false))
                }
            }
        }

        // Current month days
        for day in 0..<totalDays {
            if let d = calendar.date(byAdding: .day, value: day, to: firstDay) {
                result.append((d, true))
            }
        }

        // Trailing days to fill the last row
        let remainder = result.count % 7
        if remainder > 0 {
            let trailing = 7 - remainder
            if let lastDate = result.last?.0 {
                for i in 1...trailing {
                    if let d = calendar.date(byAdding: .day, value: i, to: lastDate) {
                        result.append((d, false))
                    }
                }
            }
        }

        return result
    }

    static func isToday(_ date: Date) -> Bool {
        calendar.isDateInToday(date)
    }

    static func isSameDay(_ a: Date, _ b: Date) -> Bool {
        calendar.isDate(a, inSameDayAs: b)
    }

    static func dayNumber(for date: Date) -> Int {
        calendar.component(.day, from: date)
    }

    static func shortWeekdayName(for date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "EEE"
        return f.string(from: date).uppercased()
    }

    static func monthYearString(for date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return f.string(from: date)
    }

    static func weekRangeString(offset: Int) -> String {
        let (start, end) = weekRange(offset: offset)
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return "\(f.string(from: start)) — \(f.string(from: end))"
    }

    static func fullDateString(for date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMM d"
        return f.string(from: date)
    }
}
