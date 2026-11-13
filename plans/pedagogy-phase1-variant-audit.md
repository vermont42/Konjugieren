# Phase 1 Variant Audit: Optional Standard Conjugations (T1.5)

**For:** Josh, to rule on each row before any variant becomes an accepted quiz answer.
**Written:** 2026-11-13, in Phase 1 of [`pedagogy-implementation.md`](pedagogy-implementation.md).

## Method

1. `VerbExportTests` wrote every verb's conjugations (primary reading) to JSON.
2. A script compared each cell with the conjugation table that Wiktionary gives for the same
   verb, from the kaikki.org snapshot in `verbdata/` (the classify-and-verify pipeline's source),
   and listed every Wiktionary form the conjugator does not produce: 13,023 forms across 3,571
   verbs.
3. The forms fell into the patterns below. Each pattern was checked against Duden's conjugation
   tables at `duden.de/konjugation/<verb>`, which list alternatives side by side. Where Duden had
   no page (HTTP 404 for backen, sehen, saugen, lesen, weben, glimmen, triefen, schallen,
   handeln, bergen), the row says so.

Wiktionary alone was not trusted. It lists `ich wandre` and `klettre`, which Duden does not, and
it tags nearly every Konjunktiv II form "formal, rare", which tells us nothing.

## Rows to Rule On

"Verbs" counts verbs in the corpus that a rule would touch, prefixed verbs included.

| # | Variant | Example (conjugator / variant) | Verbs | Duden | Recommendation |
|---|---|---|---:|---|---|
| A1 | du-Imperativ with -e | geh / gehe, komm / komme, entschuldig / entschuldige | ~2,740 | [gehen](https://www.duden.de/konjugation/gehen): "geh, gehe!"; [kommen](https://www.duden.de/konjugation/kommen): "komm, komme!"; [entschuldigen](https://www.duden.de/konjugation/entschuldigen) | Accept. Never for a changed stem (sieh, nimm, gib), whose -e form is fixed phrase only (siehe oben). |
| A2 | du-Imperativ without -e, strong verbs on -d/-t | bitte / bitt, halte / halt, finde / find | ~210 | [bitten](https://www.duden.de/konjugation/bitten): "bitt, bitte!"; [halten](https://www.duden.de/konjugation/halten); [finden](https://www.duden.de/konjugation/finden) | Accept for strong verbs only. Weak verbs stay strict: [arbeiten](https://www.duden.de/konjugation/arbeiten) has only "arbeite!". |
| B1 | -eln verbs drop the e of -el: ich-Präsens, Konjunktiv I ich and er, du-Imperativ | sammele / sammle; sammel / sammle, sammele | 49 | [sammeln](https://www.duden.de/konjugation/sammeln): "sammele, sammle"; Imperativ "sammel, sammele, sammle!" | Accept. Duden's grammar calls sammle the usual form. |
| B2 | -ern verbs drop the e of -er | wandere / wandre | 117 | [wandern](https://www.duden.de/konjugation/wandern) and [ändern](https://www.duden.de/konjugation/aendern) list only wandere, ändere | Reject. Wiktionary only. |
| B3 | Konjunktiv I du and ihr of -eln and -ern verbs | sammelest / sammelst; wanderet / wandert | 166 | [sammeln](https://www.duden.de/konjugation/sammeln): only "sammelst", "sammelt"; [wandern](https://www.duden.de/konjugation/wandern): only "wanderst", "wandert" | Accept. See also Q4: the conjugator's form is not in Duden at all. |
| C1 | Konjunktiv II du and ihr without e (strong verbs) | kämest / kämst, kämet / kämt; wärest / wärst | ~1,040 | [kommen](https://www.duden.de/konjugation/kommen): "kämest, kämst"; [sein](https://www.duden.de/konjugation/sein_Hilfsverb): "wärest, wärst", "wäret, wärt" | Accept, except after s, ß, z, x, d, t ([essen](https://www.duden.de/konjugation/essen): only "äßest"). |
| C2 | Präteritum du of strong verbs, with or without e | batest / batst, hieltest / hieltst; aßt / aßest | ~400 | [bitten](https://www.duden.de/konjugation/bitten): "batest, batst"; [halten](https://www.duden.de/konjugation/halten); [finden](https://www.duden.de/konjugation/finden); [essen](https://www.duden.de/konjugation/essen): "aßest, aßt" | Accept both directions. |
| C3 | Konjunktiv I du of sein | seist / seiest | 1 | [sein](https://www.duden.de/konjugation/sein_Hilfsverb): "seiest, seist" | Accept. |
| D1 | Konjunktiv II vowel doublets | stände / stünde; hälfe / hülfe; begänne / begönne; schwämme / schwömme; empfähle / empföhle; stähle / stöhle; gölte / gälte | ~80 with derivatives | [stehen](https://www.duden.de/konjugation/stehen), [helfen](https://www.duden.de/konjugation/helfen), [beginnen](https://www.duden.de/konjugation/beginnen), [schwimmen](https://www.duden.de/konjugation/schwimmen), [empfehlen](https://www.duden.de/konjugation/empfehlen), [stehlen](https://www.duden.de/konjugation/stehlen), [gelten](https://www.duden.de/konjugation/gelten): both, unlabeled | Accept. This also settles the roadmap's open "helfen: hälfe or hülfe" question: both. |
| D2 | heben's hub and hübe | hob / hub; höbe / hübe | 6 | [heben](https://www.duden.de/konjugation/heben) lists both, unlabeled; Wiktionary marks hub archaic | Reject: archaic in every other source. |
| E1 | senden family: sandte, gesandt | sendete / sandte; gesendet / gesandt | 10 | [senden](https://www.duden.de/konjugation/senden): "sandte / (seltener) sendete, gesandt / (seltener) gesendet"; Konjunktiv II only "sendete" | Accept (Präteritum, participle, and every compound with it). |
| E2 | wenden family: wandte, gewandt | wendete / wandte; verwendet / verwandt | 11 | [wenden](https://www.duden.de/konjugation/wenden): a-forms "more common" except for changing direction; [verwenden](https://www.duden.de/konjugation/verwenden): both | Accept. |
| E3 | Other strong/weak doublets Duden lists | molk / melkte, gemolken / gemelkt; gewinkt / gewunken; gor / gärte; gesalzen / gesalzt; sott / siedete, gesotten / gesiedet; haute / hieb | ~20 with derivatives | [melken](https://www.duden.de/konjugation/melken), [winken](https://www.duden.de/konjugation/winken) ("auch: gewunken"), [gären](https://www.duden.de/konjugation/gaeren), [salzen](https://www.duden.de/konjugation/salzen), [sieden](https://www.duden.de/konjugation/sieden), [hauen](https://www.duden.de/konjugation/hauen) | Accept. Not gehaut (Duden: "österreichisch, sonst landschaftlich"). |
| E4 | Doublets Wiktionary marks archaic, colloquial, or regional | frug, stak, buk, erhing, schnob, gescheint, geschalten | ~15 | not standard, or no Duden page | Reject. |
| F1 | anerkennen split | anerkennt / erkennt an | 1 | [anerkennen](https://www.duden.de/konjugation/anerkennen): "erkennt an / (besonders schweizerisch) anerkennt" | Accept. The conjugator shows only the rarer, Swiss-leaning form. |

Not variants, and left alone: Wiktionary's noise (`ich anleste`, `werden: worden` as the passive
auxiliary's participle, `können` as a replacement infinitive), and cells a verb's *other* reading
already produces (bewegen's bewog, hängen's hing).

## Defects Found Along the Way

These are wrong canonical conjugations, not optional variants. They need Josh's word before a
change to the verb page.

| Verb | Shipped | Correct | Cause |
|---|---|---|---|
| scheiden (both readings) | schie, geschien, schiest | schied, geschieden, schiedst | `Verbs.xml` marks the ablaut region `sch^eid^en`; the `bleiben` group needs `sch^ei^den`. The classifier skips multi-reading verbs, so it never flagged this. |
| vergleichen | vergliech, vergliechen | verglich, verglichen | Ablaut group `bleiben`; it needs `gleichen`'s (`streichen`). Listed in `docs/roadmap.md` as the last wrong group. |
| every -eln and -ern verb | du sammelest, ihr sammelet; du wanderest | du sammelst, ihr sammelt; du wanderst | Konjunktiv I appends -est and -et to a stem that already ends in a syllabic el or er. Duden lists only the short forms. |
| anerkennen | anerkennt (only) | erkennt an (usual), anerkennt | Encoded as inseparable. |
| senden, wenden, verwenden, and derivatives | weak only | sandte and gesandt are the usual forms | Encoded weak, with no mixed reading. |

## Rulings

**Josh, 2026-11-13.** Every row the audit recommended accepting is accepted: A1, A2, B1, B3, C1,
C2, C3, D1, E1, E2, E3, and F1. B2, D2, and E4 are rejected. All are built in
`Konjugieren/Models/StandardVariants.swift` and pinned row by row in `StandardVariantsTests`.

- **Quiz acceptance only.** The verb page keeps the conjugator's conjugation in every row, the
  plan's default. The defects table's last three rows (the Konjunktiv I of -eln and -ern verbs,
  anerkennen, and senden and wenden) are therefore left on the verb page, as candidates for a later
  session that changes the conjugator and re-runs the classify-and-verify regression.
- **scheiden and vergleichen fixed now**, in `Verbs.xml`, pinned by
  `ConjugatorTests.scheidenAndVergleichen()`.

Two narrowings made while building, both on the side of rejecting:

- **E3's hauen covers hauen alone.** Its derivatives keep haute only, since abhauen ("scram") has
  no hieb ab.
- **C1 skips a vowel before the ending**, as well as a sibilant, d, or t, since schriest's e is
  the stem's own (schrie + st).
