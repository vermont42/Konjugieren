# Verb history, Phase 3: the essay against the app

Phase 3 checks "A History of the German Verb System" against Konjugieren's own code and its own
conjugation output. No web research was done and none is cited. Where the essay and the app
disagree about a German conjugation, the app is treated as the arbiter, except where the app is
itself wrong, which happened once and is reported as a finding against the app.

Files under review: `docs/verb_history.txt` (English source, body from line 79) and
`docs/verb_history_de.txt` (German, body from line 45). Neither was edited. The only file created
was a temporary test, `KonjugierenTests/Utils/VerbHistorySpanTests.swift`, deleted after the run.

## What ran and what it proved

**1. `scripts/sync_verb_history.py --check`, both languages.** Clean.

```
markup OK (en): 2900 words, 18 headings, 27 conjugation spans, 0 warning(s)
markup OK (de): 2829 words, 18 headings, 27 conjugation spans, 0 warning(s)
```

**2. `scripts/test_sync_verb_history.py`.** 18 checks, 0 failures. Every validator still fires,
including the two that matter most here: "balanced across headings but not within a block" and
"lone capital in a conjugation span".

**3. An independent per-block parity check**, written so that a bug shared between the checker and
this report could not hide. Both files split into 19 body blocks and 18 headings; every body block
holds an even count of each of `~`, `‡`, `$` and `^`; no heading contains any of the four inline
markers, so nothing in a heading is silently literal.

**4. A live falsification of the per-block rule.** One stray `~` was injected into the first body
block of the English essay and a second into a later block, leaving the essay's overall tilde count
even. The script reported two problems, one per block. The per-block rule is real, not aspirational,
and the script covers it.

**5. The temporary Swift Testing suite, `VerbHistorySpanTests`.** Eight tests ran; five assertion
failures across four of them. Test count read from the run rather than inferred from the exit
status, per `CLAUDE.md`:

```
Suite "VerbHistorySpanTests" started
    ✔ singen() … ✖ nehmen() 2 issue(s) … ✔ geben() … ✖ können() 2 issue(s)
    ✔ kommen() … ✔ werden() … ✖ lesen() 1 issue(s) … ✔ dumpEveryFormTheEssayTouches()
✘ Test run with 8 tests in 1 suite failed after 0.054 seconds with 5 issues.
```

Comparisons were case-sensitive, because case is the claim. Inside `$…$` every uppercase letter is
an irregular letter that `RichTextView` reddens, keyed on `Character.isUppercase` in
`StringExtensions.parseConjugationToSegment`. A case-insensitive comparison would have verified the
one thing nobody disputes.

The eighth test dumped every form the essay touches, marked and bare alike, so the unmarked
neighbours could be judged from the same run. The relevant output:

| probe | app emits |
|---|---|
| singen prät 1s / 3s | `sAng` / `sAng` |
| singen Perfektpartizip | `gesUngen` |
| nehmen prät 1s / 3s | `nAhm` / `nAhm` |
| nehmen Perfektpartizip | `genOmmen` |
| geben prät 1s / 3s | `gAb` / `gAb` |
| geben Perfektpartizip | `gegeben` |
| können präs 1s / 3s / 1p | `kAnn` / `kAnn` / `können` |
| kommen prät Konj II 1s | `kÄme` |
| kommen Perfektpartizip | `gekommen` |
| kommen Perfekt 1s | `BIN gekommen` |
| werden prät Konj II 1s / 3s | `wÜrde` / `wÜrde` |
| werden präs 1s | `werde` |
| lesen präs 3s / 1s | `lIEst` / `lese` |
| auslesen präs 3s | `auslIEst` |
| machen / sagen / spielen prät 1s | `machte` / `sagte` / `spielte` |
| singen präs 1s, Futur 1s, Perfekt 1s | `singe`, `werde singen`, `habe gesUngen` |
| müssen / dürfen / mögen / wissen präs 1s | `mUsS` / `darF` / `mAG` / `wEIẞ` |
| **sollen präs 1s / 3s / 1p** | **`solle` / `sollt` / `sollen`** |

The last row is a bug in the app, not in the essay. It is written up under app-claims below.

## The 27 spans

The two language files carry byte-identical spans in the same order. Verified independently, not
assumed: 27 in each, equal element by element, 17 distinct. The German header's claim at line 24 of
`docs/verb_history_de.txt` therefore holds today, and any correction below has to be applied to
**both files** to keep it holding.

App values come from `Conjugator.conjugate(infinitiv:conjugationgroup:)`. English spans have no app
value, because the app conjugates no English; they are judged against the same rule, namely that the
uppercase must mark exactly the material that a regular composition would not produce.

| # | line en / de | span | lang | app emits | verdict |
|---|---|---|---|---|---|
| 1 | 121 / 87 | `sAng` | de | `sAng` | correct |
| 2 | 121 / 87 | `gesUngen` | de | `gesUngen` | correct |
| 3 | 121 / 87 | `sAng` | en | n/a | correct. sing to sang, i to a, consonants untouched. Byte-identical to the German span by coincidence, which is why span 1 and span 3 read alike |
| 4 | 121 / 87 | `sUng` | en | n/a | correct. i to u |
| 5 | 122 / 88 | `nahm` | de | `nAhm` | **WRONG.** Marks nothing. See H11 |
| 6 | 122 / 88 | `genOMmen` | de | `genOmmen` | **WRONG.** Over-marks the first m |
| 7 | 122 / 88 | `tOOk` | en | n/a | correct. take to took: the vowel is replaced as a unit, t and k survive. Consistent with the app's own treatment of a digraph replacement |
| 8 | 123 / 89 | `gAb` | de | `gAb` | correct |
| 9 | 123 / 89 | `gAve` | en | n/a | correct. give to gave, i to a |
| 10 | 153 / 119 | `mAde` | en | n/a | **WRONG.** Marks the one letter that did not change. See H13 |
| 11 | 153 / 119 | `saId` | en | n/a | **WRONG** in context. See H13 |
| 12 | 155 / 121 | `crEw` | en | n/a | correct. crow to crew, o to e, c/r/w survive |
| 13 | 160 / 126 | `gesUngen` | de | `gesUngen` | correct |
| 14 | 160 / 126 | `sUng` | en | n/a | correct |
| 15 | 161 / 127 | `cAme` | en | n/a | correct. come to came, o to a |
| 16 | 171 / 137 | `kAnN` | de | `kAnn` | **WRONG.** Over-marks the second n and splits a geminate |
| 17 | 171 / 137 | `kAnN` | de | `kAnn` | **WRONG**, same |
| 18 | 171 / 137 | `kAnN` | de | `kAnn` | **WRONG**, same |
| 19 | 174 / 140 | `kÄme` | de | `kÄme` | correct |
| 20 | 174 / 140 | `cAme` | en | n/a | correct |
| 21 | 175 / 141 | `wÜrde` | de | `wÜrde` | correct |
| 22 | 175 / 141 | `wOUld` | en | n/a | correct. will to would: the vowel is replaced as a unit and the dental suffix stays lowercase, which is right, since the suffix is the regular part. The reduction of ll to l is unmarkable in this notation and is the one loose end |
| 23 | 177 / 143 | `wÜrde` | de | `wÜrde` | correct |
| 24 | 180 / 146 | `lIest` | de | `lIEst` | **WRONG.** Under-marks the e of the digraph |
| 25 | 180 / 146 | `lIest` | de | `lIEst` | **WRONG**, same |
| 26 | 187 / 153 | `sAng` | de | `sAng` | correct |
| 27 | 187 / 153 | `gesUngen` | de | `gesUngen` | correct |

**Tally.** 16 German spans checked mechanically against the app. 9 correct, 7 wrong: one `nahm`,
one `genOMmen`, three `kAnN`, two `lIest`. Four distinct German values are wrong. Of the 11 English
spans, 9 are sound and 2 are wrong, both belonging to H13. Nine of 27 span occurrences need to
change.

### The corrections, span by span

Each lands in **both** `docs/verb_history.txt` and `docs/verb_history_de.txt`, at the line pairs
given in the table, since the two files carry the spans byte for byte.

| was | becomes | occurrences |
|---|---|---|
| `$nahm$` | `$nAhm$` | 1 |
| `$genOMmen$` | `$genOmmen$` | 1 |
| `$kAnN$` | `$kAnn$` | 3 |
| `$lIest$` | `$lIEst$` | 2 |
| `$mAde$`, `$saId$` | removed, see H13 | 2 |

All four replacements still satisfy the sync script's lone-capital rule, since each begins with a
lowercase letter. If H13 is fixed as recommended, the essay drops from 27 spans to 25 and both
headers' span counts need updating: `docs/verb_history_de.txt` line 24 states "Die 27 $…$-Spannen".

### Why `lIEst` rather than `lIest`

This is the span where the essay's instinct is most defensible, so it is worth stating the argument
rather than just citing the app. `lesen` takes ablaut group `sehen`, whose entry in
`AblautGroups.xml` is `IE,a2s,a3s`: the stem region `e` is replaced by the two-character string
`IE`, both uppercase. The app therefore reddens both letters, and
`ConjugatorTests.swift:488` has shipped `expected: "lIEst"` all along.

The app is also right on the merits. In `liest` the digraph ⟨ie⟩ is a single grapheme for a single
long vowel, and the ⟨e⟩ inside it is not the surviving ⟨e⟩ of ⟨les⟩; the two spell different
phonemes. Writing `lIest` tells the reader that one letter of the stem survived the alternation,
which is false. The decisive practical argument is the same one that settles spans 6 and 16: a
reader who meets `lIest` in the essay is one tap from the verb detail view, where the app shows
`liest` with both letters red. An essay whose highlighting contradicts the app one tap away teaches
the reader to distrust the highlighting.

### Where the essay's instinct was not baseless

Two of the wrong spans were wrong in an interesting direction, and the reason is in the app's data.

`$genOMmen$`. The app's group is `Omm,pp`, replacing `ehm`. Only the O is marked, so the app says
the geminate mm is not new material. Yet the base stem has one m and the participle has two, so one
of those m's genuinely is new. The essay marked it. The app still wins, for the tap-away reason
above, but this is a marking the app arguably gets slightly wrong, not a plain author error.

`$kAnN$`. Look at the whole preterite-present family in `AblautGroups.xml`:

```
<ag e="können" a="kAnn*,a1s,a3s|…" />
<ag e="müssen" a="mUsS*,a1s,a3s|…" />
<ag e="wollen" a="…"                   → ConjugatorTests expects wIlL
<ag e="dürfen" a="darF*,a1s,a3s|…" />
```

`kAnn` marks the vowel only. `mUsS` and `wIlL` mark the vowel and the final consonant. `darF` marks
the final consonant and **not** the vowel, even though the ü to a change is the entire point. So
`$kAnN$` matches the majority pattern in the app's own preterite-present data; it just does not
match the one entry it is quoting. The correction stands, and the inconsistency is reported below as
a finding against the app.

## H11: `$nahm$` against `$gAb$`

**`$nahm$` gives way. It becomes `$nAhm$`.**

The app settles it without ambiguity. `nehmen` carries `Ahm,bA`, so the Präteritum stem region `ehm`
becomes `Ahm` and the app emits `nAhm`, with the ablaut vowel red and the h black. `geben` carries
`A,bA` and emits `gAb`. Both are e-to-a strong preterites and both mark the vowel; the essay's
`$gAb$` already agrees with the app, and its `$nahm$` does not.

Three further reasons point the same way, none of which needs the app:

1. `$nahm$` was the lone outlier in a three-item list. Its neighbours are `$sAng$` above and `$gAb$`
   below, and both mark the ablaut vowel.
2. The list exists to demonstrate the claim at line 119 that PIE ablaut became the German vowel
   alternations. A span with no uppercase demonstrates nothing: it renders entirely black, exactly
   as unmarked prose would.
3. `$nahm$` is the only span in the essay with no uppercase at all. Every other one of the 27 marks
   something.

The fix is one character in each file, at English line 122 and German line 88. Nothing else on
either line changes.

## H13: the "-ed" list

**The example list gives way.** Recommended replacement, identical in both files:

> This is the origin of the "-te" ending in German preterites (machte, sagte, spielte) and the
> "-ed" ending in English (loved, worked, played).

The sentence's German half and English half are meant to be parallel, and only the German half is.
`machte`, `sagte` and `spielte` are three regular weak preterites, all bare, all spelling the "-te"
the sentence is illustrating; the app agrees, emitting exactly those three strings with no uppercase
anywhere. The English half offers `$mAde$`, `$saId$` and played. Neither of the first two spells
"-ed"; both are wrapped in spans whose uppercase renders them red for "irregular", inside a sentence
whose whole point is that they exemplify the regular pattern; and played, the only one that actually
exhibits the ending, is the only one with no span.

`$mAde$` is additionally wrong on its own terms, independently of the sentence around it. The
irregularity in made is the lost k of make, not the vowel: the a of made is the a of make, unchanged.
The span reddens the one letter that did not change and leaves unmarked the change that happened.
The notation cannot mark a deleted letter, which is a reason to choose a different example rather
than to recase this one. `$saId$` is more defensible in isolation, since the y of say really did
become i, but it is being cited as an instance of a regular suffix, so nothing in it should render
red at all.

If Josh prefers to keep made and said, because both really are weak preterites with the dental
suffix still inside them, then the minimum fix is different: unwrap both to bare `made, said,
played` and reword the clause to say "the dental suffix in English" rather than "the '-ed' ending",
because the claim as written is about the spelling. The recommendation above is preferred, since it
keeps the claim and repairs the examples, and it makes the English half mirror the German half that
is already correct.

Either fix removes two spans, taking the essay from 27 to 25 and requiring the German header's span
count to change.

## Markup integrity

**Passes, in both languages, with nothing outstanding.**

| check | English | German |
|---|---|---|
| body blocks / headings | 19 / 18 | 19 / 18 |
| subheading backticks | 36, balanced | 36, balanced |
| `~` emphasis | 118, balanced, 59 spans | 118, balanced, 59 spans |
| `$` conjugation | 54, balanced, 27 spans | 54, balanced, 27 spans |
| `^` emoji | 6, balanced, 3 spans, all mapped | 6, balanced, 3 spans, all mapped |
| `‡` link | 0 | 0 |
| per-block balance of the four inline markers | every block even | every block even |
| inline marker inside a heading | none | none |
| nesting | none reported | none reported |
| lone leading capital in a span | none | none |
| newline before an opening backtick | none | none |
| asterisks | 20, correctly unpaired | 20, correctly unpaired |

The per-block rule is genuinely covered by `sync_verb_history.py`, not merely claimed. `split_blocks`
mirrors `String.richTextBlocks` by splitting on every backtick and taking the even-index segments,
and `validate` runs `check_inline_markers` over each body block separately rather than over the
essay. `check_inline_markers` keeps one `open_marker` for all four markers, which is the right
simulation of the Swift parser's single shared `markupStart`. The injected-tilde experiment above
confirms it fires. `scripts/test_sync_verb_history.py` already has a negative test for exactly this
case, named "balanced across headings but not within a block", and it passes.

The 20 asterisks are linguistics and must stay unpaired. Nothing in the script or in this check
treats them as markup, and nothing should.

## Links

**Zero links, in both files.** Confirmed by counting rather than by trusting the header: the raw
`‡` character occurs 0 times in the English body and 0 times in the German body, so the regex that
extracts payloads has nothing to extract and `check_link` never runs.

The header's claim at line 38 of `docs/verb_history.txt` ("The essay contains no links today, so the
check is idle") is therefore accurate as of this pass. The check is idle, not absent:
`test_sync_verb_history.py` exercises it with three negative cases (relative link, no host, embedded
space), so the first link added will be validated.

## Claims the essay makes about Konjugieren

The essay never names the app, never says "this app", and makes no claim about what Konjugieren
does. The single occurrence of the string "konjugieren" in the German body is the ordinary verb, at
DE line 48, "und Verben zu konjugieren". So the literal reading of this job returns nothing.

The useful reading is broader: statements about German that the app's own code or corpus can settle.
Four findings, in descending order of importance.

### A. `sollen` conjugates wrongly in the app. The essay is right and the app is wrong.

Line 169 names six preterite-presents: können, müssen, dürfen, sollen, mögen, wissen. Line 171 says
the class takes no ending in 1s and 3s and shows a singular-to-plural vowel difference. That is
correct German, and the app confirms it for können: `kAnn`, `kAnn`, `können`.

It does not hold for `sollen` in the app. In `Verbs.xml`, sollen is
`<verb in="sollen"><reading tn="should, ought, be obligated, shall" fa="w" /></verb>`: family weak,
no ablaut group, unlike the other five, which are all `fa="m"` with their own group. So
`Conjugator.applyAblaut` returns the stem unchanged and the ordinary weak Präsens endings apply:

```
sollen präs 1s → solle     (correct German: soll)
sollen präs 3s → sollt     (correct German: soll)
sollen präs 1p → sollen    (correct)
```

Both singular conjugations are wrong, and they are wrong in precisely the way line 171 says
preterite-presents are not. The essay is the accurate document here.

This survived because it is untested. `ConjugatorTests.modalVerbs()` covers mögen, wissen and
wollen only. A repo-wide search for `"sollen"`, `"können"`, `"müssen"` and `"dürfen"` in
`KonjugierenTests/` returned nothing outside the temporary file this pass created. Four of the six
verbs the essay names, including the broken one, have no test.

The fix belongs to Josh and is not Phase 3's to make, but the shape is clear: sollen needs an
`fa="m"` reading and an ablaut group along the lines of `soll*,a1s,a3s|sollst*,a2s|…`, plus
coverage in `modalVerbs()`.

**Fixed 2026-07-29**, and the shape above was one override too large. `sollen` is now
`<verb in="s^oll^en"><reading tn="…" fa="m" ag="sollen" /></verb>` against a new group
`<ag e="sollen" a="soll*,a1s,a3s" />`. The `sollst*,a2s` override Phase 3 sketched is not needed:
the stem does not alternate, so the ordinary weak 2s ending already yields *du sollst*. Note that
`fa="m"` is `Family.mixed`, not a modal family, and `.mixed` takes weak Präteritum and Perfektpartizip
endings, which is why *sollte* and *gesollt* stay correct with no override at all.

Nothing is uppercased in `soll*`, deliberately. Under the rule that an uppercase letter inside
`$…$` is an irregular letter, no letter of *soll* qualifies: the form is the bare stem, and the
irregularity is the absent ending, which the notation cannot mark. That also keeps the app
consistent with the essay correction this pass made in the other direction, from `$kAnN$` to
`$kAnn$`.

`modalVerbs()` now covers all six preterite-presents plus wissen rather than three, so the four
that had no test anywhere have one. The suite passes at 211 tests in 32 suites.

### B. `auslesen` is glossed in the essay in a sense the app does not ship.

Line 180 reads "er $lIest$ das Buch aus = he finishes reading the book". `auslesen` is in the
corpus, as `aus+l^e^sen`, and the translation the app ships for it is **"select, pick out"**. Both
senses are real German, so the essay is not wrong; but a reader who meets the sentence and then
looks the verb up in the app gets a different meaning with no bridge. Either the essay's gloss or
the corpus reading should move, and the corpus is the cheaper place to add a second reading.

### C. The passive is the one item in the closing list the app does not model.

Line 183 lists the passive with werden or sein plus past participle, alongside future, perfect and
aspect. The other three all correspond to something in `Conjugationgroup`: `futurIndikativ` builds
on werden, `perfektIndikativ` selects haben or sein through `Auxiliary`, and the aspect bullet's
`er liest` is a real Präsens conjugation. `Conjugationgroup` has no passive case; the string
"passiv" does not occur in the file. Not an error in the essay, and not a bug. Recording it because
the essay's closing list is the place a reader forms an expectation about what the app contains.

### D. Terminology and the "form" rule.

`docs/terminology.md` asks that "tense" not be used to describe conjugationgroups. The essay uses
"tense" twelve times, and ten are legitimate historical linguistics about tense as time, including
"two tenses: present and preterite" and "past tense in PIE". Two are headings that name what this
project calls conjugationgroups: "Development of the Perfect Tense" and "The Future Tense and Modal
Verbs". Perfekt and Futur are conjugationgroups here, and the app's own UI labels them Perfekt
Indikativ and Futur Indikativ. Minor and editorial; flagged rather than recommended, since the
headings are historical narrative and the German translations already avoid the word.

The "prefer conjugation over form" rule is satisfied. "Form" occurs three times in the English body
and none of the three refers to an inflected verb: iron would "form Earth's molten core", silicates
rose to "form a crust", and cattle were "a form of currency". Where the essay does mean an inflected
verb it says conjugation, eight times.

### E. Verified and correct

Recorded so a later pass does not re-derive them: every verb the essay cites is in the corpus with
the family the essay implies (singen, nehmen, geben, kommen, werden, lesen strong; machen, sagen,
spielen weak; können, müssen, dürfen, mögen, wissen mixed). Perfect with haben and sein matches
`Auxiliary`. Future with werden matches `Conjugator`'s `futurIndikativ`. The würde periphrasis at
line 172 matches `futurKonjunktivII`, which emits "wÜrde machen". "Ich bin gekommen" is right:
kommen carries `ay="s"` in the corpus. The three principal-part verbs at lines 121 to 123 are all
strong. Line 171's claim about können holds exactly.

## What a future session should not trust

1. **A green `run_tests.sh` says nothing about the preterite-presents.** `modalVerbs()` covers
   mögen, wissen and wollen. können, müssen, dürfen and sollen are untested, and sollen is broken.
   Do not use the app as an oracle for sollen until finding A is fixed.

2. **The app's uppercase marking is not consistent inside the preterite-present class.** `kAnn`
   marks the vowel; `mUsS` and `wIlL` mark the vowel and the final consonant; `darF` marks the final
   consonant and not the vowel, which looks flatly wrong. "The app is the arbiter" settles each span
   individually and yields no rule that generalizes from one modal to another. Check each verb.

3. **`CLAUDE.md`'s mixed-case example for wissen is wrong.** It shows
   `expected: "wEIsS"`. The app emits and the shipped test at `ConjugatorTests.swift:811` expects
   `wEIẞ`, with U+1E9E, the capital sharp s. Do not copy the CLAUDE.md line into a new test.

4. **The span counts in both headers become stale the moment H13 is fixed.**
   `docs/verb_history_de.txt` line 24 asserts 27 spans. The recommended H13 fix leaves 25. Nothing
   automated checks that number; `check_docs.py` does not read these two files.

5. **The byte-identity of the spans across the two files is a live invariant, not a fact.** It holds
   today, verified element by element. Every correction in this report has to be applied to both
   files in the same edit, or the German ships a stale value marked "translated", which does not
   fall back to English.

6. **Line numbers in this report will drift.** Both headers warn that adding a line to the header
   shifts every body line. Findings are cited by quoted text as well as by line for that reason;
   prefer the quoted text.

7. **Phase 3 did not adjudicate H14.** Phase 1 recorded the tension between the essay's claim that
   ablaut is systematic and the app's rendering of those same alternations as red irregularities.
   Fixing the four wrong spans makes that tension slightly sharper, since more letters end up red,
   not less. It remains an editorial decision and it remains open.

8. **`$genOMmen$` and `$kAnN$` were not arbitrary.** Both were corrected toward the app, and the
   reasoning is above. If the app's own marking for either verb is ever revised, these two spans
   have to be revisited, because they were decided by deference and not by an independent argument.
