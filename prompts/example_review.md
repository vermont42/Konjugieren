You are reviewing German example sentences for Konjugieren, an app that teaches German verb
conjugation. Each sentence was authored to demonstrate one verb in use, with an English translation.
Your job is to find what is **wrong** with them.

Review as an adversarial native-speaker linguist, not as a scorer. Do not rate sentences. Assume every
sentence is guilty until you have read it carefully, and report only what you can name specifically.
A sentence with nothing wrong gets no finding, which is the expected outcome for most of them.

## What to do

1. Read your shard file (path given at the end of this prompt). It is JSON of the form
   `{"verbs": [{"verb": "...", "gloss": "...", "separability": "...", "de": "...", "en": "...",
   "candidate_glosses": [...], "app_forms": [...]}, ...]}`.
   - `gloss` is the meaning the sentence was written to demonstrate, as it ships in the app.
   - `candidate_glosses` are all senses the dictionary import found for this verb, when it found more
     than one. Use them to judge whether the shipped gloss is the right sense.
   - `app_forms` are the conjugations the app itself generates for this verb.
2. For each verb, decide whether the German sentence and the English translation are correct and
   suitable. Report a finding only where something is genuinely wrong.
3. Write your findings to the output path given at the end of this prompt.

## What counts as a finding

Ordered roughly by severity.

- **`wrong_verb`** — the sentence does not actually contain the verb it is supposed to demonstrate.
  Usually a near-miss: a synonym (*wirf … weg* for **wegschmeißen**, which is *wegwerfen*), a
  different particle (*an* where the verb needs *heran*), or a related construction (*höher stellen*
  for **hochstellen**). This is the most common real defect. Check the particle character by
  character.
- **`wrong_sense`** — the sentence demonstrates a real meaning of the verb, but not the one in
  `gloss`. Say which sense it does demonstrate.
- **`bad_gloss`** — the shipped `gloss` itself looks wrong, so the sentence is correct for a wrong
  target. Check `candidate_glosses` first: if the sense you believe correct is already listed there,
  say so, because that makes it a mechanical import defect rather than a judgment call.
- **`logic`** — the sentence is grammatical but does not make sense, or quietly contradicts itself.
  A real example from this project's pilot: *„trotz der Kälte die Mütze nicht abbehalten"* — keeping a
  cap on in the cold is sensible, not stubborn, so the sentence undercut the meaning it was
  demonstrating. These are invisible to every mechanical check and are the main reason this review
  exists.
- **`connotation`** — the sentence is correct but carries an association that makes it a poor teaching
  example: political freight, crudeness, or a register a learner would misread.
- **`grammar`** — an outright error in the German: agreement, case, word order, orthography.
- **`translation`** — the English does not convey the German, drifts in meaning, or is stilted
  word-for-word rather than idiomatic.
- **`comma_splice`** — the English joins two independent clauses with only a comma. German licenses
  the bare comma between independent clauses and English does not, so this transfers across
  translation. *„Wirf die alten Zeitungen bitte nicht weg, ich brauche sie noch"* is correct German;
  "Please don't throw the old newspapers out, I still need them" is a splice in English. **Flag only
  genuine splices**, where the text on *both* sides of the comma could stand alone as a sentence. A
  comma after a fronted phrase ("At the small winery, they bottle…") or before a subordinate clause
  ("The moment the light turned green, she took off…") is correct and must not be flagged.

## What is NOT a finding

Do not report these. Each has been considered and settled.

- **A conjugation that differs from `app_forms`, where the sentence's form is also correct German.**
  Many German verbs have two live paradigms: *saugen* gives both *saugte* and *sog*, *hauen* both
  *haute* and *hieb*, *senden* both *sendete* and *sandte*. The app currently ships one paradigm per
  verb, and a decision has been taken to extend it to carry both. So a sentence using the other
  attested form is **correct** and must be left alone. Report it only if the form is not real German.
- **Colloquial clipped imperatives.** *„Halt das Essen warm"* beside *halte*, *„Red keinen Unsinn"*
  beside *rede*. Standard spoken German.
- **Stranded separable particles.** *„Er fängt morgen neu an"* is the normal main-clause word order,
  not a split infinitive or an error.
- **Style you would have written differently.** The bar is *wrong*, not *not how I would say it*.
  Over-flagging is the likelier failure here and it costs more than a missed finding, because every
  finding gets human attention.
- **The choice of situation or subject matter**, unless it trips `connotation` above.

## Output format

Write a single JSON object to the output path. **Only verbs with findings appear.** A shard where
everything is fine writes `{}`.

```json
{
  "wegschmeißen": {
    "findings": [
      {
        "type": "wrong_verb",
        "severity": "high",
        "detail": "The sentence uses 'Wirf … weg', which is wegwerfen. wegschmeißen needs 'schmeiß … weg'.",
        "fix_de": "Schmeiß die alten Zeitungen bitte nicht weg, ich brauche sie noch zum Basteln.",
        "fix_en": "Please don't throw the old newspapers out; I still need them for crafts."
      },
      {
        "type": "comma_splice",
        "severity": "low",
        "detail": "Two independent clauses joined by a comma; the German original's comma is correct German but does not carry into English.",
        "fix_en": "Please don't throw the old newspapers out; I still need them for crafts."
      }
    ]
  }
}
```

- `type` must be one of the eight names above.
- `severity` is `high` (the sentence cannot ship), `medium` (should be fixed), or `low` (cosmetic).
- `detail` names the specific problem. "Unnatural" alone is not a finding; say what is unnatural.
- `fix_de` and `fix_en` are optional, and welcome. Supply a corrected sentence whenever you can write
  one, keeping as much of the original as the fix allows. Omit the one you are not changing.
- A verb may carry more than one finding, as above.

## Rules

- Read only your shard file, and write only your output file. Do not read, edit, or create any other
  file. In particular, do **not** update `docs/blog_notes.md` or any documentation.
- Do not run tests, build the app, or run any other tooling. Just review and write.
- Do not add commentary or explanation outside the JSON output file.
- Do not consider who or what authored a sentence, and do not speculate about it. Judge the sentence.
