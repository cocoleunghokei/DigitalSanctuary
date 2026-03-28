import SwiftUI

struct AIMonthlySummaryView: View {
    let entries: [MoodEntry]
    let month: Date

    @State private var state: ViewState = .idle

    private enum ViewState {
        case idle
        case loading
        case loaded(AISummaryResult)
        case error(String)
        case noKey
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader

            switch state {
            case .idle:
                EmptyView()
            case .loading:
                loadingCard
            case .loaded(let result):
                loadedCard(result)
            case .error(let msg):
                errorCard(msg)
            case .noKey:
                noKeyCard
            }
        }
        .onAppear { loadIfNeeded() }
        .onChange(of: month) { _, _ in state = .idle; loadIfNeeded() }
        .onChange(of: entries.count) { _, count in
            if count > 0, case .idle = state { loadIfNeeded() }
        }
    }

    // MARK: - Section header

    private var sectionHeader: some View {
        Text("YOUR NARRATIVE ARC")
            .font(.dsCaption)
            .foregroundStyle(Color.dsOnSurfaceVariant)
            .kerning(1.5)
            .padding(.bottom, 10)
    }

    // MARK: - Loaded card

    private func loadedCard(_ result: AISummaryResult) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            headlineText(result.headline)
                .padding(.bottom, 4)

            VStack(alignment: .leading, spacing: 16) {
                summaryText(result.summary)

                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.dsPrimary)
                        .frame(width: 6, height: 6)
                    Text("AI-Generated Reflection")
                        .font(.dsCaption)
                        .foregroundStyle(Color.dsPrimary)

                    Spacer()

                    Button {
                        AISummaryService.clearCache(for: month)
                        refresh()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color.dsOnSurfaceVariant)
                    }
                }
            }
            .padding(20)
            .background(
                ZStack(alignment: .top) {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.dsSurfaceContainerLowest)
                    LinearGradient(
                        colors: [Color.dsSecondaryContainer.opacity(0.45), Color.clear],
                        startPoint: .top, endPoint: .center
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }
            )
            .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
        }
    }

    // MARK: - Headline text with *italic* parsing

    private func headlineText(_ raw: String) -> some View {
        let (regular, italic) = parseHeadline(raw)
        return Group {
            Text(regular)
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(Color.dsOnSurface)
            + Text(italic)
                .font(.system(size: 30, weight: .bold, design: .serif).italic())
                .foregroundStyle(Color.dsPrimary)
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    private func parseHeadline(_ text: String) -> (regular: String, italic: String) {
        // Find first *...* pair
        var chars = text
        if let starStart = chars.range(of: "*"),
           let starEnd = chars.range(of: "*", range: starStart.upperBound..<chars.endIndex) {
            let regular = String(chars[chars.startIndex..<starStart.lowerBound])
            let italic = String(chars[starStart.upperBound..<starEnd.lowerBound])
            let after = String(chars[starEnd.upperBound...])
            return (regular + after.replacingOccurrences(of: ".", with: "") + ".", italic)
        }
        return (text, "")
    }

    // MARK: - Summary text with **accent** parsing

    private func summaryText(_ raw: String) -> some View {
        // Parse **word** → accent colored
        let parts = parseSummary(raw)
        var result = Text("")
        for part in parts {
            if part.isAccent {
                result = result + Text(part.text)
                    .foregroundStyle(Color.dsPrimary)
                    .fontWeight(.medium)
            } else {
                result = result + Text(part.text)
                    .foregroundStyle(Color.dsOnSurface)
            }
        }
        return result
            .font(.system(size: 17, weight: .regular))
            .lineSpacing(6)
            .fixedSize(horizontal: false, vertical: true)
    }

    private struct TextPart { let text: String; let isAccent: Bool }

    private func parseSummary(_ text: String) -> [TextPart] {
        var parts: [TextPart] = []
        var remaining = text
        while !remaining.isEmpty {
            if let start = remaining.range(of: "**"),
               let end = remaining.range(of: "**", range: start.upperBound..<remaining.endIndex) {
                let before = String(remaining[remaining.startIndex..<start.lowerBound])
                let accent = String(remaining[start.upperBound..<end.lowerBound])
                if !before.isEmpty { parts.append(TextPart(text: before, isAccent: false)) }
                if !accent.isEmpty { parts.append(TextPart(text: accent, isAccent: true)) }
                remaining = String(remaining[end.upperBound...])
            } else {
                parts.append(TextPart(text: remaining, isAccent: false))
                break
            }
        }
        return parts
    }

    // MARK: - Loading card

    private var loadingCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                ProgressView()
                    .scaleEffect(0.8)
                Text("Composing your narrative arc…")
                    .font(.dsBody)
                    .foregroundStyle(Color.dsOnSurfaceVariant)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.dsSurfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - No key card

    private var noKeyCard: some View {
        EmptyView()
    }

    // MARK: - Error card

    private func errorCard(_ message: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Couldn't generate summary")
                .font(.dsLabel)
                .foregroundStyle(Color.dsOnSurface)
            Text(message)
                .font(.dsCaption)
                .foregroundStyle(Color.dsOnSurfaceVariant)
            Button { refresh() } label: {
                Text("Try Again")
                    .font(.dsCaption)
                    .foregroundStyle(Color.dsPrimary)
            }
            .buttonStyle(.plain)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.dsSurfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Load logic

    private func loadIfNeeded() {
        guard !entries.isEmpty else { return }

        // Check cache
        if let cached = AISummaryService.cachedResult(for: month) {
            state = .loaded(cached)
            return
        }

        generate()
    }

    private func refresh() {
        guard !entries.isEmpty else { return }
        if let cached = AISummaryService.cachedResult(for: month) {
            state = .loaded(cached)
            return
        }
        generate()
    }

    private func generate() {
        if case .loading = state { return }
        state = .loading
        Task {
            do {
                let result = try await AISummaryService.generate(entries: entries, month: month)
                await MainActor.run { state = .loaded(result) }
            } catch AISummaryError.noAPIKey {
                await MainActor.run { state = .noKey }
            } catch let e as AISummaryError {
                await MainActor.run { state = .error(e.errorDescription ?? e.localizedDescription) }
            } catch {
                await MainActor.run { state = .error(error.localizedDescription) }
            }
        }
    }
}
