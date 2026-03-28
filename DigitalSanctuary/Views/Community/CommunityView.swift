import SwiftUI
import SwiftData

struct CommunityView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CommunityMessage.createdAt) private var messages: [CommunityMessage]
    @Query(sort: \MoodEntry.date, order: .reverse) private var recentEntries: [MoodEntry]

    @State private var showAdd = false

    private var currentMoodEmoji: String? {
        recentEntries.first?.moodRaw
    }

    private var alignedLabel: String {
        recentEntries.first?.resolvedLabel ?? "your mood"
    }

    // Messages aligned to current mood shown first, then the rest
    private var sortedMessages: [CommunityMessage] {
        guard let emoji = currentMoodEmoji else { return messages }
        let aligned = messages.filter { $0.moodTags.contains(emoji) }
        let others = messages.filter { !$0.moodTags.contains(emoji) }
        return aligned + others
    }

    private var totalThisWeek: Int {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        return messages.filter { $0.createdAt >= weekAgo }.count + 4280
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                headerSection
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)

                if let emoji = currentMoodEmoji {
                    alignedChip(emoji: emoji)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                }

                LazyVStack(spacing: 16) {
                    addPromptCard

                    ForEach(sortedMessages) { msg in
                        messageCard(msg)
                    }

                    collectivePeaceCard
                }
                .padding(.horizontal, 20)

                Spacer(minLength: 100)
            }
        }
        .background(Color.dsSurface.ignoresSafeArea())
        .onAppear { seedIfNeeded() }
        .sheet(isPresented: $showAdd) {
            AddMessageView()
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Spacer().frame(height: 20)
            Text("COMMUNITY")
                .font(.dsCaption)
                .foregroundStyle(Color.dsOnSurfaceVariant)
                .kerning(1.5)
            Text("Sanctuary\nEchoes.")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(Color.dsOnSurface)
                .lineSpacing(2)
            Text("Gentle reminders from fellow travelers.\nYou are seen, even in the silence.")
                .font(.dsBody)
                .foregroundStyle(Color.dsOnSurfaceVariant)
                .lineSpacing(4)
                .padding(.top, 4)
        }
    }

    // MARK: - Aligned chip

    private func alignedChip(emoji: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "sparkles")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(Color.dsPrimary)
            Text("Aligned with your \(alignedLabel.lowercased()) mood")
                .font(.dsCaption)
                .foregroundStyle(Color.dsPrimary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Color.dsPrimaryContainer.opacity(0.35))
        .clipShape(Capsule())
    }

    // MARK: - Message card

    private func messageCard(_ msg: CommunityMessage) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("❝")
                .font(.system(size: 28, weight: .bold, design: .serif))
                .foregroundStyle(Color.dsSurfaceContainerHigh)
                .padding(.bottom, -8)

            Text("\"\(msg.text)\"")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.dsOnSurface)
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)

            HStack {
                Text(msg.author.uppercased())
                    .font(.dsCaption)
                    .foregroundStyle(Color.dsOnSurfaceVariant)
                    .kerning(0.8)

                Spacer()

                Button {
                    msg.isLikedByUser.toggle()
                    msg.likeCount += msg.isLikedByUser ? 1 : -1
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: msg.isLikedByUser ? "heart.fill" : "heart")
                            .font(.system(size: 14))
                            .foregroundStyle(msg.isLikedByUser ? Color.dsPrimary : Color.dsOnSurfaceVariant)
                        Text("\(msg.likeCount)")
                            .font(.dsCaption)
                            .foregroundStyle(msg.isLikedByUser ? Color.dsPrimary : Color.dsOnSurfaceVariant)
                    }
                }
                .buttonStyle(.plain)
                .animation(.spring(response: 0.25), value: msg.isLikedByUser)
            }
        }
        .padding(20)
        .background(Color.dsSurfaceContainerLowest)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.03), radius: 6, x: 0, y: 2)
    }

    // MARK: - Collective peace card

    private var collectivePeaceCard: some View {
        VStack(spacing: 10) {
            Image(systemName: "cloud.fill")
                .font(.system(size: 32))
                .foregroundStyle(Color.dsPrimary.opacity(0.7))

            Text("The Collective Peace")
                .font(.dsSubtitle)
                .foregroundStyle(Color.dsOnPrimaryFixed)

            Text("\(totalThisWeek.formatted()) messages shared this week by people seeking calm just like you.")
                .font(.dsBody)
                .foregroundStyle(Color.dsOnPrimaryFixed.opacity(0.7))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [Color.dsSecondaryContainer, Color.dsPrimaryContainer.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Add prompt card

    private var addPromptCard: some View {
        Button { showAdd = true } label: {
            HStack(spacing: 14) {
                Image(systemName: "pencil.line")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(Color.dsPrimary.opacity(0.7))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Share a gentle word")
                        .font(.dsLabel)
                        .foregroundStyle(Color.dsOnSurface)
                    Text("Tap to leave an anonymous message for someone who needs it today")
                        .font(.dsCaption)
                        .foregroundStyle(Color.dsOnSurfaceVariant)
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
                Image(systemName: "plus.circle")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(Color.dsPrimary)
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(
                        Color.dsPrimary.opacity(0.35),
                        style: StrokeStyle(lineWidth: 1.5, dash: [6, 4])
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Seed

    private func seedIfNeeded() {
        guard messages.isEmpty else { return }
        for seed in CommunityMessage.seeds {
            modelContext.insert(CommunityMessage(
                text: seed.text,
                author: seed.author,
                likeCount: seed.likes,
                moodTags: seed.tags
            ))
        }
    }
}
