import SwiftUI

struct EmojiPickerView: View {
    @Binding var selectedMood: MoodType?

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 4)

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("How are you feeling?")
                .font(.dsSubtitle)
                .foregroundStyle(Color.dsOnSurface)

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(MoodType.allCases, id: \.self) { mood in
                    MoodChipView(
                        mood: mood,
                        isSelected: selectedMood == mood,
                        action: { selectedMood = mood }
                    )
                }
            }
        }
    }
}
