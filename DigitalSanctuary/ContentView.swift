import SwiftUI

struct ContentView: View {
    @State private var activeTab: AppTab = .weekly
    @State private var showNewEntry = false
    @State private var targetDate: Date = Date()

    var body: some View {
        ZStack(alignment: .bottom) {
            // Main content — fills full screen
            Group {
                switch activeTab {
                case .monthly:
                    MonthlyView(onDayTap: { date in
                        targetDate = date
                        withAnimation(.spring(response: 0.35)) { activeTab = .daily }
                    })
                case .weekly:
                    WeeklyView(onDayTap: { date in
                        targetDate = date
                        withAnimation(.spring(response: 0.35)) { activeTab = .daily }
                    })
                case .daily:
                    DailyView(initialDate: targetDate)
                        .id(targetDate)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.bottom, 80)

            // Glassmorphic bottom nav
            BottomNavBar(activeTab: $activeTab)

            // Floating Action Button (bottom-right, above nav bar)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FABButton(action: { showNewEntry = true })
                        .padding(.trailing, 22)
                        .padding(.bottom, 94)
                }
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .sheet(isPresented: $showNewEntry) {
            DailyView(isModal: true)
        }
    }
}
