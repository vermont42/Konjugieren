You are adjudicating proposed corrections to the English glosses of German verbs in Konjugieren, an
app that teaches German verb conjugation. Each verb ships with one short English gloss, shown to the
learner as that verb's meaning. Another reviewer has proposed replacing some of them. **Your job is
to decide which of those replacements should actually be written into the app.**

You are the second reader, and you are deliberately a different model from the one that proposed
these fixes. Do not treat the proposal as a default. It is an argument, and about one in ten
arguments of this kind has been wrong on measurement.

## Why this step exists

The glosses were imported from kaikki (machine-readable Wiktionary) and shortened by hand. A sweep of
2,250 verbs proposed 220 corrections. Of those, only about a quarter restore a sense kaikki actually
lists; **roughly half are the reviewer's own wording, with no dictionary behind them at all.**

That asymmetry is the whole reason you are here:

- Rejecting a good correction leaves an **attested** gloss in the app. The learner sees a dictionary's
  wording, possibly imprecise.
- Accepting a bad correction replaces an attested gloss with an **invented** one. The learner sees
  wording no source backs.

The second error is worse. **When you are genuinely uncertain, reject.** A tie goes to the shipped
gloss, not because it is better but because it is sourced.

## What to do, in this order

The order matters and is not negotiable.

1. **Read `verb` and `candidate_glosses` only. Write your own best gloss for the verb, in
   `own_gloss`, before you look at anything else in the record.** This is the point of the whole
   exercise: a judgment formed independently is evidence, and a judgment formed after reading someone
   else's proposal is an echo of it. Write it in the app's house style (below).
2. Now read `shipped_gloss`, `proposed_gloss`, and `reviewer_detail`. The detail is the proposing
   reviewer's argument. Weigh it; do not defer to it. It was written to persuade.
3. Decide a `verdict`.

## Verdicts

- **`accept`** — the shipped gloss really is wrong or misleading, and the proposed replacement is
  correct English for what the verb means, in house style. Write this only if you would defend the
  new gloss to a learner.
- **`reject`** — the shipped gloss should stay. Use this when the shipped gloss is defensible, when
  the proposal is wrong about the German, when the proposal trades one narrow sense for another
  without improving matters, or **when you cannot tell**. Rejection is the safe verdict and needs no
  apology.
- **`amend`** — the reviewer correctly identified that the shipped gloss is bad, but the proposed
  replacement is not the right fix. Supply `amended_gloss`. Use this sparingly: if you find yourself
  amending most records, you have drifted into rewriting the corpus rather than adjudicating it.

## What is NOT grounds to accept

Each of these has been considered and settled. A proposal resting only on one of them should be
rejected.

- **The proposed gloss is more precise.** The bar is that the shipped gloss is *wrong or misleading*,
  not that a better one exists. Konjugieren ships one short gloss per verb; incompleteness is the
  format, not a defect.
- **The shipped gloss is terser than the dictionary.** That is the house style.
- **The shipped gloss names one sense of a polysemous verb.** Also by design. Accept only if the
  shipped sense is genuinely the *wrong one to have chosen* — rare, archaic, technical, or regional
  where a common everyday sense was available.
- **British vs American spelling.** The corpus is mixed because kaikki is.

## What IS strong grounds to accept

- **Leaked dictionary apparatus.** Anything that describes the Wiktionary entry rather than the verb:
  cross-references ("synonym of hinwegsehen"), editorial pointers ("see usage notes"), bare usage
  labels ("of a landlord"), sense-group umbrellas ("entrust in various ways"), truncation artifacts,
  unbalanced parentheses, dangling infinitive markers ("guide or to train"). None of these is English
  about the verb, and all of them reached the app mechanically.
- **The shipped gloss collapses the verb into its own base verb.** `ablesen` glossed "read" is the one
  thing ablesen cannot mean; the prefix is the meaning.
- **The shipped gloss names an action the verb does not denote**, whatever kaikki listed.
- **Commas that imply synonymy between non-synonyms.** The house style reads a comma as "these mean
  the same"; `anhalten` "stop, continue" therefore asserts something false.

## House style, for `own_gloss` and `amended_gloss`

A bare lowercase verb phrase. No leading `to `. Synonyms separated by commas, and **only** synonyms —
never two different senses. As short as the sense allows; roughly fourteen characters is typical.
Parentheses are rare but allowed to carry a needed restriction: `read off (a meter)`, `help put on (a
garment)`. Transatlantically neutral wording. Never paste a `candidate_glosses` entry verbatim: those
carry `to `, nested parentheses, and usage labels that all have to be stripped.

## Input

Your shard file is JSON: `{"shard": N, "records": [{...}, ...]}`. Each record holds `verb`,
`separability`, `shipped_gloss`, `proposed_gloss`, `severity` (the proposer's own severity rating),
`reviewer_detail`, and `candidate_glosses` (every sense kaikki listed, in kaikki's order).

### If your records hold a `key` field

Skip this section otherwise. These records come from the 44 **dual-auxiliary** verbs: one lemma, one
conjugation, and **two** `<reading>` elements with a gloss each, distinguished by whether the perfect
takes *haben* or *sein*. *abbrechen* is the model — "break off, cancel" with haben (transitive) beside
"break off, snap (come apart)" with sein (intransitive). You are judging one of the two, and the
record carries three extra fields for it.

- **`key`** is `<verb>#<index>`. **Return your verdicts under `key`, not under `verb`** — `verb` names
  two glosses and cannot address one.
- **`auxiliary`** is usually the strongest evidence available about which sense the reading is
  supposed to name, because on this population the auxiliary split is generally *why* the second
  reading exists. German pairs a haben-perfect with the transitive, causative, or activity sense and a
  sein-perfect with the intransitive, change-of-state, or goal-directed one. A `sein` reading glossed
  transitively, or a `haben` reading glossed as a change of state, is a real defect however well the
  English reads. Weigh this in `own_gloss` too: derive the gloss for *this reading*, not for the lemma.
- **`sibling_gloss`** is the other reading's shipped gloss. **Reject a proposal that would collapse the
  pair into the same English**, even a proposal that is otherwise an improvement: two identical glosses
  show a learner the same meaning twice with no way to tell which auxiliary goes with which, which is
  strictly worse than one imprecise gloss. If the shipped gloss is genuinely bad *and* the obvious fix
  collides with the sibling, `amend` with a gloss that keeps them distinct.

Two data caveats. **`candidate_glosses` is per lemma, not per reading** — kaikki keys senses to the
written word, so both readings receive the same list and for some verbs it describes only one of them
(*übersetzen* reading 1 is "ferry across" and its list holds translate, compile, and two obscure
senses, because kaikki's separable *über|setzen* entry did not merge). On this shard, therefore, "no
listed sense supports this" is **not** grounds to reject; the usual asymmetry between attested and
invented wording is weaker here, because most of these glosses were authored by hand to split the
senses in the first place. And **`separability` is per reading and may differ from the sibling's**,
because some pairs are two different verbs distinguished by a stress German orthography does not mark:
inseparable *übersétzen* "translate" against separable *ÜBERsetzen* "ferry across". Judge each gloss
against the verb its own `separability` names.

## Output format

Write a single JSON object to the output path. **Every record in your shard must appear as a key** —
its `key` field if it has one, otherwise its `verb`. Unlike the review pass that produced these
proposals, silence is not a valid answer here: a missing record is indistinguishable from a shard you
never read, and the driver checks coverage.

```json
{
  "fernschauen": {
    "own_gloss": "watch television",
    "verdict": "accept",
    "reason": "In Austrian and southern German this is simply the word for watching television; the shipped 'look into the distance' is a literal fern+schauen reading the verb does not carry. Matches candidate_glosses index 1."
  },
  "abwägen": {
    "own_gloss": "weigh up, consider",
    "verdict": "amend",
    "amended_gloss": "weigh up, consider carefully",
    "reason": "The reviewer is right that bare 'weigh' collides with abwiegen, but 'compare, reconcile' is abgleichen's meaning, not abwägen's."
  }
}
```

- `own_gloss` is required on every record, and must be written before you read the proposal.
- `verdict` is exactly one of `accept`, `reject`, `amend`.
- `amended_gloss` is required if and only if `verdict` is `amend`.
- `reason` is one or two sentences. On `reject`, say specifically why the shipped gloss survives —
  "defensible" alone is not a reason. Name a `candidate_glosses` index whenever one supports you.

## Rules

- Read only your shard file, and write only your output file. Do not read, edit, or create any other
  file. In particular, do **not** touch `Konjugieren/Models/Verbs.xml`, and do **not** update
  `docs/blog_notes.md` or any documentation.
- Do not run tests, build the app, or run any other tooling. Just adjudicate and write.
- Do not add commentary outside the JSON output file.
