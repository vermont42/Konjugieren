# Phase 2 of the verb-history fact-check: adversarial verification

Run 2026-07-28 and 2026-07-29 against [`prompts/verify-verb-history.md`](../prompts/verify-verb-history.md),
over the 31 findings in [`docs/verb_history_phase1.md`](verb_history_phase1.md). Fifty-one agents,
no failures: 31 skeptics, 19 second opinions, and one coverage auditor. 2,376,954 subagent tokens,
592 tool calls, 303 web searches of the session's 600, about 22 minutes of wall clock across two
sittings either side of a usage-window pause.

Nothing in the essay was edited. `docs/verb_history.txt` and `Konjugieren/Assets/Localizable.xcstrings`
are what Phase 0 left. For the German-specific half the deliverable is this document, and Josh
decides what changes.

Full reports are in [`docs/verb_history_phase2_reports/`](verb_history_phase2_reports/): one
`verdict_<REF>.md` per finding, one `second_<REF>.md` per second opinion, plus the coverage audit
and the machine-readable `final.json`.

## The decomposition, and why this one

The runbook costed two and asked that the choice be deliberate and stated. **Per finding was
chosen**, not per cluster. Seven cluster-skeptics would have run 55 to 65 percent of Phase 1's cost
with a straggler in cluster E, which carries 8 of the 31 findings against B's 2. Thirty-one
per-finding skeptics is the structure that produced the Conjugar run's kill rate, and it
parallelizes flat.

Each skeptic was given its finding, the essay in both languages, and one instruction: refute. It was
told to research the underlying question itself rather than re-read Phase 1's sources, and to answer
three questions separately, because they can have three different answers. Is the sentence wrong as
written, hedges included? Is Phase 1's account of the truth correct? And is Phase 1's replacement
prose itself correct, since a finding can be right about the defect and wrong about the fix. That
third question turned out to matter: **15 of the 27 surviving findings ship with prose neither Phase 1
nor its skeptic wrote.**

One thing was added that the runbook does not specify. A **second opinion** fires whenever a skeptic
returns `refuted`, and attacks the refutation rather than the essay. It also fires on the five
findings the runbook flagged in advance as likely to fall, when the skeptic upheld them anyway. The
reasoning was the runbook's own warning that a fact-checker with a search engine and no
self-skepticism will turn a careful hedge into a confident mistake. That warning was aimed at Phase
1's researchers and applies at least as hard to an agent whose explicit instruction is to refute. In
the Conjugar run, 104 findings were killed and no kill was ever checked.

## The result, and the bias inside it

| | Phase 1 | after the skeptics | after the second opinions |
|---|---|---|---|
| factual-error | 7 | 5 | **7** |
| needs-hedging | 7 | 1 | **4** |
| nitpick | 17 | 10 | **16** |
| refuted | 0 | 15 | **4** |

The skeptics killed 15 of 31, a 48 percent rate against Conjugar's 55. The second opinions then
overturned **11 of those 15**.

**That number should not be read as "Phase 1 was mostly right after all."** Nineteen second opinions
ran. Fourteen changed the disposition. **All fourteen moved toward a stronger finding, and not one
moved toward a weaker one.** A pass that only ever pushes one direction is not measuring; the
direction was designed into it, because "attack the skeptic" applied to a kill means "restore it."

So the honest statement of what this phase established is narrower than the table looks:

- **Neither a refutation pass nor a restoration pass is self-validating.** How many findings survive
  depends substantially on which agent goes last. Three passes did not converge; they alternated.
- **This bears on the sibling run.** Conjugar's skeptic pass dismissed 104 of 188 proposals and
  nothing ever audited those kills. When this run audited its own, 11 of 15 did not survive the
  audit. That is not proof that Conjugar's kills were wrong, and the bias above is a reason to
  discount it. It is a reason to stop citing 104-of-188 as a validated result.
- **What the three passes do establish is which findings are robust.** A finding that survived
  Phase 1, a hostile skeptic, and in some cases a hostile third reading is better evidenced than
  anything the earlier runs produced. The four that died died with two agents agreeing.

Where the passes agree is where to place confidence. Measured against Phase 1 rather than against
the skeptics, the run is mostly a **regrading**: 21 of 31 findings ended at the grade Phase 1 gave
them, 8 ended weaker, 2 stronger. The severity mix barely moved. What moved is the prose, and the
reasoning behind it.

## What changed hands

Three of the four findings the runbook told me to attack first did move, which is an argument for
writing traps down in advance:

- **B12** fell from factual-error to needs-hedging. The skeptic accepted Phase 1's linguistics and
  rejected its grade, on the ground that "Romanization" as grammatical agent already signals
  replacement rather than descent.
- **R6**, the argument-from-absence about `*n̥-péh₂-tōr`, went the other way. The skeptic downgraded
  it to nitpick and the second opinion restored it to factual-error.
- **F8** was the largest single move in the run: Phase 1 filed it needs-hedging, the skeptic cut it
  to nitpick, and the second opinion raised it to **factual-error** and upheld it outright.
- **C13** is the one the runbook expected to fall that actually fell, and it fell twice. Both agents
  killed it independently, on the ground that the sentence sits under a paragraph datelined "At the
  time of the battle at Teutoburg" and Phase 1's own evidence is third-century.

C13 also produced the run's best illustration of why the third question was worth asking. Phase 1's
replacement prose would have introduced an error: "archaeology has since found roofed cult houses"
carries no date, and lands in a paragraph whose governing sentence fixes it to 9 AD.

## Disposition of all 31 findings

Every row is one finding. `2nd` marks the 19 that drew a second opinion. The last column is
what Phase 4 acts on.

| Ref | Cl | Line | Phase 1 | Skeptic | 2nd | Final | Grade |
|---|---|---|---|---|---|---|---|
| C9 | C | 140 | factual-error | upheld | yes | **upheld** | factual-error |
| D6 | D | 148 | factual-error | upheld |  | **upheld** | factual-error |
| R2c | E | 92 | factual-error | partly |  | **partly** | factual-error |
| R6 | E | 113-117 | factual-error | partly | yes | **partly** | factual-error |
| F13 | F | 169 | factual-error | partly |  | **partly** | factual-error |
| F8 | F | 164 | needs-hedging | partly | yes | **upheld** | factual-error |
| G8 | G | 180 | factual-error | partly |  | **partly** | factual-error |
| A4 | A | 126 | needs-hedging | refuted | yes | **partly** | needs-hedging |
| B12 | B | 133 | factual-error | partly | yes | **partly** | needs-hedging |
| D7 | D | 150 | needs-hedging | upheld |  | **upheld** | needs-hedging |
| E12 | E | 157 | nitpick | refuted | yes | **partly** | needs-hedging |
| A7 | A | 130 | nitpick | partly |  | **partly** | nitpick |
| R1 | A | 90 | nitpick | refuted | yes | **upheld** | nitpick |
| B7 | B | 131 | nitpick | refuted | yes | **partly** | nitpick |
| C1 | C | 136 | nitpick | refuted | yes | **partly** | nitpick |
| C10 | C | 140 | needs-hedging | refuted | yes | **partly** | nitpick |
| C12 | C | 142 | nitpick | partly |  | **partly** | nitpick |
| C2 | C | 136 | nitpick | partly |  | **partly** | nitpick |
| D12 | D | 153 | nitpick | refuted | yes | **partly** | nitpick |
| D17 | D | 155 | nitpick | refuted | yes | **partly** | nitpick |
| E1 | E | 156 | nitpick | upheld |  | **upheld** | nitpick |
| E3 | E | 156 | nitpick | refuted | yes | **partly** | nitpick |
| R2a | E | 92 | needs-hedging | partly |  | **partly** | nitpick |
| R8 | E | 121-123 | nitpick | refuted | yes | **partly** | nitpick |
| R9 | E | 125 | needs-hedging | refuted | yes | **partly** | nitpick |
| F16 | F | 171 | nitpick | upheld |  | **upheld** | nitpick |
| G4 | G | 174 | nitpick | partly |  | **partly** | nitpick |
| C13 | C | 142 | needs-hedging | refuted | yes | **refuted** | none |
| C6 | C | 138 | nitpick | refuted | yes | **refuted** | none |
| R5 | D | 110 | nitpick | refuted | yes | **refuted** | none |
| G14 | G | 187 | nitpick | refuted | yes | **refuted** | none |

## Factual errors (7)

### C9 · line 140 · German line 106 · **upheld** · Phase 1 said factual-error

> They built no stone monuments

**Skeptic.** Upheld at factual-error: I tried to kill this on the Tacitean reading, but the Gothic Wielbark culture raised stone circles up to 33 m across in continental Pomerania in the 1st and 2nd centuries AD, which closes off the narrow geographic defense that "they built no stone monuments" needed to survive.

**Second opinion.** Upheld at factual-error, but the finding stands on the essay's own southern-Scandinavian geography plus the domarringar (c. 500 BC to AD 400, straddling AD 9), not on the skeptic's Wielbark kill-shot, whose circles postdate Teutoburg by two to four generations and rest on non-peer-reviewed sources; and Phase 1's replacement, which the skeptic certified as sound, is rewritten because its positive clause is false of the Rhine-Weser interior the paragraph foregrounds.

**Replacement prose, English** (second opinion):

> They built nothing in cut stone, though standing stones and stone circles marked their graves in Scandinavia and along the Baltic.

Reports: [`verdict_C9.md`](verb_history_phase2_reports/verdict_C9.md), [`second_C9.md`](verb_history_phase2_reports/second_C9.md)

### D6 · line 148 · German line 114 · **upheld** · Phase 1 said factual-error

> The ~subjunctive and optative moods merged~ into a single Germanic subjunctive, reducing the modal options available to speakers

**Skeptic.** Line 148 states flatly that the PIE subjunctive and optative merged, but Fulk's handbook says Germanic reduced PIE's moods to three with "no subjunctive mood (since the Gmc. subjunctive reflects the PIE optative)", so the essay asserts a joint descent that never happened, in a paragraph where every neighboring sentence is a descent claim.

**Replacement prose, English** (skeptic):

> The ~optative became the single Germanic subjunctive~, taking over the jobs of the PIE subjunctive, which Germanic did not keep, and reducing the modal options available to speakers.

Reports: [`verdict_D6.md`](verb_history_phase2_reports/verdict_D6.md)

### R2c · line 92 · German line 58 · **partly** · Phase 1 said factual-error

> then, through Medieval Latin theodiscus ("of the people"), Modern German Deutsch

**Skeptic.** The Old English link is a real error and carries the factual-error grade, but Phase 1 wrongly treats the Latin-to-German routing as equally false when it is a live minority position, and its replacement prose introduces a new error by attributing the 786 theodiscus attestation to Old High German when that attestation refers to Old English.

**Replacement prose, English** (skeptic):

> it became Proto-Germanic *þeudō, which gave Old English þēod (“nation”) and, with a Germanic adjective suffix, Old High German diutisc, the ancestor of Modern German Deutsch. Latin scribes were writing the Germanic adjective as theodiscus (“of the people”) by 786, some two centuries before the German form itself is attested.

Reports: [`verdict_R2c.md`](verb_history_phase2_reports/verdict_R2c.md)

### R6 · line 113-117 · German line 83 · **partly** · Phase 1 said factual-error

> ^🐎^ ~e-grade~ (full grade): the vowel *e (as in the root *bʰer-, "to carry") / 🐄 ~o-grade~: the vowel *o (as in *bʰor-) / 🐖 ~zero-grade~: absence of the vowel (as in *bʰr-) / 🐐 ~lengthened e-grade~: *ē (as in *mḗh₁-n̥s) / 🐑 ~lengthened o-grade~: *ō (as in *n̥-péh₂-tōr)

**Skeptic.** The form *n̥-péh₂-tōr is indeed ill-formed, since the root of "father" is zero grade throughout and Greek ἀπάτωρ has short alpha, but Phase 1's core evidentiary claim is false: the string is printed verbatim in the PIE column of English Wikipedia's "Indo-European ablaut" table, which is plainly the essay's source, so this is a copied tertiary slip in an unglossed ornamental example, worth fixing at nitpick weight rather than factual-error.

**Second opinion.** The runbook's suspicion was right about the diagnosis and the skeptic's attack was soft on the grade: Wikipedia does print *n̥-péh₂-tōr verbatim, so Phase 1 was wrong that the essayist invented it, but that is a provenance fact and the skeptic used it as a severity fact; Ringe 2006 confirms the root of "father" is *ph₂- in every case form, and the spurious *é sits under the acute accent that bullet four has just taught the reader to read as the graded vowel, so the error is in the marked syllable rather than an unattended one. Grade restored to factual-error at low consequence; the skeptic's replacement prose is adopted unchanged.

**Replacement prose, English** (second opinion):

> 🐑 ~lengthened o-grade~: *ō (as in *bʰōr, "thief", from *bʰer-)

Reports: [`verdict_R6.md`](verb_history_phase2_reports/verdict_R6.md), [`second_R6.md`](verb_history_phase2_reports/second_R6.md)

### F13 · line 169 · German line 135 · **partly** · Phase 1 said factual-error

> These include the modal verbs ~können~ (can), ~müssen~ (must), ~dürfen~ (may), ~sollen~ (shall), ~mögen~ (may/like), and ~wissen~ (to know)

**Skeptic.** The diagnosis and factual-error grade are upheld, since the essay flatly calls wissen a modal verb and IDS grammis and Duden both put it outside the modal class as the preterite-presents' one Vollverb, but Phase 1's fix needs revision because its added wollen sentence sits immediately before a paragraph whose subject is "these verbs" and whose explanation is false of wollen.

**Replacement prose, English** (skeptic):

> These include the modal verbs ~können~ (can), ~müssen~ (must), ~dürfen~ (may), ~sollen~ (shall), and ~mögen~ (may/like), together with ~wissen~ (to know), which shares their history but is a full verb, not a modal.

Reports: [`verdict_F13.md`](verb_history_phase2_reports/verdict_F13.md)

### F8 · line 164 · German line 130 · **upheld** · Phase 1 said needs-hedging

> Beginning in Middle High German, the verb ~werden~ (to become) was grammaticalized as a future auxiliary

**Skeptic.** The sentence's "Beginning in Middle High German" is an onset claim and is correct under every account of the werden future, so the real defect is only that the essay never supplies the Early New High German terminus, which is an omission rather than an unhedged contested claim, and Phase 1's fix introduces Early New High German with no dates and overshoots with "a true future auxiliary".

**Second opinion.** The skeptic's case rests on "Beginning in Middle High German is correct under every account", which Paul's Mittelhochdeutsche Grammatik refutes by dating werden + INF to the second half of the 14th century while Concu dates it to Old High German; the skeptic also stopped reading four lines short of line 168's "This created a three-way temporal system", and graded the finding "nitpick" (defined as misleading nobody) in the same paragraph where it conceded the reader is misdirected by two centuries, so the finding is restored and escalated to factual-error because werden + infinitive was very rare in MHG, futurity there was carried by the simple present and by sol/wil/muoz, the construction was only firmly established by the sixteenth century, and neither localization names Early New High German anywhere or dates any period past 1350.

**Replacement prose, English** (second opinion):

> Beginning in Middle High German, the verb ~werden~ (to become) was paired with an infinitive, though the construction stayed rare there beside the simple present and periphrases with ~sollen~ and ~wollen~; only in Early New High German (1350–1650) was ~werden~ grammaticalized as the regular future auxiliary, a change that culminated in the sixteenth century:

Reports: [`verdict_F8.md`](verb_history_phase2_reports/verdict_F8.md), [`second_F8.md`](verb_history_phase2_reports/second_F8.md)

### G8 · line 180 · German line 146 · **partly** · Phase 1 said factual-error

> ~Aspect~ is expressed periphrastically (er $lIest$ = he reads/is reading)

**Skeptic.** The bullet's sole illustration of "periphrastically" is er liest, a single synthetic form containing no periphrasis, so the defect is real, but Phase 1's second charge, that the sentence implies a grammaticalized aspect category German lacks, does not survive, since the sentence never claims grammaticalization, its prefix clause is correct, and line 144 has already told the reader Germanic abandoned aspect.

**Replacement prose, English** (Phase 1, certified unchanged):

> 🇩🇪 ~Aspect~ is carried by context (er $lIest$ = he reads/is reading), by the colloquial ~am~-progressive (er ist am Lesen = he is reading), or by verbal prefixes and particles (er $lIest$ das Buch aus = he finishes reading the book)

Reports: [`verdict_G8.md`](verb_history_phase2_reports/verdict_G8.md)

## Needs hedging (4)

### A4 · line 126 · German line 92 · **partly** · Phase 1 said needs-hedging

> Equipped with horses, wheeled carts, and perhaps bronze weapons, they moved westward in successive waves

**Skeptic.** Line 126 asserts only that the Yamnaya had horses, which is uncontested on both sides of the riding debate, the riding question is already hedged at line 86, and Phase 1's evidentiary base (Librado 2021's rejection) was rebutted point by point in Science Advances in May 2026 by Anthony, Trautmann and Heyd, whose abstract states that Yamnaya groups rode DOM2 horses.

**Second opinion.** Finding restored at needs-hedging with new prose: the skeptic litigated Librado 2021's abstract, whose body says "Yamnaya pastoralism did not spread horses far outside their native range," and the 2026 rebuttal it relied on defends the migration only as "compatible with the spread of DOM2-clade horses," so no live camp establishes the flat claim at line 126, though the skeptic was right that Phase 1's replacement prose was itself an unhedged claim in the opposite direction.

**Replacement prose, English** (second opinion):

> Equipped with ox-drawn carts and perhaps with bronze weapons and horses of their own, they moved westward in successive waves.

Reports: [`verdict_A4.md`](verb_history_phase2_reports/verdict_A4.md), [`second_A4.md`](verb_history_phase2_reports/second_A4.md)

### B12 · line 133 · German line 99 · **partly** · Phase 1 said factual-error

> the Germanic languages developed free from the Romanization that transformed Gaulish into French, Iberian languages into Spanish and Portuguese, and Dacian into Romanian

**Skeptic.** Phase 1's linguistics is right but its grade is not: "Romanization" as grammatical agent already signals replacement rather than descent, and the next sentence names Vulgar Latin adoption explicitly, so the surviving defect is only the ambiguous "Iberian languages" phrase, which Phase 1's own replacement fails to fix.

**Second opinion.** The skeptic's core argument, that an external agent on "transformed" signals replacement rather than descent, is refuted by the essay's own line 156 ("This series of sound changes transformed voiceless stops into fricatives"), which uses the identical frame to mean continuity; and both prior agents flattened the three legs without checking the Dacian one, where two handbooks (Cambridge History of the Romance Languages 2013 p. 287, Oxford Guide 2016 p. 91) decline to say where Daco-Romance formed, so the sentence states as settled what the field calls unresolved: needs-hedging, fixed by naming regions and putting Latin where the descent starts.

**Replacement prose, English** (second opinion):

> This had profound linguistic consequences: the Germanic languages developed free from the Romanization that replaced the languages of Gaul, Iberia, and the Danube provinces with the Latin that became French, Spanish, Portuguese, and Romanian.

Reports: [`verdict_B12.md`](verb_history_phase2_reports/verdict_B12.md), [`second_B12.md`](verb_history_phase2_reports/second_B12.md)

### D7 · line 150 · German line 116 · **upheld** · Phase 1 said needs-hedging

> The ~augment~ (*e-), which had marked past tense in PIE, was lost entirely in Germanic

**Skeptic.** Line 150 asserts flatly that the augment marked past tense in PIE and was lost in Germanic, but Lehmann's Grammar of Proto-Germanic treats the augment as a common innovation of Indo-Iranian, Greek and Armenian that Germanic never had, and Willi 2018 argues it was not a past marker even at the PIE stage, so the sentence states a live question as settled and contradicts the essay's own hedge at line 102.

**Replacement prose, English** (Phase 1, certified unchanged):

> The ~augment~ (*e-), the past-tense prefix of a few branches, left no trace at all in Germanic.

Reports: [`verdict_D7.md`](verb_history_phase2_reports/verdict_D7.md)

### E12 · line 157 · German line 123 · **partly** · Phase 1 said nitpick

> Today, German strong verbs must largely be memorized individually, their ablaut patterns, while still systematic, are no longer predictable from the infinitive.

**Skeptic.** The essay's sentence is a near-paraphrase of Mailhammer 2007 in Morphology, whose abstract says the German strong verbs became "inflection classes whose predictability is no longer based on the citation form" while "remnants of the old system keep them together as a group," which is exactly the essay's "no longer predictable from the infinitive" plus "while still systematic."

**Second opinion.** The skeptic demolished Phase 1's bad evidence correctly but then treated one side of a live specialist disagreement as settled consensus: Wiese 2008 (IDS Mannheim, Benjamins CILT 285), which neither prior agent found, concludes that "for the majority of strong verbs, membership in these classes (and thus ablaut) is predictable," directly negating the essay's flat "no longer predictable from the infinitive" at the same scope, so the finding is restored and regraded from nitpick to needs-hedging with new prose.

**Replacement prose, English** (second opinion):

> Today, German strong verbs must largely be memorized individually. No infinitive reveals whether a verb is strong at all, and among those that are, the shape of the stem still points to an ablaut pattern in most cases without settling it.

Reports: [`verdict_E12.md`](verb_history_phase2_reports/verdict_E12.md), [`second_E12.md`](verb_history_phase2_reports/second_E12.md)

## Nitpicks (16)

### A7 · line 130 · German line 96 · **partly** · Phase 1 said nitpick

> By the first millennium BC, a recognizable Proto-Germanic language had emerged

**Skeptic.** The ambiguity of "By the first millennium BC" is real and worth one phrase, but Phase 1's supporting claims fail: the German carries the same ambiguity rather than resolving it early, and "nothing recognizable as Proto-Germanic is reconstructed for 1000 BC" is false, since Lehmann dates PGmc from c. 2500 BC and Euler and Badenheuer reconstruct the Bronze Age stage.

**Replacement prose, English** (skeptic):

> By the second half of the first millennium BC, a recognizable Proto-Germanic language had emerged in southern Scandinavia and along the North Sea and Baltic coasts.

Reports: [`verdict_A7.md`](verb_history_phase2_reports/verdict_A7.md)

### R1 · line 90 · German line 56 · **upheld** · Phase 1 said nitpick

> These languages include German, English, Ukrainian, Hindi, Persian, Cornish, Greek, and Latin

**Skeptic.** The essay is fine as written: "spoken by nearly half of humans alive today" is a collective property no single language satisfies, so "These languages" necessarily denotes the Indo-European family rather than a roster of living languages, and even on Phase 1's stricter parse nothing false is said about Latin, which Ethnologue and the Holy See both record as still in restricted use.

**Second opinion.** Kill reversed: the skeptic's core argument, that a non-distributing measure phrase forces a family reading, confuses cumulative with collective predication (cumulativity pools the headcount but keeps "spoken" true of each member), and its Ethnologue fallback is overridden by SIL's own ISO 639-3 registry, which types Latin "Historical" and defines Living by a first-language criterion; since the essay's "nearly half" figure is an L1 count over ~445 living Indo-European languages, Latin is excluded from the set by the essay's own arithmetic, so the finding stands at nitpick with new prose replacing only the second sentence.

**Replacement prose, English** (second opinion):

> The Indo-European family includes German, English, Ukrainian, Hindi, Persian, Cornish, Greek, and Latin.

Reports: [`verdict_R1.md`](verb_history_phase2_reports/verdict_R1.md), [`second_R1.md`](verb_history_phase2_reports/second_R1.md)

### B7 · line 131 · German line 97 · **partly** · Phase 1 said nitpick

> an alliance of Germanic tribes led by Arminius (Hermann)

**Skeptic.** "Arminius (Hermann)" is a true alternate-name gloss that asserts nothing about etymology, and the essay's own parenthetical convention eleven lines later (Wōðanaz (later Wōden), Þunaraz (Thunor and Þórr)) puts the older form first and the later reflex in the parenthesis, which is exactly the right chronology here.

**Second opinion.** Kill overturned: the skeptic was right that "Arminius (Hermann)" asserts nothing false, but its two supporting arguments both beg the question, so the finding is restored as a nitpick with new, cheaper prose.

**Replacement prose, English** (second opinion):

> Three Roman legions under the command of Publius Quinctilius Varus (perhaps 20,000 soldiers) were ambushed and annihilated by an alliance of Germanic tribes led by Arminius (known to later Germans as Hermann), a Romanized chieftain of the Cherusci.

Reports: [`verdict_B7.md`](verb_history_phase2_reports/verdict_B7.md), [`second_B7.md`](verb_history_phase2_reports/second_B7.md)

### C10 · line 140 · German line 106 · **partly** · Phase 1 said needs-hedging

> they did develop the runic alphabet for short inscriptions and magical purposes

**Skeptic.** Both halves of C10 fail against the standard handbooks: Düwel dates the emergence of runic writing to "at the latest in the course of the 1st century AD" (distinct from the c. 200 date of the oldest surviving monuments), so the essay's undated concessive clause is not misplaced at Teutoburg, and Nedoma states that runes served both profane communication and communication with the supernatural sphere, so "magical purposes" is handbook doctrine rather than a walked-back older strand.

**Second opinion.** The skeptic killed the magic half correctly and I confirm that, but its chronology defense rests on "the essay asserts no date," which is true only of the English concessive: the German ships a pluperfect ("entwickelt hatten") inside a frame explicitly anchored at 9 AD, flatly placing the runic alphabet before Teutoburg, which no handbook affirms (Nedoma's chronology section gives no creation date and starts at c. 150 AD, Barnes says there is little certainty, and the skeptic's Svingerud 50 BC plank misapplies a grave's radiocarbon range to a carving), so the finding survives as a two-word German repair using the essay's own "sollten" narrative future rather than Phase 1's rejected prose.

**Replacement prose, English** (second opinion):

> They committed little to writing, though they would develop the runic alphabet for short inscriptions and magical purposes.

Reports: [`verdict_C10.md`](verb_history_phase2_reports/verdict_C10.md), [`second_C10.md`](verb_history_phase2_reports/second_C10.md)

### C1 · line 136 · German line 102 · **partly** · Phase 1 said nitpick

> lived in small villages and farmsteads scattered through the forests of northern Europe

**Skeptic.** Roberts et al. 2018 names north central Europe as the region where "the majority of forests remained intact until Mediaeval times" (still ~60% forest cover at 550-750 CE), so the essay's forest matrix at 9 AD is archaeology, not Tacitean scene-setting, and Phase 1's "settled zones were largely open" holds only for the Danish and coastal fringe Roberts explicitly separates out.

**Second opinion.** The skeptic's whole case is one number, Roberts et al.'s ~60% forest cover, and the paper says that figure is "for the same area" as Schlüter's Atlas Östliches Mitteleuropa, eastern Central Europe, while the same paper's next sentence puts north western Europe and the coasts of southern Scandinavia in the already-cleared bucket, which is precisely where the essay itself locates the Germanic peoples six lines earlier, so the finding is restored at nitpick with a two-word fix.

**Replacement prose, English** (second opinion):

> At the time of the battle at Teutoburg, the Germanic peoples lived in small villages and farmsteads scattered through the forests and cleared fields of northern Europe.

Reports: [`verdict_C1.md`](verb_history_phase2_reports/verdict_C1.md), [`second_C1.md`](verb_history_phase2_reports/second_C1.md)

### C12 · line 142 · German line 108 · **partly** · Phase 1 said nitpick

> Wōðanaz (later Wōden (Old English) and Óðinn (Old Norse)), Þunaraz (Thunor and Þórr), Tīwaz (Tiw and Týr)

**Skeptic.** The missing asterisks on the three reconstructed theonyms are a real but harmless internal inconsistency (nitpick, as Phase 1 graded it), while the labelling half of the complaint fails because Phase 1's own replacement leaves it unfixed, and that replacement also strands the participle "worshipped", silently swaps Þunaraz for Þunraz, and makes the header's "twenty asterisks" stale.

**Replacement prose, English** (skeptic):

> Their religion centered on a pantheon of gods (*Wōðanaz, later Wōden in Old English and Óðinn in Old Norse; *Þunaraz, later Thunor and Þórr; *Tīwaz, later Tiw and Týr; and others) worshipped in sacred groves rather than temples.

Reports: [`verdict_C12.md`](verb_history_phase2_reports/verdict_C12.md)

### C2 · line 136 · German line 102 · **partly** · Phase 1 said nitpick

> growing barley, oats, rye, and wheat

**Skeptic.** Phase 1's archaeobotany is right (barley dominant, rye still mostly a weed at 9 AD) but its reading of the sentence overstates the harm and its replacement adds a comma-fenced aside the house style bans, so the survivor is a two-word fix, not a clause.

**Replacement prose, English** (skeptic):

> They practiced mixed agriculture, growing barley above all, along with oats, wheat, and some rye, while raising cattle, pigs, sheep, and horses.

Reports: [`verdict_C2.md`](verb_history_phase2_reports/verdict_C2.md)

### D12 · line 153 · German line 119 · **partly** · Phase 1 said nitpick

> and the "-ed" ending in English ($mAde$, $saId$, played)

**Skeptic.** The sentence asserts an origin, not a spelling, and all three examples end in the same suffixal /d/, so nothing false is said; the essay's own red markup already flags made and said as irregular, and Phase 1's replacement makes things worse by saying the dental suffix "worn down" in exactly the two words where it survives intact.

**Second opinion.** The skeptic is right that the prose asserts an origin rather than a spelling and that Phase 1's rewrite is worse, but it leaned its third argument on markup it wrongly believed nobody had questioned: $mAde$ reddens a letter that did not change, so the finding survives as a one-character span fix ($maDe$) belonging with H13 in Phase 3.

**Replacement prose, English** (second opinion):

> This is the origin of the "-te" ending in German preterites (machte, sagte, spielte) and the "-ed" ending in English ($maDe$, $saId$, played).

Reports: [`verdict_D12.md`](verb_history_phase2_reports/verdict_D12.md), [`second_D12.md`](verb_history_phase2_reports/second_D12.md)

### D17 · line 155 · German line 121 · **partly** · Phase 1 said nitpick

> Speakers of Modern English are aware that the conjugation later became "crowed"

**Skeptic.** The essay never claims speakers recognize "crew" as a preterite nor that "crew" is extinct, so both legs of D17 attack propositions the sentence does not make, and the only fact it conveys, that Modern English says "crowed", is true.

**Second opinion.** The skeptic killed leg two correctly and was right to reject Phase 1's prose, but its refutation of leg one deletes the words "later became" from the sentence it is defending, and its register-marker defense depends on the reader being an English speaker, which the German localization's reader is not; restore as a nitpick with new prose.

**Replacement prose, English** (second opinion):

> The strong preterite later gave way to the weak "crowed".

Reports: [`verdict_D17.md`](verb_history_phase2_reports/verdict_D17.md), [`second_D17.md`](verb_history_phase2_reports/second_D17.md)

### R2a · line 92 · German line 58 · **partly** · Phase 1 said needs-hedging

> Linguists reconstruct PIE *tewtéh₂, from the root *tew- ("to swell, be strong"), as a word meaning "the full community" or simply "the people"

**Skeptic.** The derivation of *tewtéh₂ from the swelling root is genuinely disputed by Beekes 1998, but Beekes himself opens by conceding it "is generally accepted", and Delamarre and Meini rejected his attack in print, so the essay represents the consensus correctly and the defect shrinks to a specialist quibble worth a two-word softening.

**Replacement prose, English** (skeptic):

> Linguists reconstruct PIE *tewtéh₂ as a word meaning “the full community” or simply “the people”, and usually trace it to the root *tew- (“to swell, be strong”).

Reports: [`verdict_R2a.md`](verb_history_phase2_reports/verdict_R2a.md)

### R9 · line 125 · German line 91 · **partly** · Phase 1 said needs-hedging

> These vowel changes are direct inheritances from Proto-Indo-European, preserved across five millennia of linguistic evolution.

**Skeptic.** The finding misreads "these vowel changes" as "these vowels" when its antecedent is the previous sentence's "the vowel alternations we still see in German strong verbs today," so the essay already claims exactly what Phase 1 says is true, and "direct inheritance" is a term whose contrast is borrowing, not sound change.

**Second opinion.** The skeptic correctly showed "these vowel changes" refers to the alternations and that "inherited" does not imply phonetic identity, but it defended "inherited" and let "preserved" ride in free: "preserved across five millennia of linguistic evolution" is concessive in favor of stasis, and the three-slot alternation printed above it is a New High German reduction of the four-slot Old High German paradigm (ahd. sang vs. sungum), so the paragraph corrects the vowel-quality overstatement but never the pattern-continuity one.

**Replacement prose, English** (second opinion):

> These vowel changes descend from Proto-Indo-European ablaut, carried across five millennia by sound change and analogy rather than preserved unchanged.

Reports: [`verdict_R9.md`](verb_history_phase2_reports/verdict_R9.md), [`second_R9.md`](verb_history_phase2_reports/second_R9.md)

### E1 · line 156 · German line 122 · **upheld** · Phase 1 said nitpick

> The Germanic dialects spoken in what is now southern Germany and Switzerland developed into Old High German (roughly 750–1050 AD)

**Skeptic.** Upheld at nitpick: Old High German's territory is defined by participation in the second sound shift and comprises Franconian (Fulda, Mainz, Trier, Cologne) alongside Alemannic and Bavarian, so "southern Germany and Switzerland" omits the band that produced most of the corpus and leaves the paragraph's own Kölsch example with nowhere to sit, though the sentence states no falsehood and no verb fact depends on it.

**Replacement prose, English** (Phase 1, certified unchanged):

> The Germanic dialects spoken in what is now southern and central Germany, Austria, and Switzerland developed into Old High German (roughly 750–1050 AD), distinguished from other Germanic languages by the ~High German consonant shift~.

Reports: [`verdict_E1.md`](verb_history_phase2_reports/verdict_E1.md)

### E3 · line 156 · German line 122 · **partly** · Phase 1 said nitpick

> This series of sound changes transformed voiceless stops into fricatives or affricates (p → pf or ff; t → ts or s; k → ch)

**Skeptic.** Line 156's sentence is scoped to voiceless stops and is accurate and complete within that scope, so omitting the Medienverschiebung is an enrichment opportunity rather than a defect, and Phase 1 concedes in its own second line that nothing in the sentence is false.

**Second opinion.** The finding is restored at nitpick but on a different basis: Braune's Old High German grammar shows Phase 1's stated rationale is backwards (p and t shift across the whole High German area, d > t only in Upper German and East Franconian, so the voiced-stop phase is one of the shift's less widespread parts, not its most widespread), and the skeptic rescued that false claim with a lenition story the same grammar contradicts instead of striking it; what survives is that the essay defines the named shift more narrowly than the handbook does with no hedge marking the narrowing, and the omitted phase is the one that turned Old High German -ta against Old Saxon -da, i.e. the change that gave the German weak preterite the -te the essay introduced two paragraphs earlier, which makes it a gap the essay's own argument opens rather than generic enrichment.

**Replacement prose, English** (second opinion):

> A later stage of the same shift turned Germanic d into t across much of the High German area. It is why ~machen~ builds its preterite as ~machte~ where English ~played~ keeps the older d, and why *dō- itself is ~tun~ in modern German.

Reports: [`verdict_E3.md`](verb_history_phase2_reports/verdict_E3.md), [`second_E3.md`](verb_history_phase2_reports/second_E3.md)

### R8 · line 121-123 · German line 88 · **partly** · Phase 1 said nitpick

> 🇩🇪 singen, $sAng$, $gesUngen$ (sing, $sAng$, $sUng$) / 🇩🇪 nehmen, $nahm$, $genOMmen$ (take, $tOOk$, taken) / 🇩🇪 geben, $gAb$, gegeben (give, $gAve$, given)

**Skeptic.** Phase 1's etymology is correct but its reading of the essay is not: parenthesized English after a German bullet is a translation throughout this essay, most decisively at line 153 where spielte is glossed played, so line 122 never asserts the cognate parallel the finding faults it for.

**Second opinion.** The skeptic is right that the parenthesis is a translation slot and that nothing false is asserted, but it reached that conclusion on a mis-parsed example (line 153's English list glosses the English ending, not the German words) and propped it up with a false equivalence (give is a native lexeme with a Norse-influenced consonant, not a Norse loan like take), so the grade drops only to nitpick, not none; separately, mechanical extraction shows $nahm$ is the sole one of 57 marked forms across both localizations with no uppercase letter, so the row's preterite renders with nothing red between $sAng$ above and $gAb$ below, which Phase 4 should fix at four sites whatever it decides about the cognate question.

**Replacement prose, English** (second opinion):

> Minimal fix, recommended, at docs/verb_history.txt line 122, docs/verb_history_de.txt line 88, and Localizable.xcstrings lines 3072 and 3078: "🇩🇪 nehmen, $nAhm$, $genOMmen$ (take, $tOOk$, taken)". Optional row swap if the cognate parallel is wanted, same lines: "🇩🇪 brechen, $brAch$, $gebrOchen$ (break, $brOke$, $brOken$)".

Reports: [`verdict_R8.md`](verb_history_phase2_reports/verdict_R8.md), [`second_R8.md`](verb_history_phase2_reports/second_R8.md)

### F16 · line 171 · German line 137 · **upheld** · Phase 1 said nitpick

> and vowel differences between singular and plural (ich $kAnN$ vs. wir können)

**Skeptic.** Line 171 attributes singular/plural vowel alternation to an explicitly enumerated set of six preterite-presents, and sollen has none, a real but low-cost imprecision that Phase 1 graded correctly and fixed correctly.

**Replacement prose, English** (Phase 1, certified unchanged):

> and vowel differences between singular and plural in all of them but ~sollen~ (ich $kAnN$ vs. wir können)

Reports: [`verdict_F16.md`](verb_history_phase2_reports/verdict_F16.md)

### G4 · line 174 · German line 140 · **partly** · Phase 1 said nitpick

> 🇩🇪 Old: Wenn ich $kÄme$... (If I $cAme$...)

**Skeptic.** The mislabel is real and nitpick is the right grade, but Phase 1's Duden citation does not check out on the page it names and its fix repairs only one label of a two-label contrast, leaving "Synthetic" opposite "Modern alternative".

**Replacement prose, English** (skeptic):

> 🇩🇪 Synthetic: Wenn ich $kÄme$... (If I $cAme$...)
🇩🇪 Periphrastic: Wenn ich kommen $wÜrde$... (If I $wOUld$ come...)

Reports: [`verdict_G4.md`](verb_history_phase2_reports/verdict_G4.md)

## Refuted (4)

Phase 1 proposed these and they did not survive three passes. Recorded so a future run
does not rediscover them and pay for them twice.

### C13 · line 142 · German line 108 · **refuted** · Phase 1 said needs-hedging

> worshipped in sacred groves rather than temples

**Skeptic.** The sentence is governed by the section's opening "At the time of the battle at Teutoburg," and for the early first century the open-air, building-less cult picture is the archaeological mainstream, while the finding's cult houses are two to eight centuries later by its own admission and its one contemporaneous item, Tacitus's templum Tanfanae, turns on a Latin word that means consecrated precinct before it means building.

**Second opinion.** Kill confirmed: the sentence is scoped by the paragraph's "At the time of the battle at Teutoburg" dateline, and every roofed Germanic cult building anyone can cite (Gudme c. AD 200, Uppåkra, Sorte Muld, and even the temple-like structure at Oberdorla in Germania Magna) postdates that moment by two centuries or more, with specialists reading the type as a Roman-contact innovation, so the exclusion is the period's archaeological mainstream and not merely Tacitus's rhetoric; the skeptic's Lewis-and-Short sense-order argument is a bad route to a right conclusion and its Oberdorla quotation does not appear in the source it cites, but neither defect touches the outcome, and Phase 1's replacement prose would have imported an undated "archaeology has since found roofed cult houses" into a Teutoburg-datelined paragraph, shipping the very anachronism the finding disclaimed.

Reports: [`verdict_C13.md`](verb_history_phase2_reports/verdict_C13.md), [`second_C13.md`](verb_history_phase2_reports/second_C13.md)

### C6 · line 138 · German line 104 · **refuted** · Phase 1 said nitpick

> The warrior aristocracy formed a ~comitatus~, a band of followers bound to their lord by oaths of loyalty

**Skeptic.** Germania 14 calls the comitatus bond "praecipuum sacramentum", the Roman word for the oath of allegiance, so the essay's "oaths of loyalty" tracks Tacitus rather than contradicting him, and the essay's ~…~ span demonstrably marks outsiders' terms (~Germani~, ~limes~, ~kurgans~), not self-designations.

**Second opinion.** Kill confirmed: Perseus shows Germania 14's shame clause and "praecipuum sacramentum est" are one colon-divided sentence, so Phase 1's core charge denies a clause its own chapter contains and the essay's "oaths of loyalty" tracks its source; but the skeptic's supporting argument that the essay's ~…~ span "marks outsiders' terms" is false against all 59 spans (~Pfund~, ~haben~, ~können~ are native), the span is provenance-neutral, and the skeptic's own catch on German line 104, "eine ~comitatus~" for a Latin masculine, was wrongly punted to a nonexistent later pass and should be fixed to "einen".

Reports: [`verdict_C6.md`](verb_history_phase2_reports/verdict_C6.md), [`second_C6.md`](verb_history_phase2_reports/second_C6.md)

### R5 · line 110 · German line 76 · **refuted** · Phase 1 said nitpick

> ~Voice~ distinguished active and middle (the latter indicating action affecting the subject or done in the subject's interest), with a developing passive

**Skeptic.** "With a developing passive" is itself the hedge and matches the mainstream account that passive function was emerging from the middle in late PIE, so the essay is fine as written and Phase 1's "independent later creations rather than a shared inheritance in progress" overstates the truth.

**Second opinion.** Kill confirmed: the literature itself places a passive "developing" out of the middle at a late stage of PIE, so the essay's four-word coda compresses the handbooks rather than overreaching them, while Phase 1's own summary ("independent later creations rather than a shared inheritance in progress") denies a PIE passive function that Kulikov and Lavidas and Grestenberger both reconstruct.

Reports: [`verdict_R5.md`](verb_history_phase2_reports/verdict_R5.md), [`second_R5.md`](verb_history_phase2_reports/second_R5.md)

### G14 · line 187 · German line 153 · **refuted** · Phase 1 said nitpick

> that primordial cloud of supernova-enriched gas from which the Solar System was born

**Skeptic.** "Supernova-enriched gas" is a true, non-exclusive claim about the presolar cloud, it is not the same epithet Conjugar's pass adjudicated (that one attributed the elements themselves, including gold and uranium, to supernovae), and line 80 still names supernovae among the enrichers, so nothing in the essay disagrees with line 187.

**Second opinion.** Kill confirmed at grade none, but on a better argument than the skeptic's: line 80 already gives supernovae "the rest," i.e. the larger share of the enrichment, so line 187's compression follows the essay's own apportionment rather than contradicting it, and specialists publish under the phrase "supernova-enriched" for this exact cloud; the skeptic's 60Fe argument is overstated and should not be reused.

Reports: [`verdict_G14.md`](verb_history_phase2_reports/verdict_G14.md), [`second_G14.md`](verb_history_phase2_reports/second_G14.md)

## Agent H's 19 items, carried through unchanged

These did not go to the skeptic fleet, and the runbook is right about why: they are
internal-consistency observations produced with no web access, research cannot settle them, and most
are a choice about which of two sentences gives way, which is Josh's call rather than a fact
question. They are in [`docs/verb_history_phase1.md`](verb_history_phase1.md) under
`## Agent H: internal consistency`, and nothing in Phase 2 touched them. Routing:

| Item | Goes to |
|---|---|
| H11, H13 | **Phase 3.** Both turn on `$…$` span values, which Phase 3 checks against the app's own conjugation output |
| H14 | **Josh.** Same question in prose rather than markup: whether the essay should explain its own red letters |
| the other 16 | **Phase 4**, as their own section of the corrections document |

Three are worth naming here because they are the ones a reader would notice.

- **H3** is this essay's closest analogue to the *poder* / *puedo* seam that the Conjugar run's
  fan-out structurally could not find. Line 92 derives "the word German" from the steppe autonym
  `*tewtéh₂`; line 130 supplies its actual source, Latin *Germani*. The German localization does not
  have the problem, because it names *deutsch*, which is the word the chain actually derives. So it
  is a contradiction in exactly one of the two shipped languages, and the translator resolved it
  correctly and invisibly.
- **H5** has the essay failing its own definition. Line 146 defines periphrasis as combinations of
  auxiliary verbs with main verbs; line 180 then offers *er liest*, a synthetic finite form with no
  auxiliary, as its headline example of periphrasis.
- **H6** partly overturns Phase 0's conclusion that the promise-versus-delivery trap is empty. It is
  empty in the form Conjugar had it, since Konjugieren's opening makes no learner-memorization
  promise. It exists inverted: the shared half promises preservation and system, the German-specific
  half delivers erosion and class blurring and individual memorization, and the closing at line 185
  reverts to "survive" and "living fossil" without carrying a word of that forward.

Agent H also found two things that are bookkeeping rather than criticism, and both are settled: the
27 `$…$` spans are byte-identical between the two languages in the same order, and every numeric
value matches across both surfaces.

## Coverage

The auditor ran with no web access and no authority to open questions of fact. Full report:
[`coverage_audit.md`](verb_history_phase2_reports/coverage_audit.md).

**The partition held, and it is now settled rather than sampled.** All 111 inventory rows appear
exactly once. None appears in both the findings and the confirmed set, none was reported that the
inventory does not contain, and no cluster reported outside its own territory. Grade-sums match row
counts in all seven clusters and in the totals.

**The line numbers are now audited rather than spot-checked.** Every row's quoted fragment was
matched against the text at its cited line, normalizing whitespace, the five markup characters,
asterisks, curly against straight quotes, en dash against hyphen, and the emoji bullets. **All 111
verify.** Phase 1's nine shared-half corrections are confirmed in place, and Phase 0's patch table is
now correct throughout.

The auditor also caught a defect in the shape of Phase 1's own coverage table: its **Rows** and
**Verdicts** columns are equal by construction and can never disagree, so their agreement is not
evidence. The check that can fail is grade-sum against row count.

**Seven of the eighty confirmed rows have reasoning that does not carry the verdict.** Four are worth
reopening. None was researched, and none is a predicted error; these are judgements about the audit
trail.

| Row | Line | Why |
|---|---|---|
| G16 | 187 | "fifty centuries" confirmed only against the essay's own internal consistency, and one of the four corroborating occurrences has no inventory row at all |
| D1 | 143 | "some two millennia", and the single source is disclaimed in its own annotation as not assigning the interval, and the row's arithmetic yields 1,500 to 2,000 years |
| C8 | 140 | the cities half is uncited; the states half confirms a universal by noting that standard accounts call Maroboduus an exception, at the paragraph's own date |
| C7 | 138 | confirms "gold" while its own evidence establishes "treasure", with the archaeological dating sourced to grokipedia.com |

Note-only: C11, E7, G13.

One structural observation, which is a property of the inventory rather than anyone's conduct. **The
five-millennia figure has four occurrences and three owners**: R9 at line 125 in cluster E, G13 at
185 and G16 at 187 in cluster G, and line 92, which has no inventory row at all. G13 and G16 partly
corroborate themselves by pointing at each other and at line 92, so three rows lean on one another
around a single external date. Whoever settles one of these must settle all four, and one of the four
is not in the inventory. Partitioning by claim prevents duplicated research; it does not prevent a
claim from being distributed across cells that cite each other.

## What a future session should not trust

1. **Phase 1's "byte-identical to what Phase 0 left" is stale.** `docs/verb_history_de.txt` carries
   the 58-to-59 tilde-span header correction, and `verb_history_claims.md` and
   `verb_history_phase0.md` carry the line-number corrections. The essay itself and the catalog are
   untouched, so nothing shipped changed, but a session that discards those working-tree edits
   silently restores the stale count of 58.
2. **This document's `finalVerdict` field had one ambiguity, now corrected in `final.json`.** For a
   second opinion, "upheld" can mean the finding is upheld or the skeptic's kill is upheld. C13's
   agent meant the second. The disambiguating field is `skepticHolds`, and the corrected count is
   **11 of 15 kills overturned, not 12**, which is what the workflow's own progress log reported.
   A schema whose enum reads differently depending on which agent fills it in is a schema defect;
   a future run should name the field for the finding's disposition explicitly.
3. **The second-opinion pass is directionally biased** and its output should not be read as a neutral
   adjudication. See "The result, and the bias inside it" above.
4. **The inventory's own reconciliation table is still blank** at
   `docs/verb_history_claims.md` lines 339 to 348, while the prose above it already asserts the
   totals. The numbers that belong in it are in the coverage audit.

## What Phase 4 inherits

- 27 surviving findings with English replacement prose, above. **German prose is not written**, by
  design: Phase 1 deferred it because roughly half the findings were expected to fall, and 4 did.
  Every survivor's German counterpart line is cited so Phase 4 knows what it is translating against.
- Agent H's 16 non-routed items.
- Four confirmed rows worth reopening on reasoning, which are not findings and should not be
  presented as though they were.
- The coverage numbers for the inventory's empty reconciliation table.

Phase 3, the app-internal agent, is untouched by all of this and can run independently. It owns
H11 and H13, and it owns the more than fifty `$…$` spans that no phase so far has checked against
the app's own conjugation output.
