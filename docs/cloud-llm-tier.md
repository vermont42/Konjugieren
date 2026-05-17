# Cloud LLM Tier — Konjugieren+ via Anthropic API

A design memo for a future paid tier that swaps the on-device Foundation Models backend for an Anthropic-API-backed one. The motivation is quality: the on-device model is competent for high-frequency grammar but hallucinates confidently on the long tail (see the "third declension" / "Future Indicative changes -en to -en" failure on `beseitigen` captured during the 2026-05-17 recording session). A cloud LLM closes that gap for users willing to pay.

This is a design memo, not an implementation plan. No code changes proposed yet. Defer until interview season ends.

## Why this is architecturally cheap

The abstraction is already in place. `LanguageModelService` is a protocol (`Konjugieren/Models/LanguageModelService.swift:58`) with three real responsibilities — `explainError`, `recommendPractice`, `sendTutorMessage` — plus availability reporting. Today the protocol has two conformances: `LanguageModelServiceReal` (Foundation Models, iOS 26+) and `LanguageModelServiceDummy` (tests + `iOS < 26` fallback), wired in `World.swift:56-62`.

Adding a third conformance (`LanguageModelServiceAnthropic`) requires no caller-side changes. Every site that already gates on `Current.languageModelService.isAvailable` — `QuizView.swift:163` (ErrorExplainerView), the Tutor row in `InfoBrowseView`, the Tutor page in `OnboardingView` — will work unmodified. The protocol does the right thing.

## Currently disabled in 1.0

As of the 2026-05-17 release, two of `LanguageModelService`'s three on-device surfaces ship *dark* — the underlying protocol methods remain wired through, but the UI entry points are commented out behind `TODO: 1.0-disabled surface` markers. The cloud tier described in this memo is the path to re-enabling them.

| Surface | UI entry point | Why disabled |
|---|---|---|
| `explainError` | `ErrorExplainerView` card in `QuizView.swift` | FM confidently hallucinates fake grammar rules even on canonical strong verbs. For `singen` / Präteritum 1.P.Sg., the model produced "-en changes to -t before adding -e" — a weak-verb rule applied to the textbook Klasse III strong verb. The structured Explanation / Rule / Memory Aid headings make fabricated rules read as ground truth, and the card has no chat-style affordance for the user to push back. |
| `recommendPractice` | "Get Suggestions" button in `TutorView.swift` | The model free-associates from English tense labels ("Past Indicative" → "errors in recalling past events suggest practice on past tense structures") rather than diagnosing actual German grammar gaps. Input grounding is too thin: the model receives aggregated counts keyed on conjugationgroup names with no underlying verbs or specific mistake patterns attached. Even cloud Claude would produce slop from this input shape — re-enabling requires *both* a better model **and** richer input (top-N missed verbs with their wrong/right pairs, not just counts). |
| `sendTutorMessage` | `TutorView` chat field | **Ships live in 1.0.** Free-form chat tolerates model uncertainty better than structured surfaces — users can push back. This is also the App Store nomination demo surface (see `docs/tutor-recording.md`). |

**Restoration path.** `grep -rn "TODO: 1.0-disabled surface" Konjugieren/` locates the comment-outs. Both should re-light in the same change that introduces `HybridLanguageModelService` (per the next section). `recommendPractice` additionally needs the input-shape revision described above — re-enabling it without enriching the input would reproduce the same hallucination class on the cloud model.

**App Store metadata.** The 1.0 listing must be revised to remove mentions of `ErrorExplainerView` and on-device practice recommendations. When the cloud tier ships, metadata must be revised back in lockstep with the rollout — otherwise the App Store listing will reference surfaces the user can't see.

## Recommended dispatch shape: hybrid, not exclusive

Don't replace Foundation Models with Anthropic for paid users — *augment* it. The right user experience is:

```
entitled + online   → Anthropic
entitled + offline  → Foundation Models (graceful degradation, not zero functionality)
free                → Foundation Models
```

This implies a `HybridLanguageModelService` wrapping both backends and routing per-call based on reachability + entitlement at the moment of the call, not at app launch. A user on a flight should still get *some* explanation. A user with a flaky connection should not see the Tutor row vanish when their cellular drops.

Sketch:

```swift
@MainActor
final class HybridLanguageModelService: LanguageModelService {
  private let cloud: LanguageModelServiceAnthropic
  private let onDevice: LanguageModelService  // LanguageModelServiceReal or Dummy
  private let entitlement: EntitlementMonitor
  private let reachability: ReachabilityMonitor

  var isAvailable: Bool {
    (entitlement.hasPlus && reachability.isReachable && cloud.isAvailable) || onDevice.isAvailable
  }

  func explainError(context: ErrorExplainerContext) async throws -> ErrorExplanation {
    if entitlement.hasPlus && reachability.isReachable {
      do { return try await cloud.explainError(context: context) }
      catch { return try await onDevice.explainError(context: context) }
    }
    return try await onDevice.explainError(context: context)
  }
  // ... same pattern for the other two methods
}
```

`World.real` then constructs `HybridLanguageModelService(...)` and assigns it where it currently assigns `LanguageModelServiceReal()`. All call sites stay identical.

## Why a backend proxy is non-negotiable

**Do not ship the Anthropic API key in the iOS binary.** Anyone can extract it with `strings` or by opening the `.ipa` in a hex editor; the cost of an exfiltrated key is unbounded. The standard pattern for client→Claude integrations on a paid tier is:

```
iOS app → your backend → Anthropic
         (StoreKit receipt    (your key, server-side)
          verified per request)
```

The backend has four jobs:

1. **Validate the StoreKit receipt** on each request (or cache a short-lived JWT after first validation per device).
2. **Forward the prompt to Anthropic** with your real API key.
3. **Rate-limit per user/device** so a single compromised receipt can't drain the budget.
4. **Log usage** for cost monitoring (tokens in/out, per user, per feature).

Minimum-effort stack: a Cloudflare Worker with a KV namespace for receipt cache and request counts. ~150 lines of TypeScript. Roll the Anthropic key without shipping an app update; revoke compromised receipts at the edge. Vercel + a serverless function works equally well if you prefer that ecosystem.

A more durable option, if you want to charge users a recurring fee rather than a one-time purchase: validate StoreKit Server Notifications V2 in a Cloudflare Worker, persist entitlements to D1 (their SQLite-backed DB), and key the proxy on a user-scoped JWT signed by the worker. Slightly more code, but lets you handle refunds, renewal failures, and family sharing correctly.

## StoreKit entitlement plumbing

Add a `hasKonjugierenPlus: Bool` property to `Settings.swift`, persisted via `GetterSetter` like the existing settings. Populate it from a `StoreKitMonitor` that subscribes to `Transaction.updates`:

```swift
@MainActor
@Observable
final class StoreKitMonitor {
  private(set) var hasPlus: Bool = false
  static let productID = "biz.joshadams.Konjugieren.plus.monthly"

  func start() async {
    await refresh()
    for await update in Transaction.updates {
      if case .verified(let txn) = update, txn.productID == Self.productID {
        await refresh()
        await txn.finish()
      }
    }
  }

  private func refresh() async {
    var entitled = false
    for await result in Transaction.currentEntitlements {
      if case .verified(let txn) = result, txn.productID == Self.productID {
        entitled = true
      }
    }
    hasPlus = entitled
  }
}
```

`World.real` constructs and starts the monitor. The `EntitlementMonitor` referenced in the hybrid sketch above is this class.

A consumable IAP (one-time "buy 100 Tutor messages") is also an option and avoids the recurring-billing edge cases, but the UX is worse — users have to remember to refill. Subscription is the better fit for a feature that's always available when entitled.

## Model selection

**Recommended: Claude Haiku 4.5** for both error explanations and Tutor messages.

Haiku is fast (P50 latency under a second for these short prompts), inexpensive, and easily smart enough for "explain why *singte* is wrong instead of *sang*" or "when do I use Konjunktiv II?". Sonnet 4.6 is overkill for these tasks and would roughly triple the per-request cost without a perceivable quality improvement on the kind of grammar explanation Konjugieren wants.

If at some point you add a "deep dive" feature (long-form etymological exploration, multi-paragraph essays on the Wechselpräteritum), that surface could use Sonnet selectively — the protocol could grow a `deepExplainError(...)` method routed to a different model. But that's not for now.

## System prompts: rewrite, don't port

The Foundation Models system prompts in `LanguageModelServiceReal.swift` (`errorExplainerInstructions`, `tutorInstructions`, and the conjugation-tool instruction block) are heavily tuned to the on-device model's quirks and 4096-token budget. **Porting them verbatim to Claude would be a regression.** Several patterns exist purely to compensate for FM-specific failure modes; with Claude they would be either redundant or actively harmful.

### What to drop or rewrite

1. **All-caps emphasis** ("EXACTLY ONCE", "NEVER translate", "ALL six persons"). Small models respond well to shouted constraints because their attention to negation and quantification is weaker. Claude reads emphasis as stylistic, and overuse desensitizes it — the surrounding prose starts to read as boilerplate rather than rules. Rewrite as calm declaratives ("Call `conjugateVerb` once per question."). Reserve emphasis for the rare cases that truly need it.

2. **Inline JSON schema descriptions** ("Respond ONLY with a JSON object matching this schema: ..."). With forced tool-use, the schema is enforced by the API. Repeating it in the system prompt is redundant noise that competes with substantive guidance. Drop it.

3. **Tool-call-frequency patches** ("call `conjugateVerb` EXACTLY ONCE", "do not call the tool multiple times for different tenses"). These are workarounds for the FM tool-use bug documented in `on-device-tool-design.md` (the "stopped after three pronouns" failure). Claude handles multi-call tool sequences natively. With Claude you may actually *want* the tutor to call the conjugator multiple times — once per tense the user asked about — and present a comparative table. Carrying the FM constraint over would make the cloud tier *worse* on multi-tense questions.

4. **Negative-only instructions** ("NEVER translate", "Do not call the tool multiple times"). FM responds to "don't do X." Claude responds better to "do Y." Where possible, rephrase positively: "Present conjugations in German exactly as the tool returns them." Better yet, append a one-line example of the desired output. One concrete example is worth several "NEVER do X" prohibitions.

5. **Echo-the-label tool outputs** (returning `"ich sang (Past Indicative)"` to prevent FM from misattributing). Per `on-device-tool-design.md`, FM needed labels echoed into the tool result to stop it from guessing the wrong tense. Claude doesn't misattribute tool results; the label can live in the system prompt context once, not appended to every tool output. The tool can return clean `"ich sang"` and let the model speak the label.

6. **Token-tight `@Guide` descriptions.** The on-device-tool-design guide explicitly recommends collapsing guides to ~56-character phrases to preserve prompt space. With Claude, the analogous tool `input_schema` `description` fields can be *longer* and *more illustrative* — 1-3 sentences with an example. The cost of a few extra tokens in the cached prefix is negligible against the accuracy lift.

7. **Generic persona** ("You are a German grammar tutor."). FM doesn't reliably attend to long persona setups, so the on-device prompt stays neutral. Claude can support a much richer persona that materially changes voice — "You are an enthusiastic Volkshochschule teacher who loves etymological connections and avoids hedging. Treat the learner as a smart adult; explain rules, don't moralize about them." The app's writing style already values etymological connections (`docs/english_writing_style.md`, `docs/etymologies.md`); the cloud tier is the place to lean into that.

### What to keep

- **Brevity expectations.** Two-sentence explanations are a deliberate UX choice, not just a token-budget patch. The cloud tier should match the visual density of the on-device tier so the experience feels consistent across the entitlement gate. Reframe as a UX constraint, not a context-window constraint: "Keep each field to one or two sentences for visual consistency with the on-device tier."
- **Tense-mapping legend** ("Partizip I = present participle. Partizip II = past participle."). This is genuinely useful glossary content for any model — the German/English terminology mismatch is real and worth pinning.
- **Conjugations-stay-in-German rule.** This is a pedagogical choice — Konjugieren is a German app and translating "ich sang" to "I sang" defeats the point. Keep it, but rephrase positively: "Conjugations remain in German. Glossing the *infinitive* is fine; conjugated forms are not."

### Practical recommendation

Treat the cloud system prompts as a *new authoring task*, not a port. Draft them from scratch using the FM prompts as a checklist of behavioral requirements, not as a template. Two passes of A/B comparison against the on-device prompts on a fixed test set — ~20 wrong answers + ~20 tutor questions — should be enough to verify the cloud prompts produce strictly better output before shipping. The verbs in `docs/frequencies.txt` plus the saved quiz-error history (`QuizErrorHistory`, persisted via `GetterSetter`) are a natural source for the test set; the latter even gives you the user's actual mistake distribution.

## Structured output via tool-use

`ErrorExplanation` and `PracticeRecommendation` are `Codable` structs. The cleanest way to get reliable JSON from the Anthropic API matching those schemas is **forced tool-use**: define an `emit_explanation` tool whose `input_schema` matches `ErrorExplanation`, and pass `tool_choice: {"type": "tool", "name": "emit_explanation"}`. The model is then constrained to emit exactly that structure. This is the cloud analog of the on-device `@Generable` macro pattern.

Schema for `ErrorExplanation`:

```json
{
  "type": "object",
  "properties": {
    "explanation": { "type": "string", "description": "Brief explanation of why the answer was wrong." },
    "rule": { "type": "string", "description": "The grammar rule that applies." },
    "mnemonic": { "type": "string", "description": "A short memory aid." }
  },
  "required": ["explanation", "rule", "mnemonic"]
}
```

The forced-tool-use approach is more reliable than prompting "respond in JSON" — the API won't return prose, won't wrap in markdown code fences, won't drift between requests. JSON parsing becomes infallible.

## Prompt caching

The German tutor system prompt is long-ish, static, and identical across every Tutor turn. Cache it. The Anthropic API has explicit prompt caching support via `cache_control: {"type": "ephemeral"}` on a system block; the cache TTL is 5 minutes by default (1-hour extended caching is available). Hit rates on Konjugieren's workload should be very high — the system prompt for `sendTutorMessage` doesn't change across a tutor session, and the system prompt for `explainError` doesn't change across a quiz session. Expect ~80%+ token savings on the cacheable prefix.

This is required practice for production Anthropic API integrations; the cost difference is large enough that omitting it is a self-inflicted wound. The `claude-api` skill in this Claude Code install will set it up correctly if invoked at implementation time.

## Streaming

`sendTutorMessage` should stream. Users typing into a chat expect tokens to appear as they're generated; a 1.5-second blocking wait feels broken when the answer is going to take 3-4 seconds. Use Server-Sent Events via `URLSession` data tasks (or the official `AnthropicSwift` SDK if it's adopted by then).

`explainError` and `recommendPractice` are short, structured, one-shot — non-streaming is fine and simpler.

## Privacy and disclosure

Three things to update before shipping:

1. **App Privacy nutrition label** (App Store Connect) — declare "Data sent to a third party" with categories `Diagnostics` (because the user's wrong answer is sent) and `Other User Content` (because Tutor prompts may include free-form user text).
2. **`PrivacyInfo.xcprivacy`** — same declarations in the privacy manifest. Check current contents to confirm what already covers TelemetryDeck and adjust.
3. **In-app explainer** — a one-line note in `SettingsView.swift` or in the Konjugieren+ upgrade sheet itself: "Konjugieren+ sends your quiz answers to Anthropic for higher-quality explanations. Your data is not used to train models." (Anthropic's API does not train on API-passed data by default; confirm this is still true at implementation time and quote the current policy URL.)

The on-device tier needs no such disclosure — Foundation Models keeps everything on-device. The asymmetry is itself a selling point for users who want max privacy: "Konjugieren explains errors entirely on your device. Upgrade for higher-quality, cloud-powered explanations when you have a connection."

## Cost estimate (back of envelope)

Using Haiku 4.5 pricing (subject to change; confirm at implementation time):

- **explainError:** ~500 input tokens (system prompt + context) + ~150 output tokens. With prompt caching covering most of the system prompt, ~150 fresh input + 150 output per call. Cost per call: ~$0.001 with caching.
- **sendTutorMessage:** ~1500 input + ~200 output. With caching: ~300 fresh input + 200 output. Cost per turn: ~$0.0015.
- **recommendPractice:** ~800 input + ~250 output. With caching: ~200 fresh input + 250 output. Cost per call: ~$0.002.

A heavy paid user doing 50 error explanations + 80 tutor turns + 10 practice recommendations per month: roughly **$0.20/month** in API cost.

Anthropic-pricing assumption: ~$0.80/MTok input, $4/MTok output for Haiku 4.5. Treat these as order-of-magnitude until verified against current rates.

At a $1.99/month subscription, Apple takes 30% (15% if you're in the Small Business Program) — net ~$1.39 to you per subscriber. Minus the ~$0.20 in API cost, you're at ~$1.19 net per active subscriber per month. Comfortable margin; the only real risk is a user who slams the Tutor for 1000 turns/day, which is what the rate-limiting in the proxy is for.

## Migration / rollout plan

When you come back to this:

1. **Backend first.** Ship a minimal Cloudflare Worker that proxies a single endpoint (`/v1/messages`) with a hardcoded test entitlement. Verify with `curl` from your laptop.
2. **Add StoreKit receipt validation** to the worker. Test with a sandbox subscription.
3. **`LanguageModelServiceAnthropic` in the iOS app**, talking to the worker. Skip StoreKit integration in the app initially — hardcode "always entitled" for dev builds. Write fresh system prompts for Claude (see *System prompts: rewrite, don't port*); do not port the FM prompts.
4. **`HybridLanguageModelService` with reachability + entitlement gates.** Test by toggling airplane mode and watching the fallback trigger.
5. **StoreKit IAP wiring** in the app. Test the buy-flow and cancel-flow in sandbox.
6. **Privacy manifest + App Privacy label** updates.
7. **Konjugieren+ upgrade sheet UI** — when and where to surface the prompt. Probably: a row in `SettingsView`, and a one-time offer after the user has seen the on-device explainer N times.
8. **TestFlight beta** with a small group. Watch Cloudflare Worker logs for unexpected traffic.

Foundation Models stays as the free-tier backend permanently; this is not a deprecation path.

## Open questions

- **Family Sharing.** StoreKit subscriptions can be set as family-shareable. Yes/no? Defaults to no.
- **Refund handling.** If a user refunds the subscription, `Transaction.updates` will fire a revocation; the `StoreKitMonitor` needs to flip `hasPlus` to `false`. Confirmed in StoreKit 2 semantics but worth testing explicitly.
- **Model upgrades.** When Haiku 5.0 ships, swap the model ID in the worker (no app update needed). The protocol surface doesn't care which model the proxy talks to.
- **EU / DSA.** If Konjugieren ends up in the EU featured pipeline and gets traction, the DSA's data-processing disclosures apply. Probably moot at current scale but a thing to revisit.

## Related docs

- `feature-architecture.md` — the World/DI shape this would plug into.
- `on-device-tool-design.md` — design principles for the existing on-device path. Useful background for why cloud is *different*: cloud LLMs handle multi-parameter tools and verbose schemas natively, where on-device cannot. The on-device tool design choices do not need to carry over.
- `post-release-features.md` — list of post-1.0 ideas. Add a one-line pointer to this memo from there if/when this gets greenlit.
