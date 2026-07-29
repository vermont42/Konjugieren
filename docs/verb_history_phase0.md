# Phase 0 of the verb-history fact-check: extract, validate, patch

Run 2026-07-28 against [`prompts/verify-verb-history.md`](../prompts/verify-verb-history.md).
This document is what Josh reads alongside the diff to `docs/verb_history.txt` and
`docs/verb_history_de.txt`. It records what was applied, what was deliberately not applied,
where the applied prose diverges from Conjugar's, and what the patch could not reach.

Nothing was synced back to `Localizable.xcstrings`. The catalog is byte-identical to what it
was at the start of the run, and `git diff --stat` on it is empty.

## What Phase 0 produced

| Artifact | What it is |
|---|---|
| `docs/verb_history.txt` | The English essay, extracted from the catalog, with the shared-section patches applied |
| `docs/verb_history_de.txt` | The German translation, same treatment |
| `scripts/sync_verb_history.py` | Validates an extract and writes it back into the catalog |
| `docs/verb_history_claims.md` | The Phase 0.5 claim inventory that the fan-out works from |
| this file | Patch log, divergences, residue, and notes |

The essay grew from 2,753 English words to 2,900 and from 2,695 German words to 2,829. The
prompt's verbatim rule anticipates that growth and calls it the intended trade.

## The sync script, and what it actually checks

Conjugar's script validated four things. This one validates more, because Konjugieren's
parser fails harder. `StringExtensions` calls `Current.fatalError.fatalError` on any of the
five markers left open, so bad markup is a crash on the Info screen rather than the silent
render bug it is in Conjugar and Conjuguer.

Two ports would have been wrong if copied straight across.

**Balance has to be checked per block, not per essay.** `richTextBlocks` splits the whole
text at every backtick and hands only the body segments to `parseBodyToSegments`, which
means a stray `~` cancelled by another one three headings later still crashes. The
validator simulates the split.

**A dropped marker does not report itself.** Removing one `^` mid-essay does not produce an
unterminated-emoji error, because the next `^` pairs with it; the failure surfaces as a
cascade of nesting errors ending in an unterminated `~` somewhere else entirely. The
negative test for the unterminated-emoji path had to append a stray marker at the very end
of the text to isolate it, and that surprise is recorded in the test file rather than in
prose that will not be re-read.

Every validator is negative-tested by `scripts/test_sync_verb_history.py`, which corrupts an
in-memory copy of the essay one way at a time: 16 cases covering each of the five markers,
nesting, the per-block balance rule, three shapes of malformed link, the lone-capital
conjugation span, and the four convention warnings, plus a clean-validation check on each of
the two extracts. Run it after touching `validate`, `check_inline_markers`, `check_link` or
`split_blocks`. A check that silently stops firing looks exactly like a clean essay.

The test's own two failure paths were exercised rather than assumed. Moving an anchor string
in the essay reports `SETUP FAIL` on the cases that depended on it rather than passing with a
no-op corruption, and disabling `check_link` turns its three cases red rather than being
absorbed. That second property is the whole point of the file.

The round trip was verified in both directions. `--check` passes on both extracts, the body
recovered from each file is byte-identical to the catalog value, and forcing a real write
and then restoring returns the catalog to the same MD5. The write shows one insertion and
one deletion, not the ~5,400-line churn a `json.load` plus `json.dump` round trip would
produce.

Two facts about the markup that the extract headers now record:

- **The essay contains no `‡…‡` links at all.** The link validator is idle. It exists so the
  first link added is not also the first link shipped unvalidated.
- **`^…^` is no longer load-bearing.** `BodyTextView` substitutes a PNG asset for any of the
  five mapped emoji whether it arrives as an `^…^` segment or as a bare character in plain
  text, so the wrapping is convention rather than mechanism. The catalog's convention is
  lopsided and consistent: 🐎 and 🏴󠁧󠁢󠁥󠁮󠁧󠁿 are always wrapped, and the regional-indicator flags
  are always bare, roughly 1,522 times. The script warns on a deviation rather than failing,
  since neither shape breaks anything.

One counting correction for the prompt's own record: the prompt says the essay has "more
than fifty" `$…$` spans. It has 27. Fifty-four is the count of `$` characters.

## Patches applied

Ten in English, ten in German, one to one. Conjugar's line numbers refer to its
`docs/history_corrections.md`; Konjugieren's refer to the patched `docs/verb_history.txt`.

| # | Line | Conjugar's finding | Severity | What changed |
|---|---|---|---|---|
| P1 | 80 | A · line 30 | needs-hedging | "Nearby supernovae … had enriched this cloud" becomes "Generations of dying stars had seeded the cloud", naming winds as well as explosions |
| P2 | 80 | A · line 30 | factual error | "elements that could only be created in the intense pressures of collapsing stars or the cataclysmic violence of supernovae" becomes the three-site version that crowns no site |
| P3 | 82 | A · line 32 | nitpick | "supernova-gifted elements" becomes "star-forged elements" |
| P4 | 85 | A · line 38 | needs-hedging + nitpick | "By 45,000 years ago" becomes "By 40,000 years ago, and quite possibly earlier"; the steppe's western limit moves from Ukraine to Romania |
| P5 | 86 | B · line 42 | factual error | The Yamnaya horizon starts at 3300 BC, not 4500 |
| P6 | 86 | B · line 42 | needs-hedging | The flat horsemanship claim becomes the hedged one, with the mobility attributed to the wheel |
| P7 | 88 | B · line 46 | factual error (inverted) | "having evolved lactose tolerance" is replaced by three sentences establishing the opposite |
| P8 | 102 | D · line 64 | factual error | Past time is marked chiefly by the secondary endings; the augment is a few branches' prefix of disputed antiquity |
| P9 | 106 | D · line 64 | nitpick | Subjunctive: "wishes, possibilities, intentions" becomes "intentions and things still to come" |
| P10 | 107 | D · line 64 | nitpick | Optative: "hopes, desires, gentle commands" becomes "wishes and possibilities" |

### P7 deserves its own note

Conjugar's finding was that the number thirteen in "Thirteen Yamnaya individuals have been
genotyped directly" is unsupported, and the fix was to write "Dozens". Konjugieren's problem
is larger and different in kind. Its sentence read:

> DNA evidence suggests they consumed significant amounts of dairy, having evolved lactose
> tolerance

That is the negation of what the sources say. Segurel and colleagues screened 48 individuals
affiliated with Yamnaya-associated cultures at rs4988235 and found no lactase-persistent
individual among them, and Conjugar's cluster B lists "the claim that tolerance came later
and not from the Yamnaya" among the things it checked and confirmed. So the Konjugieren
sentence asserted, in four words, the thing Conjugar's essay spends a paragraph denying.

This is the clearest evidence in the run that patching was the right call over
re-researching. No fresh researcher was needed: the fact was already established, verified,
and written down. What the patch does is import Conjugar's three corrected sentences whole,
which is why this is the largest single edit in the diff.

## Divergences, flagged rather than absorbed

The verbatim rule says to paste Conjugar's corrected sentence. Six patches could not be a
straight paste, and each is listed here rather than smoothed into the diff.

1. **P1 restructures a sentence boundary.** Conjugar's corrected text ends the enrichment
   sentence with a period and opens the element list with "Among them were". Konjugieren ran
   the two together with a colon. Taking Conjugar's clause verbatim forces its punctuation
   too, so the colon became a period plus "Among them were". Konjugieren's own element
   glosses, which no correction names, are untouched: "critical for cellular energy" stays
   rather than becoming Conjugar's "without which no cell can pay for anything".

2. **P2 adds one word.** Conjugar's corrected list reads "phosphorus, …; and sulfur, gold,
   uranium". Konjugieren's had no "and". It was added, so that the list closes the way
   Conjugar's does now that "Among them were" heads it.

3. **P5 changes only the number.** Conjugar's corrected sentence is "Between roughly 3300 and
   2500 BC, a people we call the ~Yamnaya~ inhabited the Pontic-Caspian steppe", and it
   splits the etymology into a following sentence. Konjugieren writes "approximately" and
   carries the etymology in a parenthesis. Nothing in the correction touches either, so only
   4500 became 3300. Swapping "approximately" for "roughly" would have been synonym churn
   with no correction content in it.

4. **P7 drops Conjugar's fourth sentence.** "Tolerance came later, and not from them: it was
   still rare in Bronze Age Europe more than a thousand years afterward, and it only reached
   the modern northern European rate, above ninety percent in Scandinavia and the British
   Isles, under selection that was still running three thousand years ago." That sentence
   closes a loop about modern European lactase persistence that Konjugieren's essay never
   opens, and the three sentences kept already carry the correction. Restoring it is a
   one-line decision if Josh wants the fuller version.

5. **P9 and P10 move a clause into a bullet.** Conjugar's correction rewrites a running
   clause, "a subjunctive for intentions and things still to come, an optative for wishes and
   possibilities". Konjugieren presents the four moods as an emoji-led bulleted list. The
   words are Conjugar's verbatim; only the container differs.

6. **P10 loses "gentle commands".** Conjugar's verification note flags this explicitly as a
   known cost: the replacement "silently drops 'gentle commands', which was one of the
   essay's correct details; that is a loss of color, not of truth". Konjugieren pays the same
   cost. Writing "wishes, possibilities, and gentle commands" would be a reworded hedge,
   which the verbatim rule exists to prevent, so it was not done.

Two further notes on the German, which is a translation and therefore a second surface:

7. **D4 fixes a gender error while it is in there.** The old German read "vom heutigen
   Ukraine"; the country is *die Ukraine*. The new text reads "vom heutigen Rumänien und der
   Ukraine". The fix rides along with the correction rather than being a correction itself.

8. **D8 adds a `~…~` span to both languages.** Conjugar's corrected sentence emphasizes
   *secondary*, so English gains `~secondary~` and German gains `~sekundären~`. The bold-span
   count goes from 58 to 59 in each language, symmetrically. Both extracts still validate.

## Corrections deliberately not applied

Conjugar findings whose claim Konjugieren does not make, or already words correctly. Listed
so that nobody re-derives the decision later.

- **A · line 30, the "nearby" attribution.** Applied, see P1. Recorded here only because
  Conjugar's finding is two softenings in one entry and Konjugieren needed both.
- **B · line 44, "present in every Early Bronze Age individual tested".** Konjugieren gives no
  such statistic.
- **B · line 46, the number thirteen.** Konjugieren gives no number. Its problem was the
  inverted claim, handled at P7.
- **D · line 64, the Italo-Celtic r ending.** Konjugieren makes no Italo-Celtic claim at all.
- **D · line 70, macrons on *fēcī*.** Konjugieren cites no Latin.
- **C, E, F, G, H, I, J, K, L, M, N in full.** Spanish-specific from *España* onward. None of
  their claims appears in Konjugieren's shared five sections.

Conjugar dismissals that Konjugieren's text also triggers, and which therefore stay
untouched. Each was raised against Conjugar, researched, and rejected; re-raising them here
would be re-litigating a settled question.

- "Beginning around 70,000 years ago, waves of humans migrated out of Africa" is refuted. 70,000
  is the start of the standard window, and shifting it toward 50,000 would make the sentence
  less accurate.
- "The Yamnaya spoke what linguists reconstruct as Proto-Indo-European … nearly half of humans
  alive today" had its dismissal upheld twice, on the terminology and on the 46 percent arithmetic.
- "speakers layered an intricate architecture of prefixes, suffixes, and infixes" kept its dismissal; the objection was an argument from silence in a tertiary source.
- The three-aspect reconstruction stated flatly, and the stative gloss "a state resulting from
  completed action" both kept their dismissals; these are the handbook formulations nearly
  verbatim.
- "reconstructed as *e-" rather than *h₁e- stays, deliberately. The essay uses no laryngeal
  notation anywhere, and Conjugar's corrected prose keeps *e- for the same reason.
- "Their society appears to have been patriarchal and hierarchical" survived, its hedge doing real work.
- The kurgan burials, the semi-nomadic herding, the *yama* etymology, life at 3.8 billion years,
  *Homo sapiens* at 300,000 years, and the steppe as the crucible were all confirmed sound.

## Residue: claims the patch could not reach

Claims in Konjugieren's five shared sections with **no counterpart in Conjugar's essay**.
Patching does not touch them, so they are unchecked. Every one is assigned an owning cluster
in `docs/verb_history_claims.md` rather than being left to the fan-out to notice.

| # | Line | Claim | Assigned to |
|---|---|---|---|
| R1 | 90 | The descendant list "German, English, Ukrainian, Hindi, Persian, Cornish, Greek, and Latin". Conjugar's list was checked; this is a different list | A |
| R2 | 92 | The whole *tewtéh₂ paragraph: PIE *tewtéh₂ from *tew- "to swell, be strong"; Proto-Germanic *þeudō; Old English þēod; Medieval Latin *theodiscus*; Modern German *Deutsch*; and the Haudenosaunee autonym glossed "people of the long house" | E |
| R3 | 93 | "PIE verbs were built on roots (typically consisting of a consonant-vowel-consonant structure)" | D |
| R4 | 102 | "The system allowed for present, past (preterite), and arguably future expressions" | D |
| R5 | 110 | "with a developing passive" | D |
| R6 | 113–117 | The five ablaut grades with their reconstructed forms: *bʰer-, *bʰor-, *bʰr-, *mḗh₁-n̥s, *n̥-péh₂-tōr | E |
| R7 | 119 | "the present stem might use e-grade while the perfect used o-grade; the zero-grade appeared in certain suffixes and in unstressed positions" | E |
| R8 | 121–123 | The three German triads with their English glosses: singen/sang/gesungen, nehmen/nahm/genommen, geben/gab/gegeben | E |
| R9 | 125 | "direct inheritances from Proto-Indo-European, preserved across five millennia of linguistic evolution" | E |

The prompt predicted the residue would concentrate in `Ablaut`, and it did: R6 through R9 are
that section, and they are the section's whole substance. Conjugar's counterpart section is
about Spanish *losing* ablaut and cites Latin; Konjugieren's is about German keeping it and
cites German. Almost nothing overlaps.

## Notes for the fan-out and for agent H

These are not findings. They are things Phase 0 saw while holding the whole text open, and
several of them are seams the patch itself created.

**The patch manufactured one live contradiction.** Patched line 102 now says the augment
belongs to a few branches and that "whether it goes back to Proto-Indo-European at all is
disputed". Unpatched line 150 still says "The ~augment~ (*e-), which had marked past tense in
PIE, was lost entirely in Germanic." You cannot lose what may never have been there. This is
exactly the between-ranges contradiction the prompt built agent H to catch, and it is now
manufactured rather than latent. Inventory row **D7** carries it.

**One downstream echo of P3 survives in the German half.** The closing paragraph at line 187
still says "that primordial cloud of supernova-enriched gas". P3 broadened the same epithet at
line 82 to "star-forged" on Conjugar's nitpick. The two now disagree. Inventory row **G14**.

**The horse claim at line 126 was not patched and now leans on a hedged one.** Line 126 says
the migrants were "Equipped with horses, wheeled carts, and perhaps bronze weapons"; patched
line 86 says whether the Yamnaya rode is disputed. That is not necessarily wrong, since owning
horses is not riding them, but the two sentences were written to agree and no longer plainly
do. Inventory row **A4**.

**The seam the prompt worried about does not exist here.** The prompt anticipated that a
patched opening might promise something about what a German learner has to memorize which the
Germanic half then fails to deliver, by analogy with Conjugar's *poder* / *puedo*
contradiction. Konjugieren's opening makes no such promise: where Conjugar's line 61 ends "and,
eventually, the reason a student has to memorize that the preterite of ~hacer~ is $hICE$",
Konjugieren's counterpart simply stops at "one of history's most consequential linguistic
developments". Nothing was imported that would create the promise either. Agent H should still
look, but this particular trap is empty.

**Two English style violations, both in the unpatched half.** Line 157 has a comma splice:
"German strong verbs must largely be memorized individually, their ablaut patterns, while
still systematic, are no longer predictable from the infinitive." The German uses a colon
there and is correct. Line 171 has "The peculiar conjugations … reflects", a subject-verb
disagreement; the German "spiegeln … wider" is correct. Both are English-only and neither is a
factual matter, so they are notes rather than inventory rows.

**One German translation defect worth an editor.** English line 156 explains that the Swiss
German word for "kitchen" is "Chuchi". The German renders this as `das schweizerdeutsche Wort
für "Küche" ist daher "Chuchi", im Gegensatz zum Hochdeutschen "Küche"`, which is circular: it
contrasts *Küche* with *Küche*. The English works because the head word is English. The German
needs recasting, not retranslating.

**Two `$…$` spans look wrong on their face**, and Phase 3 owns them. `$nahm$` at line 121 is
written entirely lowercase, claiming no irregularity, while `$gAb$` on the next line marks its
ablaut vowel; both are strong preterites of the same kind. And `$kAnN$` at line 171 marks the
final *n* as irregular in a way that is hard to derive from any regular composition of
*können*. Neither is a factual claim, so neither is an inventory row.

**Cluster briefs that have no rows.** The prompt's cluster briefs name several things the essay
never mentions, and a researcher looking for them will waste searches. Corded Ware, the Jastorf
culture, and any pre-Germanic substrate appeal are all absent from cluster A's range. The three
legion numbers and the Suetonius "Quintili Vare, legiones redde" line are absent from B's.
Notker is absent from E's. Konjunktiv I by name, the decline of Konjunktiv I in speech, and
Luther are all absent from G's, whose subjunctive discussion is entirely about Konjunktiv II.
The inventory records these as coverage facts so that "nobody reported it" is distinguishable
from "it was not there".
