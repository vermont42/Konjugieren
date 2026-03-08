# Post-Release Platform Features

Additional iOS-platform features not covered in `platform-features-plan.md`. These could impress Apple's editorial team or improve the user experience. Consider implementing after Konjugieren's initial release.

---

## Tier 1: Strong Featuring Signals

### 1. Swift Charts — Learning-Progress Visualization (iOS 16+)

**Why it matters:** Apple has featured Swift Charts in keynotes and sessions for three consecutive years. Few language-learning apps use it, making it a differentiator.

**Concrete features:**
- **Conjugation-mastery chart:** Quiz accuracy over time, broken down by conjugationgroup or verb family.
- **Streak visualization:** Daily practice history as a GitHub-style contribution grid or bar chart.
- **Weak-spot analysis:** A chart highlighting which conjugationgroups or verb families the user struggles with most.

**Key APIs:** `Charts`, `Chart`, `BarMark`, `LineMark`, `PointMark`
**Availability:** iOS 16.0+

---

### 2. Apple Watch Companion App (watchOS 10+)

**Why it matters:** Watch apps are rare in the language-learning category. A complication keeps Konjugieren visible on the watch face, similar to how widgets keep it visible on the Home Screen. Apple consistently features apps with strong Watch companions.

**Concrete features:**
- **Verb-of-the-day complication:** Shows today's verb on the watch face.
- **Micro-quiz:** 3-5 quick conjugation questions, tap the correct answer.
- **Daily-streak complication:** Shows the user's current practice streak.

**Key APIs:** `WatchKit`, `ClockKit` (complications), `WatchConnectivity`
**Availability:** watchOS 10.0+

**Note:** Simulator-only development is feasible for a text-heavy, tap-based Watch app. The simulator faithfully renders SwiftUI views and standard interactions. Final QA on hardware is recommended but not strictly required for a windowed/list-based UI.

---

### 3. SharePlay / Group Activities (iOS 17+)

**Why it matters:** Apple has pushed SharePlay since WWDC 2023, and educational apps that adopt it receive editorial attention. Apple specifically calls out educational SharePlay in their featuring criteria.

**Concrete features:**
- **Conjugation challenge:** Two participants see the same verb and race to answer correctly.
- **Shared quiz:** Participants take turns answering, with a shared scoreboard.
- **FaceTime and iMessage support:** Works in both contexts.

**Key APIs:** `GroupActivities`, `GroupActivity`, `GroupSession`
**Availability:** iOS 17.0+

---

## Tier 2: High Impact

### 4. Local Notifications for Spaced Repetition (iOS 10+)

**Why it matters:** Not flashy, but deeply useful. Spaced-repetition reminders improve retention and engagement. Apple values features that genuinely help users build habits.

**Concrete features:**
- **Daily practice reminder:** Configurable "time to practice" notification.
- **Spaced-repetition follow-ups:** Remind users to review verbs they got wrong at 1-, 3-, and 7-day intervals.
- **Streak protection:** "Don't break your streak!" notification if the user hasn't practiced today.

**Key APIs:** `UserNotifications`, `UNUserNotificationCenter`, `UNMutableNotificationContent`
**Availability:** iOS 10.0+

---

### 5. NavigationSplitView — True iPad Optimization (iPadOS 16+)

**Why it matters:** The app supports iPad orientations but could feel more iPad-native with a sidebar-detail layout. Apple frequently features apps that feel designed for iPad rather than scaled up.

**Concrete features:**
- **Sidebar navigation:** Verb list in the sidebar, conjugation detail in the main pane.
- **Hardware-keyboard shortcuts:** Cmd+F to search verbs, arrow keys to navigate.
- **Multi-column layout:** Verb list + detail + conjugationgroup article side by side on larger iPads.

**Key APIs:** `NavigationSplitView`, `KeyboardShortcut`, `.keyboardShortcut()`
**Availability:** iPadOS 16.0+

---

### 6. visionOS Support (visionOS 1.0+)

**Why it matters:** Apple is starved for Vision Pro content, especially educational apps. Being one of the few German-learning apps on Vision Pro is a strong editorial signal.

**Concrete features:**
- **Native windowed app:** Konjugieren running as a visionOS window with glass-background material.
- **Comfortable text sizing:** Adjusted font sizes for spatial reading distance.

**Key APIs:** Standard SwiftUI (windowed app requires minimal API changes)
**Availability:** visionOS 1.0+

**Note:** Simulator-only development works well for a text-heavy, 2D SwiftUI app. The main risk is not functionality but spatial ergonomics (tap-target sizing, text density, window dimensions) that can only be fully judged in the headset. A final QA pass on hardware — at an Apple Store, Developer Center, or borrowed device — is recommended before marketing it as a visionOS showcase.

---

## Tier 3: Differentiators

### 7. CloudKit / iCloud Sync (iOS 8+)

**Why it matters:** Syncing quiz history and mastered-verb progress across devices pairs naturally with the existing Handoff support.

**Concrete features:**
- **Progress sync:** Quiz scores, mastered verbs, and settings sync across iPhone and iPad.
- **Low-effort option:** `NSUbiquitousKeyValueStore` for settings and simple state.
- **Robust option:** `CKSyncEngine` (iOS 17+) for full quiz-history sync.

**Key APIs:** `CloudKit`, `NSUbiquitousKeyValueStore`, `CKSyncEngine`
**Availability:** iOS 8.0+ (CKSyncEngine: iOS 17.0+)

---

### 8. Focus Filters (iOS 16+)

**Why it matters:** Very few apps adopt Focus Filters, so it signals platform-feature breadth. Modest user impact but meaningful differentiation.

**Concrete features:**
- **Study Focus:** Surface a study-oriented interface (verb list, quiz) when a "Study" Focus is active.
- **Suppress distractions:** Hide game features during Study Focus.

**Key APIs:** `AppIntents`, `SetFocusFilterIntent`
**Availability:** iOS 16.0+

---

### 9. Journaling Suggestions API (iOS 17.2+)

**Why it matters:** A subtle, delightful integration highlighted at WWDC 2024. Learning milestones appear as journaling suggestions in the Journal app.

**Concrete features:**
- **Milestone suggestions:** Mastering a verb family or hitting a quiz streak appears as a Journal suggestion.
- **Daily-learning summary:** "You practiced 15 verbs today" as a journaling prompt.

**Key APIs:** `JournalingSuggestions`, `JournalingSuggestion`
**Availability:** iOS 17.2+

---

### 10. App Clips (iOS 14+)

**Why it matters:** A lightweight "try before you install" experience. Useful for marketing — QR codes on conference posters, German-class handouts, or language-learning blog posts.

**Concrete features:**
- **Single-verb conjugation:** Conjugate one verb in all conjugationgroups without installing the full app.
- **QR / NFC / Safari banner:** Multiple invocation points.

**Key APIs:** `App Clips`, `SKOverlay` (for full-app install prompt)
**Availability:** iOS 14.0+

---

## Priority Summary

| Priority | Feature | Effort | Impact | Notes |
|----------|---------|--------|--------|-------|
| 1 | Swift Charts | Medium | High | Visual polish, data storytelling |
| 2 | Apple Watch | Medium-High | High | Category rarity, always-on visibility |
| 3 | SharePlay | Medium | High | Apple's current editorial focus |
| 4 | Local Notifications | Low | Medium | User retention, habit building |
| 5 | iPad NavigationSplitView | Medium | Medium-High | iPad-native feel, keyboard shortcuts |
| 6 | visionOS | Low-Medium | Medium-High | Platform scarcity = editorial attention |
| 7 | CloudKit sync | Medium | Medium | Multi-device continuity |
| 8 | Focus Filters | Low | Low-Medium | Under-adopted differentiator |
| 9 | Journaling Suggestions | Low | Low-Medium | Subtle delight |
| 10 | App Clips | Medium | Low-Medium | Marketing channel |

Top three for editorial impact: **Swift Charts**, **Apple Watch**, and **SharePlay**. For pure user value: **local notifications with spaced repetition**.
