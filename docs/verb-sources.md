# Sources for Additional Verbs

Research findings on expanding Konjugieren's verb corpus beyond the current 990.

Source counts, sizes, and frequencies were measured live on 2026-07-18 against the cited APIs; reproduction recipes appear at the end. Classification and coverage figures — anything about how many candidate verbs are verified, or how many shipping verbs disagree with Wiktionary — come from the pipeline in [`verb-classification.md`](verb-classification.md) and were last refreshed 2026-07-19. Both are pinned to a kaikki snapshot that refreshes upstream, so re-derive rather than trust; see "Verify counts, do not trust them" at the end.

## Context

Konjugieren ships 990 verbs (582 weak, 295 strong, 30 mixed, 83 -ieren), the survivors of data cleansing on a frequency-of-use list. The sibling apps Conjuguer (~6,200 verbs) and Conjugar (~4,800) were fed by the "Made Simple(r)" books; no comparable German book is in hand, so the path to parity runs through open data.

A new verb needs everything `Verbs.xml` encodes: infinitive with prefix and ablaut markers (`in`), a short English translation (`tn`), family (`fa`), raw DWDS hit count (`hi`), a frequency-icon suffix (`ic`), an ablaut group (`ag`) for strong and mixed verbs, and auxiliary (`ay`). The file's DOCTYPE is the authoritative list; see the handoff section at the end. Each verb ideally also gains entries in `Etymologies.json` and `ExampleSentences.json`. The sources below are therefore rated not just on verb count but on whether glosses, etymologies, and full conjugation tables travel with the verbs in the same pass, so that nothing must be recrawled later.

## Headline numbers

| Source | German verbs | Glosses | Etymologies | Conjugations | License |
|---|---|---|---|---|---|
| English Wiktionary | 10,407 lemmas | English, labeled | Rich; PIE roots and English cognates | `{{de-conj}}` template (compact code) | CC BY-SA 4.0 |
| German Wiktionary | 14,530 entries | German; English under Übersetzungen | Herkunft prose | Principal parts inline; full tables on Flexion pages | CC BY-SA 4.0 |
| kaikki.org (wiktextract) | Both editions, pre-extracted JSON | Yes | Yes, as expanded text | Yes, as expanded tables | CC BY-SA 4.0 |
| Wikidata lexemes | 20,421 verb lexemes | Sparse | No | Partial (forms statements) | CC0 |
| verbformen.de (Netzverb) | Largest dedicated inventory; count not verified this session | German | No | Yes | CC BY-SA 4.0 (stated on site) |
| de.wikipedia, Liste starker Verben | 186 strong bases; 569 including listed derivatives | Commentary only | No | Four principal parts | CC BY-SA 4.0 |

## Coverage check: why the diffs can be trusted

Both Wiktionaries were diffed against the current 990. German Wiktionary contains all 990. English Wiktionary contains 989, everything except weiterlesen. Both sources strictly contain the existing corpus, so a set difference against either is a genuine candidate list, not an artifact of divergent coverage.

## English Wiktionary

- `Category:German verbs` holds 10,407 lemma entries. A further 64,267 pages sit in `Category:German verb forms`; these single-conjugation entries are useless as a lemma source but usable for validating generated conjugations.
- 1,048 titles are multiword idioms and phrases ("abwarten und Tee trinken", "Alarm schlagen"). After filtering to single-word, infinitive-shaped titles, 9,335 remain, of which **8,346 are not in Konjugieren**.
- Glosses are English and carry grammatical labels (transitive, intransitive, figurative), which map directly onto `tn` and onto sense filtering.
- Etymologies are templated inheritance chains through Middle High German, Old High German, Proto-West-Germanic, and Proto-Germanic, frequently ending in a PIE root and explicit English cognates. Example, dreschen: from MHG *dreschen*, OHG *dreskan*, Proto-Germanic *\*þreskaną*; "Compare... English thresh".
- Conjugations are encoded in the `{{de-conj}}` template argument rather than written out. `bersten<birst-#barst,geborsten,bärste.sein>` encodes the Präsens stem change, Präteritum, Perfektpartizip, Konjunktiv II, and the sein auxiliary in one string. Consequence: raw wikitext requires template expansion (or a parser for the compact code, whose grammar is small); kaikki has already done the expansion.
- Access: the `categorymembers` API pages through the whole category at 500 titles per request; the full lemma list took 21 requests, about a minute. Full dumps and kaikki (below) avoid even that.

## German Wiktionary

- `Kategorie:Verb (Deutsch)`: 14,530 entries; 14,447 single-word; **13,457 not in Konjugieren**. The surplus over English Wiktionary is mostly rarer derived verbs.
- Each entry carries a `{{Deutsch Verb Übersicht}}` box with principal parts and Hilfsverb, by itself sufficient for family and ablaut-group classification. The `Flexion:` namespace holds every conjugation and is already the app's manual reference per `adding-verbs.md`.
- Glosses are German; English equivalents arrive via the Übersetzungen section. Herkunft is German prose, a good cross-check on the English etymologies.
- The sieden box surfaced a modeling wrinkle directly in the data: parallel strong and weak paradigms (sott/gesotten beside siedete/gesiedet), both listed as valid.

## kaikki.org: the recommended extraction path

Tatu Ylonen's wiktextract project publishes machine-readable extractions of both Wiktionary editions, regularly refreshed. Template expansion, gloss extraction, and etymology text are already done, so a single download satisfies the requirement that glosses and etymologies travel with the verbs, with no recrawling.

| File | Size |
|---|---|
| `kaikki.org/dictionary/German/kaikki.org-dictionary-German.jsonl` | 1,015.9 MB |
| `kaikki.org/dictionary/German/pos-verb/kaikki.org-dictionary-German-by-pos-verb.jsonl` | 293.9 MB |
| `kaikki.org/dewiktionary/Deutsch/kaikki.org-dictionary-Deutsch.jsonl` (German edition) | 3.1 GB |
| German-edition verb subset, linked from `kaikki.org/dewiktionary/Deutsch/pos-verb/` | 1.1 GB |

Each JSONL line is one word: `word`, `pos`, `senses[].glosses`, `etymology_text` (plain prose, templates resolved), and `forms[]` tagged by person, number, mood, and auxiliary. The 293.9 MB verb-only file is the right starting artifact.

## The candidate pool

- **In both Wiktionaries but not in Konjugieren: 6,980 verbs.** Agreement between two independently edited dictionaries screens out typos, protologisms, and single-editor whims.
- **2,406** of the 6,980 are prefixed or compound derivatives of a verb Konjugieren already conjugates (anklagen from klagen, anheben from heben). Their families and ablaut groups already exist; they ride the current Conjugator nearly for free.
- **4,574** are new stems, most of them weak.

## The strong-verb gap

The app's identity is ablaut, and the strong inventory, unlike the weak one, is finite and completable. de.wikipedia's "Liste starker Verben (deutsche Sprache)" organizes New High German strong verbs by historical Ablautklasse in `{{Verb Zelle}}` template rows. Extracting the bolded verbs yields 186 base strong verbs. Konjugieren has 99 of them and is **missing 87**; counting the bolded prefixed derivatives on the same rows, 569 verbs, 424 missing.

**Corrected 2026-07-19, when step 5 below actually ran: the missing count is 82, not 87.** Re-deriving it by set difference against `Verbs.xml` — the recipe in "Verify counts, do not trust them" at the end of this file — gives 180 distinct bases from 187 template rows and 82 absent from the app. The seven rows that yield no plain bolded base are the bracketed ones the list marks as non-standard (*schneen*, *kiesen*, *quillen*, *schallen*, *schröcken*, *stecken*) plus *sein*, which ships. The table below was not re-derived per Ablautklasse and its per-class figures should be treated the same way: as a sketch, not a count.

| Ablautklasse | Pattern | Bases | Missing | Notable absentees |
|---|---|---|---|---|
| 1 | ei – i(e) – i(e) | 44 | 26 | beißen, gleiten, kneifen, leihen, meiden, pfeifen, preisen, reiben |
| 2 | äu/eu – o – o | 27 | 14 | frieren, lügen, saufen, saugen, sieden, trügen, verdrießen |
| 3 | i – a/o/u – o/u | 50 | 29 | bersten, dreschen, fechten, flechten, glimmen, melken, ringen, rinnen |
| 4 | i(e)/ö – a/o – o | 18 | 8 | befehlen, gären, scheren, verhehlen, weben, wägen |
| 5 | i(e) – a – e | 13 | 1 | genesen |
| 6 | ä/e/ö – u/a/o – a/o | 13 | 2 | graben, schwören |
| 7 | former reduplicating verbs | 21 | 7 | blasen, braten, mahlen, salzen, spalten |

Caveat: the list is deliberately exhaustive and reaches into the attic (kiesen, brinnen, eischen, kröschen are archaic or regional). An editorial pass should decide how deep to go; the pedagogical core is perhaps 60 of the 87.

## Everyday verbs that turn out to be missing

The original frequency list's 990-verb cutoff left surprising holes. DWDS corpus frequencies (lemma hits in the 53.2-billion-token aggregate corpus) for verbs absent from Konjugieren:

| Verb | Meaning | DWDS hits |
|---|---|---|
| beißen | bite | 438,145 |
| meiden | avoid | 393,619 |
| leihen | lend, borrow | 359,969 |
| schmelzen | melt | 342,276 |
| blasen | blow | 338,893 |
| lügen | lie (tell untruths) | 311,367 |
| graben | dig | 279,890 |
| braten | roast, fry | 234,099 |
| frieren | freeze | 189,683 |
| befehlen | command | 180,870 |
| kriechen | creep, crawl | 159,430 |

A telling inversion: the frequency list favored derived verbs over their bases. vermeiden made the cut while meiden did not; verleihen is supported, leihen is not. And braten is the verb behind Bratwurst, the app's own icon and game mechanic, yet it cannot currently be conjugated.

## Thirteen finds

A sampler of missing verbs whose stories suit this app, with DWDS hits for scale:

| Verb | Gloss | DWDS hits | Why it delights |
|---|---|---|---|
| gedeihen | thrive | 286,547 | Cognate with the obsolete English verb *thee* ("So mote it thee!"); its old participle survives as the adjective *gediegen* |
| schwören | swear | 282,581 | English *swear*; an *answer* was originally *and-swaru*, a swearing-back |
| spinnen | spin | 170,464 | English *spin*; a spider is literally the spinner; colloquial German added "Du spinnst!" |
| mahlen | grind | 164,159 | PIE *\*melh₂-*: English *meal* (the ground kind), *molar*, and *Mühle*; weak Präteritum *mahlte* but strong participle *gemahlen* |
| genesen | recover | 158,328 | PIE *\*nes-*, "return home safely": the root of Greek *nóstos* and therefore *nostalgia*; recovery as homecoming |
| dreschen | thresh | 62,103 | Direct cognate of *thresh*; a threshold is where one threshed |
| melken | milk | 50,171 | PIE *\*h₂melǵ-*: English *milk*, Latin *mulgēre*, and *emulsion*, that which has been milked out |
| bersten | burst | 26,380 | English *burst* with the r on the other side of the vowel (Old English *berstan*): metathesis in action |
| sieden | boil, seethe | 19,878 | Cognate of *seethe*; English *sodden* is the fossilized strong participle, parallel to *gesotten*; English lost the strong verb, German kept it |
| verdrießen | vex | 14,109 | From Proto-Germanic *\*þreutaną* "to weary", the root family of English *threat*; its participle thrives in *Politikverdrossenheit* |
| kiesen | choose (archaic) | 12,428 | The direct cognate of English *choose*, alive mainly in its participle *gekoren* |
| wringen | wring | 4,602 | A Low German loan embedded in the strong system; kin to *ringen* and *würgen* as well as English *wring* |
| küren | elect (to an honor) | 439,640 | Originally weak, it borrowed the strong past *kor/gekoren* from its sibling kiesen; the same root gives *Walküre*, chooser of the slain, and *Kurfürst*, the electing prince; sports journalism keeps it frequent ("zum Sieger gekürt") |

The last row is the frequency surprise of the investigation: küren out-polls even beißen in the DWDS corpus.

## Modeling wrinkles the extraction must handle

1. **Dual paradigms.** sieden, küren, weben, and gären each have parallel strong and weak conjugation sets, both current. The model supports one paradigm per verb; either pick house style per verb or extend the model.
2. **Variant principal parts.** spinnen (spann beside archaic sponn), schwören (schwor beside archaic schwur), melken (milkt/melkt, molk/melkte).
3. **Dual auxiliaries.** schmelzen takes sein intransitively and haben transitively; `ay` is single-valued. Measured against kaikki, 469 single-word lemmas are dual-auxiliary: **51 already ship in Konjugieren** with one reading silently wrong, and 418 are in the incoming pool. The full analysis, the five classes involved, and the deferred work plan are in [`../prompts/dual_auxiliary.md`](../prompts/dual_auxiliary.md); its interim policy governs until that pass runs.
4. **Weak Präteritum with strong participle.** mahlen, salzen, spalten (mahlte, gemahlen). Neither the current mixed family (vowel change plus weak endings) nor the weak family fits; a new family or ablaut-group full overrides (the `*` suffix mechanism) would cover them.
5. **Multiword lemmas.** 1,048 English-Wiktionary titles are idioms and phrases; the model is single-word infinitives, so filter them out.
6. **Soft-redirect senses.** mahlen's second English-Wiktionary sense is "obsolete spelling of malen"; sense-level filtering must keep such cruft out of `tn`.
7. **Separable/inseparable homographs.** The pool contains verbs with both readings (the classic umfahren problem); the model encodes exactly one reading per verb.

## Automatic family classification, with verification for free

Classification need not be manual at 6,000-verb scale:

1. For each candidate, hypothesize weak, then -ieren, then every existing ablaut group, with each viable `^` marking of the stem.
2. Generate all conjugations with `Conjugator`.
3. Compare against the Wiktionary conjugation table (kaikki `forms`). An exact match confirms family, group, and marking simultaneously; the mismatch queue is precisely the set of verbs needing a new ablaut group or human judgment.

This inverts the manual checklist in `adding-verbs.md` into search plus verification, and every imported verb arrives with an externally sourced expected-conjugation set, ready to be spot-sampled into `ConjugatorTests`.

For `hi`, the DWDS frequency API (no authentication; see recipes) returns lemma hits against a 53.2-billion-token corpus and worked for every verb tried.

**Correction (2026-07-19): the licensing sentence that stood here was wrong.** It claimed DWDS-derived ranks "with a Credits mention are cleaner" than Leipzig Wortschatz, SUBTLEX-DE, or DeReWo. Reading the actual terms at `dwds.de/d/nutzungsbedingungen` reverses that judgment. Two sentences govern:

> Die Berlin-Brandenburgische Akademie der Wissenschaften (BBAW) behält sich das Recht an der Nutzung der Daten gemäß § 44b UrhG vor.

> Jegliche Nutzung der Inhalte des DWDS, einschließlich jedoch nicht beschränkt auf automatisierte Abfragen und Auswertungen (Crawlen, Parsen, Text- und Data-Mining), sofern nicht über § 60d UrhG zulässig, ist nur mit ausdrücklicher Genehmigung gestattet.

§ 44b UrhG is Germany's general text-and-data-mining exception, and rights holders may reserve it for non-research uses; BBAW has done so explicitly. § 60d is the *scientific research* TDM exception, available to non-commercial research organizations — which a shipping App Store app is not. So bulk-querying the frequency API to populate `hi` across the corpus, and shipping the derived ranks, requires written permission (`dwds@bbaw.de`), regardless of attribution. Quoting a handful of frequencies in a design document, as this file does, stays inside the citation allowance ("Der Umfang darf den üblicher Zitate nicht überschreiten") given a Quellenangabe.

The practical path is to ask: BBAW is an academic academy, Konjugieren is free and educational, and a Credits attribution costs them nothing. But ask before building on it. See `verbdata/README.md` for the snapshot taken on 2026-07-19 and the fallbacks if the answer is no.

## Other sources considered

- **Wikidata lexemes**: 20,421 German verb lexemes, CC0, queryable by SPARQL. Conjugation statements are decent, English glosses sparse. Best as a CC0 fallback or cross-check, not the primary source.
- **verbformen.de (Netzverb)**: the largest dedicated German-verb site; homepage and download page state CC BY-SA 4.0. Worth a follow-up look at its downloadable lists; its verb-count claim was not verified this session.
- **DWDS**: not a verb list, but the cleanest frequency source (see above).
- **Duden, PONS, dict.cc, printed "501 German Verbs"**: proprietary, personal-use-only, or too small; rejected.

## Licensing

Wiktionary and Wikipedia text is CC BY-SA 4.0. Deriving the verb database from them requires attribution (the Credits Info article is the natural home) and ShareAlike on the derived data files. Konjugieren's data files are already public on GitHub, so ShareAlike is satisfiable without ceremony. If ShareAlike ever becomes unwanted, Wikidata's CC0 lexemes are the fallback, with comparable verb coverage but much thinner glosses and no etymologies.

## Recommended next steps

1. **Done (2026-07-18).** Download `kaikki.org-dictionary-German-by-pos-verb.jsonl` (293.9 MB): now at `verbdata/kaikki.org-dictionary-German-by-pos-verb.jsonl` (gitignored), all 87,343 records validated, SHA-256 pinned. Provenance, integrity stats, and the re-download recipe live in `verbdata/README.md`. Filtering to single-word lemmas folds into the step-2 pipeline.
2. **Done (2026-07-19).** The classify-and-verify pipeline is built and has run repeatedly: `verbdata/build_candidates.py` → `KonjugierenTests/Utils/VerbClassificationTests.swift` → `verbdata/summarize_classification.py`. Design, invocation, and findings are in [`verb-classification.md`](verb-classification.md). **6,857 of 8,232 incoming verbs (83.3%) are classified and externally verified**, including 42 of the 44 named missing strong verbs — the two holdouts, *mahlen* and *spalten*, are wrinkle 4 above — weak Präteritum with strong participle, which the model still cannot express.

   Its first run also found that **354 of the 985 shipping verbs disagreed with Wiktionary**. Those defects were fixed the same day, in `Conjugator` (the epenthetic -e and the -ern/-eln endings) and in the data (the ß/ss alternation and eleven mis-marked prefixes). The corpus now stands at **8 verbs at odds, 99.7% verified**, and that number is the regression test for every step below: re-run the three stages after any change, and it should never rise. **Do not compare that 8 to figures in older prose.** The metric was tightened on 2026-07-19 to count a verb whose shipped encoding failed even when the classifier could rescue it with an ablaut group that already ships; under the old, looser metric the same corpus reads 6, and it read 6 while 67 verbs were quietly broken.

3. **Done (2026-07-19).** Model passes, before any import. Two enhancements reshape `Verbs.xml`, `VerbParser`, and `Verb`, and both are cheaper to do before the corpus grows than after.
   1. [`../prompts/regional_variation.md`](../prompts/regional_variation.md) — variation by **standard variety**: a Region setting, Swiss ß/ss rendering, and the Austrian/Swiss auxiliary of *stehen*, *sitzen*, *liegen*. It also dedupes the 98 incoming Swiss spellings, which would otherwise import as duplicate verbs.
   2. [`../prompts/dual_auxiliary.md`](../prompts/dual_auxiliary.md) — variation by **meaning**: the `<reading>` model, covering 48 shipping and 418 incoming dual-auxiliary verbs. **This pass also carries the double-prefix grammar**, without which the 1,186 incoming verbs needing a separable prefix over an already-prefixed base (*angehören*, *aufbewahren*) cannot be expressed at all. That is the single largest blocker to the import, and it is invisible from this list unless you read that prompt.

   Order matters: regional first, then dual-auxiliary. Both write into `ay` with different theories of what it means.

4. **Done (2026-07-19).** Refactored `fr` into `hi`: `Verbs.xml` stores the raw DWDS hit count and `VerbParser` derives the dense rank at parse time, so adding a verb no longer renumbers every incumbent. `fr` is retired from the DTD. See the section near the end of this document.

5. **Done (2026-07-19).** First tranche: the missing strong bases. 82 were missing, not 87; 78 shipped, taking the corpus from 990 verbs to **1,068** and the ablaut inventory from 68 groups to 73. The import script and its decision table are `verbdata/import_tranche1.py`, whose header records the reasoning. Four were deferred with reasons: *mahlen* and *spalten* (wrinkle 4, and kaikki lists only their strong participle, so nothing verifies), and *speien* (verifies only via a group that splits the Präteritum by person — the signature of a `Conjugator` gap, and importing it is exactly what the sequencing argument in `verb-classification.md` forbids). All 78 verify against Wiktionary with the encoding they ship with, and the at-odds count held at 8.

   Two findings worth carrying into the next tranche. The classifier minimizes for the *shortest* ablaut region, which puts a doubled consonant across the region boundary (`kn^ei^fen` + `IF`); rewriting each proposal to this corpus's convention — the region wide enough to carry the whole consonant change, `kn^eif^en` + `IFF` — collapsed thirteen proposed new groups into five, because the reworded region matched a group that already shipped. And because kaikki's `forms[]` lists *both* paradigms of a dual-paradigm verb, and the classifier accepts any listed alternative, either paradigm verifies: the strong/weak choice for *melken*, *weben*, *sieden*, *flechten*, *gären*, *glimmen*, *bellen*, *triefen* is editorial, not mechanical. The rule applied was to ship strong only where the strong paradigm is current standard German.

   Prefixed derivatives of these new bases were **not** imported; they belong to step 6, and re-running `build_candidates.py` brings them into scope there.

6. **Done (2026-07-19).** Second tranche: the prefixed derivatives of already-supported verbs. 2,315 shipped, taking the corpus from 1,068 to **3,383**, with no new ablaut groups. The importer and every rule it applies are `verbdata/import_tranche2.py`.

   The prefix-inventory blocker was cleared first, and the fix was smaller and more general than "widen the inventory". The classifier had been deriving its inventory from the prefixes shipping verbs happened to use; it now reads the separable head off Wiktionary's own participle, since German infixes the *ge-* after a separable first element. That needs no inventory to maintain and it generalizes to the adjective and noun compounds the model could always express but nothing ever proposed — *kaputtmachen*, *achtgeben*, *eislaufen*. Incoming verification went 84.4% → 94.6% and the prefix queue fell 747 → 28.

   The tranche is thirty times the size of tranche 1, which broke two per-verb doctrines outright: nobody places 2,300 hit counts "between comparable shipping verbs" and means it, and nobody picks 2,300 icons by taste. Both became rules. `ic` is inherited from the base verb. `hi` is the base's count scaled by a ratio **measured** from the corpus's own 446 real derivative/base pairs — per-prefix where the sample allows, and the per-prefix spread is linguistically legible, with lexicalizing inseparable prefixes running high (*be-* 0.37, *er-* 0.41) and directional particles low (*weiter-* 0.04). Used raw the ratio was badly wrong at the top, putting 796 verbs in the corpus's top 500 and the archaic *gehaben* fourth overall, so estimates are clamped to the count of the 900th real verb — justified by a second measured fact, that every verb here was **absent** from the frequency-ordered list that produced the original 990.

   Deferred, and recorded in `docs/roadmap.md` § "The tranche-2 deferrals": 182 derivatives needing an ablaut group that does not ship, 176 dual-auxiliary verbs shipping one reading, 70 with unusable glosses, and 28 the prefix check still rejects.

7. Then new weak stems in DWDS-frequency order until taste says stop; 6,000+ verbs are reachable from the 6,980-verb both-Wiktionaries pool alone. **Gated on a reply from BBAW** — see "`hi` is blocked" below and [`dwds-permission-email.md`](dwds-permission-email.md). Steps 5 and 6 are unaffected, since they are defined by membership rather than by frequency order; only this long tail needs a ranking. If no reply arrives, rank by a provisional source and mark it for re-derivation.

8. Feed `etymology_text` into the existing `Etymologies.json` pipeline; kaikki removes the need for the Chrome-based per-page extraction described in `docs/etymologies.md` for new verbs. 5,979 verified incoming verbs carry one.

9. On expansion, update the CLAUDE.md sentence promising "1,000 verbs", and `docs/description.md`, which has shipped a stale count to the App Store before.

## Reproduction recipes

```bash
UA="KonjugierenVerbResearch/1.0 (contact: <email>)"

# Category sizes
curl -sG -A "$UA" "https://en.wiktionary.org/w/api.php" \
  --data-urlencode "action=query" --data-urlencode "prop=categoryinfo" \
  --data-urlencode "titles=Category:German verbs" --data-urlencode "format=json"

# Full member list (loop cmcontinue until absent; ~21 requests for en, ~30 for de)
curl -sG -A "$UA" "https://en.wiktionary.org/w/api.php" \
  --data-urlencode "action=query" --data-urlencode "list=categorymembers" \
  --data-urlencode "cmtitle=Category:German verbs" --data-urlencode "cmnamespace=0" \
  --data-urlencode "cmlimit=500" --data-urlencode "format=json"

# German Wiktionary: same recipe with cmtitle="Kategorie:Verb (Deutsch)"

# Per-verb wikitext (glosses, etymology, {{de-conj}} / Übersicht)
curl -sG -A "$UA" "https://en.wiktionary.org/w/api.php" \
  --data-urlencode "action=parse" --data-urlencode "page=bersten" \
  --data-urlencode "prop=wikitext" --data-urlencode "format=json"

# DWDS lemma frequency
curl -sG -A "$UA" "https://www.dwds.de/api/frequency/" --data-urlencode "q=gedeihen"

# Wikidata: count of German verb lexemes (CC0)
curl -sG -A "$UA" "https://query.wikidata.org/sparql" --data-urlencode "format=json" \
  --data-urlencode "query=SELECT (COUNT(DISTINCT ?l) AS ?verbs) WHERE { ?l dct:language wd:Q188 ; wikibase:lexicalCategory wd:Q24905 . }"

# Strong-verb inventory: de.wikipedia "Liste starker Verben (deutsche Sprache)",
# action=parse&prop=wikitext, then extract bolded verbs from {{Verb Zelle|...}} rows
```

## Handoff for the pipeline work (written 2026-07-19, when it was step 2)

Facts a fresh session needs that are not established above. Each one was verified on the date
in the heading.

### `Conjugator` cannot conjugate a verb it has never heard of

This is the central constraint on the classify-and-verify design sketched above, and the
sketch does not mention it. `Conjugator.conjugate(infinitiv:conjugationgroup:)` resolves the
verb by dictionary lookup:

```swift
guard let verb = Verb.verbs[infinitiv] else {
  return .failure(.verbNotRecognized)
}
```

So a candidate cannot be conjugated until it exists in `Verb.verbs`. The hypothesize-and-test
loop must therefore **insert a synthetic `Verb` into `Verb.verbs` for each hypothesis**, then
conjugate, then compare against kaikki's `forms[]`. `Verb.verbs` is a `@MainActor static var`
dictionary, so this is a plain assignment; remember to remove or overwrite between hypotheses.
`Verb.init` needs `infinitiv`, `translation`, `family`, `auxiliary`, `frequency`, `prefix`,
and `frequencyIcon`, so the hypothesis has to supply placeholder values for the fields it is
not testing.

Two consequences for where the pipeline lives. `Conjugator` is **not** `nonisolated`, and the
project sets `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`, so every call site must be
`@MainActor`. And driving app code over a large input set already has a precedent in this
repo: `KonjugierenTests/Utils/VerbExportTests.swift` is a `@MainActor` `@Suite` that walks all
990 verbs, conjugates each across twelve conjugationgroups, and writes JSON to a temp path.
Step 2 wants that same shape, a test-target harness rather than a standalone script, because a
standalone script cannot reach `@testable import Konjugieren`.

### Strip `[+*^]`, not `[+^]`, from the `in` attribute

`Verbs.xml` marks infinitives with three characters: `+` separable prefix, `*` inseparable
prefix, `^` ablaut region. An extraction that strips only `+` and `^` leaves 305 verbs looking
like `be*achten`. This already caused one silent failure, described in `verbdata/README.md`:
the DWDS API answers such junk with a well-formed zero rather than an error, so the run
reported complete success while a third of the corpus was garbage. Use `re.sub(r'[+*^]', '', …)`.

### The DOCTYPE is now the schema, and the build enforces it

Corrected 2026-07-19. This section previously warned that the `Verbs.xml` DOCTYPE was stale
and should not be treated as the schema. Both halves of that are now obsolete. The internal
subset was repaired and a **Validate Verbs.xml** build phase now runs `xmllint --valid` ahead
of compilation in the Konjugieren target, so a malformed verb fails the build with a
file-and-line diagnostic rather than shipping silently.

The declaration, which is the authoritative list of what a verb carries:

| Attribute | Declared | Meaning |
|---|---|---|
| `in` | `CDATA #REQUIRED` | infinitive with `+`, `*`, `^` markers |
| `tn` | `CDATA #REQUIRED` | short English translation |
| `fa` | `(w\|s\|m\|i) #REQUIRED` | family: weak, strong, mixed, -ieren |
| `hi` | `CDATA #REQUIRED` | raw DWDS hit count; the displayed rank is derived from it at parse time |
| `ic` | `CDATA #REQUIRED` | frequency-icon suffix, e.g. `cooldown`, `walk.arrival` |
| `ag` | `CDATA #IMPLIED` | ablaut group; present on exactly the 325 strong and mixed verbs |
| `ay` | `(h\|s) #IMPLIED` | auxiliary; only ever `s` in practice, absence meaning haben. Single-valued, which is a known shortcoming: see below |

Two traps the DTD now catches that it previously could not. `ic` is required and every one of
the 990 verbs carries it, but `VerbParser` falls back to a bare `"figure"` when it is absent,
so before the build phase an omission produced no error, no test failure, and a silently
inconsistent verb list. And `fa` is now an enumeration rather than free-form `CDATA`, so a
typo in the family code fails the build instead of reaching `VerbParser`'s `default:` branch
and its `fatalError`.

Budget an `ic` decision per imported verb; 40 distinct values are in use. `ay` is genuinely
optional and rare, 63 of 990.

### Dual-auxiliary verbs are a known shortcoming with a standing interim policy

You will hit these during import: 469 single-word lemmas take sein in one reading and haben
in another, of which **418 are in the incoming pool** and 51 already ship with one reading
silently wrong. `ay` holds one value, so importing them naively bakes in the same error 418
more times.

**The rules live in [`../prompts/dual_auxiliary.md`](../prompts/dual_auxiliary.md), in its
"Interim policy" section. Read it before importing, and do not restate it here.** That file
is the single source; a copy in this document would drift from it, which is the failure this
repo has already paid for twice.

The one point worth repeating, because the build enforces it rather than the prose: the DTD
declares `ay (h|s)`, and a combined value such as `"hs"` will fail validation. That rejection
is intentional, not an obstacle to route around.

### `hi` is blocked, and re-querying DWDS is the wrong move

A permission request went to `dwds@bbaw.de` on 2026-07-19; see
[`dwds-permission-email.md`](dwds-permission-email.md). Until BBAW replies, **do not query the
DWDS frequency API in bulk**, which is the specific activity their § 44b reservation covers.
A 990-lemma snapshot already exists at `verbdata/dwds-frequencies.json`, gitignored, and
`verbdata/fetch_dwds_frequencies.py` regenerates it if permission arrives.

This blocks step 7 outright — ranking the weak long tail by frequency. It also touches steps 5
and 6 in a way that was not true before the `fr` refactor. Those tranches are defined by
membership, so their *selection* needs no reply, but `hi` is `#REQUIRED` and holds a measured
count. The old `fr` was a rank a human could assign by judgment; a hit count cannot be invented,
because you cannot eyeball whether 500,000 is common. Every imported verb therefore needs either
a real count or an explicitly provisional one. See "Provisional hit counts" below.

### Leipzig Corpora Collection was evaluated as a substitute and rejected

Checked 2026-07-19, so nobody spends another afternoon on it. Leipzig (Wortschatz, Universität
Leipzig) is the obvious alternative German frequency source and fails on four independent grounds,
any one of which is disqualifying.

**The licence splits, and the half we would use is the wrong half.** Their
[Terms of Usage](https://wortschatz.uni-leipzig.de/en/usage) put "the data and applications
provided by the project" under **CC BY-NC**, stating that "commercial use of the data are
prohibited without the written consent of the project management" — that covers the web-service
API. Separately, "the text corpora offered for download are made available under the Creative
Commons licence CC BY." So the API numbers cannot ship in a paid App Store app for the same
reason DWDS's cannot, while the downloadable corpora legitimately could underpin counts you
compute yourself. Querying the API is itself fine: the terms prohibit automated queries "except
via our web services", and the web service is the sanctioned channel. It is *shipping the
derived values* that is not.

**It is 1,000× too small.** The largest German corpus, `deu_news_2012_3M`, holds 50.7 million
tokens against DWDS's 53.2 billion.

**17 of the 87 missing strong bases are absent entirely**, returning 404: brinnen,
dahinkriechen, eischen, hangen, keifen, klieben, klimmen, kneipen, kreißen, kröschen, schleißen,
schneen, schröcken, schwären, **sieden**, spleißen, wringen. Many that are present sit at counts
of 1 to 6, which is noise rather than frequency. News and web text under-represents exactly the
archaic strong verbs this tranche is made of.

**It measures word forms, not lemmas.** `machen` is 24,992 in Leipzig — occurrences of the
literal string — against 67,161,366 in DWDS, which is the lemma across all inflections. Measured
against the DWDS snapshot on an 83-verb sample spread evenly across the rank range, Spearman
ρ = 0.876, with a worst displacement of 57 places *within the sample*, roughly 680 places at
full-corpus scale.

The worst outlier is worth naming: **`gleichen`**, one of the eight homographs repaired earlier
the same day, because the string also inflects the adjective *gleich*. Leipzig reproduces the
contamination, and the gate in `fetch_dwds_frequencies.py` cannot catch it — that check compares
the returned lemma against the one asked for, and Leipzig returns only the word you queried, so
the comparison is a tautology.

The general lesson, which applies to the next candidate source too: any corpus good enough to
substitute for DWDS is likely restricted for the same reason DWDS is, because the counts *are*
the asset. The productive question is not which free source to find, but whether a
membership-defined tranche needs measured frequency at all.

### Provisional hit counts: the `hp` attribute

For a tranche that cannot get real counts, a hand-assigned `hi` placed by editorial judgment
beats a precise-looking number that is wrong for reasons no check can detect. That is what the
old `fr` always was; the only change is the unit.

The risk is not the guess. It is that a provisional value silently becomes permanent, which is a
failure this repo has already paid for. So provisional counts are marked in the data:

```xml
<verb in="s^ie^den" hi="19878" hp="y" ic="flame">
  <reading tn="boil, seethe" fa="s" ag="sieden" />
</verb>
```

| Attribute | Declared | Meaning |
|---|---|---|
| `hp` | `(y) #IMPLIED` | present means `hi` is an editorial estimate, not a measured DWDS count |

Absence means the count is real, mirroring how `ay`'s absence means haben. The DTD admits only
`y`, so a typo fails `xmllint --valid` rather than silently reading as "real".

Rules:

- **`hp` changes no behaviour.** The rank derives from `hi` exactly as before. The flag is
  provenance, and `VerbParser` exposes it as `Verb.hitsAreProvisional`.
- **Place the estimate, do not invent it.** Pick a neighbourhood by judgment — "about as common
  as *gedeihen*" — and take a value between its neighbours' real counts. That way the derived
  rank lands where you meant, which a round number like 100000 will not.
- **Nothing renders it.** A displayed `#847` is no less useful for being an estimate, and a
  question mark in the UI would be noise.
- **Clearing it is one line per verb.** When permission arrives, re-query with probes, replace
  `hi`, drop `hp`. This is the whole reason step 6 stored counts instead of ranks.
- **Do not consult a rejected source informally.** Leipzig's numbers are CC BY-NC, and an estimate
  "informed by" them is still derived from them — a human retyping the figure in between does not
  launder it. Legitimate inputs are the verb's register and semantics, Wiktionary/kaikki labels
  such as *archaic* or *regional*, the licensed texts in `corpus/`, and the real `hi` values of
  shipping verbs.

`verbdata/generate_frequencies_txt.py` reports how many verbs carry `hp`, so the provisional
population is visible on every regeneration rather than discoverable only by grep.

### Step 4 in detail: store hits, derive rank

**Executed 2026-07-19.** `Verbs.xml` now carries `hi`, the raw DWDS hit count, and `fr` is gone
from the DTD, so a stale tool writing a rank fails `xmllint --valid` rather than passing as a
plausible small number. `VerbParser.ranked` derives the dense 1..n rank after parsing;
`Verb.hits` is the count and `Verb.frequency` stays the rank, which left all four sort sites and
both render sites correct without edits. Three tests in `VerbTests` now assert the rank is dense
and that more hits means a lower rank — the ordering guard the section below notes was missing.
The at-odds count held at 8. Everything below is the reasoning that produced this, kept because
the traps it records apply again at the next fetch.

`fr` was a dense unique rank from 1 to 990, stored per verb. That means every tranche
of new verbs rewrites the `fr` of all incumbents, which is a large useless diff and an
invitation to error. Storing raw frequency and computing the rank at parse time makes adding a
verb a one-line change. The refactor touches `VerbParser`, `Verb.verbsSortedByFrequency`, and
`VerbExportTests`, and it wants to land before the corpus grows, not after. It is independent
of the DWDS licensing question, since the argument is about diff churn rather than data
source.

**Preconditions, verified 2026-07-19 at the end of step 5.** Confirmed by measurement, not by
reading, so a fresh session can start without re-deriving them:

- `fr` really is dense and unique over 1..990. Step 5 reshaped `Verbs.xml` but changed no `fr`
  value and no verb key.
- `verbdata/dwds-frequencies.json` has a hit count for **all 990** shipping verbs, with **no
  ties** among them, so the derived rank is a strict total order and needs no tiebreak policy.
- `fr` stays on `<verb>`, not on `<reading>`, so the reading model added in step 5 does not
  interact with this refactor. See "Readings" in `adding-verbs.md`.

**The eight bad hit counts are fixed. Read this anyway before re-fetching.** `fr` itself is
hand-maintained and was never affected; the defect was in `verbdata/dwds-frequencies.json`,
which is the source step 6 switches to.

The DWDS frequency endpoint lemmatizes whatever it is given and takes no part-of-speech
parameter, so eight infinitives resolved to a homographic adjective or noun and returned that
word's count instead: `runden`→`rund` (23.4M), `gleichen`→`gleich` (18.1M), `lauten`→`laut`,
`weißen`→`weiß`, `achten`→`acht`, `tätigen`→`tätig`, `regen`→`rege`, and `einigen`, which
returned a tab-joined multi-lemma and scored zero. Nothing in the response marks these as
wrong — the count is real, it is just a different word's — and deriving rank from them would
have put `runden` 25th of 990.

All eight were re-queried on 2026-07-19 using an unambiguously verbal inflected form, with the
returned lemma verified against the verb. Their rows now carry a `probe` field naming the form
used. After the repair, no verb resolves to a mismatched lemma except three harmless variant
spellings (`reißen`→`reissen`, `erschweren`→`erschwern`, `kreieren`→`kreiern`, all shifting
fewer than 45 places), and no verb scores zero.

Post-repair, `fr` and the derived rank disagree by a median of 43 places, with the largest
legitimate shifts in the long tail where the hand-assigned ranks were always guesswork —
`weiterlesen` drops from 447 to 975 on 425K hits, which is the refactor doing its job rather
than a defect. `fällen` has the single largest shift (+575) and was checked specifically: DWDS
is case-sensitive, `Fällen` is a separate entry resolving to the noun `Fall`, and the
unambiguous `fällte` returns the same count, so its 5.7M is genuine idiom (*eine Entscheidung
fällen*) and not contamination.

The failure mode and the probe technique are documented at the top of
`fetch_dwds_frequencies.py`. What used to be a detection *recipe* there — prose a future session
had to read and act on — is now **an enforced gate**: the script classifies every row before
writing anything, and one suspect row aborts the run with a nonzero exit and no output file.
Verification is on by default, `--no-verify` opts out, and `--check FILE` audits an existing
snapshot without touching the network. Confirmed 2026-07-19 by re-querying the eight bare
infinitives live: all eight were refused, and the same eight passed when given probes,
reproducing the shipped counts exactly. The script still queries a bare infinitive when no probe
is supplied, so **a bulk import must generate probes** — from kaikki's `forms[]`, which carries
`perfektpartizip` and `präsensIndikativ.ts` for every candidate — but a naive re-fetch now fails
loudly instead of silently.

**Two traps in the call sites, one of them silent.** The section above names `VerbParser`,
`Verb.verbsSortedByFrequency`, and `VerbExportTests`. Checked on 2026-07-19, that list is
incomplete in a way worth knowing before starting:

- **`fr` is rendered, not just sorted by.** `VerbBrowseView` prints `#\(verb.frequency)` and
  `VerbView` uses the same value as the accessibility label of its `#168` pill. If `fr` starts
  holding raw hits, those render `#516850`. The derived rank has to be reachable from `Verb`,
  not merely used for ordering.
- **The sort direction inverts.** Every site sorts ascending — `$0.frequency < $1.frequency` —
  which means *most common first* for a rank and *least common first* for a hit count. Both
  `Verb.verbsSortedByFrequency` and `BrowseableFamily`'s three-exemplar picker do this, and the
  second is not in the section's list. Left alone, the family screens would quietly showcase the
  three rarest verbs in each family. No test asserts the ordering, so nothing would fail.

Keeping `Verb.frequency` as the derived rank and giving the raw count a different name avoids
both, and leaves every existing call site correct.

Note also that `VerbParser` was substantially rewritten in step 5 — it now parses nested
`<reading>` elements and an `in` grammar that admits repeated prefix markers. `fr` is still read
exactly once, in `startVerb`, so the guidance above holds; the file simply no longer looks like
it did when this section was written.

### Verify counts, do not trust them

Three documents in this repo claimed 989 verbs well after the corpus reached 990, and
`docs/description.md` shipped that number to the App Store. The stale copies were all prose
that no code consumed. `Konjugieren/Models/Verbs.xml` is the single source of truth; check
coverage by set difference rather than by comparing to a number written in a document.

This section used to point at a recipe in `etymology-pipeline.md`, a file that does not exist,
which is the failure it warns about wearing its own clothes. The recipe, inlined so it cannot
rot again:

```python
import re, xml.etree.ElementTree as ET
shipping = {re.sub(r'[+*^]', '', v.get('in')) for v in ET.parse('Konjugieren/Models/Verbs.xml').getroot()}
print(len(shipping), sorted(candidates - shipping)[:20])
```
