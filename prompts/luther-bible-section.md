# Add a section on the Luther Bible to the verb-history essay

**Status: SHIPPED, 2026-07-29.** Written the same day at Josh's request, after he read the corrected
essay and identified the gap. The essay covers the Battle of the Teutoburg Forest and says nothing
about the Luther Bible, which he judged a lacuna worth filling.

**What happened is recorded in [`docs/luther_section.md`](../docs/luther_section.md), and the
ranking below turned out to be wrong in both directions.** Candidate 1, rated strongest, survives
only after being reframed: its "visible in every paradigm cell" premise is false, and the app
disproves it, since `machen`'s imperative is `mach` and the strong preterite is `sAng`. Candidate 4,
rated weakest and most likely to produce an error, is now the best-evidenced claim in the section,
verified from 1545 page images. Candidate 2 was refuted rather than merely left unattested, and
candidate 3 had nothing to resist. Nine agents, about 1.9M subagent tokens.

**This is new work, not the last mile of something finished.** The fact-check in
[`verify-verb-history.md`](verify-verb-history.md) is closed and its corrections shipped on
2026-07-29. A new section is the one thing in this essay that has never been through that process,
and it must not become the one credulous paragraph in a text that spent 3.7 million subagent tokens
earning the right not to have any.

## The gap was already found, and recorded as deliberate

Read this before assuming the absence was an oversight. From
[`docs/verb_history_claims.md`](../docs/verb_history_claims.md), cluster G's coverage note:

> The essay never uses the terms *Konjunktiv I* or *Konjunktiv II*, never discusses indirect speech
> or the decline of Konjunktiv I in speech, and **never mentions Luther**. All four appear in the
> prompt's brief for this cluster, and the last is flagged there as something popular accounts
> overstate. Their absence is not an error, but it is the reason this cluster is smaller than its
> brief suggests, and it should be reported so that silence is not read as coverage.

So the run noticed, declined to call it an error, and wrote it down. Josh then decided the section is
wanted anyway. That is a scope decision, not a correction, and the section is therefore an addition
rather than a repair.

## The trap, stated before the candidates

**"Luther created standard German" is false**, and it is the single most likely way this section goes
wrong. The hedge belongs in the section's first or second sentence, not in a subordinate clause near
the end. What the literature supports, and what a researcher should confirm rather than take from
here:

- Luther wrote in the East Central German of the Saxon chancery and said so himself, in the
  *Tischreden*, along the lines of *Ich rede nach der sächsischen Canzeley*. Verify the wording and
  the source before quoting it.
- Standardization is a seventeenth and eighteenth century process, running through Gottsched and
  Adelung. The Upper German written tradition resisted for roughly two centuries.
- Luther's effect is best described as **prestige and diffusion**: enormous reach for one region's
  already-existing choices, at a moment when several variables were being resolved.

**Luther invented no verbal morphology.** Any sentence implying otherwise is the error this brief
exists to prevent.

## Four candidate claims, ranked, all unverified

These came out of a conversation and **none has been researched**. They are hypotheses to test, and
the ranking is a prediction about which will survive a skeptic, not a finding. A researcher who
concludes that candidate 1 is unsupportable and candidate 4 is the real story has done the job
correctly.

**1. Final `-e` on verb endings. Strongest candidate, and the only one that is visible in a
paradigm.** Upper German apocopated final `-e`: *ich mach*, *ich hab*, *ich sagt*. East Central
German, Luther's variety, retained it: *ich mache*, *ich habe*, *ich sagte*. Standard German has it.
If the East Central retention is one of the features the standard took from that region, and if the
Bible is the highest-prestige vehicle for it, this is a verb-morphological effect a reader can see in
every cell of every paradigm the app displays. Check whether the handbooks actually credit the Bible
here or merely the region.

**2. The narrative preterite in writing.** The essay already asserts that the preterite "survives
primarily in writing, in northern dialects, and with high-frequency verbs", and the
*oberdeutscher Präteritumschwund* was under way in Luther's century. His Bible is wall-to-wall
narrative preterite, and it was read aloud across regions whose speech was losing that tense. That is
a plausible mechanism for a split the essay states without explaining, which makes it the candidate
that best earns its place. Check whether the mechanism is actually attested or merely plausible.

**3. Syntax, with Luther resisting rather than driving.** Chancery prose was Latinate, with
participial constructions and long clause-final brackets. Luther argued for finite verbs and spoken
idiom in the *Sendbrief vom Dolmetschen* (1530): ask the mother in the house and the children in the
street. If this holds, his contribution to German verb syntax runs *against* the elaboration of the
Satzklammer, which is a better story than the popular one and is verb-syntactic rather than lexical.

**4. Strong-verb preterite leveling. Weakest, and the one most likely to produce an error.** Old High
German had four vowel slots, *sang* against *sungum*; modern German has three, *sang* / *sangen*. The
leveling runs through Luther's century and his text shows variation rather than resolution. **His
Bible is a witness, not a cause.** Two constraints if you touch this: it must not contradict R9's
corrected sentence at the end of the `Ablaut` section, which now says the vowel changes are "carried
across five millennia by sound change and analogy rather than preserved unchanged"; and attributing
the leveling to Luther is exactly the overstatement cluster G was warned about.

Candidates deliberately excluded, because they are not verb-specific: the diphthongizations and
monophthongizations, which affect all words; and the lexical and phraseological influence, which is
real, large, and not about verbs.

## The standard this section has to meet

The rest of the essay has a verdict behind every checkable claim. A new section written from a
conversation would be the only part without one. So:

1. **Research each claim that survives drafting**, preferring handbooks and peer-reviewed work over
   Wikipedia, and saying what each source actually states. Braune/Reiffenstein, Paul, Ebert et al.'s
   *Frühneuhochdeutsche Grammatik*, Besch, von Polenz's *Deutsche Sprachgeschichte*, Salmons's
   *A History of German*, DWDS and Pfeifer, grammis. The fact-check's own reports name which of these
   were reachable and which returned 403.
2. **Then attack the draft.** One skeptic per claim, instructed to refute, researching independently
   rather than re-reading the drafter's sources. Ask it all three questions the Phase 2 skeptics were
   asked: is the sentence wrong as written, hedges included; is the account of the truth right; and
   **is the proposed prose itself right**, since 15 of that run's 27 surviving findings shipped prose
   neither the researcher nor its skeptic wrote.
3. **Make the third agent a neutral adjudicator told to decide, not a second attacker**, and print
   the direction-of-movement arithmetic. This is the one improvement the previous run identified and
   did not get to use: its second-opinion pass moved fourteen findings and every single one moved
   toward a stronger finding, which measures the instruction rather than the truth. See
   `docs/verb_history_phase2.md` § "The result, and the bias inside it".
4. **Judge each claim as written, including its hedges.** A properly hedged claim about a contested
   question is not an error. This instruction mattered more than any other in the original run.

This is a small run: one section, a handful of claims. It does not need ultracode, a fleet, or a
claim inventory. It needs a draft, a hostile reading of the draft, and someone to decide.

## Where the section goes, and what it touches

**Placement.** The essay's periodization now runs Old High German (750–1050), Middle High German
(1050–1350), and Early New High German (1350–1650). **That last period exists in the essay only
because F8's correction put it there**, in `The Future Tense and Modal Verbs`, and it is the period
Luther belongs to. Two defensible slots: immediately after `Preterite-Present Verbs` and before
`The Subjunctive and Modern German`, which keeps the chronology clean and lets the Konjunktiv section
flow into the closing; or immediately after `Strong-Verb-Class Restructuring`, which groups it with
the other periodization material. Prefer the first unless the research argues otherwise.

**Four existing passages a new section must not contradict.** Each was corrected in the last run and
each is now load-bearing.

| Passage | Why it constrains you |
|---|---|
| R9, end of `Ablaut` | Says the alternations were "carried across five millennia by sound change and analogy rather than preserved unchanged". A Luther-as-fixative claim has to sit inside that, not against it |
| E3, in `Old High German` | Already narrates a later stage of the consonant shift turning Germanic *d* into *t*, and already cites *machen* / *machte* against English *played*, and `*dō-` becoming *tun*. Do not re-narrate it |
| E12, `Strong-Verb-Class Restructuring` | Now distinguishes "no infinitive reveals whether a verb is strong" from "the stem shape points to an ablaut pattern in most cases". A leveling claim must respect that distinction |
| F8, `The Future Tense and Modal Verbs` | Introduces Early New High German with its dates. Reuse the period label rather than inventing a second one |

**A bonus, if the research supports it.** Agent H's item H19 records a real gap: the essay locates
Germanic in the far north twice and then, with no bridge, locates the ancestor of German in the far
south. It was declined in the last run precisely because every bridge asserts an unchecked migration
claim. East Central German is geographically and historically between the two, so a Luther section
that explains why a Saxon variety became the prestige written form may narrow that gap as a side
effect. Do not stretch for this; note it if it falls out.

## Mechanical obligations

A new section is the most invasive kind of edit to these files. Everything in
[`ship-verb-history.md`](ship-verb-history.md) applies, and these are the parts that bite hardest:

1. **German prose at equal hedge strength**, written against the German file rather than translated
   from the English replacement. The last run found three findings that live in exactly one language,
   and two of them were hedges that survived a verbatim port from Conjugar and then did not survive
   translation. This section is the first one written in both languages from scratch, so it has no
   inherited hedge to lose and every opportunity to introduce a new asymmetry.
2. **Any new `$…$` span must be arbitrated by the app**, not reasoned out. Uppercase inside a span is
   a factual claim about which letters a regular composition would not produce. Phase 3 checked 27
   spans against `Conjugator.conjugate(infinitiv:conjugationgroup:)` in a temporary Swift Testing
   suite and found nine wrong. If the section quotes *ich sage* or *ich sagte* or a strong preterite,
   run the conjugator. Also: a span whose **first** letter is irregular can never open a sentence.
3. **Spans stay byte-identical across the two files.** Currently 25.
4. **Recompute both headers' counts from the edited bodies.** Currently 18 headings, 25 conjugation
   spans, 70 emphasis spans, 25 asterisks, 3 emoji spans, 0 links. A new section will change at least
   the emphasis-span count and probably the asterisk count. Do not predict these; the last run's own
   prediction was two short because it was computed over a fixed set of edits that then changed.
5. **A heading concatenates onto the end of the previous paragraph**, with no blank line and no
   newline before its opening backtick. A new section means a new heading, so this is live.
6. **Validate per block, in both languages, before syncing.** Unbalanced markup is
   `Current.fatalError` on the Info screen, not a render bug.
7. **`scripts/sync_verb_history.py` writes by default**; `--check` is what makes it read-only. It now
   rejects unrecognized flags, but the default action still publishes.

## Do not do these things

1. **Do not write the section and ship it without an adversarial pass.** The whole point of the
   preceding run was that fact-checking hedged prose is adversarial and one pass at it is not enough.
2. **Do not re-run any phase of `verify-verb-history.md`.** All five are closed.
3. **Do not extract the essay from the catalog.** The extracts are the source of truth and the
   catalog is the target; an extraction now would be a no-op at best.
4. **Do not lengthen the essay carelessly.** It is 3,163 English words and 3,078 German, and it is
   deliberately the shortest of the three sibling essays. A Luther section of 150 to 250 words can
   carry all four candidates if they survive; one of 600 changes the essay's balance.
5. **Do not attribute standardization to Luther.** Stated three times in this brief because it is the
   error the section is most likely to ship.

## Where the context lives

- [`docs/history_corrections.md`](../docs/history_corrections.md) · every correction with its
  sources, plus "What was applied and what was not"
- [`docs/verb_history_phase2.md`](../docs/verb_history_phase2.md) · the adversarial method, and the
  directional-bias finding that shapes the recommendation above
- [`docs/verb_history_phase3.md`](../docs/verb_history_phase3.md) · how spans are checked against the
  app, and the `sollen` bug that method found
- [`ship-verb-history.md`](ship-verb-history.md) · the procedure for getting an edit into the app
- [`docs/english_writing_style.md`](../docs/english_writing_style.md) · no em dashes, in either
  language, and the rest
