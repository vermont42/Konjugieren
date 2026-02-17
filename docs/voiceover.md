# VoiceOver and Mixed-Language Pronunciation

This app has German and English content side by side. VoiceOver pronunciation is controlled by `.germanPronunciation()` and `.englishPronunciation()` — custom modifiers in `Modifiers.swift` that wrap `.environment(\.locale)`.

## What Works and What Doesn't

| Approach | Works? | Notes |
|----------|--------|-------|
| `.environment(\.locale)` on a view | Yes | VoiceOver pronounces that element in the specified locale |
| `.germanPronunciation()` on a parent, `Text(verbatim:)` children | Yes | Children inherit the parent's locale |
| Per-child `.environment(\.locale)` inside `NavigationLink` or `Button` | **No** | The link/button flattens children into one element; only the container's locale applies |
| `.accessibilityElement(children: .contain)` on `NavigationLink` | **No** | Silently ignored — NavigationLink always flattens |
| `NSAttributedString.Key.accessibilitySpeechLanguage` → `AttributedString` | **No** | The attribute is stripped during the NSAttributedString → AttributedString conversion |
| `Text("a") + Text("b")` with different locales | **No** | Concatenation produces one `Text` element — one locale wins |

## Pattern: Separate VoiceOver Elements in List Rows

To get per-element pronunciation in a list row, **do not use NavigationLink**. Instead, use programmatic `NavigationPath` navigation:

```swift
// In the parent view:
@State private var navigationPath = NavigationPath()

NavigationStack(path: $navigationPath) {
  ForEach(items) { item in
    RowView(item: item) { navigationPath.append(item) }
  }
  .navigationDestination(for: Item.self) { item in
    DetailView(item: item)
  }
}

// In the row view:
struct RowView: View {
  let item: Item
  let navigate: () -> Void

  var body: some View {
    HStack {
      Text(verbatim: item.germanName)
        .germanPronunciation()
        .accessibilityAddTraits(.isButton)
        .accessibilityAction { navigate() }
      Text(verbatim: item.englishName)
        .englishPronunciation()
        .accessibilityAddTraits(.isButton)
        .accessibilityAction { navigate() }
    }
    .contentShape(Rectangle())
    .onTapGesture { navigate() }
  }
}
```

Key elements: `.onTapGesture` handles the visual tap; `.accessibilityAction` handles VoiceOver double-tap; `.accessibilityAddTraits(.isButton)` tells VoiceOver each element is activatable.

## Pattern: Mixed-Language Label/Value Pairs

For lines like "Verb: reagieren" where the label is English and the value is German, use an `HStack` with `.fixedSize(horizontal: true, vertical: false)` on the label to prevent it from compressing:

```swift
HStack(alignment: .top, spacing: 0) {
  Text(L.Quiz.verb + " ")
    .foregroundStyle(.customYellow)
    .fixedSize(horizontal: true, vertical: false)
    .englishPronunciation()
  Text(verbatim: question.verb.infinitiv)
    .foregroundStyle(.customForeground)
    .germanPronunciation()
}
```

The `.fixedSize` on the label prevents the wrapping problem where `HStack` would compress the label to give the value more room. The label takes its full intrinsic width; the value wraps in the remaining space.

## Current Pronunciation Strategy by Screen

| Screen | Approach | Why |
|--------|----------|-----|
| VerbBrowseView | Programmatic `NavigationPath` | Three separate elements: German verb, English translation, English family |
| VerbView (conjugation rows) | `.germanPronunciation()` on parent VStack | All content is German; combining is fine |
| VerbView (metadata) | Per-label locale | Each Label is its own element |
| QuizView (bilingual lines) | HStack with `.fixedSize` labels | Label in English, value in German |
| QuizView (English-only lines) | Single `Text` with `.englishPronunciation()` | Progress, Score, Elapsed are all English |
| InfoBrowseView | Programmatic `NavigationPath` | German heading and English preview as separate elements |
| ResultsView | Per-element `.germanPronunciation()` | Not inside NavigationLink, so per-element locale works directly |
