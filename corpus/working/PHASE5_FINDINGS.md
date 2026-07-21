# Phase 4 findings held over for the Phase 5 sweep

Cross-cutting observations from mining that belong to no single shard. Per-verb hedges are **not**
here — those live in the `notes` field of each `mine_<NNN>.out.json`, and the sweep should read
them from there rather than from a summary that goes stale (see § Dumping the notes).

This file is tracked, like `MINING_SPEC.md`, even though `corpus/` is gitignored. Everything else
in Phase 4 is either regenerable in about forty seconds or is a mined `.out.json`; this is neither,
and it was nearly lost to a session boundary before being written down.

## 1. Translation-field defects in `Verbs.xml`

Two glosses look like **extraction damage rather than mistranslation**, which is why they are
grouped: both are not-quite-English in a mechanical way, rather than wrong about the German.

| Verb | Shipped gloss | What the verb means |
|---|---|---|
| `ansinnen` | "designate" | *jemandem etwas ansinnen*, to demand or expect of someone — the sense the noun *Ansinnen* ("unreasonable request") preserves |
| `aufstören` | "pattern up" | to rouse, to startle out of rest |
| `ausfolgen` | "follow, accompany" | Austrian officialese for "hand over, release" (≈ *aushändigen*) |

`ausfolgen` is the worst of the three, because it is not merely wrong but *plausible*: an agent
reading "follow" would pick a sense of `aus-` built on motion and write a coherent etymology for a
verb that means something else. The other two announce themselves.

"Pattern up" is the tell: it is not a wrong translation so much as not a phrase, which suggests a
field got mangled upstream rather than mis-glossed. Two instances surfaced from the first 17
shards without anyone looking for them, so a deliberate sweep of the `translation` field is likely
to find more.

**Not fixed here on purpose.** `Verbs.xml` feeds the classify-and-verify oracle, so edits move the
at-odds count that `docs/roadmap.md` treats as the repo's regression gate. Neither half of this
pipeline touches `Verbs.xml`, and it should stay that way.

## 2. `separ:aufeinander` is tagged `kind: deictic`

It is a reciprocal, not a deictic — there is no speaker orientation in it. The brief's `kind`
table has no row that fits, so an agent following the table would write "toward/away from the
speaker" for `aufeinanderlegen`, which is nonsense. The morpheme's own `chain` text is correct;
only the `kind` tag is wrong. Either add a reciprocal row or retag.

## 3. Indexer fixes that were diagnosed correctly and declined anyway

Recorded so a later session does not re-derive them and reach a different answer. All three are
real defects. None was worth fixing, and the reasoning is the same each time: **they live in the
indexer, where a change re-ranks candidate pools and can orphan an already-mined quotation** — the
failure that hit shard 001's `abgehen` on 2026-07-20.

| Defect | Reported by | Measured | Why declined |
|---|---|---|---|
| Stranded particle credited to the wrong verb (`ansuchen` ← "fing … zu suchen an") | 011 | 4 of 5,250 candidates, **all already mined** | Nothing pending to rescue. A clean morphological fix exists — a separable verb infixes *zu* (*anzusuchen*), so "zu suchen … an" can never be *ansuchen* — and it still pays nothing. |
| Hyphen-severed extraction (`Das werden wir gemein- Aber neben`) | 015 | 15 of 5,250 (0.3%) | Agents reject these reliably by hand, which the brief prefers as a visible loss over a silent edit. |

### Two that were declined and then taken, which is the more useful record

Both were declined on a first reading and reversed once the right question was asked. Kept here
because the reversal is the lesson, not the outcome.

- **Luther verse numbers.** First declined on "filtering rescues nothing — those verbs are null
  either way". True, and the wrong question. Shard 018 pointed out the corrupt candidate was ranked
  *first*, so the exposure was never a missed rescue: it was a corrupt sentence shipping silently,
  which the validator cannot catch because verbatim-quoting a corrupt candidate passes every check
  it makes. Shard 024 then found the actual gap — `VERSE_NUMBER` required lowercase *after* the
  numeral, `BARE_VERSE_NUMBER` required lowercase *before* it, and `sprach: 24 Du Menschenkind` has
  punctuation before and a capital after, so it fell between them. **Fixed 2026-07-20.**
- **Wiki markup.** `WIKI_MARKUP` anchored list markers at `^` and had no `=` heading rule at all.
  51 matches, all in `weimar-verfassung-de.txt`; `auswandern` had lost its only candidate. **Fixed
  2026-07-20.**

## 3a. `be-` senses 0 and 1 overlap, and the boundary is being invented per shard

Sense 0 ("makes an intransitive verb transitive") and sense 1 ("promotes what the base verb governs
with a preposition or a dative to a direct object") describe the *same operation* for a large class
of verbs. Sense 0's own exemplar `besteigen` is literally *auf etwas steigen* → *etwas besteigen*,
which is sense 1's definition. Shard 025 resolved it by base-verb transitivity, noted that the rule
was its own invention, and correctly predicted another shard would invent a different one — the
`abmelken`/`abladen` situation that `sense-exemplars.json` was built to end, recurring one level up.

The discriminating fact looks like **object type**: sense 0's exemplars (`besteigen`, `betreten`,
`bewohnen`) all take a ground or location; sense 1's (`beantworten`, `besprechen`, `betrauern`) take
abstract or communicative content. If that is the intended split, saying so in the sense text would
settle it permanently.

**Resolved 2026-07-20 in the brief, not in the sense texts, and the reasoning is the point.** The
first instinct was to reword both senses. Measuring first killed that: 39 mined entries carry sense
0 and 24 carry sense 1, so rewording strands **63** — while only about **5** of the 33 pending `be-`
verbs would ever face the choice, the rest being double-prefix compounds (`einbehalten`,
`vorbestellen`, `herausbekommen`) where `be-` sits inside a lexicalised stem.

Decisively, **the shipped text is not wrong**. "Makes an intransitive verb transitive" is true of
*besteigen*; "promotes what the base verb governs with a preposition or dative" is true of
*belächeln*. The overlap means a verb *could* have gone either way, not that any verb received a
false statement. So this was never a defect in shipped prose — it was an ambiguity in the selection
rule, which by definition only affects verbs not yet selected.

`MINING_SPEC.md` now carries the decidable test: **governed preposition or dative → sense 1; free
spatial or directional phrase, or no object at all → sense 0.** Ask whether the preposition could be
swapped and the sentence still work (*auf den Berg steigen* / *in den Keller steigen* — free, so
sense 0) or whether exactly one is possible (*auf eine Frage antworten*, never *über* — governed, so
sense 1). It validates both exemplar sets as they stand and explains the inconsistent pairs:
`bescheinen` (free, correctly 0) against `belächeln` (governed, correctly 1).

**The general lesson, which § 3c should be read against:** an overlap between two senses is not the
same defect as a wrong sense. The first is fixable in the brief for nothing; the second needs the
text changed and every mined entry re-anchored. Establish which one you have before paying for the
second.

## 3b. Unmatched delimiters in quoted sentences

Grimm and Luther candidates routinely carry an unmatched `»`. Shard 025 flagged it as needing one
orchestrator-level decision rather than twenty-five independent ones, which is right. Quoting
verbatim is non-negotiable — it is the check that proves a subagent quoted rather than paraphrased —
so the question belongs to rendering, not to mining.

Relevant: the app already has a `Unterminated Delimiters` sub-suite in `StringExtensionsTests`, so
this case is anticipated on the parsing side. Confirm the rendered result before deciding anything;
this may already be handled.

## 3c. `be-` sense 3 and the denominal claim — investigated, and **not** a defect

Shard 026 reported that sense 3's "derives a verb from a noun or adjective" misdescribes
`besichern`, `besteuern`, `betätigen`, and `bewehren`, which attach `be-` to an existing *verb*.
Reading the **rendered bullets** rather than the `root:` field overturned that, and the correction
is worth keeping because the same mistake is easy to repeat:

| verb | what its root bullet already says |
|---|---|
| `beschulen` | "Derived from the noun ~Schule~" |
| `besichern` | "A denominative verb from the adjective ~sicher~" |
| `betätigen` | "Derived from the adjective ~tätig~" |
| `besteuern` | "The root noun ~Steuer~ carries two meanings…" |

The root is denominal itself and its entry says so, so sense 3 reads coherently straight after it.
The `root: root:sichern` field looks like a verb and is what misled the report.

**Rewording would have made things worse.** Dropping the denominal claim to accommodate these would
degrade `bewaffnen` ← *Waffe*, `beflaggen* ← *Flagge*, and `benachrichtigen` ← *Nachricht*, where it
is exactly right — a majority degraded for a minority the bullets already handle.

Two cases are genuinely awkward and belong to the closer, which is now stated in `MINING_SPEC.md`:
`bewehren`, whose ~wehren~ bullet never mentions ~Wehr~; and `beringen`, whose ~ringen~ bullet says
outright that it has nothing to do with ~Ring~ (shard 026 already handled that one in its closer and
notes). No sense text changed; nothing re-anchored.

## 3d. A third verse-number shape, still unfiltered

`bewerfen` candidate 0: `…an einen unreinen Ort schütten 42 und andere Steine nehmen…`. This is
**lowercase, numeral, lowercase**, which both patterns miss — `VERSE_NUMBER` wants punctuation
before, `BARE_VERSE_NUMBER` wants a capital after. It survived the 2026-07-20 fix, which closed the
punctuation-then-capital gap.

**Left unfixed deliberately, and this one may deserve to stay that way.** The other two shapes had a
mechanical tell that never occurs in real German. This one does not: "kostet 42 und mehr" is
ordinary prose, and the government sources are dense in exactly that construction. Measure the false
positives before touching it — a filter that eats legitimate Bundestag sentences to catch Luther
versification is a bad trade.

### Extraction defects still unfiltered

Reported but not acted on. Both are mechanically detectable in principle and neither has been
measured against the pool, so measure before building anything:

- **PDF hyphenation not rejoined** — `Bundeszuständig keit`, `verkehrs trägerübergreifend`. Costs
  `bereinigen` its only genuine candidate. Detecting it properly needs a dictionary check on the
  concatenation, which is why it was left; a naive rule would eat legitimate compounds.
- **Trailing footnote markers** — `bekannt.1)`. Narrow and cheap, but only one instance seen.

The general principle these three establish, worth keeping: *a correct diagnosis and a worthwhile
remedy are different questions.* Ask what the fix rescues **among verbs not yet mined** before
paying for it.

## 4. Verbs whose entire candidate pool is corrupt or homograph-starved

Two distinct starvation classes, both belonging to the Phase 5 tail rescue:

- **Homograph-drained: ~179 target verbs** (11% of those with candidates). `abfahren`'s pool is
  all *abführen*, genuinely both that verb's infinitive and the Konjunktiv II of *abfahren*.
  `MAX_OCCURRENCES = 5` is what starves the rarer lemma. Already described in `MINING_SPEC.md`.
- **Verse-corrupt: 11 pending verbs** as of shard 016, including `einreisen`, `einstürzen`,
  `erringen`, `herüberkommen`, `hinausgeben`, `mitfolgen`, `nachschauen`, `verkämpfen`,
  `zerbeißen`, `zuvorsagen`. Every candidate is a Luther passage with inline verse numbers.

Both are corpus-expansion problems, not extraction problems: the fix is more sources, which is
exactly what Phase 5 is meant to collect these lists for.

## Dumping the notes

The per-verb hedges are the richest evidence Phase 4 produces and they are scattered across the
shard outputs. Do not transcribe them into this file; read them:

```bash
python3 - <<'PY'
import json, glob
for f in sorted(glob.glob('corpus/working/shards/mine_*.out.json')):
    for verb, entry in json.load(open(f)).items():
        if entry.get('notes'):
            print(f"{f.split('_')[-1].split('.')[0]}  {verb:22} {entry['notes']}")
PY
```
