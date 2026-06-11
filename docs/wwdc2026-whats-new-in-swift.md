# WWDC2026 "What's New in Swift": Announcements Relevant to Konjugieren

Source: Apple, "What's New in Swift", WWDC2026 session 262 (https://developer.apple.com/videos/play/wwdc2026/262/). Presented by Becca and Evan of the Swift team. The transcript was pulled from the page's server-rendered `#transcript-content` DOM section on 2026-06-11 (via Claude in Chrome) and read in full; quotations below are verbatim short excerpts from it. (WebFetch returns only a small-model summary of a page, which can confabulate plausible-but-false announcements, so the raw transcript nodes were extracted directly and used as ground truth. The "Transcript" tab had to be activated before the text became extractable; it is otherwise a collapsed supplement.)

This report covers only what bears on Konjugieren. A "Considered and set aside" list at the end records what was reviewed and judged irrelevant, so the absence of a topic here is a decision, not an oversight.

This is the language companion to [`wwdc2026-platforms-sotu.md`](wwdc2026-platforms-sotu.md), which covers Foundation Models, SwiftUI, and the hardware gate from the Platforms State of the Union. Where the two overlap (async-in-`defer`, `anyAppleOS`, per-region warning control, the Apple-silicon requirement), this report defers to that one and adds the language-level detail. Its SwiftUI sibling is [`wwdc2026-whats-new-swiftui.md`](wwdc2026-whats-new-swiftui.md) (session 269), which gives the SwiftUI framework the same code-checked treatment.

## Toolchain reality (read this first — it reframes everything below)

This session is titled "what's new in Swift," but the honest headline for Josh is *when*, not *what*. The verified local toolchain is:

```
$ swift --version
Apple Swift version 6.2.4 (swiftlang-6.2.4.1.4 clang-1700.6.4.2)
Target: x86_64-apple-macosx15.0          ← Intel
$ xcodebuild -version
Xcode 26.3 (Build 17C529)
```

The talk covers **Swift 6.3 and 6.4**. Josh is on **Swift 6.2.4 / Xcode 26.3 / Intel**. So *neither* version's features are on this machine today. Every item in this report is forward-looking. Concretely:

| Feature | Swift version | On Josh's machine now? | Path to it |
|---|---|---|---|
| Module selectors (`::`), `@specialized` | 6.3 | No (he's on 6.2.4) | A future Intel Xcode 26.x *if* one ships 6.3, or a swift.org standalone 6.3 toolchain selected in Xcode 26.3 (power-user route, SDK caveats). Otherwise Xcode 27. |
| `anyAppleOS`, `@diagnose`, `some P?` without parens, `~Sendable`, `weak let`, async-in-`defer`, Swift Testing 6.4 features, `@C`, `@inline(always)`, `Iterable`, `borrow`/`mutate`, `UniqueBox`/`UniqueArray`/`Ref`, `mapKeyedValues`, task-cancellation shield, `FilePath`, `ProgressManager` | 6.4 | No | Xcode 27, which per [`wwdc2026-platforms-sotu.md` §5](wwdc2026-platforms-sotu.md) is **Apple-silicon-only**. Fully gated until Josh is on Apple silicon. |

Two precision notes so the report isn't misread:

- **`SWIFT_VERSION = 6.0` in the project is the language *mode*, not the toolchain version.** Almost every item here is *additive* — a new attribute, a new stdlib API, a new Swift Testing capability, a syntactic relaxation — and works in language mode 6.0 on a new enough compiler. So adopting these will generally not require bumping `SWIFT_VERSION`; it requires the newer *toolchain*. The gate is the toolchain (and therefore the hardware), not the language mode.
- **Swift 6.3 vs 6.4 matters for sequencing.** The two genuinely-useful-here 6.3 features (module selectors, `@specialized`) are theoretically reachable on Intel via a swift.org toolchain before any hardware move; the testing and ergonomics wins are 6.4 and wait for Apple silicon. Don't conflate them.

The upshot mirrors the SOTU report: the Apple-silicon decision in `wwdc2026-platforms-sotu.md` §5 gates this report too. Until then, this is a reading list, not a task list.

## Executive summary

Ranked by how much each should move Konjugieren's roadmap *once the toolchain question is settled*:

1. **Swift Testing gains a flaky-test repeat mode, dynamic test/argument cancellation, and issue-severity levels.** This is the one cluster with direct, concrete hooks in the existing code: a 10-file Swift Testing suite, ~50 conjugation tests, 6 parameterized tests, and a documented `-parallel-testing-enabled NO` flakiness workaround in CLAUDE.md that the new repeat mode is built to diagnose. See §1.
2. **The toolchain/hardware gate.** Nothing here runs on Josh's Intel Xcode 26.3. The 6.4 wins wait for Xcode 27 / Apple silicon. This determines *when* any of the rest applies. See the toolchain section above and SOTU §5.
3. **Everyday language ergonomics (Swift 6.4).** Small, pervasive quality-of-life: optional `some`/`any` without parentheses, a warning when a `Task` silently swallows a thrown error, async calls in `defer`, `weak let`, `~Sendable`. Free on the recompile that the hardware move will eventually force anyway. See §2.
4. **`@diagnose` for scoped warning control.** Genuinely useful during the eventual SDK migration: silence a deprecation in one declaration, promote future-error warnings to errors now, or opt a security-sensitive function into strict memory safety. See §3.
5. **Module selectors (`::`).** A minor robustness upgrade with one real hook — `TutorView.swift` already disambiguates `SwiftUI.Layout` by hand. See §4.

Everything else (`anyAppleOS` for a single-platform app, the standard-library odds and ends, Foundation speedups, and the entire performance/ownership chapter) is low-relevance or not-applicable for a verb-conjugation app, and is treated briefly in §5–§8 and the set-aside list.

---

## 1. Swift Testing: the cluster that actually fits this codebase

Konjugieren is a real Swift Testing shop — `import Testing` across 10 files (`ConjugatorTests`, `QuizTests`, `QuizErrorHistoryTests`, `SettingsTests`, `StringExtensionsTests`, `TimeFormatterTests`, `DeeplinkTests`, `MixedCaseAccessibilityTests`, `VerbExportTests`, `WidgetSnapshotTests`), with `ConjugatorTests.swift` alone holding ~50 `@Test` functions and the `expectConjugation` helper described in CLAUDE.md. Six tests are already parameterized with `@Test(arguments: zip(...))`. This session's testing improvements land squarely on that surface. All are Swift 6.4, so all wait for Xcode 27 (toolchain section).

### 1a. Repeat-until-pass/fail — built for the exact flakiness CLAUDE.md documents

> "The swift test command adds new functionality to repeat a test until it either passes or fails, while also allowing you to control the maximum number of repetitions."

And, importantly for turnaround:

> "If you specify that you want to repeat until the tests pass, only failing tests are re-run."

This is directly relevant. CLAUDE.md's diagnostic-fallback section runs `perfektpartizip()` with `-parallel-testing-enabled NO`, and the verification-config section repeatedly works around order- and state-sensitive behavior. A test that needs parallelism disabled is, by definition, a flakiness/isolation smell. The new repeat mode is the supported way to *characterize* such a test — run it N times, see whether it fails intermittently — instead of reaching straight for the parallelism off-switch. Concrete use once on Xcode 27: repeat-until-failure on the conjugation tests to confirm whether `-parallel-testing-enabled NO` is still needed, or whether the underlying shared state (likely `Current` / `World` global mutation between tests) can be fixed so parallelism can be turned back on. Note `swift test` is the SwiftPM driver; the equivalent in this Xcode-project app is the `xcodebuild ... -test-iterations` / "Run Until Failure" family, but the capability is the same.

### 1b. `Test.cancel` and per-argument cancellation — for the parameterized conjugation tests

> "You can cancel tests dynamically by calling the Test.cancel API."

> "This is especially powerful with parameterized tests, where you can cancel individual arguments that shouldn't run."

Konjugieren's 6 parameterized tests are the natural fit. The conjugation suite grows verb-by-verb as the corpus marches toward 1,000; a parameterized test over a verb list will inevitably include cases that aren't supported yet (a new ablaut group mid-implementation, a verb whose data is staged but whose pattern isn't coded). Today the choices are to omit those arguments or let them fail. `Test.cancel` lets a parameterized conjugation test skip the not-yet-supported argument *at runtime* — e.g., cancel when `Verb.verbs[infinitiv]` is absent or the conjugationgroup is known-unimplemented — keeping the suite green and honest about what it actually covers rather than silently dropping cases from the `arguments:` list.

### 1c. Issue severity — surface known gaps without failing CI

> "Now you can set the severity level of issues recorded with Issue.record."

> "Setting it to a warning means you can surface issues ... worth investigating, but not worth blocking CI workflows."

`ConjugatorTests` uses `Issue.record` exactly once (the failure path of `expectConjugation`). A warning-severity issue is a good fit for *aspirational* coverage: conjugations that are linguistically real but not yet implemented can be recorded as warnings — visible in the test report, tracked, but non-blocking — instead of either failing the build or not being tested at all. This pairs well with the verb-corpus growth model and with `docs/code-audit.md`'s test-gap notes.

### 1d. XCTest interop — good to know, not applicable here

> "In Swift 6.4, XCTest assertion failures are now reported as test issues when called from Swift Testing."

The bidirectional XCTest/Swift Testing interop (and the "Migrate to Swift Testing" session it points to) matters for codebases mid-migration. Konjugieren is already 100% Swift Testing with no XCTest, so this is informational only — there's no migration left to de-risk. Worth knowing if a dependency ever drags XCTest-based helpers in.

---

## 2. Everyday language ergonomics (Swift 6.4): small, pervasive, free on recompile

These are the "annoyances going away" Becca opens with. None is a feature investment; they're papercuts removed, and they arrive automatically on the toolchain Josh will eventually move to. Mapped to this codebase:

- **Optional `some`/`any` without parentheses.** "in Swift 6.4, you can simply get rid of those parentheses." Minor; applies wherever an existential optional is written. `LanguageModelService` and its conformances are the likeliest spot for `(any Foo)?`-style signatures.
- **A warning when a `Task` silently swallows a thrown error.** "You'll now get a warning if you silently ignore an error thrown from a Swift Concurrency task." Worth checking against the ~15 `Task { }` blocks in the app. The good news: the prominent throwing ones already do the right thing — `TutorView.swift:315` and `:344` both wrap `try await Current.languageModelService...` in `do/catch`, and `ErrorExplainerView.swift:77` follows the same shape. So this warning is mostly a *safety net* validating existing hygiene, not a bug-finder. It would catch any future `Task { try await … }` written without a `do/catch` or a saved handle.
- **Async calls in `defer`.** "the old restriction on calling async functions from a defer block is now gone." Already noted in SOTU §7; relevant to any async cleanup (e.g., finalizing a tutor stream).
- **`weak let` and `~Sendable`.** "you can now change that property to weak let"; the new "tilde Sendable syntax." Surveyed the codebase: there are currently **no** `@unchecked Sendable` declarations and **no** `weak var` properties, so neither has a present-day application. Filed for awareness if a future delegate-style or cache type introduces a weak reference.
- **Second memberwise initializer for mixed internal/private structs.** "a struct with a mix of internal and private properties will now have a second memberwise initializer that you can use from other files." Could remove a hand-written init somewhere in `Models/` if such a struct exists; low impact.

---

## 3. `@diagnose`: scoped warning control for the eventual SDK migration

> "The @diagnose attribute lets you change the behavior of specific warnings inside a particular declaration."

Three uses, all plausibly relevant when Josh eventually rebuilds against a newer SDK on Apple silicon:

- **Silence a deprecation locally.** When an Apple API Konjugieren uses gets deprecated but the replacement isn't a drop-in, `@diagnose` can quiet the `deprecated declaration` warning in just the affected declaration while the migration is planned — without a project-wide warning suppression that would hide *new* deprecations.
- **Promote future-errors to errors now.** "we've upgraded warnings that will become errors in the future to errors right now." A disciplined way to stay ahead of the Swift evolution treadmill on a per-declaration basis.
- **Opt into strict memory safety where it matters.** "you could turn on strict memory safety in security-critical functions." Konjugieren has little unsafe code, but the `StringExtensions` rich-text parser and any index-arithmetic in `Conjugator` (which does `String.index(_:offsetBy:)` / `replaceSubrange`) are the kind of place a localized strict-safety audit would be cheap insurance.

This is also the attribute Evan reuses in the embedded section to manage `EmbeddedRestrictions` diagnostics — a nice illustration that it's a general-purpose, scoped diagnostic control.

---

## 4. Module selectors (`::`): one real hook, minor

> "just change that dot to a double colon ... the name on the left is always treated as a module name."

Konjugieren already does manual module qualification in exactly the situation Becca describes. `TutorView.swift:356` declares `struct FlowLayout: SwiftUI.Layout` and then refers to `SwiftUI.Layout.Subviews` on lines 359, 364, and 372 — dot-qualifying `Layout` to disambiguate from anything else named `Layout` in scope. With a module selector, `SwiftUI::Layout` would be unambiguous *by construction*: the left side can only be a module, so it's robust even against the pathological case Becca raises (a type that shares its module's name).

Honest framing: the existing `SwiftUI.Layout` works fine today, and the example Becca gives (> "if SwiftUI and the database package you're using both have a type called View") doesn't currently bite Konjugieren — it has no database package and no observed name collisions. So `::` is a clarity/robustness upgrade to apply opportunistically, not a fix for a present bug. It's a Swift 6.3 feature, so it's the *one* item in this report that could reach Josh slightly ahead of the Apple-silicon move (via a swift.org 6.3 toolchain), though that's not worth doing for this alone.

---

## 5. `anyAppleOS`: low value for a single-platform app

> "letting you condense all of those platform names into one"

Already flagged in SOTU §7 as a tidiness win. The codebase-specific verdict is that it's **minimal benefit here**: there are exactly two `@available` attributes (both `@available(iOS 26, *)`, in `LanguageModelServiceReal.swift`) and **zero** `#if os(...)` conditions. `anyAppleOS` pays off when one annotation must list iOS + iPadOS + macOS + watchOS + tvOS + visionOS at the same version; a single-platform iOS app already writes the shortest possible form. If Konjugieren ever grows a watchOS companion or a Mac Catalyst build, revisit — until then, this changes nothing.

---

## 6. Standard-library odds and ends: mostly not applicable

- **`mapKeyedValues`** (key + value in the closure). "passes both the key and the old value into the mapping closure." Surveyed: the app uses **no** `mapValues` today, so there's nothing to upgrade. Filed for awareness — if a future dictionary transform over `Verb.verbs` or `AblautGroup.ablautGroups` needs the key to compute the new value, this is the clean tool.
- **Task-cancellation shield.** "Inside of the shield, task cancellation checks always return false." Designed for "finishing writing data to disk to avoid corrupting a file." Konjugieren's persistence goes through `GetterSetter` (UserDefaults), which is synchronous and small, so there's no torn-write risk to shield. Marginal possible use: ensuring a final tutor-message save (`saveMessages()`) completes if the surrounding `Task` is cancelled — but that save is already synchronous. Low relevance.
- **`FilePath` in the standard library.** Cross-platform path handling. Konjugieren reads bundled resources via `Bundle`, not raw path strings; not applicable.

---

## 7. Foundation: free speedups, one N/A type

- **Swift-Foundation `Data` modernization.** "we modernized more parts of Data, resulting in improvements across the board." This is a recompile-and-it's-faster win, like the SwiftUI layout speedups in SOTU §3. Konjugieren touches `Data` only lightly (e.g., decoding bundled JSON like `ExampleSentences.json`, widget snapshots), so the practical gain is small but free.
- **`ProgressManager`.** A new async-friendly progress-reporting type. Konjugieren has no long-running, progress-bar-worthy operation (conjugation is instantaneous; the LLM surfaces show a spinner, not a determinate progress bar), so this is not applicable.

---

## 8. Performance and ownership: not needed here (and Apple agrees)

The back third of the talk — `@inline(always)`, `@specialized`, the borrow/mutate accessors, `Iterable`, `UniqueBox`/`UniqueArray`/`Ref`/`MutableRef`, noncopyable and non-escapable conformances — is the deepest material and the least relevant to this app. Becca says so directly:

> "You usually won't need these advanced performance features, but when you do, you'll be glad you have them."

Why they don't apply to Konjugieren: the performance-critical premise is "a lot of computation" or "constrained environments." `Conjugator` is pure string manipulation over short stems (~5–15 characters), one verb-form at a time, behind a couple of dictionary lookups (`Verb.verbs`, `AblautGroup.ablautGroups`, `AblautGroup.ablauts`). Even the worst realistic batch — conjugating all ~1,000 verbs across all ~80 conjugationgroups, e.g. for `VerbExportTests` or a search index — is tens of thousands of short-string operations done once, i.e. a millisecond-scale job, not a hot loop. There are no large value types being copied, no `UnsafePointer` to make safe, no noncopyable resources to model. Adopting borrow/mutate accessors or `Ref` here would add ceremony for no measurable gain.

The single theoretical reach, recorded so the door isn't shut: *if* a future "conjugate everything" path is ever profiled and shown to be hot (unlikely), the first and least-invasive tools would be `@inline(always)` on the tiny private helpers in `Conjugator` (`applyAblaut`, `adjustEndingForPhonology`, etc.) and possibly `@specialized` — not the ownership machinery. Becca's caveat applies: "consider using final with @inline(always) for methods of classes" — though `Conjugator` is an `enum` of `static` functions, so that particular caveat is moot. This remains speculative; do not implement without a profile that justifies it.

The new `Iterable` protocol (borrow-based `for` loops) is similarly a non-event here: it benefits loops over large collections of noncopyable or reference-counted elements, and Konjugieren's loops are over small arrays of `String`/value enums where the existing `Sequence` path is fine. The for-loop "will prefer the Sequence protocol if available, and fall back to Iterable otherwise," so existing code is unaffected regardless.

---

## Delightful connections (because the work surfaced them)

- **An official Swift SDK for Android, and "share Swift code between Android and iOS apps."** "the first Swift SDK for Android as part of Swift 6.3." Konjugieren's core logic is unusually portable: `Conjugator` is a dependency-free `enum` of pure functions, and the verb/ablaut data is plain structured data. The German-conjugation *engine* could, in principle, be lifted into a shared Swift package and compiled for an Android edition someday — the same way the SOTU report imagined a Berlin Developer Center showcasing the app. Josh already ships a family of conjugation apps (Conjuguer, Conjugar); a cross-platform Swift core is the kind of connection-across-domains he values. Purely aspirational, but the architecture happens to be ready for it.
- **The Swift editor experience reaches the AI-assisted editors Josh's workflow lives in.** "we've added it to the OpenVSX marketplace, making the integrated Swift experience available to new editors including VSCodium, Cursor, Kiro, and Antigravity." Konjugieren is developed through Claude Code, and the broader move — official Swift tooling meeting developers in agentic/AI editors, plus Swiftly managing toolchains "right from your editor" — is the same convergence the SOTU report noted with Xcode's Agent Client Protocol support. The ecosystem is arranging itself around exactly the human-plus-agent loop this project uses. 🦀
- **Swift in the kernel and firmware, and a 35–40× JavaScriptKit bridging speedup at Goodnotes.** Not relevant to the app, but a satisfying data point on how far the "one language across the whole stack" thesis has traveled — from a verb-conjugation view layer down to, per the talk, "the lowest layers of firmware."

---

## Concrete next actions

There are no immediate code actions, because nothing in this session is available on Josh's current Intel / Xcode 26.3 toolchain. The actions are sequencing and awareness:

- [ ] Treat this report as gated by the same Apple-silicon decision as [`wwdc2026-platforms-sotu.md` §5](wwdc2026-platforms-sotu.md). Resolve that first; it unlocks the Swift 6.4 items below.
- [ ] (Optional, ahead of hardware) If module selectors or `@specialized` ever feel worth it before an Apple-silicon move, the only path on this Intel Mac is a swift.org Swift 6.3 toolchain selected inside Xcode 26.3 — a power-user route with SDK-compatibility caveats. Not recommended for these two minor wins alone.

On the Xcode 27 / Apple-silicon toolchain, in rough priority order:

- [ ] **Testing (§1):** run the conjugation suite under repeat-until-failure to determine whether `-parallel-testing-enabled NO` is still warranted, and fix the shared-state cause (likely `Current`/`World` mutation) if it isn't. Adopt `Test.cancel` in the 6 parameterized tests to skip not-yet-supported verbs/groups at runtime, and consider warning-severity `Issue.record` for aspirational coverage. Cross-reference `docs/code-audit.md` test-gap notes.
- [ ] **Ergonomics (§2):** on the first recompile, let the new "ignored error from a Task" warning run over the ~15 `Task { }` blocks and confirm the LLM tasks' existing `do/catch` coverage; clean up any incidental `(any Foo)?` parentheses.
- [ ] **`@diagnose` (§3):** keep in mind for the SDK migration itself — scoped deprecation handling and optional strict-memory-safety audits of the parser and `Conjugator` index arithmetic.
- [ ] **Module selectors (§4):** opportunistically replace the hand-qualified `SwiftUI.Layout` references in `TutorView.swift` with `SwiftUI::Layout` if/when touching that file.
- [ ] Nothing required for §5–§8; the Foundation/SwiftUI speedups arrive for free on recompile.

---

## Considered and set aside (reviewed, not relevant to Konjugieren)

- **Swift–C interoperability (`@C`, `@implementation`, span bridging to C/C++20).** Konjugieren has no C or C++ code and no C interop surface. The whole rocket-launch demo is inapplicable.
- **Swift-Java (calling async/throwing Swift from Java/Kotlin).** No Java/Kotlin/Android target today.
- **WebAssembly / JavaScriptKit.** Konjugieren is a native iOS app with no web frontend; the Goodnotes Wasm story is interesting but not actionable here.
- **Embedded Swift (existential types, untyped throws, DWARF coredump metadata, `EmbeddedRestrictions`).** No embedded/firmware target.
- **Subprocess 1.0.** A SwiftUI iOS app launches no subprocesses. (The project's *tooling* shells out — `scripts/take_screenshots.sh`, `ios-build-verify` — but those are shell scripts and `xcodebuild`, not Swift `Subprocess`.)
- **`ProgressManager`, `FilePath`, task-cancellation shield.** Covered in §6–§7 as not-applicable; listed here for completeness.
- **The advanced ownership/performance chapter** (borrow/mutate, `Ref`/`UniqueArray`/`UniqueBox`, noncopyable/non-escapable conformances, `Iterable`, `@inline(always)`, `@specialized`). Covered in §8 — set aside except as a speculative future reach behind a profile.
- **Swift Build as the default SwiftPM backend; the build/packaging, networking, and Windows workgroups.** Konjugieren builds from an Xcode project, not a Swift package, and targets only iOS; these are ecosystem news, not project work.

---

Footer: the full verbatim transcript is archived locally at `docs/wwdc2026-whats-new-in-swift-transcript.txt`, which is gitignored (Apple's copyrighted content, kept for reference only, not committed or redistributed). Quotations above are short excerpts from it.
