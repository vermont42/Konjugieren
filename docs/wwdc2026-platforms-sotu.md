# WWDC2026 Platforms State of the Union: Announcements Relevant to Konjugieren

Source: Apple, "Platforms State of the Union", WWDC2026 session 102 (https://developer.apple.com/videos/play/wwdc2026/102/). The transcript was pulled from the page's server-rendered `transcript-content` section on 2026-06-11 and read in full; quotations below are verbatim from it. (WebFetch returns only a small-model summary of a page, which can confabulate plausible-but-false announcements, so the raw transcript nodes were extracted directly and used as ground truth.)

This report covers only what bears on Konjugieren. A "Considered and set aside" list at the end records what was reviewed and judged irrelevant, so the absence of a topic here is a decision, not an oversight.

## Version-numbering note

WWDC2026 previews the fall-2026 releases, numbered 27: iOS 27, iPadOS 27, macOS 27, with Xcode 27 and Swift 6.4. (Apple shifted to year-aligned numbers at WWDC2025, when iOS 26 shipped; this year continues that scheme one step on.) The transcript says "the 27 releases" throughout; a single late mention of "the 2027 releases" looks like a slip. Konjugieren currently targets the 26 era (CLAUDE.md documents iOS 26.3.1 behavior), so "this year's releases" below means the 27 line.

## Executive summary

Ranked by how much each should move Konjugieren's roadmap:

1. **Apple Foundation Models on Private Cloud Compute, at no cloud API cost for developers under two million downloads.** This changes the cost/benefit math in `docs/cloud-llm-tier.md` directly. It offers a credible path to re-lighting the two AI surfaces that ship dark in 1.0, without building the Anthropic backend that memo describes. See "1. Foundation Models" below.
2. **The on-device and cloud Apple models are now built on Gemini technology.** The hallucinations that motivated disabling `explainError` and `recommendPractice` are knowledge errors, the class that model scale fixes. Expect the free Private Cloud Compute model, not the size-limited on-device one, to be the fix; re-test both before committing to any cloud tier.
3. **Xcode 27 and the 27 SDK are Apple-silicon-only.** Josh's development Mac is Intel. This is a hard gate on the new tooling and on building against the 27 SDK at all. It compounds the existing Intel-host Apple-Intelligence eligibility limit already noted in CLAUDE.md. See "5. The Apple-silicon gate".
4. **Image input plus on-device Vision OCR in the Foundation Models framework.** This opens a genuinely new feature for a language app: photograph German text, extract it, then conjugate or explain it.
5. A cluster of free or low-effort wins available on rebuilding against the 27 SDK: Liquid Glass refinements, SwiftUI performance, iOS text selection, toolbar adaptability, and Swift 6.4 ergonomics.

---

## 1. Foundation Models: the headline, and why it reshapes `cloud-llm-tier.md`

Konjugieren's AI surfaces (`ErrorExplainerView`, the Tutor row, the onboarding Tutor page) all route through the `LanguageModelService` protocol, today backed on device by `LanguageModelServiceReal` (Foundation Models, iOS 26+). Two of the protocol's three surfaces ship dark in 1.0 behind `TODO: 1.0-disabled surface` markers (`QuizView.swift:162` for `explainError`, `TutorView.swift:47` for `recommendPractice`), because the on-device model hallucinates fake grammar rules on the long tail. `docs/cloud-llm-tier.md` is the memo proposing to fix that quality gap with a paid, Anthropic-API-backed tier behind a backend proxy.

WWDC2026 introduces four changes that bear on that memo. They should be weighed before any of the memo's implementation work begins.

### What "Foundation Models" now means: three backends, one API

A terminology point, because it is easy to conflate the framework with the one model Konjugieren currently uses. "Foundation Models" is the framework. Konjugieren reaches it today through `SystemLanguageModel`, which is specifically the **on-device** model. As of this year the framework exposes three model backends behind essentially one API, and `SystemLanguageModel` is only one of them:

| Backend | What it is | Cost | Relevance to Konjugieren |
|---|---|---|---|
| `SystemLanguageModel` (on-device) | What Konjugieren uses now. New this year: built on Gemini technology. | Free, offline | The model that hallucinated is being replaced, so re-test it. |
| Apple model on Private Cloud Compute | A larger, different model, reached through the same framework | Free under two million downloads, with a daily per-user quota | The backend most likely to close the long-tail quality gap. |
| Third-party (Claude, Gemini) via the Language Model protocol | A bring-your-own model in a Swift package | Your API cost, plus a key-hosting proxy | The `cloud-llm-tier.md` path, now simpler on the client side. |

The practical consequence: "does Foundation Models perform better now" is two independent experiments, not one. First, does the new on-device `SystemLanguageModel` perform better on the three use cases (same API Konjugieren already calls; if it is clean, the dark surfaces may re-light with no architecture change)? Second, does the Private Cloud Compute model perform better still (a different, larger model, free, reached by selecting it in a Dynamic Profile)? The three use cases are `explainError` and `recommendPractice` (both dark in 1.0) and `sendTutorMessage` (live). Note that `recommendPractice` also has a thin-input problem the memo flags as model-independent, so for that one surface a better model is necessary but not sufficient; it also needs richer grounding, which is what the new Core Spotlight RAG tool (1d) is for.

### 1a. Private Cloud Compute at no cloud API cost

> "developers with fewer than 2 million first-time App Store downloads will be able to use Apple Foundation Models running in Private Cloud Compute with no cloud API cost. It's access to frontier level intelligence with unparalleled privacy protections."

Access is metered per user, not unlimited: "Your users will have access to features leveraging the cloud model every day, and iCloud+ subscribers will have expanded access." Privacy is stronger than the third-party path: "your user's data is not stored or accessible to Apple or anyone else."

Why this matters for Konjugieren:

- Josh is comfortably under two million downloads, so the no-cloud-cost tier applies.
- The two dark surfaces could be re-lit by routing them to the larger Private Cloud Compute model rather than the on-device one, closing the long-tail quality gap that `cloud-llm-tier.md` was written to close, with **zero backend, zero StoreKit plumbing, zero API-key management, and zero marginal cost.**
- The privacy-disclosure burden the memo enumerates (App Privacy nutrition label, `PrivacyInfo.xcprivacy` third-party declaration, an in-app "data sent to Anthropic" note) is much lighter on this path, because data stays inside Apple's privacy-preserving infrastructure rather than going to a third party.
- The per-user daily quota maps onto the memo's "heavy user" worry. The rate-limiting the memo pushes into a proxy is, on this path, handled by Apple's quota.

The strategic consequence: the **quality** motivation behind the paid tier may be satisfiable for free. The **monetization** angle weakens correspondingly, because it is hard to charge for what Apple now gives away. If a paid tier survives at all, its value proposition probably shifts from "better than on-device" to something Private Cloud Compute does not offer, for example a Claude-specific voice and persona, or a long-form "deep dive" surface. That is Josh's call. This report only flags that the premise changed.

### 1b. Third-party models (including Claude) through the same framework

> "we're extending the framework so you can easily call server models like Claude, Gemini, and more to use features like tool calling and guided generation. And any model provider can create a Swift package that conforms to the Language Model protocol."

If Josh still wants Claude specifically (the memo recommends Claude Haiku 4.5), this lets him use a Claude-conforming Language Model package inside the Foundation Models framework: the same `LanguageModelSession` API, guided generation in place of the memo's hand-rolled forced-tool-use JSON, and native streaming. The memo's "Structured output via tool-use" and "Streaming" sections get simpler or moot on this path.

Important caveat, stated precisely so the memo is not over-credited as obsolete: framework integration simplifies the **client** code, but it does not, by itself, eliminate the need to keep an API key off the device. Third-party model credentials still live somewhere. The memo's "Why a backend proxy is non-negotiable" section (do not ship the Anthropic key in the binary; validate StoreKit receipts server-side; rate-limit; log usage) most likely still stands for the Claude path. The keynote did not say Apple proxies third-party models for free; only Apple's own model on Private Cloud Compute is free.

### 1c. The new models are Gemini-derived, so re-test the documented failures first

> "Working together with Google and leveraging the technologies behind their Gemini family of models, we created the latest Apple Foundation models."

The on-device model that produced the documented hallucinations (the "third declension" error on `beseitigen`, the "-en changes to -t" weak-verb rule wrongly applied to the strong verb `singen`, both captured during the 2026-05-17 recording session) is being replaced by a Gemini-derived model. Those specific failures may simply not reproduce.

Concrete first step before any cloud-tier work, on the 27 release: re-run the failure cases from `docs/tutor-test-queries.txt` and the `beseitigen` / `singen` examples against the Private Cloud Compute model first, because that is the expected fix. The on-device model is parameter-ceilinged by phone hardware, so even the Gemini-derived version is a long shot for the explanatory surfaces. Test it too, since if it happens to come back clean the dark surfaces re-light with no backend at all, but do not plan on that. If Private Cloud Compute is clean, the likely outcome, re-light the surfaces there (1a) at no cloud cost. Only if even Private Cloud Compute still hallucinates does the Anthropic backend in `cloud-llm-tier.md` remain the quality answer.

### 1d. Dynamic Profiles, Evaluations, and the new RAG tool

- **Dynamic Profiles** are "new declarative APIs in the Foundation Models framework for building truly adaptive AI experiences with less code", letting one session swap models, tools, and instructions on the fly while sharing a continuous transcript. The demo swapped an on-device `SystemLanguageModel` for a small "explain this jargon" task against a Private Cloud Compute model for a heavier task, in one session. This is the framework-native form of the `HybridLanguageModelService` the memo sketches. Konjugieren's three methods map cleanly onto Profiles: a small on-device Profile for a term-explainer, a Private Cloud Compute Profile for `explainError`, and a chat Profile for `sendTutorMessage`. The entitlement and reachability routing the memo describes still belongs in app code; Dynamic Profiles handle the model-selection layer beneath it.
- **The Evaluations framework** "gives you the ability to test your prompts and validate that your intelligence-powered features work reliably." This is the supported replacement for the memo's hand-rolled "two passes of A/B comparison on ~20 wrong answers and ~20 tutor questions." Use `QuizErrorHistory` plus `docs/frequencies.txt` as the dataset, exactly as the memo suggests.
- **A new RAG tool "powered by Core Spotlight that's private to your app".** This addresses the memo's sharpest critique of `recommendPractice`, that "input grounding is too thin." Indexing Konjugieren's verb data and the conjugationgroup articles (the `verbHistoryText` family) into Core Spotlight would let the model ground answers in the app's real content instead of free-associating from English tense labels.
- **Open-sourcing.** "Later this summer, the framework will be open source. So the same Swift APIs you use in your app can now run on your server too." If a server component is ever wanted, this is an alternative to the memo's Cloudflare-Worker-in-TypeScript proxy: run the Foundation Models Swift API server-side. Heavier than a Worker for Konjugieren's needs, but worth knowing it exists.

### 1e. Supporting tooling

The upgraded Foundation Models instrument, a new `FM` command-line tool that prompts the model from the terminal, and a Python SDK round out the workflow. The command-line tool is useful for the re-test in 1c without launching the full app.

**Action for `cloud-llm-tier.md`:** add a pointer to this report at the top of the memo and mark it "re-evaluate against WWDC2026 before implementing." The architecture it describes is still sound if the Anthropic path is chosen, but the decision to choose that path is now much less certain.

---

## 2. Image input and on-device OCR: a new feature, not just a refinement

> "the framework's capabilities are expanding to include image input and support for server models."

> "the Vision framework is now integrated, giving you purpose-built tools the model can use, such as OCR for precise text extraction, and barcode readers for quick code scanning all on-device."

For a German-learning app this is the most interesting genuinely new capability. A user could photograph a German sign, menu, or book page; Vision OCR extracts the text on device; the model identifies the verbs and offers to conjugate or explain them. This connects Konjugieren to the real-world German a learner actually encounters, which fits the app's pedagogical character. It is a feature idea, not an action item; it belongs in `docs/post-release-features.md` as a candidate.

---

## 3. SwiftUI: free performance, plus three interaction APIs worth adopting

Konjugieren is a SwiftUI app, so the "rebuild and it is faster" improvements arrive at no cost when Josh builds against the 27 SDK:

- **Lazy `@State`.** "SwiftUI now only initializes state objects when they're first loaded", because state "was converted from a dynamic property to a macro." Free win.
- **AsyncImage HTTP caching.** "It now caches its content automatically using standard HTTP caching." Relevant only if Konjugieren loads remote images; most assets are bundled, so low impact.
- **Faster layout.** Nested stack layouts "resize up to twice as fast." Free win, most visible in dense views like `RichTextView` and the conjugation tables.

Interaction APIs worth a closer look:

- **iOS text selection becomes full-fidelity.** On iOS, text selection "gains the same full-fidelity selection already found in TextField and TextEditor." For a reference app, letting users select and copy a conjugation or an article passage is a natural fit. Worth auditing where selectable text would help (conjugation results, `RichTextView` articles).
- **Swipe actions in any container.** `.swipeActions()` plus `.swipeActionsContainer()` now work outside lists. Candidate uses: quick actions on verb-browse rows, or on quiz-history entries.
- **Toolbar adaptability.** The new `visibilityPriority` modifier, an overflow-menu container, and `topBarPinnedTrailing` placement give finer control as width changes. This pairs with resizability (section 4). There is also a "prominent tab role" that pins a tab to the trailing edge; Konjugieren has a five-tab bar (per the CLAUDE.md verification config), so this is worth knowing if tab emphasis is ever wanted.

Reorderable containers (`.reorderable()` / `.reorderContainer()`), a new alert binding API, and cross-fade transition adjustments also shipped, but none maps to an obvious Konjugieren need today.

---

## 4. App resizability: an automatic change to test, not opt into

> "Once you rebuild with the latest SDK, your app is automatically opted in to resizability."

On the 27 SDK, iOS apps become resizable when shown on iPad as an iPhone app and on Mac through iPhone Mirroring. SwiftUI apps are "well on your way" already, but custom views that assume a fixed size can break. Konjugieren has hand-tuned layouts (onboarding, the conjugation tables, the tab-pill geometry the screenshot tooling measures), so this is a "test it" item, not a "build it" item.

Apple shipped two aids: a resizable iOS simulator and Previews for testing across sizes, and, notably, "a skill for coding agents that will help you find and fix common resizability issues." That skill is directly usable in this Claude Code workflow once Josh is on the 27 toolchain. Both aids live in Xcode 27, so both are gated by section 5.

---

## 5. The Apple-silicon gate (read this before planning any 27-era adoption)

Two transcript facts combine into a hard constraint for Josh specifically:

> "macOS Tahoe was the final release to support Intel Macs. The transition of macOS to Apple silicon is now complete."

> "Xcode 27 is 30% smaller. Now, Apple silicon-only."

CLAUDE.md establishes that Josh develops on an Intel Mac. The consequences:

- **Xcode 27 will not run on an Intel Mac.** Josh is capped at Xcode 26 on his current machine.
- Everything that requires building against the 27 SDK is therefore gated behind an Apple-silicon Mac: resizability opt-in (section 4), the recompile that adopts new SwiftUI APIs (section 3), and the recompile that triggers the Liquid Glass old-design removal (section 6).
- **Device Hub, Xcode 27 agentic coding, Previews-for-any-property, and the resizability skill all ship in Xcode 27**, so all are gated too.
- This compounds the limit CLAUDE.md already documents: on an Intel host, the Apple-Intelligence eligibility gate resolves to `deviceNotEligible`, so the Tutor and ErrorExplainer surfaces cannot be exercised on this machine even today. Whether the simulator on an Intel host can reach Private Cloud Compute (section 1a) is unknown and should not be assumed; it likely delegates eligibility to the host the same way the on-device path does. Verify on real Apple-silicon or a real device.

What is not gated: Apple-silicon-only Mac App Store binaries do not affect Konjugieren (it is an iOS app). And one piece of good news lands today on Xcode 26: "ACP support and Gemini integration are shipping in an update to Xcode 26 available today", so Agent Client Protocol and Gemini are usable now without the hardware move.

The honest framing: continuing to ship App Store updates will, on Apple's usual timeline, eventually require building against a recent SDK, which on this timeline means Apple silicon. So the hardware question is a "when", not an "if", for staying current. This report does not recommend a purchase; it flags that the upgrade path now has a hardware prerequisite it did not have last year.

---

## 6. Liquid Glass and design: mostly automatic, one deadline to note

Konjugieren already adopted Liquid Glass in the 26 era, which puts it on the favorable side of these changes:

> "Apps already using Liquid Glass get these improvements automatically when they run on this year's releases without even needing to recompile."

So the refinements (better diffusion of content behind glass, a darkened edge with brighter specular highlights, and a new user-facing settings slider from "ultra clear to fully tinted") reach Konjugieren's users on iOS 27 with no work from Josh. Note the distinction: those visual refinements apply when the app **runs on** the 27 releases; the next item triggers when the app is **built with** Xcode 27.

> "We'll be removing support for opting to use the old design. So once your app is recompiled with Xcode 27, it will automatically begin to use the new design with Liquid Glass."

Because Konjugieren is already on Liquid Glass, this is low risk. The action is a verification, not a migration: confirm no view opted back into the old design, then re-screenshot once on the 27 toolchain (gated by section 5) to confirm the refinements look right.

Icon Composer gained multi-layer Liquid Glass design with selectable refraction. Konjugieren ships three alternate icons (hat, pretzel, bundestag). If Josh ever revisits icon polish, refraction is a low-effort way to add character. Minor, and entirely optional.

---

## 7. Swift 6.4: quality-of-life that fits this codebase

Konjugieren uses Swift 6 with `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`. Swift 6.4 brings several conveniences that touch this project:

- **`anyAppleOS` availability shorthand.** Instead of listing every platform with the same version in an `@available` attribute, write `anyAppleOS`. Tidier wherever availability is annotated.
- **Per-region warning control.** Suppress warnings in specific code, or promote warnings to errors where strict enforcement is wanted. Useful during incremental adoption of new APIs.
- **`async` calls allowed in `defer`.** "The limitation on async calls in a defer block is gone." Removes a small papercut in concurrency code.
- **The "unable to type-check this expression in reasonable time" error is much improved.** This error "can happen in complex operator expressions, closures, or in deeply nested SwiftUI view bodies." Konjugieren has rich bodies (`RichTextView`, `OnboardingView`), so this is a real, if occasional, quality-of-life gain.

All of this requires the Swift 6.4 toolchain, which ships with Xcode 27 (section 5).

---

## 8. Xcode 27 workflow and agentic coding (gated by section 5)

These are appealing but all require Apple silicon. Listed so the value is clear when the hardware question is settled:

- **Device Hub replaces the Simulator.** "It replaces Simulator and it does a whole lot more", unifying simulators and physical devices, with dynamic resizing and the ability to drive a device from the Mac. This is the one Xcode change with a tooling consequence for this project: the `ios-build-verify` skill and the screenshot workflow (`scripts/take_screenshots.sh`, the AXe-driven `launch_app.sh`, `measure_tab_pill.sh`) drive the Simulator today. When Josh moves to Xcode 27, those scripts may need revisiting against Device Hub. Treat this as a tooling-migration item bundled with the Apple-silicon move, not an immediate task.
- **Agentic localization in context.** Xcode "looks at each string in its context, the surrounding code, UI, the action, to find the best translation" and writes into the String Catalog. Konjugieren has a nuanced relocalization workflow (English to German, preserving custom markup, and explicitly not localizing reconstructed PIE forms, god names, or scholarly Latin; see CLAUDE.md). Apple's in-context translator is a useful first draft, but it will not know those rules. Use it as a starting point, then apply the project's relocalization conventions by hand or via this Claude Code workflow.
- **Previews variations for any property.** Pass an enum to a preview and get a grid of every case. Konjugieren is full of small enums (conjugationgroup, person, `QuizDifficulty`, `ThirdPersonPronounGender`, `AppIcon`), so this is a fast way to eyeball every state of a view.
- **Xcode Cloud is easier and faster.** "No App Store Connect setup needed", and builds are "up to twice as fast." A candidate for CI if Konjugieren ever wants automated build-and-test on push.
- **Plugins unify skills, MCP, and agents.** Xcode 27 ships "a corpus of skills, documentation, and MCP tools", and plugins can carry skills (markdown), MCP tools, and, via Agent Client Protocol, an agent of choice. Xcode's built-in agent integration now spans Anthropic, OpenAI, and Google. This is the same skills-and-MCP shape Konjugieren already uses through Claude Code, now inside Xcode.

---

## 9. App Intents and Siri: deepen what is already shipped

`docs/platform-features-plan.md` marks App Intents, Spotlight indexing, and App Shortcuts as already done, with `Verb` exposed as an entity. So the WWDC2026 App Intents news is an enhancement opportunity, not a greenfield one:

- **Entity and intent schemas** let Siri "discover and reason over" app content, and "because these schemas are system-defined, they'll benefit from future updates" without code changes. Caveat: "Schemas cover common app categories like task management, photo editing, and communication." A verb-conjugation app may not map onto a system schema, so the gain here is uncertain. The more applicable piece is the Spotlight semantic index via `IndexedEntity`, which Konjugieren is positioned to use given the existing `Verb` entity.
- **The View Annotations API** lets users "reference and take action on the content in your app when it's on screen", for example "the second message" or "this photo." For Konjugieren this could mean saying "conjugate this verb" about a verb currently on screen. It is a meaningful feature investment, worth a line in `docs/post-release-features.md` rather than immediate work.

---

## 10. Core AI: probably not needed

Core AI is "a brand new framework" for bringing and running your own custom models on device. Konjugieren uses Apple's system model through the Foundation Models framework, not a custom model, so Core AI is not relevant unless Josh ever wants to ship a bespoke German-specific model. One to know about, not to adopt.

---

## Delightful connections (because the work surfaced them)

- **Apple is opening its fifth Developer Center this fall in Berlin**, "home to one of Europe's most vibrant developer and designer communities." For an app whose whole subject is the German language, and which carries a dedication rooted in a German-speaking Ohio town, an Apple Developer Center in Berlin is a fitting place to imagine Konjugieren being shown.
- **Apple keeps choosing language and grammar apps as Foundation Models exemplars.** This year's keynote cited "educational apps like CellWalk"; `platform-features-plan.md` records that Apple previously showcased Grammo, a grammar-learning app. Konjugieren sits squarely in the category Apple repeatedly spotlights. That is an editorial-pitch angle worth keeping warm in `docs/nomination.md`: a German-conjugation app using on-device and Private Cloud Compute intelligence is close to a model citizen for App Store featuring.

---

## Concrete next actions

Immediate (no hardware change required):

- [ ] Add a pointer from `docs/cloud-llm-tier.md` to this report, and mark the memo "re-evaluate against WWDC2026 before implementing."
- [ ] Add the photo-to-conjugation idea (section 2) and the View Annotations idea (section 9) to `docs/post-release-features.md`.
- [ ] Note in `docs/nomination.md` the renewed editorial fit (CellWalk / Grammo lineage).
- [ ] Decide the hardware question framed in section 5; it gates most of the rest.
- [ ] (Available today on Xcode 26) Try the ACP and Gemini integration if useful.

On the 27 release / Apple-silicon toolchain:

- [ ] Re-run the documented hallucination cases (`beseitigen`, `singen`, `docs/tutor-test-queries.txt`) against the Private Cloud Compute model first (the expected fix), then against the on-device model as a cheaper long shot. This decides whether the dark surfaces re-light at no cloud cost (sections 1a, 1c).
- [ ] If re-lighting via Private Cloud Compute: add a Profile-based path in `LanguageModelServiceReal` (or a new conformance), wire the privacy disclosures appropriate to Apple's infrastructure, and revise App Store metadata in lockstep, as `cloud-llm-tier.md` already warns.
- [ ] Build against the 27 SDK in a branch and test resizability across sizes (section 4); use Apple's resizability skill.
- [ ] Re-screenshot once to confirm Liquid Glass refinements and the old-design removal look right (section 6).
- [ ] Revisit the `ios-build-verify` and screenshot scripts against Device Hub (section 8).

---

## Considered and set aside (reviewed, not relevant to Konjugieren)

- **MLX** (array framework for training and research): for model builders, not app consumers.
- **Reality Composer Pro 3, Spatial Preview framework**: visionOS / 3D authoring; Konjugieren is a 2D iOS app.
- **Game Porting Toolkit, Metal command-line tools**: for porting native games; the Konjugieren quiz is not a Metal game.
- **SwiftUI document infrastructure** (first-class file URL access, partial reads/writes): for document-based apps like Pages or Xcode; Konjugieren persists small settings through `GetterSetter`, not documents.
- **macOS-specific design items** (sidebar expansion, the `show borders` value on macOS 27, window corner radius, menu-picker performance): no macOS target.
- **Apple-silicon-only Mac App Store binaries**: no Mac App Store build.
- **Swift server, Linux/Windows/Android, WebAssembly, kernel-in-Swift**: outside an iOS app's scope, however interesting.

---

Footer: the full verbatim transcript is archived locally at `docs/wwdc2026-platforms-sotu-transcript.txt`, which is gitignored (Apple's copyrighted content, kept for reference only, not committed or redistributed). Quotations above are short excerpts from it.
