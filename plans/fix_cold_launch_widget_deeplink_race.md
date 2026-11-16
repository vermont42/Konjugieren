# Plan: check for (and fix) the cold-launch widget-deeplink race

## Origin

Conjuguer (the French sibling) had this bug: **force-quit the app, then tap a
Verb-of-the-Day widget → the app opened to the verb *browse* list instead of the
individual verb view.** Tapping the same widget after merely *backgrounding* the app
worked correctly. Fixed in Conjuguer commit `1f359d4`.

### Why it happened in Conjuguer

1. `ConjuguerApp` shows a `.loading` / `.loaded` state and kicks off
   `await verbData.load()` in a `.task`. The heavy XML parse of ~6,300 verbs runs
   **off the main actor** (`Task.detached`), so `Verb.verbs` is momentarily empty at
   launch.
2. On a cold launch the widget's `.widgetURL` is delivered through `.onOpenURL` →
   `World.handleURL(_:)` **before** that parse finishes.
3. Conjuguer's `handleURL` looked up `Verb.verbs[infinitif]` (→ `nil`, not loaded yet)
   but **switched the tab unconditionally** — so it selected the Verbs tab while the
   verb sheet binding stayed `nil`. Result: browse list, no verb.

The two necessary ingredients were therefore: **(a) an asynchronous verb load that can
still be in flight when the deeplink arrives, and (b) a `handleURL` that changes tab /
navigation state even when the entity lookup fails.**

The fix stashed any deeplink that arrived while `Verb.verbs.isEmpty` and replayed it
after loading finished.

## Preliminary finding for Konjugieren — likely NOT vulnerable

A quick read of the current code suggests Konjugieren is already protected on **both**
axes, but this must be confirmed, not assumed:

- **Synchronous load before the scene exists.** `AppLauncher.main()`
  (`Konjugieren/App/AppLauncher.swift`) does:
  ```swift
  static func main() {
    Verb.verbs = VerbParser().parse()
    AblautGroup.ablautGroups = AblautGroupParser().parse()
    ...
    KonjugierenApp.main()
  }
  ```
  The parse runs **synchronously on the main thread before `KonjugierenApp` is even
  instantiated**, so `Verb.verbs` is fully populated before any scene connects or any
  `.onOpenURL` can fire. There is no `.task { await load() }` / `.loading` state like
  Conjuguer had. (Ingredient (a) is absent.)

- **Guarded tab switch.** `World.handleURL(_:)`
  (`Konjugieren/Models/World.swift`, ~line 80) only switches tabs *after a successful
  lookup*:
  ```swift
  case URL.verbHost:
    ...
    verb = Verb.verbs[target]
    if verb != nil {
      selectedTab = .verbs   // only when the verb actually resolved
    }
  ```
  `handleUserActivity(_:)` (Spotlight / `viewVerb` NSUserActivity) has the same
  `if verb != nil` guard. So even in the hypothetical where the map were empty, it
  would *do nothing* rather than land on the wrong screen. (Ingredient (b) is absent.)

Because neither ingredient is present, the cold-launch symptom Conjuguer showed
almost certainly cannot occur here.

## Verification checklist (do this before concluding "safe")

1. **Confirm the synchronous-load claim still holds.** Re-read
   `Konjugieren/App/AppLauncher.swift`. Ensure `Verb.verbs` is assigned there
   synchronously and that nothing has moved verb parsing into an `async`/`.task`/
   `Task.detached` path (grep for `await ... parse`, `Task.detached`, `.task {` near
   verb loading). If verb loading has been made async, ingredient (a) is back —
   proceed to the fix.
2. **Confirm every deeplink entry point guards its tab switch.** In
   `Konjugieren/Models/World.swift`, check that `handleURL(_:)` and
   `handleUserActivity(_:)` set `selectedTab` / navigation targets **only** on a
   non-nil resolution for *every* host (`verb`, `quiz`, `family`, `info`). The `quiz`
   host currently switches unconditionally (`selectedTab = .quiz`) — that is fine,
   because starting a quiz needs no verb data, but note it if quiz start ever grows a
   data dependency.
3. **Exercise it on device (the real repro).** Build & install, **force-quit**
   Konjugieren (swipe up from app switcher — not just background it), then tap the
   medium/large Verb-of-the-Day widget (`konjugieren://verb/<infinitiv>`, built in
   `KonjugierenWidget/Views/{Medium,Large,Small,Accessory,Quiz}WidgetView.swift`).
   Expected: the verb detail view opens directly. Repeat after only backgrounding, to
   match Conjuguer's original comparison. Also test the control-center intents, whose
   deeplink is drained on `scenePhase == .active` in
   `KonjugierenApp.swift` (`OpenRandomVerbIntent` → `konjugieren://verb/random`,
   `OpenQuizIntent` → `konjugieren://quiz/start`).
4. If all three pass, **record the result** (a one-line note here or in the commit) and
   stop — no code change needed.

## Fix (apply ONLY if step 1 or 2 shows a real gap)

Mirror Conjuguer commit `1f359d4`:

1. Add `@ObservationIgnored var pendingDeeplink: URL?` to `World`.
2. In `handleURL(_:)` (and any other cold-launch-reachable deeplink entry such as
   `handleUserActivity`), after the format guards, bail out and stash when the data
   isn't ready:
   ```swift
   guard !Verb.verbs.isEmpty else {
     pendingDeeplink = url          // for handleUserActivity, synthesize the equivalent URL first
     return
   }
   ```
3. Add `func drainPendingDeeplink()` that replays `pendingDeeplink` (clear it first,
   then call `handleURL`).
4. Call `Current.drainPendingDeeplink()` at the point where loading is known complete.
   **Caveat:** Konjugieren has no post-load hook today because loading is synchronous
   at `AppLauncher`. Only if loading has been made async would such a hook exist —
   drain right after the `await load()` completes (as Conjuguer does in its `.task`).
5. Even if the app proves not vulnerable, consider adopting the defensive
   `if entity != nil { switch tab }` pattern uniformly as cheap insurance — but that is
   already the prevailing style here.

## Result (2026-07-09) — NOT vulnerable, no code change

Static verification steps 1 and 2 both pass; the cold-launch race is **structurally
impossible** here, so no fix was applied.

- **Step 1 (ingredient (a) — async load in flight): ABSENT.** The only assignment to
  `Verb.verbs` in the entire codebase is `AppLauncher.swift:8`
  (`Verb.verbs = VerbParser().parse()`), which runs synchronously on the main thread
  inside the `@main` `AppLauncher.main()` **before** `KonjugierenApp.main()` is called —
  i.e. before the `App` type is even instantiated. A codebase-wide grep for
  `Task.detached`, `.task {`, and `await … parse` near verb loading found nothing; the
  only `.task {}` uses are in `TutorView`, `TutorTestView`, and `SettingsView`, none
  touching verb loading. So `Verb.verbs` is fully populated before any scene connects
  and before any deeplink callback can fire.

- **Step 2 (ingredient (b) — unconditional tab switch on failed lookup): ABSENT.** In
  `World.handleURL(_:)`, every data-dependent host branch gates its `selectedTab`
  mutation on a successful resolution: `verb` (`if verb != nil`), `family`
  (`if BrowseableFamily(rawValue:) != nil`), `info` (`if … indices.contains`).
  `quiz` switches unconditionally but has no verb-data dependency. `handleUserActivity`
  has the same `if verb != nil` guard. This is already exercised by
  `DeeplinkTests.handleURLInfoDeeplinkOutOfBounds` (asserts the tab stays at the neutral
  `.settings` baseline after a failed lookup) and `handleURLVerbDeeplinkUnknownVerb`.

- **All four scene entry points inherit the guarantee.** `.onOpenURL` (widget
  `.widgetURL` taps → `konjugieren://verb/<infinitiv>`), `onContinueUserActivity`
  (Spotlight + `viewVerb`), and the `scenePhase == .active` drain of
  `WidgetConstants.pendingDeeplinkKey` (Control Center `OpenQuizIntent` /
  `OpenRandomVerbIntent`) all fire only after the scene is live — strictly after the
  synchronous `AppLauncher` parse. Note the shared-defaults `pendingDeeplinkKey`
  mechanism is a cross-process handoff for Control Center intents, unrelated to the
  load race.

**Step 3 (on-device force-quit + widget-tap repro) not performed** — it requires a
physical home-screen widget interaction that can't be reliably driven here. Because the
race is structurally impossible (ingredient (a) absent), this step would only reconfirm
that the widget deeplinks correctly at all, not the race. Left as an optional manual
confirmation.

## Tests

If a fix is applied, add a `KonjugierenTests/Utils/DeeplinkTests.swift` case for the
drain-replay path and a no-op-when-nothing-pending case, mirroring Conjuguer's
`testDrainPendingDeeplinkReplaysDeferredLink` /
`testDrainPendingDeeplinkIsNoOpWhenNonePending`. **Do not** write a test that empties
the global `Verb.verbs` — parallel suites read it; test `drainPendingDeeplink()`
directly by setting `Current.pendingDeeplink` instead.
