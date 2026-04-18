# Control Center Controls (ControlWidget) — Lessons Learned

## Key Constraints (iOS 18+)

1. **`openAppWhenRun = true` is blocked in widget extensions.** Runtime error: `"openAppWhenRun is not supported in extensions"` (LNContextErrorDomain Code=2001). The intent never executes.

2. **`OpenURLIntent` from widget extensions is a silent no-op for custom URL schemes.** The intent reports success (`"Button control action succeeded"`), `linkd` creates a StreamReference for the extension, but the app never opens. No error logged.

3. **Solution: Place `AppIntent` files in `Shared/` (dual-target compilation).** When the intent is compiled into both the app and widget extension via `fileSystemSynchronizedGroups`, the App Intents runtime discovers the app target's version and runs `perform()` in the app process, where `openAppWhenRun` is honored.

## Working Architecture

- **Intent files** → `Shared/` directory (compiled into both app + widget extension targets)
- **ControlWidget files** → `KonjugierenWidget/` (widget extension only)
- **Intent `perform()`** → writes pending deeplink URL to shared `UserDefaults` (app group)
- **App `scenePhase == .active`** → reads and processes pending deeplink, then clears it
- **`MainActor.run`** required in `perform()` because main app has `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`, making `WidgetConstants` implicitly `@MainActor`, while `AppIntent.perform()` is `nonisolated`

## Debugging Tips

- Use Console.app filtered by app bundle ID to see `chronod` and `SpringBoard` logs
- Look for `"Action failure"` or `"Action success"` in SpringBoard logs
- `os.Logger` with `.notice` level from widget extensions is visible in Console.app
