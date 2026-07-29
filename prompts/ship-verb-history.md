# Ship the corrected verb-history essay

**Status: not started. Written 2026-07-29.** This is the last mile of the fact-check run in
[`verify-verb-history.md`](verify-verb-history.md), which is complete. That run corrected the essay
in both extracts. This one takes Josh's own editing pass, propagates it to the German, and puts both
localizations into the app.

**Step 1 is Josh's and blocks everything else.** He reviews `docs/verb_history.txt` and edits it. No
session starts at step 2 until he says the English is final.

## Where things stand

| File | State |
|---|---|
| `docs/verb_history.txt` | English source. Phase 0's ten patches plus every correction from `docs/history_corrections.md`. Validates clean |
| `docs/verb_history_de.txt` | German. The same corrections, plus three repairs that exist only here. Validates clean |
| `Konjugieren/Assets/Localizable.xcstrings` | **Untouched, and two runs behind.** Still the pre-Phase-0 text, so nothing corrected has ever shipped |
| `docs/history_corrections.md` | Why the essay says what it says. Its "What was applied and what was not" section lists nine declines |

The catalog being two runs behind is the thing to hold onto: when the sync finally happens it lands
the ten Conjugar patches, yesterday's 69 corrections, and Josh's new edits, all at once. Nobody has
seen that text rendered in the app.

## Do not do these things

1. **Do not re-translate the German essay.** Translate only the sentences Josh changed. The German
   is not a translation of the current English in three places, on purpose. See
   [The three intentional divergences](#the-three-intentional-divergences). A wholesale
   re-translation silently reverts all three, and one of them cannot be recovered by translating at
   any level of care, because the English it would be translating is correct.
2. **Remember that `scripts/sync_verb_history.py` writes by default.** `--check` is what makes it
   read-only. This is worth stating even though the obvious way to get it wrong has been closed:
   the script used to scan `sys.argv` by hand for the literal strings `--check` and `--lang` and
   ignore everything else, so `--help`, `-h`, `--dry-run` and a typo like `--checks` all fell
   through to a real English sync and printed a reassuring `wrote Info.verbHistoryText (en)`. That
   happened on 2026-07-29 while this file was being written, and was reverted with
   `git checkout --`. It now uses `argparse`, so an unrecognized flag exits 2 with a usage message
   and `--help` prints help. **Do not reintroduce hand-rolled argv scanning in a script whose
   default action publishes.**
3. **Do not hand-edit `Localizable.xcstrings`.** The essay lives on one JSON line there. The Edit
   tool renders `\"` as `"` and writes it back unescaped, corrupting the catalog. The sync script is
   the only route. See `CLAUDE.md` § "Editing Localizable.xcstrings Safely".
4. **Do not re-run any phase of `verify-verb-history.md`.** All five are done and three of them cost
   over a million subagent tokens each. In particular, do not re-extract the essay from the catalog:
   the catalog holds the *old* text, so an extraction overwrites everything.
5. **Do not invent a `$…$` span value.** See [Spans](#spans-are-data-not-typography).
6. **Do not trust a count you did not just compute.** Three cached counts have rotted in this
   project inside two weeks: a header claiming 58 emphasis spans when there were 59, a prompt
   claiming "more than fifty" conjugation spans when there were 27, and a correctness table
   predicting 68 emphasis spans when the answer was 70.

---

## Step 1 · Josh reviews and edits the English

**Owner: Josh. Everything downstream waits.**

Open `docs/verb_history.txt`. The body starts after the dashed separator; the header above it is
documentation and ships nowhere. `git diff` against the last commit shows what yesterday's pass
changed, and `git diff --word-diff=plain` renders it inline, which is easier to scan than the
wrapped file.

Four things worth knowing while editing, because they are cheap to respect now and expensive to
repair later.

- **Paragraphs are single long lines.** Word wrap is what makes the file readable. A hard newline
  inside a paragraph becomes a paragraph break in the app.
- **A heading concatenates onto the end of the preceding paragraph**, with no blank line and no
  newline before its opening backtick: `…to conjugate verbs.` then the heading in backticks.
  `RichTextView` supplies its own spacing, so an added newline renders as a visible blank line.
- **The five markers are `` ` `` heading, `~` emphasis, `$` conjugation, `‡` link, `^` emoji.** They
  must balance, and they must balance *within* each backtick-delimited block rather than merely
  across the essay. An unbalanced marker is `Current.fatalError` on the Info screen, not a render
  bug. They also must not nest.
- **Asterisks are linguistics, not markup.** The 25 in the essay mark reconstructed forms. They do
  not pair and must never be "balanced".

If an edit adds or removes a `~…~`, a `$…$`, or an asterisk, do not adjust the header counts by
hand. Step 4 recomputes them.

When the English is final, say so, and hand a session this file.

---

## Step 2 · Scope the work mechanically

Do not read both essays and compare them by eye. The scope is a diff:

```bash
git diff docs/verb_history.txt                    # what Josh changed
git diff --word-diff=plain docs/verb_history.txt  # the same, easier to read
```

If Josh's edits are already committed, diff against the commit before his: `git log --oneline -5 --
docs/verb_history.txt` finds it.

Produce an explicit list of changed sentences before touching the German. Every item on that list
gets a German counterpart; nothing else in the German is touched. Report the list back, because a
sentence Josh rewrote for voice rather than for content still needs its German counterpart rewritten
and it is the easiest kind to skip.

---

## Step 3 · Translate only the changed sentences

For each changed English sentence, locate its German counterpart in `docs/verb_history_de.txt` and
rewrite that sentence alone.

**Rules, in order of how badly they bite.**

1. **Hedge strength is preserved exactly.** This is the failure mode this whole project has hit
   most often: an English hedge that concedes a dispute becomes a German assertion. "Quite possibly"
   is not `womöglich`, and "arguably" is not `wohl`. Both of those were real defects in the shipped
   German and both were repaired yesterday. If a sentence is hedged in English, read your German
   back and ask what it would take for the sentence to be false.
2. **`$…$` spans stay byte-identical between the files**, in the same order. Currently 25. This is a
   live invariant, verified element by element rather than assumed, and it is what lets a
   span-level correction be made once instead of twice.
3. **Markup is equivalent, not identical.** `~…~` spans emphasize technical terms, and those are
   different words in German: `~Aspekt~` for `~Aspect~`, `~Präteritopräsentia~` for
   `~preterite-presents~`. The count should match the English unless there is a reason it cannot.
4. **No em dashes, in either language.** `docs/english_writing_style.md` governs the German too, and
   says why: the German text in this app is the same authored prose in another language rather than
   a concession to German convention. The Gedankenstrich is ordinary German typography and is still
   out.
5. **Match the quotation marks the surrounding line already uses.** The essay is inconsistent, and
   symmetrically so in both languages: exactly one paragraph per file uses curly quotes, the one
   about autonyms and `*tewtéh₂`. Everything else uses ASCII straight quotes. Copy the local habit
   rather than normalizing, and note that ASCII `"` is the quote type that breaks the catalog under
   hand-editing, which is one more reason step 5 uses the script.
6. **English glosses inside the German stay English where they carry contrast**, as in
   `wo das Englische ~pound~, ~water~ und ~make~ hat` and `er $lIEst$ = he reads/is reading`. Ten
   other glosses of ordinary German verbs, such as `~haben~ (to have)`, are vestigial and were left
   alone deliberately; whether to strip them is Josh's editorial call and not this step's.

### Spans are data, not typography

Inside `$…$`, **every uppercase letter is an irregular letter that the app renders red**, keyed on
`Character.isUppercase` in `StringExtensions.parseConjugationToSegment`. A span's capitalization is
therefore a factual claim about which letters a regular composition would not produce.

If Josh's edits introduce a new German span, **the app is the arbiter and you must ask it**, not
reason it out. Phase 3 did exactly this and found four of the essay's German span values wrong,
including one that marked nothing at all. The method: a temporary Swift Testing suite calling
`Conjugator.conjugate(infinitiv:conjugationgroup:)`, compared case-sensitively, deleted afterward.
Read the test count from the run rather than the exit status; `CLAUDE.md` documents three ways a
filtered run reports success having executed nothing.

Two further span rules:

- **The app is not self-consistent across the preterite-presents.** `kAnn` marks the vowel, `mUsS`
  and `wIlL` mark the vowel and the final consonant, `darF` marks the final consonant and not the
  vowel. No rule generalizes from one modal to another. Check each verb.
- **A form whose first letter is irregular can never open a sentence.** The sentence would demand a
  capital and that capital would render as one more red letter, claiming an irregularity the form
  does not have. Recast so something else leads. The sync script enforces this and calls it the
  lone-capital rule.

---

## Step 4 · Recompute both headers

Both files' headers assert counts, and **nothing automated checks them**: `scripts/check_docs.py`
does not read these two files, and the sync script validates structure rather than arithmetic.

Recompute from the edited bodies. Do not predict, and do not carry a number forward from this file,
which will be stale the moment anyone edits anything:

```bash
python3 - <<'PY'
import pathlib, re
SEP = '-' * 80
for f in ['docs/verb_history.txt', 'docs/verb_history_de.txt']:
    body = pathlib.Path(f).read_text().split(SEP, 1)[1]
    print(f, 'headings', body.count('`') // 2, '| $ spans', body.count('$') // 2,
          '| ~ spans', body.count('~') // 2, '| asterisks', body.count('*'),
          '| ^ spans', body.count('^') // 2, '| links', body.count('‡') // 2)
en, de = (pathlib.Path(f).read_text().split(SEP, 1)[1] for f in
          ['docs/verb_history.txt', 'docs/verb_history_de.txt'])
print('spans byte-identical across languages:',
      re.findall(r'\$([^$]*)\$', en) == re.findall(r'\$([^$]*)\$', de))
PY
```

The claim sites:

| Count | Where |
|---|---|
| `$…$` conjugation spans | German header, "Die 25 $…$-Spannen" |
| `~…~` emphasis spans | German header, "Die 70 ~…~-Spannen" |
| asterisks | English header, "The twenty-five in this essay"; German header, "Die 25 Sternchen" |
| `` `…` `` headings | German header, "Die 18 Überschriften" |

The English header states no span or emphasis count, only the asterisk count, so it needs attention
only if an edit adds or removes a reconstructed form.

**The byte-identity line in that script is the one to watch.** If it prints `False`, a `$…$` span
diverged between the languages, and the German ships a stale value marked `translated`, which does
not fall back to English. Fix it before going on.

---

## Step 5 · Validate, in both languages

```bash
python3 scripts/sync_verb_history.py --check
python3 scripts/sync_verb_history.py --check --lang de
python3 scripts/test_sync_verb_history.py
```

The first two print `markup OK (en|de): N words, 18 headings, N conjugation spans, 0 warning(s)` and
exit 0. Problems exit 1. Warnings are conventions rather than correctness and let the run continue,
so **read the warning count rather than only the exit status**.

The third runs the validator's own negative tests, 18 of them, by corrupting a copy of the essay one
way at a time. It is what establishes that the checks in the first two can fail at all. A validator
that has never failed is a validator nobody has tested, and here bad markup is a crash rather than a
render bug.

---

## Step 6 · Sync, and only now

**Exactly these two commands, and note that neither carries `--check`. This is the step that
publishes.**

```bash
python3 scripts/sync_verb_history.py
python3 scripts/sync_verb_history.py --lang de
```

Each validates and then writes its localization of `Info.verbHistoryText`.

Then check the shape of the diff before believing it:

```bash
git diff --stat -- Konjugieren/Assets/Localizable.xcstrings
python3 -c "import json; json.load(open('Konjugieren/Assets/Localizable.xcstrings'))"
```

**Expect exactly two changed lines, one per localization, and zero deletions elsewhere.** The essay
is one JSON line per language. A larger diff means the file was reformatted, which is the
round-tripping failure `CLAUDE.md` describes: `json.dump` writes `"key": value` where Xcode writes
`"key" : value`, so the whole 5,400-line file churns without a single value changing. If that
happens, `git checkout --` the file and find out what did it.

---

## Step 7 · See it in the app

A green script says the catalog parses. It does not say the Info screen renders, and this is the
first time any of this text will have been rendered anywhere.

Use the `ios-build-verify` skill. Resolve the scripts path once per session:

```bash
export IBV_SCRIPTS=$(dirname "$(find ~/.claude/plugins/marketplaces -path '*ios-build-verify*' -name build_app.sh 2>/dev/null | head -1)")
"$IBV_SCRIPTS/build_app.sh"
```

Then launch, navigate to Info, open "A History of the German Verb System", and screenshot it in
both languages. What to look for:

- **It renders at all.** An unbalanced marker is `fatalError`, so the failure mode is a crash on
  entry rather than a garbled paragraph.
- **Red letters land where they should.** Spot-check `$nAhm$`, `$genOmmen$`, `$kAnn$` and `$lIEst$`,
  the four values yesterday's pass changed. Each should match what the verb's own detail view shows,
  which is one tap away, and that agreement is the whole argument for deferring to the app.
- **No literal markup characters are visible.** A stray `$` or `~` in the rendered text means a
  marker was consumed as content.
- **Headings have one blank line above them, not two.**

Two cautions from `CLAUDE.md`. The review prompt fires on simulators with accumulated UserDefaults
and gates the AXTree; tap "Not Now" once, or uninstall the app for a clean reset. And nothing on the
Info screen here is Apple-Intelligence-gated, so an Intel host is fine for this particular check.

---

## Step 8 · Close it out

1. **`python3 scripts/check_docs.py`**, which asserts the machine-checkable claims in the four cache
   files. It does not read the two essay files, which is exactly why step 4 exists.
2. **Update `docs/history_corrections.md`'s status block** to say the essay shipped, with the date.
   It currently says the catalog is untouched.
3. **Update `verify-verb-history.md`'s status block** for the same reason.
4. **Append to `docs/blog_notes.md`**, per `CLAUDE.md`: a `## <Title> (YYYY-MM-DD)` heading at the
   bottom, narrative rather than changelog. Worth recording: what Josh changed and why, anything the
   translation step found, and whether the rendered essay looked like the file.
5. **Commit.** Directly to `main`; this project does not branch.

---

## Reference

### The three intentional divergences

These exist only in `docs/verb_history_de.txt`. All three were introduced deliberately on
2026-07-29. **Do not "fix" any of them toward the English.**

| German line | What it does | Why the English cannot produce it |
|---|---|---|
| `Bis vor 40.000 Jahren, und durchaus auch früher` | Restores a hedge the original translation weakened twice over | `Vor 40.000 Jahren` states a point where English "By" states a bound, and `womöglich` is a plain "possibly" where the English "quite possibly" asserts that earlier is a live reading |
| `und, wie manche annehmen, auch Zukunft` | Restores "arguably" as a flag | `wohl` means presumably and reads as mild affirmation, so an English hedge conceding a dispute had become a German assertion |
| `Es heißt daher "Chuchi", wo das Hochdeutsche "Küche" hat` | Stops the sentence refuting itself | The English works because its head word is English and its contrast term is German. Translating the head word makes *Küche* both the thing being translated and the thing contrasted against. **The English contains no defect, so this cannot be reached by translating it** |

The first two are in text pasted verbatim from Conjugar: the hedge survived the port and then did
not survive the translation, which is the exact failure the verbatim rule exists to prevent and the
one place it has no purchase.

Two smaller German-only repairs, same date, same rule: `einen ~comitatus~` for the Latin masculine,
and the English-only subject-verb fix at "The peculiar conjugations … reflect", where the German was
already correct.

### The markup, from `Konjugieren/Utils/StringExtensions.swift`

| Marker | Meaning |
|---|---|
| `` `…` `` | subheading. Parsed in an earlier pass, so a `~…~` inside one is literal tildes |
| `~…~` | emphasis |
| `$…$` | conjugation; uppercase letters inside are irregular and render red |
| `‡…‡` | link; the essay has none today, so the check is idle but live |
| `^…^` | emoji shipped as a PNG asset |

Bulleted items lead with an emoji rather than a dash: 🇩🇪 for a German item, and 🐎 🐄 🐖 🐐 🐑 down
the livestock for a list that is neither.

### If something looks wrong with a line number

Every line number in this file and in `docs/history_corrections.md` drifts the moment anyone adds a
line to either file's header. Findings are cited by quoted text for that reason. Locate by the text.
The audit that settles a suspect number is four lines of Python matching each quoted fragment
against its cited line, and it is worth re-running before trusting a number: it found nine wrong
line numbers in this run's own inventory.

### Where the reasoning lives

- [`docs/history_corrections.md`](../docs/history_corrections.md) · why the essay says what it says,
  with sources per correction, plus the nine declines
- [`docs/verb_history_phase3.md`](../docs/verb_history_phase3.md) · the spans against the app's own
  conjugator, and the `sollen` bug it found in the corpus
- [`verify-verb-history.md`](verify-verb-history.md) · the whole run, and what a future session
  should not trust
