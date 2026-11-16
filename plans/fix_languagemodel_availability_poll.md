# Fix plan: `LanguageModelServiceReal` polls availability every 5 seconds forever

**Status:** ✅ implemented 2026-07-08 (recommended approach — scene-activation refresh, plus the optional `InfoBrowseView.onAppear` refinement; the same `.onAppear` refinement was also applied to Conjuguer, which already had the scene-activation fix)
**Category:** concurrency / performance · **Severity: Medium**
**File:** `Konjugieren/Models/LanguageModelServiceReal.swift:19-30`

## The bug

`LanguageModelServiceReal.init()` spawns an unstructured, never-stored,
never-cancelled `Task` that polls `SystemLanguageModel` availability on a fixed
5-second cycle for the lifetime of the process:

```swift
init() {
  let snapshot = Self.snapshot(of: model.availability)
  self.isAvailable = snapshot.isAvailable
  self.unavailabilityReason = snapshot.reason
  Task { [weak self] in
    while !Task.isCancelled {
      try? await Task.sleep(for: .seconds(5))
      guard let self else { return }
      self.refreshAvailability()
    }
  }
}
```

The service is created once in `World.real` (`Konjugieren/Models/World.swift:49`)
and lives in the global `Current` for the whole app session. Nothing retains a
handle to the `Task`, so:

- **It never stops.** The `while !Task.isCancelled` guard is dead — no one holds
  the task to cancel it. It wakes the process every 5 seconds forever, even when
  the user is deep in the quiz or the game and the tutor is never opened.
- **It has no early-out.** Once the model is `.available` (the terminal state that
  matters for the UI), the loop keeps polling anyway.
- **It's pure overhead in the common case.** Most sessions never visit the tutor,
  so every one of those wake-ups is wasted work against battery and CPU.

This is the same defect that was in Conjuguer (fixed 2026-07-08) and that Conjugar
already fixed (it cites "item 15" in its own code). Konjugieren's copy is
byte-for-byte the original defect.

### Why availability needs *any* refresh at all

`model.availability` can flip **after** launch: the user enables Apple Intelligence
in Settings, or the on-device model finishes downloading. The snapshot taken in
`init()` would otherwise be stale until the next cold launch, so the tutor entry
points would keep showing "unavailable" even after the model became ready. The
fix must preserve a live refresh — it just must not be a forever-poll.

### Where availability is consumed (so we know what the refresh must drive)

`isAvailable` / `unavailabilityReason` are read (via `@Observable`, so SwiftUI
re-renders when they change) in:

- `Views/InfoBrowseView.swift:20,25` — the tutor row on the Info tab (shows the
  tutor entry or an "unavailable" row).
- `Views/OnboardingView.swift:14,90` — onboarding page count + a tutor page.
- `Views/SettingsView.swift:180` — a chat-history affordance.
- `Views/TutorView.swift` / `TutorTestView.swift` — gate before sending a message.

The dominant real-world transition is: user leaves the app → enables Apple
Intelligence in system Settings → returns to the app. That return is a
**scene-activation** event, which the recommended approach hooks directly.

## Recommended approach — on-demand refresh driven by `scenePhase == .active`

This mirrors Conjuguer's fix and is the least-code option for Konjugieren because
`KonjugierenApp` **already has** a `.onChange(of: scenePhase)` handler that runs on
`.active` (`Konjugieren/App/KonjugierenApp.swift:52-64`). We add one call there and
delete the poll.

### Step 1 — add `refreshAvailability()` to the protocol

`Konjugieren/Models/LanguageModelService.swift`, in the `LanguageModelService`
protocol:

```swift
@MainActor
protocol LanguageModelService {
  var isAvailable: Bool { get }
  var unavailabilityReason: LanguageModelUnavailability? { get }
  func refreshAvailability()          // <-- add
  func explainError(context: ErrorExplainerContext) async throws -> ErrorExplanation
  func recommendPractice(aggregatedErrors: String) async throws -> PracticeRecommendation
  func sendTutorMessage(_ message: String) async throws -> String
  func resetTutorSession()
}
```

### Step 2 — delete the poll; make `refreshAvailability()` non-private

`Konjugieren/Models/LanguageModelServiceReal.swift`. The method body already exists
(lines 32-40); just drop the `private` keyword so it satisfies the protocol, and
remove the `Task { … }` block from `init()`:

```swift
init() {
  let snapshot = Self.snapshot(of: model.availability)
  self.isAvailable = snapshot.isAvailable
  self.unavailabilityReason = snapshot.reason
}

// Re-read model availability on demand (the app calls this when the scene becomes
// active) instead of a fixed forever-poll, which woke the process every 5s for the
// service's whole lifetime even when the tutor was never opened.
func refreshAvailability() {
  let snapshot = Self.snapshot(of: model.availability)
  if snapshot.isAvailable != isAvailable {
    isAvailable = snapshot.isAvailable
  }
  if snapshot.reason != unavailabilityReason {
    unavailabilityReason = snapshot.reason
  }
}
```

### Step 3 — add the no-op to the dummy

`Konjugieren/Models/LanguageModelServiceDummy.swift`:

```swift
func refreshAvailability() {}
```

### Step 4 — call it on scene activation

`Konjugieren/App/KonjugierenApp.swift`, inside the existing
`.onChange(of: scenePhase)` block's `if scenePhase == .active { … }` branch (add
alongside the widget refresh already there, ~line 63):

```swift
.onChange(of: scenePhase) {
  if scenePhase == .active {
    // …existing widget-deeplink + snapshot refresh…
    WidgetSnapshotWriter.writeSnapshot()
    WidgetCenter.shared.reloadAllTimelines()
    Current.languageModelService.refreshAvailability()   // <-- add
  }
}
```

Because `LanguageModelServiceReal` is `@Observable`, updating `isAvailable` /
`unavailabilityReason` here automatically re-renders `InfoBrowseView`,
`OnboardingView`, and `SettingsView`.

### Optional refinement — also refresh when the Info tab appears

The scene-activation hook covers the "left to Settings and came back" path. If you
also want the tutor row to react while the app stays foregrounded (rare, but e.g.
the model finishes downloading while the user browses Info), add an `.onAppear`
call in `InfoBrowseView`:

```swift
.onAppear {
  Current.analytics.signal(name: .viewInfoBrowseView)
  Current.languageModelService.refreshAvailability()   // <-- add
}
```

This is a single synchronous read on appear — still not a poll — so it's cheap and
optional.

## Alternative approach — view-scoped cancellable monitor (Conjugar's fix)

If you specifically want a *live* poll while the model is still downloading (rather
than only re-checking on scene activation / tab appearance), port Conjugar's shape
instead:

- Store the task: `private var availabilityMonitor: Task<Void, Never>?`
- Add `startAvailabilityMonitoring()` / `stopAvailabilityMonitoring()` to the
  protocol + both conformers.
- `start` guards `availabilityMonitor == nil, !isAvailable`, loops with the 5s
  sleep, **breaks once `isAvailable` becomes true**, and nils its own handle;
  `stop` cancels and nils the handle.
- Call `start` from `InfoBrowseView.onAppear` and `stop` from `.onDisappear`.

This bounds the poll to the one screen that shows availability and stops it as
soon as the model is ready — strictly better than the current forever-poll, but
more moving parts than the recommended approach. Given Konjugieren already has the
`scenePhase` hook, the recommended approach is preferred for minimal surface area
and consistency with Conjuguer.

## Verification

1. **Build:** `docs/vanilla_build_and_test.md` path (or the project's build script).
   Expect a clean build — the protocol gains one method, both conformers implement
   it, the app calls it.
2. **No behavioral regression in the tutor gate:** with Apple Intelligence enabled,
   the Info-tab tutor row and onboarding tutor page still appear (they read the same
   `isAvailable`, now refreshed on activation instead of on a timer).
3. **Live flip still works:** on a device/simulator where the model starts
   unavailable, background the app, enable Apple Intelligence, return — the Info tab
   should now show the tutor row (driven by the `scenePhase == .active` refresh).
4. **No unit-test impact expected:** `LanguageModelServiceDummy` returns a fixed
   `isAvailable = false`; the new no-op doesn't change that. If any test constructs
   a service and asserts on availability, the added protocol requirement only needs
   the no-op body, already covered by Step 3.

## Files touched

| File | Change |
|---|---|
| `Konjugieren/Models/LanguageModelService.swift` | add `refreshAvailability()` to the protocol |
| `Konjugieren/Models/LanguageModelServiceReal.swift` | delete the `Task` poll from `init()`; drop `private` from `refreshAvailability()` |
| `Konjugieren/Models/LanguageModelServiceDummy.swift` | add `func refreshAvailability() {}` |
| `Konjugieren/App/KonjugierenApp.swift` | call `Current.languageModelService.refreshAvailability()` in the `scenePhase == .active` branch |
| `Konjugieren/Views/InfoBrowseView.swift` | *(optional)* refresh on `.onAppear` |
