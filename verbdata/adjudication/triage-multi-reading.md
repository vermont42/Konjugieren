# Adjudication triage — 6 of 6 proposals judged

**6 accepted · 0 amended · 0 rejected.** 6 correction(s) written to `verbdata/gloss-review/gloss-corrections-multi-reading-final.json`.

## Verdict by traceability

Traceability was withheld from the adjudicator, so this table measures something.

| | accept | amend | reject |
|---|---|---|---|
| repick | 0 | 0 | 0 |
| partial | 2 | 0 | 0 |
| authored | 4 | 0 | 0 |

## Accepted (6)

- **passieren#1** `pass through, strain` → `pass, cross` (partial) ✓ both models wrote the same gloss independently
- **tauchen#1** `dive, surface` → `dive down, plunge` (authored)
- **umgehen#0** `deal with, handle` → `bypass, circumvent` (partial)
- **umgehen#1** `circulate, make a detour` → `deal with, handle` (authored) ✓ both models wrote the same gloss independently
- **zurückziehen#1** `retreat, move away` → `move back (relocate)` (authored)
- **überkochen#0** `overcook` → `cook again` (authored) ✓ both models wrote the same gloss independently
## External verification against attested use (2026-07-26)

Hand-checked in session, per `prompts/multi_reading_glosses.md`: Reverso Context for
frequency-ranked renderings (the Chrome MCP, since it 403s WebFetch), DWDS where the question was
which *paradigm* carries which sense — a distinction Reverso's per-lemma pooling cannot make.
**All six survive.**

| key | shipped | applied | attested-use finding |
|---|---|---|---|
| `umgehen#0` | deal with, handle | bypass, circumvent | Reverso ranks `deal · handle · bypass · avoid · circumvent`. The split is visible in the grammar of the examples, not the ranking: every *mit*-dative use ("mit Stress umgehen") renders deal/handle, every accusative-transitive one ("das Zollamt umgehen") renders bypass. The pair was **crossed**. |
| `umgehen#1` | circulate, make a detour | deal with, handle | Same source; the separable *mit*-dative verb is deal/handle, ranked 1st–2nd overall. |
| `überkochen#0` | overcook | cook again | DWDS lists two entries with explicit paradigms: sense I *kocht über / übergekocht /* sein = boil over; sense II *überkocht / überkocht /* haben, marked *landschaftlich, besonders österreichisch* = "etw. noch einmal kochen". The app's reading pair is a faithful model of a real split. Reverso ranks `boil over · overboil · run high · overcooking`; "cook again" appears in no bilingual pair and the inseparable sense has no DWDS corpus citation, only its dictionary example. Kept unmarked, on the `fernschauen` precedent. |
| `tauchen#1` | dive, surface | dive down, plunge | Reverso ranks `dive · dip · appear · immerse · plunge · emerge · submerge · swim`. **"surface" is absent from the list entirely** — the `anschlagen` shape from the recall-gap pass. |
| `zurückziehen#1` | retreat, move away | move back (relocate) | Reverso ranks `withdraw · retreat · retire · retract · pull back …` with every free example reflexive, so it cannot settle this; DWDS can. Its sense 3 is "zum Ausgangsort ziehen" with both examples in **sein** — "sie *sind* nach Leipzig zurückgezogen" — which is exactly this reading. |
| `passieren#1` | pass through, strain | pass, cross | Reverso ranks `happen · pass · pass through · occur · happen to · cross · come · go through · go wrong · strain`. The shipped gloss paired the 3rd-ranked rendering with the **last**. |

Two notes for the record.

**`überkochen` is regionally restricted and deliberately not labelled.** DWDS marks the inseparable
sense Austrian/regional, and a learner meeting "cook again" will not learn that. Appending
"(regional)" was rejected as reproducing the leaked-dictionary-apparatus defect class the sweep spent
49 shards removing — `gloss_review.md` rates `entmieten` "of a landlord" high-severity for exactly
that. The precedent is `fernschauen`, which the brief's own worked example glosses "watch television"
with no marker despite being Austrian and southern.

**`passieren#1` is the weakest of the six, and it is the one rated `low`.** "pass through" ranks 3rd
and would be defensible on its own; what makes the shipped gloss bad is pairing it with the
last-ranked "strain", which turns a comma the house style reads as synonymy into a sieve. Both
`pass, cross` and `pass, pass through` would fix that. Nothing here is load-bearing.
