# Mining brief — Phase 4 of `prompts/uses_etymologies.md`

You are producing, for each verb in one shard, **an etymology and an example sentence**, in
German and English. Your shard is self-contained: everything you need has been joined into it.

**Do not read the corpus.** Do not read `Etymologies.json`, `Verbs.xml`, or the kaikki JSONL.
Phase 2 exists precisely so you don't have to — the German corpus is ~6.5 MB and a subagent
that searches it pays that cost for nothing. The one exception is step 3 below, where you
re-open a single source file at a single line.

## Your input

`corpus/working/shards/mine_<NNN>.in.json`, shaped:

```json
{ "morphemes": { "separ:ab": {...}, "root:arbeiten": {...} },
  "verbs": [ { "verb": "abarbeiten",
               "readings": [ { "in": "ab+arbeiten", "translation": "work off",
                               "family": "w", "auxiliary": null,
                               "prefixes": ["separ:ab"], "root": "root:arbeiten" } ],
               "candidates": [ {"doc":…, "line":…, "token":…, "text":…,
                                "contiguous":…, "source":…} ] } ] }
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
- ~ver-~: <the prefix chain, verbatim> <one sentence, yours, on what it does here>

<optional closing sentence on the compound's own semantics>
```

What you write is the **joining prose**: the lead, the per-compound sense sentence after each
prefix chain, and the optional closer. The chains and the root text are not yours to rewrite.
Use the reading's `translation` to pick the sense that actually fits — for `abarbeiten`
"work off", *ab-* is the separation sense, not the dismantling one.

If the verb has **several readings** that differ in meaning or separability (`über*setzen`
"translate" vs `über+setzen` "ferry across"), write one etymology covering both, and say which
reading takes which separability. That contrast is usually the most interesting fact available.

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

**3. Re-open the source at `doc:line` for one clean, complete sentence.**

The `text` field is a ±200-character snippet and is often truncated mid-clause. Read the file
around that line and take the whole sentence. `doc:line` points at the matched verb itself and
resolves for about 99% of candidates; if it does not resolve, try the next candidate rather
than quoting the snippet.

Keep the sentence a reasonable length for a phone screen — roughly 8 to 30 words. If the only
clean sentence is a 60-word legal period, prefer the next candidate.

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
before you finish. Reply with a short report: verbs done, sentences found versus null, and
anything you hedged or refused.
