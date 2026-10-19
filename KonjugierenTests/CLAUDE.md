# KonjugierenTests

Conventions for writing tests in this target. Claude Code loads this file when working with files
under `KonjugierenTests/`. How to *run* tests, including the filter and environment-variable traps
that make a run report success while doing nothing, stays in the root `CLAUDE.md`.

## Swift Testing conventions

The project uses Swift Testing (`import Testing`), not XCTest.

- `import Testing` does **not** re-export Foundation transitively. A test file that uses `URL`, `Date`, `JSONEncoder`, or any other Foundation string/date API must `import Foundation` itself.
- Prefer `@Test(arguments:)` (optionally with `zip`) when test cases differ only in their input values, so each case reports independently and the body stays single-assertion. `TimeFormatterTests`, `MixedCaseAccessibilityTests`, and parts of `StringExtensionsTests` already follow this.

## Parallel execution and `@Suite(.serialized)`

- Swift Testing runs suites and tests **in parallel by default**.
- A suite that mutates shared global state (the `@MainActor var Current` world, or any `static`) must be `@Suite(.serialized)` so its tests don't race each other. That's why `SettingsTests`, `DeeplinkTests`, `QuizTests`, `QuizErrorHistoryTests`, and the `Unterminated Delimiters` sub-suite of `StringExtensionsTests` are serialized: each one swaps out parts of `Current` (e.g. `Current.fatalError = spy`) or touches UserDefaults-backed state.
- There is no `setUp`/`tearDown`. Do per-test setup in the suite `init` or in a helper called at the top of each `@Test`. Note: on a `struct` with no stored properties, a parameterless `init()` used only for side-effecting reset can trip SwiftLint's `unneeded_synthesized_initializer`. Prefer an explicit reset helper if that rule is enabled here.

## Test Suites Need `@MainActor`

Test suites that call into `@MainActor`-isolated app code must be annotated `@MainActor`. In Swift Testing, **`@MainActor` does not propagate to nested `@Suite` structs**. Each nested struct needs its own annotation:

```swift
@MainActor
@Suite("Outer")
struct OuterTests {
  @MainActor  // Required, not inherited from parent
  @Suite("Inner")
  struct InnerTests {
    @Test func example() { ... }
  }
}
```

A suite also needs `@MainActor` when it merely **compares two app values inside `#expect` whose `Equatable` conformance is main-actor-isolated**, with no "call into app code" required. A non-`@MainActor` suite doing `#expect(parsedSegments == [...])` on isolated model types (e.g. the `StringExtensions` markup enums) hits:

> `main actor-isolated conformance of '…' to 'Equatable' cannot be used in nonisolated context`

## Shared assertion helpers forward `#_sourceLocation`

`ConjugatorTests`' `expectConjugation` helper forwards `sourceLocation: SourceLocation = #_sourceLocation` to both `#expect` and `Issue.record`. Because `#_sourceLocation` resolves at each call site, a failing assertion reports the `expectConjugation(...)` line that actually failed rather than the helper's internal line. Without that, every one of the ~hundreds of assertions funneled through this helper would collapse to a single line, making a red test impossible to locate without bisecting. Any new shared assertion helper must do the same.

## Mixed-Case Convention in Test Expectations

Test expected values use mixed case to indicate ablaut changes:
- **Lowercase** = expected/unchanged portions of the conjugation
- **UPPERCASE** = unexpected/ablaut-changed portions

Examples:
```swift
// Strong verb singen: i→a in Präteritum
expectConjugation(infinitiv: "singen", conjugationgroup: .präteritumIndikativ(.firstSingular), expected: "sAng")

// Modal verb wissen: irregular Präsens
expectConjugation(infinitiv: "wissen", conjugationgroup: .präsensIndikativ(.firstSingular), expected: "wEIsS")

// Irregular sein: highly irregular forms
expectConjugation(infinitiv: "sein", conjugationgroup: .präsensIndikativ(.firstSingular), expected: "BIN")
```

This convention helps verify that `Conjugator` correctly identifies and marks ablaut regions for UI highlighting.
