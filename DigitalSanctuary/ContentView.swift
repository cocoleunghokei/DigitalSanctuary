import SwiftUI

// Identifiable wrapper so .sheet(item:) gets a fresh instance on every tap
private struct EntryTarget: Identifiable {
    let id = UUID()
    let date: Date
}

struct ContentView: View {
    @State private var activeTab: AppTab = .monthly
    @State private var entryTarget: EntryTarget? = nil
    @State private var refreshTrigger = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            // Main content — fills full screen
            Group {
                switch activeTab {
                case .monthly:
                    MonthlyView(
                        onDayTap: { date in entryTarget = EntryTarget(date: date) },
                        refreshTrigger: refreshTrigger
                    )
                case .weekly:
                    WeeklyView(
                        onDayTap: { date in entryTarget = EntryTarget(date: date) },
                        refreshTrigger: refreshTrigger
                    )
                case .community:
                    CommunityView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.bottom, 80)

            // Glassmorphic bottom nav
            BottomNavBar(activeTab: $activeTab)

            // Floating Action Button — visible on all tabs
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FABButton(action: { entryTarget = EntryTarget(date: Date()) })
                        .padding(.trailing, 22)
                        .padding(.bottom, 94)
                }
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .sheet(item: $entryTarget) { target in
            DailyView(isModal: true, initialDate: target.date, onSave: {
                entryTarget = nil
                refreshTrigger += 1
            })
        }
    }
}
