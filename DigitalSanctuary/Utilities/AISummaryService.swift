import Foundation

struct AISummaryResult {
    let headline: String       // may contain *italic* markers
    let summary: String
    var generatedAt: Date? = nil
}

enum AISummaryError: Error, LocalizedError {
    case noAPIKey
    case networkError(Error)
    case apiError(String)   // HTTP-level error with message from Anthropic
    case parseError

    var errorDescription: String? {
        switch self {
        case .noAPIKey:           return "No API key configured."
        case .networkError(let e): return "Network error: \(e.localizedDescription)"
        case .apiError(let msg):  return msg
        case .parseError:         return "Unexpected response format from API."
        }
    }
}

struct AISummaryService {

    private static var apiKey: String? {
        let key = Secrets.anthropicAPIKey
        return key.isEmpty || key == "YOUR_ANTHROPIC_API_KEY_HERE" ? nil : key
    }

    // Cache key format: "ai_summary_YYYY_MM"
    static func cacheKey(for month: Date) -> String {
        let cal = Calendar.current
        let y = cal.component(.year, from: month)
        let m = cal.component(.month, from: month)
        return "ai_summary_\(y)_\(m)"
    }

    static func cachedResult(for month: Date) -> AISummaryResult? {
        let key = cacheKey(for: month)
        guard let headline = UserDefaults.standard.string(forKey: "\(key)_headline"),
              let summary = UserDefaults.standard.string(forKey: "\(key)_summary")
        else { return nil }
        let generatedAt = UserDefaults.standard.object(forKey: "\(key)_date") as? Date
        return AISummaryResult(headline: headline, summary: summary, generatedAt: generatedAt)
    }

    static func cache(_ result: AISummaryResult, for month: Date) {
        let key = cacheKey(for: month)
        UserDefaults.standard.set(result.headline, forKey: "\(key)_headline")
        UserDefaults.standard.set(result.summary, forKey: "\(key)_summary")
        UserDefaults.standard.set(Date(), forKey: "\(key)_date")
    }

    static func clearCache(for month: Date) {
        let key = cacheKey(for: month)
        UserDefaults.standard.removeObject(forKey: "\(key)_headline")
        UserDefaults.standard.removeObject(forKey: "\(key)_summary")
        UserDefaults.standard.removeObject(forKey: "\(key)_date")
    }

    static func generate(entries: [MoodEntry], month: Date) async throws -> AISummaryResult {
        guard let apiKey = apiKey else {
            throw AISummaryError.noAPIKey
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        let monthName = formatter.string(from: month)

        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEEE MMM d"
        let entryLines = entries.map { e in
            let day = dayFormatter.string(from: e.date)
            let mood = "\(e.moodRaw) \(e.resolvedLabel)"
            let note = e.reflection.isEmpty ? "" : " — \"\(e.reflection.prefix(80))\""
            return "• \(day): \(mood)\(note)"
        }.joined(separator: "\n")

        let positiveCount = entries.filter { $0.resolvedIsPositive }.count
        let total = entries.count

        let prompt = """
        You are a compassionate wellness journal companion. Craft a warm, poetic monthly reflection based on this person's mood log for \(monthName).

        Mood entries:
        \(entryLines)

        Positive days: \(positiveCount) of \(total)

        Write:
        1. A short evocative HEADLINE (5–7 words). Wrap the most poetic 2–3 words in *asterisks* so they can be italicised. Example: "Finding light in the *ebb and flow*."
        2. A SUMMARY paragraph (2–4 sentences). Warm, personal, and specific to their data. End with one word in the primary accent color wrapped in **double asterisks**. Offer gentle encouragement.

        Reply ONLY with valid JSON, no markdown fencing:
        {"headline":"...","summary":"..."}
        """

        var request = URLRequest(url: URL(string: "https://api.anthropic.com/v1/messages")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")

        let body: [String: Any] = [
            "model": "claude-haiku-4-5-20251001",
            "max_tokens": 400,
            "messages": [["role": "user", "content": prompt]]
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        let data: Data
        let httpResponse: URLResponse
        do {
            (data, httpResponse) = try await URLSession.shared.data(for: request)
        } catch {
            throw AISummaryError.networkError(error)
        }

        // Surface HTTP-level errors (rate limit, auth, etc.) with the actual message
        if let http = httpResponse as? HTTPURLResponse, http.statusCode != 200 {
            struct APIError: Codable {
                struct Detail: Codable { let type: String; let message: String }
                let error: Detail?
            }
            let msg = (try? JSONDecoder().decode(APIError.self, from: data))?.error?.message
                ?? "HTTP \(http.statusCode)"
            throw AISummaryError.apiError(msg)
        }

        struct AnthropicResponse: Codable {
            struct Content: Codable { let text: String }
            let content: [Content]
        }

        guard let response = try? JSONDecoder().decode(AnthropicResponse.self, from: data),
              let rawText = response.content.first?.text
        else {
            throw AISummaryError.parseError
        }

        // Strip markdown code fences the model sometimes adds despite instructions
        var text = rawText.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.hasPrefix("```") {
            text = text
                .components(separatedBy: "\n")
                .dropFirst()          // drop ```json line
                .joined(separator: "\n")
            if let fenceEnd = text.lastIndex(of: "`") {
                text = String(text[text.startIndex..<fenceEnd])
                    .trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }

        guard let jsonData = text.data(using: .utf8),
              let parsed = try? JSONDecoder().decode([String: String].self, from: jsonData),
              let headline = parsed["headline"],
              let summary = parsed["summary"]
        else {
            throw AISummaryError.parseError
        }

        let result = AISummaryResult(headline: headline, summary: summary)
        cache(result, for: month)
        return result
    }
}
