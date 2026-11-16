# Prompt: tighten the Swift Testing code + docs

You are improving this project's Swift Testing setup. Consult the `swift-testing-expert`
skill for best practices, and match the existing conventions in `KonjugierenTests/` and
the house style in `CLAUDE.md`. Build and test with the `ios-build-verify` skill
(resolve `IBV_SCRIPTS` against the **marketplace clone** exactly as `CLAUDE.md`'s "build
and test" section instructs). Do the tasks in order; build + run the affected tests after
the code change.

## Task 1 — Code fix: thread `sourceLocation` through `expectConjugation` (HIGH value)

`KonjugierenTests/Models/ConjugatorTests.swift` defines the shared helper
`expectConjugation(infinitiv:conjugationgroup:expected:)` (near line 998). Every one of
ConjugatorTests' ~25 test functions funnels its (many) assertions through it. Because the
helper doesn't forward a source location, **every failure reports the helper's line, not
the `expectConjugation(...)` call that actually failed** — so a red conjugation test can't
be located without bisecting.

Fix: give the helper a defaulted `sourceLocation` parameter and forward it to both the
`#expect` and the `Issue.record`:

```swift
private func expectConjugation(
  infinitiv: String,
  conjugationgroup: Conjugationgroup,
  expected: String,
  sourceLocation: SourceLocation = #_sourceLocation
) {
  let result = Conjugator.conjugate(infinitiv: infinitiv, conjugationgroup: conjugationgroup)
  switch result {
  case .success(let conjugation):
    #expect(conjugation == expected, "Expected \(infinitiv) → \(expected), got \(conjugation)", sourceLocation: sourceLocation)
  case .failure(let err):
    Issue.record("Failed to conjugate \(infinitiv): \(err)", sourceLocation: sourceLocation)
  }
}
```

`#_sourceLocation` resolves to each caller's location, so failures now point at the right
`expectConjugation(...)` line. No call sites change. Then check every **other** helper in
`KonjugierenTests/` that wraps `#expect`/`Issue.record` and give it the same treatment if
any exist (at audit time `expectConjugation` was the only such helper — confirm this is
still true with a quick search rather than assuming).

Verify: build, then run `ConjugatorTests` and confirm it still passes. As a spot check,
temporarily break one expected value, run the suite, confirm the failure now cites the
calling line (not the helper), then revert.

## Task 2 — CLAUDE.md: document the `sourceLocation` convention

In `CLAUDE.md`, under **"### The expectConjugation Helper"**, add a short note that the
helper forwards `sourceLocation: SourceLocation = #_sourceLocation` so failures point at
the calling test, and that any new shared assertion helper must do the same. Update the
code block in that section to match the new signature.

## Task 3 — CLAUDE.md: document parallel-by-default + `.serialized`

The code already serializes the right suites (`SettingsTests`, `DeeplinkTests`,
`QuizTests`, `QuizErrorHistoryTests`, and the `Unterminated Delimiters` sub-suite of
`StringExtensionsTests`), but `CLAUDE.md` never explains *why*. Add a subsection under
**"## Test Suite"** (e.g. **"### Parallel execution and `@Suite(.serialized)`"**) stating:

- Swift Testing runs suites and tests **in parallel by default**.
- A suite that mutates shared global state — the `@MainActor var Current` world, or any
  `static` — must be `@Suite(.serialized)` so its tests don't race; that's why the suites
  above are serialized.
- There is no `setUp`/`tearDown`; do per-test setup in the suite `init` or a helper called
  at the top of each `@Test`. (Note: on a `struct` with no stored properties, a
  parameterless `init()` used only for side-effecting reset can trip SwiftLint's
  `unneeded_synthesized_initializer` — prefer an explicit reset helper if that rule is
  enabled here.)

## Task 4 — CLAUDE.md: add the second `@MainActor` trigger

The **"### Test Suites Need `@MainActor`"** section (under "## Swift 6 and Default
Main-Actor Isolation") is excellent on nested-`@Suite` non-propagation. Add one sentence:
a suite also needs `@MainActor` when it merely **compares two app values inside `#expect`
whose `Equatable` conformance is main-actor-isolated** (no "call into app code" required),
and quote the exact compiler symptom:

> `main actor-isolated conformance of '…' to 'Equatable' cannot be used in nonisolated context`

(This is the error a non-`@MainActor` suite hits doing `#expect(parsedSegments == [...])`
on isolated model types — e.g. the StringExtensions markup enums.)

## Task 5 — CLAUDE.md: two short notes

In the **"## Test Suite"** section, add brief notes that:

- `import Testing` does **not** re-export Foundation transitively, so a test file using
  `URL`/`Date`/`JSONEncoder`/Foundation string APIs must `import Foundation` itself.
- Prefer `@Test(arguments:)` (optionally with `zip`) when tests differ only in input
  values — as `TimeFormatterTests`, `MixedCaseAccessibilityTests`, and parts of
  `StringExtensionsTests` already do.

## Acceptance criteria

- `expectConjugation` (and any sibling helper) forwards `#_sourceLocation`; a deliberately
  broken expectation reports the calling line.
- Build succeeds and the full `KonjugierenTests` suite passes (run it via the
  `ios-build-verify` scripts).
- `CLAUDE.md` gains the four documentation additions (Tasks 2–5), in the project's voice,
  with no references to XCTest/XCTAssert.
- No production code and no unrelated tests changed; no SwiftLint violations introduced
  (the pre-commit hook, if enabled, must pass).
- Do **not** commit unless asked; leave the changes staged-or-unstaged for review.
