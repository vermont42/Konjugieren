# Exploration: Query Rewriting to Work Around Hard Refusals

## Problem

Two test queries consistently fail across all runs despite instruction tuning:

1. **#19** "What is the future subjunctive of nehmen?" — The model refuses before calling the tool. No tool call appears in logs. The phrase "future subjunctive" appears to trigger a safety refusal, even though "Futur Konjunktiv I" (the German equivalent) works reliably.

2. **#30** "What does ablaut mean?" — The model refuses every time. Meanwhile, "What is the difference between Präteritum and Perfekt?" (a similar grammar-concept question) passes consistently. The "what does X mean" phrasing may be the trigger.

These are not instruction-fixable — the model's safety behavior activates before it processes our instructions.

## Proposed Solution: Pre-Model Query Rewriting

Intercept the user's message in `sendTutorMessage` *before* sending it to the model. Apply a set of deterministic rewrites that transform known-problematic phrasings into equivalent phrasings that the model handles well.

## Design Questions to Explore

### 1. Where should rewriting live?

Option A: Inside `sendTutorMessage` in `LanguageModelServiceReal`, as a private helper that transforms the prompt string before `session.respond(to:)`.

Option B: As a separate `QueryRewriter` type (enum with static functions, like `TutorChatHistory`) that can be unit-tested independently.

Option C: As a Tool — give the model a "rephrase this question" tool that it calls on itself. This is probably too clever and adds latency.

### 2. What rewrites are needed?

Based on test data, the following mappings would address known failures:

| User phrasing | Rewritten phrasing | Rationale |
|--------------|-------------------|-----------|
| "future subjunctive" | "Futur Konjunktiv I" | German tense name passes; English name triggers refusal |
| "future conditional" | "Futur Konjunktiv II" | Same pattern, preemptive |
| "past conditional" | "Präteritum Konjunktiv II" | Same pattern, preemptive |
| "pluperfect conditional" | "Plusquamperfekt Konjunktiv II" | Same pattern, preemptive |
| "present perfect subjunctive" | "Perfekt Konjunktiv I" | Same pattern, preemptive |
| "what does ___ mean" | "Explain the grammar concept ___" | Rephrase definition requests as explanation requests |
| "define ___" | "Explain the grammar concept ___" | Same pattern |

### 3. Should rewrites be transparent to the user?

The rewritten text is what gets sent to the model, but the user's original text is what appears in the chat bubble. The user never sees the rewrite. This is important — we don't want the chat history to show text the user didn't type.

### 4. Should we also rewrite English tense names in the instructions-to-tool mapping?

Currently, `buildConjugationgroup` in `ConjugationTool` handles both English and German tense names. The model sometimes passes English names to the tool, which works. But if we rewrite the *user's* query to use German names, the model is more likely to pass German names to the tool, which is more reliable end-to-end.

### 5. How do we avoid over-rewriting?

Rewrites should be narrow and targeted. A rewrite that transforms "what does X mean" should only apply when X is a grammar term, not arbitrary text. Consider maintaining an allowlist of grammar terms: ablaut, umlaut, conjugation, declension, tense, mood, voice, indicative, subjunctive, imperative, participle, auxiliary, etc.

## Verification Plan

1. Unit-test the rewriter in isolation: input string → output string for each mapping.
2. Run the 30-query test suite and confirm #19 and #30 now pass.
3. Verify that rewrites don't break queries that already work (no regressions on the ~25 passing queries).
4. Verify the user's chat bubble still shows their original text, not the rewritten version.
