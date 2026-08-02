# Plan: Tutor-Row Kill Switch for Screenshots

**Status:** ✅ implemented and shipped in `7dd7b88`. Kept for the rationale; the plan
below describes what was built, not outstanding work.
**Superseded in one detail:** the three kill switches later moved out of
`Konjugieren/Models/KonjugierenTips.swift` into `Konjugieren/Utils/KillSwitches.swift`,
so §"The catch" and the `sed` recipes below name a file that no longer holds them. The
paths are left as written because they record what was true then; for a live recipe use
[`docs/screenshot-playbook.md`](../docs/screenshot-playbook.md) § *Flip the kill switches
first*, which is the maintained copy.
**Ported from:** Conjugar, where this shipped 2026-07-18 as `TutorDisplay.tutorUnavailableRowEnabled`.
**Estimated size:** ~20 lines of app code, plus playbook and journal prose.

## Why

`InfoBrowseView` renders a tutor entry point above the first info row. When the on-device
model is available it is a live `TutorRowView`; when it is not, it falls back to
`TutorUnavailableRowView` — a row reading "Apple Intelligence isn't available on this
device." (`L.Tutor.reasonDeviceNotEligible`).

On the screenshot host that fallback is **not** an edge case, it is the only outcome. Per
`CLAUDE.md`, iOS 26.3.1 tightened the `os-eligibility-domain.change.greymatter` gate and
Intel-Mac hosts now resolve to `.unavailable(.deviceNotEligible)`. `info_browse` is one of
the nine sweep views (`VIEWS` in `scripts/take_screenshots.sh`), so **every `info_browse`
screenshot currently ships with an "Apple Intelligence isn't available" row in it.** That is
honest on a real device and reads as a defect in an App Store listing.

The fix is the one Conjugar landed: a compile-time switch that suppresses **only** the
unavailability row, never the working `NavigationLink`. Josh asked for this after the row
turned up in Conjugar's first full sweep.

> **Correct a stale claim while you are here.** `docs/screenshot-playbook.md` (~line 313)
> asserts: *"None of the 9 target screenshot views are Tutor-gated, so this doesn't affect
> the sweep."* That is false — `info_browse` is tutor-gated and does capture the row. Fix
> that sentence in the same pass; leaving it would tell the next session the problem does
> not exist.

## Design constraints (learned from Conjugar)

1. **Suppress the reason row only.** Guard the `else if let reason = …` branch, never the
   `isAvailable` branch. A switch that can hide a *working* feature is a footgun; this one
   structurally cannot.
2. **Default `true`.** Ordinarily on; flipped `false` only for a sweep, restored after. The
   playbook's operator checklist is what enforces the restore.
3. **Compile-time, not `UserDefaults`.** It must be impossible for the flag to be wrong at
   runtime in a shipped build, and the screenshot driver builds once at start — a runtime
   flag would invite a stale-build mismatch. (Note this differs from the existing
   `KONJUGIEREN_QUIZ_FIXTURE` UserDefaults flag, which is deliberately runtime because the
   driver must toggle it per-cell.)

## The catch: Konjugieren has no kill-switch convention yet

Conjugar has `TipDisplay.tipsEnabled` and `OnboardingDisplay.onboardingEnabled` in
`ConjugarTips.swift`, and the new switch simply joined them. **Konjugieren has neither** —
`grep` for `tipsEnabled` / `onboardingEnabled` / `TipDisplay` / `OnboardingDisplay` is empty
repo-wide, and `Konjugieren/Models/KonjugierenTips.swift` holds only four plain TipKit `Tip`
structs. So this introduces the convention rather than extending it.

**Recommendation: introduce only the tutor switch now.** Do not speculatively add tips and
onboarding switches — Konjugieren's sweep has not been shown to need them, and unused
switches rot. Put the new enum in `KonjugierenTips.swift` anyway, so the file is the
convention's home in both apps and a future `TipDisplay` has an obvious place to land.

## Steps

### 1. Add the switch

In `Konjugieren/Models/KonjugierenTips.swift`, above the `Tip` structs:

```swift
enum TutorDisplay {
  /// Master switch for the tutor section's *unavailability* row. Ordinarily `true`.
  /// Set to `false` before generating App Store screenshots (then restore to `true`).
  ///
  /// The tutor needs Apple Intelligence, which does not resolve as available on the
  /// screenshot host (see CLAUDE.md on the iOS 26.3+ host-eligibility gate), so
  /// `InfoBrowseView` renders a reason row there — "Apple Intelligence isn't available on
  /// this device." That is honest on a device but reads as a defect in a store listing, so
  /// the `info_browse` shots hide it. Only the reason row is suppressed: when the model
  /// *is* available the section still renders `TutorRowView`, so this switch can never
  /// hide a working feature.
  static let tutorUnavailableRowEnabled = true
}
```

### 2. Gate the fallback branch

In `Konjugieren/Views/InfoBrowseView.swift`, the tutor rows are **inlined in `body`** inside
the `ForEach` over `Info.infos`, gated on `index == 0` (~lines 19–31) — there is no
`tutorSection` computed property as in Conjugar. Change only the `else if`:

```swift
} else if let reason = Current.languageModelService.unavailabilityReason,
          TutorDisplay.tutorUnavailableRowEnabled {
```

Leave the `Divider()` inside that branch as-is — it is scoped to the branch, so suppressing
the row correctly suppresses its divider too. Verify that in the built UI: a stray divider
above the first info row is exactly the kind of artifact that survives review.

> **Consider extracting a `tutorSection` while you are in here** — Conjugar's equivalent is a
> `@ViewBuilder private var tutorSection`, which is why its change was a one-line diff in one
> place. Optional, and orthogonal to this plan; if you do it, do it as a separate commit so
> the kill switch stays reviewable on its own.

### 3. Verify

```bash
# with the switch false
xcodebuild -project Konjugieren.xcodeproj -scheme Konjugieren \
  -destination 'platform=iOS Simulator,name=iPhone 17' build
```

Then drive the app to the Info tab and confirm: no tutor row, no orphan divider, the first
info row sits directly under the header. Flip back to `true` and confirm the reason row
returns. **Both directions** — a switch verified in one direction is half-verified.

### 4. Update `docs/screenshot-playbook.md`

Konjugieren's playbook has **no kill-switch table, no `sed` recipe section, and no
"Running it from a fresh Claude session" paste-in prompt block** (all of which Conjugar's
has). So this is new prose, not a table row. Add a section before *Quick Start*:

```markdown
## Disable the tutor row first (then restore)

`TutorDisplay.tutorUnavailableRowEnabled` in `Konjugieren/Models/KonjugierenTips.swift` is
ordinarily `true`. **Set it to `false` before running the driver and restore it to `true`
afterward.** The driver builds once at start, so it must be flipped *before* you launch it —
flipping it mid-sweep does nothing.

| Switch | Effect when `false` | What you get if you forget |
|---|---|---|
| `TutorDisplay.tutorUnavailableRowEnabled` | `InfoBrowseView` drops the tutor **unavailability reason row**. Only that row: when the model *is* available the section still renders `TutorRowView`. | Both `info_browse` shots carry "Apple Intelligence isn't available on this device." |

```bash
# before the sweep
sed -i '' 's/static let tutorUnavailableRowEnabled = true/static let tutorUnavailableRowEnabled = false/' \
  Konjugieren/Models/KonjugierenTips.swift

# after the sweep — restore
sed -i '' 's/static let tutorUnavailableRowEnabled = false/static let tutorUnavailableRowEnabled = true/' \
  Konjugieren/Models/KonjugierenTips.swift

git diff --stat Konjugieren/Models/KonjugierenTips.swift   # must be empty when you are done
```
```

Also: add it to the *Prerequisites* list, add a **workaround #13** (the list currently tops
out at #12) describing the symptom and fix, add the file to *Don't Break These — Driver
Anchor Dependencies*, and **fix the stale Known Gotcha at ~line 313** per the note above.

### 5. Journal it

Append a `## <Title> (YYYY-MM-DD)` entry to `docs/blog_notes.md` (newest at bottom, narrative
not changelog — what was tried, what failed, why it was decided this way). Worth recording:
that Konjugieren had no kill-switch convention and this introduced one; that the playbook
gotcha claiming no sweep view was tutor-gated was wrong; and that the switch is deliberately
incapable of hiding a working tutor.

## Out of scope

- Tips and onboarding kill switches (add when a sweep proves they are needed).
- The `SettingsView` / `OnboardingView` / `TutorTestView` availability gates — those are
  not in the sweep's nine views. If the spec ever adds a Settings screenshot, revisit.
- Making the tutor actually available on the screenshot host. That is a host-eligibility
  problem (Apple Silicon or a real device), not something a flag can fix, and it means the
  store listing will never show the tutor *entry point*. If Josh wants that in the listing,
  the shot must be taken by hand on an Apple-Intelligence-capable device.
