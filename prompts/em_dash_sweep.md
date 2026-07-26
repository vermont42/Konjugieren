# Sweeping the em dashes: a plan

**Audience: a future session enforcing a style rule the corpus has never honored.**
[`docs/english_writing_style.md`](../docs/english_writing_style.md) says "Avoid em dashes entirely,"
gives two reasons, and has been ignored by roughly every generated artifact in the repo. This
document says how many there are, which of them must **not** be touched, and why the obvious
`sed` is the wrong tool. Written 2026-07-26, from counts taken the same day.

Companion: [`cognate_precision.md`](cognate_precision.md), which sweeps the same files for a
different defect and should probably run in the same pass. See "Run this with the cognate sweep."

## The rule, and why it has teeth

> Avoid em dashes entirely. Instead, use a colon, semicolon, or comma. Or break into a new sentence
> with a period. This prohibition springs from two facts. First, Josh dislikes em dashes as an
> æsthetic matter. Second, many readers infer, often correctly, that prose containing em-dashes is
> AI-generated.

The second reason is the one that makes this worth doing rather than merely tidy. The etymologies
and most of the long-form Info text **were** model-generated, and the em dash is precisely the tell
Josh names. A reader who notices it is not wrong.

## The population is not one population

This is the whole design of the sweep. Counts as of 2026-07-26:

| surface | em dashes | in scope | what it is |
|---|---|---|---|
| `Konjugieren/Models/Etymologies.json` | 10,742 | **10,742** | authored prose, user-visible. Also 138 en dashes and 250 double hyphens |
| `Konjugieren/Models/ExampleSentences.json` | 4,651 | **2** | 4,372 are the citation separator, 277 sit in quoted sentences |
| `Konjugieren/Assets/Localizable.xcstrings` | 592 | **592** | UI strings and the long-form Info articles. Also 296 en dashes |
| `KonjugierenWidget/Localizable.xcstrings` | 3 | **3** | widget strings |
| `docs/` + `prompts/` (81 files) | ~3,484 | **1,489** | `etymologies.md` (1,293) and `blog_notes.md` (~700) are logs |
| `*.swift` (130 files) | 45 | **45** | comments |
| **total** | **~19,517** | **~12,873** | |

**Roughly 12,900 of 19,500 are in scope; the other third is exempt.** Two of those counts drift by
design and must be re-derived rather than trusted: `blog_notes.md` grows with every session, and
this file's own specimen count changes when it is edited. `CLAUDE.md` is absent from the table
because it was swept on 2026-07-26 and holds none.

Four classes, and they take four different verdicts.

### 1. Quoted text: DO NOT TOUCH. Confirmed by Josh, 2026-07-26.

All **55** German example sentences containing an em dash are **mined quotations**: Kafka's *Der
Proceß*, Nietzsche's *Zarathustra*, Grimms' *Märchen*, Luther's Bible, Bundestag plenary protocols.
**Zero** are Claude-authored. Changing one would falsify a quotation, which is a worse defect than
the one being fixed and is not recoverable by a later pass.

The English side is 166 sentences, of which **164 are translations of mined German and 2 are
Claude-authored**. Translations inherit the exemption: a translation whose punctuation diverges from
its source reads as a different sentence. The two authored English sentences are in scope, and the
check that identifies them is membership in `verbdata/authored/provenance.json`.

```python
prov = set(json.load(open("verbdata/authored/provenance.json")))
in_scope = {k for k, v in S[lang].items() if "—" in v["sentence"] and k in prov}   # 0 de, 2 en
```

### 2. The `source` field: a format decision, not prose

**4,372** of `ExampleSentences.json`'s em dashes are in `source`, where the dash is a structural
separator in a citation format: `Kafka — Der Proceß`, `Bundestag — Plenarprotokoll 20/214`,
`Mann — Der Tod in Venedig`. That is not prose containing an em dash; it is a delimiter that
happens to be spelled with one.

**Resolved 2026-07-26: the separator does not change. Leave all 4,372 alone.** The style rule is
about prose, and a delimiter in a citation format is not prose. This is the largest single exemption
in the sweep, so it is worth stating in the negative too: a later pass that counts em dashes in
`ExampleSentences.json`, reports 4,651 outstanding, and calls it a regression has misread the scope.

### 3. Authored prose: the actual work

Everything else. `Etymologies.json` is the bulk, and it splits again:

| | en | de |
|---|---|---|
| em dashes in **shared component bullets** | 2,565 | 2,563 |
| em dashes in **per-verb prose** | 2,719 | 2,895 |

### 4. Internal docs: the two logs are excluded

`docs/` and `prompts/` hold about 3,484, and **1,995 of them are excluded as logs.**

**`docs/blog_notes.md` (~700, and growing) is left alone**, and this is not laziness. `CLAUDE.md`
describes the journal as dated project memory that narrates what was tried and when; rewriting its
punctuation edits the historical record to make the past comply with a rule it predates.

**`docs/etymologies.md` (1,293) is left alone too. Resolved 2026-07-26: Josh confirms it is a log.**
The same argument applies, and it is the larger of the two.

That leaves **1,489** across the other 79 files, which are live documents describing current truth
and are fair game. The largest are `docs/ui-audit-2.md` (215), `prompts/uses_etymologies.md` (76),
`docs/wwdc2026-whats-new-swiftui.md` (62), and `docs/roadmap.md` (56); the rest is a long tail of a
few dashes per file. Note what the exemption actually rests on: a log is exempt for being a
**historical record**, not for being internal. A live internal doc gets no exemption from being
internal.

**The journal's exclusion is not permission, and the distinction has a place to live now.**
`CLAUDE.md` says Josh may eventually generate blog posts from `blog_notes.md`, and a blog post
publishes under his byline, where the rule plainly governs. So the archive keeps its em dashes as
a record of how the entries were written, and the sweep belongs in the **post-generation step**
instead. That is now written into `CLAUDE.md`'s work-journal section and into
`docs/english_writing_style.md`, so it does not depend on a future session reading this plan.

## The 4× economy: deduplicate before reviewing

**70% of etymology bullet lines are repeats.** 6,194 bullet occurrences reduce to **1,872 distinct
strings**, because every `ab-` verb carries the same `ab-` bullet:

```
  94x  • ~ab-~: From MHG ~ab(e)-~, from OHG ~ab(a)-~, from Proto-West Germanic *~ab~, …
  71x  • ~ein-~: …
  69x  • ~halten~: …
```

For this sweep that means: **419 distinct bullets contain an em dash, covering 1,835 occurrences.**
Fix the 419 strings and 1,835 sites change. A per-verb pass would review the identical `ab-` bullet
94 times and risk fixing it 94 different ways, which is worse than not fixing it: inconsistency
across entries is more visible to a user than a dash.

So the pipeline is:

1. Extract every distinct bullet line containing an em dash. Fix those **once**, as a set.
2. Apply each fix to every entry carrying that exact string, asserting the occurrence count matches
   what was measured.
3. Then review per-verb prose, which is genuinely per-verb and cannot be deduplicated.

## Why this is not a `sed`

`s/—/,/g` produces wrong prose at a rate that would need a review pass anyway. The rule names four
replacements (colon, semicolon, comma, new sentence), and which one applies is a judgment about the
clause. Three real cases from this morning's work:

| before | after | why |
|---|---|---|
| `…over the rim of the pot — ~die Milch kocht über~.` | `…over the rim of the pot, as in ~die Milch kocht über~.` | needed a connective, not punctuation |
| `…and ~überprüfen~ ("to check over") — the prefix of doing a thing a second time` | `…("to check over"); it is the prefix of doing a thing a second time` | needed a semicolon **and** a subject |
| `a formal declaration — ~einen Antrag~, ~eine Klage~ — and one withdraws oneself` | `a formal declaration (~einen Antrag~, ~eine Klage~), and one withdraws oneself` | a dash **pair** is parenthetical; commas would collide with the list's own commas |

The third is the one a `sed` gets catastrophically wrong. Paired dashes bracket a parenthetical, and
replacing both with commas inside a comma-separated list produces a sentence no reader can parse.
**Count the dashes per sentence first**: a lone dash and a matched pair are different problems.

## Detection is unambiguous, because the corpus sets every dash the same way

Measured over `Etymologies.json`, English side, 2026-07-26:

| spacing | count | share |
|---|---|---|
| `word — word` (open, spaced both sides) | **5,281** | 99.9% |
| spaced on one side only | 2 | 0.0% |
| `word—word` (closed) | 1 | 0.0% |

**Search for U+2014 unconditionally.** No context test is needed, because the corpus never uses the
closed form that a rule about prose would have to think about: an em dash set tight can be doing
typographic work inside a compound, and a spaced one between clauses is always the punctuation this
rule targets. Every hit is the latter.

That uniformity is itself worth understanding, because it is a **second, independent tell** on top of
the dash. A closed em dash is the American convention, in Chicago and every American house style.
British and AP style avoid the em dash here entirely and use a **spaced en dash** instead,
`word – word`. The spaced *em* dash is neither convention. It is what splitting the difference across
mixed training sources produces, and to anyone who has done copy-editing it reads as machine-set
before the dash itself even registers. Do not "fix" the spacing; remove the dash.

For anyone typing the characters deliberately on macOS: `⌥⇧-` gives the em dash, `⌥-` the en dash.
The family is hyphen-minus `-` (U+002D), en dash `–` (U+2013), em dash `—` (U+2014), figure dash `‒`
(U+2012), and true minus `−` (U+2212).

One note about this document itself. The thirteen em dashes still in it are **specimens**: code
literals being searched for, quoted `source` values, the "before" column of the table above, and the
spacing table below. They illustrate the defect and must survive, on exactly the principle that
exempts the Kafka sentences. Everything that was this document's own prose has been fixed. If a
future counter flags this file, that is the counter's bug.

## Ordering, and the en dashes

`Etymologies.json` also holds **138 en dashes** (`–`) and **250 double hyphens** (` -- `), and
`Localizable.xcstrings` holds **296 en dashes**. Sweep them in the same pass. The double hyphens are
plainly artifacts (one was found sitting in `zurückziehen` on 2026-07-26, in text that had
already shipped), and most are a comma or a colon.

En dashes need a second look rather than a blanket rule: a genuine numeric range (`1904–1944`, which
appears in the dedication) is correct typography and must survive. Filter to `–` **with spaces
around it** before proposing anything.

## Run this with the cognate sweep

[`cognate_precision.md`](cognate_precision.md) reviews the same distinct-bullet population for a
different defect: **940 distinct bullets mention "cognate", covering 4,395 occurrences**, and 419
of the dashed bullets overlap that set. Two passes over the same strings, a week apart, will produce
two rounds of merge conflicts against a 7.5 MB JSON file, and the second will have to re-derive the
dedup machinery. Build the extract-distinct-bullets step once and let both sweeps consume it.

## Steps

1. **Both scope questions are already answered** (2026-07-26): the `source` separator does not
   change, and `docs/etymologies.md` is a log. Nothing blocks the start. Re-derive the counts in the
   table above before trusting them, since two of them drift by design.
2. Build `verbdata/style/extract_units.py`: emit every distinct bullet line and every per-verb prose
   paragraph containing `—`, ` – `, or ` -- `, each with its occurrence count and the verbs carrying
   it. Assert the totals against the table above; a mismatch means the corpus moved and the counts
   in this document are stale.
3. Fix the **distinct bullets** first, as one reviewed set. Verify each replacement's occurrence
   count matches the extract, and that `git diff --stat` shows the expected line count and no
   collateral churn.
4. Review per-verb prose in shards. Same brief shape as `gloss_review.md`; the reviewer returns a
   replacement sentence, never a punctuation substitution.
5. Assert the exclusions held: **zero** changes to any sentence not in `provenance.json`, and zero
   to `blog_notes.md`.
6. `python3 scripts/check_docs.py`, the suite via `ios-build-verify`, screenshots of `VerbView` and
   the Info articles, and a journal entry.

## What "done" means, and a warning about the counter

The natural finish line is "zero em dashes outside the exempt set," and the natural check is a
`grep -c`. **Do not add that check to `check_docs.py` without an exemption list that names the
quoted sentences.** A checker that counts dashes repo-wide will go red the next time a Kafka
sentence is mined, and the fix a future session will reach for is deleting Kafka's dash. Any
assertion here must be scoped to authored text, the same way `CACHE_FILES` is scoped to files that
make no historical claims.

## Kickoff: paste into a fresh session

````
Execute prompts/em_dash_sweep.md: enforce the no-em-dash rule in docs/english_writing_style.md
across the corpus. Working directory: /Users/josh/Desktop/workspace/Konjugieren

Read that plan first. Key points it explains: the population splits four ways and only one of them
is in scope. Em dashes in MINED example sentences are correct and must not be touched (Josh,
2026-07-26). All 55 dashed German sentences are Kafka, Nietzsche, Grimm, Luther, Bundestag; only
2 English sentences are Claude-authored and in scope. 4,372 dashes are a citation separator in the
`source` field, which is a format question for Josh, not prose. docs/blog_notes.md is dated project
memory and is left alone. 70% of etymology bullets are shared, so 419 distinct strings cover 1,835
sites. Deduplicate BEFORE reviewing or the same ab- bullet gets fixed 94 different ways.

Both scope questions in step 1 are already resolved, so nothing blocks the start.
````
