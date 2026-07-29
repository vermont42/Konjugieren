# Corrections to "A History of the German Verb System"

This is the deliverable of the fact-check described in
[`prompts/verify-verb-history.md`](../prompts/verify-verb-history.md). It merges four finished
inputs into one document: the 27 findings that survived Phase 2's adversarial verification, agent
H's internal-consistency items, Phase 3's check of the essay against Konjugieren's own conjugator,
and the coverage audit's list of confirmed rows whose reasoning does not carry their verdict.

## Status: applied 2026-07-29

**Josh reviewed this document and directed that it be applied.** All 7 factual errors, all 4
hedges, all 16 nitpicks, all 9 span occurrences, and 11 of the 16 internal-consistency items are
now in `docs/verb_history.txt` and `docs/verb_history_de.txt`, along with three repairs to the
German localization alone. Sixty-nine edits, thirty-three English and thirty-six German, each one
asserted against an expected occurrence count rather than eyeballed. Both files validate clean and
the two headers' counts have been updated to match. What was declined, and why, is in
[What was applied and what was not](#what-was-applied-and-what-was-not).

**Shipped to the catalog 2026-07-29.** Both localizations of `Info.verbHistoryText` in
`Konjugieren/Assets/Localizable.xcstrings` now carry the corrected essay, along with Phase 0's ten
patches, which had also never shipped. The catalog diff is exactly two changed lines, one per
localization, and each round-trips byte-identical to its extract.

**Verified in the running app**, in both languages, which no one had done for any of this text.
Screenshots were taken but `docs/screenshots/` is gitignored, so what they showed is recorded here
instead. The Info screen renders without the `fatalError` that unbalanced markup would cause. No
literal markup character appears in the rendered text. `ich k`**`a`**`nn` reddens only the a, which
is the `$kAnN$` to `$kAnn$` fix, since the old value also reddened the second n. `ich s`**`a`**`ng`
and `ich habe ges`**`u`**`ngen` redden correctly in both languages. E3's added sentences render with
`*dō-` as a literal asterisk rather than as markup. G4's `Synthetic:` and `Periphrastic:` labels,
H16's parenthetical hedge, H6's `worn down and learned one verb at a time`, and H7's new subjunctive
bullet are all present, as are their German counterparts. Ten further assertions were run
mechanically against the shipped catalog values, covering the two restored German hedges, the recast
Küche sentence, `einen ~comitatus~`, H3's `“Deutsch”`, the deleted stellar-winds clause, and the
`reflect` agreement fix. All ten pass.

The entries below are kept in the form they were written, as proposals with their evidence, because
the evidence is the reason to trust the change. Read them as the record of why the essay now says
what it says.

**What produced it.** Phase 1 inventoried 111 checkable claims in the German-specific half and ran
seven researchers plus one internal-consistency agent over them, returning 31 findings. Phase 2 ran
one skeptic per finding, instructed to refute, and one second opinion per kill, instructed to attack
the refutation: 51 agents, 2.38 million subagent tokens. Four findings died. Phase 3 ran the app's
own conjugator over the essay's `$…$` spans. The shared opening sections were not researched in this
run; they carry Conjugar's already-adjudicated corrections, applied verbatim by Phase 0.

**One caution about the evidence, carried forward from Phase 2 rather than softened here.** The
second-opinion pass is directionally biased. Nineteen ran, fourteen changed the disposition, and all
fourteen moved toward a stronger finding. "Attack the skeptic" applied to a kill means "restore it",
so the pass measured robustness rather than truth. What the three passes do establish is which
findings are robust: a finding below that survived Phase 1, a hostile skeptic, and in some cases a
hostile third reading is better evidenced than anything the earlier runs produced.

## How to read this

- **Line numbers drift, quoted text does not.** Every entry cites its English line in
  `docs/verb_history.txt` and its German line in `docs/verb_history_de.txt`, both as of this writing.
  Adding a line to either file's header shifts every body line. Locate by the quoted fragment.
- **Every correction is given in both languages.** The catalog marks both localizations
  `translated`, so a stale German value ships as though it were current rather than falling back to
  English. The English prose below is what Phase 2 certified; the German is written here, against the
  German line each finding cites, with hedge strength matched deliberately rather than incidentally.
- **Severity means what Phase 2 defined.** `factual-error`, a reader would be actively misinformed.
  `needs-hedging`, the question is contested and the essay states it flatly. `nitpick`, a
  specialist's quibble that misleads nobody.
- **Markup is preserved in place.** Uppercase inside `$…$` is data: it marks the letters the app
  reddens as irregular. `~…~` spans are equivalent rather than identical across languages, since they
  emphasize technical terms and those are different words in German.
- **Six corrections collide with another correction on the same line**, and each entry says so:
  C1 with C2 at EN 136, R2a with R2c at EN 92, D12 with H13 at EN 153, G8 with span 24 and 25,
  F16 with span 16, R8 with spans 5 and 6, E1 with E3 and with H19 at EN 156. Applying one without
  reading the other produces a line that is half corrected.
- **Applying any of this changes counts that the two file headers assert.** See
  [Bookkeeping](#bookkeeping-the-corrections-create) before syncing.

## What this document hands over

| Section | Items | Kind |
|---|---|---|
| [Factual errors](#factual-errors-7) | 7 | corrections, prose in both languages |
| [Needs hedging](#needs-hedging-4) | 4 | corrections, prose in both languages |
| [Nitpicks](#nitpicks-16) | 16 | corrections, prose in both languages |
| [Span corrections against the app](#span-corrections-against-the-app) | 9 occurrences | mechanical, both files, byte-identical |
| [Internal consistency](#internal-consistency-agent-hs-16-items) | 16 | editorial decisions, five already discharged |
| [Thin confirmations](#confirmed-rows-whose-reasoning-is-thin) | 4 | audit-trail defects, **not** proposed corrections |
| [Findings against the app](#findings-against-the-app-rather-than-the-essay) | 3 | corpus and code, not essay text |
| [Refuted, recorded](#refuted-and-recorded) | 4 | so a future run does not pay for them twice |

## What was applied and what was not

Everything graded as a finding was applied: 7 factual errors, 4 hedges, 16 nitpicks, and all 9 span
occurrences. The judgement calls were in the two categories where this document offered options.

**Applied from the sixteen internal-consistency items.** H3, which Josh named explicitly, changes
one word: `The word “German”` becomes `The word “Deutsch”` in the English, and the German needed no
change because the translator had already resolved it. H6 gives the closing sentence the body's
qualification, "worn down and learned one verb at a time". H7 adds a subjunctive bullet to the
closing periphrastic list, which also answers half of H8 by putting one of the two omitted sections
back into the summary. H9 removes the third competing principle for strong-class membership. H12
dates the periphrases to the daughter languages that built them. H16 hedges the preterite inside the
parenthesis it already had, rather than adding a new aside. H18's distinguished glosses were merged
into F13's replacement sentence. H1, H4, H5 and H15 needed nothing, having been discharged by D7,
R1, G8 and R2c.

**Applied to the German alone**, from agent H's German-surface list. Item 1 restores the hedge the
translation dropped: `Vor 40.000 Jahren, womöglich früher` becomes `Bis vor 40.000 Jahren, und
durchaus auch früher`, recovering both the bound the English states with "By" and the emphasis of
"quite possibly". Item 2 restores "arguably" as a flag rather than an affirmation, `und wohl auch
Zukunft` becoming `und, wie manche annehmen, auch Zukunft`. Item 4 recasts the Küche sentence so it
stops contrasting *Küche* with itself. C6's second opinion also caught `eine ~comitatus~` for a Latin
masculine, now `einen`. And the English-only subject-verb disagreement agent H flagged at EN 171,
"The peculiar conjugations … reflects", is now "reflect"; the German was already correct.

**Declined, with reasons.**

| Not applied | Why |
|---|---|
| **H2**, the closing supernova epithet | Superseded by G14, the researched finding on the identical sentence, which two agents killed independently. An unresearched internal reading does not outrank a three-pass verdict. |
| **H10**, the "arguably" against the flat mood bullet | Both sentences are pasted patch text and the verbatim rule covers both. Note that fixing German-surface item 2 puts the German in the same position as the English, so the tension now exists equally in both languages, which is more honest than having it in one. |
| **H14**, whether the essay should explain its own red letters | Editorial, and Josh's. Fixing the four wrong spans makes it slightly sharper rather than softer, since more letters are now red. |
| **H17**, naming the zero-grade exception to the CVC shape | "Typically" already carries it, and introducing the zero grade twenty-two lines before the essay defines it would cost more than the inconsistency does. |
| **H19**, a bridging clause from the northern coasts to the southern dialects | Any bridge asserts a migration claim this run did not check. Adding unchecked prose to an essay whose point was removing unchecked prose is self-defeating. E1's widened geography narrows the gap without closing it. |
| **H8**'s other half, dropping the passive bullet | The bullet is true, and the closing summarizes Modern German rather than the essay. H7's new bullet already returns the subjunctive to the summary. |
| **R8**'s optional *brechen* row | Unchecked against the app's conjugator, and Phase 3's method is what settles span values. The minimal `$nAhm$` fix landed instead. |
| **German-surface item 5**, the ten English glosses | Editorial and Josh's: whether a German reader should be told that *haben* means "to have". Untouched, so F13's and F8's new sentences keep the convention those lines already had. |
| **Items 6 and 7** | Notes rather than defects. Item 7 explicitly warns against "fixing" the German toward the English. |

---

# Factual errors (7)

### C9 · EN 140 / DE 106 · cluster C · upheld through both passes

> They built no stone monuments.

**Verdict.** Phase 1 said factual-error; the skeptic tried to kill it on the Tacitean reading and
could not; the second opinion upheld it on different evidence and rewrote the prose.

**What is true.** The Germanic peoples of the essay's period built nothing in dressed or cut stone,
which is the defensible core of the sentence. They did raise stone in burial contexts: the
southern-Scandinavian *domarringar* run from about 500 BC to AD 400 and straddle AD 9, which is the
essay's own geography for the Germanic homeland six lines earlier. The second opinion explicitly
declined the skeptic's Gothic Wielbark stone circles as the kill shot, since those postdate Teutoburg
by two to four generations, and it rewrote Phase 1's replacement because that version's positive
clause is false of the Rhine-Weser interior the paragraph foregrounds.

**Sources.** Tacitus, *Germania* 16 and 27; *Antiquity* (Cambridge) on the Wielbark culture;
Pachulska (2021) on Pomeranian stone circles; Iron Age burial surveys for northern Germany and
southern Scandinavia; Bogucki and Crabtree, *Ancient Europe 8000 BC–AD 1000*.

**English.**

> They built nothing in cut stone, though standing stones and stone circles marked their graves in Scandinavia and along the Baltic.

**German.**

> Sie bauten nichts aus behauenem Stein, doch aufgerichtete Steine und Steinkreise markierten ihre Gräber in Skandinavien und entlang der Ostsee.

**Reports.** [`verdict_C9.md`](verb_history_phase2_reports/verdict_C9.md),
[`second_C9.md`](verb_history_phase2_reports/second_C9.md)

### D6 · EN 148 / DE 114 · cluster D · upheld

> The ~subjunctive and optative moods merged~ into a single Germanic subjunctive, reducing the modal options available to speakers

**Verdict.** Upheld at factual-error by the skeptic, which is also where Phase 1 filed it.

**What is true.** Germanic did not merge two PIE moods. It kept the optative and lost the
subjunctive; the mood called the Germanic subjunctive continues the PIE optative and took over the
old subjunctive's work. Fulk's handbook states that Germanic has "no subjunctive mood (since the Gmc.
subjunctive reflects the PIE optative)". The essay asserts a joint descent that never happened, in a
paragraph where every neighboring sentence is a descent claim.

**Sources.** R. D. Fulk, *A Comparative Grammar of the Early Germanic Languages* (Benjamins, 2018),
§1.3; Rolf Noyer, "The PIE Verb" (Penn).

**English.**

> The ~optative became the single Germanic subjunctive~, taking over the jobs of the PIE subjunctive, which Germanic did not keep, and reducing the modal options available to speakers.

**German.**

> ~Der Optativ wurde zum einzigen germanischen Konjunktiv~ und übernahm die Aufgaben des PIE-Konjunktivs, den das Germanische nicht bewahrte, was die modalen Optionen für Sprecher reduzierte.

**Also settles H1.** See [Internal consistency](#discharged-by-a-surviving-finding).

**Reports.** [`verdict_D6.md`](verb_history_phase2_reports/verdict_D6.md)

### R2c · EN 92 / DE 58 · cluster E · partly upheld

> then, through Medieval Latin theodiscus (“of the people”), Modern German Deutsch

**Verdict.** Phase 1 said factual-error; the skeptic upheld the grade for one leg and rejected
another, and rewrote the prose because Phase 1's version introduced a fresh error.

**What is true.** The Old English link is a real error: *Deutsch* does not descend through *þēod*.
The Germanic adjective, Old High German *diutisc*, is the actual ancestor. The Latin-to-German
routing that Phase 1 wanted struck out entirely is a live minority position rather than a settled
falsehood, and the 786 *theodiscus* attestation refers to Old English, not to Old High German, which
is what Phase 1's replacement got wrong.

**Sources.** Pfeifer, *Etymologisches Wörterbuch des Deutschen*, s.v. *deutsch*, via DWDS; Online
Etymology Dictionary, s.v. *Dutch*; the *Reichsannalen* 788 *theodisca lingua* passage as reported in
the same literature.

**English.**

> it became Proto-Germanic *þeudō, which gave Old English þēod (“nation”) and, with a Germanic adjective suffix, Old High German diutisc, the ancestor of Modern German Deutsch. Latin scribes were writing the Germanic adjective as theodiscus (“of the people”) by 786, some two centuries before the German form itself is attested.

**German.**

> Daraus wurde protogermanisch *þeudō, das altenglisch þēod („Nation“) ergab und, mit einem germanischen Adjektivsuffix, althochdeutsch diutisc, den Vorfahren des neuhochdeutschen Deutsch. Lateinische Schreiber notierten das germanische Adjektiv schon 786 als theodiscus („des Volkes“), rund zwei Jahrhunderte bevor die deutsche Form selbst bezeugt ist.

**Collides with R2a**, one sentence earlier in the same paragraph, and **also settles H15**. Both
languages use curly quotation marks in this paragraph and nowhere else; the prose above keeps that.

**Reports.** [`verdict_R2c.md`](verb_history_phase2_reports/verdict_R2c.md)

### R6 · EN 113–117 / DE 79–83 · cluster E · partly upheld, restored by the second opinion

> 🐑 ~lengthened o-grade~: *ō (as in *n̥-péh₂-tōr)

**Verdict.** Phase 1 said factual-error; the skeptic cut it to nitpick on a provenance argument; the
second opinion restored factual-error at low consequence and adopted the skeptic's prose unchanged.

**What is true.** `*n̥-péh₂-tōr` is ill-formed. The root of "father" is `*ph₂-`, zero grade in every
case form, and Greek ἀπάτωρ has a short alpha, so the acute `é` in the essay's form is spurious. The
string is printed verbatim in English Wikipedia's "Indo-European ablaut" table, which is plainly the
source, so the essayist did not invent it; the second opinion's point is that provenance is not
severity, and the spurious vowel sits under the very accent that the preceding bullet has just taught
the reader to read as the graded vowel.

**Sources.** Ringe, *From Proto-Indo-European to Proto-Germanic* (OUP, 2006); Wiktionary
reconstructions of `*ph₂tḗr` and `*bʰṓr`; English Wikipedia, "Indo-European ablaut", raw wikitext.

**English.**

> 🐑 ~lengthened o-grade~: *ō (as in *bʰōr, "thief", from *bʰer-)

**German.**

> 🐑 ~gedehnte o-Stufe~: *ō (wie in *bʰōr, "Dieb", von *bʰer-)

The bullet list in both files uses straight ASCII quotation marks, as at EN 113 / DE 79; the prose
above keeps that rather than importing the curly quotes used one paragraph away.

**Reports.** [`verdict_R6.md`](verb_history_phase2_reports/verdict_R6.md),
[`second_R6.md`](verb_history_phase2_reports/second_R6.md)

### F13 · EN 169 / DE 135 · cluster F · partly upheld

> These include the modal verbs ~können~ (can), ~müssen~ (must), ~dürfen~ (may), ~sollen~ (shall), ~mögen~ (may/like), and ~wissen~ (to know)

**Verdict.** The skeptic upheld the diagnosis and the factual-error grade, and revised the fix
because Phase 1's added *wollen* sentence would have sat immediately before a paragraph whose subject
is "these verbs" and whose explanation is false of *wollen*.

**What is true.** *Wissen* is not a modal verb. IDS grammis and Duden both put it outside the modal
class as the preterite-presents' one full verb. The essay calls all six modals flatly.

**Sources.** grammis (IDS Mannheim), progr@mm, "Flexion der Modalverben" and "Modalverb"; Duden,
"Modalverb"; Wright, *Grammar of the Gothic Language* (1910), on *wiljan*.

**English.**

> These include the modal verbs ~können~ (can), ~müssen~ (must), ~dürfen~ (may), ~sollen~ (shall), and ~mögen~ (may/like), together with ~wissen~ (to know), which shares their history but is a full verb, not a modal.

**German.**

> Dazu gehören die Modalverben ~können~ (can), ~müssen~ (must), ~dürfen~ (may), ~sollen~ (shall) und ~mögen~ (may/like), dazu ~wissen~ (to know), das ihre Geschichte teilt, aber ein Vollverb ist und kein Modalverb.

The German keeps the English glosses because that is what the line does today. Agent H flagged those
ten glosses as an editorial question of their own; see [H18](#open-decisions-for-josh), which if taken
lands inside this sentence.

**Reports.** [`verdict_F13.md`](verb_history_phase2_reports/verdict_F13.md)

### F8 · EN 164 / DE 130 · cluster F · upheld and escalated

> Beginning in Middle High German, the verb ~werden~ (to become) was grammaticalized as a future auxiliary

**Verdict.** The largest single move in the run. Phase 1 filed it needs-hedging, the skeptic cut it
to nitpick, and the second opinion raised it to factual-error and upheld it outright.

**What is true.** *Werden* plus infinitive was very rare in Middle High German. Futurity there was
carried by the simple present and by *sol*, *wil* and *muoz*. Paul's *Mittelhochdeutsche Grammatik*
dates the construction to the second half of the fourteenth century, while Concu dates its beginnings
to Old High German, so "Beginning in Middle High German" is not the safe onset claim the skeptic took
it for. The construction was firmly established only in the sixteenth century. The essay never names
Early New High German anywhere in either language and dates no period past 1350, so a reader is
misdirected by roughly two centuries four lines before line 168 announces a three-way temporal system.

**Sources.** Hermann Paul, *Mittelhochdeutsche Grammatik*, § Tempora, via secondary literature;
Valentina Concu on *werden* periphrases; Agnes Jäger, "Die Entstehung des deutschen
werden+Infinitiv-Futurs"; Booth (Oxford), "Middle High German: Syntax".

**English.**

> Beginning in Middle High German, the verb ~werden~ (to become) was paired with an infinitive, though the construction stayed rare there beside the simple present and periphrases with ~sollen~ and ~wollen~; only in Early New High German (1350–1650) was ~werden~ grammaticalized as the regular future auxiliary, a change that culminated in the sixteenth century:

**German.**

> Beginnend im Mittelhochdeutschen trat das Verb ~werden~ (to become) mit einem Infinitiv zusammen, doch die Konstruktion blieb dort selten neben dem einfachen Präsens und den Umschreibungen mit ~sollen~ und ~wollen~; erst im Frühneuhochdeutschen (1350–1650) wurde ~werden~ zum regulären Futurauxiliar grammatikalisiert, ein Wandel, der im sechzehnten Jahrhundert seinen Abschluss fand:

This is the one correction that adds a period label to the essay, so it also closes the gap between
1350 and the modern day that the essay otherwise leaves unnamed. It adds three `~…~` spans; see
[Bookkeeping](#bookkeeping-the-corrections-create).

**Reports.** [`verdict_F8.md`](verb_history_phase2_reports/verdict_F8.md),
[`second_F8.md`](verb_history_phase2_reports/second_F8.md)

### G8 · EN 180 / DE 146 · cluster G · partly upheld

> 🇩🇪 ~Aspect~ is expressed periphrastically (er $lIest$ = he reads/is reading)

**Verdict.** The skeptic upheld the core defect and rejected Phase 1's second charge. Phase 1's
replacement prose was certified unchanged.

**What is true.** *Er liest* is a single synthetic finite form containing no periphrasis at all, so
the bullet's sole illustration of "periphrastically" illustrates the opposite. What does not survive
is Phase 1's further claim that the sentence implies a grammaticalized aspect category German lacks:
the sentence never claims grammaticalization, its prefix clause is correct, and line 144 has already
told the reader Germanic abandoned aspect. German does have a colloquial *am*-progressive, which is
the periphrasis the bullet was reaching for.

**Sources.** Brown, Chumakina, Corbett and Hippisley, "Defining 'periphrasis': key notions",
*Morphology*; grammis (IDS Mannheim), "Darf man Ich bin am Schreiben schreiben?"; *Journal of Germanic
Linguistics* on emergent progressive aspect in spoken German.

**English.** Span values already corrected per Phase 3:

> 🇩🇪 ~Aspect~ is carried by context (er $lIEst$ = he reads/is reading), by the colloquial ~am~-progressive (er ist am Lesen = he is reading), or by verbal prefixes and particles (er $lIEst$ das Buch aus = he finishes reading the book)

**German.**

> 🇩🇪 ~Aspekt~ wird durch den Kontext getragen (er $lIEst$ = he reads/is reading), durch die umgangssprachliche ~am~-Verlaufsform (er ist am Lesen = he is reading) oder durch verbale Präfixe und Partikeln (er $lIEst$ das Buch aus = he finishes reading the book)

**Collides with span corrections 24 and 25**, which change `$lIest$` to `$lIEst$` on this exact line
in both files. The prose above has the corrected spans already. The English glosses inside the German
bullet are deliberate and stay: the contrast is the point, which is why agent H separated this case
from the ten vestigial glosses it flagged elsewhere. **Also settles H5.**

**Reports.** [`verdict_G8.md`](verb_history_phase2_reports/verdict_G8.md)

---

# Needs hedging (4)

### A4 · EN 126 / DE 92 · cluster A · partly upheld, restored by the second opinion

> Equipped with horses, wheeled carts, and perhaps bronze weapons, they moved westward in successive waves

**Verdict.** Phase 1 said needs-hedging, the skeptic refuted it, and the second opinion restored it
at needs-hedging with new prose that also fixes what the skeptic correctly saw wrong in Phase 1's fix.

**What is true.** No live camp establishes the flat claim. Librado et al. 2021 says in its body that
"Yamnaya pastoralism did not spread horses far outside their native range", and the 2026 rebuttal by
Anthony, Trautmann and Heyd defends the migration only as "compatible with the spread of DOM2-clade
horses". The skeptic was right that Phase 1's replacement was itself an unhedged claim in the
opposite direction. Ox-drawn carts are not in dispute, and the riding question is already hedged
forty lines earlier at EN 86.

**Sources.** Librado et al. (2021), *Nature*, on the origins and spread of domestic horses; Anthony,
Trautmann and Heyd (2026), *Science Advances*; Trautmann et al. (2023) on Yamnaya horsemanship.

**English.**

> Equipped with ox-drawn carts and perhaps with bronze weapons and horses of their own, they moved westward in successive waves.

**German.**

> Ausgestattet mit ochsenbespannten Karren und vielleicht mit Bronzewaffen und eigenen Pferden zogen sie in aufeinanderfolgenden Wellen westwärts.

The hedge is "perhaps", scoping over both the weapons and the horses, and the German "vielleicht mit"
scopes the same way. Do not let it slide to "wahrscheinlich".

**Reports.** [`verdict_A4.md`](verb_history_phase2_reports/verdict_A4.md),
[`second_A4.md`](verb_history_phase2_reports/second_A4.md)

### B12 · EN 133 / DE 99 · cluster B · partly upheld, regraded

> the Germanic languages developed free from the Romanization that transformed Gaulish into French, Iberian languages into Spanish and Portuguese, and Dacian into Romanian

**Verdict.** Phase 1 said factual-error. The skeptic cut it to needs-hedging on the ground that
"Romanization" as grammatical agent already signals replacement rather than descent; the second
opinion refuted that argument using the essay's own line 156, which uses the identical frame to mean
continuity, and then found a different defect that both prior agents had missed.

**What is true.** French, Spanish, Portuguese and Romanian descend from Latin, not from Gaulish,
Iberian or Dacian. Beyond that, the Dacian leg states as settled what the field calls unresolved: the
*Cambridge History of the Romance Languages* (2013, p. 287) and the *Oxford Guide to the Romance
Languages* (2016, p. 91) both decline to say where Daco-Romance formed. Naming regions rather than
languages, and putting Latin where the descent starts, fixes both problems at once.

**Sources.** *Cambridge History of the Romance Languages* (2013) p. 287; *Oxford Guide to the Romance
Languages* (2016) p. 91; Britannica on the Romance languages and on Basque.

**English.**

> This had profound linguistic consequences: the Germanic languages developed free from the Romanization that replaced the languages of Gaul, Iberia, and the Danube provinces with the Latin that became French, Spanish, Portuguese, and Romanian.

**German.**

> Dies hatte tiefgreifende sprachliche Konsequenzen: Die germanischen Sprachen entwickelten sich frei von der Romanisierung, die die Sprachen Galliens, der Iberischen Halbinsel und der Donauprovinzen durch das Latein ersetzte, aus dem Französisch, Spanisch, Portugiesisch und Rumänisch wurden.

**Reports.** [`verdict_B12.md`](verb_history_phase2_reports/verdict_B12.md),
[`second_B12.md`](verb_history_phase2_reports/second_B12.md)

### D7 · EN 150 / DE 116 · cluster D · upheld

> The ~augment~ (*e-), which had marked past tense in PIE, was lost entirely in Germanic

**Verdict.** Upheld at needs-hedging by the skeptic, which is where Phase 1 filed it. Phase 1's
replacement prose was certified unchanged.

**What is true.** Two live questions are stated as settled. Lehmann's *Grammar of Proto-Germanic*
treats the augment as a common innovation of Indo-Iranian, Greek and Armenian that Germanic never
had, so there was nothing for Germanic to lose; and Willi (2018) argues it was not a past marker even
at the PIE stage. The essay's own EN 102 already hedges exactly this, which makes EN 150 an internal
contradiction as well as an overstatement.

**Sources.** Winfred P. Lehmann, *A Grammar of Proto-Germanic* (ed. Slocum, LRC Austin); Bryn Mawr
Classical Review 2019.01.34 on Andreas Willi, *Origins of the Greek Verb*; Martirosyan on Armenian.

**English.**

> The ~augment~ (*e-), the past-tense prefix of a few branches, left no trace at all in Germanic.

**German.**

> Das ~Augment~ (*e-), das Vergangenheitspräfix einiger weniger Zweige, hinterließ im Germanischen keine Spur.

Both versions drop the presupposition of presence, which is the half of the repair that a shorter fix
would miss: striking only "which had marked past tense in PIE" would leave "was lost entirely in
Germanic" still asserting that Germanic once had it. **Also settles H1.**

**Reports.** [`verdict_D7.md`](verb_history_phase2_reports/verdict_D7.md)

### E12 · EN 157 / DE 123 · cluster E · restored and upgraded by the second opinion

> Today, German strong verbs must largely be memorized individually, their ablaut patterns, while still systematic, are no longer predictable from the infinitive.

**Verdict.** Phase 1 said nitpick, the skeptic refuted it, and the second opinion restored it and
regraded it upward to needs-hedging on evidence neither prior agent had found.

**What is true.** This is a live specialist disagreement that the essay states as settled. Mailhammer
(2007) supports the essay's wording; Wiese (2008, IDS Mannheim, Benjamins CILT 285) concludes at the
same scope that "for the majority of strong verbs, membership in these classes (and thus ablaut) is
predictable". The defensible statement separates two questions the essay merges: whether the
infinitive tells you the verb is strong, which it does not, and whether the stem shape predicts the
ablaut pattern once you know it is strong, which is disputed and largely works.

**Sources.** Mailhammer, "Islands of resilience", *Morphology* (2007); Bernd Wiese, "Form and function
of verbal ablaut in contemporary standard German" (2008); grammis, "Starke Verben".

**English.**

> Today, German strong verbs must largely be memorized individually. No infinitive reveals whether a verb is strong at all, and among those that are, the shape of the stem still points to an ablaut pattern in most cases without settling it.

**German.**

> Heute müssen deutsche starke Verben größtenteils einzeln auswendig gelernt werden. Kein Infinitiv verrät, ob ein Verb überhaupt stark ist, und unter denen, die es sind, weist die Gestalt des Stammes in den meisten Fällen noch auf ein Ablautmuster hin, ohne es festzulegen.

This also repairs a comma splice the English has today and the German does not, which agent H
recorded as one of the essay's two English-only style defects.

**Reports.** [`verdict_E12.md`](verb_history_phase2_reports/verdict_E12.md),
[`second_E12.md`](verb_history_phase2_reports/second_E12.md)

---

# Nitpicks (16)

### A7 · EN 130 / DE 96 · cluster A · partly upheld

> By the first millennium BC, a recognizable Proto-Germanic language had emerged

**What is true.** The ambiguity is real and worth one phrase, since "by the first millennium BC"
reads as 1000 BC. Phase 1's supporting claims fail: the German carries the same ambiguity rather than
resolving it, and it is not true that nothing recognizable as Proto-Germanic is reconstructed for
1000 BC, since Lehmann dates Proto-Germanic from about 2500 BC and Euler and Badenheuer reconstruct
the Bronze Age stage.

**Sources.** Lehmann, *A Grammar of Proto-Germanic*; Euler and Badenheuer, *Sprache und Herkunft der
Germanen*; Iversen and Kroonen, "Talking Neolithic".

**English.**

> By the second half of the first millennium BC, a recognizable Proto-Germanic language had emerged in southern Scandinavia and along the North Sea and Baltic coasts.

**German.**

> Bis zur zweiten Hälfte des ersten Jahrtausends v. Chr. war eine erkennbare proto-germanische Sprache in Südskandinavien und entlang der Nordsee- und Ostseeküsten entstanden.

**Interacts with D1**, one of the four thin confirmations: D1's "some two millennia" derives its
range partly from this row, and this correction pushes that range toward its lower end.

**Reports.** [`verdict_A7.md`](verb_history_phase2_reports/verdict_A7.md)

### R1 · EN 90 / DE 56 · cluster A · restored by the second opinion

> These languages include German, English, Ukrainian, Hindi, Persian, Cornish, Greek, and Latin.

**What is true.** The antecedent of "These languages" is "languages spoken by nearly half of humans
alive today", and Latin has no first-language community. The skeptic argued that a non-distributing
measure phrase forces a whole-family reading; the second opinion answered that this confuses
cumulative with collective predication, and that SIL's own ISO 639-3 registry types Latin
"Historical" while defining Living by a first-language criterion. The essay's "nearly half" figure is
an L1 count over roughly 445 living Indo-European languages, so Latin is excluded by the essay's own
arithmetic. The fix widens the antecedent rather than editing the list.

**Sources.** SIL International, ISO 639-3 registry, code `lat`, and "Types of Languages"; Ethnologue
statistics for the Indo-European family; Benedict XVI, *Latina Lingua* (2012), cited by the skeptic
and answered.

**English.** Second sentence only:

> The Indo-European family includes German, English, Ukrainian, Hindi, Persian, Cornish, Greek, and Latin.

**German.**

> Zur indoeuropäischen Familie gehören Deutsch, Englisch, Ukrainisch, Hindi, Persisch, Kornisch, Griechisch und Latein.

**Also settles H4.**

**Reports.** [`verdict_R1.md`](verb_history_phase2_reports/verdict_R1.md),
[`second_R1.md`](verb_history_phase2_reports/second_R1.md)

### B7 · EN 131 / DE 97 · cluster B · restored by the second opinion

> an alliance of Germanic tribes led by Arminius (Hermann)

**What is true.** Nothing false is asserted: "Hermann" is a true alternate-name gloss. The second
opinion agreed with the skeptic on that and restored the finding anyway, because the skeptic's two
supporting arguments beg the question, and because the bare parenthesis invites the reader to take
Hermann as a contemporary Germanic name rather than as a name given to Arminius by later Germans, most
famously in the nineteenth century. The repair is cheap and asserts less than Phase 1's did.

**Sources.** Herbert W. Benario, "Arminius into Hermann: History into Legend", *Greece & Rome* 51.1
(2004); Martin M. Winkler, *Arminius the Liberator* (OUP, 2016); Pfeifer s.v. *Heer* via DWDS.

**English.**

> Three Roman legions under the command of Publius Quinctilius Varus (perhaps 20,000 soldiers) were ambushed and annihilated by an alliance of Germanic tribes led by Arminius (known to later Germans as Hermann), a Romanized chieftain of the Cherusci.

**German.**

> Drei römische Legionen unter dem Kommando von Publius Quinctilius Varus (vielleicht 20.000 Soldaten) wurden von einer Allianz germanischer Stämme unter der Führung von Arminius (den späteren Deutschen als Hermann bekannt), einem romanisierten Häuptling der Cherusker, überfallen und vernichtet.

**Reports.** [`verdict_B7.md`](verb_history_phase2_reports/verdict_B7.md),
[`second_B7.md`](verb_history_phase2_reports/second_B7.md)

### C1 · EN 136 / DE 102 · cluster C · restored by the second opinion

> lived in small villages and farmsteads scattered through the forests of northern Europe

**What is true.** The skeptic defended the forest matrix using Roberts et al. 2018's roughly 60
percent forest cover figure. The second opinion showed that figure is stated "for the same area" as
Schlüter's *Atlas Östliches Mitteleuropa*, meaning eastern Central Europe, while the same paper's
next sentence puts north western Europe and the coasts of southern Scandinavia in the already-cleared
bucket. That is precisely where the essay locates the Germanic peoples six lines earlier. Two words
fix it.

**Sources.** Roberts et al., "Europe's lost forests", *Scientific Reports* 8 (2018); Nielsen et al.
on quantitative land-cover reconstruction; Odgaard and Rasmussen on the Danish cultural landscape.

**English.**

> At the time of the battle at Teutoburg, the Germanic peoples lived in small villages and farmsteads scattered through the forests and cleared fields of northern Europe.

**German.**

> Zur Zeit der Schlacht im Teutoburger Wald lebten die germanischen Völker in kleinen Dörfern und Gehöften, die über die Wälder und gerodeten Felder Nordeuropas verstreut waren.

**Collides with C2**, the next sentence in the same paragraph. See the merged form under C2.

**Reports.** [`verdict_C1.md`](verb_history_phase2_reports/verdict_C1.md),
[`second_C1.md`](verb_history_phase2_reports/second_C1.md)

### C2 · EN 136 / DE 102 · cluster C · partly upheld

> growing barley, oats, rye, and wheat

**What is true.** Phase 1's archaeobotany is right: barley dominates, and rye is still mostly a weed
of other crops at 9 AD rather than a crop in its own right. The four-item list gives them equal
billing. The skeptic reduced the fix to a reordering, since Phase 1's version added a comma-fenced
aside the house style avoids.

**Sources.** Pliny, *Natural History* 18.141 and 18.149; Grabowski on Iron Age cereal cultivation in
east-central Jutland; Behre, "The history of rye cultivation in Europe", *Vegetation History and
Archaeobotany*.

**English.**

> They practiced mixed agriculture, growing barley above all, along with oats, wheat, and some rye, while raising cattle, pigs, sheep, and horses.

**German.**

> Sie betrieben gemischte Landwirtschaft, bauten vor allem Gerste an, dazu Hafer, Weizen und etwas Roggen, und hielten Rinder, Schweine, Schafe und Pferde.

**Merged with C1**, since the two corrections are consecutive sentences and Josh will want to read
the line whole:

> At the time of the battle at Teutoburg, the Germanic peoples lived in small villages and farmsteads scattered through the forests and cleared fields of northern Europe. They practiced mixed agriculture, growing barley above all, along with oats, wheat, and some rye, while raising cattle, pigs, sheep, and horses. Cattle were especially important, serving as a measure of wealth and a form of currency.

> Zur Zeit der Schlacht im Teutoburger Wald lebten die germanischen Völker in kleinen Dörfern und Gehöften, die über die Wälder und gerodeten Felder Nordeuropas verstreut waren. Sie betrieben gemischte Landwirtschaft, bauten vor allem Gerste an, dazu Hafer, Weizen und etwas Roggen, und hielten Rinder, Schweine, Schafe und Pferde. Rinder waren besonders wichtig und dienten als Maß für Wohlstand und als Zahlungsmittel.

**Reports.** [`verdict_C2.md`](verb_history_phase2_reports/verdict_C2.md)

### C10 · EN 140 / DE 106 · cluster C · restored by the second opinion, as a German-side repair

> they did develop the runic alphabet for short inscriptions and magical purposes

**What is true.** The "magical purposes" half of Phase 1's complaint is dead: Nedoma states that runes
served both profane communication and communication with the supernatural, so that is handbook
doctrine. The chronology half survives, and it survives **in the German only**. The English
concessive asserts no date. The German ships a pluperfect, "entwickelt hatten", inside a frame
anchored at 9 AD, which flatly places the runic alphabet before Teutoburg. No handbook affirms that:
Nedoma's chronology section gives no creation date and starts at about 150 AD, Barnes says there is
little certainty, and the skeptic's Svingerud 50 BC plank misapplies a grave's radiocarbon range to a
carving.

**Sources.** Klaus Düwel, *Runenkunde* (Metzler); Robert Nedoma, "Runenschrift und Runeninschriften";
Solheim et al. on the Hole sandstone fragments; Michael P. Barnes, *Runes: A Handbook*, via review.

**English.** Optional, and the essay is defensible as it stands:

> They committed little to writing, though they would develop the runic alphabet for short inscriptions and magical purposes.

**German.** This is the one that matters:

> Sie hinterließen wenig Schriftliches, obwohl sie das Runenalphabet für kurze Inschriften und magische Zwecke entwickeln sollten.

The German uses the narrative future the essay already uses elsewhere ("sollte zum Schmelztiegel
werden", "der zum Germanischen werden sollte"), so the register is the essay's own. Two words change.

**Reports.** [`verdict_C10.md`](verb_history_phase2_reports/verdict_C10.md),
[`second_C10.md`](verb_history_phase2_reports/second_C10.md)

### C12 · EN 142 / DE 108 · cluster C · partly upheld

> Wōðanaz (later Wōden (Old English) and Óðinn (Old Norse)), Þunaraz (Thunor and Þórr), Tīwaz (Tiw and Týr)

**What is true.** Three reconstructed theonyms are printed without the asterisk the essay uses for
every other reconstruction, which is an internal inconsistency rather than an error about the gods.
The labelling half of Phase 1's complaint fails, since Phase 1's own replacement left it unfixed, and
that replacement additionally stranded the participle "worshipped" and silently respelled *Þunaraz*
as *Þunraz*. The skeptic's version fixes the nesting, which is four parentheses deep in places, and
keeps the spellings.

**Sources.** Vladimir Orel, *A Handbook of Germanic Etymology* (Brill, 2003); DWDS *Etymologisches
Wörterbuch*, s.v. *Donner*; Haukur Þorgeirsson, "The Name of Thor and the Transmission of Old Norse
Poetry", *Neophilologus*.

**English.**

> Their religion centered on a pantheon of gods (*Wōðanaz, later Wōden in Old English and Óðinn in Old Norse; *Þunaraz, later Thunor and Þórr; *Tīwaz, later Tiw and Týr; and others) worshipped in sacred groves rather than temples.

**German.**

> Ihre Religion konzentrierte sich auf ein Pantheon von Göttern (*Wōðanaz, später Wōden im Altenglischen und Óðinn im Altnordischen; *Þunaraz, später Thunor und Þórr; *Tīwaz, später Tiw und Týr; und andere), die in heiligen Hainen statt in Tempeln verehrt wurden.

The German gains the comma before "die" that the current line omits. This correction adds three
asterisks and so makes both headers' "twenty asterisks" claim stale; see
[Bookkeeping](#bookkeeping-the-corrections-create).

**Reports.** [`verdict_C12.md`](verb_history_phase2_reports/verdict_C12.md)

### D12 · EN 153 / DE 119 · cluster D · restored by the second opinion, then superseded by Phase 3

> and the "-ed" ending in English ($mAde$, $saId$, played)

**What is true.** The skeptic was right that the sentence asserts an origin rather than a spelling,
that all three examples end in the same suffixal /d/, and that Phase 1's rewrite made things worse by
saying the dental suffix had "worn down" in exactly the two words where it survives intact. The
second opinion restored the finding on the markup instead: `$mAde$` reddens the a, which is the one
letter that did not change, since the a of *made* is the a of *make*. Its proposed one-character fix
was `$maDe$`, and it routed the question to Phase 3 explicitly.

**Phase 3 owns the outcome and went further.** Its recommendation removes both spans rather than
recasing one, on the ground that the sentence's English half is meant to mirror its German half and
only the German half does: *machte*, *sagte* and *spielte* are three regular weak preterites, bare,
all spelling the "-te" the sentence illustrates, while the English half offered two irregulars
wrapped in red and left the one regular example unmarked. See
[H13](#h13-the--ed-list) for the full argument and for the alternative if Josh prefers to keep *made*
and *said*.

**Sources.** Etymonline, s.v. *made*, *said*, *play*, *spiel*; Middle English Compendium; Old English
Online on class III weak verbs.

**English.**

> This is the origin of the "-te" ending in German preterites (machte, sagte, spielte) and the "-ed" ending in English (loved, worked, played).

**German.**

> Dies ist der Ursprung der "-te"-Endung in deutschen Präterita (machte, sagte, spielte) und der "-ed"-Endung im Englischen (loved, worked, played).

**Reports.** [`verdict_D12.md`](verb_history_phase2_reports/verdict_D12.md),
[`second_D12.md`](verb_history_phase2_reports/second_D12.md),
[`verb_history_phase3.md`](verb_history_phase3.md)

### D17 · EN 155 / DE 121 · cluster D · restored by the second opinion

> Speakers of Modern English are aware that the conjugation later became "crowed"

**What is true.** The skeptic killed one leg correctly: the essay never claims *crew* is extinct. Its
refutation of the other leg does not hold, because it works by deleting the words "later became" from
the sentence it is defending, and because its register-marker defense assumes the reader is an English
speaker, which the German localization's reader is not. *Crew* survives in the King James idiom and in
some varieties; what happened is that the strong preterite yielded to the weak one, and saying so is
both shorter and true in both languages.

**Sources.** Oxford Advanced Learner's Dictionary and Dictionary.com, s.v. *crow* (verb); Etymonline,
s.v. *crow*; Krygier, *The Disintegration of the English Strong Verb System*.

**English.**

> The strong preterite later gave way to the weak "crowed".

**German.**

> Das starke Präteritum wich später dem schwachen "crowed".

**Reports.** [`verdict_D17.md`](verb_history_phase2_reports/verdict_D17.md),
[`second_D17.md`](verb_history_phase2_reports/second_D17.md)

### R2a · EN 92 / DE 58 · cluster E · partly upheld, regraded down

> Linguists reconstruct PIE *tewtéh₂, from the root *tew- ("to swell, be strong"), as a word meaning "the full community" or simply "the people"

**What is true.** The derivation from the swelling root is disputed by Beekes (1998), but Beekes
himself opens by conceding that it "is generally accepted", and Delamarre and Meini rejected his
attack in print. So the essay represents the consensus correctly and the defect shrinks from Phase 1's
needs-hedging to a two-word softening: the derivation is what linguists usually give, not what the
reconstruction rests on.

**Sources.** Beekes, "The origin of Lat. *aqua*, and of *teutā* 'people'", *Journal of Indo-European
Studies*; Linda Meini, "Some remarks on the etymology of *teutā*"; Matasović, *Etymological Dictionary
of Proto-Celtic*.

**English.**

> Linguists reconstruct PIE *tewtéh₂ as a word meaning “the full community” or simply “the people”, and usually trace it to the root *tew- (“to swell, be strong”).

**German.**

> Linguisten rekonstruieren PIE *tewtéh₂ als ein Wort für „die gesamte Gemeinschaft“ oder schlicht „das Volk“ und führen es gewöhnlich auf die Wurzel *tew- („schwellen, stark sein“) zurück.

**Collides with R2c**, two sentences later in the same paragraph.

**Reports.** [`verdict_R2a.md`](verb_history_phase2_reports/verdict_R2a.md)

### R9 · EN 125 / DE 91 · cluster E · restored by the second opinion, regraded down

> These vowel changes are direct inheritances from Proto-Indo-European, preserved across five millennia of linguistic evolution.

**What is true.** The skeptic correctly showed that "these vowel changes" refers to the alternations
rather than to the vowels, and that "inherited" contrasts with borrowed rather than with changed. It
then let "preserved" ride in free. "Preserved across five millennia of linguistic evolution" argues
for stasis, and the three-slot alternation printed directly above it is a New High German reduction of
the four-slot Old High German paradigm: *sang* against *sungum*. So the paragraph corrects the
vowel-quality overstatement and never the pattern-continuity one.

**Sources.** Ad fontes (Universität Zürich), "Ablaut: Systematik der starken Verben"; Ringe, *From
Proto-Indo-European to Proto-Germanic*, via secondary summary; Middle High German teaching material on
the strong verb.

**English.**

> These vowel changes descend from Proto-Indo-European ablaut, carried across five millennia by sound change and analogy rather than preserved unchanged.

**German.**

> Diese Vokalwechsel stammen vom proto-indoeuropäischen Ablaut ab, über fünf Jahrtausende von Lautwandel und Analogie getragen, nicht unverändert bewahrt.

**Interacts with H6 and with G16 and G13**, the two thin confirmations that lean on the same
five-millennia figure. This correction keeps the figure, so those rows are unaffected on the
arithmetic; what it changes is the claim of stasis, which is exactly the claim H6 says the closing
sentence at EN 185 reasserts without qualification.

**Reports.** [`verdict_R9.md`](verb_history_phase2_reports/verdict_R9.md),
[`second_R9.md`](verb_history_phase2_reports/second_R9.md)

### E1 · EN 156 / DE 122 · cluster E · upheld

> The Germanic dialects spoken in what is now southern Germany and Switzerland developed into Old High German (roughly 750–1050 AD)

**What is true.** Old High German territory is defined by participation in the second sound shift and
includes Franconian, which is Fulda, Mainz, Trier and Cologne, alongside Alemannic and Bavarian. The
essay's geography omits the band that produced most of the corpus and leaves the paragraph's own
Kölsch example with nowhere to sit. Nothing false is stated and no verb fact depends on it, which is
why this is a nitpick. Phase 1's replacement was certified unchanged.

**Sources.** Harbert, *The Germanic Languages* (Cambridge Language Surveys); Universität Zürich, *Ad
fontes*, "Die althochdeutsche Sprachlandschaft"; Braune/Reiffenstein, *Althochdeutsche Grammatik I*,
via preview.

**English.**

> The Germanic dialects spoken in what is now southern and central Germany, Austria, and Switzerland developed into Old High German (roughly 750–1050 AD), distinguished from other Germanic languages by the ~High German consonant shift~.

**German.**

> Die germanischen Dialekte, die im heutigen Süd- und Mitteldeutschland, in Österreich und der Schweiz gesprochen wurden, entwickelten sich zum Althochdeutschen (etwa 750–1050 n. Chr.), das sich von anderen germanischen Sprachen durch die ~hochdeutsche Lautverschiebung~ unterschied.

**Collides with E3**, which adds two sentences to the same paragraph, and with
[H19](#open-decisions-for-josh), which proposes a bridging clause on this same sentence.

**Reports.** [`verdict_E1.md`](verb_history_phase2_reports/verdict_E1.md)

### E3 · EN 156 / DE 122 · cluster E · restored by the second opinion on a different basis

> This series of sound changes transformed voiceless stops into fricatives or affricates (p → pf or ff; t → ts or s; k → ch)

**What is true.** Phase 1's stated rationale is backwards, and the skeptic rescued the false claim
with a lenition story that Braune's grammar contradicts, instead of striking it. What survives is
narrower and better: the essay defines the named shift more narrowly than the handbooks do, with no
hedge marking the narrowing, and the phase it omits is the one that turned Old High German *-ta*
against Old Saxon *-da*. That is the change that gave the German weak preterite the *-te* the essay
introduced two paragraphs earlier, so it is a gap the essay's own argument opens rather than generic
enrichment.

**Sources.** Braune / Ebbinghaus, *Abriß der althochdeutschen Grammatik*, §18 and §20; Paul Kiparsky,
"The Germanic Weak Preterite"; DWDS *Etymologisches Wörterbuch* (Pfeifer), s.v. *tun*.

**English.** An addition rather than a replacement. Recommended position: immediately after "where
English has ~pound~, ~water~, and ~make~." and before "The effects of the shift were not uniform."

> A later stage of the same shift turned Germanic d into t across much of the High German area. It is why ~machen~ builds its preterite as ~machte~ where English ~played~ keeps the older d, and why *dō- itself is ~tun~ in modern German.

**German.**

> Eine spätere Stufe derselben Verschiebung machte aus germanischem d ein t im größten Teil des hochdeutschen Gebiets. Sie ist der Grund, weshalb ~machen~ sein Präteritum als ~machte~ bildet, wo das englische ~played~ das ältere d bewahrt, und weshalb *dō- im modernen Deutsch ~tun~ heißt.

This adds four `~…~` spans and one asterisk in each language; see
[Bookkeeping](#bookkeeping-the-corrections-create).

**Reports.** [`verdict_E3.md`](verb_history_phase2_reports/verdict_E3.md),
[`second_E3.md`](verb_history_phase2_reports/second_E3.md)

### R8 · EN 121–123 / DE 87–89 · cluster E · partly upheld, and it is a span fix

> 🇩🇪 nehmen, $nahm$, $genOMmen$ (take, $tOOk$, taken)

**What is true.** The cognate complaint fails. Parenthesized English after a German bullet is a
translation slot throughout this essay, so line 122 never asserts that *nehmen* and *take* are
cognate. The skeptic reached that conclusion through a mis-parsed example and a false equivalence,
which is why the grade drops only to nitpick rather than to none. What the second opinion added is
mechanical and decisive: `$nahm$` is the only one of the essay's 27 marked forms with no uppercase
letter at all, so the row's preterite renders entirely black between `$sAng$` above it and `$gAb$`
below it, in the list whose whole job is to show the ablaut vowel.

**Sources.** Etymonline, s.v. *take* and *give*; Old English Online, class IV and class VI strong
verbs; DWDS s.v. *brechen* quoting Pfeifer; mechanical extraction over both localizations.

**English and German**, identical, at EN 122 and DE 88, incorporating span corrections 5 and 6:

> 🇩🇪 nehmen, $nAhm$, $genOmmen$ (take, $tOOk$, taken)

**Optional, if the cognate parallel is wanted after all**, same line in both files:

> 🇩🇪 brechen, $brAch$, $gebrOchen$ (break, $brOke$, $brOken$)

The optional swap has not been checked against the app's conjugator and would need to be before it
ships, since Phase 3's method is what settles span values. **Collides with span corrections 5 and 6**
and with **H11**, which is the same question and is answered under
[Span corrections](#span-corrections-against-the-app).

**Reports.** [`verdict_R8.md`](verb_history_phase2_reports/verdict_R8.md),
[`second_R8.md`](verb_history_phase2_reports/second_R8.md)

### F16 · EN 171 / DE 137 · cluster F · upheld

> and vowel differences between singular and plural (ich $kAnN$ vs. wir können)

**What is true.** The sentence attributes singular-to-plural vowel alternation to an explicitly
enumerated, closed set of six preterite-presents, and *sollen* has none: *ich soll*, *wir sollen*.
IDS grammis cannot state the same generalization without writing the exception into the sentence:
"Die Modalverben (außer sollen) und wissen besitzen getrennte Präsensstammformen für Singular und
Plural." Phase 1 graded and fixed this correctly, and the skeptic certified the prose unchanged.

**Sources.** IDS grammis, kontrastive Grammatik, inflection of the modal verbs; Wright, *Old High
German Primer* §194 and §198, and *Middle High German Primer* §93; DWDS Pfeifer, s.v. *sollen*.

**English**, with span correction 16 applied:

> and vowel differences between singular and plural in all of them but ~sollen~ (ich $kAnn$ vs. wir können)

**German.**

> und Vokalunterschiede zwischen Singular und Plural bei allen außer ~sollen~ (ich $kAnn$ vs. wir können)

**Collides with span corrections 16, 17 and 18**, all three on this line in both files. **Related but
now closed:** Phase 3 found that the app itself conjugated *sollen* wrongly, which is finding A under
[Findings against the app](#findings-against-the-app-rather-than-the-essay); it was fixed on
2026-07-29, and the essay was right all along.

**Reports.** [`verdict_F16.md`](verb_history_phase2_reports/verdict_F16.md)

### G4 · EN 174 / DE 140 · cluster G · partly upheld

> 🇩🇪 Old: Wenn ich $kÄme$... (If I $cAme$...)

**What is true.** The label is wrong: *Wenn ich käme* is not old German, it is the synthetic
Konjunktiv II, current and standard. The mislabel is real and nitpick is the right grade. Phase 1's
Duden citation does not check out on the page it names, and its fix repaired only one label of a
two-label contrast, which would have left "Synthetic" opposite "Modern alternative". Both labels move.

**Sources.** IDS grammis, Systematische Grammatik, on Konjunktiv syncretism; Duden Sprachratgeber,
"Konjunktiv II oder 'würde'-Form?"; Google Books Ngram Viewer, German 2019 corpus, *käme* against
*kommen würde*.

**English.**

> 🇩🇪 Synthetic: Wenn ich $kÄme$... (If I $cAme$...)
> 🇩🇪 Periphrastic: Wenn ich kommen $wÜrde$... (If I $wOUld$ come...)

**German.**

> 🇩🇪 Synthetisch: Wenn ich $kÄme$... (If I $cAme$...)
> 🇩🇪 Periphrastisch: Wenn ich kommen $wÜrde$... (If I $wOUld$ come...)

**Reports.** [`verdict_G4.md`](verb_history_phase2_reports/verdict_G4.md)

---

# Span corrections against the app

Phase 3 ran Konjugieren's own conjugator over every German form the essay marks with `$…$`, in a
temporary Swift Testing suite that was deleted afterward. Uppercase inside `$…$` means irregular and
is reddened by `RichTextView`, keyed on `Character.isUppercase` in
`StringExtensions.parseConjugationToSegment`, so a span's capitalization is a factual claim about
what a regular composition would not produce.

**Sixteen of the 27 spans are German and the app can arbitrate them. Nine were wrong: seven German,
two English.** Four distinct German values change, at seven occurrences, and the English `-ed` list
loses its two spans.

The two language files carry byte-identical spans in the same order, verified element by element
rather than assumed, so **every line below lands in both files in the same edit**. A one-sided fix
ships a stale German value marked `translated`, which does not fall back to English.

| # | was | becomes | occurrences | EN line / DE line | why |
|---|---|---|---|---|---|
| 5 | `$nahm$` | `$nAhm$` | 1 | 122 / 88 | marks nothing at all; the app emits `nAhm` from `nehmen`'s `Ahm,bA` |
| 6 | `$genOMmen$` | `$genOmmen$` | 1 | 122 / 88 | over-marks the first m; the app's group is `Omm,pp` and marks only the O |
| 16–18 | `$kAnN$` | `$kAnn$` | 3 | 171 / 137 | over-marks the second n and splits a geminate; `AblautGroups.xml` has `kAnn*` |
| 24–25 | `$lIest$` | `$lIEst$` | 2 | 180 / 146 | under-marks the e of the digraph; `lesen` takes group `sehen`, `IE,a2s,a3s` |
| 10–11 | `$mAde$`, `$saId$` | removed | 2 | 153 / 119 | see [H13](#h13-the--ed-list) |

All four replacements still satisfy the sync script's lone-capital rule, since each begins with a
lowercase letter and so may open a sentence without a capital reading as one more red letter.

**Where the essay's instinct was not baseless.** Two of these are worth knowing about, because they
were decided by deference to the app rather than by an independent argument, and would have to be
revisited if the app's own marking is ever revised. `$genOMmen$`: the base stem has one m and the
participle has two, so one of those m's genuinely is new material, and the app arguably under-marks
it. `$kAnN$`: across the preterite-present family the app is inconsistent with itself, since `kAnn`
marks the vowel, `mUsS` and `wIlL` mark the vowel and the final consonant, and `darF` marks the final
consonant and not the vowel. `$kAnN$` matches the majority pattern in the app's data; it just does
not match the one entry it is quoting.

**Why `lIEst` rather than `lIest`.** In *liest* the digraph ⟨ie⟩ is a single grapheme for a single
long vowel, and the ⟨e⟩ inside it is not the surviving ⟨e⟩ of ⟨les⟩; the two spell different phonemes.
Writing `lIest` tells the reader that one letter of the stem survived the alternation, which is
false. The decisive practical argument is the same one that settles the other spans: a reader who
meets `lIest` in the essay is one tap from the verb detail view, where the app shows *liest* with
both letters red, and an essay whose highlighting contradicts the app one tap away teaches the reader
to distrust the highlighting.

### H11: `$nahm$` against `$gAb$`

**Answered. `$nahm$` gives way and becomes `$nAhm$`.** Agent H's form of the question needs no appeal
to the app: *nehmen* and *geben* are the same case, an e-to-a strong preterite, presented in adjacent
bullets of one three-item list, and one marks its ablaut vowel while the other does not. The app
settles which is right without ambiguity: `nehmen` carries `Ahm,bA` and emits `nAhm`; `geben` carries
`A,bA` and emits `gAb`. The essay's `$gAb$` already agrees with the app and its `$nahm$` does not.
The list exists to demonstrate EN 119's claim that PIE ablaut became the German alternations, and a
span with no uppercase demonstrates nothing: it renders exactly as unmarked prose would.

### H13: the "-ed" list

**Answered. The example list gives way.** The sentence's German half and English half are meant to be
parallel and only the German half is. *Machte*, *sagte* and *spielte* are three regular weak
preterites, all bare, all spelling the "-te" the sentence illustrates, and the app emits exactly those
three strings with no uppercase anywhere. The English half offered `$mAde$`, `$saId$` and played:
neither of the first two spells "-ed"; both were wrapped in spans whose uppercase renders them red for
"irregular", inside a sentence whose whole point is that they exemplify the regular pattern; and
*played*, the only one that actually exhibits the ending, was the only one with no span.

`$mAde$` is additionally wrong on its own terms. The irregularity in *made* is the lost k of *make*,
not the vowel: the a of *made* is the a of *make*, unchanged. The span reddened the one letter that
did not change and left unmarked the change that happened. The notation cannot mark a deleted letter,
which is a reason to choose a different example rather than to recase this one, and it is why Phase 3
declined the second opinion's `$maDe$`.

**Recommended, identical in both files**, and the same prose D12 carries:

> This is the origin of the "-te" ending in German preterites (machte, sagte, spielte) and the "-ed" ending in English (loved, worked, played).

**Alternative, if Josh prefers to keep *made* and *said***, since both really are weak preterites with
the dental suffix still inside them: unwrap both to bare `made, said, played` and reword the clause to
say "the dental suffix in English" rather than "the '-ed' ending", because the claim as written is
about the spelling. The recommendation above is preferred, since it keeps the claim and repairs the
examples.

Either fix removes two spans and takes the essay from 27 to 25.

---

# Internal consistency: agent H's 16 items

Agent H held both languages at once with no cluster and no web access, and asked one question: does
anything here contradict anything else here? Nineteen items came back. **These are not findings and
must not be read as though they were.** Research cannot settle them; most are a choice about which of
two sentences gives way, which is Josh's call. Two of the nineteen, H11 and H13, turned on span
values and went to Phase 3, which answered them above. H14 is Josh's and is stated at the end.

The synthesis this phase adds: **five of the sixteen are already discharged by corrections above, and
one is superseded by a finding that died.** Eleven remain open.

## Discharged by a surviving finding

| Item | The tension | What discharges it |
|---|---|---|
| **H1** | EN 102 hedges whether the augment goes back to PIE at all and gives past marking to the secondary endings; EN 150 restores the augment as the thing that "had marked past tense in PIE". Two contradictions, on antiquity and on job, present at identical strength in German. | **D7.** Its replacement drops both the antiquity claim and the presupposition of presence. It was written to address exactly the two halves H1 identified. |
| **H4** | EN 90's antecedent is "languages spoken by nearly half of humans alive today"; the list one clause later closes with Latin. | **R1.** Its replacement widens the antecedent to the family rather than editing the list, which is one of the two routes H4 named. |
| **H5** | EN 146 defines periphrasis as combinations of auxiliary verbs with main verbs; EN 180 offers *er liest*, a synthetic finite form, as its headline example of periphrasis. The essay fails its own definition, in the closing summary. | **G8.** Its replacement removes "expressed periphrastically" and replaces it with "carried by context", plus a real periphrasis in the *am*-progressive. |
| **H15** | The essay's one etymological chain to a modern German word routes through Old English and Medieval Latin and never touches Old High German, which the essay establishes 64 lines later as German's direct ancestor. | **R2c.** Its replacement puts Old High German *diutisc* into the chain as the actual ancestor. |

## Superseded by a refuted finding

**H2**, EN 187 / DE 153. H said the closing "that primordial cloud of supernova-enriched gas"
reasserts the framing that Phase 0's two largest patches were applied to remove, and is flatly wrong
on the essay's own terms because EN 80 attributes the heaviest elements to neutron-star collisions.

**Recommendation: no change, and H2 should not be actioned.** G14 is the same sentence and the same
question, researched, and it was killed twice. The second opinion's argument is the one that answers
H: EN 80 already gives supernovae "the rest", meaning the larger share of the enrichment, so EN 187's
compression follows the essay's own apportionment rather than contradicting it, and the claim is
non-exclusive rather than a claim that supernovae made everything. Specialists publish under the
phrase "supernova-enriched" for this exact cloud.

This is the one place where an unresearched internal-consistency reading and a three-pass researched
verdict disagree, and the researched verdict wins. Recorded rather than quietly dropped, because H2
reads convincingly on its own and a future session will otherwise re-derive it.

## Open decisions for Josh

Ordered as agent H graded them: contradictions first, then tensions, then nitpicks.

### H3 · contradiction · EN 92, English only

EN 92 derives *Deutsch* through the whole `*tewtéh₂` chain and then generalizes: "The word “German”,
in other words, may trace back to a five-thousand-year-old way of saying “us”." But "German" is an
English exonym, and EN 130 supplies its actual source: Latin *Germani*. **The German localization does
not have the problem**, because DE 58 names *deutsch*, which is the word the chain actually derives.
So this is a contradiction in exactly one of the two shipped languages, and the translator resolved it
correctly and invisibly.

It is a referent fix, not a fact change, and the sentence is not a patch site.

**English.**

> The word “Deutsch”, in other words, may trace back to a five-thousand-year-old way of saying “us”.

**German.** No change; DE 58 is already correct.

### H6 · tension · EN 185 / DE 151, promise against delivery

The shared half promises preservation and system: "direct inheritances", "preserved", and at EN 111
"not arbitrary sound change but a structured system". The German-specific half delivers erosion, class
blurring, strong-to-weak drift and individual memorization at EN 155 and 157. The closing at EN 185
then reverts to "survive" and "living fossil" without carrying a word of that forward. This partly
overturns Phase 0's conclusion that the promise-versus-delivery trap is empty: it is empty in the form
Conjugar had it, since Konjugieren's opening makes no learner-memorization promise, and it exists
inverted.

**R9's correction weakens the opening end of the tension** by replacing "preserved across five
millennia" with "carried across five millennia by sound change and analogy rather than preserved
unchanged". If Josh takes R9 and stops there, the closing sentence becomes the essay's only unhedged
claim of stasis.

**English**, optional:

> The ablaut patterns that once pervaded Proto-Indo-European morphology survive in the strong verbs, worn down and learned one verb at a time, a living fossil of that 5,000-year journey from the Pontic steppe to the German-speaking lands of central Europe.

**German.**

> Die Ablautmuster, die einst die proto-indoeuropäische Morphologie durchdrangen, überleben in den starken Verben, abgeschliffen und Verb für Verb gelernt, ein lebendes Fossil jener 5.000-jährigen Reise von der pontischen Steppe in die deutschsprachigen Länder Mitteleuropas.

### H7, H8 and H16 · the closing summary at EN 178 to 183 / DE 144 to 149

Three independent problems in one summary, which agent H notes is a signal about the sentence rather
than about any one of them.

**H7.** The summary puts the subjunctive in the retained column immediately after a section that spent
six lines establishing that the subjunctive went periphrastic. The cheapest repair leaves the retained
clause alone and adds a bullet:

> 🇩🇪 The ~subjunctive~ is increasingly expressed with ~würde~ + infinitive

> 🇩🇪 Der ~Konjunktiv~ wird zunehmend mit ~würde~ + Infinitiv ausgedrückt

**H8.** The closing summary is the only place the German passive and the German imperative appear at
all, and it summarizes them as though the essay had covered them, while omitting two sections the
essay did develop. Two routes: accept that a summary may exceed its body, or drop the passive bullet.
Phase 3's finding C is a mild argument for dropping it: the passive is the one item in that list the
app does not model, and the closing list is where a reader forms an expectation about what Konjugieren
contains.

**H16.** The summary lists the preterite among retained architecture with no trace of EN 163's
qualification fifteen lines earlier. Reconcilable, since a tense can be morphologically present and
pragmatically retreating, but "has" is doing different work in the two sentences. If anything gives
way it is the parenthetical:

> two morphological tenses, present and preterite, though the preterite has yielded much of its ground in speech

> zwei morphologische Tempora, Präsens und Präteritum, wobei das Präteritum in der gesprochenen Sprache viel Boden verloren hat

### H9 · tension · EN 152 / DE 118

Across two clusters the essay gives three answers to what determines strong-class membership:
present-stem structure at 152, ablaut pattern at 152 and 157, and phonological conditioning at 157.
Line 152 gives two of them inside one sentence, main clause against parenthesis. A specialist can
reconcile all three; a reader cannot. Line 152 gives way, since it is the site that states two
principles at once.

**English**, optional:

> ~Verb classes proliferated~, leading to the complex system of "strong" verb classes (organized by ablaut patterns) and "weak" verbs (a Germanic innovation using a dental suffix for the preterite).

**German.**

> ~Verbklassen vermehrten sich~, was zum komplexen System der "starken" Verbklassen (organisiert nach Ablautmustern) und "schwachen" Verben (eine germanische Innovation mit einem Dentalsuffix für das Präteritum) führte.

### H12 · tension · EN 146 / DE 112

EN 146 says Proto-Germanic, having lost the aspect system, relied on periphrastic constructions. The
essay then dates both of its periphrases to Old High German and Middle High German, thousands of years
later, and names no third. The essay's own timeline says the constructions 146 has Germanic relying on
did not yet exist. Line 146 gives way; the two later sentences are specific and dated.

**English**, optional:

> Germanic had to rely on context, and later on the periphrastic constructions (combinations of auxiliary verbs with main verbs) that its daughter languages built.

**German.**

> musste das Germanische sich auf den Kontext verlassen und später auf die periphrastischen Konstruktionen (Kombinationen von Hilfsverben mit Hauptverben), die seine Tochtersprachen ausbildeten.

Note that G8's correction already removes the other end of this problem, since it stops calling *er
liest* periphrasis.

### H10 · tension · EN 102 against EN 106, both patched

The tense paragraph hedges PIE futurity as "arguably" and the mood list four lines later asserts a PIE
category whose defining job is futurity, flatly. **Both sentences are pasted patch text from Conjugar
and the verbatim rule covers both**, so no rewording is proposed. This is the clearest example in the
run of what the verbatim rule costs: in Conjugar's longer opening the two sentences were separated by
much more text. If Josh wants it resolved, the resolution is a decision about which of two Conjugar
sentences to override.

The German loses the mismatch in the other direction, because DE 68 renders "arguably future" as "wohl
auch Zukunft", which is closer to "probably". That is item 2 of the German-surface list below and it
is a hedge weakening, so fixing the German would restore the English mismatch rather than remove it.

### H17 · nitpick · EN 93 / DE 59

The zero-grade bullet at EN 115 is defined as the absence of the vowel that the CVC generalization at
EN 93 requires, so the essay's own ablaut list is a systematic counterexample to the shape it gave
roots twenty-two lines earlier. "Typically" absorbs most of this. If anything gives way it is 93,
which could name the exception it is already hedging against.

**English**, optional:

> PIE verbs were built on roots (typically consisting of a consonant-vowel-consonant structure, with the vowel absent in the zero grade) that carried core meaning.

**German.**

> PIE-Verben wurden auf Wurzeln aufgebaut (typischerweise aus einer Konsonant-Vokal-Konsonant-Struktur bestehend, wobei der Vokal in der Nullstufe fehlt) die die Kernbedeutung trugen.

### H18 · nitpick · EN 169 / DE 135

Two members of a six-item gloss list are given the same English word as their primary translation,
*dürfen* (may) and *mögen* (may/like), in the same parenthetical series, so the list does not
distinguish the two verbs it exists to distinguish. **If Josh takes this, it lands inside F13's
replacement sentence**, so here is the merged form:

> These include the modal verbs ~können~ (can), ~müssen~ (must), ~dürfen~ (be allowed to), ~sollen~ (shall), and ~mögen~ (like), together with ~wissen~ (to know), which shares their history but is a full verb, not a modal.

> Dazu gehören die Modalverben ~können~ (can), ~müssen~ (must), ~dürfen~ (be allowed to), ~sollen~ (shall) und ~mögen~ (like), dazu ~wissen~ (to know), das ihre Geschichte teilt, aber ein Vollverb ist und kein Modalverb.

### H19 · tension · EN 156 / DE 122

The essay locates Germanic in the far north twice, at EN 128 and 130, then without narrating any
movement locates the ancestor of German in the far south at EN 156. Nothing bridges roughly a thousand
kilometres and a thousand years, and EN 185's "journey from the Pontic steppe to the German-speaking
lands of central Europe" implies a continuous path the body never draws. This is a gap rather than a
correction, and neither site is wrong.

E1's replacement widens the southern geography and narrows the gap slightly without closing it.
**A bridging clause would assert a migration claim that this run did not check**, so it is offered
with that caveat rather than as a correction, and it should get a verdict before it ships:

> As Germanic speakers spread south from those coasts over the following centuries, the dialects of what is now southern and central Germany, Austria, and Switzerland developed into Old High German (roughly 750–1050 AD), distinguished from other Germanic languages by the ~High German consonant shift~.

> Als sich germanische Sprecher in den folgenden Jahrhunderten von jenen Küsten nach Süden ausbreiteten, entwickelten sich die Dialekte im heutigen Süd- und Mitteldeutschland, in Österreich und der Schweiz zum Althochdeutschen (etwa 750–1050 n. Chr.), das sich von anderen germanischen Sprachen durch die ~hochdeutsche Lautverschiebung~ unterschied.

### H14 · Josh's, and still open

Phase 1 recorded the tension between the essay's claim that ablaut is systematic, at EN 111 and 157,
and the app's rendering of those same alternations inside `$…$` as red irregularities at EN 121 to
123. Both are defensible: the app's "irregular" is synchronic, the essay's "systematic" is diachronic.
The essay never says so. **Phase 3 notes that fixing the four wrong spans makes the tension slightly
sharper rather than softer, since more letters end up red, not fewer.** The place a bridging clause
could go is EN 157, which already contains the essay's only acknowledgement that the patterns are
systematic and unpredictable at once, and which E12's correction rewrites. It remains an editorial
decision about whether the essay should explain its own red letters.

## The German as a second surface

Agent H's seven observations about the existing translation. **The first two change hedge strength,
which is the failure the verbatim rule exists to prevent, and both are in patched text**: the hedge
survived the port from Conjugar and then did not survive the translation. They are corrections to the
German alone, since the English is right.

1. **DE 51, hedge weakened.** DE "Vor 40.000 Jahren, womöglich früher, hatten Menschen die
   pontisch-kaspische Steppe erreicht" against EN "By 40,000 years ago, and quite possibly earlier,
   humans had reached the Pontic-Caspian steppe". Two weakenings in one clause: "quite possibly" is
   an emphatic hedge asserting that earlier is a live reading, and "womöglich" is a plain "possibly";
   and English "By 40,000 years ago" states an upper bound while the German reads as a point in time,
   because there is no "bis". The German asserts a date the English only caps. Suggested:
   *Bis vor 40.000 Jahren, sehr wohl auch früher, hatten Menschen die pontisch-kaspische Steppe erreicht.*
2. **DE 68, hedge reversed.** DE "und wohl auch Zukunft" against EN "and arguably future
   expressions". "Arguably" flags a contested reading; "wohl" means presumably and reads as a mild
   affirmation. An English hedge that concedes a dispute becomes a German assertion. This sits one
   sentence after the patched augment hedge, in a paragraph whose entire job is to say PIE tense was
   thin and contested. Suggested: *und, wie manche annehmen, auch Zukunft*. See H10: fixing this
   restores the English mismatch, so the two decisions are linked.
3. **DE 58.** Not a hedge change. The referent differs, and the German is the correct one. This is
   the evidence that settles H3.
4. **DE 122, self-refuting.** "Das schweizerdeutsche Wort für "Küche" ist daher "Chuchi", im Gegensatz
   zum Hochdeutschen "Küche"." The English works because its head word is English and its contrast
   term is German. The German translated the head word, so the sentence now says that the Swiss German
   word for *Küche* stands in contrast to *Küche*. The English contains no defect, so this cannot be
   fixed by re-translating; the German sentence needs recasting. Suggested:
   *Im Schweizerdeutschen heißt es daher "Chuchi", wo das Hochdeutsche "Küche" hat.*
5. **DE 124, 130, 135, 138.** Ten English glosses of ordinary German verbs survive untranslated in the
   German essay, where they do no work: a German reader is told that *haben* means "to have". These
   are parentheticals, not `$…$` spans, so the German header's invariant about English staying English
   does not cover them; that rule is about the conjugation spans. The distinction matters because the
   German text elsewhere uses English content-bearingly and correctly, at DE 122's "wo das Englische
   ~pound~, ~water~ und ~make~ hat" and DE 146's "er $lIEst$ = he reads/is reading", where the contrast
   is the point. Editorial, and it touches F13's and F8's replacement sentences if taken.
6. **DE 110, rank of a qualification.** EN uses a participial adjunct, subordinating the merging to the
   loss; the German promotes it to a coordinate clause joined by a bare comma, which German licenses.
   The German states the merging slightly more firmly. The only place in the essay where the German
   changes the grammatical rank of a qualification.
7. **DE 68, an asymmetry in the German's favour**, recorded so it is not later "fixed" the wrong way.
   English now uses "secondary" twice in consecutive sentences in two unrelated senses, subordinate and
   technical, with the second bolded by the patch. German renders the first as "untergeordnet" and has
   no collision. If anyone harmonizes, the direction is English toward German, and the English half is
   pasted patch text that must not be reworded.

## Patch-site notes

Agent H also recorded ten observations about the sentences Phase 0 pasted verbatim from Conjugar:
redundancy and register breaks at the patch sites, most visibly the lactose material at EN 88, which
is now 84 of that paragraph's 155 words in a paragraph whose topic sentence is about social structure.
**No rewording was proposed for any of them**, because rewording pasted text is the thing the
verbatim rule exists to prevent. They are in
[`docs/verb_history_phase1.md`](verb_history_phase1.md) under `## Agent H: internal consistency`,
subsection "Patch-site notes", and they are what Josh looks at when he reads the Phase 0 diff.

### One patch site was actioned by Josh, 2026-07-29

**P1's redundancy, the only one of the ten to be acted on.** Agent H observed that the opening
paragraph names stellar winds twice under two names about ninety words apart: `some shed quietly on
the winds of aging giants` early, and `in the winds of dying giants` inside the pasted closing
clause. Same referent, two adjectives, far enough apart that the second reads as new information
that is not new.

Josh reviewed the sentence, kept its length and its register, which is the part agent H filed as a
cost, and cut the later clause. The tail now reads:

> …and dozens of other elements that no star makes in its long middle age, forged instead in the crush of collapse and, for the heaviest, in the collision of two neutron stars.

> …und Dutzende anderer Elemente, die kein Stern in seinem langen mittleren Lebensalter erzeugt, sondern die im Zusammenbruch geschmiedet werden und, für die schwersten, im Zusammenstoß zweier Neutronensterne.

Nothing factual is lost, because the winds are still named in the same sentence, and the three-item
list becomes two, which is why the serial comma before `and` goes with it. No marker count changed.
The English body loses six words and the German five.

**This is a deliberate edit to pasted patch text, and it is the first one.** It is recorded here
rather than left to a future diff, because a session comparing Konjugieren's shared sections against
Conjugar's corrected prose will find a divergence at this exact clause and needs to know it is a
decision rather than a botched port. The verbatim rule was always a default for agents, with the
author reserving the judgement; this is the author exercising it.

One consequence worth noting for anyone who reuses these sections. **The register break agent H
flagged at P2 survives, on the author's explicit preference.** "Elements that no star makes in its
long middle age" is still the only clause in the paragraph that personifies a star, and it is still
the longest non-list clause. H was right that it departs from the paragraph's habit of terse
appositive glosses, and wrong that the departure is a cost: it is what makes the sentence's tail read
as a turn rather than as a run-on. Do not "fix" it.

---

# Confirmed rows whose reasoning is thin

**These are not findings and no correction is proposed for any of them.** They are rows that came back
`confirmed` on reasoning that does not carry the verdict. Nothing here was researched, and none is a
predicted error; the auditor had no web access and no authority to open questions of fact. Four of the
eighty are worth reopening if anyone runs another pass.

| Row | Line | The defect in the audit trail |
|---|---|---|
| **G16** | EN 187 | "still sounding after fifty centuries" is confirmed only against the essay's own internal consistency, and the row then meets the one external fact it raises, patch S1's move of the Yamnaya horizon to 3300 BC, by appealing to "the tolerance the surrounding prose sets for itself". That is exactly what a fact-check may not accept as a warrant. Compounding it, one of the four corroborating occurrences it leans on, EN 92, **has no inventory row at all**. |
| **D1** | EN 143 | "some two millennia" has no external support: the single source is disclaimed in its own annotation as not assigning the interval, and the row closes "I did not research the endpoints themselves." Its own arithmetic yields fifteen hundred to two thousand years, and fifteen hundred is not two millennia. It derives the range partly from A7, which is not a confirmed row but a live nitpick whose correction moves Proto-Germanic toward the lower end. |
| **C8** | EN 140 | "no centralized states or cities" is a compound claim whose halves get very different treatment. The cities half is asserted with no citation covering it. The states half confirms a universal by noting that the standard accounts call Maroboduus an exception, and Rome recognised his kingdom in AD 6, inside the paragraph's own date. |
| **C7** | EN 138 | confirms "gold" while its own evidence establishes "treasure": *Germania* 15's *phalerae torquesque* are precious-metal objects, and the row's own research says the imports contemporary with the battle are bronze, silver and glass while Germanic gold rings belong mainly to c. 150 AD and after. That archaeological dating is sourced to grokipedia.com. The one-word repair the row considered and declined is the repair its own reasoning argues for. |

**Note-only, below the reopening bar:** C11, whose independent comparative strand carries no citation
while both cited sources are Tacitus; E7, whose entire external warrant for the Kölsch unshifted /t/ is
two grokipedia.com pages, on facts that are textbook and would survive any challenge; and G13, which
has the same self-referential structure as G16 but is anchored to an externally sourced date.

**One structural observation about the inventory rather than about anyone's conduct.** The
five-millennia figure has four occurrences and three owners: R9 at EN 125 in cluster E, G13 at 185 and
G16 at 187 in cluster G, and EN 92, which has no inventory row. G13 and G16 partly corroborate
themselves by pointing at each other and at 92, so three rows lean on one another around a single
external date. Whoever settles one of these must settle all four. Partitioning by claim prevents
duplicated research; it does not prevent a claim from being distributed across cells that cite each
other.

Full report: [`coverage_audit.md`](verb_history_phase2_reports/coverage_audit.md).

---

# Findings against the app rather than the essay

Phase 3 checked the essay against Konjugieren's code and corpus. It found four things that are not
essay errors. **The chief one is already fixed and needs no action.**

**A. `sollen` conjugated wrongly, and the essay was right. Fixed 2026-07-29.** In `Verbs.xml`,
*sollen* was `fa="w"` with no ablaut group, unlike the other five preterite-presents, so the app
emitted *ich solle* and *er sollt* rather than *ich soll* and *er soll*. EN 171's claim about the class
is correct German and the corpus contradicted it. It survived because it was untested: `modalVerbs()`
covered *mögen*, *wissen* and *wollen* only, so four of the six verbs the essay names, including the
broken one, had no test anywhere. *Sollen* now has its own ablaut group, `modalVerbs()` covers all six
preterite-presents, and the suite passes at 211 tests.

The three that remain are recorded here without proposed corrections, since none is an error in the
essay. Details are in [`verb_history_phase3.md`](verb_history_phase3.md) under "Claims the essay makes
about Konjugieren".

**B. `auslesen` is glossed in a sense the corpus does not ship.** EN 180 reads "er $lIEst$ das Buch
aus = he finishes reading the book". *Auslesen* is in the corpus as `aus+l^e^sen`, and the translation
the app ships is "select, pick out". Both senses are real German, so the essay is not wrong, but a
reader who meets the sentence and then looks the verb up gets a different meaning with no bridge. The
corpus is the cheaper place to add a second reading.

**C. The passive is the one item in the closing list the app does not model.** EN 183 lists the
passive alongside future, perfect and aspect. The other three all correspond to something in
`Conjugationgroup`; the string "passiv" does not occur in that file. Not an error and not a bug.
Recorded because the closing list is where a reader forms an expectation about what the app contains,
which is also the argument under [H8](#h7-h8-and-h16--the-closing-summary-at-en-178-to-183--de-144-to-149).

**D. Terminology.** [`docs/terminology.md`](terminology.md) asks that "tense" not describe
conjugationgroups. The essay uses "tense" twelve times; ten are legitimate historical linguistics
about tense as time. Two are headings naming what this project calls conjugationgroups, "Development
of the Perfect Tense" and "The Future Tense and Modal Verbs". Minor and editorial, flagged rather than
recommended, since the headings are historical narrative and the German translations already avoid the
word. The "prefer conjugation over form" rule is satisfied: "form" occurs three times in the English
body and none of the three refers to an inflected verb.

---

# Refuted, and recorded

Four of Phase 1's 31 findings did not survive, each killed by two agents independently. Recorded so a
future run does not rediscover them and pay for them twice.

| Ref | Line | Claim | Why it died |
|---|---|---|---|
| **C13** | EN 142 | "worshipped in sacred groves rather than temples" | The sentence is scoped by the paragraph's "At the time of the battle at Teutoburg" dateline, and every roofed Germanic cult building anyone can cite, Gudme c. AD 200, Uppåkra, Sorte Muld, Oberdorla, postdates that moment by two centuries or more, with specialists reading the type as a Roman-contact innovation. Phase 1's replacement would have imported an undated "archaeology has since found roofed cult houses" into a paragraph datelined 9 AD, shipping the very anachronism the finding disclaimed. |
| **C6** | EN 138 | the *comitatus* "bound to their lord by oaths of loyalty" | *Germania* 14 calls the bond "praecipuum sacramentum", the Roman term for the oath of allegiance, and Perseus shows the shame clause and that phrase are one colon-divided sentence, so Phase 1's core charge denies a clause its own chapter contains. |
| **R5** | EN 110 | "with a developing passive" | The four-word coda is itself the hedge and compresses the handbooks rather than overreaching them: Kulikov and Lavidas and Grestenberger both reconstruct a passive function developing out of the middle at a late stage of PIE. Phase 1's summary denied that function. |
| **G14** | EN 187 | "that primordial cloud of supernova-enriched gas" | EN 80 already gives supernovae "the rest", the larger share of the enrichment, so the closing compression follows the essay's own apportionment; specialists publish under this exact phrase for this exact cloud. See [H2](#superseded-by-a-refuted-finding), which this also answers. |

One thing C6's second opinion caught in passing and wrongly punted to a later pass, so it lands here:
**DE 104 reads "eine ~comitatus~" for a Latin masculine and should be "einen"**.

---

# Bookkeeping the corrections create

Both file headers assert counts, and applying these corrections made several of them stale. Nothing
automated checks them: `scripts/check_docs.py` does not read `docs/verb_history.txt` or
`docs/verb_history_de.txt`, and `scripts/sync_verb_history.py` validates structure rather than
arithmetic. **The headers were updated on 2026-07-29 from counts recomputed off the edited bodies,
not from the predictions in the right-hand column.**

| Count | Header site | Before | Predicted | **Actual** | Driven by |
|---|---|---|---|---|---|
| `$…$` conjugation spans | DE header line 24 | 27 | 25 | **25** | H13 removes two |
| `~…~` emphasis spans | DE header line 26 | 59 | 68 | **70** | F8 +3, E3 +4, G8 +1, F16 +1, and H7 +2 |
| asterisks | EN header line 57, DE header line 29 | 20 | 25 | **25** | C12 +3, E3 +1, R6 +1 net |
| `` `…` `` headings | DE header line 21 | 18 | 18 | **18** | unchanged |
| `^…^` emoji spans | both headers | 3 | 3 | **3** | unchanged |
| `‡…‡` links | EN header line 38 | 0 | 0 | **0** | unchanged |

**The emphasis-span prediction was two short, and the reason is worth keeping.** The table above was
computed over the findings only. H7's new subjunctive bullet carries `~subjunctive~` and `~würde~`,
and it is an internal-consistency item rather than a finding, so it sat outside the arithmetic that
produced the estimate. A predicted count is a prediction about a fixed set of edits; the moment the
set changes the prediction is stale, which is the argument for recomputing from the file rather than
carrying the number forward. Distinct span values also fell from 17 to 15 with the removal of
`$mAde$` and `$saId$`.

Two further header repairs went in at the same time, both accuracy rather than arithmetic. The
English header described 🏴󠁧󠁢󠁥󠁮󠁧󠁿 as leading an English bulleted item, and agent H counted zero
occurrences of that glyph in either body; the header now says so, matching the scrupulousness it
already showed about links. Both headers' asterisk examples gained `*Wōðanaz`, which C12 introduced.

Three further invariants to hold while editing:

1. **The `$…$` spans must stay byte-identical across the two files.** That is a live invariant, not a
   fact: it holds today, verified element by element. Every span correction lands in both files in the
   same edit, or the German ships a stale value marked `translated`, which does not fall back to
   English.
2. **Markers must balance within each backtick-delimited block, not merely across the essay.** Bad
   markup here is `Current.fatalError.fatalError` on the Info screen rather than a render bug. Run
   `python3 scripts/sync_verb_history.py --check` for both languages after every edit; the per-block
   rule is genuinely covered and was falsified live in Phase 3 by injecting two stray tildes that
   balanced globally and not per block.
3. **The essay's asterisks are linguistics and do not pair.** Nothing balances them and nothing should.

Finally: nothing here has been synced to `Konjugieren/Assets/Localizable.xcstrings`. When it is, the
catalog holds the essay on a single JSON line, so the sync script is the only safe route; hand-editing
it there is the foot-gun `CLAUDE.md` describes, where the Edit tool renders `\"` as `"` and writes it
back unescaped.

---

# Coverage

Every one of the 111 inventory rows in [`docs/verb_history_claims.md`](verb_history_claims.md) is
accounted for below: each is either a finding in this document or an explicit `confirmed`. The
partition was settled mechanically rather than sampled. All 111 rows appear exactly once, none appears
in both the findings and the confirmed set, none was reported that the inventory does not contain, and
no cluster reported outside its own territory. Every row's quoted fragment was matched against the
text at its cited line, normalizing whitespace, the five markup characters, asterisks, curly against
straight quotes, en dash against hyphen, and the emoji bullets. **All 111 verify.**

The four refuted findings are counted as `confirmed` here, since the essay's sentence stands unchanged
in each case.

| Cluster | Rows | Verdicts | Findings in this document | Confirmed | factual-error | needs-hedging | nitpick | Missing |
|---|---|---|---|---|---|---|---|---|
| A. Into Europe | 10 | 10 | 3 | 7 | 0 | 1 | 2 | 0 |
| B. Teutoburg | 13 | 13 | 2 | 11 | 0 | 1 | 1 | 0 |
| C. Tacitus country | 14 | 14 | 5 | 9 | 1 | 0 | 4 | 0 |
| D. The Germanic verb | 20 | 20 | 4 | 16 | 1 | 1 | 2 | 0 |
| E. Old High German | 21 | 21 | 8 | 13 | 2 | 1 | 5 | 0 |
| F. Tense-building | 16 | 16 | 3 | 13 | 2 | 0 | 1 | 0 |
| G. Modern German | 17 | 17 | 2 | 15 | 1 | 0 | 1 | 0 |
| **Total** | **111** | **111** | **27** | **84** | **7** | **4** | **16** | **0** |

Phase 1 returned 31 findings graded 7 factual-error, 7 needs-hedging and 17 nitpick against 80
confirmed. Phase 2 refuted four, and of the 27 that survived it regraded four down and two up, which
is where the 7 / 4 / 16 against 84 above comes from. Measured against Phase 1 rather than against
the skeptics, the run is mostly a regrading: 21 of 31 findings ended at the grade Phase 1 gave them,
8 ended weaker counting the refutations, and 2 ended stronger. What moved is the prose.
**Fifteen of the 27 surviving findings ship replacement prose that neither Phase 1 nor its own skeptic
wrote**, which is the argument for asking a skeptic whether the proposed fix is right and not only
whether the claim is wrong.

Two coverage facts that the table cannot show, both worth carrying forward:

- **One claim in the essay has no inventory row.** EN 92's "five-thousand-year-old way of saying 'us'"
  was reported as a gap by cluster E and never assigned. G16 and G13 both lean on it as corroboration,
  so part of their internal consistency is consistency with a sentence nobody checked.
- **A coverage table's most visible column cannot fail.** Rows and Verdicts are equal by construction
  and their agreement is not evidence. The check that can fail is grade-sum against row count, and it
  passes in all seven clusters and in the totals.

## What a future session should not trust

1. **The second-opinion pass is directionally biased.** It only ever pushed toward stronger findings,
   by design. Do not read the 27-survivor count as a neutral adjudication, and do not cite Conjugar's
   104-of-188 kill rate as a validated result: those kills were never audited, and when this run
   audited its own, 11 of 15 did not survive the audit.
2. **The line numbers in this document drift** the moment anything is added to either file's header.
   Every entry quotes its claim for that reason. Locate by text.
3. **The app is the arbiter for German span values, and it is not self-consistent.** `kAnn` marks the
   vowel, `mUsS` and `wIlL` mark the vowel and the final consonant, `darF` marks the final consonant
   and not the vowel. Each span was settled individually and no rule generalizes from one modal to
   another.
4. **`CLAUDE.md`'s mixed-case example for *wissen* is wrong.** It shows `expected: "wEIsS"`; the app
   emits and the shipped test expects `wEIẞ`, with U+1E9E.
5. **Nothing here is in the catalog.** The essay ships from
   `Konjugieren/Assets/Localizable.xcstrings`, which still holds the pre-Phase-0 text. Even the ten
   Phase 0 patches are not shipped yet.
