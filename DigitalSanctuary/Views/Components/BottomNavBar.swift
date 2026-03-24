import SwiftUI

enum AppTab: CaseIterable {
    case monthly, weekly, daily

    var label: String {
        switch self {
        case .monthly: return "Monthly"
        case .weekly:  return "Weekly"
        case .daily:   return "Daily"
        }
    }

    var icon: String {
        switch self {
        case .monthly: return "calendar"
        case .weekly:  return "chart.bar"
        case .daily:   return "face.smiling"
        }
    }
}

struct BottomNavBar: View {
    @Binding var activeTab: AppTab

    var body: some View {
        HStack(spacing: 0) {
            navItem(.monthly)
            Spacer()
            navItem(.weekly)
            Spacer()
            navItem(.daily)
        }
        .padding(.horizontal, 40)
        .padding(.top, 14)
        .padding(.bottom, 32)
        .glassmorphic()
        .clipShape(RoundedCorner(radius: 32, corners: [.topLeft, .topRight]))
        .shadow(color: Color.dsOnSurface.opacity(0.04), radius: 20, x: 0, y: -4)
    }

    @ViewBuilder
    private func navItem(_ tab: AppTab) -> some View {
        let isActive = activeTab == tab
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                activeTab = tab
            }
        } label: {
            VStack(spacing: 5) {
                Image(systemName: tab.icon)
                    .symbolVariant(isActive ? .fill : .none)
                    .font(.system(size: 22, weight: isActive ? .semibold : .regular))
                Text(tab.label)
                    .font(.dsCaption)
            }
            .foregroundStyle(isActive ? Color.dsPrimary : Color.dsOnSurfaceVariant)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                isActive
                    ? Color.dsPrimaryContainer.opacity(0.35)
                    : Color.clear
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .animation(.spring(response: 0.3), value: isActive)
        }
        .buttonStyle(.plain)
    }
}
