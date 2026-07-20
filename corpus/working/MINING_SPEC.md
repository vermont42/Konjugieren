# Mining brief — Phase 4 of `prompts/uses_etymologies.md`

You are producing, for each verb in one shard, **an etymology and an example sentence**, in
German and English. Your shard is self-contained: everything you need has been joined into it.

**Do not read the corpus.** Do not read `Etymologies.json`, `Verbs.xml`, or the kaikki JSONL.
Phase 2 exists precisely so you don't have to — the German corpus is ~6.5 MB and a subagent
that searches it pays that cost for nothing. The single narrow exception is step 3, and it
applies to roughly 3% of candidates.

**Expect to finish without opening any file but your own shard.** If you find yourself reading
source texts for most of your verbs, re-read step 3 — you are paying for something you were
already given.

## Your input

`corpus/working/shards/mine_<NNN>.in.json`, shaped:

```json
{ "morphemes": { "separ:ab": {...}, "root:arbeiten": {...} },
  "verbs": [ { "verb": "abarbeiten",
               "readings": [ { "in": "ab+arbeiten", "translation": "work off",
                               "family": "w", "auxiliary": null,
                               "prefixes": ["separ:ab"], "root": "root:arbeiten" } ],
               "candidates": [ {"doc":…, "line":…, "token":…, "text":…,
                                "truncated":…, "contiguous":…, "source":…} ] } ] }
```

Morphemes are **interned**: `prefixes` and `root` hold keys into the shard's `morphemes`
table, because a shard is usually 25 verbs sharing one prefix and inlining it 25 times was
waste. Look each key up; every key resolves.

A morpheme entry carries `de` and `en`. A **root**'s value is a ready-to-use string. A
**prefix**'s value is `{kind, chain, senses}` — `chain` is the genealogy, reusable verbatim;
`senses` is the range of contributions the prefix can make, from which you pick the one that
fits *this* compound.

`kind` says what the "prefix" actually is, and it changes how you write the bullet:

| kind | how to phrase its contribution |
|---|---|
| `particle` | a true verbal particle: "the prefix conveys …" |
| `deictic` | give the orientation: *her-* toward the speaker, *hin-* away from them |
| `adjective` | resultative: "…until the object is X" (*totschlagen* = beat until dead) |
| `adverb` | adverbial modification, not a resulting state |
| `noun` | incorporated as object or adverbial (*teilnehmen* = take part) |
| `verb` | the state the subject remains in (*stehenbleiben*) |
| `fossil` | say it is no longer a free word; the fossilization is the interesting part |

## What to do, per verb

**1. Compose the etymology. Reuse verbatim; do not re-derive.**

Follow the shape the app already uses for compounds: a lead sentence, then one bullet per
morpheme, then optionally a closing sentence.

```
From MHG ~vermīden~, from OHG ~firmīdan~. Compound of ~ver-~ + ~meiden~:

- ~meiden~: <the root entry, verbatim>
- ~ver-~: <the prefix chain, verbatim> <the picked sense from `senses`, verbatim>

<closing sentence, yours, on the compound's own semantics>
```

What you write is the **lead sentence and the closer**. Everything inside the bullets is
reused: the root entry, the prefix chain, *and* the sense. The `senses` strings are finished
prose written for exactly this slot — pick the index that fits and splice it unchanged. Use the
reading's `translation` to pick: for `abarbeiten` "work off", *ab-* is the separation sense, not
the dismantling one.

Do **not** author a per-bullet sentence of your own on top of the spliced sense. An earlier
version of this brief asked for one, which duplicated the closer's job and made the bullets
drift in voice from shard to shard. Compound-specific meaning belongs in the closer, which is
where the genuinely interesting observation usually goes — that *abkehren* is "turn away" and
not "sweep up," or that *abschaffen*'s root merged a strong and a weak twin.

**Splice by script, not by retyping.** Read the shard with `json.load`, pull the chain, root,
and sense strings out of the `morphemes` table, and build your output with string concatenation.
Retyping them by hand introduces a typo that the verbatim-reuse check will catch as a
divergence, and hunting that typo costs more than writing the script did.

If the verb has **several readings** that differ in meaning or separability (`über*setzen`
"translate" vs `über+setzen` "ferry across"), write one etymology covering both, and say which
reading takes which separability. That contrast is usually the most interesting fact available.

**When a root entry covers two homographs, `family` tells you which one you have.** Several
roots are two verbs that fell together in modern spelling — *kehren* "turn" versus *kehren*
"sweep", *laden* "load" versus *laden* "invite", *löschen* "extinguish" versus the Low German
*löschen* "unload cargo". The root entry describes both branches without saying which your
compound descends from, so pick using the reading's `family` (a strong/weak split usually
separates the twins) together with its `translation`, and **state the choice in your closer** —
that *abkehren* is "turn away" and not "sweep up" is exactly the observation the closer exists
for. If `family` and `translation` disagree, or neither settles it, say so in `notes` rather
than guessing; a confidently wrong branch is worse than a hedge.

**Do not trust a decomposition because it looks like one.** *begleiten* is not *be-* +
*gleiten*; it descends from MHG *geleiten*, which is why it is weak while *gleiten* is strong.
The shard's decomposition comes from `Verbs.xml`'s markers and is reliable, but if the
resulting etymology would be semantically absurd, say so in `notes` rather than writing it.

**2. Pick the sentence: walk candidates in order, take the earliest genuine verbal use.**

Candidates are already ranked and balanced across sources. Reject a candidate when:

- the token is a **nominalized infinitive** — *das Ringen*, *beim Abarbeiten*. German
  capitalizes nouns, so this is usually visible; the indexer already filters most, not all.
- the token is a **participle used purely adjectivally** — *die abgearbeitete Liste*.
- the snippet is **too fragmentary** to stand alone, or needs its antecedent to make sense.
- it is a **different verb** that happens to share the form. Candidates are deliberately
  ambiguous: a form maps to several verbs and disambiguation was left to you.

**3. Quote `text` as it stands. Do not re-open the source file unless `truncated` is true.**

Each candidate carries a `truncated` flag. When it is `false` — which is the case for about
97% of candidates — `text` is the stored quotation in full, and you should quote it verbatim.
Opening the file to re-derive a sentence you were already handed wastes most of a shard's
budget and is how a misquote gets manufactured: several of these sources are two-column PDF
extractions, and reassembling prose across a column gutter by hand is error-prone in a way that
reads perfectly fluently afterward.

**Know precisely what the flag claims.** `truncated: false` means *the indexer did not clip
this text to fit a length ceiling*. It does **not** certify that the upstream sentence splitter
produced a whole sentence. The two are different guarantees, and earlier shard-runs rejected
candidates that arrived flagged complete while ending mid-clause on a comma. The indexer now
drops the mechanically detectable cases — text starting lowercase, ending without terminal
punctuation, severed by a column gutter, carrying a stray `(A)`/`(B)` column marker, a Luther
verse number between clauses, or raw wiki markup — but it cannot catch every mis-split. If a
candidate is plainly not a sentence, reject it and move on; the flag is not an instruction to
quote something broken.

Trust the flag over the punctuation *in one specific respect*: a sentence may legitimately
*contain* an ellipsis — the Bundestag protocols use them for interruptions — so a leading or
trailing "…" is not evidence of truncation and its absence is not evidence of completeness.

Copy the chosen `text` and `source` into your output **programmatically, by candidate index**,
for the same reason you splice the morphemes by script: a validator checks that your quoted
German is exactly equal to some candidate's `text`, and a retyped quotation fails that check on
a single character.

Only when `truncated` is true may you open the file at `doc:line` to recover the whole
sentence. `doc:line` points at the matched verb itself. If it does not resolve, move to the
next candidate rather than quoting a fragment.

Keep the sentence a reasonable length for a phone screen — roughly 8 to 30 words. Candidates
are now sorted so that ones inside that band come first within their rank tier, so the earliest
genuine verbal use is usually also the right length.

**When there is no next candidate, 45 words is the ceiling.** Past that, return `null` rather
than quoting a period that will not fit a phone screen. A null is a productive result — Phase 5
collects them and Josh expands the corpus — whereas an unreadable 62-word quotation ships. Below
45, prefer the shorter candidate but do not reject a usable sentence for length alone.

**Never trim a sentence to hit that target.** Quote it whole or reject it. German puts the
finite verb second and strands its particle at the clause end, so the target verb frequently
sits in precisely the subordinate clause a length-trim would remove — this has already happened
once in this pipeline, and the trimmed quote no longer contained the verb it was illustrating.

**4. Translate it into natural English.** Not a gloss — real English prose that a learner would
recognize as the same thought. Keep the target verb's sense visible in the translation.

Use the candidate's `source` string verbatim as the citation. Do not invent or reformat one.

**5. If no candidate is a genuine verbal use, return `"sentence": null` and say why in
`notes`. Do not invent a sentence.** About a third of the targets have no candidates at all —
`"candidates": []` — and for those the sentence is null with `notes: "no candidates"`. The
etymology is still required. An honest null is worth more than a plausible fabrication; Phase 5
collects the nulls and Josh expands the corpus for them.

## Markup

| Marker | Use |
|---|---|
| `~word~` | emphasis; wraps every cited word form |
| `*~form~` | reconstructed form, asterisk **outside** the tildes |
| `"gloss"` en / `„Glosse“` de | meaning gloss |

Never use `` ` ``, `$…$`, `‡…‡`, or `^…^` — all four are meaningful to the app's parser.
German prose uses `„…“` and never ASCII `"`. Bullets are `- ~morpheme~: …`, one per line.

**These rules govern the prose you write, never the sentence you quote.** Some corpus sentences
punctuate speech with ASCII `"`, and the validator compares your quoted German to the candidate
by exact equality — so "correcting" those marks to `„…“` fails validation. Verbatim always wins:
inside a quoted sentence, copy every character as it stands.
Paragraph breaks are real newlines in the JSON string, never a literal backslash-n.

## Your output

Write **one file**, `corpus/working/shards/mine_<NNN>.out.json`, same number as your input:

```json
{ "abarbeiten": {
    "etymology": {"de": "…", "en": "…"},
    "sentence": {"de": {"sentence": "…", "source": "…"},
                 "en": {"sentence": "…", "source": "…"}},
    "notes": null } }
```

- Every verb in your shard must appear as a key, even if both halves failed.
- `sentence` is `null` (not an empty object) when no candidate was usable.
- `source` is identical in `de` and `en`.
- `notes` is a short string or `null`. Use it for a rejected decomposition, a hedge, or the
  reason a sentence is missing.

Validate that the file parses as JSON and that its key set equals your shard's verb list
before you finish.

**Write no file but your own `.out.json`.** In particular, do not append to
`docs/blog_notes.md`, even though the repo's `CLAUDE.md` asks contributors to journal their
work. Shards run concurrently, and several agents appending to one file corrupt it. The journal
entry for Phase 4 belongs to the orchestrator, which writes one entry per session covering every
shard — your report is how your shard reaches it.

Reply with a short report: verbs done, sentences found versus null, and anything you hedged or
refused.

**Report friction, not just status.** If you wanted a file your shard should have contained,
rejected candidates for a reason that kept recurring, did expensive work that could have been
precomputed, or worked around this brief rather than following it, say so concretely. If you
think this brief is factually wrong about German morphology or etymology, say that and give your
reasoning. Every substantive improvement to this pipeline so far came from a report of this kind
rather than from anyone inspecting the code — the length ranking, the corrupt-candidate filter,
and the correction to what `truncated` means were all found by subagents mining shards, and each
cost seconds to fix and would otherwise have degraded every shard that followed.
