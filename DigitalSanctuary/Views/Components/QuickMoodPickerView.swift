import SwiftUI

struct QuickMoodPickerView: View {
    let moods: [MoodType] = MoodType.allCases
    let hoveredIndex: Int?

    var body: some View {
        HStack(spacing: 4) {
            ForEach(Array(moods.enumerated()), id: \.offset) { i, mood in
                let isHovered = hoveredIndex == i
                Text(mood.emoji)
                    .font(.system(size: isHovered ? 28 : 22))
                    .frame(width: 38, height: 38)
                    .background(
                        Circle()
                            .fill(isHovered
                                  ? Color.dsPrimaryContainer
                                  : Color.dsSurfaceContainerHigh)
                    )
                    .scaleEffect(isHovered ? 1.25 : 1.0)
                    .animation(.spring(response: 0.2, dampingFraction: 0.6), value: hoveredIndex)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 9)
        .background(
            Capsule()
                .fill(Color.dsSurface)
                .shadow(color: .black.opacity(0.18), radius: 14, x: 0, y: 6)
        )
    }
}
