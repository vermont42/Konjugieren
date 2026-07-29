# Make the red-letter marking consistent across full-override conjugations

**Status: not started.** Written 2026-07-29 from the session that fixed the `sollen`
conjugation bug. Josh will run this **after the verb-history rewrite**, because the two touch
the same three `$kAnN$` spans in the essay and doing them in the other order means resolving a
conflict by hand. See "Ordering" below, which is the one thing in this file that can waste a run.

## What is wrong

Uppercase inside a conjugation is data, not orthography. `StringExtensions.swift:215` reads
`isUpper = char.isUppercase` and line 216 lowercases the character for display, so case controls
one thing only: whether the letter renders red for "this letter is irregular". The rule, as the
essay extract's own header states it, is that a span **should be the difference between the real
form and its regular composition**.

The app does not follow its own rule in a handful of hand-authored forms. Phase 3 of the
verb-history fact-check found it inside the preterite-presents, where three different conventions
sit side by side:

| Group | Form | Marks | Should mark, under the stated rule |
|---|---|---|---|
| können | `kAnn` | the changed vowel | correct |
| wissen | `wEIẞ` | every changed letter | correct |
| müssen | `mUsS` | vowel **plus an unchanged final s** | `mUss` |
| müssen | `mUssT` | vowel **plus an unchanged final t** | `mUsst` |
| mögen | `mAG` | vowel **plus an unchanged g** | `mAg` |
| mögen | `mAGst` | same | `mAgst` |
| wollen | `wIlL` | vowel **plus an unchanged final l** | `wIll` |
| dürfen | `darF` | **the unchanged f, and not the ü-to-a change at all** | `dArf` |

`darF` is the worst of them and is wrong twice: it reddens a letter that did not change and leaves
plain the letter that did. Note that `dürfen`'s 2s, `dArfst`, is already correct, so the group
disagrees with itself.

This is not cosmetic. The red letters are the app's whole visual claim about what a learner has to
notice, and the essay author read `mUsS`-style marking, generalized it, and wrote `$kAnN$` into
`Info.verbHistoryText` three times. Phase 3 corrected the essay to match the app. This plan
corrects the app to match its own rule.

## Scope, measured rather than estimated

`AblautGroups.xml` holds **73 groups**, **171 region-replacement clauses** and **34 full-override
clauses** across **12 groups**. The region-replacement clauses cannot have this defect: their case
comes from the ablaut spec applied to a marked region, so what is uppercase is what was replaced.
**Every instance of the bug is in the 34 overrides**, which is where a human typed a whole form and
its case by hand with nothing checking it.

The 34 divide into three piles, and only the first is unambiguous.

**Pile 1, six forms that are simply wrong.** `mUsS`, `mUssT`, `darF`, `mAG`, `mAGst`, `wIlL`. Each
is a substitution in a non-suppletive verb, so "the regular composition" is well defined and the
diff is one vowel. **Ten assertions** in `ConjugatorTests.swift` change: mUsS 2, mUssT 1, darF 2,
mAG 2, mAGst 1, wIlL 2.

**Pile 2, one form that may not need to exist.** `werden`'s `werdEt*,a2p`. Regular composition is
stem `werd` plus `t`, which the epenthetic-e rule turns into `werdet`, which is the override's own
value. If that holds, the override is a no-op and the `E` marks a change that did not happen.
Delete the clause rather than recase it, and let the ordinary path produce the form. **One
assertion.** Verify the epenthetic-e claim before deleting: `Conjugator.needsEpentheticE` is the
function, and its comment explains why a Dehnungs-h does not trigger it.

**Pile 3, twenty-seven forms where the rule itself is underdetermined**, in `sein` (8), `werden`
(5 remaining), `tun` (4), `gelten` (2), `essen` (1), plus the seven already-correct ones. These
resist the rule for two distinct reasons and the distinction matters:

- **Suppletion.** `sein` has no regular composition to diff against. `BIN`, `IST`, `sIND` are
  wholly marked, which is defensible, but `seI*,c1s,c3s,i2s` marks `I` in a form whose letters are
  all in the stem, and `seiD*,a2p` marks only the `d` that genuinely differs from a regular `seit`.
  The group is internally inconsistent in the same way the modals are, but no mechanical rule
  settles it.
- **Insertion and deletion rather than substitution.** `gegEssen` marks a vowel when the actual
  irregularity is an inserted `g`. `getAn` and `tATest` mark letters across a length change.
  Positional diffing is not defined when the two strings differ in length, and the notation cannot
  mark an absent or inserted letter at all. This is the same limitation that made `soll*` correctly
  carry no uppercase: the irregularity is a missing ending, and no letter can carry it.

**Do not fix pile 3 by rule.** Decide it case by case with Josh, or leave it. Piles 1 and 2 are
seven forms and eleven assertions, and they remove the inconsistency that misled the essay author.

## The durable fix, which is the actual point

Recasing seven forms takes twenty minutes and does not stop the next one. The defect exists because
**34 hand-authored case patterns have nothing checking them**, exactly the way four claim sites went
stale before `scripts/check_docs.py` existed.

Add a test that derives the expected case rather than asserting it. For each full-override clause
whose verb is not on a suppletion allowlist, compute the regular composition the conjugator would
have produced without the override, diff it against the override value, and require that the
uppercase set equals the differing positions. Sketch:

```swift
// Pile 3's suppletive and length-changing forms cannot be derived; they are listed, not computed,
// so that adding one is a deliberate act rather than a silent exemption.
private let unmarkableByRule: Set<String> = ["sein", "tun", "essen", "gelten", "werden"]
```

Two properties matter more than the mechanism. The allowlist must be **explicit and small**, so a
future author adding an override has to justify an exemption rather than inherit one. And the test
must **fail loudly on a new group**, not skip it, since a silent skip is how this class of bug lives.

If deriving proves too awkward against `Conjugator`'s internals, the weaker version still pays:
assert that within a single group, every override marks the changed vowel if it marks anything.
That alone catches `darF`, `mUsS`, `mAG` and `wIlL`.

## Ordering

**Run this after the verb-history rewrite lands.** The essay carries `$kAnN$` three times at line
171, byte-identical in the `en` and `de` values of `Info.verbHistoryText`, and Phase 3 already
resolved them to `$kAnn$` as part of the corrections Phase 4 is applying. Nothing in this plan
touches `kAnn`, which is one of the correct forms, so the two jobs do not collide **as long as the
essay change goes first**. Doing this plan first means the essay rewrite lands on top of a moved
target and someone reconciles two corrections to the same three spans by hand.

Concretely: `docs/verb_history_phase3.md` owns the span corrections, and this file owns the ablaut
groups. They overlap in exactly zero forms today. Confirm that is still true before starting, with
one command:

```bash
python3 -c "
import re, pathlib
spec = pathlib.Path('Konjugieren/Models/AblautGroups.xml').read_text()
essay = pathlib.Path('docs/verb_history.txt').read_text()
overrides = {v[:-1] for v in re.findall(r'a=\"([^\"]+)\"', spec) for v in v.replace('|', ',').split(',') if v.endswith('*')}
spans = set(re.findall(r'\\\$([^\$]+)\\\$', essay))
print('shared:', sorted(overrides & spans))
"
```

## What else mentions these forms, and what does not break

- **`KonjugierenTests/Models/ConjugatorTests.swift`**, 80 lines assert some override form; **eleven
  change** under piles 1 and 2.
- **`KonjugierenTests/Utils/MixedCaseAccessibilityTests.swift`** feeds `"BIN"` and `"wEIẞ"` to the
  accessibility-label segmenter as **inputs**. Both are pile-3 forms this plan does not touch, and
  the test is about segmentation rather than correctness, so it should not change. If it does, the
  segmenter is case-sensitive in a way nobody intended and that is a separate finding.
- **`Konjugieren/Models/Quiz.swift` lines 312 and 320** discuss `IST` and `wEIẞ` in comments about
  normalizing typed answers. Pile 3, untouched, but re-read them: the comment at 312 counts "22 of
  these 30 answers carry them", and a recasing changes counts of that kind elsewhere if it ever
  reaches pile 3.
- **`docs/screenshot-playbook.md` lines 556 to 569** explain that capitals in quiz answers are
  correct output rather than a defect, citing `IST`, `fÄhrt`, `lÄUft`, `wEIẞ`. All pile 3.
- **`CLAUDE.md:158`** shows `expectConjugation(infinitiv: "wissen", …, expected: "wEIsS")`, but the
  app and the shipped test both produce **`wEIẞ`** with U+1E9E. The doc example is wrong today,
  independently of this plan, and is a one-line fix worth doing whenever someone is next in there.

## Verification

- `scripts/check_docs.py` must stay at 0 problems. It counts ablaut groups against `README.md`, so
  it fires if a group is added or removed; deleting `werden`'s `werdEt` clause does not change the
  group count, only the clause count, which nothing checks.
- Full suite, not a filtered run: **211 tests in 32 suites** is the current green baseline. A
  filtered run that matches nothing reports success, so read the count rather than the exit status.
  `CLAUDE.md` documents three separate ways that happens.
- The XML has a build-phase validator, "Validate Verbs.xml", which runs on every build and will
  catch a malformed clause before the tests do.
