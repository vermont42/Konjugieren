# Claim inventory for "A History of the German Verb System"

Built in Phase 0 of [`prompts/verify-verb-history.md`](../prompts/verify-verb-history.md) on
2026-07-28, before any researcher was spawned. **This file, not the section ranges in the
prompt, is what each cluster works from.** Where the two disagree, this wins, because it is the
only artifact that guarantees no claim is researched twice and none is researched zero times.

111 rows. Every checkable assertion in the German-specific half of the essay, plus the nine
residue items carried in from the shared half, which occupy thirteen rows because the
*tewtéh₂* etymology splits into five links that can be judged separately. Every row has exactly
one owning cluster.

## How to read it

**Line numbers refer to the patched `docs/verb_history.txt`.** Adding to that file's header
shifts every body line, so locate a row by its quoted text if the number looks wrong.

**A heading shares a line with the paragraph before it.** `The Battle of the Teutoburg Forest`
sits at the end of line 130, which is otherwise the last paragraph of `The Migration to Europe`.
So a section's first line number is one past where a reader would expect it.

**`kind`** is one of: date, number, name, etymology, sound law, consensus attribution, quoted
verb form. A row can be checkable in more than one way; the tag names the one that decides it.

**`depends-on`** names a row whose verdict you must know before judging this one. **Do not
research a row you do not own, even when your own row leans on it.** Cite the dependency and
state what your verdict assumes. If the owner's verdict has not landed, flag it and move on;
agent H resolves anything still open.

**Return a verdict for every row you own, `confirmed` ones included, keyed by row number.** A
row with no verdict is an unfinished job, not a passed one.

## Rows the shared half already settled

Three patched sentences are cited by rows below. They are **settled** and must not be
re-litigated. If one looks wrong, report it as a note for agent H.

| Ref | Line | What it now says |
|---|---|---|
| S1 | 86 | The Yamnaya horizon runs from roughly 3300 BC, and whether they rode is disputed; the wheel carries the mobility claim |
| S2 | 86 | The Yamnaya were lactose intolerant. Dozens were genotyped directly and none carried the persistence allele |
| S3 | 93 | Past time was marked chiefly by the secondary endings. The augment belongs to a few branches and its Proto-Indo-European antiquity is disputed |

## A. Into Europe

`The Migration to Europe`, lines 125 to 130. Plus residue row R1.

| # | Line | Claim | kind | depends-on |
|---|---|---|---|---|
| A1 | 126 | "Beginning around 3000 BC … the Yamnaya and their descendants began a series of migrations" | date | S1 |
| A2 | 126 | "(approximately 5,000 years ago)" as the gloss on 3000 BC | number | A1 |
| A3 | 126 | those migrations "would reshape the genetic and linguistic landscape of Europe" | consensus attribution | |
| A4 | 126 | "Equipped with horses, wheeled carts, and perhaps bronze weapons, they moved westward in successive waves" | consensus attribution | S1 |
| A5 | 128 | "The branch that would become Germanic likely separated from other Indo-European groups sometime between 2500 and 2000 BC" | date | |
| A6 | 128 | "as speakers moved into southern Scandinavia and northern Germany" | consensus attribution | A5 |
| A7 | 130 | "By the first millennium BC, a recognizable Proto-Germanic language had emerged" | date | A5 |
| A8 | 130 | "in southern Scandinavia and along the North Sea and Baltic coasts" | consensus attribution | A6 |
| A9 | 130 | "known to the Romans as ~Germani~" | name | |
| R1 | 90 | The Indo-European descendant list: "German, English, Ukrainian, Hindi, Persian, Cornish, Greek, and Latin" | name | |

**A4 is a seam.** The sentence was written when the essay claimed flatly that the Yamnaya rode.
S1 now hedges that. Owning horses is not riding them, so A4 may survive intact, but judge it
against S1 rather than in isolation.

**Coverage note.** Corded Ware, the Jastorf culture, and any appeal to a pre-Germanic substrate
appear nowhere in this range. The prompt's brief names all three. There are no rows for them
because there are no claims.

## B. Teutoburg

`The Battle of the Teutoburg Forest`, lines 130 to 135.

| # | Line | Claim | kind | depends-on |
|---|---|---|---|---|
| B1 | 131 | "In 9 AD" | date | |
| B2 | 131 | "in the densely forested hills of what is now northwestern Germany" | name | |
| B3 | 131 | "Three Roman legions" | number | |
| B4 | 131 | "under the command of Publius Quinctilius Varus" | name | |
| B5 | 131 | "(perhaps 20,000 soldiers)" | number | B3 |
| B6 | 131 | "were ambushed and annihilated", against a running engagement of three or four days | consensus attribution | |
| B7 | 131 | "an alliance of Germanic tribes led by Arminius (Hermann)"; whether *Hermann* is a name he bore or a sixteenth-century identification | name | |
| B8 | 131 | "a Romanized chieftain of the Cherusci" | name | |
| B9 | 133 | "halted Roman expansion into Germanic territory" | consensus attribution | |
| B10 | 133 | "eventually establish the ~limes~ (a fortified frontier)" | name | |
| B11 | 133 | "they never permanently conquered the lands beyond the Rhine and Danube" | consensus attribution | |
| B12 | 133 | "the Germanic languages developed free from the Romanization that transformed Gaulish into French, Iberian languages into Spanish and Portuguese, and Dacian into Romanian" | consensus attribution | B9 |
| B13 | 135 | "Had the Romans conquered Germania, the Germanic peoples might have adopted Vulgar Latin, as did so many others within the Empire" | consensus attribution | B11 |

**B11 has prior art. Read it before searching.** Conjugar's cluster G raised the near-identical
"Rome never took Germania at all" and the adversarial pass **refuted the objection and dropped
it**: the two provinces called Germania lay west of the Rhine and were reckoned part of Roman
Gaul, and reference works state flatly that the territories east of the Rhine remained outside
Roman control. See `/Users/josh/Desktop/workspace/Conjugar.mig/docs/history_corrections.md`,
cluster G, "Raised and dismissed". Konjugieren's wording is narrower than the one that was
refuted, so the row still needs a verdict, but re-running that research is waste.

**B9 and B12 are the cluster's real work.** The prompt flags the claim that Teutoburg kept
Latin out of Germania as a popular simplification, and B12 extends it into a four-way
comparison, one leg of which ("Dacian into Romanian") describes language replacement rather
than transformation.

**Coverage note.** The essay names no legion numbers and does not quote Suetonius. Both appear
in the prompt's brief. No rows.

## C. Tacitus country

`Lifeways of the Germanic Tribes`, lines 135 to 143.

Nearly everything here traces to Tacitus's *Germania*, a moralizing text by a man who never
went. **Flag any row that presents it as straight ethnography**, and say for each row whether
archaeology corroborates Tacitus or only repeats him.

| # | Line | Claim | kind | depends-on |
|---|---|---|---|---|
| C1 | 136 | "lived in small villages and farmsteads scattered through the forests of northern Europe" | consensus attribution | |
| C2 | 136 | "growing barley, oats, rye, and wheat" | consensus attribution | |
| C3 | 136 | "raising cattle, pigs, sheep, and horses" | consensus attribution | |
| C4 | 136 | "Cattle were especially important, serving as a measure of wealth and a form of currency" | consensus attribution | |
| C5 | 138 | "led by chieftains whose authority derived from military prowess, generosity, and noble lineage" | consensus attribution | |
| C6 | 138 | "The warrior aristocracy formed a ~comitatus~, a band of followers bound to their lord by oaths of loyalty" | name | |
| C7 | 138 | warriors "expected gifts of weapons, gold, and feasting in return for their service" | consensus attribution | C6 |
| C8 | 140 | "The Germanic peoples had no centralized states or cities" | consensus attribution | |
| C9 | 140 | "They built no stone monuments" | consensus attribution | |
| C10 | 140 | "they did develop the runic alphabet for short inscriptions and magical purposes", in a paragraph anchored to "the time of the battle at Teutoburg" | date | B1 |
| C11 | 140 | "Their literature was oral: heroic poetry, mythological tales, and genealogies" | consensus attribution | |
| C12 | 142 | The theonyms and their descendants: "Wōðanaz (later Wōden (Old English) and Óðinn (Old Norse)), Þunaraz (Thunor and Þórr), Tīwaz (Tiw and Týr)" | etymology | |
| C13 | 142 | gods "worshipped in sacred groves rather than temples" | consensus attribution | |
| C14 | 142 | "They practiced animal and occasionally human sacrifice, particularly at times of crisis or celebration" | consensus attribution | |

**C10 carries a chronology problem worth checking first.** The elder futhark is conventionally
dated to around 150 AD, roughly a century and a half after the battle the paragraph anchors
itself to. The "magical purposes" reading is separately contested.

**C12 is the densest row in the cluster.** Check the reconstructions themselves, the
descendant pairings, and the pattern: *Wōðanaz* gets its languages labelled and the other two
do not, so a reader must infer that *Thunor* is Old English and *Þórr* Old Norse.

## D. The Germanic verb

`The Germanic Verb System: Simplification and Innovation`, `Losses from Proto-Indo-European`,
`The Germanic Innovation: Weak Verbs`, lines 142 to 156. Plus residue rows R3, R4, R5.

**This cluster owns Grimm's law, Verner's law, and the dental preterite.** No other cluster may
research them. It also owns whatever the essay says about Proto-Indo-European verbal
morphology, since no other cluster has a natural claim on it.

| # | Line | Claim | kind | depends-on |
|---|---|---|---|---|
| D1 | 143 | "As Proto-Indo-European evolved into Proto-Germanic over some two millennia" | date | A5, A7 |
| D2 | 144 | "The old imperfective became the Germanic present" | consensus attribution | |
| D3 | 144 | "the old perfect, with its distinctive reduplication and o-grade ablaut, was repurposed as a preterite" | consensus attribution | |
| D4 | 144 | "The aorist was largely lost, its conjugations occasionally merging with the new preterite" | consensus attribution | D3 |
| D5 | 146 | "This left Germanic with only ~two tenses~: present and preterite" | consensus attribution | |
| D6 | 148 | "The ~subjunctive and optative moods merged~ into a single Germanic subjunctive" | consensus attribution | |
| D7 | 150 | "The ~augment~ (*e-), which had marked past tense in PIE, was lost entirely in Germanic" | consensus attribution | S3 |
| D8 | 152 | "~Verb classes proliferated based on the structure of the present stem~", filed under *Losses* | consensus attribution | |
| D9 | 152 | strong classes are "organized by ablaut patterns" | consensus attribution | D8 |
| D10 | 153 | "weak verbs added a dental suffix (*-d- or *-t-)" | sound law | |
| D11 | 153 | "This is the origin of the "-te" ending in German preterites (machte, sagte, spielte)" | etymology | D10 |
| D12 | 153 | "and the "-ed" ending in English ($mAde$, $saId$, played)" | quoted verb form | D10 |
| D13 | 155 | "The origin of this dental suffix is debated, but the most widely accepted theory is that it derives from a compound with the verb "to do" (*dō-)" | consensus attribution | D10 |
| D14 | 155 | "What began perhaps as "I love-did" grammaticalized into a single word with a fused past-tense suffix" | consensus attribution | D13 |
| D15 | 155 | "new verbs entering Germanic languages almost always followed the weak pattern, and many originally strong verbs eventually became weak" | consensus attribution | |
| D16 | 155 | "The King James Bible … the phrase "the cock $crEw$" appears" | quoted verb form | |
| D17 | 155 | "Speakers of Modern English are aware that the conjugation later became "crowed"" | quoted verb form | D16 |
| R3 | 92 | "PIE verbs were built on roots (typically consisting of a consonant-vowel-consonant structure)" | consensus attribution | |
| R4 | 93 | "The system allowed for present, past (preterite), and arguably future expressions" | consensus attribution | S3 |
| R5 | 102 | "with a developing passive" | consensus attribution | |

**D7 is the run's known contradiction, and it was created by Phase 0.** S3 now says the
augment's Proto-Indo-European antiquity is disputed. D7 says it "had marked past tense in PIE"
and "was lost entirely in Germanic", which presupposes it was there to lose. Judge D7 on the
facts, and route the contradiction itself to agent H.

**D6 is the likeliest single error in the cluster.** The standard account is that the Germanic
subjunctive continues the Proto-Indo-European **optative**, with the subjunctive lost, rather
than the two merging. Check it against Ringe and Braune-Reiffenstein before accepting the
essay's framing.

**D13 is the prompt's named trap.** The *dō-* compound account is one hypothesis among several,
routinely repeated as settled. The essay hedges it: "is debated", "the most widely accepted
theory". **Judge the hedge as written.** A properly hedged claim about a contested question is
not an error, and a hedge that misrepresents where the consensus sits is.

**Grimm's law and Verner's law have no rows because the essay never names them.** That is
itself worth reporting: this cluster's brief expects both, and their absence means the
consonant-shift story reaches the reader only through cluster E's High German shift, which is
the *second* shift. Report it as a coverage observation, not a finding.

## E. Old High German

`Old High German and the Continuing Evolution`, `Strong-Verb-Class Restructuring`, lines 155 to
158. Plus residue rows R2, R6, R7, R8, R9.

**This cluster owns the High German consonant shift and the seven strong classes.** No other
cluster may research either.

| # | Line | Claim | kind | depends-on |
|---|---|---|---|---|
| E1 | 156 | "The Germanic dialects spoken in what is now southern Germany and Switzerland developed into Old High German (roughly 750–1050 AD)" | date | |
| E2 | 156 | Old High German is "distinguished from other Germanic languages by the ~High German consonant shift~" | consensus attribution | |
| E3 | 156 | "This series of sound changes transformed voiceless stops into fricatives or affricates (p → pf or ff; t → ts or s; k → ch)" | sound law | E2 |
| E4 | 156 | "giving German words like ~Pfund~, ~Wasser~, and ~machen~ their characteristic sounds where English has ~pound~, ~water~, and ~make~" | quoted verb form | E3 |
| E5 | 156 | "The effects of the shift were not uniform. Dialects further south experienced more sound changes." | consensus attribution | E3 |
| E6 | 156 | "in Swiss German, the /k/ sound became guttural /x/. The Swiss German word for "kitchen" is therefore "Chuchi", contrasting with High German "Küche"." | sound law | E5 |
| E7 | 156 | "in Kölsch, spoken in Cologne, the /t/ in "et", English "it", never shifted to /s/, as it did in German "es"" | sound law | E5 |
| E8 | 157 | "Old High German inherited seven classes of strong verbs from Proto-Germanic" | number | |
| E9 | 157 | those classes are "organized by their ablaut patterns" | consensus attribution | D9 |
| E10 | 157 | "Some verbs shifted classes; others became weak." | consensus attribution | D15 |
| E11 | 157 | "The original phonological conditioning that determined class membership became opaque as sound changes altered vowels." | sound law | E9 |
| E12 | 157 | "Today, German strong verbs must largely be memorized individually, their ablaut patterns, while still systematic, are no longer predictable from the infinitive." | consensus attribution | E11 |
| R2a | 90 | "Linguists reconstruct PIE *tewtéh₂, from the root *tew- ("to swell, be strong"), as a word meaning "the full community" or simply "the people"" | etymology | |
| R2b | 90 | "it became Proto-Germanic *þeudō, then Old English þēod ("nation")" | etymology | R2a |
| R2c | 90 | "then, through Medieval Latin theodiscus ("of the people"), Modern German Deutsch" | etymology | R2b |
| R2d | 90 | "The Haudenosaunee, whom Europeans called the Iroquois, named themselves "people of the long house"" | etymology | |
| R2e | 90 | "Autonyms often incorporate the concept of "the people"" | consensus attribution | |
| R6 | 113–117 | The five ablaut grades and their cited forms: e-grade *bʰer- "to carry", o-grade *bʰor-, zero-grade *bʰr-, lengthened e-grade *mḗh₁-n̥s, lengthened o-grade *n̥-péh₂-tōr | etymology | |
| R7 | 119 | "the present stem might use e-grade while the perfect used o-grade; the zero-grade appeared in certain suffixes and in unstressed positions" | consensus attribution | R6 |
| R8 | 121–123 | The three triads: "singen, $sAng$, $gesUngen$ (sing, $sAng$, $sUng$)", "nehmen, $nahm$, $genOMmen$ (take, $tOOk$, taken)", "geben, $gAb$, gegeben (give, $gAve$, given)" | quoted verb form | E8 |
| R9 | 123 | "These vowel changes are direct inheritances from Proto-Indo-European, preserved across five millennia of linguistic evolution." | number | R8, G13 |

**R2c is the essay's best etymological thread and the least checked thing in it.** The chain
runs PIE *tewtéh₂ to Proto-Germanic *þeudō to Old English *þēod* to Medieval Latin *theodiscus*
to *Deutsch*, and the last step is the one to interrogate: *theodiscus* is a Latinization of a
West Germanic adjective rather than a Latin word German borrowed back, the Old High German
reflex is *diutisc*, and the first attestation is usually given as 786. The essay's hedges
("may trace back", "If the Yamnaya or their linguistic heirs used something like") are doing
real work. Judge them as written.

**E6 has a translation defect the researcher does not own but should see.** The German
localization renders the Swiss German example circularly, contrasting *Küche* with *Küche*,
because the English head word is "kitchen". That is an editorial matter for Josh, not a
finding, and it is recorded in `docs/verb_history_phase0.md`.

**E3 is incomplete rather than wrong, which is the hardest kind of row.** The shift's second
phase affects voiced stops too, and the *k* outcome is southern. E5, E6 and E7 are the essay's
own qualification of E3, so judge the four together.

**Coverage note.** The essay assigns no date to the consonant shift itself, only to the Old
High German period, and never mentions Notker. Both appear in the prompt's brief. No rows.

## F. Tense-building

`Development of the Perfect Tense`, `The Future Tense and Modal Verbs`,
`Preterite-Present Verbs`, lines 157 to 171.

| # | Line | Claim | kind | depends-on |
|---|---|---|---|---|
| F1 | 158 | "the development of the ~perfect tense~ using the auxiliaries ~haben~ (to have) and ~sein~ (to be) with the past participle" | consensus attribution | |
| F2 | 158 | that periphrasis "began in Old High German and became fully established in Middle High German" | date | E1 |
| F3 | 158 | Middle High German is "(1050–1350)" | date | E1 |
| F4 | 160–161 | "Ich habe $gesUngen$ (I have $sUng$)" and "Ich bin gekommen (I have come / I $cAme$)" as the *haben* and *sein* exemplars | quoted verb form | F1 |
| F5 | 163 | "In modern spoken German, this perfect construction has largely replaced the simple preterite in everyday speech, particularly in southern dialects" | consensus attribution | |
| F6 | 163 | "The preterite survives primarily in writing, in northern dialects, and with high-frequency verbs." | consensus attribution | F5 |
| F7 | 164 | "Old High German expressed future time primarily through the present tense with temporal adverbs" | consensus attribution | E1 |
| F8 | 164 | "Beginning in Middle High German, the verb ~werden~ (to become) was grammaticalized as a future auxiliary" | date | F3 |
| F9 | 166 | "Ich werde singen (I will sing)" | quoted verb form | F8 |
| F10 | 168 | "This created a three-way temporal system (present, preterite/perfect, future) from the original two-tense Proto-Germanic system" | consensus attribution | D5 |
| F11 | 168 | "though notably through periphrasis rather than new morphological conjugations of the verb itself" | consensus attribution | F10 |
| F12 | 169 | "verbs whose present-tense conjugations derive historically from Proto-Germanic strong preterites" | consensus attribution | D3 |
| F13 | 169 | "These include the modal verbs ~können~, ~müssen~, ~dürfen~, ~sollen~, ~mögen~, and ~wissen~" | name | F12 |
| F14 | 169 | The glosses: können "(can)", müssen "(must)", dürfen "(may)", sollen "(shall)", mögen "(may/like)", wissen "(to know)" | quoted verb form | F13 |
| F15 | 171 | "with no endings in 1s and 3s (ich $kAnN$, er $kAnN$)" | consensus attribution | F12 |
| F16 | 171 | "and vowel differences between singular and plural (ich $kAnN$ vs. wir können)" | sound law | F15 |

**F5 is the *oberdeutscher Präteritumschwund* and the essay never names it.** Check both the
phenomenon and whether "particularly in southern dialects" understates a change that is close
to categorical in Upper German.

**F8 is the prompt's named trap.** The *werden* future is usually dated later than "beginning in
Middle High German" implies, and it competed with *werden* plus present participle for a long
time. Establish what the handbooks actually date and to what.

**F13 hands wissen to the wrong class.** The sentence calls all six "the modal verbs", and
*wissen* is a preterite-present but not a modal. Separately, check whether the omission of
*wollen*, which is a modal but not a preterite-present, is correct. Both halves are one row's
work.

## G. Modern German

`The Subjunctive and Modern German`, `The Verb System Today`, lines 171 to 187.

| # | Line | Claim | kind | depends-on |
|---|---|---|---|---|
| G1 | 172 | "Old High German had a fully functional subjunctive mood in both present and preterite" | consensus attribution | E1 |
| G2 | 172 | "as vowel distinctions reduced and the subjunctive conjugations became identical to the indicative in many verbs" | sound law | G1 |
| G3 | 172 | "speakers increasingly used periphrastic constructions with ~würde~ (would) + infinitive to express what the old synthetic subjunctive once conveyed" | consensus attribution | G2 |
| G4 | 174 | "Old: Wenn ich $kÄme$… (If I $cAme$…)", labelling *käme* as old | quoted verb form | G3 |
| G5 | 175 | "Modern alternative: Wenn ich kommen $wÜrde$… (If I $wOUld$ come…)" | quoted verb form | G3 |
| G6 | 177 | "the $wÜrde$ construction increasingly replaces synthetic subjunctive conjugations except for common verbs and in formal registers" | consensus attribution | G3 |
| G7 | 178 | "Modern German retains the essential architecture established in Proto-Germanic: two morphological tenses (present and preterite), strong verbs with ablaut, weak verbs with a dental suffix, and a distinction between indicative, subjunctive, and imperative moods" | consensus attribution | D5, D6, D10 |
| G8 | 180 | "~Aspect~ is expressed periphrastically (er $lIest$ = he reads/is reading)" | consensus attribution | |
| G9 | 180 | "or through verbal prefixes and particles (er $lIest$ das Buch aus = he finishes reading the book)" | quoted verb form | G8 |
| G10 | 181 | "~Future~ is expressed with ~werden~ + infinitive" | consensus attribution | F8 |
| G11 | 182 | "~Perfect~ is expressed with ~haben~/~sein~ + past participle" | consensus attribution | F1 |
| G12 | 183 | "~Passive~ is expressed with ~werden~ + past participle (dynamic) or ~sein~ + past participle (stative)" | consensus attribution | |
| G13 | 185 | "a living fossil of that 5,000-year journey from the Pontic steppe to the German-speaking lands of central Europe" | number | A1, A2, S1 |
| G14 | 187 | "that primordial cloud of supernova-enriched gas from which the Solar System was born" | consensus attribution | |
| G15 | 187 | "through Old High German scribes in medieval monasteries" | date | E1 |
| G16 | 187 | "still sounding after fifty centuries" | number | G13 |
| G17 | 187 | "ich singe, ich $sAng$, ich habe $gesUngen$" | quoted verb form | R8 |

**G8 may invert its own point.** *Er liest* is a single synthetic form covering both the
habitual and the progressive reading, which is the **absence** of aspect marking rather than
periphrasis. Check whether "periphrastically" is the wrong word for the example given, and
whether German has periphrastic aspect worth naming instead, such as the *am*-progressive.

**G14 is a downstream echo of a patch and is nearly settled already.** Conjugar's cluster A
nitpick broadened the same epithet at line 82 from "supernova-gifted" to "star-forged", and
Phase 0 applied it. This closing occurrence was not patched, because it sits in the
German-specific half where Phase 0 may not edit. The finding is therefore close to free: one
word, already researched, already verified. Report it with the replacement prose.

**Coverage note.** The essay never uses the terms *Konjunktiv I* or *Konjunktiv II*, never
discusses indirect speech or the decline of Konjunktiv I in speech, and never mentions Luther.
All four appear in the prompt's brief for this cluster, and the last is flagged there as
something popular accounts overstate. Their absence is not an error, but it is the reason this
cluster is smaller than its brief suggests, and it should be reported so that silence is not
read as coverage.

## Coverage reconciliation

Fill this in at the end of Phase 2. Every row above must appear either as a finding in
`docs/history_corrections.md` or as an explicit `confirmed`. A row appearing in neither is the
run's own bug, and it should be visible in the deliverable rather than discovered later.

| Cluster | Rows | Verdicts returned | Findings | Confirmed | Missing |
|---|---|---|---|---|---|
| A | 10 | | | | |
| B | 13 | | | | |
| C | 14 | | | | |
| D | 20 | | | | |
| E | 21 | | | | |
| F | 16 | | | | |
| G | 17 | | | | |
| **Total** | **111** | | | | |
