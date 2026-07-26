You are auditing the English glosses of German verbs for Konjugieren, an app that teaches German verb
conjugation. Each verb ships with one short English gloss, shown to the learner as that verb's
meaning. Your job is to find the ones that are **wrong**.

Review as an adversarial native-speaker lexicographer, not as a scorer. Do not rate glosses. A gloss
with nothing wrong gets no finding, which is the expected outcome for most of them — the observed
defect rate on a comparable set was about one verb in twenty.

## Where these glosses came from, and how they go wrong

They were imported from kaikki (machine-readable Wiktionary) and then shortened by hand to the app's
house style. Both steps introduce defects, and they look different:

- **The importer took the wrong sense.** kaikki lists senses in entry order, not frequency order, and
  the import often took the first. So a verb ships glossed with a rare, archaic, or technical sense
  while the meaning a learner actually meets sits further down the list. This is the most common real
  defect. `fernschauen` shipped as "look into the distance" when in Austrian and southern German it is
  simply *watch television*.
- **The shortening mangled it.** A dictionary definition cut to a phrase can lose the part that
  carried the meaning, or keep only scaffolding. Real examples: `abschmecken` shipped as "taste a dish
  and, if necessary" — truncated mid-clause at a comma; `entmieten` as "of a landlord" — only the
  parenthetical usage label survived; `durchspielen` as "play out to its conclusion)" — an unbalanced
  parenthesis from a nested definition; `hinwegschauen` as "synonym of hinwegsehen" — a cross-reference
  rather than a meaning; `kaltmachen` as "off someone, duppy" — an unfiltered synonym list in which
  "duppy" is Jamaican English and opaque to any learner.
- **The gloss is simply wrong about German.** `niederführen` shipped as "run someone over", which
  belongs to the near-homograph *niederfahren*; it means *lead down*. No import rule catches this.

## What to do

1. Read your shard file (path given at the end of this prompt). It is JSON of the form
   `{"verbs": [{"verb": "...", "gloss": "...", "separability": "...", "candidate_glosses": [...],
   "sense_index": 0, "sense_match": "exact"}, ...]}`.
   - `gloss` is what the app ships and shows the learner.
   - `candidate_glosses` is every sense kaikki listed for this verb, in kaikki's order. It may hold
     one entry, or none.
   - `sense_index` is which of those the shipped gloss came from, or `null` for none, and
     `sense_match` is how faithfully: `exact`, `shortened`, or `none`.
2. For each verb, decide whether the shipped gloss correctly and usefully names what the verb means.
3. Write your findings to the output path given at the end of this prompt.

**Work down from the most frequent verbs in the shard, not from the oddest-looking English.** A
measured verification of an earlier wave found this to be the pass's one real recall gap: it caught
every gloss whose English *looked* broken, and missed glosses that read as perfectly good English
while naming the wrong sense of a common verb. `abheben` shipped "lift off" — plausible English,
but the senses a learner meets are withdrawing money (*Geld abheben*) and answering the phone.
`anspringen` shipped "jump at, pounce", missing that it is what an engine does. Both were missed on a
shard where far rarer verbs were caught. **A gloss that reads well is not thereby correct**, and the
common verbs are where a wrong gloss does the most damage.

**`sense_index: 0` is a hint, not a verdict.** It means the importer shipped kaikki's first-listed
sense, which is where wrong-sense defects concentrate — but measured on a comparable set, only about
one in nine such verbs was actually defective. Most first-listed senses are first because they are the
common ones. Do not treat the flag as evidence.

**`sense_match: "none"` is not suspicious either.** It usually means the gloss was rewritten by hand
rather than lifted, which is normal and often better than what kaikki offered. Judge the gloss against
the German, not against its provenance.

## What counts as a finding

There is only one finding type, `bad_gloss`. Severity carries the weight:

- **`high`** — the gloss would teach a learner the wrong word. It names a different verb, a different
  action, or is unusable as English (truncated, a bare usage label, a cross-reference, an opaque
  regionalism). `niederführen` "run someone over" and `entmieten` "of a landlord" are both high.

  **Leaked dictionary apparatus is always `high`, whether or not the punctuation survived intact.**
  Sense-group umbrellas that describe the entry rather than the verb (`anvertrauen` "entrust in
  various ways"), cross-references (`hinwegschauen` "synonym of hinwegsehen"), and editorial pointers
  (`anhaben` "wear, have on, see usage notes") are all high, because none of them is English about the
  verb. A gloss reading as clean prose does not exempt it: "entrust in various ways" is grammatical
  and still tells the learner nothing.
- **`medium`** — the gloss names a real sense of this verb, but **not one the learner will meet**. The
  rare-sense-shipped-over-common-sense case. `fernschauen` "look into the distance" is medium.

  **A vaguer synonym of the right sense is not medium — it is low.** If the shipped gloss points at
  the correct action and merely does so loosely, that is imprecision, not a wrong sense. Reserve
  medium for a genuinely different sense of the verb.
- **`low`** — the gloss is broadly right but imprecise in a way that could mislead. `zuschwellen`
  "swell up" blurs the *zu-* shut component and collides with *anschwellen*; the right gloss is
  "swell shut".

## What is NOT a finding

Do not report these. Each has been considered and settled.

- **A gloss that is terser than the dictionary definition.** This is the house style, not a defect.
  `work off` for kaikki's "to work off (a debt, the items on a to-do list, etc); to resolve or take
  care of something by working" is a good gloss, and the long version would be a bad one.
- **A gloss that names one sense when the verb has several.** The app ships one gloss per reading by
  design. Flag it only if the shipped sense is the *wrong one to have chosen*, and say which sense you
  would ship instead.
- **British vs American spelling.** The corpus is mixed (`synchronise` beside `organize`) because
  kaikki is. Not worth a finding.
- **A missing nuance you would have included.** The bar is *wrong* or *misleading*, not *incomplete*.
  Over-flagging is the likelier failure here and it costs more than a missed finding, because every
  finding gets human attention and a gloss that is merely thin harms nobody.
- **Anything about the German verb itself** — its conjugation, its separability, whether it should be
  in the app. You are auditing the English gloss only.

## Output format

Write a single JSON object to the output path. **Only verbs with findings appear.** A shard where
everything is fine writes `{}`.

```json
{
  "fernschauen": {
    "findings": [
      {
        "type": "bad_gloss",
        "severity": "medium",
        "detail": "In Austrian and southern German this is simply the word for watching television, which candidate_glosses lists as sense 2. The shipped 'look into the distance' is a literal reading of fern + schauen that the verb does not carry in use.",
        "fix_gloss": "watch television"
      }
    ]
  }
}
```

- `type` is always `bad_gloss`.
- `severity` is `high`, `medium`, or `low`, per the definitions above.
- `detail` names the specific problem and says what the verb actually means. "Wrong" alone is not a
  finding. If the sense you believe correct is already in `candidate_glosses`, **say which index**,
  because that makes it a mechanical import defect rather than a judgment call, and those are applied
  with more confidence.
- `fix_gloss` is required. A finding without a replacement cannot be applied and wastes the review.

**Commas separate synonyms for a single sense — never two different senses.** The house style reads a
comma as "these mean the same thing", so `anhalten` "stop, continue" presents two opposite actions as
equivalents. Your `fix_gloss` must **commit to one sense**. Do not hedge by pairing the sense you are
proposing with the one you just condemned: if you argue that `auflegen` means hanging up the phone,
ship `hang up`, not `hang up, lay on`. Pairing them re-creates the exact defect on a new verb.

**Write `fix_gloss` in transatlantically neutral English.** British *spelling* in an existing gloss is
not a finding, but your replacement is new text and should not be regionally marked either way:
prefer `run away` to `clear off`, `take compensatory time off` to `take time off in lieu`.

**Write `fix_gloss` in the app's house style, which is not the dictionary's.** A bare lowercase verb
phrase, no leading `to `, synonyms separated by commas, as short as the sense allows — `watch
television`, `offset, set off`, `sweep up, sweep together`, `lead down`. Roughly fourteen characters is
typical and parentheticals are rare, so `help put on (a garment)` is acceptable but `to swing by, to
visit briefly (especially if not at a specific time)` is not. Do **not** paste a `candidate_glosses`
entry verbatim: those carry `to `, nested parentheses, and usage labels that all have to be stripped.

## Rules

- Read only your shard file, and write only your output file. Do not read, edit, or create any other
  file. In particular, do **not** update `docs/blog_notes.md` or any documentation.
- Do not run tests, build the app, or run any other tooling. Just review and write.
- Do not add commentary or explanation outside the JSON output file.
