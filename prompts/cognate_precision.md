# Correcting the imprecise use of "cognate": a plan

**Audience: a future session auditing one word across 3,385 etymologies.** The corpus says "cognate
with" for two different relationships, and only one of them is cognacy. This document says how to
tell them apart, how big the real population is (much smaller than the first count suggests), and
why the first instinct, find-and-replace, would damage several hundred entries that are correct
as written. Written 2026-07-26.

Companion: [`em_dash_sweep.md`](em_dash_sweep.md), which reviews the same strings for a different
defect. **These two should run as one pass.** See "Run this with the em dash sweep."

## The distinction

**Cognates** are reflexes of a common ancestor, inherited by both languages. **Co-borrowings** are
words each language took separately from a shared donor. They look identical in an etymology entry
and they are not the same relationship.

The test is a single question, and it is about *sequence*, not about whether a loan is involved:

> **Did the borrowing happen before or after the languages split?**

- **Before → genuine cognates.** `kaufen` and English `cheap` both descend from Proto-Germanic
  *`kaupōną`/*`kaupaz`, which Proto-Germanic borrowed from Latin `caupō` ("trader"). One borrowing
  event, then ordinary inheritance. `abkaufen`'s "Cognate with English `cheap`, Dutch `kopen`,
  Danish `købe`, Icelandic `kaupa`" is **correct and must not be touched.**
- **After → not cognates.** `kochen` comes from Latin `coquere` via a West Germanic borrowing;
  English `cook` comes from Latin `cocus` ("a cook", the noun) borrowed separately into Old English,
  with the verb derived from the noun later. Two borrowing events, two different Latin words.
  `abkochen`'s "Cognate with English `cook`" is **wrong**, and so is `passieren`'s "Cognate with
  English `pass`" (both from French, separately) and `abliefern`'s "Cognate with … English
  `deliver`" (German from `livrer`, English from `delivrer`).

This is why no regex can do the work. The surface pattern is identical; only the history separates
them.

## Scale: 323 candidates, not 3,385 defects

Measured 2026-07-26 on the English side:

| | count |
|---|---|
| entries using "cognate" at all | **3,385** of 3,572 |
| ...**and** describing a borrowing | **323** ← the candidate population |
| `-ieren` verbs (loans by construction) using "cognate" | 50 of 92 |
| distinct **shared bullets** mentioning "cognate" | 940, covering 4,395 occurrences |

**323 is a candidate count, not a defect count**, and the difference matters more here than in any
previous sweep in this repo. `abkaufen` is in the 323 and is correct. A pass that treats the filter
output as a work list will "fix" genuine cognates into vaguer prose and make the corpus worse in
both directions at once. Expect the true defect rate to be well under half, and require the reviewer
to say *which side of the split the borrowing falls on* in every finding.

## The 4.7× economy, and a consistency argument that outranks it

**70% of etymology bullet lines are repeats**: 6,194 occurrences reduce to 1,872 distinct strings,
because every `ab-` verb carries the same `ab-` bullet (94 of them do). For this sweep, **940
distinct bullets mention "cognate" and cover 4,395 occurrences.**

Deduplicate before reviewing. The cost saving is the smaller half of the argument. The larger half
is that a per-verb pass shows the same `kochen` bullet to a reviewer once per `kochen` compound and
gets a slightly different rewording each time, so the corpus ends up saying three things about one
etymology. Users compare entries; the pipeline never has.

## What the replacement should say

The corpus already contains the phrasing to standardize on. `kopieren` reads:

> Cognate with English `copy` and French `copier`, **all from the same Latin source.**

That trailing clause is doing the work: it says the relationship without claiming inheritance. Three
house options, in descending preference:

1. **"From the same Latin source as English `cook`, Dutch `koken`."** States the relationship
   exactly, costs no more words, and keeps the cross-language list that makes these entries fun.
2. **"Related to English `cook` through Latin `coquere`."** Better when the shared donor is worth
   naming and is not already in the sentence.
3. **Leave "cognate" and add the qualifier**, as `kopieren` does. Weakest, because it uses the word
   and then takes it back.

Do **not** simply delete the cross-language list. It is the most-loved thing about these entries and
the reason a learner reads past the first line.

## The other defect this pass will find, and should record separately

Reading 940 bullets for one word will surface a second, worse class: **"cognate with" pointing at a
word that is not related at all.** That is a factual error, not a terminological one, and it should
be filed at a higher severity with a different type, because the fixes differ: one rewords, the
other deletes a claim. Budget for it in the finding schema up front rather than discovering mid-pass
that there is nowhere to put it. `gloss_review.md`'s single-`type` design was right for glosses and
would be wrong here.

## The decision to get from Josh first

**Is this worth changing at all?** A real case exists for leaving it: popular etymological writing
uses "cognate" loosely, the corpus is internally consistent in doing so, and 3,385 entries of
consistency have their own value. The case against is that this app is precise everywhere else, its
audience self-selects for people who care, and Josh's stated Weltanschauung is delight at *accurate*
connection.

Either answer is fine and the cheap outcome is available under both: **whichever Josh chooses, write
it into `docs/english_writing_style.md`.** The rule's absence is why this question came up twice in
one day on 2026-07-26 (once on `passieren`, once here). A documented loose usage costs one paragraph
and permanently stops the re-litigation; an undocumented one guarantees the next session re-derives
the whole argument, as this document just did.

## Steps

1. **Ask Josh the scope question above before writing any code.** If the answer is "document the
   loose usage," the entire remaining plan collapses to one paragraph in
   `docs/english_writing_style.md`, and that is a legitimate and cheap outcome.
2. Build the distinct-unit extract shared with `em_dash_sweep.md`. Emit every distinct bullet and
   per-verb prose paragraph containing "cognate", with occurrence counts and carrier verbs.
3. Filter to units that also describe a borrowing. Verify the count against the 323/940 figures
   above; a mismatch means the corpus moved since 2026-07-26.
4. Review in shards, on `claude-opus-5`. The brief must require, in every finding, an explicit
   statement of **when** the borrowing happened relative to the split. That is the whole judgment,
   and a finding that omits it has not been made.
5. Adjudicate on `claude-opus-4-8`, per `gloss_adjudication.md`. This population needs it more than
   the gloss sweep did: the failure mode is a confident-sounding false positive on a true cognate,
   and the adjudication brief's "when uncertain, reject" already leans the right way.
6. Apply by distinct string, asserting occurrence counts. `git diff --stat` insertions should equal
   deletions and nothing else should move.
7. `python3 scripts/check_docs.py`, the suite, a screenshot of one changed `VerbView` entry, and a
   journal entry recording the defect **rate** against the 323 candidates. That number is what
   tells a future reader whether the filter was any good.

## Run this with the em dash sweep

Both passes read the same 1,872 distinct bullet strings out of the same 7.5 MB JSON file, and 419
of the dashed bullets are inside the 940 cognate-bearing ones. Running them separately means
building the dedup machinery twice, reviewing overlapping strings twice, and resolving merge
conflicts between two large diffs against one file. Build `verbdata/style/extract_units.py` once,
emit both populations from it, and let the two briefs consume the same extract.

## Kickoff: paste into a fresh session

````
Execute prompts/cognate_precision.md: audit the corpus's use of the word "cognate".
Working directory: /Users/josh/Desktop/workspace/Konjugieren

Read that plan first, then ask me its step-1 scope question before writing code. If I say
"document the loose usage", the whole plan collapses to one paragraph and that is a fine outcome.

Key points it explains: cognates are inherited from a common ancestor; co-borrowings are taken
separately from a shared donor. The test is whether the borrowing preceded or followed the split.
kaufen/cheap ARE cognates (Proto-Germanic borrowed from Latin caupō, then both inherited) and must
not be touched; kochen/cook are NOT (two separate Latin borrowings, two different Latin words).
323 entries are candidates, NOT defects: expect well under half to be real. 70% of etymology
bullets are shared, so deduplicate before reviewing or one kochen bullet gets three different
rewordings. Run this together with prompts/em_dash_sweep.md; they read the same strings.
````
