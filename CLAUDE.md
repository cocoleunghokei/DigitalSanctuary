# DigitalSanctuary — CLAUDE.md

## Project Overview

DigitalSanctuary is a personal mood-tracking iOS app built with SwiftUI and SwiftData. Users log daily moods (with emoji), write reflections, and attach photos. The app surfaces insights via monthly calendar, weekly summaries, an AI-generated narrative arc, and a community encouragement feed.

---

## Tech Stack

| Layer | Technology |
|---|---|
| UI | SwiftUI (iOS 17+) |
| Persistence | SwiftData (`@Model`, `@Query`) |
| AI summary | Anthropic API via `URLSession` (no SDK) |
| Photos | `PhotosUI` (`PhotosPicker`) |
| Emoji keyboard | `UIViewRepresentable` wrapping `UITextField` |
| Architecture | Single `WindowGroup`, tab-based navigation via `AppTab` enum |

---

## Project Structure

```
DigitalSanctuary/
├── DigitalSanctuaryApp.swift      # @main, .modelContainer([MoodEntry, CustomMood, CommunityMessage])
├── ContentView.swift              # Root ZStack: tab content + BottomNavBar + FAB
│
├── Models/
│   ├── MoodEntry.swift            # Core journal entry (@Model)
│   ├── MoodType.swift             # Built-in mood enum + MoodSelection struct
│   ├── CustomMood.swift           # User-created mood (@Model)
│   └── CommunityMessage.swift     # Sanctuary Echoes messages (@Model)
│
├── Views/
│   ├── Daily/
│   │   ├── DailyView.swift        # Entry form — mood, reflection, photos
│   │   ├── EmojiPickerView.swift  # Built-in + custom moods + Add button
│   │   ├── CustomMoodCreatorView.swift  # Emoji keyboard + label + sentiment
│   │   └── PhotoGridView.swift
│   ├── Monthly/
│   │   ├── MonthlyView.swift      # Scroll: header → nav → calendar → cloud → trend → AI → quote
│   │   ├── CalendarGridView.swift # 7-col grid, long-press quick picker
│   │   ├── AIMonthlySummaryView.swift  # Narrative arc card
│   │   ├── MoodCloudView.swift
│   │   └── MonthlyTrendView.swift
│   ├── Weekly/
│   │   ├── WeeklyView.swift
│   │   ├── DayCardView.swift
│   │   ├── WeeklySummaryCard.swift
│   │   └── ReflectionListView.swift
│   ├── Community/
│   │   ├── CommunityView.swift    # Sanctuary Echoes feed
│   │   └── AddMessageView.swift
│   └── Components/
│       ├── BottomNavBar.swift     # AppTab enum lives here
│       ├── FABButton.swift        # Sticky new-entry button
│       ├── MoodChipView.swift     # emoji + label chip (used in picker)
│       └── QuickMoodPickerView.swift  # Long-press calendar overlay
│
├── DesignSystem/
│   ├── Colors.swift               # All ds* color tokens + gradients
│   ├── Typography.swift           # All ds* font tokens
│   └── ViewModifiers.swift        # .sanctuaryCard(), .glassmorphic(), .gradientCard()
│
└── Utilities/
    ├── DateHelpers.swift
    ├── WeeklySummaryGenerator.swift
    ├── QuoteProvider.swift
    └── AISummaryService.swift     # Anthropic API + UserDefaults cache
```

---

## Data Models

### `MoodEntry` — the core unit
```swift
moodRaw: String          // emoji string (e.g. "😊") — always the source of truth
moodLabel: String        // "" for built-in moods; non-empty for custom moods
moodIsPositive: Bool     // only meaningful when moodLabel is non-empty
reflection: String
photoData: [Data]        // @Attribute(.externalStorage)
```

Computed helpers — always prefer these over `mood.emoji` / `mood.label`:
- `resolvedEmoji` → `moodRaw`
- `resolvedLabel` → falls back to `MoodType.label` if `moodLabel` is empty
- `resolvedIsPositive` → falls back to `MoodType.isPositive` if `moodLabel` is empty
- `mood: MoodType` → legacy computed property, returns `.neutral` for custom moods

**Rule**: never use `entry.mood.emoji` or `entry.mood.label` in display code — use `entry.moodRaw` and `entry.resolvedLabel` instead.

### `MoodSelection` — transient selection type
Used in `DailyView` and `EmojiPickerView` to carry a mood selection (built-in or custom) without coupling to `MoodType` enum:
```swift
struct MoodSelection: Equatable {
    let emoji: String
    let label: String
    let isPositive: Bool
}
```
Create with `MoodSelection.from(_ mood: MoodType)` or `MoodSelection.from(_ custom: CustomMood)`.

### `CustomMood`
User-created moods with `emoji`, `label`, `isPositive`. Sentiment is auto-inferred via `CustomMood.inferIsPositive(for:)` (lookup table of known negative emojis).

### `CommunityMessage`
Pre-seeded and user-created encouragement messages. `moodTags: [String]` contains emoji strings — messages whose tags include the user's current `moodRaw` are shown first in `CommunityView`.

---

## Navigation

`AppTab` enum (in `BottomNavBar.swift`): `.monthly`, `.weekly`, `.daily`, `.community`

- Default tab on launch: `.monthly`
- Tapping a calendar/week day → sets `previousTab`, navigates to `.daily`
- Saving from `.daily` (reached via day-tap) → navigates back to `previousTab`
- FAB (`+` button) is always visible in `ContentView`'s ZStack overlay, on every tab
- `.daily` opened from FAB uses `isModal: true` and `dismiss()` on save

---

## Design System

All tokens live in `DesignSystem/`. Never use raw hex values or system fonts in views.

### Colors (prefix `ds`)
```swift
Color.dsPrimary              // #24667f — teal, main accent
Color.dsPrimaryContainer     // #a3e0fc — light blue, selected states
Color.dsPrimaryDim           // #125a72 — darker accent
Color.dsSurface              // #f8f9fa — page background
Color.dsSurfaceContainerLow  // #f1f4f5 — card/input backgrounds
Color.dsSurfaceContainerLowest // #ffffff
Color.dsSurfaceContainerHigh // #e5e9eb
Color.dsOnSurface            // #2d3335 — primary text
Color.dsOnSurfaceVariant     // #5a6062 — secondary text
```

### Gradients
```swift
LinearGradient.dsPrimaryGradient    // teal → light blue, used on buttons/FAB
LinearGradient.dsMoodCloudGradient  // green → blue, mood cloud card
```

### Typography (prefix `ds`)
```swift
.dsHero      // 34pt bold rounded — page titles
.dsTitle     // 22pt bold rounded
.dsSubtitle  // 17pt semibold rounded — section headers, button labels
.dsBody      // 15pt regular
.dsLabel     // 13pt medium
.dsCaption   // 11pt semibold — section labels (use with .kerning(1.5) for ALL-CAPS labels)
.dsMoodEmoji // 28pt — emoji in chips
```

### View modifiers
```swift
.sanctuaryCard()                   // white card with soft shadow
.sanctuaryCard(background:, cornerRadius:)
.glassmorphic()                    // frosted glass (nav bar)
.gradientCard(gradient:, cornerRadius:)
```

---

## Key Patterns

### Long-press quick mood picker (CalendarGridView)
Uses a **single `DragGesture(minimumDistance: 0)` + `Timer`** per cell — not `LongPressGesture.sequenced`. This avoids tap/long-press gesture conflicts:
- Timer fires after 0.45s → show `QuickMoodPickerView`
- Quick lift before timer → navigate (tap)
- Drag >8pt before timer → cancel (scroll)
- Lift after long press → commit hovered mood, dismiss

### AI Summary (AISummaryService)
- API key stored in `UserDefaults` under `"ds_anthropic_api_key"`
- Results cached per month: `"ai_summary_{year}_{month}_headline"` / `"_summary"`
- Call `AISummaryService.clearCache(for:)` to force regeneration
- Model: `claude-haiku-4-5-20251001`, max 400 tokens
- Response format: `{"headline": "...*italic*...", "summary": "...**accent**..."}`
- `*asterisks*` in headline → italic + primary color in `AIMonthlySummaryView`
- `**double asterisks**` in summary → primary color text

### Community messages seeding
`CommunityView.seedIfNeeded()` seeds 10 messages on first open (checks `messages.isEmpty`). Do not re-seed.

---

## Common Mistakes to Avoid

1. **Don't use `entry.mood.emoji`** — use `entry.moodRaw`. The `mood` computed property returns `.neutral` for custom moods.
2. **Don't use `entry.mood.label`** — use `entry.resolvedLabel`.
3. **Don't use `entry.mood.isPositive`** — use `entry.resolvedIsPositive`.
4. **Don't add `LongPressGesture` to calendar cells** — the timer+DragGesture pattern in `CalendarGridView` is intentional and handles tap/long-press/scroll correctly.
5. **Don't pass `MoodType?` through `EmojiPickerView`** — use `Binding<MoodSelection?>`.
6. **Don't modify `DigitalSanctuaryApp.swift` model container** without adding all three models: `[MoodEntry.self, CustomMood.self, CommunityMessage.self]`.
7. **Don't access `AISummaryService.storedAPIKey` without nil-checking** — it's optional and may not be set.
8. **Don't hardcode colors or fonts** — use design system tokens exclusively.

---

## Adding a New Tab

1. Add a case to `AppTab` in `Views/Components/BottomNavBar.swift`
2. Add the `label` and `icon` (SF Symbol name) for the new case
3. Add the view case in `ContentView.swift`'s `switch activeTab`
4. The FAB is already visible on all tabs — no changes needed

## Adding a New Built-in Mood

1. Add a case to `MoodType` enum in `Models/MoodType.swift` with an emoji rawValue
2. Add the `label`, `isLow`, and `isPositive` switch cases
3. Add a matching entry to `WeeklySummaryGenerator.generate` switch
4. `MoodType.allCases` automatically picks it up everywhere else

---

## API Notes

- Anthropic base URL: `https://api.anthropic.com/v1/messages`
- Required headers: `x-api-key`, `anthropic-version: 2023-06-01`, `content-type: application/json`
- Preferred model for summaries: `claude-haiku-4-5-20251001` (fast, cheap, good for short creative text)
- Always wrap API calls in `Task {}` and handle `AISummaryError.noAPIKey` separately (shows setup UI, not an error)
