import SwiftUI
import SwiftData

struct CalendarGridView: View {
    let monthStart: Date
    let entries: [MoodEntry]
    var onDayTap: ((Date) -> Void)? = nil
    var onMoodQuickSaved: (() -> Void)? = nil

    @Environment(\.modelContext) private var modelContext

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    private let weekdayLabels = ["M", "T", "W", "T", "F", "S", "S"]

    // Picker state
    @State private var longPressedDate: Date? = nil
    @State private var pickerAnchor: CGPoint = .zero
    @State private var hoveredMoodIndex: Int? = nil
    @State private var containerWidth: CGFloat = 300

    // Timer used to distinguish tap (<0.45s) from long press (≥0.45s)
    @State private var pressTimer: Timer? = nil

    private let moods = MoodType.allCases
    private let emojiSlotWidth: CGFloat = 42   // 38px item + 4px gap
    private let pickerHPad: CGFloat = 10
    private let pickerTotalWidth: CGFloat = 310
    private let pickerHalfHeight: CGFloat = 28

    private var gridDays: [(date: Date, isCurrentMonth: Bool)] {
        DateHelpers.calendarGridDays(for: monthStart)
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: 4) {
                // Weekday header
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
            .coordinateSpace(name: "calendarGrid")
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onAppear { containerWidth = geo.size.width }
                        .onChange(of: geo.size.width) { _, w in containerWidth = w }
                }
            )

            // Quick mood picker — only visible while finger is held after long press
            if longPressedDate != nil {
                let clampedX = min(max(pickerAnchor.x, pickerTotalWidth / 2),
                                   containerWidth - pickerTotalWidth / 2)
                QuickMoodPickerView(hoveredIndex: hoveredMoodIndex)
                    .position(x: clampedX, y: pickerAnchor.y - pickerHalfHeight - 8)
                    .transition(.scale(scale: 0.8, anchor: .bottom).combined(with: .opacity))
                    .zIndex(1)
            }
        }
        .onDisappear {
            pressTimer?.invalidate()
            pressTimer = nil
            longPressedDate = nil
            hoveredMoodIndex = nil
        }
    }

    // MARK: - Day cell

    @ViewBuilder
    private func dayCellView(date: Date, isCurrentMonth: Bool) -> some View {
        let entry = entries.first { DateHelpers.isSameDay($0.date, date) }
        let isToday = DateHelpers.isToday(date)

        GeometryReader { cellGeo in
            ZStack {
                if isToday {
                    Circle()
                        .fill(Color.dsPrimaryContainer)
                        .frame(width: 42, height: 42)
                }

                if let entry = entry {
                    Text(entry.moodRaw)
                        .font(.system(size: 22))
                } else {
                    Circle()
                        .fill(isCurrentMonth
                              ? Color.dsSurfaceContainerLow
                              : Color.dsSurfaceContainerLow.opacity(0.3))
                        .frame(width: 28, height: 28)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .opacity(isCurrentMonth ? 1.0 : 0.3)
            .contentShape(Rectangle())
            // Single gesture handles both tap and long press to avoid conflicts
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .named("calendarGrid"))
                    .onChanged { value in
                        guard isCurrentMonth else { return }

                        if pressTimer == nil && longPressedDate == nil {
                            // ── Touch just started: begin long-press countdown ──
                            let frame = cellGeo.frame(in: .named("calendarGrid"))
                            pressTimer = Timer.scheduledTimer(withTimeInterval: 0.45, repeats: false) { _ in
                                DispatchQueue.main.async {
                                    pressTimer = nil
                                    withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                                        pickerAnchor = CGPoint(x: frame.midX, y: frame.midY)
                                        longPressedDate = date
                                    }
                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                }
                            }
                        } else if pressTimer != nil {
                            // ── Finger moved significantly before long press fires → treat as scroll ──
                            let dx = abs(value.translation.width)
                            let dy = abs(value.translation.height)
                            if dx > 8 || dy > 8 {
                                pressTimer?.invalidate()
                                pressTimer = nil
                            }
                        } else if longPressedDate != nil {
                            // ── Long press active: drag finger over emojis to hover ──
                            updateHovered(at: value.location)
                        }
                    }
                    .onEnded { _ in
                        if let timer = pressTimer {
                            // ── Timer hasn't fired → quick tap → navigate ──
                            timer.invalidate()
                            pressTimer = nil
                            onDayTap?(date)
                        } else if longPressedDate != nil {
                            // ── Finger lifted after long press → commit & dismiss ──
                            commitSelection()
                            withAnimation(.spring(response: 0.2)) {
                                longPressedDate = nil
                                hoveredMoodIndex = nil
                            }
                        }
                        // If timer was cancelled (scroll gesture) → do nothing
                    }
            )
        }
        .frame(height: 46)
    }

    // MARK: - Helpers

    private func updateHovered(at location: CGPoint) {
        let clampedX = min(max(pickerAnchor.x, pickerTotalWidth / 2),
                           containerWidth - pickerTotalWidth / 2)
        let pickerLeft = clampedX - pickerTotalWidth / 2 + pickerHPad
        let relX = location.x - pickerLeft
        let index = Int(relX / emojiSlotWidth)
        hoveredMoodIndex = (index >= 0 && index < moods.count) ? index : nil
    }

    private func commitSelection() {
        guard let date = longPressedDate, let index = hoveredMoodIndex else { return }
        let mood = moods[index]

        if let existing = entries.first(where: { DateHelpers.isSameDay($0.date, date) }) {
            existing.moodRaw = mood.rawValue
        } else {
            modelContext.insert(MoodEntry(date: date, mood: mood))
            onMoodQuickSaved?()
        }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}
