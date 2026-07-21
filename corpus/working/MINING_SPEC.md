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

**The lead sentence has a fixed form, so you never need to look at another shard to match it.**
For a separable compound, German reads `Trennbares Kompositum aus ~auf-~ + ~reißen~:` and English
reads `A separable compound of ~auf-~ + ~reißen~:`; for an inseparable one, substitute
`Untrennbares Kompositum` / `An inseparable compound`. Note the asymmetry — German drops the
article and English keeps it. That is not a slip: it is what the mined corpus already
overwhelmingly does, and these two forms were chosen by counting the existing shards rather than
by taste, so following them keeps new shards consistent with the ones already written.

**Write each morpheme exactly as its `display` field gives it, hyphen included.** Every morpheme
entry carries one — `"display": "~auf-~"`, `"display": "~besser~"` — and it is the whole rule. Do
not derive the hyphen from `kind`, from the shape of the word, or from what a neighbouring shard
did.

The field exists because the hyphen was the most-reported defect of 2026-07-21. The rule used to
key on `kind == "prefix"`, which is the value the shard builder defaults to for the 13 inseparable
prefixes and therefore says nothing about the 233 separable kinds; three shard-runs reported it
unusable on the same morning and each inferred a different answer. The underlying distinction is
bound versus free — *auf-* cannot stand alone in that use, while `besserstellen` takes `~besser~`
because *besser* is an ordinary free adjective and hyphenating it would claim otherwise — but you
no longer have to apply it, because `display` already has. Where the compound also has an attested
history of its own — the `vermeiden` example above — put that first and let the compound clause
follow. A shard-run on 2026-07-20 opened a neighbouring `.out.json` purely to copy this phrasing,
which is both a waste of its budget and a way for the house voice to drift by transcription; it is
written here so the shard is genuinely self-sufficient.

**Pick the sense by analogy, using `sense_exemplars`.** Where a morpheme carries that field, it
is a list parallel by index to `senses`, holding two or three verbs that uncontroversially use
each sense. Find the entry whose exemplars your verb most resembles and take that index. This is
the tiebreaker, and it outranks your own reading of the sense text, because the point is that
every shard resolves the same ambiguity the same way.

The field exists because sense selection was the last genuinely underdetermined step here: two
shard-runs reported on 2026-07-20 that `abmelken` sits between completion and drawing-out, and
`abladen` between separation and downward motion, with the terse `translation` unable to settle
it. One of them invented a tiebreak rule and noted that another shard would invent a different
one. If your verb resembles none of the exemplars, say so in `notes` — a missing sense is a real
finding, and two were added from exactly such a report.

**A denominal sense on a verb root is normal, not a mismatch — but check that the bullet carries
the noun.** Senses like `be-` 3 ("derives a verb from a noun or adjective") are regularly correct
for a compound whose `root` is a *verb*, because the root is usually denominal itself and its entry
says so: `besichern`'s bullet already reads "a denominative verb from the adjective ~sicher~", and
`besteuern`'s already names ~die Steuer~. Read the rendered bullet before concluding the sense is
wrong; the `root:` field alone will mislead you.

Two cases do need your closer. When the root entry **omits** the noun — `bewehren`, whose ~wehren~
bullet never mentions ~Wehr~ — name it there. When the root entry **contradicts** the derivation —
`beringen`, whose ~ringen~ bullet says outright that it has nothing to do with ~Ring~ — say that the
decomposition is formal only and that the verb is denominal from the noun. Do not solve either by
picking a sense you think fits the bullet better; the sense describes the compound, the closer
reconciles it with the root.

**When two senses of one prefix both fit, the tie is broken by the base verb, not by the compound.**
The standing case is `be-` senses 0 and 1, which describe the same operation for a large class of
verbs — sense 0's own exemplar `besteigen` is *auf etwas steigen* → *etwas besteigen*, which is
sense 1's definition read literally. The test that separates them:

- **Sense 1** when the base verb reaches that participant through a **lexically governed**
  preposition or a dative — one that is fixed and has to be memorised. *antworten **auf***,
  *sprechen **über***, *trauern **um***, *folgen* + dative. `be-` only changes its case.
- **Sense 0** when the base verb reaches it through a **free spatial or directional** phrase chosen
  for meaning, or does not reach it at all. *steigen auf/in/über*, *wohnen in/bei*, *atmen*,
  *leben*. `be-` creates the object slot.

Ask whether the preposition is predictable from the meaning. If it could be swapped for another and
the sentence still works (*auf den Berg steigen*, *in den Keller steigen*), it is free, and the
sense is 0. If only one preposition is possible (*auf eine Frage antworten*, never *über*), it is
governed, and the sense is 1. This settles `bescheinen` (free — 0) and `belächeln` (governed — 1),
which have identical surface shape and were being assigned inconsistently.

Two shard-runs invented their own tiebreak here and each said another shard would invent a
different one, which is the `abmelken`/`abladen` drift one level up. **The sense texts themselves
are not being changed**: both are true of the verbs they already describe, and rewording them would
strand 63 mined entries to help about five that remain.

Exemplars are a picking aid only. They are never spliced into the prose and must not appear in
your output — and that includes `notes`, not just the etymology.

**The rule bites in a way that is easy to miss.** Exemplars are ordinary German verbs, and some
are exactly what a good closer would reach for: *ausschenken* is a natural thing to cite while
writing about *ausbringen*. A shard-run on 2026-07-20 caught four such leaks in its own prose
only by checking afterwards. So the constraint is narrower than "avoid these words" — it is
**do not present an exemplar as evidence for the sense you picked**, which is what would make the
selection aid look like an argument. Citing a cognate or a neighbouring compound on its own
merits is fine, and a post-hoc scan of your output against the exemplar list is cheap insurance.

**Every sense is a complete sentence, so add no connective of your own.** It already carries
its own subject — `~be-~ makes an intransitive verb transitive, …` — and concatenating it after
the chain's final period needs nothing between them but a space. This is worth stating because
it is the rule the pipeline has broken most often: senses used to come in two grammars, about
half of them verb-initial fragments that could not be spliced as written, and every subagent
independently invented a connective to bridge the gap. Eight shards ended up carrying four
different ones ("Here it conveys…", "It promotes…", "Here the prefix conveys…", "The prefix
conveys…"). The senses were normalized on 2026-07-20 so that no bridge is needed; if you find
yourself wanting to write one, the sense is malformed and that is a finding to report, not a
gap to paper over.

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
- the token is a **participle used purely adjectivally** — *die abgearbeitete Liste*. This covers
  the **predicative** case too, which is where whole pools disappear: *ist stark ausgeprägt* is an
  adjective, not a passive. The test is gradability — if it takes a degree adverb (*stark*,
  *gering*) or forms a comparative (*geringer ausgeprägt*), it has become an adjective, because
  only adjectives compare. A *werden*-passive (*wurde ausgeprägt*) is a genuine verbal use; a
  *sein*-Zustandspassiv that grades is not. `ausprägen` lost all five candidates this way, which
  is the right outcome: shipping one would teach the adjective rather than the verb.
- the snippet is **too fragmentary** to stand alone, or needs its antecedent to make sense.
- it is a **different verb** that happens to share the form. Candidates are deliberately
  ambiguous: a form maps to several verbs and disambiguation was left to you.
- it is **the other half of a separability doublet** — the same lemma, but the reading your shard
  did not ask for. *durchbrechen* is two verbs spelled alike: separable "break in two" and
  inseparable "break through." The reading's `separability` field says which one you have, and the
  indexer cannot tell them apart because the spelling is identical. The tells are syntactic and
  reliable: an infinitive with `zu` shows it (*zu durchbrechen* is inseparable, *durchzubrechen*
  separable), as does a participle (*durchbrochen* against *durchgebrochen*), and in a main clause
  the separable one strands its particle at the end. `durchbrechen` and `durchdringen` each lost
  three of five candidates this way in one shard, so expect it wherever the chain itself mentions
  a doublet. Reject and move on; it is not a homograph of a different lemma and not an indexer bug.

**Among candidates that are all genuine, prefer one attesting the sense the reading glosses.**
Walk the candidates in order and take the earliest genuine verbal use *whose sense matches the
reading's `translation`*; if none matches, fall back to the earliest genuine use and say so in
`notes`. A different sense of the same lemma is never a rejection — it is a tiebreak, and it
loses to every rejection criterion above.

**Apply the three rules in this order, because two of them used to contradict each other.**

1. **Reject** anything failing a criterion above. This always wins.
2. **Sense.** Among survivors, prefer one attesting the glossed sense — but the sense tiebreak
   **does not reach past a usable candidate to one of 40 words or more**. If the only sense-matching
   candidate is a 61-word Kafka period and a 20-word candidate attests a neighbouring sense of the
   same lemma, take the short one and note the mismatch.

   *Forty is inclusive because the boundary was tested at exactly 40 within a day of being written:*
   `bescheiden`'s only gloss-matching candidate is a 40-word Mann period, and "over 40" let the
   tiebreak reach past a clean 12-word Luther candidate to ship it. German literary prose clusters
   right at that length, so an exclusive bound is a bound that does not bind.
3. **Length.** Among candidates equally genuine *and* equally sense-matching, prefer the one inside
   the 8–30 word band. A 38-word rank-0 loses to a 20-word rank-1 when both attest the gloss.

Otherwise do not reorder. Two shard-runs on 2026-07-20 hit rules 2 and 3 pulling opposite ways
within an hour of the sense rule being added — `ausstoßen` (20-word "expel" against 61-word "emit")
and `ausräumen` (38-word against 20-word, both matching) — and each resolved it sensibly but
differently, which is the drift this brief exists to prevent. The precedence above is what they
were each inventing.

The rule earned its place on 2026-07-20, when three consecutive shards reported the same loss
independently. `aufblasen`'s first candidate is Luther's smith blowing on coals; its second is
Nietzsche's *Zuletzt platzt ein Frosch, der sich zu lange aufblies* — fourteen words, and an
exact attestation of the gloss "inflate." Strict rank order shipped the smith. Both are real
uses of the lemma, so no rejection criterion touched either, and each run invented and then
recorded a different tiebreak — the signature of drift this brief exists to prevent.

Note what this rule is *not*: it does not re-rank the pool, and it never reaches past a
candidate it would otherwise have taken for any reason other than sense. Shards mined before
this date followed strict rank order, so a handful of early verbs attest a sense other than
their gloss. That is an accepted inconsistency, not a defect to repair — re-mining costs far
more than it recovers.

**A verb whose every candidate is a homograph is a known, accepted outcome — not an indexer
bug.** Return nulls and say so; do not infer that the form→lemma map is broken. The map is
built by running the app's own `Conjugator` over every verb, so it does not stem and cannot
confuse two lemmas.

`abfahren` is the standard example, and two shard-runs have now diagnosed it wrongly. All of its
candidates are the token *abführen*, which looks like a different verb and partly is — but
*abführen* is also the genuine Konjunktiv II plural of *abfahren* (*fahren* → *fuhr* → *führe*),
so the map is right to list it. What starves the rarer reading is `MAX_OCCURRENCES = 5`: the
commoner lemma fills every slot before the rarer one is reached. About 179 target verbs, 11% of
those with candidates, lose their whole pool this way. A tail rescue is Phase 5's job.

The tempting inference — that *führen* and *fahren* were collapsed by a stemmer — is wrong about
this pipeline but right about the history: *führen* descends from Proto-Germanic \*`fōrijaną`,
the causative of \*`faraną` "to travel," so it once meant "to make go." The pair really is one
root, which is exactly why the coincidence is so convincing here.

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

**When there is no next candidate, 65 words is the ceiling.** Past that, return `null` rather
than quoting a period that will not fit a phone screen. A null is a productive result — Phase 5
collects them and Josh expands the corpus — whereas an unreadable 80-word quotation ships. Below
65, prefer the shorter candidate but do not reject a usable sentence for length alone.

The ceiling was 45 until 2026-07-20, when a shard-run reported nulling `anbetreffen` and
`andrehen` — both sole candidates, both genuine verbal uses, both 53 words, both trapped in a
single long Nietzsche or Kafka period. Losing a verb's only attestation to eight words of margin
is the worse error, since a null ships nothing at all. It was raised again, to 65, when the
same complaint arrived at 57 words (`aufklingen`, Mann) — at which point the pool was measured
rather than argued about: 22 verbs across the corpus have every candidate above 55 but at least
one at 65 or below, and they were shipping nothing. The distribution has no cliff, so the number
is a judgment about phone screens, not a natural boundary; 65 still nulls the genuine runaways,
which in the shard that prompted the change ran 86 words. The ceiling still exists, and still
binds; it simply no longer sits just below where German literary prose naturally lands. This
applies only when the candidate is the last one — a long sentence never beats a short one that
is equally good.

**Raising this number is cheap and safe, which is why it has moved twice.** The ceiling is a rule
in this brief, not a filter in the indexer, so changing it leaves every candidate pool byte-identical
and cannot orphan a quotation an earlier shard already mined. Contrast the indexer's ranking and
`MAX_OCCURRENCES`, where the same-looking edit invalidates mined work.

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
