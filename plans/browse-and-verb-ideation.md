# Plan: Ideate Improvements to the Browse and Verb Screens

**For:** a fresh Claude Code session. **Kind of work:** research and ideation only, no code
changes. **Written:** 2026-11-10.

## Status

**Executed 2026-11-10.** The findings are in
[`docs/browse-and-verb-ideas.md`](../docs/browse-and-verb-ideas.md). Two things happened
afterwards, both on the same day.

1. The defects found along the way became a plan of their own,
   [`fix-reference-defects.md`](fix-reference-defects.md), to be carried out before any idea is
   built. **It was finished on 2026-11-10**, so the ideas are no longer waiting on it. The fixes
   are on `main` and reach learners with the next release.
2. Josh said that no release of Konjugieren, Conjuguer, or Conjugar is possible before 2027, as
   `CLAUDE.md` records. This brief was written without that knowledge. Where it has the quiz
   changes proceeding "at the same time", and signals that "would at least show direction over
   time", read both as beginning with a release in 2027. The ideas document was revised to say
   what the constraint changes.

The original brief follows.

## Goal

Generate, assess, and rank ideas that would make Konjugieren's verb-browsing and verb-detail
screens more useful and stickier, so that people who look a verb up come back, and come back
more often. Conjuguer and Conjugar should benefit later, so note how each idea would carry over.

Josh will analyze and iterate on the output before any code is written.

## Why these screens

Usage data from all three apps shows that the reference half of each app is what people actually
use. Verb browsing and the verb page dominate every app's signals, and a typical Konjugieren session
is a quick lookup: about 1.6 browse views and 1.1 verb views per session for real devices, with a
median session of 19 seconds. Conjugar looks the same (1.8 and 1.5 per session). Apple even files
Conjuguer and Conjugar under Reference.

Two cautions temper that, and the ideation should keep both in view:

- **Some of the dominance is structural.** Verb Browse is the landing tab, so nearly every session
  logs a view of it. High counts show where people land, not only what they value.
- **The lookup mostly works already.** A 19-second visit that ends with one verb viewed suggests
  people find what they came for. The upside is less in speeding up a task that already succeeds
  and more in (a) the cases where a lookup *fails*, and (b) giving people a reason to return other
  than their next homework question.

## Read first

1. [`docs/telemetry-usage.md`](../docs/telemetry-usage.md): the usage snapshot from TelemetryDeck
   and App Store Connect. Most relevant: "Headline numbers", "Observations", "Feature usage",
   "App Store Connect" → "Observations from App Store Connect", and "The China devices". **Use the
   57 real Konjugieren devices, not TelemetryDeck's raw 77**; 20 devices are an automated visitor
   in China, explained in that section.
2. [`docs/pedagogy.md`](../docs/pedagogy.md): the parallel research on the quiz. Most relevant:
   "Short Answers", "What the Usage Data Add", the six suggestion tiers (especially
   [Tier 2](../docs/pedagogy.md#tier-2-change-what-the-quiz-asks) and
   [Tier 3](../docs/pedagogy.md#tier-3-give-the-quiz-a-memory)),
   [What to Measure](../docs/pedagogy.md#what-to-measure), and
   [Decisions for Josh](../docs/pedagogy.md#decisions-for-josh).
3. The screens themselves: `Konjugieren/Views/VerbBrowseView.swift`, `VerbView.swift`,
   `FamilyBrowseView.swift`, and `FamilyDetailView.swift`. Note the search in `VerbBrowseView`:
   it matches infinitives (with ß/ss normalization) and, depending on the `searchScope` setting,
   English translations, and nothing else.
4. Surfaces that already reach outside the app: the App Intents in `Konjugieren/Intents/`
   (`OpenVerbIntent`, `ConjugateVerbIntent`, `VerbEntity`, `KonjugierenShortcuts`), the shared
   `Shared/OpenRandomVerbIntent.swift`, the widget's `NextVerbIntent`, and the Control Center
   controls described in [`docs/control-center-controls.md`](../docs/control-center-controls.md).
   Ideas about return visits should account for what these already do.
5. `Konjugieren/Utils/Analytics.swift`: the complete list of signals the app sends today. They are
   screen views and a few taps. Nothing records searches, how a verb was reached, or what part of
   a verb page was read.

## What the quiz work will be doing in parallel

Assume the quiz changes in `docs/pedagogy.md` proceed at the same time, starting with its top three:
accept correct German that is now marked wrong (Tier 1), make the default session about ten
questions on frequent verbs at a beginner's set of conjugationgroups (Tier 2), and re-ask missed
questions within a session (Tier 3). Later tiers add memory across sessions, feedback, and
learner-chosen scope, including a "my verbs" scope.

So the ideation should:

- **Not duplicate quiz work.** Ideas whose substance is "a better quiz" belong to that track. Say
  so and hand them over in a short section instead of developing them.
- **Treat the two tracks as one product.** The most promising ideas connect lookup and practice.
  Where an idea needs shared state with the quiz (a list of verbs the learner cares about, error
  history, frequency bands), name the shared piece, say what the Browse and Verb screens would
  need from it, and flag who should build it as a decision for Josh. `QuizErrorHistory` already
  records missed questions and is one such piece.
- **Line up measurement with the quiz track's.** `docs/pedagogy.md` already proposes signals in
  "What to Measure". New signals for Browse and Verb should use the same conventions, and
  shouldn't collide with them.

## Ideas already on the table

These came out of the usage analysis on 2026-11-10. Assess them alongside whatever the session
generates; they are starting points, not conclusions.

1. **Reverse lookup from a conjugation.** Let search find a verb from any of its conjugations, so a
   learner who meets *ging*, *gefunden*, or *stand … auf* in a text can land on gehen, finden, or
   aufstehen. This may be the most common real lookup need, and an online conjugation table can't
   easily match it. The corpus already supports it: the `CorpusFormsDumpTests` harness
   (`KonjugierenTests/Utils/`) writes a map from every conjugation to its infinitive, as
   `corpus/working/forms.json` (gitignored and regenerable; see
   [`prompts/uses_etymologies.md`](../prompts/uses_etymologies.md)). Open questions include
   ambiguous conjugations that belong to more than one verb, separable verbs split across a
   sentence, the size cost of shipping the map, and how results should present the matched
   conjugation.
2. **Measure the lookup path before redesigning it.** Candidate signals: a search that returned no
   result (the most valuable signal a reference app can collect, because it shows what people
   wanted and didn't get), how a verb page was reached (search, scrolling, a family, a deeplink, an
   intent, the widget), and which sections of the verb page were reached (for example the
   Konjunktiv tables, the etymology, the example sentence). Whether to log search text is a
   privacy decision for Josh. A middle path, such as logging only that a search failed and its
   length, should be offered.
3. **Let lookups feed practice.** Every verb someone looks up becomes part of a personal list, which
   the quiz track's "my verbs" scope can draw on. The verb page could offer a short "test me on this
   verb" while the learner is already there. The reference then stops competing with the quiz and
   starts supplying it: the learner chooses what to study by what they look up, and spaced
   practice brings those verbs back later. This is the idea that most depends on coordinating with
   the quiz track.

Don't treat this list as complete, and don't anchor on it. The session's own ideation is the main
deliverable.

## Questions the session should answer

- What does a lookup visit need, step by step, and where can it fail? Consider learners reading a
  German text, writing German, doing homework, and checking a single conjugation.
- What would give someone a reason to open the app between lookup needs, without the app becoming
  a nag?
- Which ideas help a learner who arrives from a Shortcut, Spotlight, a widget, or a deeplink, and
  never sees Verb Browse?
- How does each idea carry over to Conjuguer and Conjugar? Their audiences differ: Conjuguer's is
  largely francophone, much of it in West and Central Africa, and Conjugar's is mostly American.
- For each idea: what would it cost (S for hours to a day, M for several days, L for weeks), what
  evidence or principle supports it, and what signal would show whether it worked?
- Which ideas could be tried on a few real people before being built in full?

## Constraints and context

- **Localization and availability are fixed policy.** Each app is localized into English and the
  language it teaches, and offered only where those are spoken. Don't propose new localizations
  or storefronts.
- **Konjugieren's binding constraint is discovery, not engagement.** It gets about 157 App Store
  impressions and 6.5 first-time downloads a month and converts well when seen. Screen
  improvements will not change that, and the document should not imply they will. If an idea also
  helps the App Store listing (a screenshot-worthy feature, say), note it.
- **The numbers are too small for A/B testing.** With 57 real devices ever, no engagement change
  will be measurable for months. Rank ideas by reasoning, evidence from elsewhere, and qualitative
  testing, and say which signals would at least show direction over time.
- **Respect the app's existing constraints**, so that the ideas are buildable: VoiceOver
  pronunciation rules in [`docs/voiceover.md`](../docs/voiceover.md) (per-child locale does not
  work inside `NavigationLink` or `Button`), the Apple Intelligence gating described in `CLAUDE.md`
  (Tutor features render only on eligible devices), the Swiss ß/ss normalization in search, and
  the Regional Variety setting.
- **Terminology:** follow [`docs/terminology.md`](../docs/terminology.md). Say "conjugationgroup",
  not "tense", and "conjugation", not "form", for an inflected verb.
- **Prose:** follow [`docs/english_writing_style.md`](../docs/english_writing_style.md). In
  particular, no em dashes.

## Method

1. Read the inputs above. Skim the rest of `docs/pedagogy.md` for findings on reference tools and
   competitors that apply here.
2. Read the views closely. Whenever a question comes up about how the Browse or Verb screens look
   or behave, run the app with the `ios-build-verify` skill (see `CLAUDE.md` for the script path
   and the verification configuration) and check, rather than guessing from the code. Screenshots
   taken on this Intel host can't show Tutor-gated surfaces.
3. Survey how other conjugation and dictionary apps handle lookup, reverse lookup, history,
   favorites, and return visits. Mark sources and distinguish what was observed from what was
   inferred, as `docs/pedagogy.md` does.
4. Generate ideas broadly, then assess and rank them.

Subagents may be useful, for example for the survey of other apps or for parallel reading of the
three codebases. If the session uses them, they should run on the Sonnet 5.5 model
(`claude-sonnet-5-5`).

## Deliverable

A new Markdown file, `docs/browse-and-verb-ideas.md`, structured along the lines of
`docs/pedagogy.md`:

1. Short answers: the handful of ideas worth doing first, and why.
2. What the screens do today, and where a lookup fails.
3. Ideas, grouped and ranked, each with basis, effort, the signal that would show whether it
   worked, and how it carries over to Conjuguer and Conjugar.
4. Coordination with the quiz track: the shared pieces, who might build them, and the ideas handed
   over to that track.
5. What to measure, aligned with `docs/pedagogy.md`'s proposals.
6. Decisions for Josh.
7. Limits of the research, and sources.

When done, add a dated entry to `docs/blog_notes.md` and a line for the new doc in
`docs/project-structure.md`, then run `python3 scripts/check_docs.py`. Don't modify app code.

## Prompt to hand the session

> Read `plans/browse-and-verb-ideation.md` and carry it out. It's a research-and-ideation project
> on Konjugieren's Browse and Verb screens: no code changes. Write your findings to
> `docs/browse-and-verb-ideas.md`. Ask me if anything in the plan is unclear or seems wrong.
