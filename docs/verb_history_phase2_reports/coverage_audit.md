# Phase 2 coverage audit

Bookkeeping pass over Phase 1's fan-out. No web research, no new questions of fact. Four jobs:
reconcile the 111 inventory rows against the 111 verdicts, read the 80 confirmed rows for
reasoning that does not carry its verdict, verify that no cluster reported outside its own
territory, and settle the inventory's line numbers mechanically rather than by spot-check.

The script is `scratchpad/phase2/audit.py`; its full output is quoted under
[Line-number audit](#line-number-audit).

## Reconciliation

**The table reconciles. Every one of the 111 inventory rows appears exactly once, and the
arithmetic is right in every cell.**

Enumerated, not trusted: 111 rows parsed out of `docs/verb_history_claims.md` (the S1 to S3
settled table excluded, since those are patches rather than inventoried claims), 80 confirmed rows
parsed out of `confirmed_rows.md`, 31 findings parsed out of `index.json`.

- rows in neither confirmed nor findings: **none**
- rows in both: **none**
- rows reported that the inventory does not contain: **none**
- duplicate row refs in any of the three files: **none**

| cluster | inventory rows | confirmed | factual-error | needs-hedging | nitpick | sum | Phase 1's published row |
|---|---|---|---|---|---|---|---|
| A | 10 | 7 | 0 | 1 | 2 | 10 | matches |
| B | 13 | 11 | 1 | 0 | 1 | 13 | matches |
| C | 14 | 7 | 1 | 2 | 4 | 14 | matches |
| D | 20 | 15 | 1 | 1 | 3 | 20 | matches |
| E | 21 | 13 | 2 | 2 | 4 | 21 | matches |
| F | 16 | 13 | 1 | 1 | 1 | 16 | matches |
| G | 17 | 14 | 1 | 0 | 2 | 17 | matches |
| **total** | **111** | **80** | **7** | **7** | **17** | **111** | matches |

Every cluster's factual-error + needs-hedging + nitpick + confirmed equals its row count, the
columns sum to the totals, and the totals match the published 7 / 7 / 17 / 80. Each cluster's row
count also matches what the inventory actually contains, so the published "Rows" column is not
merely self-consistent.

One arithmetic caveat about the shape of Phase 1's table rather than its numbers: its **Rows** and
**Verdicts** columns are identical by construction and can never disagree, so their agreement is
not evidence of anything. The check that can fail is grade-sum against row count, and that is the
one this pass ran.

The inventory's own reconciliation table (`docs/verb_history_claims.md` lines 339 to 348) is still
empty. It is meant to be filled at the end of Phase 2; the numbers above are what belongs in it.

## Thin confirmations

Seven of the eighty. Ordered worst first. Two below the bar are listed at the end and are **not**
flags. Nothing here was researched; these are judgements about whether the written reasoning
carries the verdict it returns.

### 1. G16 · line 187 · "still sounding after fifty centuries" · worth-reopening

The only source is the essay:

> - docs/verb_history.txt lines 92, 125, 126 and 185
>   > The essay states the same interval four times as five thousand years, five millennia,
>   > approximately 5,000 years ago, and a 5,000-year journey

That is the purest instance in the run of a verdict resting on the essay's internal consistency
rather than on anything external. The row's own reasoning then meets the one external fact it
raises, the settled patch S1, by appealing to the prose under audit:

> The one thing that could unsettle the figure is the anchor: S1 now opens the Yamnaya horizon at
> 3300 BC, which would be fifty-three centuries … Rounding fifty-three to fifty in a closing
> cadence would in any case be within the tolerance the surrounding prose sets for itself.

The tolerance the surrounding prose sets for itself is exactly what a fact-check is not allowed to
accept as a warrant. Compounding it, one of the four corroborating occurrences the row leans on,
line 92's "five-thousand-year-old way of saying 'us'", **has no inventory row at all**; cluster E
reported it as a gap. So part of the internal consistency is consistency with a sentence nobody
checked. The underlying figure is very probably fine, which is why this is a reasoning defect
rather than a predicted error, but a skeptic should get to see the anchor question argued rather
than rounded away.

### 2. D1 · line 143 · "As Proto-Indo-European evolved into Proto-Germanic over some two millennia" · worth-reopening

The row's single source is disclaimed in its own annotation:

> - Lehmann, A Grammar of Proto-Germanic, ch. 5
>   > Treats Proto-Germanic as a reconstructed stage … **without assigning the essay's specific
>   > interval.**

So nothing external supports the interval. The reasoning derives it from two other rows plus an
uncited chronology, and closes "I did not research the endpoints themselves." Worse, its own
arithmetic does not quite land where it says:

> The essay's own chronology puts the Germanic separation at 2500 to 2000 BC (A5) and a
> recognizable Proto-Germanic in the first millennium BC (A7), which yields between fifteen hundred
> and two thousand years. "Some two millennia" is the correct round number for that span.

Fifteen hundred years is not two millennia, and A7 is not a confirmed row: it is a Phase 1 nitpick
whose replacement moves Proto-Germanic to the second half of the first millennium BC, i.e. toward
the fifteen-hundred end of D1's own range. The two rows are not in conflict, and cluster A said so
deliberately, but D1's confirmation is the weaker of a pair whose stronger member is under
revision, and it was reached with no source for the quantity it confirms.

### 3. C8 · line 140 · "The Germanic peoples had no centralized states or cities" · worth-reopening

A compound claim whose two halves get very different treatment. The cities half is asserted
without a citation:

> no urban settlement is known anywhere beyond the Rhine and Danube in this period, and the large
> central places that later develop, Gudme, Uppåkra, Helgö, are third century and after

Neither cited source covers that: they are Tacitus, Germania 16 (which is the "only repeats him"
case the cluster brief was told to separate out) and a Britannica entry on Maroboduus. The states
half is confirmed over a named counterexample sitting at the section's own date:

> He is routinely described as the first documented Germanic ruler with a government of that kind.
> That is a genuine complication, but it is also the exception that the standard accounts name as
> an exception … The essay is making a structural point about Germanic society at large, and on
> that point it is right.

The paragraph is anchored at line 136 to "the time of the battle at Teutoburg", and Rome
recognised Maroboduus's kingdom in AD 6. Confirming a universal on the ground that the standard
accounts label its counterexample an exception is a weaker result than the row states.

### 4. C7 · line 138 · "expected gifts of weapons, gold, and feasting in return for their service" · worth-reopening

Weapons and feasting are quoted from Germania 14. Gold is not established; the reasoning
substitutes a weaker claim and says so:

> Germania 15 lists among the gifts sent to chiefs "electi equi, magna arma, phalerae torquesque"
> … which are precious-metal objects. That is enough that the claim as written cannot be called
> wrong, **and the essay does not date the gold.**

Precious metal is not gold, and the essay does date it: the section opens at line 136 with "At the
time of the battle at Teutoburg", which is the very anchor the inventory's C10 row cites for the
runic chronology. The row's own research says the Lübsow-horizon imports contemporary with the
battle are bronze, silver and glass and that Germanic gold rings belong mainly to c. 150 AD and
after; that archaeological dating is sourced to grokipedia.com. So the row confirms "gold" while
its evidence establishes "treasure", and the one-word repair it considered and declined is the
repair its own reasoning argues for.

### 5. C11 · line 140 · "Their literature was oral: heroic poetry, mythological tales, and genealogies" · note-only

The verdict's whole value is the claim that the evidence does not run only through Tacitus:

> The independent strand is comparative: Old English, Old Saxon, Old High German and Old Norse all
> inherit the same alliterative metre and share legendary matter … Jordanes independently reports
> Gothic history preserved in their ancient songs.

Both cited sources are Tacitus, the Latin Library text and Harland's translation. The independent
strand carries no citation, and Jordanes is named without a reference. The claim is not in doubt;
the audit trail simply does not contain the part of the argument that answers the cluster's own
question about corroboration versus repetition.

### 6. E7 · line 156 · Kölsch unshifted /t/ in "et" · note-only

A sound-law row whose entire external warrant is two grokipedia.com pages, "Central Franconian
languages" and "Colognian dialect". The same source appears in E5 and C7. The Ripuarian et / dat /
wat facts are textbook and I would expect them to survive any challenge, so this is a citation
defect rather than a suspected error, but a sound law confirmed only against an AI-generated
encyclopedia is the weakest sourcing in the confirmed set, and the run has better sources for
exactly this material elsewhere.

### 7. G13 · line 185 · "that 5,000-year journey from the Pontic steppe" · note-only

Same structure as G16 and listed separately only because it is the better of the pair: both of its
sources are `docs/verb_history.txt`, but its arithmetic is anchored to A1's "around 3000 BC", which
is externally sourced under A1 to Librado et al. 2021. What it inherits from G16 is the unargued
choice of anchor. A2, A1's gloss row, in turn corroborates itself partly by pointing at lines 185
and 187, which is where G13 and G16 live, so the three rows lean on one another in a small circle
with one external date at its centre. The date holds it up. It is worth knowing that it is the only
thing that does.

**Below the bar, not flagged.** G1 cites Braune/Reiffenstein through a ResearchGate record of a
*review* of it, "as summarized in teaching material derived from it", while the Old High German
paradigms it quotes (nëme, nāmi) come from the researcher rather than from the cited page. F15
confirms "no endings in 1s and 3s" against a source quote covering only "fehlende Endung -t in der
3. Person Singular". Both are terse rather than thin, and both concern facts a reader can check in
any grammar.

## Ownership

**No violations.** Every confirmed row appears under the cluster heading the inventory assigns it,
and every finding in `index.json` carries the cluster the inventory assigns it, checked
mechanically for all 111. The residue rows are where a boundary problem would show first and they
are clean: R1 to cluster A, R3 to R5 to cluster D, R2a to R2e and R6 to R9 to cluster E. Each
row's line label in `confirmed_rows.md` and in `index.json` also matches the inventory's line
field, with no disagreements.

Cross-cluster material was handled by deferral rather than by trespass, which is the behaviour the
partition wants: E9 declines the class VII qualification because "the identical claim is stated
first at line 152 and owned by D9"; A2 notes that lines 185 and 187 "are cluster G's rows G13 and
G16 and I have not researched them"; G13 cites A1 and A2 as owned elsewhere. The one structural
consequence is the small circle described under thin confirmation 7, which is a property of the
inventory's partition rather than of anyone's conduct.

## Line-number audit

Every inventory row's quoted text was matched against the text at its cited line, normalizing
whitespace, the markup characters `` ` ~ $ ‡ ^ ``, asterisks, curly versus straight quotation
marks, en dash versus hyphen, and the emoji bullets. Quotations containing an ellipsis were split
and each side matched independently. Multi-line rows (R6 at 113 to 117, R8 at 121 to 123, F4 at 160
to 161) were matched against the join of their range. A second pass strips parenthetical glosses
from both sides, because the inventory sometimes quotes a sentence with the essay's inline glosses
removed.

Script: `scratchpad/phase2/audit.py`. Output:

```
inventory rows parsed: 111  (duplicates: [])
confirmed rows parsed: 80  (duplicates: [])
finding rows parsed:   31  (duplicates: [])

== RECONCILIATION ==
in neither confirmed nor findings: none
in both confirmed and findings:    none
reported but not in inventory:     none

== ARITHMETIC ==
cl   inv  conf  fact  hedge  nit   sum  published  ok
A     10     7     0      1    2    10  (10, 10, 0, 1, 2, 7)  OK
B     13    11     1      0    1    13  (13, 13, 1, 0, 1, 11)  OK
C     14     7     1      2    4    14  (14, 14, 1, 2, 4, 7)  OK
D     20    15     1      1    3    20  (20, 20, 1, 1, 3, 15)  OK
E     21    13     2      2    4    21  (21, 21, 2, 2, 4, 13)  OK
F     16    13     1      1    1    16  (16, 16, 1, 1, 1, 13)  OK
G     17    14     1      0    2    17  (17, 17, 1, 0, 2, 14)  OK
tot [111, 111, 7, 7, 17, 80]  published total (111,111,7,7,17,80) OK

== OWNERSHIP ==
no cross-cluster reporting: every row was reported by the cluster that owns it

== LINE-NUMBER AUDIT ==
fragments checked: 120 across 111 rows
rows with NO fragment at the cited line: none
  fragment miss C10 (cited 140): 'the time of the battle at Teutoburg' -> [136]
```

**Result: all 111 rows verify.** Phase 1's spot-check conclusion was right, and it is now settled
rather than sampled. The nine shared-half corrections it made are all confirmed in place: S2 at 88,
S3 at 102, R2a to R2e at 92, R3 at 93, R4 at 102, R5 at 110, R9 at 125, with R1 at 90, R6 at 113 to
117, R7 at 119 and R8 at 121 to 123 unchanged and correct.

The single fragment miss is not a defect. C10's claim cell quotes two things: its own claim, "they
did develop the runic alphabet for short inscriptions and magical purposes", which is at line 140
where the row says it is, and the section anchor "the time of the battle at Teutoburg", which is
the opening of line 136 and is quoted as context for the chronology question rather than as the
row's location. Worth recording anyway, because C10 is a live finding and the four-line gap between
the anchor and the runic sentence is part of what its chronology objection turns on.

Phase 0's patch table in `docs/verb_history_phase0.md` was re-checked the same way and is now
correct throughout: P1 to P3 at 80, 80, 82; P4 at 85; P5 and P6 at 86; P7 at 88; P8 at 102; P9 at
106; P10 at 107. The five corrections Phase 1 reported have been applied to the file.

## What a future session should not trust

1. **"Nothing was edited … byte-identical to what Phase 0 left" is no longer true.** Files did
   change after Phase 1 wrote that sentence. `git diff` against HEAD now shows
   `docs/verb_history_de.txt` altered by exactly one line, the header count "Die 58 ~…~-Spannen"
   corrected to 59, which is the correction Phase 1 recommended. `docs/verb_history_claims.md`
   (+34/-11) and `docs/verb_history_phase0.md` (22 lines) carry the line-number corrections.
   `docs/verb_history.txt` and `Konjugieren/Assets/Localizable.xcstrings` are untouched relative to
   HEAD, so the essay itself is still what Phase 0 left. A session that reads the Phase 1 write-up
   and infers the German file is unmodified will be wrong; a session that discards the working-tree
   change will silently restore the stale count of 58. Counted independently here: 118 tilde
   characters per body in both files, so 59 spans, and 27 `$…$` spans, 18 backtick headings and 3
   `^…^` emoji spans in each, identical across the two languages.
2. **"Spot-checked" was doing more work than it could carry.** Phase 1 corrected nine shared-half
   row numbers and then asserted the German-specific rows were fine on the strength of a sample.
   The conclusion survives audit, but the same sentence in a future run should not be believed
   without the mechanical check, and the check is cheap: `audit.py` runs in under a second.
3. **The published coverage table cannot fail in its most visible column.** Rows equals Verdicts by
   construction. Read the grade-sum instead.
4. **The inventory's own reconciliation table is still blank** while its prose above the table
   already asserts the run's totals. Until this pass, that assertion had never been checked against
   the inventory it summarizes. The numbers belong in the table.
5. **C10's cited line does not contain every string the inventory quotes for it.** A future session
   grepping line 140 for "the time of the battle at Teutoburg" will not find it; the anchor is at
   line 136.
6. **The five-millennia figure has four occurrences and three owners.** R9 at 125 (cluster E,
   needs-hedging), G13 at 185 and G16 at 187 (cluster G, both confirmed), and line 92, which has no
   row at all. R9's replacement prose keeps "five millennia" and says it should track G13; G13 and
   G16 corroborate themselves partly by pointing at line 92. Whoever settles one of these must
   settle all four occurrences, and one of them is not in the inventory.
