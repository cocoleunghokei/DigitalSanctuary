import SwiftUI
import SwiftData

struct EmojiPickerView: View {
    @Binding var selection: MoodSelection?

    @Query(sort: \CustomMood.createdAt) private var customMoods: [CustomMood]
    @State private var showCreator = false
    @State private var currentPage = 0

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 4)

    // All moods as a flat list of (emoji, label, MoodSelection)
    private struct MoodItem {
        let emoji: String
        let label: String
        let sel: MoodSelection
    }

    private var allMoods: [MoodItem] {
        MoodType.allCases.map { MoodItem(emoji: $0.emoji, label: $0.label, sel: .from($0)) } +
        customMoods.map { MoodItem(emoji: $0.emoji, label: $0.label, sel: .from($0)) }
    }

    // Chunk into pages of 7 — slot 8 on each page is always the Add button
    private var pages: [[MoodItem]] {
        stride(from: 0, to: max(1, allMoods.count), by: 7).map { i in
            Array(allMoods[i ..< min(i + 7, allMoods.count)])
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("How are you feeling?")
                .font(.dsSubtitle)
                .foregroundStyle(Color.dsOnSurface)

            TabView(selection: $currentPage) {
                ForEach(pages.indices, id: \.self) { pageIndex in
                    pageView(pages[pageIndex])
                        .padding(.horizontal, 2)
                        .padding(.bottom, 28)
                        .tag(pageIndex)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .frame(height: 210)
        }
        .sheet(isPresented: $showCreator) {
            CustomMoodCreatorView { newMood in
                selection = .from(newMood)
                // Jump to the page containing the new mood (it's appended last)
                let newIndex = MoodType.allCases.count + customMoods.count // position after insert
                currentPage = newIndex / 7
            }
        }
    }

    // MARK: - One page: up to 7 mood chips + Add at slot 8

    private func pageView(_ items: [MoodItem]) -> some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(items.indices, id: \.self) { i in
                let item = items[i]
                MoodChipView(
                    emoji: item.emoji,
                    label: item.label,
                    isSelected: selection?.emoji == item.emoji,
                    action: { selection = item.sel }
                )
            }

            // Invisible spacers to push Add to slot 8
            let empty = 7 - items.count
            ForEach(0 ..< empty, id: \.self) { _ in
                Color.clear
                    .frame(maxWidth: .infinity, minHeight: 80)
            }

            // Slot 8 — Add button
            Button { showCreator = true } label: {
                VStack(spacing: 6) {
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(Color.dsOnSurfaceVariant)
                    Text("Add")
                        .font(.dsCaption)
                        .foregroundStyle(Color.dsOnSurfaceVariant)
                }
                .frame(maxWidth: .infinity, minHeight: 80)
                .background(Color.dsSurfaceContainerLow)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(Color.dsOnSurfaceVariant.opacity(0.3), lineWidth: 1.5)
                )
            }
            .buttonStyle(.plain)
        }
    }
}
