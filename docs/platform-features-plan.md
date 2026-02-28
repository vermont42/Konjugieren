# High-Impact Platform Features for Konjugieren

## Context

Konjugieren already adopts many platform features that Apple values for App Store featuring: dark mode, Dynamic Type, localization (EN/DE), alternate icons, Game Center, VoiceOver accessibility, deep linking, text-to-speech, and a privacy manifest. This plan identifies additional high-impact features — ordered by likely editorial weight — that could delight users and catch the attention of Apple's App Store editorial team.

The recommendations draw from Apple's official featuring criteria, Design Award patterns, WWDC 2024–2025 sessions, and the Cupertino documentation index.

---

## Tier 1: Strongest Featuring Signals

### 1. Foundation Models Framework (iOS 26+) - DONE

**Why it matters:** Apple explicitly showcased **Grammo** — a grammar-learning app — as a Foundation Models exemplar. A German conjugation app using on-device AI is a near-perfect editorial pitch. The model is free, on-device, offline-capable, privacy-preserving, and multilingual (German is supported).

**Concrete features for Konjugieren:**
- **Conjugation-error explainer:** When a quiz answer is wrong, generate a brief, personalized explanation of *why* — e.g., "singen is a strong verb with an i→a ablaut in Präteritum, so it becomes *sang*, not *singte*."
- **Conversational verb tutor:** A chat-style view where users ask questions like "When do I use Konjunktiv II?" and get concise, on-device answers.
- **Personalized practice recommendations:** Analyze quiz-error patterns and suggest which conjugationgroups or verb families to practice next.
- **Structured output via `@Generable`:** Use guided generation to produce structured conjugation hints, making responses reliable and type-safe.

**Key APIs:** `FoundationModels`, `LanguageModelSession`, `@Generable`, `@Guide`
**Availability:** iOS 26.0+

---

### 2. App Intents / Siri / Spotlight Integration (iOS 16+)

**Why it matters:** Apple has invested in App Intents across three consecutive WWDCs (2023–2025). It enables Siri, Spotlight, Shortcuts, and Action button integration — all from one framework. Educational apps with App Intents stand out because few adopt them.

**Concrete features for Konjugieren:**
- **Siri voice interaction:** "Hey Siri, conjugate *gehen* in Präteritum" → returns the conjugation table or speaks it aloud.
- **Spotlight indexing of verbs:** Typing "konjugieren singen" in Spotlight surfaces the verb directly, with a tap navigating into the app.
- **App Shortcuts (zero-config):** Pre-configured shortcuts like "Start a quiz" or "Show a random verb" available from the moment of install.
- **Action button mapping:** Users can assign "Quick Quiz" to the Action button for instant launch.
- **App Entities for verbs:** Expose `Verb` as an `AppEntity` so the system can resolve verb names in Siri queries and Shortcuts parameters.

**Key APIs:** `AppIntents`, `AppShortcut`, `AppEntity`, `IndexedEntity`
**Availability:** iOS 16.0+ (enhanced in iOS 18 with Apple Intelligence)

---

### 3. Home Screen & Lock Screen Widgets (iOS 14+ / iOS 16+)

**Why it matters:** Widgets keep your app visible between sessions. Language-learning widgets (verb of the day, practice reminders) have proven popular in the category. Apple features widget-rich apps frequently.

**Concrete features for Konjugieren:**
- **"Verb des Tages" widget (small/medium):** Shows a daily verb with one highlighted conjugation and ablaut markup.
- **Medium widget:** A verb with its full Präsens paradigm (ich/du/er/wir/ihr/sie).
- **Lock Screen accessory widget:** Compact daily-verb reminder (verb + translation).
- **Interactive widget (iOS 17+):** A mini-quiz question directly on the Home Screen — tap the correct conjugation without opening the app.

**Key APIs:** `WidgetKit`, `TimelineProvider`, `WidgetFamily`, `AppIntentTimelineProvider` (for interactive widgets)
**Availability:** iOS 14.0+ (interactive: iOS 17.0+, Lock Screen: iOS 16.0+)

---

## Tier 2: High Impact

### 4. Control Center Controls (iOS 18+)

**Why it matters:** Under-adopted by educational apps, making it a differentiator. Lets users launch app actions from Control Center, the Lock Screen, or the Action button.

**Concrete features:**
- **"Quick Quiz" button:** Launches directly into a quiz from Control Center.
- **"Random Verb" button:** Opens a random verb detail view.

**Key APIs:** `ControlWidget`, `ControlWidgetButton`
**Availability:** iOS 18.0+

---

### 5. Live Activities / Dynamic Island (iOS 16.1+)

**Why it matters:** Provides at-a-glance information on the Lock Screen and Dynamic Island during active sessions.

**Concrete features:**
- **Quiz session tracker:** Shows current score, question progress (e.g., "15/30"), and timer on the Lock Screen and Dynamic Island while a quiz is in progress.
- **Game session display:** Shows current wave and score during an active game.

**Key APIs:** `ActivityKit`, `Activity<Attributes>`
**Availability:** iOS 16.1+

---

### 6. TipKit (iOS 17+) - DONE

**Why it matters:** Apple's native feature-discovery framework. Low implementation effort, high polish signal. Shows contextual tips that educate users about features they haven't discovered yet.

**Concrete features:**
- **"Try the Quiz" tip** on the Verbs tab for new users.
- **"Change Difficulty" tip** after a user's first quiz completion.
- **"Explore Verb Families" tip** on the Families tab.
- **"Play the Game" tip** pointing to the game entry point.

**Key APIs:** `TipKit`, `Tip`, `TipView`, `Tips.ConfigurationOption`
**Availability:** iOS 17.0+

---

### 7. Haptic Feedback (CoreHaptics / UIFeedbackGenerator) - DONE

**Why it matters:** Tactile feedback during quiz interactions and game events adds polish and delight. Simple to implement, meaningful impact on perceived quality. The game already has haptics via a private `haptic()` method in `GameState` — but it doesn't respect the audioFeedback setting, and the quiz has no haptics at all.

**Concrete features:**
- **Quiz correct/incorrect:** Success/error haptics on answer submission.
- **Quiz start/completion:** Medium impact on start, success on completion.
- **Game events:** Already present — just needs to respect the audioFeedback setting.
- **GameState fix:** Add `guard Current.settings.audioFeedback == .enable` to the existing `haptic()` method.

**Key APIs:** `UIImpactFeedbackGenerator`, `UINotificationFeedbackGenerator`, `UISelectionFeedbackGenerator`
**Availability:** iOS 10.0+

---

## Tier 3: Differentiators

### 8. In-App Events (App Store Connect)

**Why it matters:** Free editorial visibility — In-App Events appear in App Store search results and the Today tab. No code changes required; configured entirely in App Store Connect.

**Concrete events:**
- "New Verb Family Added" when verb count milestones are reached.
- "Deutsche Sprachwoche" (German Language Week) seasonal challenge.
- "1,000 Verbs Challenge" when the full verb list is complete.

---

### 9. Liquid Glass (iOS 26) - DONE

**Why it matters:** The biggest visual redesign since iOS 7. SwiftUI apps compiled with the iOS 26 SDK get Liquid Glass styling on navigation bars, tab bars, and toolbars largely for free. Actively embracing it (rather than fighting it) signals platform alignment.

**Action:** Recompile with Xcode 26 SDK and verify that Konjugieren's UI looks polished with the new glass materials. Adjust custom styling as needed.

---

### 10. NSUserActivity / Handoff - DONE

**Why it matters:** Lets users start studying on one device and continue on another. The existing deep-link scheme (`konjugieren://`) provides the foundation; `NSUserActivity` extends it to cross-device continuity.

**Concrete feature:** Viewing a verb on iPhone → pick up on iPad (or vice versa) at the same verb detail view.

**Key APIs:** `NSUserActivity`, `.userActivity()`, `.onContinueUserActivity()`
**Availability:** iOS 8.0+

---

## Implementation Priority (Recommended Order)

| Priority | Feature | Effort | Impact |
|----------|---------|--------|--------|
| 1 | Haptic Feedback | Low | Medium |
| 2 | TipKit | Low | Medium |
| 3 | App Intents + Spotlight | Medium | High |
| 4 | Widgets (Home + Lock Screen) | Medium | High |
| 5 | Control Center Controls | Low–Medium | Medium |
| 6 | Foundation Models | Medium–High | Very High |
| 7 | Live Activities | Medium | Medium |
| 8 | In-App Events | None (ASC only) | Medium |
| 9 | Liquid Glass verification | Low | Medium |
| 10 | Handoff | Low–Medium | Low–Medium |

The order balances effort against impact: start with quick wins (haptics, TipKit) to build momentum, then tackle the high-visibility features (App Intents, Widgets) before the flagship Foundation Models integration. In-App Events and Liquid Glass require minimal code and can be done in parallel at any point.
