# Sources for Additional Verbs

Research findings on expanding Konjugieren's verb corpus beyond the current 990. All counts, sizes, and frequencies in this document were measured live on 2026-07-18 against the cited APIs; reproduction recipes appear at the end.

## Context

Konjugieren ships 990 verbs (583 weak, 294 strong, 30 mixed, 83 -ieren), the survivors of data cleansing on a frequency-of-use list. The sibling apps Conjuguer (~6,200 verbs) and Conjugar (~4,800) were fed by the "Made Simple(r)" books; no comparable German book is in hand, so the path to parity runs through open data.

A new verb needs everything `Verbs.xml` encodes: infinitive with prefix and ablaut markers (`in`), a short English translation (`tn`), family (`fa`), frequency rank (`fr`), a frequency-icon suffix (`ic`), an ablaut group (`ag`) for strong and mixed verbs, and auxiliary (`ay`). The file's DOCTYPE is the authoritative list; see the handoff section at the end. Each verb ideally also gains entries in `Etymologies.json` and `ExampleSentences.json`. The sources below are therefore rated not just on verb count but on whether glosses, etymologies, and full conjugation tables travel with the verbs in the same pass, so that nothing must be recrawled later.

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
3. **Dual auxiliaries.** schmelzen takes sein intransitively and haben transitively; `ay` is single-valued.
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

For `fr`, the DWDS frequency API (no authentication; see recipes) returns lemma hits against a 53.2-billion-token corpus and worked for every verb tried.

**Correction (2026-07-19): the licensing sentence that stood here was wrong.** It claimed DWDS-derived ranks "with a Credits mention are cleaner" than Leipzig Wortschatz, SUBTLEX-DE, or DeReWo. Reading the actual terms at `dwds.de/d/nutzungsbedingungen` reverses that judgment. Two sentences govern:

> Die Berlin-Brandenburgische Akademie der Wissenschaften (BBAW) behält sich das Recht an der Nutzung der Daten gemäß § 44b UrhG vor.

> Jegliche Nutzung der Inhalte des DWDS, einschließlich jedoch nicht beschränkt auf automatisierte Abfragen und Auswertungen (Crawlen, Parsen, Text- und Data-Mining), sofern nicht über § 60d UrhG zulässig, ist nur mit ausdrücklicher Genehmigung gestattet.

§ 44b UrhG is Germany's general text-and-data-mining exception, and rights holders may reserve it for non-research uses; BBAW has done so explicitly. § 60d is the *scientific research* TDM exception, available to non-commercial research organizations — which a shipping App Store app is not. So bulk-querying the frequency API to populate `fr` across the corpus, and shipping the derived ranks, requires written permission (`dwds@bbaw.de`), regardless of attribution. Quoting a handful of frequencies in a design document, as this file does, stays inside the citation allowance ("Der Umfang darf den üblicher Zitate nicht überschreiten") given a Quellenangabe.

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
2. Build the classify-and-verify pipeline against `Conjugator`.
3. First tranche: the 87 missing strong bases plus their common derivatives. "Every German strong verb" is a completable, marketable milestone for an ablaut-centric app.
4. Second tranche: the 2,406 prefixed derivatives of already-supported verbs.
5. Then new weak stems in DWDS-frequency order until taste says stop; 6,000+ verbs are reachable from the 6,980-verb both-Wiktionaries pool alone.
6. Feed `etymology_text` into the existing `Etymologies.json` pipeline; kaikki removes the need for the Chrome-based per-page extraction described in `docs/etymologies.md` for new verbs.
7. On expansion, update the CLAUDE.md sentence promising "1,000 verbs", and decide whether `fr` stays list-based or is re-derived from DWDS for all verbs.

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

## Handoff for step 2 (written 2026-07-19)

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
| `fr` | `CDATA #REQUIRED` | frequency rank |
| `ic` | `CDATA #REQUIRED` | frequency-icon suffix, e.g. `cooldown`, `walk.arrival` |
| `ag` | `CDATA #IMPLIED` | ablaut group; present on exactly the 324 strong and mixed verbs |
| `ay` | `(h\|s) #IMPLIED` | auxiliary; only ever `s` in practice, absence meaning haben |

Two traps the DTD now catches that it previously could not. `ic` is required and every one of
the 990 verbs carries it, but `VerbParser` falls back to a bare `"figure"` when it is absent,
so before the build phase an omission produced no error, no test failure, and a silently
inconsistent verb list. And `fa` is now an enumeration rather than free-form `CDATA`, so a
typo in the family code fails the build instead of reaching `VerbParser`'s `default:` branch
and its `fatalError`.

Budget an `ic` decision per imported verb; 40 distinct values are in use. `ay` is genuinely
optional and rare, 63 of 990.

### `fr` is blocked, and re-querying DWDS is the wrong move

A permission request went to `dwds@bbaw.de` on 2026-07-19; see
[`dwds-permission-email.md`](dwds-permission-email.md). Until BBAW replies, **do not query the
DWDS frequency API in bulk**, which is the specific activity their § 44b reservation covers.
A 990-lemma snapshot already exists at `verbdata/dwds-frequencies.json`, gitignored, and
`verbdata/fetch_dwds_frequencies.py` regenerates it if permission arrives.

This does not block step 2. It blocks assigning `fr` to newly imported verbs, which is a
step-3 concern. If step 3 needs to proceed before a reply, rank the new tranche by a
provisional source and mark it for later re-derivation.

### Recommendation not yet implemented: store hits, derive rank

`fr` is currently a dense unique rank from 1 to 990, stored per verb. That means every tranche
of new verbs rewrites the `fr` of all incumbents, which is a large useless diff and an
invitation to error. Storing raw frequency and computing the rank at parse time makes adding a
verb a one-line change. The refactor touches `VerbParser`, `Verb.verbsSortedByFrequency`, and
`VerbExportTests`, and it wants to land before the corpus grows, not after. It is independent
of the DWDS licensing question, since the argument is about diff churn rather than data
source.

### Verify counts, do not trust them

Three documents in this repo claimed 989 verbs well after the corpus reached 990, and
`docs/description.md` shipped that number to the App Store. The stale copies were all prose
that no code consumed. `Konjugieren/Models/Verbs.xml` is the single source of truth; check
coverage by set difference rather than by comparing to a number written in a document. See the
recipe at the top of `etymology-pipeline.md`.
