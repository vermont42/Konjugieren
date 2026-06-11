# WWDC2026 "What's New in SwiftUI": Announcements Relevant to Konjugieren

Source: Apple, "What's new in SwiftUI", WWDC2026 session 269 (https://developer.apple.com/videos/play/wwdc2026/269/). Presenters: Steven and Julia, UI Frameworks engineers. The transcript was pulled from the page's server-rendered `#transcript-content` section on 2026-06-11 (76 timestamped segments, ~23.5K characters) and read in full; quotations below are verbatim from it. (WebFetch returns only a small-model summary of a page, which can confabulate plausible-but-false announcements, so the raw transcript nodes were extracted directly and used as ground truth — the same method used for the Platforms SOTU report.)

This is the SwiftUI-specific companion to [`docs/wwdc2026-platforms-sotu.md`](wwdc2026-platforms-sotu.md). The SOTU report's section 3 previewed SwiftUI at altitude; this report goes deeper on the dedicated talk, naming the exact APIs and — crucially — checking each one against Konjugieren's actual code, so the verdict is "this matters / this is already safe / this does not apply here," not just "Apple announced X." Its language-side sibling is [`docs/wwdc2026-whats-new-in-swift.md`](wwdc2026-whats-new-in-swift.md) (session 262), covering the Swift 6.3/6.4 language, standard library, and Swift Testing changes.

This report covers only what bears on Konjugieren. A "Considered and set aside" list at the end records what was reviewed and judged irrelevant, so the absence of a topic here is a decision, not an oversight.

## Version-numbering note

This talk's transcript refers to "the 2027 releases" repeatedly (segments at 0:32, 8:29, 22:57, 25:44, 26:28, 27:23) while also saying "iOS 27", "Xcode 27", and "iOS 17, macOS 14". The Platforms SOTU report's version-numbering note treated "2027" as a one-off slip against a "27 releases" norm; this session shows "the 2027 releases" is actually a recurring house phrasing across WWDC2026 sessions, not a slip. The substance is unchanged either way: the product numbers are unambiguously **27** (iOS 27, iPadOS 27, macOS 27, Xcode 27), previewed June 2026 and shipping fall 2026, one step on from the 26 line Konjugieren targets today. Below, "this year's releases" means that 27 wave; "Xcode 27" means the toolchain that builds against its SDK.

## The Apple-silicon gate applies to almost everything actionable here

Before the rankings: the SOTU report's section 5 established that **Xcode 27 is Apple-silicon-only and Josh develops on an Intel Mac.** This talk makes that gate bite harder than the SOTU summary implied, because the SwiftUI wins split into two buckets and the valuable bucket is gated:

- **Runtime-only (arrive when the user's device runs iOS 27, no rebuild):** the Liquid Glass refinements (§6). That is essentially the whole no-rebuild list for Konjugieren, because the other "automatic" runtime win — AsyncImage HTTP caching — does not apply (Konjugieren has no `AsyncImage`; see §7).
- **Build-time (require building against the 27 SDK with Xcode 27 → Apple silicon):** the `@State` macro and its lazy-init benefit (§1), the ContentBuilder type-check speedup (§2), the Xcode 27 SwiftUI agent skills (§3), resizability testing tools (§4), and every new interaction API — toolbar (§5), swipe, reorder, dialog binding (§7).

So the honest headline is: the SwiftUI improvements most worth having are real and well-matched to this codebase, and they are waiting behind the same hardware decision section 5 of the SOTU report already framed. This report does not re-argue that decision; it sharpens what is on the far side of it.

## Executive summary

Ranked by how much each should move Konjugieren's roadmap:

1. **`@State` becomes a macro, giving lazy single-initialization of stored classes — and Konjugieren is verified safe from the one source-breaking change it introduces.** This is the headline *for Konjugieren specifically*, because it is both a free correctness/perf win for `MainTabView`'s `quiz` and `GameView`'s `gameState`, and a migration trap that an audit of the real code confirms Konjugieren sidesteps. See §1.
2. **`ContentBuilder` unifies SwiftUI's result builders and substantially speeds up type-checking** — even when targeting older OSes — directly attacking the "unable to type-check this expression in reasonable time" error that CLAUDE.md and the SOTU Swift-6.4 note already call out. Konjugieren's dense bodies (`RichTextView`, `OnboardingView`, `FamilyDetailView`) are exactly the beneficiaries. See §2.
3. **Xcode 27 ships official SwiftUI agent skills that export to portable Markdown via `xcrun agent skills export`.** This is the announcement most directly relevant to *this* Claude Code workflow, which already runs on a skills-and-MCP footing (`ios-build-verify`, the bundled `swiftui-expert-skill`). See §3.
4. **iPhone apps become resizable on iOS 27 — a "test it" item, low-risk here** because Konjugieren is idiomatic SwiftUI with zero UIKit interop. See §4 (cross-references SOTU §4).
5. **Toolbar refinements**, of which `toolbarMinimizeBehavior(.onScrollDown)` is the one genuinely worth adopting for Konjugieren's scrolling reference views; the crowding APIs matter less because Konjugieren's toolbars are sparse. See §5.
6. **Liquid Glass refinements arrive automatically at runtime** on iOS 27, since Konjugieren already adopted Liquid Glass. See §6 (cross-references SOTU §6).
7. A cluster of APIs that are real but **do not currently apply** to Konjugieren — AsyncImage caching, `confirmationDialog`/`alert` item-binding, swipe-actions-anywhere, reorderable containers, the prominent tab role — each set aside with the codebase reason. See §7.
8. **The talk's actual headline, the new Document API, is not relevant to Konjugieren**, which is not a document-based app. See "Considered and set aside."

---

## 1. `@State` becomes a macro: free lazy init, and a source-break Konjugieren dodges

This is the SwiftUI change with the most direct, verifiable consequence for Konjugieren's code.

> "In the 2027 releases, for the first time, classes initialized and stored using State properties are now lazy, which means they will only be initialized once. This is thanks to the conversion of State from a Dynamic Property to a macro!"

> "this behavior has been back ported to the releases where @Observable was first introduced, starting with iOS 17, macOS 14, and aligned releases."

### The win

Previously, a `@State private var x = SomeObservableClass()` re-ran `SomeObservableClass()` on every re-initialization of the view, then discarded the new instance because `@State` keeps the first one. Now the initializer runs once. Konjugieren has exactly two `@State`-stored `@Observable` classes, and both benefit:

- `MainTabView.swift:7` — `@State private var quiz = Quiz()` (`Quiz` is `@Observable`)
- `GameView.swift:6` — `@State private var gameState = GameState()` (`GameState` is `@Observable`)

Konjugieren's other ~47 `@State` properties hold value types (`Bool`, `CGFloat`, `String`, `Int`, arrays, `NavigationPath`, enums, optionals); the lazy-class benefit does not apply to them, but there is no downside either. Because Konjugieren leans on `@Observable` throughout (`Settings`, `World`, `Quiz`, `GameState`, `GameCenterReal`, `LanguageModelServiceReal`), it is squarely in the population this change was designed for.

Note on delivery: the benefit comes from the **macro**, which you get by building with the Xcode 27 toolchain; Apple states the behavior is "back ported" in effect to deployment targets as old as iOS 17 / macOS 14, so once rebuilt, `quiz` and `gameState` initialize once on every OS Konjugieren supports — not only iOS 27. The exact runtime-vs-toolchain delivery of the back-port is worth confirming in the released documentation, but the practical takeaway is unambiguous: rebuild on Xcode 27 and the two stored classes stop being re-created. This is therefore gated by the Apple-silicon requirement (SOTU §5), like the rest of the build-time bucket.

### The source-break — and why Konjugieren is already safe

> "the introduction of the state macro can be a source-breaking change. For example, if you specify a default value for your @State variable, and then you assign a value to the same @State variable inside your init, Xcode will show an error about use before initialization. To resolve this error, remove the unnecessary default value assignment."

The dangerous pattern is precise: a `@State` property with a **default value** *plus* an **assignment to that same property inside a custom `init()`** (typically written `_x = State(...)` or a direct `x = ...`). An audit of the codebase confirms Konjugieren does not contain it:

- An app-wide search for the underlying-storage assignment form (`_<name> = State(...)`, `State(initialValue:)`, `State(wrappedValue:)`) returns **zero matches**.
- The only two custom `View` initializers that coexist with `@State` properties are in `OnboardingView.swift`:
  - `OnboardingView.init(isReshow:)` (line 18) assigns only `self.isReshow` — a `let` stored property. Its `@State` vars (`currentPage`, `getStartedOffset`, `getStartedOpacity`) keep their defaults and are never touched in `init`.
  - The `OnboardingPage` helper's `init(...)` (line 173) assigns only `let` properties (`symbolName`, `title`, `bodyText`, …). Its `@State` vars (`showingSheet`, `contentOffset`, `contentOpacity`, `bounceValue`) likewise keep their defaults.

Because every custom initializer assigns exclusively to `let` properties and never to `@State`, the "use before initialization" error cannot arise. **Verdict: the `@State` macro is pure upside for Konjugieren — no migration work, with the lazy-init benefit on rebuild.** Re-run the build once on Xcode 27 to confirm no new diagnostics, but none are expected from this change.

---

## 2. `ContentBuilder` and the type-check performance fix

> "If your app has complex, deeply nested views, you may have encountered this error: 'The compiler is unable to type-check this expression in reasonable time'."

> "multiple different builder types have been unified under a single builder: ContentBuilder! This is a step towards enabling unified builders across all of SwiftUI's APIs. And ContentBuilder can be used with any minimum deployment target, because under the hood, it's an evolution of the existing ViewBuilder."

> "ContentBuilder provides a substantial improvement in type checking performance in SwiftUI when building using Xcode 27; whether you're targeting the 2027 releases, or previous releases as well."

The talk's explanation is worth internalizing: the old slowness came from the compiler having to try every overload of `Section`, `Group`, `ForEach`, etc. (each can build a `View` *or* `TableRowContent`) and resolve the whole nested decision tree. Unifying the common builders under one `ContentBuilder` initializer collapses that to "one straightforward path."

Why this matters for Konjugieren: this is precisely the error CLAUDE.md's Swift-6.4 note and the SOTU report (§7) already flag as an occasional pain in this codebase's rich bodies. The concrete beneficiaries are the deeply nested views — `RichTextView.swift` (the markup renderer that builds heterogeneous runs of headings, bold, ablaut highlights, links, and bullet rows), `OnboardingView.swift` (paged, animated, conditionally including the Tutor page), and `FamilyDetailView.swift` (nested prefix/ablaut lists with expandable groups). The win is automatic on building with Xcode 27 and, helpfully, applies even while Konjugieren still targets the 26 line — no deployment-target bump required. Gated by Apple silicon (SOTU §5).

Worth a delightful footnote for the codebase: CLAUDE.md already carries a SwiftUI convention note — "@ViewBuilder Has No Child Limit … removed in Swift 5.9 via variadic generics." `ContentBuilder` is the *next* chapter of that same `ViewBuilder` lineage. The convention note and this announcement are two points on one continuous evolution of how SwiftUI assembles view content. (More in "Delightful connections.")

---

## 3. Xcode 27 SwiftUI agent skills — exportable to Markdown for this workflow

> "We're also excited to introduce new agent skills included with Xcode 27 to help you adopt the new features from the 2027 releases in your apps, and improve your app's performance and code correctness."

> "The SwiftUI Specialist Skill can help you follow SwiftUI best practices in your apps. The What's New In SwiftUI Skill can guide you through adopting new APIs from the 2027 releases. Both of these skills can be accessed in the Coding Assistant in Xcode 27. And to use these skills with other tools, you can export them with the 'xcrun agent skills export' command. This will create markdown files you can import in your workflows."

This is the announcement with the most direct bearing on how Konjugieren is *built* day to day, because this repository already runs on a skills-and-MCP workflow: `ios-build-verify` for build/verify, a bundled `swiftui-expert-skill` for SwiftUI guidance, plus the `cupertino` documentation MCP. Apple now ships two first-party skills in the same shape:

- **SwiftUI Specialist Skill** — best-practices guidance, conceptually overlapping the bundled `swiftui-expert-skill`. Apple's is authored by the framework team, so it is a strong candidate to complement (or be cross-checked against) the existing one.
- **What's New In SwiftUI Skill** — a guided adoption path for the 27 APIs, i.e. an authoritative companion to *this very report*.

The portability detail is the important part: `xcrun agent skills export` produces **Markdown files importable into other agent workflows** — including this Claude Code setup, where skills are exactly Markdown. So Apple's official SwiftUI skill content could live alongside Konjugieren's existing skills.

The gate, stated honestly: `xcrun` ships with Xcode 27, so *obtaining* the exported Markdown requires the Apple-silicon toolchain (SOTU §5). But once exported, the Markdown is plain text and portable — it would run in this Intel-Mac Claude Code workflow without needing Xcode at all. So this is "gated to acquire, unrestricted to use." A natural first task on the day Josh moves to Apple silicon: run the export and drop the two skills into the workflow.

---

## 4. Resizability: a low-risk "test it" item here

> "And on iOS 27, our iPhone app becomes resizable too."

> "Apps built with SwiftUI gain a lot of this functionality automatically, but if your app uses both UIKit and SwiftUI, there may be some additional things to consider."

The SOTU report (§4) already covers resizability as a "test it, don't build it" item and notes Konjugieren's hand-tuned layouts. This talk adds two clarifications that lower the risk for Konjugieren specifically:

- **No UIKit-interop caveats apply.** A search for `UIViewRepresentable`, `UIViewControllerRepresentable`, `UIHostingController`, `UINavigationController`, and `UITableView` returns zero matches: Konjugieren is idiomatic SwiftUI (`TabView`, `NavigationStack`/`NavigationPath`, `@State`/`@Observable`). The talk's referral to the "Modernize your UIKit app" session — for apps mixing UIKit and SwiftUI, needing to handle size classes vs. idiom, screen geometry, and orientation changes — does not apply here. Konjugieren is in the "gain a lot automatically" group.
- **Xcode 27 Live Previews gain resize handles** for interactively testing how a view responds to resizing (useful for iPhone-on-iPad and iPhone Mirroring). This is the convenient way to exercise the hand-tuned layouts the SOTU report flags — onboarding pages, the conjugation tables, and the tab-pill geometry the screenshot tooling measures. Gated by Apple silicon (SOTU §5).

Net: still a verification rather than a build, and a comparatively safe one given the clean SwiftUI baseline. Test the known-fragile layouts across sizes once on the 27 toolchain.

---

## 5. Toolbar refinements: one clear adopt, the rest low-priority

The talk introduces four toolbar APIs, all aimed at toolbars that get crowded as windows resize:

> "I can do this by adding the new visibilityPriority modifier, and setting the priority to high."

> "I choose to always place these buttons in the overflow menu by grouping them in the new ToolbarOverflowMenu container."

> "I can use the new topBarPinnedTrailing placement to make the Share button always visible in the trailing position."

> "So I add the new toolbarMinimizeBehavior modifier, and set it to 'onScrollDown' for the navigationBar placement. Now, the system automatically moves the navigation bar out of the way when I scroll."

How this maps to Konjugieren's actual toolbars (`QuizView`, `InfoBrowseView`, `TutorView`, `TutorTestView` — each typically a single `cancellationAction` plus a `principal` title):

- **`visibilityPriority`, `ToolbarOverflowMenu`, `topBarPinnedTrailing`** solve a crowding problem Konjugieren does not have — its toolbars hold one or two items and will never overflow. Low priority; know they exist if a future view grows a busy toolbar.
- **`toolbarMinimizeBehavior(.onScrollDown)`** is the one worth adopting. It reclaims vertical space by sliding the navigation bar away as the user scrolls — a natural fit for Konjugieren's scrolling reference surfaces: the verb list in `VerbBrowseView`, long Info articles rendered by `RichTextView`/`InfoView`, and the `TutorView` chat transcript. Pure polish, low effort, build-time (Xcode 27).

Two smaller appearance refinements from the same stretch of the talk, both marginal for an iOS-only single-window app: the `appearsActive` environment value (conditionally dim custom controls when a window is inactive — relevant to multi-window/Mac/iPad, used in the demo's sidebar account button) and `labelStyle(.titleAndIcon)` to force an icon back into the now-minimal iPad/Mac menu bars. Konjugieren has neither a custom inactive-state control need nor a menu bar to tune.

---

## 6. Liquid Glass refinements: automatic at runtime

> "the Liquid Glass design automatically takes on its updated appearance. Apps gain this look without having to change a single line of code!"

> "Liquid Glass has a refined look and automatically responds to the new Liquid Glass slider to adjust its tint."

Konjugieren already adopted Liquid Glass in the 26 era, so this is the one bucket that needs no Apple-silicon move: the refined look and the response to the user's new system tint slider reach Konjugieren's users when their devices run iOS 27, with no rebuild. This restates SOTU §6 from the SwiftUI side; see that section for the "runs on 27" vs. "built with Xcode 27" distinction and the one-time re-screenshot verification (which is itself gated by §5). The macOS-only "mark custom Liquid Glass elements as interactive" point from this talk does not apply (no Mac target).

---

## 7. Real APIs that do not currently apply to Konjugieren

Each of these is a genuine SwiftUI 27 feature, checked against the code and set aside with the reason — so a future reader knows it was evaluated, not missed.

- **AsyncImage HTTP caching** — *"AsyncImage now supports standard HTTP caching … enabled automatically for every app."* Konjugieren contains **no `AsyncImage`** (grep: zero matches); all imagery is bundled assets, and no code path loads a remote image (its app-code `URLSession` use is non-image — e.g. `RatingsFetcher`'s iTunes lookup, which returns the App Store rating string as JSON). This sharpens the SOTU report's tentative "low impact" to a definite **zero impact**. (If a future feature ever streams remote images — e.g. illustrated verb cards — the new `URLRequest`/`URLSession`/`asyncImageURLSession` customization hooks would then matter.)
- **`confirmationDialog` / `alert` item-binding** — *"confirmation dialogs support the same item-binding pattern that sheets use … And this also works with alert!"* Konjugieren uses **neither** `confirmationDialog` nor `.alert(` (grep: zero matches); its "Enjoying Konjugieren?" review prompt is a custom surface, not a system alert. Nothing to migrate.
- **Swipe actions on any view** (`swipeActions` + `swipeActionsContainer` beyond `List`) — Konjugieren has no swipe actions today and only one `List` (`ResultsView`); its browse rows are not in row-action contexts. The API lowers the barrier *if* a row action (favorite, share a verb) is ever wanted, but there is no current need.
- **Reorderable containers** (`Reorderable` + `reorderContainer`, working in any container, backed by swift-collections' `difference.apply`) — Konjugieren has no user-reorderable content; verb and family ordering is frequency- or data-driven, not user-arranged. Set aside, consistent with SOTU §3's read.
- **Prominent tab role** — Konjugieren's `MainTabView` has five content tabs (verbs, families, quiz, info, settings; this is the 5-tab geometry CLAUDE.md's `MAIN_TABS_COORDS` calibrates). The prominent role is for an *accessory* tab distinct from content — a cart or search pinned to the trailing edge — which none of Konjugieren's five are. Worth knowing if tab emphasis is ever wanted; no natural use today. (Konjugieren already uses the modern `Tab(value:)` API, so it is current on the tab front.)

---

## Delightful connections (because the work surfaced them)

- **One continuous thread from a CLAUDE.md convention to this year's headline compiler win.** CLAUDE.md instructs: "@ViewBuilder Has No Child Limit — The old 10-child @ViewBuilder limit was removed in Swift 5.9 via variadic generics." This talk reveals the next step in that exact lineage: the new `ContentBuilder` is, in the presenters' words, "an evolution of the existing ViewBuilder," unifying the result builders so the type-checker stops exploring a combinatorial decision tree. The 10-child limit (gone via variadic generics), and the type-check blowup (now tamed via builder unification), are two symptoms of the same underlying thing — how much type-level work `ViewBuilder` has to do — being progressively engineered away. The convention note Josh already keeps and this WWDC announcement are the same story, three Swift versions apart.
- **A small etymological wink hiding in the engineering.** The reorderable demo commits its changes through swift-collections' `CollectionDifference.apply` — the standard library's diffing machinery, an implementation of Eugene Myers's 1986 diff algorithm, the same lineage that powers `git diff`. A verb app whose whole craft is tracking how a stem *changes* form (sing → sang → sung) is, under the hood, offered ordering by a framework that models change itself as a first-class `Difference`. Ablaut and diffing are both, at root, the disciplined study of what stays and what shifts.

---

## Concrete next actions

Immediate (no hardware change required):

- [ ] Add a cross-reference from `docs/wwdc2026-platforms-sotu.md` §3 to this deeper SwiftUI report (done as part of landing this doc).
- [ ] No `@State` migration is required — §1 verified Konjugieren is safe. Keep this finding in mind if a future view ever gains a custom `init()` that assigns to a `@State` property with a default value.

On the 27 release / Apple-silicon toolchain (all gated by SOTU §5):

- [ ] Rebuild on Xcode 27 and confirm a clean build (expect the lazy-`@State` benefit for `quiz`/`gameState`, no new diagnostics) — §1.
- [ ] Run `xcrun agent skills export` and import Apple's "SwiftUI Specialist" and "What's New In SwiftUI" skills into this Claude Code workflow as Markdown — §3.
- [ ] Confirm the ContentBuilder type-check speedup on the dense bodies (`RichTextView`, `OnboardingView`, `FamilyDetailView`) — §2.
- [ ] Test the hand-tuned layouts across sizes with the new Live Preview resize handles — §4.
- [ ] Consider `toolbarMinimizeBehavior(.onScrollDown)` on the scrolling reference views (verb list, Info articles, Tutor chat) — §5.
- [ ] Re-screenshot once to confirm the Liquid Glass refinements render correctly — §6 (and SOTU §6).

---

## Considered and set aside (reviewed, not relevant to Konjugieren)

- **The new SwiftUI Document API** — the talk's actual centerpiece (`DocumentGroup`, `DocumentCreationSource`, `NewDocumentButton`, `WritableDocument`/`ReadableDocument`, `DocumentWriter`/`DocumentReader`, `PageSnapshot`, `Subprogress`-based write progress, multi-format export to PNG via Core Graphics). Konjugieren is **not a document-based app**: it persists small settings through `GetterSetter`/UserDefaults, not user-authored document files with open/save/autosave semantics. This is the same call the SOTU report made when it set aside "SwiftUI document infrastructure." If Konjugieren ever shipped an export-a-conjugation-table-as-a-file feature it would revisit this, but nothing on the roadmap implies it.
- **macOS-specific items** — interactive Liquid Glass elements optimized for the mouse pointer, the minimal Mac/iPad menu-bar icon default. No macOS target.
- **iPad inactive-window dimming and `appearsActive`** — multi-window/active-state affordances; marginal for an iOS-first single-window app.
- **watchOS reordering** ("reordering capabilities to watchOS for the first time") — no watchOS target. (A Watch companion is a *future* idea tracked in `docs/post-release-features.md`; if it ships, revisit.)
- **"Modernize your UIKit app" session** — for apps mixing UIKit and SwiftUI; Konjugieren has no UIKit interop (§4).
- **"Build powerful drag and drop in SwiftUI" code-along** — deep dive on reorderable/drag-drop; no current Konjugieren need (§7).
- **swift-collections `difference.apply`** — only needed to commit reordering changes, which Konjugieren does not do.

---

Footer: the full verbatim transcript is archived locally at `docs/wwdc2026-whats-new-swiftui-transcript.txt`, which is gitignored (Apple's copyrighted content, kept for reference only, not committed or redistributed). Quotations above are short excerpts from it.
