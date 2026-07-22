# Separability & decomposition audit for imported verbs

**Status:** not started. Queued 2026-07-22 out of the Phase-4 mining run (shards 071–084), where
subagents flagged five `Verbs.xml` entries whose separability marker or root split contradicts
attestation. This is a *conjugation-correctness* task, not an etymology task — which is why it was
deferred out of the mining window rather than fixed inline.

## Why this is delicate (read before touching anything)

Separability is not cosmetic. It changes what the app **conjugates and teaches**:

- A **separable** verb strands its particle in a main clause (*die Milch kocht über*) and takes the
  `-ge-` infix in the Partizip II (*überge­kocht*).
- An **inseparable** verb keeps the prefix attached and takes **no** `-ge-` (*überkocht*).

So flipping a marker changes the app's output for that verb across every conjugationgroup. If a verb
is currently mis-marked, the app is teaching a wrong conjugation **today** — worth fixing. But if a
marker is actually *right* for the reading the app intends, flipping it *introduces* an error. The
job is therefore per-verb verification, not a mechanical sweep.

**These are genuine homograph pairs.** Most German `um-/über-/unter-/durch-` verbs exist in both a
separable and an inseparable form with different meanings and stress:

- *UMlagern* (sep., "relocate, restack") vs *umLAGern* (insep., "besiege, surround")
- *ÜBERsetzen* (sep., "ferry across") vs *überSETZen* (insep., "translate")
- *DURCHbrechen* (sep., "break in two") vs *durchBREchen* (insep., "break through")

`Verbs.xml` carries one reading per entry. When the flagged marker and the entry's own `translation`
disagree, the likely cause is that the import paired a marker with the *other* twin's gloss. So
"fixing" first means **deciding which reading the app should teach** — an editorial call, usually
resolved by matching the marker to the existing `translation`, but confirm against usage.

## The five flagged entries

| verb | shard | marker says | attestation / gloss says | kind |
|---|---|---|---|---|
| `überkochen` | 073 | inseparable | separable "boil over" (*die Milch kocht über*) | separability |
| `umlagern` | 076 | inseparable | gloss "transfer, relocate" is the *separable* twin's meaning | separability |
| `umsorgen` | 077 | separable (`separ:um`) | predominantly inseparable in usage (*umsorgt*) | separability |
| `unterwinden` | 079 | separable (`unter+winden`) | both Luther attestations behave inseparably (*unterwinde sich*) | separability |
| `versiegen` | 084 | root split `ver-` + `siegen` ("win") | false split; continues MHG *versīgen*, to *sīgen* "trickle away" | decomposition |

`versiegen` is the odd one out: a wrong **root decomposition**, not a separability marker. It affects
only the etymology splice (the conjugation is identical either way), and the mined 084 output already
carries a corrected etymology authored inline. So it is the lowest-risk of the five — a `Verbs.xml`
decomposition fix that matters only for a future re-mine.

## Per-verb procedure

For each of the four separability entries:

1. **Locate the entry** in `Verbs.xml` (`hp="y"` marks the imported set). Note its current `in`
   marker, `translation`, and any `separability`/prefix attributes.
2. **Decide the intended reading.** Default rule: the marker should match the entry's own
   `translation`. If the gloss is "boil over," the verb is separable; if "besiege," inseparable.
   Where the gloss itself is ambiguous, pick the reading the app most usefully teaches (usually the
   commoner everyday sense) and record the choice.
3. **Check for an existing test.** Search `KonjugierenTests/ConjugatorTests.swift` for the verb. If
   it has expectations, they encode the *current* behavior — changing the marker will change them,
   and the mixed-case ablaut convention in those expectations must be preserved.
4. **Make the change**, then conjugate the verb both ways to see the diff. The cleanest check is a
   focused test run, e.g. `--only-testing KonjugierenTests/ConjugatorTests/<fn>()` (heed the CLAUDE.md
   trailing-`()` and struct-vs-`@Suite`-name gotchas — a filter that matches nothing still reports
   success).
5. **Show the conjugation diff** (current vs. corrected Partizip II and a V2 present form) before
   committing. For a homograph flip this is the artifact that proves the fix is right, the same way
   the verbatim-quote check proved the mining quotes.
6. **Run the full conjugator suite + build-verify** once all four are changed, since separability
   feeds shared code paths.

For `versiegen`: correct the root decomposition in `Verbs.xml` so the splicer stops emitting the
victory root. Use the *begleiten* exact-remainder test (see `prompts/uses_etymologies.md` § Traps)
to confirm the corrected split, and check whether other `ver-` + `root` entries share the false
split — the same test finds them cheaply.

## Recommended first step

Work **`überkochen` end-to-end as a representative** — locate, decide, show the current-vs-corrected
conjugation and the test impact — before touching the other three. It surfaces the shape of the
decision (and any conjugator surprises) on one low-stakes verb, so the remaining flips are routine.

## Scope note

These five are what one 14-shard mining pass happened to surface, not a complete list. German's
separable/inseparable homographs are a known closed-ish class; a thorough pass would enumerate the
`um-/über-/unter-/durch-/wider-/wieder-` entries and check each marker against its `translation` as a
set. Treat the five above as the seed, not the boundary.

## Invocation

> Please execute `prompts/separability_audit.md`. Start with the `überkochen` representative, show me
> the conjugation diff, then proceed through the other four separability entries and `versiegen`.
