import SwiftUI
import SwiftData
import PhotosUI

struct DailyView: View {
    var isModal: Bool = false
    var onSave: (() -> Void)? = nil

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var selectedDate: Date
    @State private var moodSelection: MoodSelection? = nil
    @State private var reflection = ""
    @State private var photoData: [Data] = []
    @State private var existingEntry: MoodEntry? = nil
    @State private var showSavedBadge = false

    private let maxReflectionChars = 200
    private let maxPhotos = 4
    private let maxBytes = 5 * 1024 * 1024

    init(isModal: Bool = false, initialDate: Date = Date(), onSave: (() -> Void)? = nil) {
        self.isModal = isModal
        self.onSave = onSave
        self._selectedDate = State(initialValue: Calendar.current.startOfDay(for: initialDate))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                headerSection
                EmojiPickerView(selection: $moodSelection)
                reflectionSection
                PhotoGridView(photoData: $photoData, maxPhotos: maxPhotos, maxBytes: maxBytes)
                saveButton
                    .padding(.bottom, 40)
            }
            .padding(.horizontal, 20)
            .padding(.top, isModal ? 28 : 16)
        }
        .background(Color.dsSurface.ignoresSafeArea())
        .onAppear { loadEntry() }
        .overlay(savedBadgeOverlay, alignment: .top)
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            if isModal {
                HStack {
                    Button("Cancel") { dismiss() }
                        .font(.dsLabel)
                        .foregroundStyle(Color.dsOnSurfaceVariant)
                    Spacer()
                }
                .padding(.bottom, 4)
            } else {
                Spacer().frame(height: 60)
            }

            Text(formattedDateLabel)
                .font(.dsCaption)
                .foregroundStyle(Color.dsOnSurfaceVariant)
                .kerning(1.5)

            Text(Calendar.current.isDateInToday(selectedDate) ? "Today's Entry" : "Past Entry")
                .font(.dsHero)
                .foregroundStyle(Color.dsOnSurface)
        }
    }

    private var formattedDateLabel: String {
        let f = DateFormatter()
        f.dateFormat = "EEEE · MMMM d"
        return f.string(from: selectedDate).uppercased()
    }

    // MARK: - Reflection

    private var reflectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Reflection")
                .font(.dsSubtitle)
                .foregroundStyle(Color.dsOnSurface)

            ZStack(alignment: .topLeading) {
                TextEditor(text: $reflection)
                    .font(.dsBody)
                    .foregroundStyle(Color.dsOnSurface)
                    .frame(minHeight: 100, maxHeight: 160)
                    .padding(12)
                    .scrollContentBackground(.hidden)
                    .background(Color.dsSurfaceContainerLow)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .onChange(of: reflection) { _, newVal in
                        if newVal.count > maxReflectionChars {
                            reflection = String(newVal.prefix(maxReflectionChars))
                        }
                    }

                if reflection.isEmpty {
                    Text("What's on your mind today?")
                        .font(.dsBody)
                        .foregroundStyle(Color.dsOnSurfaceVariant)
                        .padding(.top, 20)
                        .padding(.leading, 16)
                        .allowsHitTesting(false)
                }
            }

            HStack {
                Spacer()
                Text("\(reflection.count)/\(maxReflectionChars)")
                    .font(.dsCaption)
                    .foregroundStyle(
                        reflection.count >= maxReflectionChars
                            ? Color.red.opacity(0.6)
                            : Color.dsOnSurfaceVariant
                    )
            }
        }
    }

    // MARK: - Save button

    private var saveButton: some View {
        Button(action: save) {
            Text(existingEntry != nil ? "Update Entry" : "Save Entry")
                .font(.dsSubtitle)
                .foregroundStyle(moodSelection == nil ? Color.dsOnSurfaceVariant : .white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    moodSelection == nil
                        ? AnyShapeStyle(Color.dsSurfaceContainerHigh)
                        : AnyShapeStyle(LinearGradient.dsPrimaryGradient)
                )
                .clipShape(Capsule())
        }
        .disabled(moodSelection == nil)
        .animation(.easeInOut(duration: 0.2), value: moodSelection)
    }

    // MARK: - Saved badge overlay

    @ViewBuilder
    private var savedBadgeOverlay: some View {
        if showSavedBadge {
            Text("✓  Saved")
                .font(.dsLabel)
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.dsPrimary)
                .clipShape(Capsule())
                .padding(.top, 64)
                .transition(.move(edge: .top).combined(with: .opacity))
        }
    }

    // MARK: - Data

    private func loadEntry() {
        let start = DateHelpers.startOfDay(selectedDate)
        let end = Calendar.current.date(byAdding: .day, value: 1, to: start) ?? start
        let descriptor = FetchDescriptor<MoodEntry>(
            predicate: #Predicate { $0.date >= start && $0.date < end }
        )
        existingEntry = try? modelContext.fetch(descriptor).first
        if let entry = existingEntry {
            moodSelection = MoodSelection(
                emoji: entry.moodRaw,
                label: entry.resolvedLabel,
                isPositive: entry.resolvedIsPositive
            )
            reflection = entry.reflection
            photoData = entry.photoData
        }
    }

    private func save() {
        guard let sel = moodSelection else { return }

        if let entry = existingEntry {
            entry.moodRaw = sel.emoji
            entry.moodLabel = sel.label == (MoodType(rawValue: sel.emoji)?.label ?? "") ? "" : sel.label
            entry.moodIsPositive = sel.isPositive
            entry.reflection = reflection
            entry.photoData = photoData
        } else {
            let entry = MoodEntry(
                date: selectedDate,
                mood: MoodType(rawValue: sel.emoji) ?? .neutral,
                reflection: reflection,
                photoData: photoData
            )
            // Override with actual selection in case it's a custom mood
            entry.moodRaw = sel.emoji
            entry.moodLabel = sel.label == (MoodType(rawValue: sel.emoji)?.label ?? "") ? "" : sel.label
            entry.moodIsPositive = sel.isPositive
            modelContext.insert(entry)
            existingEntry = entry
        }

        onSave?()
        if isModal {
            dismiss()
        } else if onSave == nil {
            withAnimation(.spring()) { showSavedBadge = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation { showSavedBadge = false }
            }
        }
    }
}
