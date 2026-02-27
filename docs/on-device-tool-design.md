# On-Device Tool Design Guide

Lessons learned from implementing Foundation Models `Tool` conformances for the tutor's `LanguageModelSession`. These principles apply to any tool added to the app's on-device model sessions.

## Core Principle

**Minimize what the model must decide.** Push complexity into tool code, not the tool schema. The on-device model makes one decision (which verb + which conjugationgroup); the tool handles everything else deterministically.

This is the opposite of designing for a large cloud model, which can handle rich multi-parameter tools. On-device models need the simplest possible contract.

## Context Budget

Tool schemas consume prompt space. The Foundation Models `Tool` protocol injects tool definitions (name, description, every `@Guide`) into the prompt *before* the user's message. The on-device model has a combined input/output limit of 4096 tokens, and verbose schemas crowd out actual conversation space.

Apple's guidance is explicit: reduce `@Guide` descriptions to a short phrase each.

**Before (model refused to call tool):**
```swift
@Guide(description: "The tense to conjugate in. One of: Present Indicative, Past Indicative, Present Subjunctive, Past Conditional, Present Perfect, Present Perfect Subjunctive, Pluperfect, Pluperfect Conditional, Future, Future Subjunctive, Future Conditional, Imperative, Past Participle, Present Participle")
var conjugationgroup: String  // 332 characters
```

**After (model calls tool reliably):**
```swift
@Guide(description: "The tense in English, e.g. Past Indicative, Present Indicative")
var conjugationgroup: String  // 56 characters
```

## Fewer Parameters

Remove optional parameters the model handles poorly. When `ConjugationTool` had a `person` parameter, the model was expected to make six tool calls (one per pronoun) to fetch a full paradigm. It reliably fetched only three (ich, du, er) before stopping.

**Fix:** Remove the `person` parameter entirely. When the model omits it, the tool iterates all six pronouns internally and returns the complete paradigm in one call.

```swift
let pronouns = ["ich", "du", "er", "wir", "ihr", "sie"]
var lines: [String] = []
for pronoun in pronouns {
  guard let conjugationgroup = Self.buildConjugationgroup(name: arguments.conjugationgroup, person: pronoun) else {
    continue
  }
  let result = Conjugator.conjugate(infinitiv: arguments.infinitiv, conjugationgroup: conjugationgroup)
  if case .success(let conjugation) = result {
    lines.append("\(pronoun) \(conjugation.lowercased())")
  }
}
```

## Structured Output

Return labeled results so the model echoes correct terminology rather than guessing.

**Before:** Tool returned bare `"sang"` — model misattributed it as "present participle."

**After:** Tool returns `"ich sang (Past Indicative)"` — model echoes the label accurately.

The label comes from `conjugationgroup.englishDisplayName`, keeping terminology authoritative and consistent with the rest of the app.

## Ablaut Stripping

`Conjugator` output uses mixed case to mark ablaut changes (e.g., `sAng`, `gesUngen`) for UI highlighting in `RichTextView`. In plain-text chat, this is confusing.

**Fix:** Call `.lowercased()` on conjugation output before returning it to the model:

```swift
return "\(conjugation.lowercased()) (\(conjugationgroup.englishDisplayName))"
```

## Fuzzy Parsing

The model's free-text `conjugationgroup` parameter won't always match exact names. Use `contains()` with ordered specificity — check longer, more specific names before shorter ones that are substrings.

```swift
// Check "Present Perfect Subjunctive" BEFORE "Present Perfect"
if lowercasedName.contains("present perfect subjunctive") {
  return .perfektKonjunktivI(personNumber)
}
if lowercasedName.contains("present perfect") {
  return .perfektIndikativ(personNumber)
}
```

Without this ordering, "Present Perfect Subjunctive" would match the "Present Perfect" check first and return the wrong conjugationgroup.

## German-to-English Mapping

The on-device model doesn't reliably know that Prateritum = Past Indicative. Include the most important mappings directly in the session instructions:

```swift
private static let tutorInstructions = """
  You are a German verb conjugation tutor. Answer concisely. Use the conjugateVerb tool \
  to look up conjugations instead of guessing. Präteritum means Past Indicative. \
  Präsens means Present Indicative. Konjunktiv II means Past Conditional. \
  If asked something unrelated to German verbs, politely redirect.
  """
```

Keep these mappings to the three or four most commonly confused pairs. Listing all fourteen conjugationgroups consumes too much context budget.

## Actor Isolation and `Tool` Protocol

The `Tool` protocol requires `Sendable`, which forces all members of the conforming struct to be `nonisolated` — even in a module with `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`. This means `call(arguments:)` cannot directly access any `@MainActor`-isolated code (which, under default isolation, is everything else in the module).

**Fix:** Extract the main-actor work into an explicitly `@MainActor` helper that `call` awaits:

```swift
func call(arguments: Arguments) async throws -> String {
  await Self.performLookup(infinitiv: arguments.infinitiv, conjugationgroupName: arguments.conjugationgroup)
}

@MainActor private static func performLookup(infinitiv: String, conjugationgroupName: String) -> String {
  // All conjugation logic here — can freely call Conjugator.conjugate,
  // access .englishDisplayName, etc.
}
```

This pattern will be needed by every `Tool` conformance in the project.

## Concise Instructions

Verbose instructions can cause small models to refuse entirely. The tutor instructions went from ~650 characters (detailed behavioral guidance) to ~250 characters (essential mappings only) across iterations.

**Guideline:** If the model refuses to respond or stops calling the tool, the first thing to try is shortening the instructions.

## Constrained Generation with `.anyOf`

When a `@Guide` parameter has a known set of valid values, use `.anyOf` instead of a free-text description with examples. The on-device model is trained specifically for guided generation and reliably picks from constrained sets.

**Before (model defaulted to first example 60% of the time):**
```swift
@Guide(description: "Tense name, e.g. Präteritum, Perfekt, Futur, Imperativ")
var conjugationgroup: String
```

**After (model picks from valid set):**
```swift
@Guide(description: "Tense from the question", .anyOf([
  "Präsens", "Präteritum", "Perfekt", "Plusquamperfekt",
  "Futur", "Imperativ", "Partizip I", "Partizip II",
  "Konjunktiv I", "Konjunktiv II"]))
var conjugationgroup: String
```

This eliminated wrong-tense errors where the model sent "Präteritum" for present tense, future tense, and participle queries. The model can only choose from the listed values, and the parser handles all of them.

Note that `.anyOf` values consume prompt space, so keep the list minimal — include only the values the tool code can resolve. For truly fixed sets, `@Generable` enums are even tighter (the model is constrained to enum cases at the type level).

## Example Ordering Bias

When a `@Guide` includes examples or an `.anyOf` array, the model defaults to the first value when uncertain. In testing, the model sent "Präteritum" for present tense, present participle, and future tense queries — all because Präteritum was listed first in the `@Guide`.

**Fix:** Lead with the most commonly requested value, not the most "obvious" one. For conjugationgroups, Präsens is asked about far more often than Präteritum. Reordering the `.anyOf` array to start with Präsens eliminated the default-to-Präteritum pattern.

## Instruction Emphasis with ALL CAPS

The on-device model responds to ALL CAPS for critical directives. When "Always call conjugateVerb" produced inconsistent tool usage (model sometimes answered from memory or refused), changing to "ALWAYS call conjugateVerb" increased the tool-call rate.

Use sparingly — one or two ALL CAPS words per instruction set. Overuse dilutes the emphasis.

## Descriptive Error Messages

When the tool can't fulfill a request, return a message the model can relay gracefully.

**Before:** `"Could not parse conjugationgroup \"Präsens\"."`

**After (verb not found):** `"\"pizza\" is not a recognized verb."`

**After (tense not parsed):** Lists valid tense names so the model can self-correct on a retry.

The model echoes error messages nearly verbatim, so write them as if a user will read them directly.

## Non-Determinism

The on-device model does not produce identical results across runs. In a 15-scenario test suite, 2 tests that passed in one run regressed in the next with no code changes. Expect ~10–20% variation.

**Implications:**
- Don't over-tune instructions for a single failing scenario — fixing one test may regress another.
- Evaluate changes across the full test suite, not just the targeted scenario.
- A test harness that runs all scenarios in sequence (like `TutorTestView`) is essential for measuring net improvement.

## Iteration Summary

| Round | Change | Result |
|-------|--------|--------|
| 1 | Verbose schema (332-char `@Guide`), verbose instructions (~650 chars) | Model refused to call tool |
| 2 | Trimmed all `@Guide` descriptions to short phrases, shortened instructions | Model called tool but returned ablaut markup, misattributed terminology |
| 3 | Added labeled output (`"ich sang (Past Indicative)"`), `.lowercased()` | Correct terminology, but only fetched 3 of 6 persons |
| 4 | Removed `person` parameter, tool iterates all 6 pronouns internally | One call, complete paradigm, fully correct |
| 5 | Rewrote instructions (~270 chars), expanded fuzzy parser with bare-name fallbacks, fixed third-plural bug (`PersonNumber.allCases` instead of pronoun array), added descriptive error messages | 9/15 scenarios pass (up from 3/15). Bare "Präsens", "Konjunktiv II", etc. now resolve. Model still defaulted to Präteritum for wrong tenses. |
| 6 | Added `.anyOf` constraint (10 German tense names), ALL CAPS "ALWAYS call", reordered examples (Präsens first), added Partizip I/II mappings in instructions | 11/15 pass. Wrong-tense errors eliminated. Two previously-passing tests showed non-deterministic regression. |
| 7 | Added "Use German infinitives" to instructions | Targets regression where model sent English "sing" instead of German "singen" |
| 8 | Expanded `.anyOf` from 10 to 14 values (added compound tenses), reordered parser for ordered specificity, added Konjunktiv I/II and ablaut mappings to instructions, markdown stripping, retry loop (0→3), refusal-pattern detection | 30-query suite: ~18/30 pass. Parser ordering bugs fixed (#20, #27 consistently correct). |
| 9 | Removed "I have found" false-positive refusal pattern, added 15-call tool circuit breaker, degenerate-response replacement | werden Perfekt (#23) fixed (was 1/7, now passing). wissen (#9) fixed (was R:3 failure, now R:0). |
| 10 | Added 5 new refusal patterns (`cannot fulfill`, `unable to provide`, `outside the scope`), expanded instructions with RULES block (no English translation, list all persons, single tense only, present tool data faithfully), fixed imperative pronoun doubling | Targets #4, #6, #9, #11, #16, #17, #18, #19, #25, #26, #29. |

## Tool-Call Loops

The on-device model can enter infinite tool-calling loops, requesting the same conjugationgroup repeatedly (observed: 35+ consecutive calls for `wissen Präteritum` when asked for Präsens). This exhausts the 4096-token context window.

**Fix:** Add a call counter with a circuit breaker. Reset the counter before each retry attempt:

```swift
nonisolated(unsafe) private static var callCount = 0
private static let maxCallsPerSession = 15

func call(arguments: Arguments) async throws -> String {
  Self.callCount += 1
  if Self.callCount > Self.maxCallsPerSession {
    return "Limit reached. Respond with the conjugations you already have."
  }
  // ... normal tool logic
}
```

The `nonisolated(unsafe)` annotation is acceptable because tool calls are sequential within a session.

## False-Positive Refusal Detection

Refusal-detection patterns can cause correct responses to be discarded. Example: `"I have found the conjugation..."` was flagged as a refusal because `"I have found"` was in the pattern list, triggering a retry that produced a worse answer.

**Guidelines:**
- Test refusal patterns against successful responses, not just refusals
- Prefer specific phrases (`"cannot fulfill"`, `"unable to assist"`) over generic ones (`"I have found"`)
- When adding a new pattern, grep the test results for false positives first

## Imperative Pronoun Doubling

When `Conjugator.conjugate` returns imperative forms for wir/Sie, it already embeds the pronoun (e.g., `"helfen wir"`, `"helfen Sie"`). If the tool's output loop also prepends the pronoun, the result is garbled: `"wir helfen wir"`.

**Fix:** Skip the pronoun prefix for imperative conjugationgroups:

```swift
if imperativ {
  lines.append(conjugation.lowercased())
} else {
  lines.append("\(personNumber.pronoun) \(conjugation.lowercased())")
}
```

## Checklist for New Tools

When adding a new `Tool` conformance:

- [ ] Keep `@Guide` descriptions under ~60 characters
- [ ] Keep session instructions under ~300 characters
- [ ] Use `.anyOf` to constrain free-text parameters to valid values when possible
- [ ] Put the most commonly requested value first in `.anyOf` arrays and `@Guide` examples
- [ ] Remove any parameter the model might skip or misuse — handle it in `call(arguments:)`
- [ ] Return labeled results with authoritative terminology
- [ ] Strip any UI markup (ablaut casing, rich-text markers) from tool output
- [ ] Use `contains()`-based fuzzy parsing with ordered specificity for free-text parameters
- [ ] Add bare-name fallback parsing for short German tense names the model may send
- [ ] Write error messages as user-facing text — the model often echoes them verbatim
- [ ] Use ALL CAPS sparingly for critical directives (e.g., "ALWAYS call toolName")
- [ ] Use an `@MainActor` helper method for `call(arguments:)` to bridge `Tool`'s `nonisolated` requirement
- [ ] Test with the actual on-device model across the full scenario suite, not just targeted cases — behavior is non-deterministic
