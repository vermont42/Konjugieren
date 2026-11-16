You are writing example sentences for Konjugieren, an app that teaches German verb conjugation.
Your job: for every verb in your shard, author one short, natural German sentence that clearly shows
the verb in use, together with an idiomatic English translation.

## What to do

1. Read your shard file (its path is given at the end of this prompt). It is JSON of the form
   `{"verbs": [{"verb": "...", "gloss": "...", "separability": "..."}, ...]}`.
2. For each verb, write:
   - **A German sentence** — roughly 10–20 words, in natural everyday German, that unambiguously
     demonstrates the verb in the meaning given by its gloss. The sentence must contain a correctly
     conjugated form of that verb. Pick a concrete, ordinary situation; a little situational or
     cultural color is welcome. Avoid literary or archaic phrasing unless the verb itself is archaic.
   - **An idiomatic English translation** — natural English that conveys the same meaning, not a
     word-for-word gloss.
3. Write your result to the output path given at the end of this prompt.

## German details

- **Separable verbs** (`separability: separable`) split in a main clause: the finite verb comes second
  and the particle strands at the end of the clause — e.g. *anfangen* → „Er **fängt** morgen neu **an**."
  That stranded word order is normal and good; use it when it reads naturally.
- **Inseparable verbs** (`separability: inseparable`) keep the prefix attached — *umsorgen* →
  „Sie **umsorgt** ihren kranken Vater."
- Use correct German orthography (ß, ä/ö/ü). If you quote speech inside the sentence, use German
  quotation marks („ … "). Do not use any markup — plain sentences only.

## Style — follow these examples

| Verb | German | English |
|---|---|---|
| buchen | Wir haben die Reise so spät gebucht, dass nur noch ein einziges Zimmer frei war. | We booked the trip so late that only a single room was still available. |
| entsorgen | Wer alte Medikamente im Hausmüll entsorgt, riskiert, dass sie in falsche Hände geraten. | Anyone who disposes of old medications in the household trash risks them falling into the wrong hands. |
| tippen | Er tippte so schnell auf der Tastatur, dass seine Finger über die Tasten zu fliegen schienen. | He typed so fast on the keyboard that his fingers seemed to fly across the keys. |
| weiterlesen | Das Buch war so spannend, dass sie nicht aufhören konnte und bis zum Morgengrauen weiterlas. | The book was so gripping that she couldn't stop and kept reading until dawn. |
| ähneln | Die beiden Schwestern ähneln einander so sehr, dass selbst ihre Eltern sie verwechseln. | The two sisters resemble each other so closely that even their parents mix them up. |
| abbuchen | Die Miete wird jeden Monat automatisch von meinem Konto abgebucht. | The rent is automatically debited from my account every month. |
| seilspringen | Die Boxerin sprang zum Aufwärmen jeden Morgen zehn Minuten Seil. | To warm up, the boxer jumped rope for ten minutes every morning. |
| durchdrehen | Als der Alarm losging, drehte er vor Panik völlig durch. | When the alarm went off, he completely freaked out in panic. |

Concise, everyday, one clear verb per sentence, idiomatic English. Aim for that.

## When the gloss looks wrong

The gloss comes from a dictionary import and is occasionally mistaken (a wrong sense, or the opposite
meaning). If you are confident a verb actually means something different from its gloss, **author the
sentence for the verb's real meaning anyway**, and add a short `gloss_note` explaining the discrepancy
(e.g. "gloss says 'chat'; aufsprechen means to record a spoken message"). Do not skip the verb.

If a verb is genuinely obscure and you cannot be sure you have it right, still write your best sentence
and add a brief `note` flagging that you are uncertain. Do not leave any verb without a sentence.

## Output format

Write a single JSON object to the output path, one key per verb in your shard:

```json
{
  "abbuchen": {
    "de": "Die Miete wird jeden Monat automatisch von meinem Konto abgebucht.",
    "en": "The rent is automatically debited from my account every month."
  },
  "aufsprechen": {
    "de": "Weil niemand ans Telefon ging, sprach er ihr eine kurze Nachricht auf.",
    "en": "Since no one answered the phone, he recorded a short message for her.",
    "gloss_note": "gloss says 'chat, talk'; aufsprechen standardly means to record a spoken message"
  }
}
```

Every verb in the shard must appear as a key. `gloss_note` and `note` are optional per verb.

## Rules

- Read only your shard file, and write only your output file. Do not read, edit, or create any other
  file. In particular, do **not** update `docs/blog_notes.md` or any documentation.
- Do not run tests, build the app, or run any other tooling. Just author and write.
- Do not add commentary or explanation outside the JSON output file.
