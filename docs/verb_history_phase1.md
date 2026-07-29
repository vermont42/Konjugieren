# Phase 1 of the verb-history fact-check: the fan-out over the German-specific claims

Run 2026-07-28 against [`prompts/verify-verb-history.md`](../prompts/verify-verb-history.md),
working from the Phase 0.5 inventory in [`docs/verb_history_claims.md`](verb_history_claims.md).
Eight agents: seven cluster researchers, each handed an explicit list of inventory rows rather
than a section range, and agent H, which held the whole essay in both languages and did no web
research at all.

**Nothing here is settled.** Phase 2 hands each finding to an independent skeptic instructed to
refute it. In the sibling run on Conjugar's Spanish essay that pass dismissed 104 of 188
proposals, one of which had already been written up as a factual error. Read this document as a
list of things worth attacking, not as a list of things wrong with the essay.

Nothing was edited. `docs/verb_history.txt`, `docs/verb_history_de.txt` and
`Konjugieren/Assets/Localizable.xcstrings` are byte-identical to what Phase 0 left.

## Coverage reconciliation

The inventory's own table, filled in. Every row returned a verdict, so the run has no
unaccounted claims.

| Cluster | Rows | Verdicts | factual-error | needs-hedging | nitpick | confirmed | Searches |
|---|---|---|---|---|---|---|---|
| A · Into Europe | 10 | 10 | 0 | 1 | 2 | 7 | 13 |
| B · Teutoburg | 13 | 13 | 1 | 0 | 1 | 11 | 9 |
| C · Tacitus country | 14 | 14 | 1 | 2 | 4 | 7 | 22 |
| D · The Germanic verb | 20 | 20 | 1 | 1 | 3 | 15 | 16 |
| E · Old High German | 21 | 21 | 2 | 2 | 4 | 13 | 22 |
| F · Tense-building | 16 | 16 | 1 | 1 | 1 | 13 | 14 |
| G · Modern German | 17 | 17 | 1 | 0 | 2 | 14 | 11 |
| **Total** | **111** | **111** | **7** | **7** | **17** | **80** | **107** |

No row came back `unresolved`, and no agent reported on a row it did not own, which is the
signal the prompt asked to watch for as evidence of a boundary problem in the inventory.

## Corrections to the inventory itself

Agent H found, and I verified against the file, that **the inventory's line numbers are wrong
for seven rows in the shared half**. The German-specific rows are all correct; every one spot-
checked landed on its quoted sentence. The offsets are not uniform, so this is not the header
shift the inventory's own How-to-read section anticipates, and it cannot be repaired by adding a
constant.

| Ref | Inventory says | Actually at | The sentence at the inventory's number is about |
|---|---|---|---|
| S2 | 86 | **88** | the Yamnaya riding, not the lactase allele |
| S3 | 93 | **102** | PIE root structure, not the augment |
| R2a–R2e | 90 | **92** | the descendant list, not *tewtéh₂* |
| R3 | 92 | **93** | the *tewtéh₂* paragraph, not root structure |
| R4 | 93 | **102** | root structure, not tense |
| R5 | 102 | **110** | the augment, not voice |
| R9 | 123 | **125** | the *nehmen* triad, not the closing claim |

R1 at 90, R6 at 113 to 117, R7 at 119 and R8 at 121 to 123 are correct. Phase 0's patch table
has the same defect: P4 is at 85 rather than 83, P7 at 88 rather than 86, P8 at 102 rather than
93, P9 at 106 rather than 96, and P10 at 107 rather than 97. P1, P2, P3, P5 and P6 are right.

A second cache is stale for the same reason. `docs/verb_history_de.txt`'s header says the essay
has 58 `~…~` spans; both bodies now carry 59, because P8 added `~secondary~` and `~sekundären~`
and the header was not updated with the patch. Counted: 118 tilde characters per body. Every
other header count is right in both files, including the 27 `$…$` spans, which agent H verified
are byte-identical between the two languages in the same order.

## Findings

Thirty-one of 111 rows came back as something other than `confirmed`: 7 factual errors,
7 needing a hedge, 17 nitpicks. Each carries replacement prose in the essay's voice,
checked mechanically for the two things that would bite: no em dashes, and all five markers
balanced and unnested, since unbalanced markup is a `fatalError` on the Info screen rather than a
render bug. The German counterpart sentence is quoted for each so Phase 4 knows what it is
translating against. German replacement prose is deliberately not written yet, because roughly
half of these will not survive Phase 2.

### Cluster A: Into Europe

#### A4 · line 126 · **needs-hedging** · confidence high

> Equipped with horses, wheeled carts, and perhaps bronze weapons, they moved westward in successive waves

**Why.** Judged against S1 rather than in isolation, as the brief directs. S1 concedes that some Yamnaya may have ridden, so the essay may say the Yamnaya had horses. What this sentence does is different: it lists horses as part of the equipment of the westward move, alongside the carts, and that is the specific proposition Librado et al. 2021 set out to refute in the sentence that closes their abstract. Their evidence is direct rather than inferential: horses recovered from Corded Ware contexts, the archaeological end point of the westward waves, almost entirely lack the ancestry that is maximized in DOM2 and in Yamnaya horses. The migrants did not bring their horses. Librado et al. 2024, on 475 ancient genomes, then date the rise of widespread horse-based mobility to about 2200 BC, roughly eight centuries after the waves this sentence describes. Meanwhile the carts are solid and belong in the sentence: Yamnaya wagon burials preserve wheels and wagon parts, and the traction was a paired ox team, not a horse. "Perhaps bronze weapons" is already correctly hedged, since Yamnaya metalwork is arsenical copper and bronze. So the defect is one word in a list, and it is the word that carries the popular misconception. I did not raise this as a factual error, for two reasons that a skeptic would raise anyway. Yamnaya horses existed as a genetic population, so "equipped with horses" is not false of the Yamnaya in their homeland. And the horse question is genuinely live: Trautmann et al. 2023 argue from skeletal morphology for Yamnaya horsemanship, and a re-analysis by Maier and colleagues finds several models that do admit steppe admixture in Corded Ware horses. The replacement therefore removes the horse from the migration kit without denying the Yamnaya kept horses, which also leaves S1 undisturbed.

**What is actually true.** The westward waves were wagon-borne, not horse-borne. Yamnaya wagons were drawn by paired oxen, and wagon parts survive in their kurgans. Horses existed in Yamnaya contexts, and whether some Yamnaya rode is disputed, which is what line 86 already says. But the horses recovered from Corded Ware contexts in Europe carry local ancestry rather than Yamnaya or DOM2 ancestry, so the migrants did not carry their horses west, and widespread horse-based mobility across Eurasia dates to about 2200 BC, several centuries after these migrations.

**Replacement, English.**

> Equipped with ox-drawn wagons and perhaps bronze weapons, they moved westward in successive waves. Widespread horse-based mobility came later, arising across Eurasia around 2200 BC.

**German counterpart**, `docs/verb_history_de.txt` line 92:

> Ausgestattet mit Pferden, Räderkarren und vielleicht Bronzewaffen zogen sie in aufeinanderfolgenden Wellen westwärts.

**Assumes.** Depends on S1 (line 86), which is settled and which I have not touched. I assume S1 stands as written: some Yamnaya may have ridden, the reading is disputed, and the mobility claim is carried by the wheel rather than the horse. My replacement is written to be compatible with S1 under either resolution of the riding question, because it removes the horse from the migration kit without denying that the Yamnaya had horses.

**Sources.**

- Librado, P. et al. (2021). The origins and spread of domestic horses from the Western Eurasian steppes. Nature 598:634-640. <https://pmc.ncbi.nlm.nih.gov/articles/PMC8550961/>
  > Abstract: "Our results reject the commonly held association between horseback riding and the massive expansion of Yamnaya steppe pastoralists into Europe around 3000 bc, driving the spread of Indo-European languages." And: "modern domestic horses ultimately replaced almost all other local populations as they expanded rapidly across Eurasia from about 2000 bc, synchronously with equestrian material culture, including Sintashta spoke-wheeled chariots." Main text on the westward end of the migration: "The genetic profile of horses from CWC contexts, however, almost completely lacked the ancestry maximized in DOM2 and Yamnaya horses … and showed no direct connection with the WE group."
- Librado, P. et al. (2024). Widespread horse-based mobility arose around 2200 bce in Eurasia. Nature 631:819-825. <https://ut3-toulouseinp.hal.science/hal-04607980v1/file/Librado_2024.pdf>
  > From 475 ancient horse genomes: reproductive control of the modern domestic lineage emerges around 2200 BC through close-kin mating and shortened generation times, following a severe domestication bottleneck starting no earlier than about 2700 BC, and coincides with a sudden expansion across Eurasia that replaced nearly every local horse lineage. The title states the conclusion: widespread horse-based mobility arose around 2200 BC, not around 3000 BC.
- Yamnaya wagon burials and draught animals, as reported in the survey literature on Pontic-Caspian wheeled transport. <https://europe.factsanddetails.com/article/entry-886.html>
  > The Yamnaya used the four-wheeled wagon pulled by a pair of oxen or bulls across the Pontic-Caspian region; wagon parts and wheels recovered from Yamnaya burials in the Urals attest to cattle traction. Two-wheeled carts and four-wheeled wagons alike are taken to have been ox-drawn.
- Trautmann, M. et al. (2023). First bioanthropological evidence for Yamnaya horsemanship. Science Advances; and the subsequent re-analysis literature on Corded Ware horse ancestry. <https://www.science.org/doi/full/10.1126/sciadv.ady7336>
  > Argues from skeletal morphology consistent with habitual riding that some Yamnaya individuals rode. A separate re-analysis by Maier and colleagues reports that six of ten better-fitting models admit varying steppe admixture in Corded Ware horses while four show none, so the genomic case against horses in the westward move is strong but not closed. This is why the verdict is needs-hedging rather than factual error.

#### A7 · line 130 · **nitpick** · confidence medium

> By the first millennium BC, a recognizable Proto-Germanic language had emerged

**Why.** The facts are not in dispute; the preposition is. Ringe dates Proto-Germanic to "probably not before ca. 500 BCE, possibly a bit later", and the standard handbook range runs from about 500 BC to roughly 200 AD, ending with the Gothic migration. The essay's "By the first millennium BC" reads most naturally as "by the time of the first millennium BC", that is, by about 1000 BC, which is some five centuries before the earliest date any handbook allows. Read charitably as "at some point during the first millennium BC" it is correct, so the sentence is ambiguous rather than false, and that is why I am filing it as a nitpick rather than a factual error. Two things push it above nothing. First, the German at line 96 resolves the ambiguity in the wrong direction: "Bis zum ersten Jahrtausend v. Chr." reads as "up to the first millennium BC", which is the early reading, so the shipped German makes the claim the English merely permits. Second, the early reading breaks the essay's own arithmetic elsewhere: cluster D's row D1 at line 143 says Proto-Indo-European evolved into Proto-Germanic "over some two millennia", which from A5's 2500 to 2000 BC separation lands at 500 BC to the turn of the era, exactly Ringe's date, and not at 1000 BC. Naming the second half of the millennium costs one phrase and makes the essay agree with itself.

**What is actually true.** Proto-Germanic is dated to the second half of the first millennium BC and the first two centuries AD. Ringe gives about 500 BC as the earliest date at which it can be placed, and the handbook range runs from there to roughly 200 AD. Nothing recognizable as Proto-Germanic is reconstructed for 1000 BC.

**Replacement, English.**

> In the second half of the first millennium BC, a recognizable Proto-Germanic language emerged in southern Scandinavia and along the North Sea and Baltic coasts.

**German counterpart**, `docs/verb_history_de.txt` line 96:

> Bis zum ersten Jahrtausend v. Chr. war eine erkennbare proto-germanische Sprache in Südskandinavien und entlang der Nordsee- und Ostseeküsten entstanden.

**Assumes.** Depends on A5, which I own and have confirmed. It also bears on D1 at line 143, which cluster D owns and which I have not researched: my reasoning assumes only that D1's "over some two millennia" is left as written, in which case the replacement makes the two dates consistent. If D were to change D1, agent H should re-check the pair rather than either row alone.

**Sources.**

- Ringe, D., on the emergence of Germanic (Language Log), summarizing From Proto-Indo-European to Proto-Germanic. <https://languagelog.ldc.upenn.edu/nll/?p=41979>
  > "PGmc. was *one* of the dialects spoken in the Jastorf area, probably not before ca. 500 BCE, possibly a bit later." Ringe gives 500 BC as an earliest bound, not as a typical or latest date.
- Standard handbook dating of Proto-Germanic as summarized in the Germanic-linguistics literature (Ringe 2006; Harbert, The Germanic Languages, Cambridge Language Surveys). <https://en.wikipedia.org/wiki/Proto-Germanic_language>
  > Proto-Germanic is dated to the last centuries BC, not earlier than 500 BC, and is taken to have been spoken from roughly 500 BC to 200 AD in the North Sea and southern Scandinavian region, coming to an end as a unity with the Gothic migration of the second century AD.

#### R1 · line 90 · **nitpick** · confidence high

> These languages include German, English, Ukrainian, Hindi, Persian, Cornish, Greek, and Latin

**Why.** Every item on the list is Indo-European, and the list is well chosen: eight languages across six branches, Germanic, Slavic, Indo-Aryan, Iranian, Celtic, Hellenic and Italic. The defect is not in the list but in what "These languages" points back to. The preceding sentence defines its noun as "languages spoken by nearly half of humans alive today", so the demonstrative hands the reader a set of currently spoken languages, and Latin is not a member of it: it has had no native speakers for well over a millennium. Cornish is a different case and survives the framing. It died as a community language in the eighteenth century, but it was revived from 1904, UNESCO moved it from extinct to critically endangered in 2010, and it has roughly five hundred to six hundred fluent speakers today, so it is spoken. Latin is the sore thumb, and the fix is one phrase: point the demonstrative at Proto-Indo-European's descendants rather than at today's speakers, which keeps the whole list and costs nothing. I considered leaving this alone on the grounds that no reader will conclude Latin is a living language, and that is why the verdict is a nitpick rather than anything heavier. But the sentence is one word away from being exactly right, and the same substitution reads better in German. I did not reopen "nearly half of humans alive today", which the brief records as dismissed twice.

**What is actually true.** All eight named languages descend from Proto-Indo-European, so the list is correct as a list of descendants. It is not correct as a list of languages spoken today, which is what the demonstrative makes it: Latin has no native speakers and has had none for many centuries. Cornish does, about five hundred to six hundred fluent speakers, through a revival that began in 1904.

**Replacement, English.**

> Its descendants include German, English, Ukrainian, Hindi, Persian, Cornish, Greek, and Latin.

**German counterpart**, `docs/verb_history_de.txt` line 56:

> Zu diesen Sprachen gehören Deutsch, Englisch, Ukrainisch, Hindi, Persisch, Kornisch, Griechisch und Latein.

**Sources.**

- Cornish language revival: Jenner's Handbook of the Cornish Language (1904); UNESCO reclassification 2010; current speaker estimates. <https://en.wikipedia.org/wiki/Cornish_language_revival>
  > Cornish died out as a community language during the eighteenth century, with the last known native speaker dying in 1777 and no speakers remaining by about 1800. The revival began with Jenner's handbook in 1904; UNESCO changed its status from extinct to critically endangered in 2010; roughly 3,000 people speak some Cornish and about 500 to 600 are fluent. Cornish therefore qualifies as spoken today, while a language with no native or community speakers does not.
- Standard classification of the languages listed. <https://en.wikipedia.org/wiki/Indo-European_languages>
  > German and English are Germanic, Ukrainian Slavic, Hindi Indo-Aryan, Persian Iranian, Cornish Brittonic Celtic, Greek Hellenic and Latin Italic. All eight are Indo-European, so the list is sound as a list of descendants; Latin is an extinct one.

### Cluster B: Teutoburg

#### B12 · line 133 · **factual-error** · confidence high

> the Germanic languages developed free from the Romanization that transformed Gaulish into French, Iberian languages into Spanish and Portuguese, and Dacian into Romanian

**Why.** The brief expected one bad leg out of three, with "Dacian into Romanian" as the odd one. Judging them separately, which is what the brief asked for, gives a different and cleaner answer: all three legs are wrong in the same way, and none of them is worse than the others. French does not descend from Gaulish, Spanish and Portuguese do not descend from the pre-Roman languages of Iberia, and Romanian does not descend from Dacian. In each case Latin replaced the older language and then became the modern one, leaving the older language behind as a substrate contributing a few dozen to a few hundred words. The relation of Gaulish to French and the relation of Dacian to Romanian are the same relation, and the substrate lexicons are even of comparable size, roughly 70 to 200 words for Gaulish in French against about 90 to 140 for the Romanian substrate. So the sentence does not contain one error inside three sound comparisons; it contains one error stated three times. Why this matters more here than the phrasing would matter in a general history: the essay's whole subject is genetic descent. It has spent four sections establishing that German descends from Proto-Germanic descends from Proto-Indo-European, and it closes by calling German ablaut a direct inheritance across five millennia. A reader who has been taught to read "X became Y" as descent, by this very essay, will read "transformed Gaulish into French" as descent, and will come away believing French is Gaulish with Latin poured over it. That is a false family tree, produced by the one text in the app whose job is family trees. I will say plainly that a downgrade to nitpick is defensible, and I would not fight it: "Romanization that transformed X into Y" is common loose usage, and the essay's own next sentence has the Germanic peoples "adopt" Vulgar Latin, which is the correct mechanism named correctly. That last point cuts both ways, though. It means the essay knows better two lines later, so the fix restores consistency rather than importing a new idea. The replacement is a word shorter than what it replaces and needs no new hedge.

**What is actually true.** French, Spanish, Portuguese and Romanian are all descendants of Latin. Gaulish, the pre-Roman languages of Iberia and Dacian are substrates: languages that the incoming Latin displaced and absorbed a limited vocabulary from before they died out. Gaulish had been supplanted by Vulgar Latin by about the end of the fifth century and leaves roughly 70 to 200 words in French; the Romanian substrate is reckoned at about 90 to 140 words, and even its source language is disputed among Dacian, Thraco-Dacian and Illyrian. Basque is the one pre-Roman language of Iberia that outlived the shift, which is a further reason not to write of Iberian languages turning into Spanish and Portuguese. The essay's own next sentence, which says the Germanic peoples might have adopted Vulgar Latin, describes the mechanism correctly.

**Replacement, English.**

> This had profound linguistic consequences: the Germanic languages developed free from the Romanization that replaced Gaulish, the languages of Iberia, and Dacian with the Latin that became French, Spanish, Portuguese, and Romanian.

**German counterpart**, `docs/verb_history_de.txt` line 99:

> Dies hatte tiefgreifende sprachliche Konsequenzen: Die germanischen Sprachen entwickelten sich frei von der Romanisierung, die Gallisch zu Französisch, iberische Sprachen zu Spanisch und Portugiesisch und Dakisch zu Rumänisch transformierte.

**Assumes.** Depends on B9, which I own and have confirmed. The verdict assumes B9 stands as written, that is, that the essay may attribute the linguistic outcome to the halt in Roman expansion. Nothing in this finding touches that attribution; the correction is entirely about how the Romance outcomes are described and would be needed whatever B9's verdict had been.

**Sources.**

- Wikipedia, "Gaulish" and "Language shift" <https://en.wikipedia.org/wiki/Gaulish>
  > Gaulish "was supplanted by Vulgar Latin" in western Europe by around the end of the fifth century, and the shift from Gaulish to Latin under the Empire is given as a documented case of language replacement. Gaulish functioned as a substrate to the Vulgar Latin of Roman Gaul, influencing it through lexical borrowing and phonetic adaptation.
- Wikipedia, "List of French words of Gaulish origin" <https://en.wikipedia.org/wiki/List_of_French_words_of_Gaulish_origin>
  > Estimates of Gaulish loanwords in French range from about 70 to 200 or more, entering "as a substrate influence during the transition from Gaulish to Vulgar Latin". The Gallo-Romance languages are "derived from forms of vulgar Latin spoken by the descendants of Romanised Gaulish-speaking peoples", that is, from Latin and not from Gaulish.
- Wikipedia, "History of the Romanian language" and "List of Romanian words of possible pre-Roman origin" <https://en.wikipedia.org/wiki/History_of_the_Romanian_language>
  > Romanian emerged as an Eastern Romance language from the Vulgar Latin of the province of Dacia after Trajan's conquest in 106 AD; Dacian elites and urban populations adopted Latin, producing bilingualism and "eventual language shift". Estimates of Romanian words of substratum origin run between about 90 and 140, and scholars disagree whether the substrate was Dacian, Thraco-Dacian or Illyrian.

#### B7 · line 131 · **nitpick** · confidence high

> an alliance of Germanic tribes led by Arminius (Hermann)

**Why.** The construction is an unglossed apposition, so what it claims depends on how a reader fills the gap, and both available fillings are available at once. Read as "the man Germans call Hermann", it is true and useful, and in an app for English speakers learning German it is more than useful, since German sources say Hermann der Cherusker and the monument near Detmold is the Hermannsdenkmal. Read as "his Germanic name", which is the reading the surrounding sentence invites by having just called him a Romanized chieftain, it is false. A reader who has been told that the man was Romanized will take the Latin name as the imposed one and the bare parenthetical as the native one, and that is exactly backwards: the Latin name is the only one recorded and Hermann postdates him by fifteen centuries. Graded nitpick rather than factual error because the sentence asserts nothing explicitly and because the German cross-reference is a real service to this particular reader. The fix costs a clause and removes the wrong reading entirely.

**What is actually true.** Arminius's Germanic name is not recorded anywhere. Hermann is a sixteenth-century German rendering of the Latin name, credited first to Martin Luther and also to Johannes Aventinus, and it is a back-formation rather than a survival: Old High German heri, "army", plus man gives "army leader", which resembles Arminius by coincidence and is etymologically unrelated to it. If Arminius latinizes anything Germanic at all, which is itself uncontested only in the weak sense that nobody can check it, the likeliest source is ermunaz, "great". Everything else in the clause holds: the coalition really was an alliance of tribes rather than the Cherusci alone.

**Replacement, English.**

> Three Roman legions under the command of Publius Quinctilius Varus (perhaps 20,000 soldiers) were ambushed and annihilated by an alliance of Germanic tribes led by Arminius, a Romanized chieftain of the Cherusci whom Germans have called Hermann since the sixteenth century.

**German counterpart**, `docs/verb_history_de.txt` line 97:

> Drei römische Legionen unter dem Kommando von Publius Quinctilius Varus (vielleicht 20.000 Soldaten) wurden von einer Allianz germanischer Stämme unter der Führung von Arminius (Hermann), einem romanisierten Häuptling der Cherusker, überfallen und vernichtet.

**Sources.**

- Wikipedia, "Arminius", infobox and naming section, citing Herbert W. Benario, "Arminius into Hermann: History into Legend", Greece & Rome 51.1 (April 2004), 83-94 <https://en.wikipedia.org/wiki/Arminius>
  > "His original Germanic name is unknown, although it is thought 'Arminius' could be a Romanization of 'Erminaz'; modern German variants of 'Arminius', e.g. Hermann and Armin, are back-formations." And: "In the 16th century, Arminius also came to be referred to as Hermann in German, possibly first by Martin Luther." And on the two names: "While bearing a superficial resemblance to the name Arminius, they are etymologically unrelated, as Arminius (if assumed to represent a Latinization of a Germanic name, which is not uncontested) would most likely derive from the Germanic word ermunaz, meaning 'huge/great'." Old High German heri 'army' plus man yields Hermann, 'army/war leader', in a language "which had not yet developed during the time of Arminius".
- Wikipedia, "Arminius", reception section, citing W. Bradford Smith, "German Pagan Antiquity in Lutheran Historical Thought", Journal of the Historical Society 4.3 (2004), 351-374 <https://en.wikipedia.org/wiki/Arminius>
  > "the name Arminius was interpreted as reflecting the name Hermann by Martin Luther, who saw Arminius as a symbol of his religious followers among the German people and their resistance to the Papacy". The first literary adaptation of the story is dated to Ulrich von Hutten's Latin dialogue Arminius of 1520.

### Cluster C: Tacitus country

#### C9 · line 140 · **factual-error** · confidence high

> They built no stone monuments

**Why.** This is an unqualified negative, and the counterexamples are neither marginal nor contested. Stone circles of the Iron Age, the Swedish domarringar, are a characteristic burial custom of southern Scandinavia dated to the Pre-Roman and Roman Iron Age, roughly 500 BC to 400 AD, and are especially dense on Gotland and in Götaland. Stone ship settings, in which the grave is ringed by upright stones in the outline of a hull, were raised in Scandinavia, northern Germany and the Baltic from about 1000 BC to about 1000 AD. Standing stones, bautastenar, mark Iron Age graves at sites such as Ekornavallen alongside circles and other settings, and triangular settings, treuddar, are associated with the Iron Age elite. Runestones follow from about the fourth century AD and Gotland's carved picture stones from the fifth. Every one of these is stone, raised deliberately, and meant to be seen and remembered, which is what a monument is. Importantly, none of this depends on Tacitus at all; it is the archaeological record speaking on its own. What the essay is reaching for is defensible and is worth keeping: no dressed stone, no monumental architecture, nothing answering to a Roman temple or arch or aqueduct. As written, though, a reader learns that the Germanic peoples left nothing in stone, and thousands of standing stones in Scandinavia say otherwise. I considered grading this needs-hedging, on the reading that 'monument' silently means 'monumental building'. I rejected that: the sentence sits between 'no centralized states or cities' and 'committed little to writing', a run of absolute negatives, and nothing in the context narrows it.

**What is actually true.** The Germanic peoples built nothing in dressed stone and left no monumental architecture, but they raised stone monuments constantly. Standing stones, stone circles, triangular settings and ship settings marked graves across southern Scandinavia and the southern Baltic through the Pre-Roman and Roman Iron Age, the period the paragraph describes, and runestones and Gotland's picture stones follow from the fourth and fifth centuries.

**Replacement, English.**

> They built nothing in dressed stone, though standing stones and stone settings marked their graves.

**German counterpart**, `docs/verb_history_de.txt` line 106:

> Sie errichteten keine Steinmonumente.

**Sources.**

- Stone circle (Iron Age), overview of the Scandinavian domarringar <https://en.wikipedia.org/wiki/Stone_circle_(Iron_Age)>
  > Dates Iron Age stone circles to c. 500 BC to c. 400 AD, calls them a characteristic burial custom of southern Scandinavia and southwestern Finland, especially on Gotland and in Götaland, typically of the Pre-Roman and Roman Iron Age, and gives the Swedish names domarringar, domkretsar and domarsäten.
- Stone ship (skeppssättning), overview <https://en.wikipedia.org/wiki/Stone_ship>
  > Describes an early burial custom in Scandinavia, northern Germany and the Baltic states in which the grave or cremation is surrounded by slabs or stones set in the shape of a ship, with such settings erected from about 1000 BCE to 1000 CE.
- 'The Tripartite Ideology: Interactions between threefold symbology, treuddar and the elite in Iron Age Scandinavia' <https://www.academia.edu/43905032/The_Tripartite_Ideology_Interactions_between_threefold_symbology_treuddar_and_the_elite_in_Iron_Age_Scandinavia>
  > Treats treuddar, triangular stone settings, as monuments predominantly linked to the Iron Age Nordic elite, associated with death, cosmology and ancestral worship, and found near elite estates as markers of aristocratic identity.

#### C10 · line 140 · **needs-hedging** · confidence high

> they did develop the runic alphabet for short inscriptions and magical purposes

**Why.** Two separate problems, and neither is a Tacitus problem, since Tacitus never mentions runes; this row is checkable against the inscribed objects themselves. First, chronology. The paragraph opens by anchoring itself to the time of the battle at Teutoburg, which row B1 dates to 9 AD, and the past tense 'did develop' then invites the reader to place the runic alphabet in that world. The elder futhark is conventionally dated to about 150 AD or to the second century generally, and the oldest undisputed inscription is the Vimose comb from Funen, about 160 AD, reading harja. The one candidate that would close the gap, the Meldorf fibula of about 50 AD, is precisely the contested case: the debate is over whether its graphemes are runic, proto-runic or Latin at all. So the script postdates the anchor by something like a century and a half, and by roughly a century even on the most generous reading. Second, the purposes. 'Magical purposes' is not a neutral description but the older strand of runology, and modern handbook treatment has moved away from it. Barnes stresses that the runes are an alphabetic writing system derived from a Mediterranean model and that there is little evidence the characters themselves were held to carry magical power; the corpus is dominated by memorials, makers' and owners' names, and ordinary messages. Formulaic items such as alu and laukaz keep the question open, which is why hedging rather than deletion is the right fix. Stated flatly and coordinated with 'short inscriptions', magic reads as one of the two things runes were for.

**What is actually true.** The elder futhark is dated to about the second century AD, roughly a century and a half after Teutoburg, with the Vimose comb of about 160 AD the oldest undisputed inscription and the c. 50 AD Meldorf fibula contested as to whether it is runic at all. Its documented uses are overwhelmingly mundane: owners' and makers' names, memorials, short messages. The magical reading belongs to an older strand of runology that current handbooks have substantially walked back, though a handful of formulaic inscriptions keep it alive as a minority possibility.

**Replacement, English.**

> They committed little to writing, and only about a century and a half later developed the runic alphabet, used for short inscriptions naming owners and makers and, some argue, for charms.

**German counterpart**, `docs/verb_history_de.txt` line 106:

> Sie hinterließen wenig Schriftliches, obwohl sie das Runenalphabet für kurze Inschriften und magische Zwecke entwickelt hatten.

**Assumes.** Assumes row B1's verdict that the battle is correctly dated to 9 AD. If B1 stands, the gap between the paragraph's anchor and the earliest undisputed runic inscription is about 150 years. The finding does not depend on B1 being confirmed, only on the date being early first century.

**Sources.**

- Michael P. Barnes, Runes: A Handbook (Boydell, 2012), as characterised in the publisher description and in the Medieval Review notice <https://scholarworks.iu.edu/journals/index.php/tmr/article/view/18626/24739>
  > Emphasises that runes are an alphabetic writing system derived from Mediterranean alphabetical models, that though they have been associated with divinatory practices there is little evidence the runes themselves were considered imbued with magic powers, and that inscription types range from memorials to the dead through everyday messages to crude graffiti.
- Vimose inscriptions <https://en.wikipedia.org/wiki/Vimose_inscriptions>
  > Identifies the Vimose comb from Funen, c. 160 AD, bearing the inscription harja, as the oldest undisputed and oldest datable runic inscription.
- Meldorf fibula <https://en.wikipedia.org/wiki/Meldorf_fibula>
  > Dates the brooch to about 50 AD and records that the inscription is the subject of intense academic debate, the controversy turning on whether the graphemes are to be understood as runic, proto-runic or Latin characters.
- Runes, general dating of the elder futhark <https://en.wikipedia.org/wiki/Runes>
  > Places the development of the alphabet in the second century AD among Germanic peoples in present-day Denmark, southern Scandinavia and parts of northern Germany, and dates the Elder Futhark to roughly 150 to 800 CE, with inscriptions of 150 to 550 AD forming Period I.

#### C13 · line 142 · **needs-hedging** · confidence high

> worshipped in sacred groves rather than temples

**Why.** This is the row where the essay reproduces Tacitus most nearly verbatim and where his framing is most visibly Roman. Germania 9 says they think it unfitting 'cohibere parietibus deos', to confine the gods within walls, and that instead 'lucos ac nemora consecrant', they consecrate groves and woods. That whole sentence is constructed as a contrast with Roman practice: the Germani are characterised by not building what Romans build. Two things undercut the exclusive 'rather than'. The first is Tacitus himself, in the same period and almost the same place as this paragraph: Annals 1.51 has Germanicus's troops in 14 AD raze to the ground among the Marsi the celebrated sanctuary they called Tanfana's, and Tacitus's own word for it is templum. The second is the archaeology of Germanic cult sites, which has moved substantially in the last twenty-five years. The Iron Age ritual building at Uppåkra in Scania is described by its excavators as the first Scandinavian building for which the term temple can justly be claimed, and closely comparable god-houses have since been excavated at Tissø in Denmark and at Ranheim and Ose in Norway. Those buildings are third century and later, so they do not bear directly on 9 AD and I am not claiming they do. What they establish is that the flat opposition between grove and temple is not the archaeological picture of Germanic religion, and the wetland sanctuaries such as Oberdorla in Thuringia, with a built and enclosed ritual space running unbroken from the Iron Age into the Merovingian period, complicate it further at the early end. Groves were central and should stay central in the sentence; the exclusion is what needs softening.

**What is actually true.** Sacred groves were central to Germanic worship, and Germania 9 is the source for the claim. But the exclusive contrast with temples is Tacitus's rhetorical opposition to Roman practice rather than an observed fact. Tacitus himself calls a Marsian sanctuary destroyed in 14 AD a templum, and excavation has since produced enclosed and roofed cult buildings at Uppåkra, Tissø, Ranheim and Ose, along with built and enclosed wetland sanctuaries such as Oberdorla whose ritual sequence begins in the Iron Age.

**Replacement, English.**

> worshipped chiefly in sacred groves, though Tacitus also reports a Germanic temple, and archaeology has since found roofed cult houses.

**German counterpart**, `docs/verb_history_de.txt` line 108:

> die in heiligen Hainen statt in Tempeln verehrt wurden

**Sources.**

- Tacitus, Germania 9 (Latin text, The Latin Library) <https://www.thelatinlibrary.com/tacitus/tac.ger.shtml>
  > States that from the greatness of the heavenly beings they judge it improper to confine the gods within walls or to liken them to any human face, and that they consecrate groves and woods and call by the names of gods that mystery which they behold in reverence alone.
- Tacitus, Annals 1.51, on the destruction of the temple of Tanfana <https://en.wikipedia.org/wiki/Tamfana>
  > Records that in the autumn of 14 AD Germanicus's forces massacred the Marsi during the night of a festival and that the celebrated sanctuary called Tanfana's, held sacred by those nations, was levelled to the ground along with both secular and religious structures; Tacitus's term for it is templum.
- Larsson and Lenntorp, 'The Iron Age ritual building at Uppåkra, southern Sweden' <https://www.researchgate.net/publication/268000679_The_Iron_Age_ritual_building_at_Uppakra_southern_Sweden>
  > Describes a tall timber structure with numerous ornamented finds, an elaborate cult house, and argues it is the first Scandinavian building for which the term 'temple' can justly be claimed.
- Excavation of the eighth-century god-house at Ose, Ørsta, Norway, with comparanda at Uppåkra and Tissø <https://www.sciencenorway.no/archaeology-iron-age-viking-age/remains-of-what-may-be-a-temple-where-norse-gods-were-worshiped-have-been-found-in-norway/1755851>
  > Reports a roofed cult building at Ose whose layout is almost identical to the late Iron Age god-houses at Uppåkra in southern Sweden and Tissø in Denmark, and distinguishes the older open-air hørg sites from the later roofed hov.

#### C1 · line 136 · **nitpick** · confidence medium

> lived in small villages and farmsteads scattered through the forests of northern Europe

**Why.** The claim splits cleanly into a part archaeology corroborates and a part that only leads back to Tacitus. Small villages and dispersed farmsteads are exactly what the excavated Roman Iron Age settlements show: Vorbasse in Jutland, Wijster and Odoorn in Drenthe, Floegeln-Eekhoeltjen in Lower Saxony, and Feddersen Wierde on the Weser estuary, the last with roughly 26 farmsteads and about 300 people in the third century. Tacitus supports the same picture in Germania 16, 'nullas Germanorum populis urbes habitari satis notum est ... colunt discreti ac diversi'. The forest, however, is Tacitean scene-setting, from Germania 5's 'terra ... silvis horrida aut paludibus foeda', and the palynology does not support it as the settlement context. Pollen sequences record extensive forest clearance around the Late Bronze Age to Pre-Roman Iron Age transition, about 500 BC, followed by a major expansion of grazing land, arable fields and meadows, so by 9 AD the settled zones were largely open. The concrete cases make the point sharper than the averages do: Feddersen Wierde sits on a fully developed salt marsh with no trees on it at all, and the Celtic-field systems of the north German and Dutch sandy soils are open arable landscape by definition. I am grading this a nitpick rather than an error because woodland was genuinely a larger presence in Germania than in the Mediterranean, and 'scattered' itself is right. What misleads is the implication that the farms sat in woodland clearings rather than in a countryside their occupants had already cleared.

**What is actually true.** Germanic settlements of this period were indeed small villages and single farmsteads, dispersed rather than nucleated, but they stood in a landscape that had been substantially cleared since about 500 BC, and several of the best-excavated of them stood on open salt marsh or sandy heath with no forest at all. The forest framing comes from Tacitus rather than from the archaeology.

**Replacement, English.**

> At the time of the battle at Teutoburg, the Germanic peoples lived in small villages and farmsteads scattered across northern Europe, in a landscape of cleared fields, pasture, and coastal marsh as much as of forest.

**German counterpart**, `docs/verb_history_de.txt` line 102:

> Zur Zeit der Schlacht im Teutoburger Wald lebten die germanischen Völker in kleinen Dörfern und Gehöften, die über die Wälder Nordeuropas verstreut waren.

**Sources.**

- Tacitus, Germania 5 and 16 (Latin text, The Latin Library) <https://www.thelatinlibrary.com/tacitus/tac.ger.shtml>
  > Ch. 5 characterises the land as 'silvis horrida aut paludibus foeda', bristling with forests or foul with marshes. Ch. 16 states 'Nullas Germanorum populis urbes habitari satis notum est' and that they dwell 'discreti ac diversi', separated and apart.
- Caseldine, 'Pollen evidence for the impact of human activity on the landscape during the Iron Age', Internet Archaeology 48 <https://intarch.ac.uk/journal/issue48/4/box1.html>
  > Reports that around the Late Bronze Age / Pre-Roman Iron Age transition, c. 500 BC, pollen data indicate extensive forest clearances followed by a major expansion of grazing areas, cultivated fields and meadows.
- Feddersen Wierde (Haarnagel excavations), overview <https://en.wikipedia.org/wiki/Feddersen_Wierde>
  > Describes a wierde settlement on marshland in the Weser estuary, occupied 1st to 5th centuries AD, with an estimated 300 inhabitants, 450 cattle and 26 farmsteads of timber longhouses in the third century.

#### C12 · line 142 · **nitpick** · confidence high

> Wōðanaz (later Wōden (Old English) and Óðinn (Old Norse)), Þunaraz (Thunor and Þórr), Tīwaz (Tiw and Týr)

**Why.** The linguistics is sound and I found nothing to overturn in it. *Wōðanaz, from the *wōð- of Gothic wods and Old Norse óðr and Old High German wuot plus the *-an- suffix, ultimately PIE *weh2t- 'be excited, inspired', is standard; the ð versus d spelling is a notational choice for the same Proto-Germanic voiced dental fricative, and both circulate, Orel writing *wōđanaz. Þunaraz is the less usual of two competing reconstructions, *Þunraz being the default and *Þunaraz the variant that better accounts for Old High German Donar and Old Saxon Thunaer, recently argued by Haukur Þorgeirsson in Neophilologus; it is defensible, not wrong. *Tīwaz from PIE *deywós is standard. All three descendant pairs are right: Old English Wōden and Old Norse Óðinn, Old English Þunor and Old Norse Þórr, Old English Tīw and Old Norse Týr. What is wrong is the presentation, in two ways that the essay's own conventions make into real defects rather than pedantry. First, none of the three carries an asterisk, in an essay whose header declares that its twenty asterisks mark reconstructed forms and which duly writes *tewtéh2, *þeudō, *bʰer- and *dō-. A reader who has learned that convention will take Wōðanaz for an attested form, which it is not. Second, only the first triple has its languages labelled, so Thunor is Old English and Þórr Old Norse by inference from position alone, an inference made harder by three levels of nested parentheses in a single clause. Nothing here misinforms a reader about the world, only about the status of the forms, hence nitpick.

**What is actually true.** All three theonyms are reconstructions and conventionally carry an asterisk, which the essay supplies for every other reconstructed form it prints. *Wōðanaz, *Þunraz, with *Þunaraz a recognised variant, and *Tīwaz are the standard forms, and the descendant pairs given are correct: Old English Wōden and Old Norse Óðinn, Old English Þunor and Old Norse Þórr, Old English Tīw and Old Norse Týr.

**Replacement, English.**

> Their religion centered on a pantheon of gods whose names linguists reconstruct as *Wōðanaz, later Old English Wōden and Old Norse Óðinn; *Þunraz, later Þunor and Þórr; and *Tīwaz, later Tīw and Týr, among others,

**German counterpart**, `docs/verb_history_de.txt` line 108:

> Ihre Religion konzentrierte sich auf ein Pantheon von Göttern (Wōðanaz (später Wōden (Altenglisch) und Óðinn (Altnordisch)), Þunaraz (Thunor und Þórr), Tīwaz (Tiw und Týr) und andere)

**Sources.**

- Reconstruction: Proto-Germanic *Þunraz <https://en.wiktionary.org/wiki/Reconstruction:Proto-Germanic/%C3%9Eunraz>
  > Gives *Þunraz as the reconstruction, the personification of *þunraz 'thunder', with descendants Old English Þunor, Þūr, Þor; Old High German Donar; Old Saxon Thunær; Old Norse Þórr. Lists *Þunaraz as an alternative reconstruction, citing Haukur Þorgeirsson, 'The Name of Thor and the Transmission of Old Norse Poetry', Neophilologus (December 2023).
- Reconstruction: Proto-Germanic *tīwaz <https://en.wiktionary.org/wiki/Reconstruction:Proto-Germanic/T%C4%ABwaz>
  > Gives *tīwaz, a masculine a-stem from PIE *deywós 'god', meaning 'deity' generally and as a proper noun the war god identified with Mars, with descendants Old English Tīw, Tīg; Old High German Ziu; Old Norse týr, Týr; also the name of the t-rune.
- Reconstruction: Proto-Germanic *Wōdanaz, with Orel's and Kroonen's treatments noted <https://en.wiktionary.org/wiki/Reconstruction:Proto-Germanic/W%C5%8Ddanaz>
  > Gives the reconstructed name of the god, written *Wōđanaz or *Wōdanaz, from *wōda- 'frenzied, possessed' plus the *-an- 'master of' suffix, ultimately PIE *weh2t- 'be excited', with Óðinn in Old Norse, Wōden in Old English, Wodan or Wotan in Old High German and Godan in Lombardic; notes that the form is conventionally written with a preceding asterisk because it is not directly attested.

#### C2 · line 136 · **nitpick** · confidence medium

> growing barley, oats, rye, and wheat

**Why.** This row is archaeologically checkable without Tacitus, who lists no crops at all: Germania 26 says only 'sola terrae seges imperatur', they demand nothing from the soil but a grain crop, and adds that they have no word for autumn. So the four-crop list is the essay's own synthesis from archaeobotany, and archaeobotany supports three of the four cleanly and the fourth only partly. Barley is the staple everywhere, naked and hulled; wheat is present as emmer and bread wheat; oats are directly attested in the Roman Iron Age assemblage at Feddersen Wierde alongside barley, flax, Camelina and beans. Rye is the outlier. It entered Europe as a weed of barley and wheat fields in the Neolithic and only became a crop in its own right in the Iron Age, with the increase in northern and northeastern Germany falling within the Roman Iron Age and the well-documented Danish material, the carbonised rye from the iron-smelting furnaces of southern Jutland, dating to about AD 400. At 9 AD rye was at the very beginning of that process and regionally patchy. The essay's list is alphabetical, which reads as neutral and therefore as coordinate, so a reader takes four equal staples where the record shows one dominant cereal and one that was barely a crop yet. I grade this a nitpick rather than an error because rye cultivation in the Pre-Roman and early Roman Iron Age of the southern Baltic is real, so the sentence is not false.

**What is actually true.** Barley was the staple cereal of the Germanic north, with wheat and oats regularly beside it. Rye entered the fields as a weed and became a crop of its own only during the Iron Age, becoming established in northern and northeastern Germany over the course of the Roman Iron Age and reaching real importance later still, so at the Teutoburg horizon it was marginal and regional rather than one of four equal staples.

**Replacement, English.**

> They practiced mixed agriculture, growing barley above all, along with wheat, oats, and, where it had taken hold, rye, while raising cattle, pigs, sheep, and horses.

**German counterpart**, `docs/verb_history_de.txt` line 102:

> Sie betrieben gemischte Landwirtschaft, bauten Gerste, Hafer, Roggen und Weizen an und hielten Rinder, Schweine, Schafe und Pferde.

**Sources.**

- Behre, 'The history of rye cultivation in Europe', Vegetation History and Archaeobotany 1 (1992) <https://link.springer.com/content/pdf/10.1007/BF00191554.pdf>
  > States that rye came to Europe as an arable weed infesting barley and wheat fields in the early Neolithic, and that only in the Iron Age do the first rye-dominated finds indicate intentional cultivation as a staple; the post-Neolithic domestication took place independently at various places in the centuries around the turn of the Christian era, with pollen and archaeobotanical data from northern and northeastern Germany showing an increase in rye cultivation during the Roman Iron Age.
- 'Rye cultivation in the Danish Iron Age: some new evidence from iron-smelting furnaces', Vegetation History and Archaeobotany (2003) <https://link.springer.com/article/10.1007/s00334-003-0007-6>
  > Analyses carbonised rye and barley preserved in iron-smelting furnaces in southern Jutland dated archaeologically to the Roman / Germanic Iron Age transition, about AD 400, and infers autumn sowing by broadcast followed by light harrowing.
- 'Early Iron Age agriculture: archaeobotanical evidence from an underground granary at Overbygård, northern Jutland', Vegetation History and Archaeobotany <https://link.springer.com/article/10.1007/BF00189430>
  > Reports that in the Late Pre-Roman Iron Age at Overbygård naked barley and bread wheat were the main crops, with hulled barley and flax also present and emmer occurring as a weed or contaminant.
- Tacitus, Germania 26 (Latin text, The Latin Library) <https://www.thelatinlibrary.com/tacitus/tac.ger.shtml>
  > Describes shifting fields and states that only a grain crop is demanded of the land, without naming any cereal species.

#### C6 · line 138 · **nitpick** · confidence medium

> The warrior aristocracy formed a ~comitatus~, a band of followers bound to their lord by oaths of loyalty

**Why.** Comitatus is indeed Tacitus's own word, and that is the point the essay's presentation obscures. Germania 13 has 'gradus quin etiam ipse comitatus habet, iudicio eius quem sectantur', the retinue itself has its grades, at the discretion of the man they follow. But the essay sets ~comitatus~ in an emphasis span exactly as it sets ~Germani~, ~limes~ and ~kurgans~, that is, as the name of the thing, and a reader will take it for what the Germanic warriors called their own institution rather than for the Latin a Roman senator reached for. Beyond the word, the modern picture is more guarded than the sentence. Warrior retinues themselves are not in doubt, and the weapon deposits corroborate hierarchically graded war-bands, so this is not a case of archaeology repeating Tacitus with nothing of its own. What has been walked back is the Gefolgschaft construct that nineteenth- and twentieth-century scholarship built on Germania 13 and 14: Kuhn, Graus and Kroeschell doubted the retinue as the crucible of aristocratic power and doubted the postulated continuity from Tacitus through the Carolingian material, and the ethic of suicidal loyalty in particular has been treated as literary. Two smaller slips ride along. Tacitus's comitatus is the following of a princeps and includes men of modest birth graded by their leader, so it is not simply 'the warrior aristocracy'; and Germania 14 grounds the bond in shame, 'infame in omnem vitam ac probrosum superstitem principi suo ex acie recessisse', not in a sworn oath. Nitpick rather than needs-hedging, because the institution is real and only the framing is Roman.

**What is actually true.** Comitatus is Tacitus's Latin word for the following of a Germanic princeps, not a Germanic term. Warrior retinues themselves are well attested and the graded weapon deposits corroborate them, but Tacitus's account of the bond is framed in Roman moral terms, and the elaborate Gefolgschaft institution that later scholarship built on it has been substantially questioned. Tacitus grounds the tie in the disgrace of outliving one's chief rather than in a sworn oath.

**Replacement, English.**

> Around a chieftain gathered what Tacitus calls a ~comitatus~, a band of followers bound to their lord by loyalty and by the disgrace of outliving him.

**German counterpart**, `docs/verb_history_de.txt` line 104:

> Die Kriegeraristokratie bildete eine ~comitatus~, eine Schar von Gefolgsleuten, die durch Treueide an ihren Herrn gebunden waren.

**Sources.**

- Tacitus, Germania 13 and 14 (Latin text, The Latin Library) <https://www.thelatinlibrary.com/tacitus/tac.ger.shtml>
  > Ch. 13 uses the word comitatus of the retinue and says it has internal grades assigned by the judgement of the man followed. Ch. 14 makes it lifelong disgrace to leave the field having outlived one's chief, and describes the relation in terms of honour and shame rather than of a formal oath.
- 'Quid Tacitus…? The Germania and the Study of Anglo-Saxon England', Florilegium 27 <https://journals.lib.unb.ca/index.php/flor/article/download/19180/25401/0>
  > Traces comitatus as convenient scholarly shorthand since the nineteenth century, from Kemble and Green onward, and records continuing doubts about its relevance and about the vexed reception history of the Germania among German and then Anglophone historians.
- On the Gefolgschaft debate: Kuhn, Graus and Kroeschell as summarised in scholarship on Germanic lordship, and Wenskus, Stammesbildung und Verfassung (1961) <https://en.wikipedia.org/wiki/Reinhard_Wenskus>
  > Wenskus argued that Germanic peoples were organised not on biological kinship but around small warrior elites carrying a core tradition; historians and legal theorists including Kuhn, Graus and Kroeschell doubted the Germanic retinue as the crucible of aristocratic power and doubted continuity from the Tacitean past to later medieval material.

### Cluster D: The Germanic verb

#### D6 · line 148 · **factual-error** · confidence high

> The ~subjunctive and optative moods merged~ into a single Germanic subjunctive, reducing the modal options available to speakers

**Why.** The brief flagged this as the likeliest error in the cluster and the sources bear that out. Germanic did not merge two inherited moods. It kept one and lost the other. The mood that Gothic grammars call the optative and that Old High German grammars call the Konjunktiv is formally the continuation of the PIE optative, suffix *-ih1-/*-yeh1-, and there are no attested Germanic reflexes of the PIE subjunctive as a mood at all. What makes "merged" tempting is that the surviving mood took over the functional territory of both, and that is a real and worth-stating fact, but a formal merger is what the sentence describes and what a reader will take from it, especially since the patched bullet list twelve lines earlier has just introduced the subjunctive and the optative as two distinct PIE moods with distinct jobs. The comparison that makes the error visible is Latin, where the subjunctive genuinely does continue both PIE moods. The essay has applied the Latin situation to Germanic. I considered whether the looser textbook phrasing "the optative merged into the Konjunktiv" rescues it, and it does not: that phrasing is about terminology, the same category under two names, not about two categories becoming one.

**What is actually true.** The Germanic subjunctive is formally the continuation of the PIE optative alone. The PIE subjunctive left no mood-level reflex in Germanic; it was lost outright, and the surviving optative took over its functions. The reduction in modal options that the essay's second clause asserts is correct, and is in fact strengthened by the correction.

**Replacement, English.**

> The ~optative survived as the Germanic subjunctive~ and took over the work of the PIE subjunctive, which was lost outright, reducing the modal options available to speakers.

**German counterpart**, `docs/verb_history_de.txt` line 114:

> ~Konjunktiv und Optativ verschmolzen~ zu einem einzigen germanischen Konjunktiv, was die modalen Optionen für Sprecher reduzierte.

**Sources.**

- Lehmann, A Grammar of Proto-Germanic, ch. 5 Syntax (LRC, UT Austin) <https://lrc.la.utexas.edu/books/pgmc/5-syntax>
  > "the Germanic subjunctive is formally a reflex of the Indo-European optative; reflexes of the Indo-European subjunctive forms are not attested."
- Kim, "Old English cyme and the Proto-Indo-European Aorist Optative in Germanic", Transactions of the Philological Society 117 (2019) <https://onlinelibrary.wiley.com/doi/abs/10.1111/1467-968X.12147>
  > Opens from the long-established position that the Germanic subjunctive continues the Proto-Indo-European optative, and that the Proto-Germanic present subjunctive derives specifically from the PIE present optative.
- German-language handbook tradition on the Old High German Konjunktiv, in the line of Braune, Althochdeutsche Grammatik <https://opendata.uni-halle.de/bitstream/1981185920/8835/1/Diss_Mihajlovic.pdf>
  > In Germanic the old Indo-European potential and cupitive optative became the Konjunktiv, clearly visible in Gothic, while the old genuine Indo-European voluntative and prospective Konjunktiv, the mood of will and expectation, was lost or never developed in Germanic. Braune designates the optative as Konjunktiv, which is a naming convention for one inherited category rather than a claim about two.

#### D7 · line 150 · **needs-hedging** · confidence high

> The ~augment~ (*e-), which had marked past tense in PIE, was lost entirely in Germanic

**Why.** The second half is right and the first half is not, judged as written. Germanic shows no augment anywhere, so "lost entirely in Germanic" describes the observable facts correctly. But "which had marked past tense in PIE" states as settled a question the literature explicitly leaves open. The augment is confined to Indo-Iranian, Greek, Armenian, Phrygian and Albanian, a contiguous group, and specialists divide on whether it is an archaism the other branches lost or a shared or parallel innovation of that area. The point pressed against the archaism reading is that in the earliest texts of the branches that have it the prefix is still optional, which is easier to reconcile with an innovation still spreading than with an inherited obligatory marker lost eight times independently. That is also exactly what patched line 102 now says, so the essay currently asserts on line 150 the thing it declines to assert on line 102. I am judging line 150 on the facts, as instructed, and routing the contradiction itself to agent H.

**What is actually true.** The augment is attested in Indo-Iranian, Greek, Armenian, Phrygian and Albanian and nowhere else. Whether it goes back to Proto-Indo-European, and was therefore available to be lost, or is an innovation of that one contiguous group is an open question, argued in part from the fact that the prefix is still optional in the oldest texts of the branches that have it. What is certain is the negative half: Germanic shows no trace of it.

**Replacement, English.**

> The ~augment~ (*e-), the past-tense prefix of a few branches, left no trace at all in Germanic.

**German counterpart**, `docs/verb_history_de.txt` line 116:

> Das ~Augment~ (*e-), das im PIE die Vergangenheit markiert hatte, ging im Germanischen vollständig verloren.

**Sources.**

- Reference article on the Indo-European augment <https://en.wikipedia.org/wiki/Augment_(Indo-European)>
  > The augment is a verbal prefix used in Indo-Iranian, Greek, Phrygian, Armenian and Albanian to indicate past time. Historical linguists are uncertain whether the augment is a feature that was added to some branches of Indo-European or whether it was present in the parent language and lost by all other branches.
- Discussion of the Graeco-Armenian and Indo-Iranian isoglosses in the comparative literature on Armenian's position in Indo-European <https://jolr.ru/files/(128)jlr2013-10(85-138).pdf>
  > The augment, found in Indo-Iranian, Greek, Armenian, Phrygian and Albanian, might be either an archaism lost elsewhere or a common innovation, and much of the development was parallel rather than shared, since in the earliest records the prefix had not yet become an obligatory marker. It is stated to be impossible to decide whether the presence or absence of an augment should be regarded as a dialectal innovation of late Proto-Indo-European.

#### D12 · line 153 · **nitpick** · confidence medium

> and the "-ed" ending in English ($mAde$, $saId$, played)

**Why.** The etymology is right and the presentation is not quite. All three words are weak preterites descending from the Germanic dental suffix, so the sentence's actual assertion, that the suffix is the origin of the English ending, is true of all three. What they do not do is show the ending the sentence names them for. Made and said are contracted weak preterites, from Old English macode and sægde by loss of the medial vowel, and modern grammars and dictionaries list both among the irregular verbs; only played displays a written "-ed". So two of the three examples of "the -ed ending" contain no -ed. The essay half-knows this, since its own markup reddens the a of made and the i of said as irregular. The trio was plainly chosen to pair with machte, sagte, spielte, which is a real virtue worth preserving, so the fix is to name the ending in a way the examples actually satisfy rather than to change the examples. This misleads nobody about history and I grade it accordingly.

**What is actually true.** Made, said and played all descend from the Germanic dental preterite, but only played carries the written ending "-ed". Made and said are contracted weak preterites, from Old English macode and sægde, and are listed as irregular verbs in modern reference works. They exemplify the dental suffix, which is the sentence's real subject, rather than the spelling the sentence names.

**Replacement, English.**

> This is the origin of the "-te" ending in German preterites (machte, sagte, spielte) and of the English dental preterite, plain in played and worn down in $mAde$ and $saId$.

**German counterpart**, `docs/verb_history_de.txt` line 119:

> Dies ist der Ursprung der "-te"-Endung in deutschen Präterita (machte, sagte, spielte) und der "-ed"-Endung im Englischen ($mAde$, $saId$, played).

**Assumes.** Depends on D10, which I also own and confirm.

**Sources.**

- Standard accounts of Old English weak-verb morphology and syncope <https://en.wikipedia.org/wiki/Weak_verb>
  > Weak verbs are characterized by a dental, normally -t- or -d-, in the preterite. Syncope of the unstressed vowel of the preterite suffix was common in Old English weak verbs, and the modern contracted forms made and said are the end result of that process, from Old English macode and sægde.
- Kiparsky, "The Germanic Weak Preterite" (Stanford) <https://web.stanford.edu/~kiparsky/Papers/lahiri_weakpreterite.pdf>
  > Treats the loss of the medial vowel in weak preterites as a regular West Germanic development conditioned by syllable weight, producing contracted preterites beside uncontracted ones within the same class.

#### D17 · line 155 · **nitpick** · confidence medium

> Speakers of Modern English are aware that the conjugation later became "crowed"

**Why.** The example is right and the sentence built on it is not quite. Two things are wrong with it and neither is grave. First, it makes a claim about what speakers of Modern English know, which no corpus can settle and which is very likely false in the plain reading: crew is far more available to a modern reader as the noun than as the preterite of crow, and it is precisely that unfamiliarity that makes the King James line worth quoting. Second, crew is not simply gone. Dictionaries still list it as a past tense of crow, marked British, with the note that in modern usage it is confined to literary and metaphorical uses. So "later became" overstates a replacement that is not quite complete. The historical direction is correct and the paragraph's argument survives untouched; this is a matter of how the sentence is worded, which is why I grade it as a nitpick rather than dressing it up.

**What is actually true.** Standard Modern English uses the weak crowed. The inherited strong preterite crew has not vanished: dictionaries still list it as a British past tense of crow, confined in modern use to literary and metaphorical contexts. Whether ordinary speakers recognize crew as a preterite of crow at all is not something the essay can assert.

**Replacement, English.**

> Modern English writes "crowed" instead, and the old strong preterite survives only in literary use.

**German counterpart**, `docs/verb_history_de.txt` line 121:

> Sprecher des modernen Englisch wissen, dass die Konjugation später zu "crowed" wurde.

**Assumes.** Depends on D16, which I also own and confirm.

**Sources.**

- Dictionary entry for the verb crow <https://en.wiktionary.org/wiki/crow>
  > "simple past crowed or (UK) crew", with the usage note that "The past tense crew in modern usage is confined to literary and metaphorical uses."
- Reference material on Old English class VII strong verbs <https://oldenglish.info/sv8.html>
  > Crow derives from Old English crāwan with past tense crēow; the strong preterite crew has largely been replaced by the weak crowed in modern English, surviving mainly in archaic, literary and British usage.

#### R5 · line 110 · **nitpick** · confidence medium

> ~Voice~ distinguished active and middle (the latter indicating action affecting the subject or done in the subject's interest), with a developing passive

**Why.** The first two thirds are exactly right and the coda leans further than the sources do. Proto-Indo-European is reconstructed with two voices, active and middle, and the gloss the essay gives the middle is the standard one. What the literature declines to reconstruct is a passive: PIE has no specialized passive markers, and passive meaning is carried by middle inflection. The dedicated passive formations are branch-specific innovations built after the breakup, the Greek -ē-/-thē- aorist and the Indo-Aryan -ya- presents being the usual examples, and they are not cognate with each other. "With a developing passive" reads as a third item in a list of PIE features and invites a reader to think a passive category was under construction in the parent language. There is a charitable reading, that the middle was already doing passive work and so contained the seed, and that reading is true; the trouble is that it is not what the phrase most naturally says. Low severity, and I would not fight hard for it, but the honest verdict is that the coda claims slightly more than the handbooks grant. This is a residue row inside the patched range that the inventory assigns to me, not a re-litigation of a patched sentence.

**What is actually true.** Proto-Indo-European had two voices, active and middle, and no dedicated passive. Passive meaning was expressed by middle inflection, and the passives of the daughter languages are independent later creations rather than a shared inheritance in progress.

**Replacement, English.**

> ~Voice~ distinguished active and middle (the latter indicating action affecting the subject or done in the subject's interest), and the middle carried the work a passive would later do.

**German counterpart**, `docs/verb_history_de.txt` line 76:

> ~Diathese~ unterschied Aktiv und Medium (letzteres zeigte Handlung an, die das Subjekt betrifft oder im Interesse des Subjekts geschieht), mit einem sich entwickelnden Passiv.

**Sources.**

- Comparative study of the passive in the ancient Indo-European languages (Folia Linguistica) <https://www.degruyterbrill.com/document/doi/10.1515/flin-2021-2033/html>
  > In Proto-Indo-European the fundamental distinction within the verbal system is between active and middle, while specialized markers of the passive are lacking and the passive syntactic pattern is encoded with middle inflection. The Indo-European languages developed different strategies for encoding the passive: in some branches the middle extended to the passive function, and dedicated derivational formations arose in a number of languages, such as the Greek -ē-/-thē- aorist and the Indo-Aryan -ya- presents.
- Lehmann, A Grammar of Proto-Germanic, ch. 5 Syntax (LRC, UT Austin) <https://lrc.la.utexas.edu/books/pgmc/5-syntax>
  > In the proto-language both passive and middle meanings were expressed by reflexes of Proto-Indo-European middle forms; those middle forms were maintained only in Gothic and were replaced by compound forms in the other dialects.

### Cluster E: Old High German

#### R2c · line 92 · **factual-error** · confidence high

> then, through Medieval Latin theodiscus ("of the people"), Modern German Deutsch

**Why.** Two things are wrong, and they compound. First, theodiscus is not a station on the way from Germanic to German. It is the Latinized shape of a West Germanic adjective, and the etymological dictionaries say so in as many words: the West Germanic adjective 'appears in Latinized form' as Medieval Latin theodiscus from 786. German Deutsch continues the native word, Old High German thiutisk or diutisc, built on *þeudō with the ordinary Germanic -isk suffix, through Middle High German diutisch and tiutsch. The Latin form is the earliest surviving record of the word, which is a fact about the manuscript tradition, not about descent. Second, and worse for a reader following the arrows, German Deutsch does not descend through Old English at all. Old English þēod is a sister reflex of *þeudō, not an ancestor of anything German. The sentence's chain of 'then … then … then' asks the reader to read a line of descent PIE to Proto-Germanic to Old English to Medieval Latin to Modern German, and only the first link of that chain is a line of descent. I note for completeness that a minority position holds theodiscus to have been coined in the Carolingian chancery and the Old High German word to be late; even on that view nothing routes German through Old English, and the -isk formation remains West Germanic.

**What is actually true.** Modern German Deutsch continues Old High German diutisc, a native West Germanic adjective formed from *þeudō 'people' with the suffix -isk. Medieval Latin theodiscus is a Latinization of that same Germanic adjective and is simply its earliest written attestation, from 786, in the papal legate's report on the English synods. Old English þēod is a cognate of Proto-Germanic *þeudō, not a link in German's line of descent.

**Replacement, English.**

> it became Proto-Germanic *þeudō, which gave Old English þēod (“nation”) and, with an adjective suffix, Old High German diutisc, the word Latin scribes recorded as theodiscus (“of the people”) in 786 and the ancestor of Modern German Deutsch.

**German counterpart**, `docs/verb_history_de.txt` line 58:

> Daraus wurde protogermanisch *þeudō, dann altenglisch þēod („Nation“), dann, über mittellateinisch theodiscus („des Volkes“), neuhochdeutsch Deutsch.

**Assumes.** Assumes R2b's forms *þeudō and þēod stand, which they do. The finding is about the relation the sentence asserts between them, not about the forms.

**Sources.**

- Etymologisches Wörterbuch des Deutschen, s.v. deutsch (DWDS) <https://www.dwds.de/wb/deutsch>
  > "In latinisierter Form erscheint das westgerm. Adjektiv bereits zur Zeit Karls des Großen (seit 786) als mlat. theodiscus 'zum (eigenen) Volk gehörig'." The German word is presented as an inherited Germanic formation on germ. *þeuðō 'Volk' with the -isk- suffix: ahd. thiutisk (um 1000), mhd. diutisch, diutsch, tiutsch, with cognates asächs. thiudisc, mnd. dǖdesch, mnl. duutsc. It is not presented as a borrowing from Medieval Latin.
- Wikipedia, "Theodiscus" <https://en.wikipedia.org/wiki/Theodiscus>
  > Theodiscus is Medieval Latin "corresponding to Old English þēodisc, Old High German diutisc and other early Germanic reflexes of Proto-Germanic *þiudiskaz", derived from *þeudō 'people' plus the adjective suffix *-iskaz. Its first attestation is a letter of about 786 by the bishop of Ostia to Pope Adrian I reporting synods in England, whose decisions were read out "tam Latine quam theodisce".

#### R6 · line 113–117 · **factual-error** · confidence medium

> ^🐎^ ~e-grade~ (full grade): the vowel *e (as in the root *bʰer-, "to carry") / 🐄 ~o-grade~: the vowel *o (as in *bʰor-) / 🐖 ~zero-grade~: absence of the vowel (as in *bʰr-) / 🐐 ~lengthened e-grade~: *ē (as in *mḗh₁-n̥s) / 🐑 ~lengthened o-grade~: *ō (as in *n̥-péh₂-tōr)

**Why.** The first three are the standard textbook series and are correct, both in shape and as illustrations. The fourth is defensible but awkward: *mḗh₁n̥s 'moon, month' is a real reconstruction and its nominative really does show a long vowel against the oblique stem, but the length arises from compensatory lengthening of an earlier *méh₁n̥s-s rather than from root ablaut proper, and reference treatments warn that many apparent lengthened grades are products of Szemerényi's and Stang's laws rather than of ablaut. I would not raise that alone. The fifth is the finding. *n̥-péh₂-tōr is not a reconstruction the handbooks give of anything. Targeted searches for the string return only the unrelated root *peh₂- 'to protect' and the entries for *ph₂tḗr 'father'; the PIE word the form seems to be reaching for, 'nephew, grandson', is reconstructed *népōts and is standardly analysed as *ne 'not' plus *pótis 'master'. The likeliest explanation is a Proto-Indo-Europeanization of Greek ἀπάτωρ 'fatherless', which is the form reference presentations do use to illustrate the lengthened o-grade; its PIE-style shape would be *n̥-ph₂-tōr, with the root of 'father' in zero grade, not the accented full grade *péh₂- of a different root meaning 'protect'. There is a second, quieter problem even if one grants the form: the *ō it is offered to illustrate sits in the agent suffix *-tor- lengthened to *-tōr in the nominative, while the accent mark sits on the root, so the bullet points at a syllable the notation does not stress. The clean fix keeps the reader on the root the list opens with, since *bʰer- has a genuine lengthened o-grade root noun: *bʰōr 'thief', literally one who carries off, behind Greek φώρ and Latin fūr.

**What is actually true.** *bʰer-, *bʰor- and *bʰr- are the standard illustration of the e-, o- and zero-grades. *mḗh₁n̥s is a real form whose long nominative vowel comes from compensatory lengthening rather than from root ablaut. *n̥-péh₂-tōr is not a reconstruction found in the reference literature; the lengthened o-grade is standardly illustrated by nominatives such as Greek ἀπάτωρ 'fatherless' or by the root noun *bʰōr 'thief', from the same root *bʰer- the list already uses.

**Replacement, English.**

> 🐑 ~lengthened o-grade~: *ō (as in *bʰōr, "thief", from the same root)

**German counterpart**, `docs/verb_history_de.txt` line 83:

> 🐑 ~gedehnte o-Stufe~: *ō (wie in *n̥-péh₂-tōr)

**Sources.**

- Wiktionary, Reconstruction:Proto-Indo-European/bʰṓr <https://en.wiktionary.org/wiki/Reconstruction:Proto-Indo-European/b%CA%B0%E1%B9%93r>
  > Reconstructs *bʰṓr 'thief' from earlier *bʰórs, "one who bears", a root noun of *bʰer- 'to carry' showing the lengthened o-grade, continued by Ancient Greek φώρ 'thief' and Latin fūr 'thief'.
- Wikipedia, "Indo-European ablaut" <https://en.wikipedia.org/wiki/Indo-European_ablaut>
  > Lists the five grades and illustrates them with the Greek 'father' paradigm: e-grade pa-tér-a, lengthened e-grade pa-tḗr, zero-grade pa-tr-ós, o-grade a-pá-tor-a, lengthened o-grade a-pá-tōr 'fatherless'. It adds that "many examples of lengthened grades … are not directly conditioned by ablaut. Instead, they are a result of sound changes like Szemerényi's law and Stang's law."
- Wiktionary, Reconstruction:Proto-Indo-European/népōts <https://en.wiktionary.org/wiki/Reconstruction:Proto-Indo-European/n%C3%A9p%C5%8Dts>
  > Reconstructs the PIE word for grandson or nephew as *népōts, with the laryngeal-free derivation from *né 'not' plus *pótis 'master, lord'; no reconstruction of the shape *n̥-péh₂-tōr appears.
- Wiktionary, Reconstruction:Proto-Indo-European/mḗh₁n̥s <https://en.wiktionary.org/wiki/Reconstruction:Proto-Indo-European/m%E1%B8%97h%E2%82%81n%CC%A5s>
  > Glosses 'moon; month' and derives it "from earlier *méh₁n̥s-s, probably from *meh₁- ('to measure')", an acrostatic athematic noun alternating between the lengthened nominative *mḗh₁n̥s and the oblique stem *méh₁n̥s-.

#### R2a · line 92 · **needs-hedging** · confidence medium

> Linguists reconstruct PIE *tewtéh₂, from the root *tew- ("to swell, be strong"), as a word meaning "the full community" or simply "the people"

**Why.** The reconstruction itself is solid and needs no hedge: *tewtéh₂ 'people, tribe' rests on Germanic *þeudō, Italic *toutā, Celtic *toutā, Baltic tautà and Oscan touto, and no one disputes it. The derivation is the problem. Deriving *tewtéh₂ from the root for swelling is the traditional account, and it is the one popular references repeat, but it is one proposal among several and it is under active objection: the root is properly *tewh₂-, and the laryngeal makes the derivation phonologically awkward; Derksen rejects the connection on semantic grounds; Mallory and Adams float a different root of the shape *tew-, possibly the one behind Latin tueor 'watch over'; and because the word is confined to the western branches and resists derivation from any PIE root, a non-Indo-European source has been proposed, which de Vaan supports on the general ground that words for 'people' are often loans and which Beekes calls speculative. The essay states the contested step flatly, with 'Linguists reconstruct' carrying the whole sentence including the derivation. That is a hedge misplaced rather than a hedge missing. The root written as *tew- rather than *tewh₂- is defensible on its own, since that is Mallory and Adams's shape and Watkins's presentation, and I am not raising it separately. 'The full community' is an interpretive rendering of the standard glosses 'people, tribe' and 'crowd', not a false one.

**What is actually true.** PIE *tewtéh₂ 'people, tribe' is securely reconstructed from its western Indo-European reflexes. Its further derivation is not secure. The traditional link to the root for swelling and being strong is doubted on both phonological and semantic grounds, an alternative root has been proposed, and some scholars suspect the word was borrowed rather than inherited.

**Replacement, English.**

> Linguists reconstruct PIE *tewtéh₂ as a word meaning “the full community” or simply “the people”, usually traced to a root *tew- (“to swell, be strong”), though that step is disputed and the word may be a borrowing.

**German counterpart**, `docs/verb_history_de.txt` line 58:

> Linguisten rekonstruieren PIE *tewtéh₂, von der Wurzel *tew- („schwellen, stark sein“), als ein Wort für „die gesamte Gemeinschaft“ oder schlicht „das Volk“.

**Sources.**

- Wiktionary, Reconstruction:Proto-Indo-European/tewtéh₂ <https://en.wiktionary.org/wiki/Reconstruction:Proto-Indo-European/tewt%C3%A9h%E2%82%82>
  > Glosses the form 'heap, pile; crowd; people'. On etymology: derivation from *tewh₂- 'to be strong; swell' is considered, but "the presence of a laryngeal renders this etymology doubtful"; Derksen rejects the connection on semantic grounds; Adams and Mallory propose an alternative root *tew-, possibly connected to Latin tueor; and given the difficulty of deriving it from a PIE root and its restriction to western branches, "it has been proposed that the term may derive from a non-IE substrate", with de Vaan noting that terms for 'people' are often loanwords and Beekes calling the substrate theory speculative. Descendants listed include Proto-Germanic *þeudō, Proto-Italic *toutā, Proto-Celtic *toutā and Proto-Balto-Slavic *t(j)autāˀ.
- Wiktionary, Reconstruction:Proto-Indo-European/tewh₂- <https://en.wiktionary.org/wiki/Reconstruction:Proto-Indo-European/tewh%E2%82%82->
  > Glosses the root 'to swell, grow fat; to be strong', which is the gloss the essay uses, and is the root traditionally invoked for the 'swollen mass, multitude' semantics behind 'people'.

#### R9 · line 125 · **needs-hedging** · confidence medium

> These vowel changes are direct inheritances from Proto-Indo-European, preserved across five millennia of linguistic evolution.

**Why.** The word doing the damage is 'direct', reinforced by 'preserved'. What German strong verbs inherit from Proto-Indo-European is the alternation, not the vowels. Every vowel in the triads the sentence is summing up is the outcome of later change. The a of sang continues a PIE *o, because PIE *a, *o and *ə all fell together as *a in Proto-Germanic. The u of gesungen continues a syllabic nasal, which Proto-Germanic resolved as *un. The i of singen continues *e raised before a nasal. Old High German umlaut, Middle High German lengthening and the New High German diphthongizations then worked the results over again, and paradigms were levelled by analogy on top of that: Middle High German still opposed sanc to sungen in the preterite, and modern sangen is a rebuilding. The essay knows this, which is what makes the sentence odd rather than merely loose: the paragraph's own lead-in says that PIE *e and *o "later developed into different vowels in the daughter languages", and then the closing sentence calls the result a direct inheritance preserved. Hedging is the right fix rather than deletion, because the underlying claim, that the alternation itself descends from PIE ablaut, is true and is the whole point of the section.

**What is actually true.** What survives from Proto-Indo-European is the ablaut alternation, not the vowels themselves. Each vowel in the German triads is the product of Germanic and then German sound change acting on an inherited alternation, with analogical levelling on top, so the pattern is continuous while the sounds are not preserved.

**Replacement, English.**

> These vowel changes descend from Proto-Indo-European ablaut, reshaped by five millennia of sound change and still recognizable through all of it.

**German counterpart**, `docs/verb_history_de.txt` line 91:

> Diese Vokalwechsel sind direkte Erbschaften aus dem Proto-Indoeuropäischen, bewahrt über fünf Jahrtausende sprachlicher Evolution.

**Assumes.** Assumes R8's triads are what this sentence refers to, and assumes G13's five-thousand-year figure. My replacement keeps 'five millennia' rather than adjusting it, so if G13 changes the figure this sentence should track G13. Note also that this sentence runs straight into the heading `The Migration to Europe` with no newline, and the replacement preserves that.

**Sources.**

- Britannica, "Germanic languages: Vowels" <https://www.britannica.com/topic/Germanic-languages/Vowels>
  > "Proto-Indo-European *ə, *a, and *o coalesced in Proto-Germanic as *a", and "syllabic *i, *u, *ṃ, *ṇ, *ḷ, and *ṛ became in Proto-Germanic the vowels *i and *u and the sequences *um, *un, *ul, and *ur". These are the changes that produce the a of sang and the u of gesungen.
- Wikipedia, "Germanic strong verb" <https://en.wikipedia.org/wiki/Germanic_strong_verb>
  > Proto-Germanic retained the PIE ablaut system in the strong classes, but the grades "underwent systematic alternations influenced by Proto-Germanic sound shifts, such as the development of *a from PIE *o"; later, once ablaut ceased to be productive, the classes lost cohesion and anomalous and analogical forms arose.

#### E1 · line 156 · **nitpick** · confidence medium

> The Germanic dialects spoken in what is now southern Germany and Switzerland developed into Old High German (roughly 750–1050 AD)

**Why.** The date range is standard and needs no change. The geography is too small. Old High German is not a southern phenomenon only: it comprises Upper German (Alemannic, Bavarian) AND Central German (Middle Franconian, Rhine Franconian, South Rhine Franconian, East Franconian), and the Middle Franconian scriptoria include Trier, Echternach and Cologne. Austria is missing too, since Bavarian OHG is written at Salzburg and Kremsmünster as well as Freising and Regensburg. This matters inside this very paragraph rather than only as a map correction: three sentences later the essay uses Kölsch, spoken in Cologne, as its northern example, and Cologne sits inside the Old High German area. As written, a reader is given a picture in which High German grows in the far south and Kölsch is somewhere else. I grade this a nitpick rather than a factual error because the sentence does not say 'only', and the dialects it names did in fact develop into Old High German.

**What is actually true.** Old High German runs conventionally from about 750 to about 1050, with some scholars starting it at 500 or 600 where they date the shift's onset. Its dialect base is Upper German plus Central German, that is southern and central Germany, Austria, Switzerland, Alsace and Luxembourg, reaching north to the Benrath line and taking in Cologne.

**Replacement, English.**

> The Germanic dialects spoken in what is now southern and central Germany, Austria, and Switzerland developed into Old High German (roughly 750–1050 AD), distinguished from other Germanic languages by the ~High German consonant shift~.

**German counterpart**, `docs/verb_history_de.txt` line 122:

> Die germanischen Dialekte, die im heutigen Süddeutschland und der Schweiz gesprochen wurden, entwickelten sich zum Althochdeutschen (etwa 750–1050 n. Chr.), das sich von anderen germanischen Sprachen durch die ~hochdeutsche Lautverschiebung~ unterschied.

**Sources.**

- Wikipedia, "Old High German" <https://en.wikipedia.org/wiki/Old_High_German>
  > "Old High German is generally dated from around 750 to around 1050", and lists the OHG dialects as Upper German (Alemannic at Murbach, Reichenau, Sankt Gallen, Strasbourg; Bavarian at Freising, Passau, Regensburg, Augsburg) and Central German (Middle Franconian at Trier, Echternach, Cologne; Rhine Franconian at Lorsch, Speyer, Worms, Mainz, Frankfurt; South Rhine Franconian at Wissembourg; East Franconian at Fulda, Bamberg, Würzburg).
- Search synthesis over Wikipedia "Old High German" and "Upper German" <https://en.wikipedia.org/wiki/Upper_German>
  > OHG dialects are traditionally classified into Upper German and Central German, with East Franconian and Rhenish Franconian spoken just north of the Upper German area and Central Franconian spoken along the Moselle and Rhine to the northern border of the High German speech area.

#### E12 · line 157 · **nitpick** · confidence medium

> Today, German strong verbs must largely be memorized individually, their ablaut patterns, while still systematic, are no longer predictable from the infinitive.

**Why.** The first clause is well hedged by 'largely' and is fair. The second clause is not hedged and goes further than the evidence. Modern German retains a great deal of predictability: an infinitive with i plus nasal plus consonant takes a and u almost without exception (singen, sinken, trinken, binden, finden, gelingen), and the ie verbs take o just as reliably (biegen, fliegen, ziehen). Against that, there are genuinely unpredictable pockets: leiden gives litt but meiden gives mied, and geben gives gab where nehmen gives nahm and heben gives hob. So the honest statement is that the infinitive often points at the pattern without settling it, not that it no longer predicts at all. Reference descriptions say the strong system in German is still coherent, in contrast to English where it has disintegrated, which is the opposite emphasis from 'no longer predictable'. I grade this a nitpick rather than needs-hedging because the sentence already concedes 'while still systematic', so the two halves argue with each other rather than the sentence stating a contested thing flatly. Per the brief I am not reporting the comma splice; my replacement happens to remove it because the sentence had to be recast anyway.

**What is actually true.** German strong verbs cannot be identified as strong from the infinitive, and several groups are genuinely unpredictable, but the strong system in German remains coherent and many patterns follow reliably from the shape of the infinitive stem. The infinitive constrains the pattern without determining it.

**Replacement, English.**

> Today, German strong verbs must largely be memorized individually. Their ablaut patterns remain systematic, and the shape of the infinitive often points to the pattern, but it no longer settles it.

**German counterpart**, `docs/verb_history_de.txt` line 123:

> Heute müssen deutsche starke Verben größtenteils einzeln auswendig gelernt werden: Ihre Ablautmuster, obwohl noch systematisch, sind nicht mehr aus dem Infinitiv vorhersagbar.

**Sources.**

- Wikipedia, "Germanic strong verb" <https://en.wikipedia.org/wiki/Germanic_strong_verb>
  > "The coherence of the strong verb system is still present in modern German", whereas in English "the original regular strong conjugations have largely disintegrated", so that for English a regular / irregular split is more useful than a strong / weak one. Principal parts remain to a degree predictable in German and not in English.
- Mailhammer, The Germanic Strong Verbs: Foundations and Development of a New System <https://dokumen.pub/the-germanic-strong-verbs-foundations-and-development-of-a-new-system-9783110198782-9783110199574.html>
  > Treats the Germanic strong verbs as a system whose classes are defined by ablaut and which is reorganized rather than dissolved in the modern languages, with new series arising by analogy.

#### E3 · line 156 · **nitpick** · confidence medium

> This series of sound changes transformed voiceless stops into fricatives or affricates (p → pf or ff; t → ts or s; k → ch)

**Why.** Judged together with E5, E6 and E7, as the inventory asks. Nothing in this sentence is false. Every outcome it lists is a real outcome, and the parenthesis is a fair summary of what standard German shows. Two things are missing, and only one of them is repaired later. First, the geographic point: 'k → ch' holds after a vowel across all High German, which is the maken/machen isogloss itself, while initial k is unshifted in standard German (Kind, kommen) and shifts only in the far south. E5 and E6 arrive two sentences later and do rescue exactly this, since the Swiss Chuchi example is the initial-k shift under another name. So the k simplification is qualified in time and in the right terms. Second, and not rescued anywhere: the shift has a further phase acting on the voiced stops, in which Germanic d hardens to t. That phase is the most widespread part of the whole shift, reaching even the northernmost High German dialects, and it produces the German and English pairs a reader is most likely to have noticed, Tag against day and tun against do. The essay's account of what the shift did therefore stops halfway, and nothing later in the essay finishes it. I grade this a nitpick because incompleteness is not misinformation, and I would not defend a stronger grade against a skeptic.

**What is actually true.** The High German consonant shift has more than one phase. The best-known phase turned the voiceless stops p, t and k into affricates initially, after a consonant and in gemination, and into fricatives after a vowel. A further phase hardened the voiced stops: Germanic d to t everywhere in High German, and b to p and g to k only in the Bavarian south. Germanic þ to d followed later still. Within the first phase, k shifts after a vowel across all High German and only initially in Alemannic and Bavarian, which is why standard German has machen but also Kind.

**Replacement, English.**

> This series of sound changes transformed voiceless stops into fricatives or affricates (p → pf or ff; t → ts or s; k → ch after a vowel), giving German words like ~Pfund~, ~Wasser~, and ~machen~ their characteristic sounds where English has ~pound~, ~water~, and ~make~. A second phase hardened the voiced stop d into t, which is why German has ~Tag~ and ~tun~ where English has ~day~ and ~do~.

**German counterpart**, `docs/verb_history_de.txt` line 122:

> Diese Reihe von Lautveränderungen verwandelte stimmlose Plosive in Frikative oder Affrikate (p → pf oder ff; t → ts oder s; k → ch), wodurch deutsche Wörter wie ~Pfund~, ~Wasser~ und ~machen~ ihre charakteristischen Laute erhielten, wo das Englische ~pound~, ~water~ und ~make~ hat.

**Sources.**

- Wikipedia, "High German consonant shift" <https://en.wikipedia.org/wiki/High_German_consonant_shift>
  > The shift comprises a first phase (voiceless stops p, t, k spirantize or affricate) and a second phase, the Medienverschiebung, in which voiced stops d, b, g devoice to t, p, k. The d shift "is found in Upper German and most Central German", while b to p and g to k are "only found consistently in (Old) Bavarian". On position: "All dialects shift /k/ to /xx/ after a vowel; only the Upper German Alemannic and Bavarian shift it in other positions." Modern standard German retains unshifted consonants "only after a fricative … or in the combination /tr/".
- Search synthesis over Citizendium "Second Consonant Shift" and Wikipedia "High German consonant shift" <https://en.citizendium.org/wiki/Second_Consonant_Shift>
  > The shift is described in successive phases: voiceless stops became fricatives in certain environments, the same sounds became affricates in others, voiced stops became voiceless (day / Tag), and /θ/ became /d/. "The strengthening of Germanic [d] to [t] was most widespread and was found even in the most northern dialects of High German."

#### R8 · line 121–123 · **nitpick** · confidence medium

> 🇩🇪 singen, $sAng$, $gesUngen$ (sing, $sAng$, $sUng$) / 🇩🇪 nehmen, $nahm$, $genOMmen$ (take, $tOOk$, taken) / 🇩🇪 geben, $gAb$, gegeben (give, $gAve$, given)

**Why.** All nine forms are correct German and correct English, so as quoted verb forms the row passes. What fails is the parallel. Two of the three pairs are cognates in the same ablaut class: singen and sing are both class III and continue the same Germanic verb, and geben and give are both class V and likewise. The middle pair is neither. English take is a late Old English borrowing from Old Norse taka, a class VI strong verb whose past tōc and participle tekinn give took and taken; it displaced Middle English nimen, from Old English niman, which is the actual cognate of German nehmen and, like nehmen, a class IV verb. So in a passage whose thesis is that these vowel alternations were inherited, the middle line pairs a class IV German verb with a class VI Norse loan and marks both sets of vowels red as though they illustrated the same inheritance. Nothing false is asserted, since take, took, taken is itself a genuine inherited Germanic ablaut alternation, which is why I grade this a nitpick rather than anything stronger. The fix is to use a pair that is cognate and same-class, as the other two lines are: brechen and break are both class IV and both continue Proto-Germanic *brekaną.

**What is actually true.** singen / sing and geben / give are cognate pairs in the same strong class, so their vowel alternations really do continue the same inherited series. nehmen and take are neither cognate nor in the same class: take is a Norse loan of class VI that replaced English's own class IV niman, the cognate of nehmen. A German and English pair that would carry the passage's point for class IV is brechen and break.

**Replacement, English.**

> 🇩🇪 brechen, $brAch$, $gebrOchen$ (break, $brOke$, $brOken$)

**German counterpart**, `docs/verb_history_de.txt` line 88:

> 🇩🇪 nehmen, $nahm$, $genOMmen$ (take, $tOOk$, taken)

**Assumes.** Assumes E8's seven-class system stands, which my own verdict on E8 confirms. The $…$ capitalization in my replacement follows the convention of the surrounding lines, where uppercase marks the letters that differ from the regular composition; Phase 3 owns whether the app reddens exactly those letters.

**Sources.**

- Oxford English Dictionary and Etymonline, s.v. take <https://www.etymonline.com/word/take>
  > English take comes from late Old English tacan, borrowed from a Scandinavian source such as Old Norse taka, past tók, participle tekinn; it was a class VI strong verb in early Scandinavian and entered the corresponding Old English class. It "gradually replaced Middle English nimen, from Old English niman, from the usual West Germanic verb *nemanan (source of German nehmen)".
- Wikipedia, "Germanic strong verb" <https://en.wikipedia.org/wiki/Germanic_strong_verb>
  > Sets out the seven classes and their vowel patterns, with class IV and class VI as distinct ablaut series; German nehmen belongs with the class IV verbs and take with class VI.

### Cluster F: Tense-building

#### F13 · line 169 · **factual-error** · confidence high

> These include the modal verbs ~können~ (can), ~müssen~ (must), ~dürfen~ (may), ~sollen~ (shall), ~mögen~ (may/like), and ~wissen~ (to know)

**Why.** Two halves, and they come out opposite ways. The list itself is exactly right: six derived preterite-presents survive into modern German, dürfen, können, mögen, müssen, sollen and wissen, and those are the six named. The omission of wollen is not an oversight but the correct call, and this is worth saying plainly because a careless editor would 'fix' it. Wollen is a modal verb, and it inflects like a preterite-present, but historically it is not one: its present continues an old optative, and it took on the preterite-present inflectional pattern secondarily on the strength of its modal semantics. So the essay's list is the right list for a sentence about preterite-presents. The error is the label. Wissen is not a modal verb in any German grammar. The standard formulation is that all the preterite-presents except wissen serve as modals, wissen being the sole full verb in the class, and Duden's inventory of Modalverben is dürfen, können, mögen, müssen, sollen and wollen. Calling all six "the modal verbs" therefore does two things at once: it misclassifies wissen for a reader learning German, and it obscures the neat fact underneath, which is that the modal class and the preterite-present class overlap heavily without coinciding, each having exactly one member the other lacks. The replacement below fixes the label and puts that fact where the reader can see it. It also protects the wollen omission from being read as a gap.

**What is actually true.** Six preterite-presents survive in modern German: dürfen, können, mögen, müssen, sollen and wissen. Of these, all but wissen function as modal verbs; wissen is the class's only full verb. Wollen is the sixth modal verb but is not a preterite-present, its present continuing an old optative and its preterite-present-style inflection being a secondary adaptation.

**Replacement, English.**

> Six survive in modern German: the modal verbs ~können~ (can), ~müssen~ (must), ~dürfen~ (may), ~sollen~ (shall), and ~mögen~ (may/like), together with ~wissen~ (to know), which shares their history but is not a modal. ~Wollen~ is a modal that stands outside the class, its present continuing an old optative.

**German counterpart**, `docs/verb_history_de.txt` line 135:

> Dazu gehören die Modalverben ~können~ (can), ~müssen~ (must), ~dürfen~ (may), ~sollen~ (shall), ~mögen~ (may/like) und ~wissen~ (to know).

**Assumes.** Depends on F12, which I own and confirm.

**Sources.**

- German Wikipedia, "Präteritopräsens" <https://de.wikipedia.org/wiki/Pr%C3%A4teritopr%C3%A4sens>
  > "Die meisten Grundverben der heutigen Präteritopräsentia des Deutschen sind ausgestorben; dagegen sind von ihnen sechs abgeleitete Präteritopräsentia in der neuhochdeutschen Sprache erhalten: dürfen, können, mögen, müssen, sollen, wissen." And: "Außer wissen dienen alle Präteritopräsentia im Deutschen als Modalverben." On wollen: "historisch betrachtet ist dieses jedoch kein Präteritopräsens, sondern eine Optativform (Wunschform)."
- grammis (Institut für Deutsche Sprache, Mannheim), terminology entry "Präteritopräsens" <https://grammis.ids-mannheim.de/terminologie/3900>
  > Lists the class as dürfen, können, mögen/möchte-, müssen, sollen, wissen, and separates "Das Vollverb wissen und die Modalverben (mit Ausnahme von wollen)". On wollen: "Das Verb wollen ist kein Präteritopräsens, hat sich aber aufgrund seines modalen Charakters dem als Flexionsklassenmerkmal für Modalverben erkennbaren Flexionsmuster der Präteritopräsentia angepasst."
- Middle High German reference material on the Präterito-Präsentia <https://mhd.sawogra.de/tptpraes.php>
  > The Middle High German preterite-presents are listed as kunnen, durfen, suln, turren, mugen, müezen and wizzen, with wizzen not counted among the modal verbs while wellen (wollen) is classified as a modal.

#### F8 · line 164 · **needs-hedging** · confidence medium

> Beginning in Middle High German, the verb ~werden~ (to become) was grammaticalized as a future auxiliary

**Why.** The onset date is defensible, and I want to say so first, because the trap here is to overcorrect it. Read strictly as a statement about when the process STARTED, "beginning in Middle High German" is right and if anything conservative: Concu's corpus study finds werden plus infinitive already in Old High German and argues it was well established in the first two centuries of MHG, against the older Bech line that it arose in the thirteenth century out of werden plus present participle. So the date is not the defect. The defect is that the sentence stops at the onset while its grammar reports a completed change, and the essay never supplies the terminus anywhere. Three facts the reader is left without. In MHG the construction was rare; Paul's grammar is cited for exactly that, and the ordinary MHG way of referring to the future was the simple present, with periphrases in sol, muoz and wil as the standing alternatives. Through the thirteenth century werden plus present participle actually outnumbered werden plus infinitive, 143 to 39 in the ReM corpus. And the grammaticalization culminates in the sixteenth century, in Early New High German, where the ratio inverts to 9 against 502 in the Bonn corpus. The essay dates Old High German and Middle High German to the year and then never names Early New High German at all, so a reader following its timeline places the arrival of the German future in the MHG period and is off by roughly two centuries on the part that matters. Note the asymmetry with F2 six lines earlier, where the essay does give the two-stage story, began here and became established there. Giving the future the same two-stage treatment is the fix, and it costs one clause.

**What is actually true.** werden plus infinitive is attested from Old High German and occurs through Middle High German, but it is rare there, is outnumbered by werden plus present participle in the thirteenth century, and competes with the simple present and with modal periphrases in sollen, wollen and müssen. Its grammaticalization as the regular future auxiliary belongs to Early New High German and culminates in the sixteenth century.

**Replacement, English.**

> Middle High German began to pair the verb ~werden~ (to become) with an infinitive, but the pattern was rare there and competed with periphrases built on ~sollen~ and ~wollen~; it hardened into a true future auxiliary only in Early New High German:

**German counterpart**, `docs/verb_history_de.txt` line 130:

> Beginnend im Mittelhochdeutschen wurde das Verb ~werden~ (to become) als Futurauxiliar grammatikalisiert:

**Assumes.** Depends on F3, which I own and confirm at 1050 to 1350. The replacement prose introduces Early New High German, a period the essay does not currently name and for which no inventory row exists; conventionally it runs about 1350 to 1650.

**Sources.**

- Valentina Concu, "Werden and Periphrases with Present Participles and Infinitives: A Diachronic Corpus Analysis", Journal of Germanic Linguistics <https://www.cambridge.org/core/journals/journal-of-germanic-linguistics/article/abs/werden-and-periphrases-with-present-participles-and-infinitives-a-diachronic-corpus-analysis/E58A413B850282E1738A3C01118520C0>
  > Abstract: "although werden + present participle and werden + infinitive were often used in similar contexts, the former construction was not the source from which the werden future emerged. Old High German data also show the use of werden + infinitive, which suggests that it was already well established in the first two centuries of the Middle High German period. This provides evidence against the view that the construction developed as late as the 13th century. I also address the grammaticalization process that werden + infinitive underwent during the Early New High German period and suggest that it culminated in the 16th century."
- Hartmann, "Diachronie der Zukunft", Beiträge zur Geschichte der deutschen Sprache und Literatur (2021) <https://www.degruyter.com/document/doi/10.1515/bgsl-2021-0028/html?lang=en>
  > In thirteenth-century Middle High German werden plus Participle I is somewhat more frequent than werden plus infinitive, 143 attestations against 39 in the ReM corpus; werden plus infinitive then increases sharply in the sixteenth century, 9 attestations of werden plus Participle I against 502 of werden plus infinitive in the Bonn Early New High German corpus.
- Secondary discussion of Hermann Paul, Mittelhochdeutsche Grammatik, on the MHG future <https://d-nb.info/1238885934/34>
  > In Middle High German the werden future is very rare; the periphrastic future is discussed there in terms of sol, muoz and wil with the infinitive alongside the construction with werden, the simple present otherwise carrying future reference.
- Wikipedia, "Middle High German verbs" <https://en.wikipedia.org/wiki/Middle_High_German_verbs>
  > Middle High German had three auxiliary-built tenses, perfect, pluperfect and future, all much less frequently used than in the modern language, and süln/suln was one of several possible choices for the future auxiliary.

#### F16 · line 171 · **nitpick** · confidence high

> and vowel differences between singular and plural (ich $kAnN$ vs. wir können)

**Why.** The generalization is true of five of the six verbs the essay has just named and false of the sixth. Kann/können, muss/müssen, darf/dürfen, mag/mögen and weiß/wissen all alternate; soll/sollen does not, and the reference literature singles it out: "Sollen wiederum hat als einziges Präteritopräsentium im heutigen Deutsch keinen Vokalwechsel." The history is the pleasing part and is what makes this a nitpick rather than nothing. Sollen once alternated like the rest, Old High German scal against sculun, Middle High German sol against suln, and the alternation was levelled out only later; so the essay is describing a pattern sollen used to have and has lost, and the exception is itself a small monument to the leveling the whole section is about. I am grading this nitpick rather than a factual error deliberately. The parenthesis quantifies nothing and offers a single example, so no careful reader is actively misled, and the cost of the sentence as written is a learner who wonders why sollen does not do what its neighbours do. Four words fix it. Separately, the brief asks whether the reader can connect the alternation to its cause, and here the connection is thinner than at F15: this vowel difference is the old ablaut of the strong preterite singular against its plural, which the essay's own ablaut section prepared the reader for, but nothing here says the word ablaut. That is a missed opportunity rather than a defect, and I am not proposing prose for it.

**What is actually true.** Five of the six preterite-presents surviving in modern German show a singular/plural vowel alternation in the present indicative: kann/können, muss/müssen, darf/dürfen, mag/mögen, weiß/wissen. Sollen is the sole exception, ich soll against wir sollen, having levelled the alternation it once had as Old High German scal against sculun and Middle High German sol against suln.

**Replacement, English.**

> and vowel differences between singular and plural in all of them but ~sollen~ (ich $kAnN$ vs. wir können)

**German counterpart**, `docs/verb_history_de.txt` line 137:

> und Vokalunterschiede zwischen Singular und Plural (ich $kAnN$ vs. wir können)

**Assumes.** Depends on F15, which I own and confirm.

**Sources.**

- German Wikipedia, "Präteritopräsens" <https://de.wikipedia.org/wiki/Pr%C3%A4teritopr%C3%A4sens>
  > Lists "Vokalwechsel von Singular zu Plural im Präsens Indikativ" among the class's features, and then states the exception outright: "Sollen wiederum hat als einziges Präteritopräsentium im heutigen Deutsch keinen Vokalwechsel."
- Wikipedia, "Germanic verb", preterite-presents <https://en.wikipedia.org/wiki/Germanic_verb>
  > The present tense of a preterite-present has the form of a vocalic (strong) preterite, with vowel alternation between singular and plural, the present singular typically showing o-grade radical vocalism to match the strong preterite singular.
- Middle High German reference material on the Präterito-Präsentia <https://mhd.sawogra.de/tptpraes.php>
  > Gives the Middle High German paradigms in which suln (sollen) alternates sol in the singular against suln in the plural, an alternation modern sollen no longer has.

### Cluster G: Modern German

#### G8 · line 180 · **factual-error** · confidence high

> ~Aspect~ is expressed periphrastically (er $lIest$ = he reads/is reading)

**Why.** The example demonstrates the opposite of what the sentence claims. Er liest is a single synthetic present-tense form, and the reason it covers both 'he reads' and 'he is reading' is that Standard German does not grammatically mark the perfective/imperfective or progressive distinction at all. That is an absence of aspect marking, not a periphrasis: there is no auxiliary, no participle, no second word. A reader is misinformed twice over, first about what periphrasis means, since the parenthesis contains none, and second about German, since the sentence implies German has a grammaticalized aspect device when the standard description is that it has none and leaves the reading to context. German does have periphrastic progressives worth naming, and the essay names none of them: the am-progressive (er ist am Lesen), the parallel beim- and zum-constructions, and dabei sein zu. The IDS grammar treats these as the German answer to the progressive while noting they are not yet a grammaticalized verbal aspect, and Duden has accepted the am-form since 1998 while still marking it colloquial and originally regional. Naming the am-progressive both repairs the sentence and adds the fact the bullet was reaching for.

**What is actually true.** Standard German marks no aspect on the verb. Er liest is aspectually neutral and its habitual or progressive reading comes from context, which is the absence of aspect marking rather than a periphrastic expression of it. Where a speaker needs the progressive explicitly, German supplies it with the am-progressive, er ist am Lesen, still colloquial and strongest in the Rhineland and Westphalia though accepted by Duden since 1998, or with beim + infinitive and dabei sein zu. Whether these are grammaticalizing into a true verbal aspect is, in the IDS's words, still open.

**Replacement, English.**

> 🇩🇪 ~Aspect~ is carried by context (er $lIest$ = he reads/is reading), by the colloquial ~am~-progressive (er ist am Lesen = he is reading), or by verbal prefixes and particles (er $lIest$ das Buch aus = he finishes reading the book)

**German counterpart**, `docs/verb_history_de.txt` line 146:

> 🇩🇪 ~Aspekt~ wird periphrastisch ausgedrückt (er $lIest$ = he reads/is reading) oder durch verbale Präfixe und Partikeln (er $lIest$ das Buch aus = he finishes reading the book)

**Sources.**

- grammis (IDS Mannheim), Fragen zur Grammatik, 'Darf man Ich bin am Schreiben schreiben? Bereichert die Verlaufsform (der Progressiv) das Deutsche?' <https://grammis.ids-mannheim.de/fragen/4551>
  > German has no fully grammaticalized progressive of the English or Russian kind and instead uses nominal constructions with a preposition plus infinitive: am + Infinitiv (Paula ist am Singen), beim + Infinitiv, zum + Infinitiv, or simply the present tense with an adverbial (Paula singt gerade). Of the am-construction it says 'Ob die Konstruktion sich grammatisch zu einem Verbalaspekt entwickelt, ist noch offen', and it records that the Duden dictionary and its editors have had no problem with the form since 1998 while it remains marked as colloquial or regional in formal contexts
- WALS Online, chapter on tense and aspect (Dahl and Velupillai, on grammatical marking of perfective/imperfective aspect) <https://wals.info/chapter/s7>
  > In languages that do not mark the imperfective/perfective distinction, temporal and aspectual interpretation falls to the lexical class of the verb and to context; German is used as the illustration of a language whose forms are read this way rather than by grammatical aspect marking
- Duden-Redaktion (Annette Klosa), 'Zur Verlaufsform im Deutschen', and the Duden Grammatik's treatment of the am-Progressiv <https://ids-pub.bsz-bw.de/frontdoor/deliver/index/docId/3861/file/Klosa_Zur_Verlaufsform_im_Deutschen_1999.pdf>
  > The am-progressive is the product of a comparatively recent grammaticalization, is used chiefly with activity verbs without complements, is commoner in speech than in written standard German, and is now partly reckoned standard, having earlier been classed as regional (chiefly Rhineland and Westphalia)

#### G14 · line 187 · **nitpick** · confidence high

> that primordial cloud of supernova-enriched gas from which the Solar System was born

**Why.** The research behind this one is already done and settled, so I spent no searches on it. Conjugar's cluster A raised the same epithet, the skeptic pass upheld it as a nitpick, and Phase 0 applied the fix at line 82, where 'supernova-gifted elements' became 'star-forged elements'. The reason is stated at the patched line 80: generations of dying stars seeded the cloud, some shedding quietly on the winds of aging giants, the rest blasting outward in supernovae, with the heaviest elements coming from neutron-star collisions. Crowning the supernovae alone is what the patch removed. This closing occurrence survived only because it sits in the German-specific half, which Phase 0 was not permitted to edit, so the essay now describes the same cloud two ways two hundred words apart. The replacement echoes the patched line 80's own verb, seeded, so the opening and the closing say the same thing.

**What is actually true.** The presolar cloud was enriched by several stellar processes, not one. Supernovae contributed, but so did the slow winds of aging giant stars, and the heaviest elements came from neutron-star mergers, which is what the patched account at line 80 now says and what line 82's 'star-forged elements' now reflects.

**Replacement, English.**

> that primordial cloud of star-seeded gas from which the Solar System was born

**German counterpart**, `docs/verb_history_de.txt` line 153:

> bis hin zu jener Urwolke aus supernova-angereichertem Gas, aus der das Sonnensystem geboren wurde

**Sources.**

- docs/verb_history_phase0.md, patch P3 and the 'Notes for the fan-out and for agent H' section
  > P3 broadened 'supernova-gifted elements' to 'star-forged elements' at line 82 on Conjugar's nitpick, and the note records that 'One downstream echo of P3 survives in the German half. The closing paragraph at line 187 still says "that primordial cloud of supernova-enriched gas" ... The two now disagree. Inventory row G14.'
- docs/verb_history.txt line 80 (patched)
  > 'Generations of dying stars had seeded the cloud with heavy elements forged in stellar furnaces, some shed quietly on the winds of aging giants, the rest blasted outward by supernovae', with the heaviest elements attributed to the collision of two neutron stars

#### G4 · line 174 · **nitpick** · confidence high

> 🇩🇪 Old: Wenn ich $kÄme$... (If I $cAme$...)

**Why.** The German is correct and the gloss is right; the defect is the label. 'Old', set against 'Modern alternative' on the next line, tells a learner that käme belongs to an earlier stage of the language and that the würde form has succeeded it. Neither is true. Duden's list of synthetic Konjunktiv-II forms that remain in ordinary use names käme explicitly, alongside bliebe, brächte, gäbe, ginge, hätte, könnte, wäre and wüsste, and the forms Duden does mark as archaic and fit for replacement are hülfe and gälte/gölte, not käme. The IDS grammar makes the same point structurally: where mood must be marked, speakers use either a distinct Konjunktiv-Präteritum form or the würde-form, and käme is precisely a distinct form. The essay contradicts itself three lines later at line 177, which exempts 'common verbs' from the würde takeover; kommen is among the most common verbs in German, so the essay's own rule protects the form its example has just labelled old. Graded a nitpick rather than a factual error because the surrounding prose partly repairs the impression: the alternative is called an alternative, not a replacement. The fix is one word and it removes the contradiction as well as the mislabel.

**What is actually true.** Käme is current written and formal German, not an archaism. It is one of the high-frequency strong-verb Konjunktiv-II forms whose synthetic shape survives, and it is the form Duden and the IDS grammar treat as preferred where a subjunctive has to be visible. What the two lines actually contrast is a synthetic form and a periphrastic one, both live in contemporary German and differing in register rather than in date.

**Replacement, English.**

> 🇩🇪 Synthetic: Wenn ich $kÄme$... (If I $cAme$...)

**German counterpart**, `docs/verb_history_de.txt` line 140:

> 🇩🇪 Alt: Wenn ich $kÄme$... (If I $cAme$...)

**Sources.**

- Duden, Sprachratgeber, 'Konjunktiv II oder „würde“-Form?' <https://www.duden.de/sprachwissen/sprachratgeber/Konjunktiv-2-oder-w%C3%BCrde-Form>
  > Among strong verbs the Konjunktiv-II form is very common for bliebe, brächte, gäbe, ginge, hätte, käme, könnte, wäre, würde and wüsste; the würde-construction may be used in place of Konjunktiv-II forms that seem old-fashioned, the examples given being hülfe (würde helfen) and gälte/gölte (würde gelten)
- grammis (IDS Mannheim), Systematische Grammatik, 'Formensynkretismus von Konjunktiv und Indikativ' <https://grammis.ids-mannheim.de/systematische-grammatik/315>
  > In text types with obligatory mood marking speakers 'stets auf distinkte Konjunktiv-Präteritum-Formen oder die würde-Form ausweichen', i.e. a distinct synthetic form such as käme is one of the two live options rather than a superseded one
- docs/verb_history.txt line 177 (the essay's own next paragraph)
  > 'the $wÜrde$ construction increasingly replaces synthetic subjunctive conjugations except for common verbs and in formal registers', which exempts kommen from the replacement the label at line 174 asserts

## Confirmed rows

The audit trail, and Phase 2's other job: a skeptic should challenge any row here whose
reasoning looks thin, without opening fresh research on rows the researcher settled.

### Cluster A: Into Europe

**A1 · line 126** · confidence high

> Beginning around 3000 BC … the Yamnaya and their descendants began a series of migrations

The date the essay uses is the date the primary literature itself uses when it describes this event in one phrase. Librado et al. 2021 write of "the massive expansion of Yamnaya steppe pastoralists into Europe around 3000 bc" and, in the body, of "a massive expansion from the Western Eurasia steppes into Central and Eastern Europe during the third millennium bc, associated with the Yamnaya culture". Haak et al. 2015 date the arrival of that ancestry in central Europe to roughly 4,500 years ago via the Corded Ware, which is the downstream end of the same process, so 3000 BC as the beginning and 2500 BC as the central-European arrival are consistent rather than competing. The essay also hedges with "around" and with "a series of migrations" rather than one event, which is the shape the archaeology actually has: an expansion running roughly 3200 to 2600 BC across 5,000 km. I considered whether "beginning around 3000 BC" sits awkwardly inside the patched horizon at line 86, which runs 3300 to 2500 BC, and it does not: the migrations start midway through the horizon, which is what the sources describe.

*Assumes.* Depends on S1 (line 86), owned by the settled patch. I assume S1's Yamnaya horizon of approximately 3300 to 2500 BC stands. If that window were later revised, "beginning around 3000 BC" would need to move with it, since a migration cannot begin before the culture it is attributed to.

- Librado, P. et al. (2021). The origins and spread of domestic horses from the Western Eurasian steppes. Nature 598:634-640, abstract and main text. <https://pmc.ncbi.nlm.nih.gov/articles/PMC8550961/>
  > Abstract: "Our results reject the commonly held association between horseback riding and the massive expansion of Yamnaya steppe pastoralists into Europe around 3000 bc, driving the spread of Indo-European languages." Main text: "analyses of ancient human genomes have revealed a massive expansion from the Western Eurasia steppes into Central and Eastern Europe during the third millennium bc, associated with the Yamnaya culture." The paper thus takes ~3000 BC as the received date of the westward expansion, disputing only the horse's role in it.
- Haak, W. et al. (2015). Massive migration from the steppe was a source for Indo-European languages in Europe. Nature 522:207-211; Max Planck Society summary. <https://www.mpg.de/9005184/humans-migration-indo-european-languages>
  > Late Neolithic Corded Ware individuals from Germany, dating to about 4,500 years ago, trace roughly 75 percent of their ancestry to Yamnaya-like steppe populations, which the authors read as documenting a large-scale movement into the heart of Europe from its eastern periphery.

**A2 · line 126** · confidence high

> (approximately 5,000 years ago)

Arithmetic. 3000 BC is 5,026 years before 2026, so "approximately 5,000 years ago" is exact to within the rounding the word "approximately" licenses. The gloss also matches the way the ancient-DNA literature routinely states the same date in years-ago form. The essay uses the same 5,000-year figure twice more, at line 185 and by implication at line 187, so the gloss is internally consistent as well; those are cluster G's rows G13 and G16 and I have not researched them.

*Assumes.* Depends on A1, which I also own and have confirmed. The gloss is a conversion of A1's date and inherits A1's verdict.

- Arithmetic against the essay's own date, cross-checked against the years-ago phrasing used in the steppe-migration literature. <https://www.mpg.de/9005184/humans-migration-indo-european-languages>
  > The Max Planck summary of Haak et al. 2015 states the central-European arrival of steppe ancestry as "about 4,500 years ago", i.e. the literature routinely converts these third-millennium BC dates into round years-ago figures of the same magnitude the essay uses.

**A3 · line 126** · confidence high

> would reshape the genetic and linguistic landscape of Europe

This is the Haak and Allentoft result stated in ordinary words, and it is stated at exactly the altitude the ancient DNA supports. Haak's Corded Ware sample derives roughly three quarters of its ancestry from a Yamnaya-like source, which is a reshaping of the genetic landscape by any reading. The live argument in the field is about mechanism and degree, not about whether the landscape changed: critics of the 2015 framing object that treating Yamnaya as one unified genetic element produced an over-clean one-way replacement story, and argue for smaller-scale, longer, multi-directional mobility. None of that touches "reshape", which is agnostic between replacement and admixture. I specifically considered whether "reshape" overclaims population turnover and concluded it does not, because the essay never says replaced, never gives a percentage, and the following sentence at line 128 already offers "settled among or displaced" as alternatives. The linguistic half is the steppe hypothesis, which is the majority position; even the leading rival, the Heggarty 2023 hybrid model, routes the European branches through the steppe and so preserves this sentence.

- Haak, W. et al. (2015). Massive migration from the steppe was a source for Indo-European languages in Europe. Nature 522:207-211; Max Planck Society summary. <https://www.mpg.de/9005184/humans-migration-indo-european-languages>
  > Corded Ware individuals from Germany carry approximately 75 percent Yamnaya-derived ancestry; under a three-way model the estimate is 79 percent Yamnaya-like, 17 percent Early Neolithic and 4 percent western hunter-gatherer. The Corded Ware are the first group in the European sequence to show this eastern ancestry and they show the most of it, indicating a major genetic turnover at that time.
- Librado, P. et al. (2021). Nature 598:634-640, main text. <https://pmc.ncbi.nlm.nih.gov/articles/PMC8550961/>
  > Restates the human-genomic result as settled background: "analyses of ancient human genomes have revealed a massive expansion from the Western Eurasia steppes into Central and Eastern Europe during the third millennium bc, associated with the Yamnaya culture." A paper whose whole purpose is to overturn the horse half of the story leaves the genetic-transformation half standing.
- Heggarty, P. et al. (2023). Language trees with sampled ancestors support a hybrid model for the origin of Indo-European languages. Science 381:eabg0818. <https://www.science.org/doi/10.1126/science.abg0818>
  > Proposes a hybrid origin with a deep root south of the Caucasus, dating the first Anatolian/non-Anatolian split to 4740-7610 BC (median 6120 BC) and the [Balto-Slavic,[Italic,[Celtic,Germanic]]] break-up to 3040-5940 BC (median 4470 BC). The model still carries the European branches, Germanic among them, into Europe by a steppe route, so the essay's clause survives even under the chief rival to the pure steppe hypothesis.

**A5 · line 128** · confidence medium

> The branch that would become Germanic likely separated from other Indo-European groups sometime between 2500 and 2000 BC

This is the row where a fact-checker most wants to be clever, and the field will not support cleverness. No handbook fixes a date for the separation of the Germanic branch, and the published estimates disagree by thousands of years depending on method. Iversen and Kroonen put the Indo-European dialect ancestral to Proto-Germanic in southern Scandinavia with the Single Grave culture, whose overlap with the Funnel Beaker culture they date to the first quarter of the third millennium BC, which is earlier than the essay's window. Heggarty et al. 2023, by Bayesian phylogenetics, put the node uniting Germanic with Celtic and Italic at a median of 4470 BC, far earlier still. Anthony works the other way: for him the Corded Ware horizon, roughly 2900 to 2350 BC, is the medium through which pre-Germanic dialects spread, which places the differentiation of pre-Germanic proper in the later third millennium, squarely inside the essay's window. Ringe, who is the closest thing to an authority here, declines to date the split at all and dates only the proto-language. Against that spread, a claim carrying three hedges at once, "likely", "sometime between", and a five-hundred-year window, is doing exactly the work hedges are for. Narrowing it, or moving it to satisfy any one of the three positions above, would replace a defensible statement with a confident mistake. The one thing I would flag for Josh rather than correct is that the window is tied to the movement into southern Scandinavia in the same sentence, and the best-attested such movement, the Single Grave arrival in Jutland, is a century or three earlier than 2500 BC.

- Iversen, R. and Kroonen, G. (2017). Talking Neolithic: Linguistic and Archaeological Perspectives on How Indo-European Was Implemented in Southern Scandinavia. American Journal of Archaeology 121(4):511-525. <https://ajaonline.org/article/3545/>
  > The Single Grave culture, part of the Corded Ware horizon, superseded the Funnel Beaker culture and is a likely vector for the introduction of Indo-European speech into southern Scandinavia. The dialect that ultimately developed into Proto-Germanic can be shown to have taken over non-Indo-European vocabulary for local flora, fauna and plant domesticates, and the coexistence of the two cultures in the first quarter of the third millennium BC supplies the setting for that exchange. This places pre-Germanic speech in southern Scandinavia earlier than the essay's window.
- Heggarty, P. et al. (2023). Science 381:eabg0818. <https://www.science.org/doi/10.1126/science.abg0818>
  > Dates the break-up of the clade [Balto-Slavic,[Italic,[Celtic,Germanic]]] to 3040-5940 BC at 95 percent probability, median 4470 BC, on a root age of roughly 6100 BC. Bayesian phylogenetic estimates for the Germanic node are therefore far older than the essay's window and far older than the archaeological scenarios, which is the measure of how unsettled this dating is.
- Anthony, D. W. (2007). The Horse, the Wheel, and Language. Princeton University Press. <https://press.princeton.edu/books/paperback/9780691148182/the-horse-the-wheel-and-language>
  > Treats the Corded Ware horizon, which ran from about 2900 to 2350 BC and stretched from Ukraine to the Netherlands, as the medium through which pre-Germanic dialects spread over a wide area. Under this model the pre-Germanic dialect differentiates within a Corded Ware continuum in the later third millennium, which falls inside the essay's window.
- Ringe, D., writing on the emergence of Germanic (Language Log, summarizing the position of From Proto-Indo-European to Proto-Germanic). <https://languagelog.ldc.upenn.edu/nll/?p=41979>
  > Dates the proto-language rather than the split: "PGmc. was *one* of the dialects spoken in the Jastorf area, probably not before ca. 500 BCE, possibly a bit later." He offers no date for when the branch separated, which is the point: the standard reference treatment leaves this question open.

**A6 · line 128** · confidence high

> as speakers moved into southern Scandinavia and northern Germany

The location is the least contested thing in this section. Ringe reports a consensus placing Proto-Germanic in the Jastorf culture and its successors in southern Denmark and northern Germany, and Iversen and Kroonen route the ancestral dialect into southern Scandinavia with the Single Grave culture. Both halves of the essay's phrase, southern Scandinavia and northern Germany, are named in the literature as the zone in question, and no serious rival homeland is on offer. The clause's exposure is chronological rather than geographic: it welds the movement to A5's window, and the best-attested movement into southern Scandinavia is somewhat earlier than 2500 BC. I judged that under A5 rather than here, since A6 as written asserts only where, not when.

*Assumes.* Depends on A5, which I own and have confirmed. I assume the 2500 to 2000 BC window stands as a hedged statement. If A5 were moved earlier to match the Single Grave arrival, this clause would move with it unchanged, since the geography is the same under every scenario.

- Ringe, D., on the emergence of Germanic (Language Log). <https://languagelog.ldc.upenn.edu/nll/?p=41979>
  > "There's a consensus that PGmc. belongs in the Jastorf culture and its successors in southern Denmark and northern Germany." He adds the caution that most tribes the Romans identified as Germans spoke not reconstructed Proto-Germanic but closely related sister dialects that left no descendants.
- Iversen, R. and Kroonen, G. (2017). American Journal of Archaeology 121(4):511-525. <https://ajaonline.org/article/3545/>
  > Frames the whole problem as how Indo-European was implemented in southern Scandinavia, with the Single Grave culture as the vector and the local Funnel Beaker population as the source of the non-Indo-European substrate vocabulary in the dialect that became Proto-Germanic.

**A8 · line 130** · confidence high

> in southern Scandinavia and along the North Sea and Baltic coasts

This is the standard homeland description, and it is stated at a width the sources support. Ringe's consensus formulation is narrower, the Jastorf culture and its successors in southern Denmark and northern Germany, and the essay's "along the North Sea and Baltic coasts" is a fair reader-facing rendering of the same North German and Jutish zone, since Jastorf territory reaches both seas. The wider handbook framing, the Nordic Bronze Age of southern Scandinavia together with the north German plain, is exactly what the essay says. I considered whether "southern Scandinavia" overreaches by pulling in southern Sweden and Norway, and concluded it does not: the Nordic Bronze Age scenario includes them, and Ringe's own caution is that Proto-Germanic was one dialect among sisters spread across this area rather than that the area was too large.

*Assumes.* Depends on A6, which I own and have confirmed. A8 restates A6's geography for the proto-language rather than for the migrating speakers, so the two stand or fall together.

- Ringe, D., on the emergence of Germanic (Language Log). <https://languagelog.ldc.upenn.edu/nll/?p=41979>
  > "There's a consensus that PGmc. belongs in the Jastorf culture and its successors in southern Denmark and northern Germany." He notes contact evidence on both flanks, Celtic loans into pre-Proto-Germanic and shared items with Balto-Slavic, which situates the speech area between the two.
- Standard handbook localization of Proto-Germanic. <https://en.wikipedia.org/wiki/Proto-Germanic_language>
  > Places Proto-Germanic in the region around the North Sea and southern Scandinavia in the last centuries BC, which is the essay's description in the essay's own words.

**A9 · line 130** · confidence high

> known to the Romans as ~Germani~

The claim is worded in precisely the form the scholarship licenses, and the trap the brief points at is one the essay has already avoided. What is contested is whether any of these peoples used the name of themselves. Tacitus reports at Germania 2 that the name belonged first to a single group, the people now called Tungri, and only gradually came into general use; the etymology is disputed between Celtic, Germanic, Latin and Illyrian derivations, with Pfeifer favouring a Celtic source; and it is unclear that any group ever applied the name to itself. None of that touches the essay, which says only that the Romans knew them by it, attributes the label to the Romans rather than to the peoples, and puts it in the emphasis marker as a foreign term rather than as an autonym. Note that this restraint is the same point the essay makes at length in the settled paragraph at line 92, where it says outright that we do not know what these people called themselves.

- Tacitus, Germania 2 (English translation). <https://www.philipharland.com/Blog/2022/07/germans-tacitus-germania-in-full-late-first-century-ce/>
  > The first people to cross the Rhine and drive out the Gauls are now called Tungri but were then called Germani; the name of one tribe, not of a nation, gradually came into general use, applied first by the victors to intimidate the Gauls and afterwards adopted more widely. Tacitus thus records the name as an externally applied and then generalized label.
- Scholarship on the etymology and application of Latin Germani, including Pfeifer's Celtic derivation. <https://en.wikipedia.org/wiki/Germanic_peoples>
  > The etymology of Latin Germani is unknown and even the source language is disputed, with Germanic, Celtic, Latin and Illyrian proposals in circulation; Pfeifer favours a Celtic origin related to Old Irish gair, neighbours, or gairm, war cry. It is unclear whether any group ever called itself Germani; the peoples in question identified by tribal names such as Cherusci, Marcomanni and Suebi.

### Cluster B: Teutoburg

**B1 · line 131** · confidence high

> In 9 AD

Uncontested in every source consulted. No ancient or modern account places the Varus disaster in any other year, and the September dating is standard. The essay gives only the year, which is the least exposed form the claim could take. Nothing to correct.

- Jona Lendering, "Teutoburg Forest (7)", Livius.org, last modified 11 October 2020 <https://www.livius.org/articles/battle/teutoburg-forest-9-ce/teutoburg-forest-7/>
  > Heads the article: "Battle in the Teutoburg Forest (Latin Saltus Teutoburgiensis): the defeat of the Roman commander Publius Quintilius Varus against the Germanic tribesmen of the Cheruscian leader Arminius in 9 CE. In this battle, three legions (XVII, XVIII, XIX) were annihilated."
- Wikipedia, "Battle of the Teutoburg Forest" <https://en.wikipedia.org/wiki/Battle_of_the_Teutoburg_Forest>
  > Dates the engagement to 8-11 September 9 CE, with the infobox narrowing the main fighting to 8-9 September.
- Livius.org, "Kalkriese" <https://www.livius.org/articles/battle/teutoburg-forest-9-ce/kalkriese/>
  > "In September 9 CE, the Romans suffered one of the greatest defeats in their history in the Teutoburg Forest. Three legions (the Seventeenth, Eighteenth, and Nineteenth) were destroyed; general Publius Quintilius Varus was forced to commit suicide."

**B2 · line 131** · confidence high

> in the densely forested hills of what is now northwestern Germany

I went in expecting the Kalkriese Gap to break this and it does not. Two things separate the claim from the objection. First, the sentence locates the battle rather than describing the battlefield, and every candidate site is in northwestern Germany: Kalkriese sits in Lower Saxony just north of Osnabrueck, and the Teutoburger Wald proper runs southwest of it through Detmold. Second, the terrain word survives even at Kalkriese. The corridor is bounded on its south side by the Wiehengebirge, which the excavators describe as a wooded ridge falling steeply toward the narrows, and palaeoenvironmental work at the site reconstructs a heavily forested landscape two thousand years ago. What the essay omits is the Grosses Moor on the north side, and the narrowness that makes the position a trap. Omitting the bog is not an assertion about it, and no reader is left believing something false about where the battle happened or what the country looked like. Cassius Dio's own account, which is the ancient warrant for the phrase, describes mountains with ravines and trees growing close together and very high. Confirmed, and I would not want this one downgraded into a correction that trades a true general description for a contested site identification the essay never makes.

- "Uncovering Kalkriese", Current World Archaeology <https://www.world-archaeology.com/world/europe/germany/uncovering-kalkriese/>
  > "Since its discovery by the British officer Tony Clunn in the late 1980s, the German site of Kalkriese in Lower Saxony, north of Osnabrück, has been considered the scene of the AD 9 Varus Disaster." Describes pollen analysis, dendrochronology and soil studies reconstructing the ancient landscape as heavily forested with significant marshland.
- Livius.org, "Kalkriese" <https://www.livius.org/articles/battle/teutoburg-forest-9-ce/kalkriese/>
  > The Germanic force raised a rampart "at a narrow point between the hilly Wiehengebirge and the marshes of the Großes Moor"; the corridor is roughly 220 metres wide at its narrowest, with the Great Bog to the north and the wooded Wiehen ridge falling steeply to the south. Notes the nearby place name Engter, meaning "narrows".

**B3 · line 131** · confidence high

> Three Roman legions

XVII, XVIII and XIX, destroyed and never reconstituted; the three numbers were never reused, which is the strongest single piece of evidence that the annihilation was total. The essay declines to name them, which the inventory already records as a coverage fact rather than a defect.

- Jona Lendering, "Teutoburg Forest (7)", Livius.org <https://www.livius.org/articles/battle/teutoburg-forest-9-ce/teutoburg-forest-7/>
  > "In this battle, three legions (XVII, XVIII, XIX) were annihilated."
- Wikipedia, "Battle of the Teutoburg Forest" <https://en.wikipedia.org/wiki/Battle_of_the_Teutoburg_Forest>
  > Roman order of battle given as three legions, XVII, XVIII and XIX, at roughly 15,000 men, with nine auxiliary units of about 4,500 and three cavalry squadrons.

**B4 · line 131** · confidence high

> under the command of Publius Quinctilius Varus

Correct name and correct command. Worth recording that the essay uses the better of the two circulating spellings: Quinctilius, from the gens Quinctilia, is the form used by Wikipedia and by most modern scholarship, while Livius and some older works print Quintilius. Varus was legate of Germania and took his own life during the battle.

- Wikipedia, "Battle of the Teutoburg Forest" <https://en.wikipedia.org/wiki/Battle_of_the_Teutoburg_Forest>
  > Names the Roman commander as Publius Quinctilius Varus throughout.
- Livius.org, "Kalkriese" <https://www.livius.org/articles/battle/teutoburg-forest-9-ce/kalkriese/>
  > "general Publius Quintilius Varus was forced to commit suicide", using the variant spelling with -t-.

**B5 · line 131** · confidence high

> (perhaps 20,000 soldiers)

The brief asked whether 20,000 is the figure for the legions alone or for the whole column. It is the whole column, and the essay's syntax gets that right by accident or by care. The parenthesis follows "Varus", not "legions", so it glosses the force under his command rather than the three legions by themselves, and reference works give roughly 20,000 for exactly that: three legions at about 15,000 plus six to nine auxiliary cohorts and three cavalry alae. The essay also writes "soldiers" rather than "men", which correctly leaves out the several thousand servants, wives and children that some accounts fold into a larger total. Estimates do spread, from about 15,000 up to 30,000, and a few low reconstructions go under 15,000; the word "perhaps" is carrying that spread and carrying it honestly. If the parenthesis had been placed immediately after "legions" I would have called this a nitpick, since three legions alone are about 15,000. It is not placed there.

*Assumes.* Assumes B3 is confirmed as written, that is, that the force consisted of three legions. If B3's owner had found a different legion count the 20,000 gloss would have to be re-derived; B3 is mine and I have confirmed it.

- Wikipedia, "Battle of the Teutoburg Forest" <https://en.wikipedia.org/wiki/Battle_of_the_Teutoburg_Forest>
  > Gives three legions at about 15,000 men, nine auxiliary units at about 4,500, and three cavalry squadrons, with total estimates of "20,000 to 30,000" and Michael McNally's figure of "about 21,000 at the start of campaigning".
- World History Edu, "Battle of the Teutoburg Forest in 9 AD" <https://worldhistoryedu.com/battle-of-teutoburg-forest-in-9-ad/>
  > "Varus' army consisted of three Roman Legions (XVII, XVIII and XIX) and several thousand auxiliaries, a total of roughly 20,000 men", and separately notes about 12,000 legionaries, three auxiliary alae and six auxiliary cohorts of about 4,000, plus "several thousand servants" and the soldiers' unofficial wives and children.

**B6 · line 131** · confidence high

> were ambushed and annihilated

It compresses, and the compression is the one the handbooks themselves use. Wikipedia's narrative opens "Fighting began with an ambush", which is precisely the essay's claim: the ambush is how the engagement started, not a claim about how long it lasted. Lendering, who devotes two separate chapters to days one and two and days three and four, still calls the force "the ambushed army" and speaks of "the Kalkriese ambush", and heads his article with the statement that the three legions "were annihilated". So both of the essay's verbs are the sources' own verbs. The essay asserts nothing about duration, which is the safer choice and one this run has prior reason to prefer: Conjugar's adversarial pass refuted a proposed replacement precisely because it compressed the three-to-four-day battle into "one afternoon". A reader of this sentence learns that a marching column was surprised and destroyed. That is what happened. I considered proposing "ambushed and destroyed over four days" and rejected it: it lengthens the sentence, it asserts a duration the sources give as three or four rather than four, and it corrects nothing.

- Wikipedia, "Battle of the Teutoburg Forest" <https://en.wikipedia.org/wiki/Battle_of_the_Teutoburg_Forest>
  > "Fighting began with an ambush by the Germanic alliance on three Roman legions"; the engagement is dated 8-11 September 9 CE, that is a running battle of several days.
- Jona Lendering, "Teutoburg Forest (7)", Livius.org <https://www.livius.org/articles/battle/teutoburg-forest-9-ce/teutoburg-forest-7/>
  > Chapters the battle as "Battle: day 1 and 2" and "Battle: day 3 and 4", yet writes of "the ambushed army" and "survivors of the Kalkriese ambush", and states that in the battle "three legions (XVII, XVIII, XIX) were annihilated".

**B8 · line 131** · confidence high

> a Romanized chieftain of the Cherusci

Every word carries. He was born a prince of the Cherusci, son of the pro-Roman chief Segimerus, and led the tribe at the time of the battle. "Romanized" is not loose praise: he learned Latin, served in the Roman army from AD 1 to 6, took a Roman military education, and held Roman citizenship and equestrian rank, which is a formal Roman status and not a courtesy. The one thing a pedant could press is that in AD 9 he was a nobleman and war leader rather than a sole tribal ruler, but chieftain covers that in ordinary English and the reference works use the same word.

- Wikipedia, "Arminius", infobox and early-life section <https://en.wikipedia.org/wiki/Arminius>
  > Titled "Prince and chieftain of the Cherusci tribe"; born 18/17 BC, "the son of the Cheruscan chief Segimerus"; "Arminius learned to speak Latin and joined the Roman military with his younger brother Flavus. He served in the Roman army between AD 1 and 6, and received a military education, as well as Roman citizenship and the status of equite before returning to Germania."
- Jona Lendering, "Teutoburg Forest (7)", Livius.org <https://www.livius.org/articles/battle/teutoburg-forest-9-ce/teutoburg-forest-7/>
  > Calls him "the Cheruscian leader Arminius", and records that after the battle "Arminius created a new tribal coalition" over the winter.

**B9 · line 133** · confidence high

> halted Roman expansion into Germanic territory

This is the row I spent the most on and it does not break. The objection is real in outline: Roman armies fought east of the Rhine for seven more years after the battle. Tiberius campaigned in 9, 10 and 11 and triumphed in 12; Germanicus invaded in 14, 15 and 16, recovered two of the lost eagles, beat Arminius at Idistaviso with eight legions, and reconquered the Lippe valley and the North Sea coast. The frontier settled on the Rhine because Tiberius then chose to evacuate what Germanicus had retaken and recall him, and Lendering notes that Tiberius had already taken a similar decision in 8 BC, before the battle existed to cause anything. So the proximate mechanism is a policy decision of AD 16, not a defeat of AD 9. What keeps this from being a finding is three things, and each of them would have to be argued away by anyone proposing one. First, the essay's very next sentence concedes the continued campaigning, in the words "While the Romans would launch punitive expeditions", so no reader is left thinking Rome went home in 9 AD. Second, "halted" is the reference works' own verb: Wikipedia says the battle "dissuaded the Romans from pursuing the conquest of Germania", and Lendering, who explicitly warns that the battle's importance can be overstated, still writes that "the Roman Empire had met its limits". Third, the same objection in a stronger form was already put to an adversarial pass in the sibling run and refuted there, with Germanicus's campaigns named. The most I would concede is that Lendering's formulation, that the fighting was "not the cause of this rift" but "a precondition", is more exact than the essay's, and a reader wanting to be careful about causation would prefer it. That is a difference of philosophical grain, not a difference a general reader is misinformed by.

- Jona Lendering, "Teutoburg Forest (7)", Livius.org, sections "Tiberius", "Germanicus" and "Assessment" <https://www.livius.org/articles/battle/teutoburg-forest-9-ce/teutoburg-forest-7/>
  > "After three campaigns (in 9, 10 and 11), Tiberius thought that the Germanic tribes had been punished sufficiently, and he celebrated a triumph in 12. He also decided not to try to occupy the country east of the Rhine anymore. This was not surprising: he had already taken a similar decision in 8 BCE." On AD 16: "It was up to the emperor Tiberius to decide what to do next … He chose the latter: the Lippe valley was evacuated by the Romans … Arminius was murdered, Germanicus recalled." In assessment: "It is possible to overstate the importance of the battle in the Teutoburg Forest… Yet, the battle was important. The Roman Empire had met its limits." And on the linguistic consequence: "the fights were not the cause of this rift; they were a precondition."
- Wikipedia, "Battle of the Teutoburg Forest", aftermath and legacy <https://en.wikipedia.org/wiki/Battle_of_the_Teutoburg_Forest>
  > The battle "dissuaded the Romans from pursuing the conquest of Germania" and "the Rhine became the border between the Roman Empire and the rest of Germania"; Germanicus's retaliatory campaigns of 14-16 CE had initial success but he was recalled by Tiberius, who "ordered the Roman forces to halt and withdraw across the Rhine".
- Wikipedia, "Arminius", aftermath section <https://en.wikipedia.org/wiki/Arminius>
  > "Between 14-16 AD, Germanicus led punitive operations into Germany", fighting Arminius to a draw at the pontes longi and defeating him twice, at Idistaviso and the Angrivarian Wall; "Tiberius denied the request of Germanicus to launch an additional campaign for 17, but decided the frontier with Germania would stand at the Rhine River." The phrase "punitive operations" is the reference work's own characterization of the campaigns the essay calls punitive expeditions.

**B10 · line 133** · confidence high

> eventually establish the ~limes~ (a fortified frontier)

Accurate on both halves. "Eventually" is right: the Limes Germanicus dates from about 83 AD under Domitian, three-quarters of a century after the battle, and the Upper German-Raetian stretch was built out through the second century. "A fortified frontier" is a fair gloss on what was actually there, an earth bank and ditch with a timber palisade, roughly 900 watchtowers and more than 60 forts along 550 kilometres between the Rhine near Rheinbrohl and the Danube. The one specialist objection available is that Latin limes originally meant a boundary path or swathe rather than a fortified line, and Benjamin Isaac has argued the fortified-frontier sense is a late-antique and largely modern usage. That does not reach this sentence, because the essay is using limes as every reference work and every German speaker uses it, as the name of the physical frontier work, and it glosses the word rather than leaving the reader to guess.

- Wikipedia, "Limes Germanicus" <https://en.wikipedia.org/wiki/Limes_Germanicus>
  > "a line of frontier fortifications that bounded the ancient Roman provinces of Germania Inferior, Germania Superior and Raetia, dividing the Roman Empire and the unsubdued Germanic tribes from the years 83 to about 260 AD"; construction used "an earth bank and ditch with a wooden palisade and watchtowers at intervals, and a system of linked forts … built behind them". Notes that the term limes originally meant "border path" or "swathe".
- UNESCO World Heritage listing material for the Upper German-Raetian Limes <https://www.romantischer-rhein.de/en/rhine-romanticism-and-the-region/majestic-unesco-world-heritage/unesco-world-heritage-site-upper-german-raetian-limes>
  > The Upper German-Raetian Limes runs 550 km from the Rhine near Rheinbrohl to the Danube near Regensburg and comprised about 900 watchtowers, numerous small forts and over 60 large forts for cohorts and alae.

**B11 · line 133** · confidence high

> they never permanently conquered the lands beyond the Rhine and Danube

Per the brief I read Conjugar's cluster G before searching, and did not re-run the two-Germanias research the adversarial pass already settled. What remained was the Agri Decumates, and it is the right thing to press on, because it is the counterexample the earlier objection missed: a wedge of territory east of the Rhine and north of the Danube, taken under Vespasian from about 74 AD, enclosed by the limes from about 83 AD, and held until the Alamanni took it around 260. That is roughly 180 years, which is well over a century and is not a raid. Dacia, beyond the Danube from 106 to 271, is a second such case. The claim survives on one word. "Permanently" is not decoration here; it is the load-bearing element, and both holdings ended with Rome giving the ground up, so neither falsifies it. The essay is also not blind to the Agri Decumates, since the clause immediately before this one has Rome establishing the limes, and the limes is exactly the wall around that territory. A reader who takes the sentence to mean Rome never set foot east of the Rhine has misread a sentence that has just told him otherwise. Two consequences worth recording rather than researching. If the word "permanently" were ever dropped in an edit, the sentence would become false; the German at line 99 preserves it as "dauerhaft", so both surfaces are currently sound.

- Encyclopaedia Britannica, "Agri Decumates" (read via search summary; direct fetch of britannica.com returned HTTP 403) <https://www.britannica.com/place/Agri-Decumates>
  > The Agri Decumates was the wedge of territory between the upper Rhine, the Danube and the Main, and "The Romans were displaced from the Agri Decumates by the Alemanni in about ad 260."
- Imperium Romanum, "Gain and loss of Agri Decumates" <https://imperiumromanum.pl/en/article/gain-and-loss-of-agri-decumates/>
  > Roman subordination of the Agri Decumates began under Vespasian, who from 72-74 AD began the settlement and fortification of the region between the upper Rhine and the Danube, and by about 80 AD had taken a large strip of land between the two rivers; the territory was abandoned around 260.
- Wikipedia, "Limes Germanicus" <https://en.wikipedia.org/wiki/Limes_Germanicus>
  > The frontier fortifications divided the Roman Empire from the unsubdued Germanic tribes "from the years 83 to about 260 AD", which brackets the period of Roman tenure east of the Rhine inside the limes.
- Conjugar cluster G, "Raised and dismissed", /Users/josh/Desktop/workspace/Conjugar.mig/docs/history_corrections.md line 759
  > The near-identical objection "Rome never took Germania at all" was refuted and dropped: the two provinces called Germania lay west of the Rhine and were reckoned part of Roman Gaul, reference works state that the territories east of the Rhine "remained independent of Roman control", and the proposed replacement was judged worse than the original for compressing the battle into "one afternoon" and implying an immediate withdrawal contradicted by Germanicus's campaigns of AD 14 to 16.

**B13 · line 135** · confidence high

> Had the Romans conquered Germania, the Germanic peoples might have adopted Vulgar Latin, as did so many others within the Empire

A counterfactual cannot be checked, only its hedge and its supporting generalization. Both hold. "Might have" is the correct strength, and it is not a weasel: Britain is the standing counterexample, conquered and held for the better part of four centuries without Latin displacing Brittonic, and the eastern provinces kept Greek, Coptic and Aramaic throughout. So an unhedged "would have" would have been an error, and the essay does not write one. "As did so many others within the Empire" is also correctly bounded by "so many" rather than "all": Gauls, the peoples of Iberia, Dacians and much of North Africa did shift, which is more than enough to carry the phrase. The sentence is also the one place in the section that names the mechanism correctly, adoption of Latin by a population, which is why it is worth keeping exactly as it stands while B12's sentence is brought into line with it.

*Assumes.* Depends on B11, which I own and have confirmed. The verdict assumes B11 stands as written, that Rome never permanently held the lands beyond the Rhine and Danube, since the counterfactual is only interesting if the conquest did not in fact happen. The Agri Decumates, which B11 discusses, is a partial and temporary exception and does not disturb the counterfactual as the essay frames it, because the essay is talking about Germania as a whole.

- Jona Lendering, "Teutoburg Forest (7)", Livius.org, "Assessment" <https://www.livius.org/articles/battle/teutoburg-forest-9-ce/teutoburg-forest-7/>
  > Puts the identical counterfactual and hedges it the same way the essay does: "if the Romans had kept the country between the Rhine and Elbe, the North Sea tribes that were later known as Saxons would have spoken Latin. The English language would, for better or worse, never have existed, and German would have been marginal." He then qualifies the causation: "But the fights were not the cause of this rift; they were a precondition."
- Wikipedia, "History of the Romanian language"; Wikipedia, "Gaulish" <https://en.wikipedia.org/wiki/History_of_the_Romanian_language>
  > Both describe completed shifts to Latin under Roman rule: Dacian elites and urban populations "adopting Latin for social mobility, intermarriage, and governance, leading to bilingualism and eventual language shift", and Gaulish "supplanted by Vulgar Latin by around the end of the 5th century". These are the "so many others" the essay's clause points at.

### Cluster C: Tacitus country

**C3 · line 136** · confidence high

> raising cattle, pigs, sheep, and horses

This one archaeology settles on its own, without recourse to Tacitus. Iron Age faunal assemblages in the Germanic north are dominated by cattle, pig and sheep or goat, and the byre-houses give an independent line of evidence, since stall partitions in the longhouses allow herd sizes to be counted rather than estimated from bone fragments. Feddersen Wierde yields about 450 cattle across the settlement on that basis. Horses are the fourth animal and are securely attested, though in smaller numbers as livestock; the sacrificial deposits make them highly visible, with roughly a hundred sacrificed horses at Skedemosse on Öland and about twenty-four at Oberdorla in Thuringia. Tacitus agrees but adds nothing the bones do not already say: Germania 5 calls the land 'pecorum fecunda, sed plerumque improcera', fertile in livestock but mostly undersized, and Germania 12 has lesser offences fined 'equorum pecorumque numero', by a count of horses and cattle, which presupposes both. The essay's omission of goats is not a defect, since sheep and goat are a single osteological category in practice.

- 'Fårehyrder, kvægbønder eller svineavlere: en revurdering af jernalderens dyrehold' (reassessment of Iron Age animal husbandry), summarised via archaeozoological review <https://www.researchgate.net/publication/358343479_Farehyrder_kvaegbonder_eller_svineavlere_-_En_revurdering_jernalderens_dyrehold>
  > States that cattle, pig and sheep/goat dominated Iron Age faunal assemblages, and that the proportion of cattle is probably less marked than the bone material suggests because recovery without sieving favours the largest species and bone elements; houses with a byre and stall partitions have traditionally been used to calculate herd size.
- Tacitus, Germania 5 and 12 (Latin text, The Latin Library) <https://www.thelatinlibrary.com/tacitus/tac.ger.shtml>
  > Ch. 5: 'pecorum fecunda, sed plerumque improcera'. Ch. 12: lesser offences are punished in proportion, the convicted being fined 'equorum pecorumque numero'.
- Skedemosse and Oberdorla sacrificial deposits, comparative figures <https://en.wikipedia.org/wiki/Roman_Iron_Age_weapon_deposits>
  > Records horse and cattle skeletons deposited with weapons at Skedemosse on Öland, with around 100 horse sacrifices there against 24 at Oberdorla, indicating differing ritual valuation of the animals.

**C4 · line 136** · confidence high

> Cattle were especially important, serving as a measure of wealth and a form of currency

Three independent evidence chains converge here, and only one of them is Tacitus, which is unusual for this section. Archaeology: the Germanic longhouse is a byre-house, and its stall partitions mean cattle holdings are physically built into the architecture and countable per farmstead, which is what lets an excavator report roughly 450 cattle at Feddersen Wierde; a society that measures its houses in stall places is measuring its wealth in cattle. Linguistics, entirely independent of any Roman source: Proto-Germanic *fehu 'livestock', from PIE *pek'u, yields Gothic faihu, Old English feoh 'livestock, property, money' which becomes Modern English fee, Old Norse fé 'livestock, wealth, money', Old High German fihu, the semantic drift from cattle to money happening inside Germanic exactly as Latin pecus yields pecunia. Tacitus is the third leg and is the weakest, being a moralising contrast with Roman avarice, but it is specific: Germania 5 says of their herds 'numero gaudent, eaeque solae et gratissimae opes sunt', they delight in number and these are their only and most cherished riches, and Germania 12 assesses judicial fines in a count of horses and cattle, which is cattle functioning as a medium of payment rather than merely as an index of status. 'A form of currency' is the strongest phrase in the sentence and Germania 12 is what carries it.

- Reconstruction: Proto-Germanic *fehu, with Germanic descendants <https://en.wiktionary.org/wiki/Reconstruction:Proto-Germanic/fehu>
  > Derives *fehu 'livestock' from PIE *pék'u and lists Gothic faihu, Old English feoh 'livestock, property, money', Old Norse fé 'livestock, wealth, money', Old High German fihu, Old Saxon fehu, cognate with Latin pecū and Sanskrit paśu; notes the sense development to 'movable property, wealth' and the English descendant 'fee'.
- Tacitus, Germania 5 and 12 (Latin text, The Latin Library) <https://www.thelatinlibrary.com/tacitus/tac.ger.shtml>
  > Ch. 5 says of their cattle that they take pleasure in mere number and that these are their sole and most welcome wealth. Ch. 12 states that those convicted of lesser offences are fined by a number of horses and cattle.
- Feddersen Wierde settlement data (Haarnagel excavations) <https://en.wikipedia.org/wiki/Feddersen_Wierde>
  > Gives an estimated 450 cattle for the third-century settlement alongside 26 farmsteads and about 300 inhabitants, figures derived from the byre-house stalls.

**C5 · line 138** · confidence medium

> led by chieftains whose authority derived from military prowess, generosity, and noble lineage

The three sources of authority are all Tacitus, and the chain does lead back to him, but each is corroborated at least indirectly. Germania 7 opens 'reges ex nobilitate, duces ex virtute sumunt', they take kings on the basis of noble birth and war-leaders on the basis of valour, and adds that royal power is neither unlimited nor unchecked; Germania 13 says conspicuous nobility or a father's great services can win the standing of a princeps even for very young men; Germania 14 and 15 make liberality the leader's defining obligation. So lineage, prowess and generosity are all there. Archaeology corroborates a ranked elite without being able to speak to the basis of its authority: the Lübsow horizon of richly furnished inhumations of the earlier Roman Iron Age, spread across northern central Europe with Roman bronze, silver and glass imports, is read as the burials of the highest tribal nobility, and the weapon deposits show equipment in graded tiers. The one thing the essay does that Tacitus does not is collapse his own distinction between hereditary kingship and elected war-leadership into a single office holding all three qualifications at once. That is a real loss of nuance, but the claim as written, that authority rested on those three things, is not thereby wrong, and no reader is misinformed about anything statable. I am recording the tension rather than proposing a finding on it.

- Tacitus, Germania 7 and 13 (Latin text, The Latin Library) <https://www.thelatinlibrary.com/tacitus/tac.ger.shtml>
  > Ch. 7: 'Reges ex nobilitate, duces ex virtute sumunt. Nec regibus infinita aut libera potestas'. Ch. 13: 'insignis nobilitas aut magna patrum merita principis dignationem etiam adulescentulis adsignant'.
- Lübsow / Lubieszewo group princely graves <https://en.wikipedia.org/wiki/Prince_graves_of_the_Lubieszewo_group>
  > Describes a supra-regional horizon of richly furnished inhumation burials of local elites with luxury imports, chiefly Roman bronze vessels along with silver, glass and pottery, attributed to members of the highest tribal nobility and used as a status marker.

**C7 · line 138** · confidence medium

> expected gifts of weapons, gold, and feasting in return for their service

Weapons and feasting are Tacitus almost word for word and need no defence: Germania 14 has the followers demand of their chief's liberality 'illum bellatorem equum, illam cruentam victricemque frameam', that warhorse, that bloody and victorious spear, and states that 'epulae et quamquam incompti, largi tamen apparatus pro stipendio cedunt', feasts and lavish if unrefined provisions serve in place of pay. Gold is the item I looked hardest at, because Germania 5 says the gods have denied them silver and gold, and because the archaeological gold of the Germanic north, the arm-rings and neck-rings of high-status graves, belongs mainly to the Late Roman Iron Age from about 150 AD onward and to the Migration Period, while the Lübsow-horizon imports contemporary with Teutoburg are bronze, silver and glass. But Germania 5 goes on to allow that those nearest the frontier value gold and silver for trade, and Germania 15 lists among the gifts sent to chiefs 'electi equi, magna arma, phalerae torquesque', chosen horses, great arms, trappings and neck-rings, which are precious-metal objects. That is enough that the claim as written cannot be called wrong, and the essay does not date the gold. I considered proposing a nitpick swapping gold for treasure and decided against it: the correction would be one word, it would not change what a reader believes, and Germania 15 would carry the refutation. Recording the tension instead.

- Tacitus, Germania 5, 14 and 15 (Latin text, The Latin Library) <https://www.thelatinlibrary.com/tacitus/tac.ger.shtml>
  > Ch. 5 doubts whether the gods denied them silver and gold in favour or in anger, while noting that those nearest the frontier prize gold and silver for commerce. Ch. 14 has the retinue demand the warhorse and the victorious spear and says feasts serve as pay. Ch. 15 lists gifts of chosen horses, great arms, phalerae and torques.
- Rings in early Germanic cultures, survey of arm-rings and oath-rings <https://grokipedia.com/page/Rings_in_early_Germanic_cultures>
  > Places gold arm-rings interred in high-status graves with Roman imports chiefly in the Late Roman Iron Age, c. 150 to 400 CE, with a material hierarchy in which gold marks kings and nobles and silver marks warriors and lesser elites, the metals sourced through Roman imports.

**C8 · line 140** · confidence medium

> The Germanic peoples had no centralized states or cities

The half about cities is corroborated independently of Tacitus and is not in doubt: no urban settlement is known anywhere beyond the Rhine and Danube in this period, and the large central places that later develop, Gudme, Uppåkra, Helgö, are third century and after and are magnate residences with attached workshops rather than towns. Tacitus says the same in Germania 16, 'nullas Germanorum populis urbes habitari satis notum est', but the archaeology would say it without him. The half about centralized states is a generalisation with one well-known exception standing almost exactly at the essay's chosen date. Maroboduus of the Marcomanni moved his people into Bohemia around 9 BC and built a kingdom and a confederacy that Rome recognised in AD 6, with a standing force drilled on Roman lines; in 9 AD he declined to join Arminius. He is routinely described as the first documented Germanic ruler with a government of that kind. That is a genuine complication, but it is also the exception that the standard accounts name as an exception, it left no city that has been located, and the kingdom did not outlive the next decade. The essay is making a structural point about Germanic society at large, and on that point it is right. Confirming, with Maroboduus noted rather than suppressed.

- Tacitus, Germania 16 (Latin text, The Latin Library) <https://www.thelatinlibrary.com/tacitus/tac.ger.shtml>
  > 'Nullas Germanorum populis urbes habitari satis notum est', it is well enough known that no cities are inhabited among the peoples of the Germani, who live separated and apart.
- Maroboduus, Britannica <https://www.britannica.com/biography/Maroboduus>
  > Records that about 9 BC Maroboduus led his people from the Main valley into Bohemia, founded a kingdom and formed a powerful confederacy with neighbouring tribes; Rome recognised the kingdom in AD 6, and in AD 9 he refused to support Arminius against Rome.

**C11 · line 140** · confidence high

> Their literature was oral: heroic poetry, mythological tales, and genealogies

No archaeology can corroborate this, because oral literature leaves no material trace, so the honest answer to the cluster's question is that the evidence chain here does not run through the ground. But it does not run only through Tacitus either, and the second strand is genuinely independent of him. Tacitus supplies the direct testimony, and it supplies all three of the essay's categories in one sentence: Germania 2 says they celebrate in ancient songs, 'quod unum apud illos memoriae et annalium genus est', which is their only form of record and annals, the earth-born god Tuisto and his son Mannus as 'originem gentis conditoresque', the origin and founders of the people. That is mythological tale and genealogy at once, and Germania 3 adds songs of Hercules and the barditus, which covers heroic verse. The independent strand is comparative: Old English, Old Saxon, Old High German and Old Norse all inherit the same alliterative metre and share legendary matter, the Hildebrandslied and Beowulf and the Nibelung and Ermanaric cycles, which is not explicable unless a common oral verse tradition preceded the written ones; and Anglo-Saxon and Scandinavian royal genealogies survive in quantity. Jordanes independently reports Gothic history preserved in their ancient songs. The essay's sentence claims nothing beyond what those two strands together support.

- Tacitus, Germania 2 and 3 (Latin text, The Latin Library) <https://www.thelatinlibrary.com/tacitus/tac.ger.shtml>
  > Ch. 2 says they celebrate in ancient songs, the one kind of memory and annals they have, the god Tuisto sprung from the earth and his son Mannus as the origin and founders of the nation. Ch. 3 refers to songs of Hercules and to the battle chant they call barditus.
- Tacitus, Germania, full text with commentary (Harland) <https://www.philipharland.com/Blog/2022/07/germans-tacitus-germania-in-full-late-first-century-ce/>
  > Presents the Germania in translation with the songs of ch. 2 identified as the Germani's only form of historical record, and notes throughout the work's dependence on ethnographic commonplaces.

**C14 · line 142** · confidence high

> They practiced animal and occasionally human sacrifice, particularly at times of crisis or celebration

This is the one row in the cluster where archaeology corroborates independently, abundantly, and at exactly the right hedge strength. Animal sacrifice: Skedemosse on Öland produced roughly a hundred sacrificed horses along with cattle deposited with weapons; Oberdorla in Thuringia produced about twenty-four horses within an unbroken ritual sequence running from the Iron Age into the Merovingian period. The great weapon deposits, Illerup Ådal, Nydam, Ejsbøl, Vimose, consist of deliberately destroyed war gear, swords twisted and spearheads bent, sunk in bogs, with at least three separate depositional events at Illerup between about 200 and 500 AD, and their occasions are military defeats, which is 'times of crisis' as literally as the record permits. Human sacrifice: the bog bodies, Tollund Man, Grauballe Man, the Elling Woman, are commonly interpreted as sacrificial killings, and Tacitus independently reports human victims in Germania 9, a man publicly killed in the Semnones' grove in 39, and the drowning of the Nerthus attendants in 40. The essay's 'occasionally' is doing exactly the work it should, because the bog-body interpretation is genuinely contested, with judicial execution and punishment live alternatives, and because no human remains accompany the weapon deposits themselves. A stronger word would have been an error; the hedge as written matches where the scholarship sits.

- Roman Iron Age weapon deposits, overview <https://en.wikipedia.org/wiki/Roman_Iron_Age_weapon_deposits>
  > Describes intentional deposition of large quantities of weapons in Scandinavian bogs, ritually 'killed' by twisting swords and bending spearheads; at least three sacrificial events at Illerup in the period around 200 to 500 AD; horse and cattle skeletons with weapons at Skedemosse, around 100 horse sacrifices there against 24 at Oberdorla; and notes that no human bodies accompany the weapon sacrifices themselves.
- National Museum of Denmark, weapon sacrifices in the Iron Age <https://en.natmus.dk/historical-knowledge/denmark/prehistoric-period-until-1050-ad/the-early-iron-age/weapon-sacrifices-in-the-iron-age/>
  > Presents the bog weapon deposits as sacrificial offerings of defeated armies' equipment, deposited after military events.
- Tacitus, Germania 9, 39 and 40 (Latin text, The Latin Library) <https://www.thelatinlibrary.com/tacitus/tac.ger.shtml>
  > Ch. 9 says they hold it lawful to propitiate the god they identify with Mercury with human victims as well. Ch. 39 describes the Semnones' grove and a man killed publicly there. Ch. 40 describes the Nerthus rite and the drowning of those who served the goddess.

### Cluster D: The Germanic verb

**D1 · line 143** · confidence medium

> As Proto-Indo-European evolved into Proto-Germanic over some two millennia

Judged as an interval claim, not an absolute date, because the absolute endpoints belong to cluster A. The essay's own chronology puts the Germanic separation at 2500 to 2000 BC (A5) and a recognizable Proto-Germanic in the first millennium BC (A7), which yields between fifteen hundred and two thousand years. "Some two millennia" is the correct round number for that span and is hedged by "some". Read against the ordinary handbook chronology instead, with PIE dissolving around 3000 to 2500 BC and Proto-Germanic in place by roughly 500 BC, the interval is two to two and a half millennia, so the essay's figure is if anything conservative. No reading of the standard datings makes "some two millennia" wrong. I did not research the endpoints themselves.

*Assumes.* Assumes cluster A upholds A5 (Germanic separating between 2500 and 2000 BC) and A7 (a recognizable Proto-Germanic by the first millennium BC). If A5 or A7 is moved substantially later, the interval shrinks and "some two millennia" would need rechecking.

- Lehmann, A Grammar of Proto-Germanic, ch. 5 (Linguistics Research Center, University of Texas at Austin) <https://lrc.la.utexas.edu/books/pgmc/5-syntax>
  > Treats Proto-Germanic as a reconstructed stage with two indicative tenses standing at the end of a long restructuring of the inherited Indo-European verb, without assigning the essay's specific interval.

**D2 · line 144** · confidence high

> The old imperfective became the Germanic present

This is the standard account. The PIE present or imperfective stem is the direct source of the Germanic present, and no handbook derives the Germanic present from the aorist or perfect as a general matter. The one specialist qualification is that a handful of Germanic strong presents are analyzed as reinterpreted PIE aorist subjunctives rather than as inherited present stems, which Ringe notes; that is a footnote to a generalization, not a counterexample to it, and the essay's flat sentence is the right level of resolution for a general reader. Nothing here would misinform anyone.

- Lehmann, A Grammar of Proto-Germanic, ch. 3 Inflection (LRC, UT Austin) <https://lrc.la.utexas.edu/books/pgmc/3-inflection>
  > Describes the Proto-Germanic present-tense forms of strong classes 1 to 5 as continuations of the inherited active inflection, in contrast with the preterite, which it derives from the Indo-European perfect.
- Ringe, From Proto-Indo-European to Proto-Germanic, as summarized in reference material on Proto-Germanic verb morphology <https://en.wikipedia.org/wiki/Germanic_strong_verb>
  > The Proto-Germanic present indicative derives from the PIE present indicative, or for a few verbs from an aorist subjunctive that was reinterpreted as a present.

**D3 · line 144** · confidence high

> the old perfect, with its distinctive reduplication and o-grade ablaut, was repurposed as a preterite

Every element of this sentence is standard. The PIE perfect is characterized by reduplication and by o-grade in the singular against zero grade in the dual and plural; the Germanic strong preterite continues exactly that pattern, with PIE o showing up as Germanic a in the singular and zero grade in the plural, which is why German sang stands against sungen. Reduplication survives visibly in the Gothic class VII preterites such as staistaut to stautan, and its residue is what the seventh class is defined by. "Repurposed" is the right verb: what had been a stative aspect stem became a past tense.

- Reference grammar of the Germanic strong verb <https://en.wikipedia.org/wiki/Germanic_strong_verb>
  > The Indo-European perfect took o-grade in the singular and zero grade in the dual and plural; the Germanic strong preterite shows the expected development of short o to short a in the singular and zero grade in the plural. Reduplication, one of the regular ways of forming the Indo-European perfect, was inherited into early Germanic as a marker of the preterite in some strong verbs, seen most clearly in Gothic, and those verbs are grouped as the seventh class.
- Lehmann, A Grammar of Proto-Germanic, ch. 3 Inflection (LRC, UT Austin) <https://lrc.la.utexas.edu/books/pgmc/3-inflection>
  > "the preterite is based at least in part on the perfect of Proto-Indo-European, which indicated state as the result of completed action".

**D4 · line 144** · confidence medium

> The aorist was largely lost, its conjugations occasionally merging with the new preterite

I went looking for the objection the brief anticipated, that the Germanic aorist residue is systematic rather than occasional, and it does not hold up as a correction. The standard formulation is that the PIE aorist and perfect fell together in a single Germanic preterite whose morphology comes overwhelmingly from the perfect, with a limited set of aorist elements absorbed. The residue usually named is specific and small: the preterite optative suffix Germanic *-i- from the athematic root-aorist optative *-ih1-, which is the subject of Kim's 2019 study of Old English cyme; the long-vowel preterites of class VI, which several scholars trace to a lengthened-grade aorist; and a few presents built on reanalyzed aorist subjunctives. "Largely lost" and "occasionally merging with the new preterite" is a fair compression of exactly that. A stronger word than "occasionally" would have been defensible, but so is the essay's, and nothing here misinforms a reader.

*Assumes.* Depends on D3, which I also own and confirm: the claim that the aorist merged into "the new preterite" presupposes that the new preterite is the repurposed perfect.

- Kim, "Old English cyme and the Proto-Indo-European Aorist Optative in Germanic", Transactions of the Philological Society 117 (2019) <https://onlinelibrary.wiley.com/doi/abs/10.1111/1467-968X.12147>
  > Argues that Old English cyme reflects a PIE root-aorist optative, and discusses other candidate reflexes of PIE root-aorist optatives in Germanic together with an explanation of why they mostly disappeared. The paper's premise is that such reflexes are isolated survivals worth arguing for individually, not a productive inherited category.
- Reference material on Germanic verb morphology summarizing the standard account <https://en.wikipedia.org/wiki/Germanic_strong_verb>
  > The PIE aorist and perfect merged into a single preterite category, with the strong preterite deriving primarily from the PIE perfect and incorporating some aorist elements; a present/preterite system replaced the older Indo-European aorist and perfect in Proto-Germanic.

**D5 · line 146** · confidence high

> This left Germanic with only ~two tenses~: present and preterite

Uncontroversial and stated in the same terms by the handbooks. Proto-Germanic had exactly two inflected indicative tenses. Everything else German later acquired, the perfect, the pluperfect, the future, is periphrastic, which the essay itself says two sentences later and again in the sections cluster F owns. The one thing a specialist might raise is that Lehmann argues an imperfective versus perfective aspect opposition survived into Proto-Germanic carried by the ga- prefix, but that is a claim about aspect, not about the number of tenses, and it does not touch this sentence. It does touch the uninventoried sentence next to it, which I report as a gap.

- Lehmann, A Grammar of Proto-Germanic, ch. 5 Syntax (LRC, UT Austin) <https://lrc.la.utexas.edu/books/pgmc/5-syntax>
  > "The two Proto-Germanic indicative tenses, present and preterite, primarily expressed present and past time."

**D8 · line 152** · confidence medium

> ~Verb classes proliferated based on the structure of the present stem~

I judged the factual content and the placement separately, per the brief. The factual content holds. Germanic verb-class membership really is read off the present stem in both halves of the system: the seven strong classes are distinguished by the shape of the root as it appears in the present, with classes one to three built on e plus a resonant plus a consonant and classes four and five on e plus a single consonant, and the four weak classes are distinguished by nothing but their present-stem suffix, *-jan, *-on, *-an and *-nan. So "based on the structure of the present stem" is an accurate compression of both. "Proliferated" is the word a specialist could argue with, since PIE had a wider inventory of present-stem formations than the eleven classes Germanic ended up with, so what happened is better described as a reorganization into a smaller number of larger classes. But the essay is comparing against the PIE aspect stems it has just described losing, and against that baseline eleven conjugation classes is a genuine increase in the number of things a learner must know. The mismatch between this sentence and the heading it sits under, "Losses from Proto-Indo-European", is real but editorial, and I report it as a note rather than dress it as a factual error.

- Reference grammar of the Germanic strong verb <https://en.wikipedia.org/wiki/Germanic_strong_verb>
  > Seven classes are traditionally proposed for strong verbs. The first three classes have bases with the vocalism e plus a resonant plus a consonant, while the fourth and fifth have bases with e followed by a single consonant. The first six classes form the past tense with ablaut alone and the seventh through reduplication.
- Reference grammar of the Germanic weak verb <https://en.wikipedia.org/wiki/Germanic_weak_verb>
  > Proto-Germanic has four main classes of weak verb which differ in the vowels that follow the verb stem: verbs in -janą with past in -id-, verbs in -ōną with past in -ōd-, verbs in -āną with past in -ād-, and the small class in -nan.
- Lehmann, A Grammar of Proto-Germanic, ch. 3 Inflection (LRC, UT Austin) <https://lrc.la.utexas.edu/books/pgmc/3-inflection>
  > Weak verbs are categorized by their suffixes, -ja-, -ō-, -ái- and -nō-, and derive from causative, denominative or inchoative formations.

**D9 · line 152** · confidence high

> strong classes are "organized by ablaut patterns"

This is the definition of the category, not a contestable claim about it. Strong verbs are precisely those that mark the preterite and the participle by vowel gradation rather than by affixation, and the traditional seven classes are the seven ablaut series, the Ablautreihen of the German grammatical tradition. The only strong class not defined by its ablaut series is the seventh, which is defined by reduplication in Gothic and which acquired an ablaut-like pattern secondarily in Northwest Germanic, and the essay does not enumerate the classes here, so that does not bear on the sentence as written.

*Assumes.* Cluster E's E9 restates this claim for Old High German and cites D9. My verdict here should be read as covering the Proto-Germanic statement; E owns the OHG one.

- Reference grammar of the Germanic strong verb <https://en.wikipedia.org/wiki/Germanic_strong_verb>
  > Strong verbs form their preterite and past participle primarily through ablaut, a system of vowel gradation inherited from Proto-Indo-European, rather than by affixation, and the seven classes are given by their principal parts: infinitive, preterite singular, preterite plural and past participle.

**D10 · line 153** · confidence high

> weak verbs added a dental suffix (*-d- or *-t-)

A fair reconstruction at the essay's resolution. Specialists usually write the Proto-Germanic suffix as a voiced fricative, *-ð-, with two conditioned allomorphs: it devoices to *-t- after a voiceless obstruent, which is why Gothic has waurhta to waurkjan and kunþa to kunnan, and it hardens to a stop *-d- after a nasal, which is why Gothic has nasida. Writing the alternation as "*-d- or *-t-" names the two shapes that actually surface in the daughter languages and matches the standard textbook formulation for a non-specialist audience. It would be a bad correction to insist on *-ð- here, since that notation buys precision the surrounding paragraph does not use and the essay uses no phonetic notation anywhere else. The word "dental" is doing the real work in the sentence and it is right.

- Reference grammar of the Germanic weak verb <https://en.wikipedia.org/wiki/Germanic_weak_verb>
  > In its original Proto-Germanic form the dental suffix appears to have been realized as the voiced fricative /ð/, classically spelled d. It devoices to /t/ after a voiceless consonant, as in Gothic waurhta and kunþa, and hardens to the voiced plosive /d/ after a nasal, as in Gothic nasida.
- Lehmann, A Grammar of Proto-Germanic, ch. 3 Inflection (LRC, UT Austin) <https://lrc.la.utexas.edu/books/pgmc/3-inflection>
  > Describes the weak preterite as "based on the addition of a *dh-suffix that indicated state", that is, a dental formative added to the stem.

**D11 · line 153** · confidence high

> This is the origin of the "-te" ending in German preterites (machte, sagte, spielte)

Direct and uncontested. The modern German weak preterite in -te continues the Old High German weak preterite in -ta, which is the Proto-Germanic dental suffix with its endings; Kiparsky's discussion works through Old High German forms of exactly this shape, zelita, hōrta, tuomta, and traces the -t- of Old High German zelitun back to the Germanic dental formative. All three of the essay's examples are ordinary weak verbs of the productive classes, machen, sagen and spielen, with no complication of any kind, and they were plainly chosen to pair with the three English examples that follow.

*Assumes.* Depends on D10, which I also own and confirm.

- Kiparsky, "The Germanic Weak Preterite" (Stanford) <https://web.stanford.edu/~kiparsky/Papers/lahiri_weakpreterite.pdf>
  > Sets out the development from Germanic [[tal + i] + [dēd + un]] to Old High German [zel + i + t + un], and analyzes Old High German weak preterites zelita 'told', hōrta 'heard', tuomta 'judged', dampfta, branta and kusta as the dental preterite of the weak classes.

**D13 · line 155** · confidence high

> The origin of this dental suffix is debated, but the most widely accepted theory is that it derives from a compound with the verb "to do" (*dō-)

This is the run's named trap and the essay does not fall into it. The rule is to judge the hedge as written, and the hedge is not merely defensible, it is close to verbatim what the specialist literature says. Kiparsky, whose paper is about this exact question and who does not himself need the composition theory to be true, writes that the derivation from the past tense of the light verb dōn goes back at least to Bopp 1816 and that "though not uncontroversial, it is perhaps the most widely accepted etymology of the dental preterite", naming Streitberg, Sverdrup, von Friesen, Tops and Bammesberger as its holders. He separately writes that after nearly two centuries "there is still no consensus" on whether the formative is a reflex of one or more Indo-European dental suffixes, a grammaticalized form of the light verb, or some mix. Set the essay's two clauses beside those two statements and they line up one to one: debated, and the do-compound is the leading account. The rival accounts the brief asked me to weigh, derivation from a dental-suffixed participle in *-to- and derivation from aorist material, are live and are exactly what Kiparsky's "one or more of the Indo-European dental suffixes" refers to, but neither is described anywhere I looked as having displaced the composition theory as the most widely held. Saying so is the valuable answer here, and I would expect a skeptic to reach the same page and agree.

*Assumes.* Depends on D10, which I also own and confirm.

- Kiparsky, "The Germanic Weak Preterite" (Stanford), section 1 <https://web.stanford.edu/~kiparsky/Papers/lahiri_weakpreterite.pdf>
  > "The idea that the dental preterite ending is descended from the past tense of the light verb dōn 'do' goes back at least to Bopp 1816. Though not uncontroversial, it is perhaps the most widely accepted etymology of the dental preterite (Streitberg 1896, Sverdrup 1929, von Friesen 1925, Tops 1974, Bammesberger 1986)." And earlier: "The morphological provenience of its dental formative -d- has been debated for nearly two centuries, and there is still no consensus on whether it is a reflex of one or more of the Indo-European dental suffixes, a grammaticalized form of the light verb dō 'do', or some mix of these."
- Reference grammar of the Germanic weak verb <https://en.wikipedia.org/wiki/Germanic_weak_verb>
  > The characteristic dental suffix of Proto-Germanic weak verbs is widely attributed to a periphrastic construction involving the auxiliary *dōną 'to do', an etymology tracing to Bopp 1816 and Streitberg 1896, with the proto-form often reconstructed as *-dē- reflecting *dʰeh₁-.

**D14 · line 155** · confidence high

> What began perhaps as "I love-did" grammaticalized into a single word with a fused past-tense suffix

This is a correct statement of what the theory D13 has just named actually claims, and it carries its own hedge in "perhaps". Kiparsky lays out the trajectory in three stages, compounding, then cliticization, then suffixation, and gives the Germanic example as the compound of the verb stem with the past of the light verb, [[tal + i] + [dēd + un]], reduced to Old High German [zel + i + t + un]. That is literally "tell-did" becoming zelitun, which is the essay's "I love-did" with a different verb. He also cites the uncontroversial parallel of Latin cantāre habeō becoming French chanterai, and a Bengali parallel, as instances of the same trajectory. The essay is not asserting the theory here, it is illustrating it, and the illustration is faithful.

*Assumes.* Depends on D13, which I also own and confirm.

- Kiparsky, "The Germanic Weak Preterite" (Stanford), examples (1) to (3) <https://web.stanford.edu/~kiparsky/Papers/lahiri_weakpreterite.pdf>
  > Gives the grammaticalization trajectory as compounding, then cliticization, then suffixation, and lines up Latin cantā-re habeō, Old Bengali, and Germanic [[tal + i] + [dēd + un]] as instances, with the outcomes French chanterai, Modern Bengali, and Old High German [zel + i + t + un]. States that the Germanic periphrastic forms could have been later grammaticalized into inflected forms, exactly as the Sanskrit periphrastic perfects were grammaticalized in Middle Indic.

**D15 · line 155** · confidence high

> new verbs entering Germanic languages almost always followed the weak pattern, and many originally strong verbs eventually became weak

Both halves are standard, and both are hedged at the right strength. The weak pattern was regular and predictable and therefore became the productive class, taking essentially all coinages and loans; the strong system stopped being productive very early and almost no new strong verbs were created. The drift from strong to weak is equally well documented, and the total number of strong verbs has fallen steadily in every Germanic language. "Almost always" is the right hedge, since a small number of verbs have moved the other way by analogy, English dove for dived and snuck for sneaked being the usual examples, and "many" rather than "most" for the strong-to-weak drift keeps the sentence out of trouble.

- Reference grammar of the Germanic weak verb <https://en.wikipedia.org/wiki/Germanic_weak_verb>
  > The weak pattern was regular and predictable, so it became the productive class: virtually all new verbs coined or borrowed into the language entered as weak verbs. Over time the weak verbs became the normal form of verbs in all Germanic languages, with most strong verbs reassigned to the weak class, and the total number of strong verbs has decreased over time.
- Standard descriptions of Old English verb morphology <https://en.wikipedia.org/wiki/Germanic_strong_verb>
  > New verbs derived from nouns, adjectives and adverbs, a very productive way of word-building in Old English, were conjugated weak, and borrowed verbs were also weak.

**D16 · line 155** · confidence high

> The King James Bible provides one example of this pattern. In that book, the phrase "the cock $crEw$" appears.

The quotation is exact and it occurs at all four of the places it is usually cited from. Matthew 26:74 reads "And immediately the cock crew"; Mark 14:68 "and the cock crew"; Luke 22:60 "And immediately, while he yet spake, the cock crew"; John 18:27 "Peter then denied again: and immediately the cock crew." The example also does the job the paragraph asks of it, which is the point the brief told me to check independently of the sentence around it: crow was a class VII strong verb in Old English, crāwan with preterite crēow and participle crāwen, and it has gone weak, so it is a genuine instance of the strong-to-weak drift D15 describes and not merely an archaic spelling.

- King James Version, Matthew 26:74, Mark 14:68, Luke 22:60, John 18:27 <https://www.kingjamesbibleonline.org/bible-verses-like_Matthew-26-74/>
  > Matthew 26:74: "Then began he to curse and to swear, saying, I know not the man. And immediately the cock crew." John 18:27: "Peter then denied again: and immediately the cock crew."
- Etymological entry for English crow <https://en.wiktionary.org/wiki/crow>
  > From Old English crāwan, past tense crēow, past participle crāwen, that is, a strong verb of class VII.

**R3 · line 93** · confidence high

> PIE verbs were built on roots (typically consisting of a consonant-vowel-consonant structure) that carried core meaning

This is the handbook statement almost word for word, and the parenthesis carries the hedge that makes it true. The canonical PIE root is CeC, a consonant, the vowel *e, and a consonant, and reference treatments describe the basic structure of a PIE morpheme as CVC with the understanding that the internal vowel alternates. The complications a specialist would add are that either C can be a cluster, giving the fuller template with optional s-mobile and up to three consonants on a side, and that the vowel in the basic grade is specifically *e rather than any vowel. Both are absorbed by "typically", and both would be wasted on a reader who has just been told what ablaut is. The essay's own examples elsewhere, *bʰer- and *dō-, are consistent with the shape it describes.

- Reference treatment of PIE morphology in an introductory linguistics text <https://alic.sites.unlv.edu/chapter-15-5-pie-morphology/>
  > "The basic structure of a PIE morpheme is CVC (consonant-vowel-consonant), with the understanding that the internal vowel can change."
- Reference article on the Proto-Indo-European root, following Fortson and Meier-Brügger <https://lrc.la.utexas.edu/books/piep/2-pie-phonology>
  > Roots are abstract constructs typically structured as a consonant-vowel-consonant sequence such as *bʰer- or *h₁ed-, monosyllabic and of the form C(C)VC with the vowel usually e in the basic grade, though initial or final consonant clusters occur under phonological constraints.

**R4 · line 102** · confidence high

> The system allowed for present, past (preterite), and arguably future expressions, but aspectual distinctions carried more semantic weight than temporal ones

The word "arguably" is doing exactly the work it should, and removing it would be the error. Proto-Indo-European is not standardly reconstructed with a future tense. What the branches later call a future was built independently, out of desiderative *-s- formations in Greek and Indo-Iranian and out of subjunctives elsewhere, so a future is at best marginally attributable to the parent language. The essay flags precisely that with "arguably". The rest of the sentence is safe: present and past expressions are uncontroversial, and the subordination of tense to aspect is the standard characterization of the PIE verb, which is also what the preceding patched sentence says about the secondary endings. I note only that "preterite" is a Germanic-flavored gloss for what PIE handbooks call the imperfect and aorist, which is a reasonable choice in an essay whose subject is German.

*Assumes.* Depends on S3, which is settled and which I did not reopen: that past time was marked chiefly by the secondary endings. My verdict assumes S3 stands as patched.

- Lehmann, Proto-Indo-European Syntax, ch. 5 Categories (LRC, UT Austin) <https://lrc.la.utexas.edu/books/pies/5-categories>
  > PIE itself had no future tense, contrary to the views of some scholars; reference to the time of the action was indicated by adverbial or nominal elements, and the verbal forms associated with them were aspectual.
- Reference survey of Indo-European morphology and syntax <https://www.britannica.com/topic/Indo-European-languages/Morphology-and-syntax>
  > In some dialects, notably Sanskrit, Greek, Italic and Baltic, the tense system was amplified by a future, which developed from forms indicating doubt such as -s- suffixed forms and subjunctives; many daughter languages converted the original desideratives into future formations, while the desiderative meaning is preserved in Indo-Iranian.

### Cluster E: Old High German

**E2 · line 156** · confidence high

> distinguished from other Germanic languages by the ~High German consonant shift~

This is the definitional criterion, not merely a true statement about OHG. High German just is the set of continental West Germanic dialects that underwent the second sound shift, and the shift is what separates them from Low Franconian and Low German. The essay states the standard position in the standard terms.

- Search synthesis over Wikipedia "Old High German" and "High German consonant shift" <https://en.wikipedia.org/wiki/Old_High_German>
  > Old High German "encompasses the numerous West Germanic dialects that had undergone the set of consonantal changes called the Second Sound Shift", and "the main difference between Old High German and the West Germanic dialects from which it developed is that it underwent the Second Sound Shift"; the shift "is used to distinguish High German from other continental West Germanic languages, namely Low Franconian (including standard Dutch) and Low German, which experienced no shift".
- Wikipedia, "High German consonant shift" <https://en.wikipedia.org/wiki/High_German_consonant_shift>
  > "All High German dialects have experienced at least part of the shift of voiceless stops to fricatives/affricates."

**E4 · line 156** · confidence high

> giving German words like ~Pfund~, ~Wasser~, and ~machen~ their characteristic sounds where English has ~pound~, ~water~, and ~make~

These are the three canonical illustrations, one per stop, and each is correct: initial p to pf (Pfund), post-vocalic t to a fricative written s (Wasser), post-vocalic k to ch (machen), against unshifted English. One specialist's footnote that changes nothing: Pfund and pound are both borrowings of Latin pondō rather than an inherited Germanic pair, so the German word shows the shift applying to an early loan. The shift applied all the same, and the contrast the sentence draws holds.

- Wikipedia, "High German consonant shift" <https://en.wikipedia.org/wiki/High_German_consonant_shift>
  > The shift produced affricates initially, geminate and post-consonantal, and fricatives post-vocalically, for all three voiceless stops; standard German retains unshifted stops only after a fricative or in /tr/. Post-vocalic spirantization applied uniformly across all High German dialects.
- Danny Bate, "The High German Consonant Shift and How to Use It" <https://dannybate.com/2021/02/20/the-high-german-consonant-shift-and-how-to-use-it/>
  > Presents the shift through exactly this kind of German-to-English correspondence set, with pf/p, s/t and ch/k pairings as the diagnostic for whether a word crossed the shift.

**E5 · line 156** · confidence high

> The effects of the shift were not uniform. Dialects further south experienced more sound changes.

This is the Rheinischer Fächer in two plain sentences, and it is exactly right. The shift is a north-to-south gradient: the northern boundary is the Benrath line, and each further isogloss south adds another environment or another stop, until Bavarian and Alemannic show the most complete application. The essay does not name the fan or its lines, which costs nothing at this level of detail.

- Wikipedia, "High German consonant shift" <https://en.wikipedia.org/wiki/High_German_consonant_shift>
  > "The gradually increasing application of the shift from north to south is most extensive in the west", forming the fan-like pattern of isoglosses; b to p and g to k are consistent only in Old Bavarian, and k shifts outside post-vocalic position only in Alemannic and Bavarian.
- Grokipedia, "Central Franconian languages" <https://grokipedia.com/page/Central_Franconian_languages>
  > Central German varieties show inconsistent application, retaining /p/ unshifted in some forms while shifting /k/ and /t/; Ripuarian is characterized by "partial application of the High German consonant shift".

**E6 · line 156** · confidence high

> in Swiss German, the /k/ sound became guttural /x/. The Swiss German word for "kitchen" is therefore "Chuchi", contrasting with High German "Küche".

Correct as written. Most Swiss German is High Alemannic, and completion of the shift, including initial k to [x], is the defining feature of High Alemannic: chalt [xalt] against standard kalt [kʰalt], and Chuchi against Küche. Two things I considered and rejected as findings. 'Guttural' is a lay word rather than a phonetic term, but it points at the right place and misleads nobody. And Highest Alemannic in the Valais has an affricate [kx] rather than a plain fricative, so 'Swiss German' flattens an internal difference; that is a dialectological footnote inside a sentence whose job is to show a reader why Chuchi sounds the way it does.

- Wikipedia, "High Alemannic German" <https://en.wikipedia.org/wiki/High_Alemannic_German>
  > "The distinctive feature of the High Alemannic dialects is the completion of the High German consonant shift", exemplified by chalt [xalt] 'cold' against Low Alemannic and standard German kalt [kʰalt]. Most Swiss German dialects are High Alemannic and have shifted k as well as t and p.
- Wikipedia, "High German consonant shift" <https://en.wikipedia.org/wiki/High_German_consonant_shift>
  > "All dialects shift /k/ to /xx/ after a vowel; only the Upper German Alemannic and Bavarian shift it in other positions", which is precisely the initial-k shift that produces Chuchi from a form whose standard German counterpart keeps k.

**E7 · line 156** · confidence high

> in Kölsch, spoken in Cologne, the /t/ in "et", English "it", never shifted to /s/, as it did in German "es"

I checked this with the care the brief asks for, and the objection does not survive. The phonological claim is textbook: Middle Franconian, of which Ripuarian and hence Kölsch is part, keeps unshifted final /t/ in the neuter pronoun set, et, dat, wat, allet, while standard German has the shifted outcome, es, das, was. The framing survives too. Kölsch is Central German and did undergo part of the shift, since it lies south of both the Uerdingen and Benrath lines and has ich and maache. But the essay does not say Kölsch escaped the shift. It says 'more northerly dialects did not experience certain sound changes associated with the shift', which is an exact description of partial application, and 'more northerly' is a relative statement inside the German continuum, where Cologne is indeed north of the Swiss example it is being contrasted with. The one thing this sentence does expose is E1's too-southern map, since Cologne is inside the Old High German area; that is E1's problem, not this row's.

- Grokipedia, "Central Franconian languages" <https://grokipedia.com/page/Central_Franconian_languages>
  > "The Central German Middle Franconian dialects show unshifted final /t/ for neuter pronouns (that, thit, it, wat, allet)", and Ripuarian is characterized by partial application of the High German consonant shift, preserving voiceless stops in certain positions.
- Grokipedia, "Colognian dialect" <https://grokipedia.com/page/colognian_dialect>
  > Kölsch is "a small set of very closely related dialects of the Ripuarian Central German group", spoken around Cologne, in the area between the Benrath and Speyer lines.

**E8 · line 157** · confidence high

> Old High German inherited seven classes of strong verbs from Proto-Germanic

Seven is the standard count for Proto-Germanic itself, not just for the daughter languages, and 'inherited from Proto-Germanic' is the right relation to assert for Old High German, which continues the Proto-Germanic system through West Germanic. Class VII does complicate what the classes are, since it was originally defined by reduplication rather than by an ablaut series, but it does not complicate the number: the handbooks count it as the seventh and reconstruct all seven for Proto-Germanic, and all seven are preserved in the first attested Germanic languages including Old High German.

- Wikipedia, "Germanic strong verb", citing Ringe (2017) <https://en.wikipedia.org/wiki/Germanic_strong_verb>
  > Proto-Germanic had seven classes of strong verbs; classes I to VI form the past by ablaut alone, and class VII "displayed reduplication of the first consonants of the stem in the past tense" instead of, or in addition to, vowel alternation. The seven classes are well preserved in Gothic, Old English, Old Norse and Old High German.
- Linguistics Research Center, University of Texas, "A Grammar of Proto-Germanic: Inflection" <https://lrc.la.utexas.edu/books/pgmc/3-inflection>
  > Presents the Proto-Germanic strong verb as a system of seven classes, with reduplication as the marker of the seventh, retained systematically only in Gothic.

**E9 · line 157** · confidence high

> organized by their ablaut patterns

True of six of the seven classes and standard shorthand for all seven. Classes I to VI are ablaut series in the strict sense. Class VII was originally the reduplicating class, so strictly it is organized by its preterite formation rather than by an ablaut series, though in Northwest Germanic, and therefore in Old High German, reduplication collapsed into what looks like an ablaut pattern of its own. I decline to raise the class VII qualification as a finding here for two reasons: it is a specialist's caveat that changes nothing a reader takes away, and the identical claim is stated first at line 152 and owned by D9, so a fix belongs there rather than in two places.

*Assumes.* Assumes D9's verdict on the identical claim at line 152 ("strong classes are organized by ablaut patterns"). If D9 proposes a class VII qualification there, this sentence should track it rather than be corrected independently.

- Wikipedia, "Germanic strong verb" <https://en.wikipedia.org/wiki/Germanic_strong_verb>
  > Classes I to VI form the past tense by ablaut alone; class VII used reduplication as an alternative mechanism, so ablaut alone does not define all seven classes.
- Search synthesis on Northwest Germanic class VII <https://www.jstor.org/stable/40849304>
  > Class VII of Northwest Germanic is discussed under the heading "From Reduplication to Ablaut", i.e. the reduplicated preterites were reanalyzed into vowel alternations in the northwest, which is the shape Old High German inherits.

**E10 · line 157** · confidence high

> Some verbs shifted classes; others became weak.

Both halves are standard history. Once the ablaut system stopped being productive, speakers lost the sense of the classes as classes, verbs were rebuilt on the model of neighbouring classes, and the weak pattern absorbed the rest. The essay states it in exactly the two clauses the handbooks use.

*Assumes.* Assumes D15's verdict on "many originally strong verbs eventually became weak" at line 155. My verdict does not depend on which way D15 goes, since this row would stand or fall with it.

- Wikipedia, "Germanic strong verb" <https://en.wikipedia.org/wiki/Germanic_strong_verb>
  > "Once the ablaut system ceased to be productive, there was a decline in the speakers' awareness of the regularity of the system. That led to anomalous forms and the six big classes lost their cohesion." It gives help / holp / holpen becoming help / helped / helped as an instance of a strong verb going weak.
- Nowak, work on an eighth German Ablautreihe (search synthesis) <https://uni-koeln.academia.edu/JessicaNowak/Books>
  > Argues for an additional New High German ablaut series arisen through analogical processes comparable to those that produced classes 6 and 7, i.e. class membership in German has been reorganized by analogy rather than staying fixed.

**E11 · line 157** · confidence high

> The original phonological conditioning that determined class membership became opaque as sound changes altered vowels.

Correct, and correctly stated. What put a Proto-Germanic strong verb in one class rather than another was the shape of what followed the root vowel: a glide, a nasal or liquid plus consonant, a bare sonorant, an obstruent. Later vowel changes, umlaut and lengthening and the New High German diphthongizations among them, buried that conditioning. The only slight compression is that opacity came from the loss of productivity as well as from the vowels, which the very next clause of the essay effectively concedes.

- Wikipedia, "Germanic strong verb" <https://en.wikipedia.org/wiki/Germanic_strong_verb>
  > Class membership was determined by "the type of consonants that follow the vowel", and once the ablaut system ceased to be productive the classes "lost their cohesion" and anomalous forms arose.

**R2b · line 92** · confidence high

> it became Proto-Germanic *þeudō, then Old English þēod ("nation")

Both forms and the gloss are right. Proto-Germanic *þeudō 'people' is the regular reflex of *tewtéh₂, and Old English þēod 'people, nation' is its regular Old English continuation. Confirmed strictly as forms and glosses. The word 'then', which turns two cognate reflexes into a chain leading onward to German Deutsch, is the defect, and the inventory assigns that clause to R2c, where I raise it.

*Assumes.* Assumes R2a's reconstruction of *tewtéh₂ stands as a form, which it does; my hedging finding on R2a concerns only the further derivation from *tew-, not the reconstruction itself.

- Wiktionary, Reconstruction:Proto-Indo-European/tewtéh₂, descendants <https://en.wiktionary.org/wiki/Reconstruction:Proto-Indo-European/tewt%C3%A9h%E2%82%82>
  > Lists Proto-Germanic *þeudō among the direct descendants of *tewtéh₂, alongside Proto-Italic *toutā and Proto-Celtic *toutā.
- Etymologisches Wörterbuch des Deutschen, s.v. deutsch (DWDS) <https://www.dwds.de/wb/deutsch>
  > Derives the whole family from "germ. *þeuðō 'Volk'" and lists the -isk- adjectives built on it across West Germanic, including Old Saxon thiudisc and Middle Dutch duutsc, which presupposes the *þeudō noun as the shared Germanic base.

**R2d · line 92** · confidence high

> The Haudenosaunee, whom Europeans called the Iroquois, named themselves "people of the long house"

The gloss the essay gives is the one the Haudenosaunee use of themselves and the one reference works give. Iroquoianists and the Confederacy's own materials note that the underlying form is verbal, so a more literal rendering is 'they are building a longhouse' or 'people who build a house', which is a translation nicety rather than a different meaning: the longhouse and the people living in it are what the name names either way. The exonym half is right too, Iroquois having reached English through French. Since the sentence is doing service as an example of an autonym built on 'the people', and 'people of the long house' contains exactly that element, it does the job it is asked to do.

- Haudenosaunee Confederacy, "Who We Are" <https://www.haudenosauneeconfederacy.com/who-we-are/>
  > Gives the meaning of Haudenosaunee as 'people who build a house' and renders it in English as 'People of the Longhouse', referring to the longhouses that housed extended families.
- Britannica, "Haudenosaunee Confederacy" and Britannica Kids, "Haudenosaunee" <https://www.britannica.com/topic/Haudenosaunee-Confederacy>
  > Haudenosaunee is an Iroquoian term meaning 'people building the longhouse', with some sources giving the more literal 'They Are Building A Longhouse'; the longhouse is the traditional dwelling of extended families and a symbol of the Confederacy.

**R2e · line 92** · confidence high

> Autonyms often incorporate the concept of "the people"

Hedged with 'often' and true as hedged. The pattern is a commonplace of the ethnonymic literature, with Anishinaabe, Lenape and Diné as the standard examples, and the term autonym itself entered linguistics from Matisoff, who described the tendency of in-groups to identify themselves with humanity in general. The unhedged version of this claim, that every group calls itself 'the people', is the folk overstatement, and the essay does not make it.

- Wikipedia, "Endonym and exonym" / "Autonym" <https://en.wikipedia.org/wiki/Endonym_and_exonym>
  > Attributes the term autonym in linguistics to James Matisoff, who described the "egocentric" tendency of in-groups to identify themselves with mankind in general; gives Anishinabe, Lenape and Diné as examples of autonyms meaning 'the people' or 'the original people', called "a common theme in many places".

**R7 · line 119** · confidence high

> the present stem might use e-grade while the perfect used o-grade; the zero-grade appeared in certain suffixes and in unstressed positions

This is the standard account, and the hedging verb 'might' is correctly placed, since present formations vary while the perfect's pattern is the fixed one. The PIE perfect shows o-grade in the singular and zero grade in the non-singular, with reduplication; the ordinary thematic present has a full-grade root. The link between zero grade and lack of accent is exactly the generalization the handbooks draw. The only compression is that the essay does not mention the perfect's singular-versus-plural split, which is not an error in a sentence introduced by 'For example'.

*Assumes.* Assumes R6's grade inventory stands. My R6 finding concerns only the fifth cited form, not the existence or definition of the grades this row describes.

- Wiktionary, Appendix:Proto-Indo-European verbs <https://en.wiktionary.org/wiki/Appendix:Proto-Indo-European_verbs>
  > The perfect shows "o-grade in the singular and zero grade in the nonsingular", and reduplicates by repeating the first consonant of the root with -e- between. The normal thematic present has a full-grade root with the accent on the root, while the tudáti type shows a zero-grade root with the accent on the thematic vowel.
- Kloekhorst, "The origin of the Proto-Indo-European nominal accent-ablaut paradigms" <https://www.kloekhorst.nl/KloekhorstOriginNominalAccentAblautParadigmsMS.pdf>
  > In the accent-ablaut paradigms, exactly one morpheme is accented and shows e-grade while all other morphemes are unaccented and show zero-grade, e.g. *h₁és-ti against *h₁s-énti.

### Cluster F: Tense-building

**F1 · line 158** · confidence high

> the development of the ~perfect tense~ using the auxiliaries ~haben~ (to have) and ~sein~ (to be) with the past participle

The claim as written is that German developed a periphrastic perfect built on two auxiliaries plus the past participle. That is uncontroversial and is what every handbook and every pedagogical grammar describes. The brief asks whether the essay's silence on WHICH verbs take sein leaves the claim true, and it does: the sentence asserts that both auxiliaries are used, not that either is used everywhere, and the two examples on lines 160 and 161 immediately instantiate the split, with a transitive taking haben and a verb of motion taking sein. Adding the unaccusative/motion/change-of-state rule would make the sentence more informative but would not change its truth value, and the rule is genuinely messier than a one-clause statement of it would suggest: Gillmann's corpus work shows transitivity is a stable predictor of haben across the whole history of German while auxiliary selection among intransitives has been repeatedly reorganised, and manner-of-motion verbs still vacillate. A flat rule inserted here would be less accurate than the current silence. Confirmed.

- Lingolia, "haben and sein as auxiliary verbs in German grammar" <https://deutsch.lingolia.com/en/grammar/verbs/sein-haben>
  > A verb takes sein in the Perfekt only when it is intransitive (no accusative object) and expresses either motion from one place to another or a change of state; otherwise the auxiliary is haben.
- Gillmann, "A usage-based perspective on change and continuity in the system of the German perfect auxiliaries haben and sein: Manner of motion and semantic transitivity", SLCS 203 (Benjamins) <https://benjamins.com/catalog/slcs.203.09gil>
  > Transitivity is a stable predictor of haben selection throughout the history of German, whereas auxiliary selection with intransitive verbs has been partly reorganised; the sein perfect became productive within the intransitive manner-of-motion group at the expense of telicity, an abstract schema linking manner-of-motion semantics to sein having evolved on the model of high-frequency verbs such as gehen.

**F2 · line 158** · confidence medium

> This periphrasis, which began in Old High German and became fully established in Middle High German

Both halves match the handbook account of the construction's rise as a form. The perfect begins to grammaticalize out of resultatives in Old High German: the participle in Tatian still carries adjectival case and gender agreement with the object (phīgboum habeta sum giflanzotan, Tatian 102,2), and in Otfrid, around 865, that adjectival marking survives only three times in the whole text, the rest of the instances being uninflected. By Middle High German the participle no longer agrees and the perfect stands beside the pluperfect and the future as one of three settled auxiliary-built tenses. I considered proposing that "fully established" belongs in Early New High German instead, because the perfect's semantic expansion out of resultative meaning and into general past reference runs on through 1450 and beyond, and because MHG uses all three periphrastic tenses far less often than the modern language does. I decided against it. The essay's own next paragraph handles that later expansion separately, as the displacement of the preterite, so "fully established" here reads as a claim about the form becoming a fixed part of the grammar rather than about it reaching modern frequency. Judged that way it is right, and a finding would be arguing about the referent of "established" rather than about a fact. Depends on E1 for the Old High German dating.

*Assumes.* Assumes cluster E confirms E1, that Old High German runs roughly 750 to 1050. If E moves the OHG/MHG boundary, F2's two-stage story moves with it but its shape does not change.

- Wikipedia, "Old High German", periphrastic perfect <https://en.wikipedia.org/wiki/Old_High_German>
  > In the early periphrastic perfect the past participle retained its original adjectival function and showed case and gender endings, nominative for intransitives and accusative for transitives, as in phīgboum habeta sum giflanzotan (Tatian 102,2); in Otfrid this adjectival mark appears just three times in the whole text while the other instances show no adjectival ending, and in time these endings fell out of use and the participle came to be seen as part of the verb.
- "Toward the German Present Perfect as an Emergent Structure" <https://www.researchgate.net/publication/343162714_Toward_the_German_Present_Perfect_as_an_Emergent_Structure>
  > The perfect does not begin to grammaticalize from resultative constructions until the Old High German period; the present perfect originated from an adjectival structure and had evolved into a periphrastic form by the ninth century, as evidenced in Otfrid's Gospel of about 865, and its development from Old High German through Early New High German is a gradual expansion from original resultative meaning to more general past reference.
- Wikipedia, "Middle High German verbs" <https://en.wikipedia.org/wiki/Middle_High_German_verbs>
  > Middle High German had three tenses that made use of auxiliary verbs, perfect, pluperfect and future, all much less frequently used than in the modern language.

**F3 · line 158** · confidence high

> Middle High German (1050–1350)

1050 to 1350 is the standard periodization, the one Paul's Mittelhochdeutsche Grammatik and the general reference works use, with the internal subdivision early MHG about 1050 to 1170, classical MHG about 1170 to 1250, late MHG about 1250 to 1350. Some usages stretch the upper boundary to 1500, folding in what is otherwise called Early New High German, but 1350 is the majority convention and the one that pairs correctly with the essay's Old High German end date of 1050. The en dash in "1050–1350" is a numeric range, which the house style doc explicitly permits.

*Assumes.* Assumes cluster E confirms E1's Old High German end date of 1050, since the two periodizations abut.

- Wikipedia, "Middle High German" <https://en.wikipedia.org/wiki/Middle_High_German>
  > Middle High German is the German language between 1050 and 1350; in some uses the term covers a longer period, up to 1500. The period is subdivided into early MHG (c. 1050–1170), classical MHG (c. 1170–1250) and late MHG (c. 1250–1350).
- Hermann Paul, Mittelhochdeutsche Grammatik, 23rd ed., rev. Wiehl and Grosse, Tübingen 1989 <https://books.google.com/books/about/Mittelhochdeutsche_Grammatik.html?id=Ph96AAAAIAAJ>
  > The standard reference grammar for the period, which takes Middle High German as the German of roughly 1050 to 1350.

**F4 · line 160–161** · confidence high

> 🇩🇪 Ich habe $gesUngen$ (I have $sUng$) / 🇩🇪 Ich bin gekommen (I have come / I $cAme$)

Both German sentences are well formed and both are correctly chosen for the job the paragraph gives them. Singen is transitive-pattern and takes haben; kommen is an intransitive verb of directed motion and takes sein, so the pair does exactly the illustrative work the haben/sein claim in F1 needs. The English glosses are right, and the second gloss usefully offers both "I have come" and "I came", which is the honest rendering, since the German Perfekt covers ground that English splits between its present perfect and its simple past. The capitalization inside the three $…$ spans is Phase 3's business, not mine, and none of the three spans opens a sentence, so the leading-capital hazard does not arise here.

*Assumes.* Depends on F1, which I own and confirm.

- Lingolia, "haben and sein as auxiliary verbs in German grammar" <https://deutsch.lingolia.com/en/grammar/verbs/sein-haben>
  > Verbs of motion from one place to another, such as kommen and gehen, form the Perfekt with sein; verbs taking an accusative object form it with haben.

**F5 · line 163** · confidence high

> In modern spoken German, this perfect construction has largely replaced the simple preterite in everyday speech, particularly in southern dialects

This is the oberdeutscher Präteritumschwund, and the essay describes it correctly without naming it. Fischer's 2018 documentation finds a north-south gradient across the whole German-speaking area: the further north the dialect region, the more verbs form a preterite at all and the more often those forms are actually used. In Upper German the loss is at or near total, and in High Alemannic Swiss German the preterite has been replaced by the perfect outright. The brief warns that this sentence may fail in opposite directions on its two halves, understating the south while overstating the north, and I tested it that way. It survives, for two reasons. "Largely replaced ... in everyday speech" is accurate for spoken German generally, not just the south: the perfect dominates spoken narrative across the area, and Fischer's explanation of the whole change is perfect expansion, the perfect encroaching semantically on preterite territory. And "particularly in southern dialects" is a gradient word, not a hedge that misrepresents the consensus. Read alone it does understate how categorical Alemannic is, but it is not read alone: the very next sentence, F6, supplies the north and the high-frequency verbs. Flagging this would be correcting a correct sentence for lacking a superlative.

- Hanna Fischer, Präteritumschwund im Deutschen. Dokumentation und Erklärung eines Verdrängungsprozesses, Studia Linguistica Germanica 132 (De Gruyter 2018), as reported in the ZRS review <https://www.degruyterbrill.com/document/doi/10.1515/zrs-2020-2061/html>
  > There is a north-south gradient across the German-speaking area: the further north the dialect region, the more verbs form the preterite and the more frequently those preterite forms are used. Fischer explains the change as perfect expansion, the perfect penetrating the meaning areas of the preterite by semantic expansion and successively displacing it. Her Wenker-based remapping shows a threefold division with a broad transitional zone between south and north.
- German Wikipedia, "Oberdeutscher Präteritumschwund" <https://de.wikipedia.org/wiki/Oberdeutscher_Pr%C3%A4teritumschwund>
  > The synthetic preterite (ich ging) is replaced by the analytic perfect (ich bin gegangen) in the Upper German dialects, Alemannic and Bavarian, and in some Central German dialects. "In gewissen Regionen dieses Sprachraums besitzen zwar die Kopula sein sowie einige Hilfs- und Modalverben noch einfache Vergangenheitsformen"; in Alemannic Swiss German the preterite has been completely replaced. Lindgren dates the retreat from the thirteenth century; Jörg puts the High Alemannic process chiefly in the sixteenth.

**F6 · line 163** · confidence high

> The preterite survives primarily in writing, in northern dialects, and with high-frequency verbs.

Three claims in one clause, and each holds separately. Writing: the synthetic preterite remains the narrative past of written German, which is the standard descriptive statement and the counterpart of the perfect's dominance in speech. Northern dialects: Low German and northern German dialects traditionally maintain a fully developed preterite paradigm, and Fischer's gradient is explicitly that preterite-forming verbs and preterite token frequency both increase northward. High-frequency verbs: Fischer establishes an implicational hierarchy in which the preterite of sein is best preserved, followed by the modal and auxiliary verbs, while the weak verbs are displaced first, which is the frequency effect the essay names. The one thing a specialist could press is that the Präteritalgrenze is not a line but a broad transitional zone that widens westward, and that standard-language influence is currently re-establishing preterite forms in some Alemannic dialects. Neither undercuts a coarse three-part summary sentence. Confirmed on all three.

*Assumes.* Depends on F5, which I own and confirm.

- Hanna Fischer, Präteritumschwund im Deutschen (De Gruyter 2018), as reported in the ZRS review <https://www.degruyterbrill.com/document/doi/10.1515/zrs-2020-2061/html>
  > A hierarchy governs the loss: preterite forms of sein are best preserved, followed by the modal and auxiliary verbs, while preterite forms of weak verbs are the first to be displaced by perfect forms. The areal distribution shows a threefold division with a broad transitional zone between south and north.
- Fischer, "The Präteritumschwund in German dialects: How to get lost", SLCS 207 (Benjamins), and associated literature on Low German tense usage <https://benjamins.com/catalog/slcs.207.07fis>
  > The loss of the preterite is a frequency-driven process modulated by morphological, syntactic and semantic properties of the verb; contemporary Low German dialects retain the preterite, with modern Platt tense usage still matching the Middle High German preterite/perfect distribution.

**F7 · line 164** · confidence high

> Old High German expressed future time primarily through the present tense with temporal adverbs

Germanic inherited no future tense, and Old High German has none: futurity is carried by the present, disambiguated where necessary by adverbs and other lexical time expressions. The word doing the work in the essay's sentence is "primarily", and it is the right word, because Old High German also had modal periphrases available, chiefly sculan and wellen with the infinitive, and those are the constructions that Middle High German inherits as werden's competitors. Had the sentence said "only", it would be wrong. It does not. Confirmed.

*Assumes.* Assumes cluster E confirms E1's Old High German period. Nothing in F7 turns on the exact boundary years.

- OUP Blog, "The future is in the past" (Anatoly Liberman) <https://blog.oup.com/2021/03/the-future-is-in-the-past/>
  > Unlike Greek and Latin, Germanic had no future tense.
- "On the degree of study of the category of future tense in Germanic languages", European Journal of Natural History <https://world-science.ru/en/article/view?id=34178>
  > In the early period of German there were two tense forms, preterite and present, the present being widely used to express future events; Gothic, Old Icelandic and Old High German expressed futurity indirectly through modal combinations such as willan plus infinitive, and through lexical means, adverbs and nouns with temporal meaning.

**F9 · line 166** · confidence high

> 🇩🇪 Ich werde singen (I will sing)

Correct German and a correct gloss. Werde is the first singular present of werden, singen is the bare infinitive, and the pair is the standard Futur I. The example is also the right one for the paragraph, since it shows the infinitive construction rather than the present participle one that lost out. No conjugation span, so no capitalization hazard.

*Assumes.* Depends on F8, which I own. My F8 finding is about dating, not about the construction, so F9 stands either way.

- Wiktionary, "werden" <https://en.wiktionary.org/wiki/werden>
  > werden with a bare infinitive forms the German future; the use as a future auxiliary is described as a Middle High German innovation, with the participle giving way to the infinitive from the fourteenth century, probably by analogy with the older future auxiliaries wollen and sollen.

**F10 · line 168** · confidence medium

> This created a three-way temporal system (present, preterite/perfect, future) from the original two-tense Proto-Germanic system

The brief asks two things: whether "three-way temporal system" can coexist with the essay's own later claim of two morphological tenses, and whether "preterite/perfect" is defensible as a single slot. Both survive. On the first, there is no contradiction because F11, the very next clause, states the reconciliation explicitly: the third slot arrived by periphrasis and not by new morphology, so the count of morphological tenses is untouched. Agent H should not read these as conflicting. On the second, collapsing preterite and perfect into one past slot is the standard descriptive move for German, and it is the move Fischer's whole account presupposes: the two forms compete for the same temporal territory, their distribution governed by region, register and verb frequency rather than by a difference in time reference. The real compression is elsewhere and I decided it is not worth a finding: German also built a pluperfect and a future perfect out of the same periphrastic machinery, so the modern paradigm is usually counted as six tenses rather than three. But the essay is claiming a three-way division of time reference, not a count of forms, and on that reading it is right. Depends on D5.

*Assumes.* Assumes cluster D confirms D5, that Germanic was left with exactly two tenses, present and preterite. If D finds D5 needs hedging, the phrase "from the original two-tense Proto-Germanic system" inherits that hedge.

- Hanna Fischer, Präteritumschwund im Deutschen (De Gruyter 2018), as reported in the ZRS review <https://www.degruyterbrill.com/document/doi/10.1515/zrs-2020-2061/html>
  > The change is analysed as perfect expansion, the perfect penetrating the meaning areas of the preterite and successively displacing it, which presupposes that the two forms occupy one past-reference domain rather than contrasting temporally.
- Wikipedia, "Middle High German verbs" <https://en.wikipedia.org/wiki/Middle_High_German_verbs>
  > Alongside the two inherited synthetic tenses, Middle High German had three tenses formed with auxiliaries, perfect, pluperfect and future, all used much less than in the modern language.

**F11 · line 168** · confidence high

> though notably through periphrasis rather than new morphological conjugations of the verb itself

True and load-bearing. Every tense German added after the two it inherited is built from an auxiliary plus a non-finite form: haben or sein plus the past participle for the perfect and pluperfect, werden plus the infinitive for the future. No new synthetic paradigm was created, and the finite verb in all of these is the auxiliary. This clause is also what keeps F10 from contradicting G7's "two morphological tenses", which makes it the most useful sentence in the section and one that should not be touched.

*Assumes.* Depends on F10, which I own and confirm.

- Wikipedia, "Middle High German verbs" <https://en.wikipedia.org/wiki/Middle_High_German_verbs>
  > The periphrastic tenses were formed by combining the present or preterite of an auxiliary verb with the past participle or, for the future, with the infinitive; the past participle can be used as part of a verbal phrase to form the perfect and pluperfect.
- Valentina Concu, Journal of Germanic Linguistics, on werden plus infinitive <https://www.cambridge.org/core/journals/journal-of-germanic-linguistics/article/abs/werden-and-periphrases-with-present-participles-and-infinitives-a-diachronic-corpus-analysis/E58A413B850282E1738A3C01118520C0>
  > The modern German periphrastic future is werden plus infinitive, an auxiliary construction rather than an inflectional form.

**F12 · line 169** · confidence high

> verbs whose present-tense conjugations derive historically from Proto-Germanic strong preterites

This is the standard definition, stated at the right level of abstraction. The deeper history is that the present of a preterite-present continues the Proto-Indo-European perfect, and that the PIE perfect is also what became the Germanic strong preterite everywhere else; so "derive from Proto-Germanic strong preterites" is the conventional shorthand and is accurate as a statement about the Proto-Germanic stage, which is the stage the essay names. It also earns its keep, because it is what explains the two oddities the essay goes on to list in F15 and F16: kann shows both the vowel alternation and the absent personal ending that would mark a strong preterite, while its own past, konnte, had to be built fresh with the weak dental suffix. Depends on D3.

*Assumes.* Assumes cluster D confirms D3, that the old PIE perfect was repurposed as the Germanic preterite. F12 is the same claim seen from the other end, so if D3 needs hedging F12 inherits it.

- Wikipedia, "Germanic verb", preterite-presents <https://en.wikipedia.org/wiki/Germanic_verb>
  > Preterite-present verbs are a small group of originally perfect verbs whose present-tense forms appear like the past-tense forms of strong verbs; the present has the form of a vocalic (strong) preterite, with vowel alternation between singular and plural. On the widely held view they derive from the Proto-Indo-European perfect, which usually developed into a Germanic past tense but here evolved into a present. Kann displays the vowel change and lack of a personal ending that would otherwise mark a strong preterite, while konnte displays the dental suffix of the weak preterites.

**F14 · line 169** · confidence high

> The glosses: können "(can)", müssen "(must)", dürfen "(may)", sollen "(shall)", mögen "(may/like)", wissen "(to know)"

Every gloss is a defensible one-word English equivalent, and five of the six are also the etymological cognate, which suits an essay about descent: können/can, müssen/must, sollen/shall, mögen/may, wissen/wit and know. Two things a reader might trip on, neither of them an error. "May" is given for both dürfen and mögen, but it is correct for both, dürfen for permission and mögen for the epistemic and concessive use in es mag sein, and the double gloss for mögen, "may/like", is what disambiguates. And "shall" for sollen is the cognate and the older sense rather than the everyday modern one, which is nearer "be supposed to"; in a historical section that choice reads as deliberate. The only inconsistency is formatting, wissen alone getting the infinitive marker "to know" where the others are bare, and that is an editor's call rather than a fact. Confirmed. Note that the replacement prose proposed at F13 carries all six glosses through unchanged.

*Assumes.* Depends on F13, which I own. The F13 finding is about the label "modal verbs", not about the glosses, so F14 stands under either outcome.

- German Wikipedia, "Präteritopräsens" <https://de.wikipedia.org/wiki/Pr%C3%A4teritopr%C3%A4sens>
  > Treats wissen as the one full verb of the class, semantically "to know", and the other five as modals with permission, ability, obligation and volitional-adjacent meanings.
- Wikipedia, "Germanic verb", preterite-presents <https://en.wikipedia.org/wiki/Germanic_verb>
  > Glosses kann as "can, am/is able to" and pairs the Germanic preterite-presents with their English cognates, which are themselves the English preterite-present modals.

**F15 · line 171** · confidence high

> with no endings in 1s and 3s (ich $kAnN$, er $kAnN$)

True of all six verbs named, without exception: ich kann/er kann, ich muss/er muss, ich darf/er darf, ich soll/er soll, ich mag/er mag, ich weiß/er weiß. Against the ordinary pattern this is doubly marked, since a regular German verb takes -e in the first singular and -t in the third, so both slots are bare here rather than one. The brief asks whether the essay lets a reader connect the fact to its cause, and it does, though obliquely: the endinglessness IS the old strong preterite's endinglessness, and the sentence's own closing clause, "reflects their origin as old preterite conjugations that were reanalyzed as presents", supplies exactly that link without spelling out the mechanism. Naming the mechanism would help, but its absence is not an error. The one thing I would not defend is the $kAnN$ span itself, whose final capital N claims an irregularity that is hard to derive; that was already routed to Phase 3 by the Phase 0 notes and is not mine.

*Assumes.* Depends on F12, which I own and confirm.

- German Wikipedia, "Präteritopräsens" <https://de.wikipedia.org/wiki/Pr%C3%A4teritopr%C3%A4sens>
  > Lists among the group's morphological features "fehlende Endung -t in der 3. Person Singular im Präsens Indikativ", the missing third-singular -t of the present indicative.
- Wikipedia, "Germanic verb", preterite-presents <https://en.wikipedia.org/wiki/Germanic_verb>
  > Kann displays the vowel change and the lack of a personal ending that would otherwise mark a strong preterite, while konnte displays the dental suffix of the weak preterites.

### Cluster G: Modern German

**G1 · line 172** · confidence high

> Old High German had a fully functional subjunctive mood in both present and preterite

The Old High German verb inflects for two synthetic tenses (present and preterite) in three moods (indicative, subjunctive, imperative), and the subjunctive is fully inflected in both tenses: present subjunctive nëme, nëmēs, nëme, nëmēm, nëmēt, nëmēn against indicative nimu, nimis, nimit; preterite subjunctive nāmi, nāmīs, nāmi (with the umlaut-triggering -i- that later yields käme) against indicative nam, nāmi, nam. 'Fully functional' also holds on the usage side: the OHG subjunctive carries both the volitive range (wish, command) and the potential range (possibility, reported speech, unreal condition), which is the standard two-way description of Germanic and German subjunctive function. Nothing in the claim is contested, and the essay is not claiming the OHG subjunctive continues the PIE subjunctive rather than the optative, which is D6's question and not stated here.

- Braune/Reiffenstein, Althochdeutsche Grammatik I, Laut- und Formenlehre, verb chapter, as summarized in teaching material derived from it <https://www.researchgate.net/publication/261898887_Althochdeutsche_Grammatik_I_Laut-_und_Formenlehre_15_Aufl_by_Wilhelm_Braune_Ingo_Reiffenstein_Althochdeutsche_Grammatik_II_by_Richard_Schrodt>
  > Old High German has two synthetic tenses, present and preterite, and three moods, indicative, subjunctive and imperative; in the use of the Germanic and German subjunctive two main types are distinguished, the volitive subjunctive expressing wish or command and the potential subjunctive designating a possibility or something merely thought
- grammis (Leibniz-Institut für Deutsche Sprache), Systematische Grammatik, 'Formenbestand' <https://grammis.ids-mannheim.de/systematische-grammatik/439>
  > 'Indikativ wie Konjunktiv haben Personalformen für Präsens und Präteritum', i.e. the indicative and the subjunctive each have a complete personal paradigm in present and preterite; the page describes pairing a full subjunctive paradigm against the indicative paradigm of every verb

**G2 · line 172** · confidence high

> as vowel distinctions reduced and the subjunctive conjugations became identical to the indicative in many verbs

Judged as written, including 'in many verbs', this is the standard account and the mechanism named is the right one. The IDS systematic grammar states flatly that for the entire weak paradigm the indicative and subjunctive preterite are homographic and homophonic, and that in the present subjunctive the first person singular and all plural forms coincide with the indicative. Both syncretisms are products of exactly what the essay names: the OHG endings that kept the moods apart were vowel-quality distinctions in unstressed syllables (present indicative 1sg -u against subjunctive -e; weak preterite indicative -a, -ōs, -a against subjunctive -i, -īs, -i), and Middle High German Nebensilbenabschwächung collapsed all of them to schwa, giving machte = machte and ich nehme = ich nehme. Which half the cause explains, since the brief asks: it explains the weak verbs, whose whole Konjunktiv II is homophonous with the preterite indicative, and the syncretic slots of Konjunktiv I in every verb. It does not explain the retreat of the strong verbs' Konjunktiv II, which stayed formally distinct through umlaut (käme against kam, hülfe against half) and nonetheless gave ground to würde. That retreat is driven by low token frequency and stylistic markedness rather than by homophony, and Duden's own list of forms fit for replacement is headed by hülfe and gälte, which are distinct but archaic-sounding. The essay does not claim its cause is the only one, and the hedge 'in many verbs' is accurate rather than evasive, so this is not a finding. The tension it creates with the essay's own käme example is real, and it is reported under G4.

*Assumes.* Assumes G1's verdict, that the OHG subjunctive was fully inflected in present and preterite, which I own and confirm.

- grammis (IDS Mannheim), Systematische Grammatik, 'Formensynkretismus von Konjunktiv und Indikativ' <https://grammis.ids-mannheim.de/systematische-grammatik/315>
  > 'Beim gesamten Paradigma der schwachen Verben sind Indikativ und Konjunktiv homograph und homophon'; in the present subjunctive the 1st person singular and all plural forms are 'sowohl homograph als auch homophon' with the indicative; where mood marking is obligatory speakers 'stets auf distinkte Konjunktiv-Präteritum-Formen oder die würde-Form ausweichen'
- Duden, Sprachratgeber, 'Konjunktiv II oder „würde“-Form?' <https://www.duden.de/sprachwissen/sprachratgeber/Konjunktiv-2-oder-w%C3%BCrde-Form>
  > 'Der Konjunktiv II wird häufig dann durch würde + Infinitiv ersetzt, wenn er mit der Form des Indikativs Präteritum übereinstimmt', which applies to all weak-verb Konjunktiv-II forms and to the wir/sie forms of strong verbs with i or ie; separately, würde may replace forms that merely sound archaic, such as hülfe and gälte/gölte

**G3 · line 172** · confidence high

> speakers increasingly used periphrastic constructions with ~würde~ (would) + infinitive to express what the old synthetic subjunctive once conveyed

This is the standard account in the reference grammars and the essay states it with the right shape: 'increasingly used', not 'replaced'. The IDS grammar describes the würde-form as what speakers switch to when the synthetic form is not recognizable as a subjunctive, and Duden describes würde + infinitive as the ordinary substitute for a Konjunktiv II that coincides with the preterite indicative. The functional description is also right: würde + infinitive takes over the work of the old synthetic Konjunktiv II rather than adding a meaning of its own. The gloss 'würde (would)' is a functional equivalence rather than an etymological one, since würde is itself the Konjunktiv II of werden, but the essay is glossing for a learner and 'would' is what the form does.

*Assumes.* Assumes G2, which I own and confirm.

- grammis (IDS Mannheim), Systematische Grammatik, 'Formensynkretismus von Konjunktiv und Indikativ' <https://grammis.ids-mannheim.de/systematische-grammatik/315>
  > Because syncretism obscures the mood distinction, in text types where indirect speech must be marked speakers always fall back on distinct Konjunktiv-Präteritum forms or on the würde-form
- Duden, Sprachratgeber, 'Konjunktiv II oder „würde“-Form?' <https://www.duden.de/sprachwissen/sprachratgeber/Konjunktiv-2-oder-w%C3%BCrde-Form>
  > The würde-construction is used ever more frequently because numerous Konjunktiv-II forms are not identifiable as subjunctives; it substitutes for the synthetic form rather than carrying a distinct meaning

**G5 · line 175** · confidence high

> 🇩🇪 Modern alternative: Wenn ich kommen $wÜrde$... (If I $wOUld$ come...)

Wenn ich kommen würde is well-formed and thoroughly current German, and 'Modern alternative' describes it accurately: it is an alternative rather than a replacement, which is what the sources support. Two things I considered and decided are not findings. First, the English gloss 'If I would come' is not idiomatic English in a conditional protasis, but it is a deliberate word-by-word gloss whose job is to show the periphrasis, and the essay glosses käme idiomatically as 'If I came' immediately above, so the contrast is legible. Second, German usage guides discourage the würde-form inside the wenn-clause, especially when the main clause also has one, but the essay is describing what speakers do rather than recommending it, and descriptively the construction is extremely common. The label 'Modern alternative' survives unchanged even under G4's proposed fix, since a synthetic form and a modern periphrastic alternative are a coherent pair.

*Assumes.* Assumes G3, which I own and confirm.

- Duden, Sprachratgeber, 'Konjunktiv II oder „würde“-Form?' <https://www.duden.de/sprachwissen/sprachratgeber/Konjunktiv-2-oder-w%C3%BCrde-Form>
  > The würde-construction is used ever more frequently, and it is the ordinary substitute where the synthetic Konjunktiv II coincides with the preterite indicative or sounds archaic; it is presented as an available variant of the synthetic form, not as its successor

**G6 · line 177** · confidence high

> the $wÜrde$ construction increasingly replaces synthetic subjunctive conjugations except for common verbs and in formal registers

Both exceptions are right, and this is the row where the temptation is to correct a careful sentence into a wrong one. 'Common verbs': Duden names the survivors and they are exactly the high-frequency ones, hätte, wäre, käme, ginge, gäbe, könnte, wüsste, bliebe, brächte. 'Formal registers': the IDS grammar ties the retention of distinct synthetic forms to text types where mood marking is obligatory, which is the formal written end of the range, and the modals' Konjunktiv II is standard there. 'Increasingly replaces' is also correctly aspectual: the process is ongoing rather than complete. I checked whether the sentence understates the extent of the spread, since some sources report würde-forms dominating Konjunktiv-II tokens in speech, and concluded it does not, because the two exceptions the essay names are precisely the two environments those studies find the synthetic form holding. The only refinement a specialist would add is that the retreat is also governed by the individual form's frequency and by whether it sounds archaic, which the essay's 'common verbs' already half captures.

*Assumes.* Assumes G3, which I own and confirm.

- Duden, Sprachratgeber, 'Konjunktiv II oder „würde“-Form?' <https://www.duden.de/sprachwissen/sprachratgeber/Konjunktiv-2-oder-w%C3%BCrde-Form>
  > Konjunktiv II is often replaced by würde + infinitive where it coincides with the preterite indicative, which covers all weak verbs and the wir/sie forms of strong verbs in i or ie; for a set of strong verbs the Konjunktiv-II form is 'sehr gebräuchlich', and archaic-seeming forms such as hülfe are the ones the würde-construction stands in for
- grammis (IDS Mannheim), Systematische Grammatik, 'Formensynkretismus von Konjunktiv und Indikativ' <https://grammis.ids-mannheim.de/systematische-grammatik/315>
  > In text types where indirect speech must be marked, speakers always fall back on distinct Konjunktiv-Präteritum forms or on the würde-form, which locates the surviving synthetic forms in the register the essay calls formal

**G7 · line 178** · confidence high

> Modern German retains the essential architecture established in Proto-Germanic: two morphological tenses (present and preterite), strong verbs with ablaut, weak verbs with a dental suffix, and a distinction between indicative, subjunctive, and imperative moods

Judged on its two jobs, summarizing the essay's body and being true. It summarizes accurately: the two-tense claim restates line 146, the dental suffix restates line 153, and the strong-verb ablaut restates lines 119 and 152. It is also true of modern German independently. The IDS systematic grammar states that indicative and subjunctive alike have personal forms for present and preterite and no others, which is exactly 'two morphological tenses'; everything else in the German tense system is periphrastic, as the following three bullets say. The three-mood inventory is the traditional and Duden description, and it is the same inventory the handbooks give for Old High German and Proto-Germanic. One nuance I decided against flagging: the IDS grammar organizes the paradigm around two Modi, indicative and subjunctive, with the imperative as a separate defective form class, so a very strict formalist would say two moods plus an imperative. That is a difference in exposition, not in fact, and the essay's three-way list is what every teaching grammar of German gives.

*Assumes.* Assumes D5 (Germanic reduced to two tenses) and D10 (the weak dental suffix) come back confirmed, which is what the standard handbooks say. Also assumes D6, but only weakly: whether the Germanic subjunctive arose by merger of PIE subjunctive and optative or continues the optative alone, Proto-Germanic still had exactly the three-mood inventory this sentence names, so G7 holds under either D6 verdict.

- grammis (IDS Mannheim), Systematische Grammatik, 'Formenbestand' <https://grammis.ids-mannheim.de/systematische-grammatik/439>
  > 'Indikativ wie Konjunktiv haben Personalformen für Präsens und Präteritum', i.e. the synthetic paradigm of the German verb is exhausted by present and preterite in each of the two moods, with all further tenses built periphrastically
- Braune/Reiffenstein, Althochdeutsche Grammatik I, verb chapter, as summarized in derived teaching material <https://www.researchgate.net/publication/261898887_Althochdeutsche_Grammatik_I_Laut-_und_Formenlehre_15_Aufl_by_Wilhelm_Braune_Ingo_Reiffenstein_Althochdeutsche_Grammatik_II_by_Richard_Schrodt>
  > Old High German has two synthetic tenses, present and preterite, and three moods, indicative, subjunctive and imperative, which is the same architecture the essay says modern German retains

**G9 · line 180** · confidence high

> or through verbal prefixes and particles (er $lIest$ das Buch aus = he finishes reading the book)

The German is right and the gloss is right. DWDS gives auslesen the sense 'ein längeres Druckerzeugnis zu Ende lesen' with 'ein Buch, einen Roman auslesen' as its example, which is exactly 'he finishes reading the book'. The separable aus- is a Verbpartikel, so 'prefixes and particles' names the right machinery. Two things I weighed and did not raise. DWDS marks that sense umgangssprachlich, but the essay is illustrating a morphological device rather than recommending a register, and the completive reading is uncontested. More substantively, what prefixes and particles contribute is Aktionsart, lexical aspect or telicity, rather than grammatical aspect in the narrow sense, so a specialist would file this one level down from the bullet's heading. That is the standard loose usage in descriptive and pedagogical work, which routinely calls these prefixes aspectual, and correcting it would cost more clarity than it buys. My proposed replacement for G8 preserves this clause intact, changing only its connective from 'or through' to 'or by' so that it stays parallel with the two carriers added ahead of it.

*Assumes.* Assumes G8, which I own; the clause is factually independent of G8's error and survives it.

- DWDS, Digitales Wörterbuch der deutschen Sprache, entry 'auslesen' <https://www.dwds.de/wb/auslesen>
  > Sense 1 is 'umgangssprachlich ein längeres Druckerzeugnis zu Ende lesen', with the usage example 'ein Buch, einen Roman auslesen'; sense 2 is the unrelated 'prüfend aus etwas heraussuchen'

**G10 · line 181** · confidence high

> ~Future~ is expressed with ~werden~ + infinitive

As a summary bullet restating the essay's own line 164 and 168, this is accurate, and it is true of modern German: werden + infinitive is the German future periphrasis, and there is no synthetic future. The one thing worth weighing is that German most often expresses future time with the present tense plus a temporal adverbial, and that werden + infinitive frequently carries epistemic rather than purely temporal force, so a sentence reading 'Future is expressed only with werden + infinitive' would be wrong. The bullet does not say that, and its neighbours in the list are stated with the same economy. Correcting it would be the kind of confident mistake the run's rules warn against.

*Assumes.* Assumes F8 (cluster F) settles when werden was grammaticalized as a future auxiliary. This row makes no dating claim, so it stands whatever F8 returns; only the essay's line 164 is exposed to F8.

- grammis (IDS Mannheim), Systematische Grammatik, 'Formenbestand' <https://grammis.ids-mannheim.de/systematische-grammatik/439>
  > The synthetic paradigm of the German verb covers present and preterite only, in indicative and subjunctive alike, so any future marking is necessarily periphrastic

**G11 · line 182** · confidence high

> ~Perfect~ is expressed with ~haben~/~sein~ + past participle

Accurate as a summary and true of modern German. It restates line 158 without adding anything, and the auxiliary split it names is the standard one. Since German has only two synthetic tenses, the perfect must be periphrastic, which is what the bullet says. The auxiliary selection itself, including which verbs take sein, is F1's row and I have not researched it; nothing in this bullet goes beyond what F1 covers, so a change to F1 would not require a change here.

*Assumes.* Assumes F1 (cluster F) confirms the haben/sein perfect with the past participle. If F1 finds a defect in the auxiliary account at line 158, this bullet inherits it verbatim.

- grammis (IDS Mannheim), Systematische Grammatik, 'Formenbestand' <https://grammis.ids-mannheim.de/systematische-grammatik/439>
  > Indicative and subjunctive each have personal forms for present and preterite only, so the perfect is among the periphrastic forms built on an auxiliary plus participle

**G12 · line 183** · confidence high

> ~Passive~ is expressed with ~werden~ + past participle (dynamic) or ~sein~ + past participle (stative)

This is the row the brief asked me to interrogate, and the interrogation clears it. Calling the sein-construction a passive is not merely uncontroversial in German descriptive grammar, it is the house terminology: the IDS defines sein-Passiv as a passive formed with the auxiliary sein plus the Partizip II, expressing states, and records Zustandspassiv as an equally current term for it, exactly parallel to werden-Passiv and Vorgangspassiv. The essay's glosses 'dynamic' and 'stative' translate Vorgangspassiv and Zustandspassiv precisely. There is a genuine theoretical debate, and I read it before deciding: Rapp (1996) and Maienborn (2007) argue that the so-called Zustandspassiv is always a copula construction with an adjectivized participle rather than a member of the verbal passive paradigm, and adduce comparative and superlative participles and coordination with primary adjectives as evidence. But that debate is about the internal analysis of a construction whose label and description the essay reproduces correctly from the reference grammars, and the essay makes no claim about its constituent structure. Downgrading the standard label on the strength of one side of a live theoretical dispute would be the error this run is built to avoid.

- grammis (IDS Mannheim), terminology entries 'werden-Passiv' and 'sein-Passiv' <https://grammis.ids-mannheim.de/terminologie/355>
  > 'Das sein-Passiv ist ein Passiv, das mit dem Hilfsverb sein (und dem Partizip II des jeweiligen Vollverbs) gebildet wird. Durch das sein-Passiv werden Zustände ausgedrückt. Ein weiterer gebräuchlicher Terminus für sein-Passiv ist Zustandspassiv.' The parallel entry defines werden-Passiv, also called Vorgangspassiv, as expressing the action or process that precedes the state expressed by the sein-Passiv
- Claudia Maienborn, 'Das Zustandspassiv: Grammatische Einordnung, Bildungsbeschränkung, Interpretationsspielraum', Zeitschrift für germanistische Linguistik 35 (2007) <https://publikationen.uni-tuebingen.de/xmlui/bitstream/handle/10900/46556/pdf/Maienborn_2007_Zustandspassiv.pdf?sequence=1&isAllowed=y>
  > The Zustandspassiv is among the most controversial topics in German grammar, the controversy being whether it belongs to the verbal paradigm or is a combination of copula plus adjectivized Partizip II; Maienborn, following Rapp (1996), argues for the copula analysis

**G13 · line 185** · confidence high

> a living fossil of that 5,000-year journey from the Pontic steppe to the German-speaking lands of central Europe

The arithmetic checks against the essay's own dates. Line 126 puts the start of the migrations at 'around 3000 BC (approximately 5,000 years ago)', and 3000 BC to the present is 5,026 years, so a journey described as 5,000 years long is right to the nearest round figure and is the same figure the essay uses at lines 92, 125 and 126. The framing is consistent too: the journey being measured is the migration out of the steppe, which A1 dates to 3000 BC, not the Yamnaya horizon itself, which S1 now opens at 3300 BC and which would give fifty-three centuries. Using the later anchor for the journey is the correct choice, since the journey is what began around 3000 BC. 'Pontic steppe' rather than the essay's usual 'Pontic-Caspian steppe' is a legitimate short form for the western part of the same grassland and reads as compression rather than error.

*Assumes.* Assumes A1 and A2 (cluster A) confirm 'around 3000 BC' and its gloss 'approximately 5,000 years ago', and assumes S1's 3300 BC horizon start is not the intended anchor for the journey. If cluster A moves the migration date, this figure and G16's move with it.

- docs/verb_history.txt line 126 (row A1/A2, cluster A)
  > 'Beginning around 3000 BC (approximately 5,000 years ago) the Yamnaya and their descendants began a series of migrations', which is the anchor the closing figure rounds
- docs/verb_history.txt lines 92 and 125
  > 'a five-thousand-year-old way of saying "us"' and 'preserved across five millennia of linguistic evolution', the essay's two other statements of the same interval

**G15 · line 187** · confidence high

> through Old High German scribes in medieval monasteries

Old High German is transmitted almost entirely through ecclesiastical scriptoria. The standard account is that OHG literacy is a product of the monasteries, with the principal centres at Fulda, St Gallen, Reichenau, Weissenburg, Lorsch, Würzburg, Trier, Echternach and Cologne, and that every manuscript containing Old High German was written by scribes whose ordinary work was Latin. The three best-known monuments make the point on their own: the Tatian translation from Fulda, Otfrid's Evangelienbuch from Weissenburg, and Notker's writings from St Gallen. 'Medieval' is right as well, since the OHG period the essay dates to roughly 750 to 1050 sits squarely in the early Middle Ages. The essay's compression, giving no dates and naming no house, means there is nothing here to be wrong about beyond the association of OHG writing with monasteries, and that association is as secure as anything in the field.

*Assumes.* Assumes E1 (cluster E) confirms the Old High German period as roughly 750 to 1050, which is what makes 'medieval' the right adjective. Any plausible adjustment to E1 leaves OHG inside the Middle Ages, so this row is insensitive to it.

- Brian Murdoch (ed.), German Literature of the Early Middle Ages, Camden House History of German Literature vol. 2, on the transmission of Old High German <https://vdoc.pub/documents/german-literature-of-the-early-middle-ages-camden-house-history-of-german-literature-3tcrniqc2vs0>
  > Old High German literacy is a product of the monasteries, notably St Gallen, Reichenau and Fulda, with further centres at Weissenburg, Lorsch, Würzburg, Trier, Echternach, Cologne and Aachen; all the manuscripts containing Old High German texts were written in ecclesiastical scriptoria by scribes whose main task was writing Latin rather than German
- Stiftsbibliothek St Gallen / e-codices, 'St Gall's Treasure Trove of Monuments to the Old High German Language' <https://www.e-codices.unifr.ch/en/list/subproject/stgall_oldhigh_german>
  > The St Gallen monastic library preserves a concentration of Old High German monuments, including Notker the German's vernacular writings, produced in the abbey's own scriptorium

**G16 · line 187** · confidence high

> still sounding after fifty centuries

Fifty centuries is 5,000 years, which is the same figure as G13's '5,000-year journey', line 125's 'five millennia' and line 92's 'five-thousand-year-old', all keyed to line 126's 'around 3000 BC (approximately 5,000 years ago)'. The arithmetic is exact to the round figure: 3000 BC to 2026 AD is 5,026 years. The framing also holds, since what is said to be still sounding is the echo of PIE ablaut, and the essay dates the ablaut it inherits to the language of the Yamnaya. The one thing that could unsettle the figure is the anchor: S1 now opens the Yamnaya horizon at 3300 BC, which would be fifty-three centuries, but the essay consistently counts from the migrations rather than from the horizon, and this closing sentence's list runs back through the herders to the cloud without claiming to reach the earliest of them. Rounding fifty-three to fifty in a closing cadence would in any case be within the tolerance the surrounding prose sets for itself.

*Assumes.* Assumes G13, which I own and confirm, and through it A1, A2 and S1 as owned by cluster A and the patched half.

- docs/verb_history.txt lines 92, 125, 126 and 185
  > The essay states the same interval four times as five thousand years, five millennia, approximately 5,000 years ago, and a 5,000-year journey, all anchored to migrations beginning around 3000 BC

**G17 · line 187** · confidence high

> ich singe, ich $sAng$, ich habe $gesUngen$

All three forms are correct German for singen, a class III strong verb with the nasal-plus-consonant root: present 1sg singe, preterite 1sg sang, perfect ich habe gesungen with haben as auxiliary, since singen is transitive-capable and non-mutative. The triad matches the essay's own earlier citation at line 121, 'singen, $sAng$, $gesUngen$', so the closing echo is internally consistent as well as correct. Whether each $…$ span reddens the right letters is not a factual question about German and belongs to Phase 3, which owns the comparison against the app's conjugation output; I note only that the spans here are character-identical to those at line 121, so whatever Phase 3 decides there applies unchanged here.

*Assumes.* Assumes R8 (cluster E) confirms the singen triad and its markup at line 121. If R8 changes those spans, line 187 must change identically or the essay will cite the same verb two ways.

- docs/verb_history.txt line 121 (row R8, cluster E)
  > '🇩🇪 singen, $sAng$, $gesUngen$ (sing, $sAng$, $sUng$)', the same three forms with the same markup, cited earlier in the essay
- DWDS, entry 'singen', principal parts <https://www.dwds.de/wb/singen>
  > singen is conjugated singt, sang, hat gesungen, i.e. present singe, preterite sang, perfect with haben and the participle gesungen

## Agent H: internal consistency

No cluster, no web access, both languages at once. Nineteen items: 6 graded as contradictions,
10 as tensions, 3 as nitpicks. Six of the nineteen are the between-ranges kind that no
researcher could have seen, because each lives at a seam where two clusters' ranges meet.

### H1 · contradiction · hedge-mismatch · row D7 (with S3)

**A.** line 102: "A few branches also added a prefix called the ~augment~, reconstructed as *e-, but it was optional even in the oldest texts, and whether it goes back to Proto-Indo-European at all is disputed."

**B.** line 150: "The ~augment~ (*e-), which had marked past tense in PIE, was lost entirely in Germanic."

CONFIRMED and EXTENDED. Phase 0 recorded this as one contradiction (existence: you cannot lose what may never have been there). It is two. Line 102 also strips the augment of its FUNCTION, assigning past marking to the secondary endings and calling the augment optional and branch-limited; line 150 restores the augment as the thing that "had marked past tense in PIE". So 150 contradicts 102 on antiquity and on job. It is also the only place in the essay where the augment is named twice, so a reader meets both sentences and nothing reconciles them. Present at identical strength in German: DE 68 "ob es überhaupt auf das Proto-Indoeuropäische zurückgeht, ist umstritten" against DE 116 "das im PIE die Vergangenheit markiert hatte, ging im Germanischen vollständig verloren". The translator did not soften either side, so this is one contradiction in two languages, not two.

**Which gives way.** Line 150 gives way. Line 102 is pasted patch text (P8) and may not be reworded; 150 is unpatched German-specific prose that D7 owns. Note for D7's owner: a fix has to address both halves, not just the antiquity, because dropping "which had marked past tense in PIE" leaves "was lost entirely in Germanic" still presupposing presence. German line 116 needs the same treatment.

### H11 · contradiction · value-mismatch · row R8; span values themselves are Phase 3's

**A.** line 122: "🇩🇪 nehmen, $nahm$, $genOMmen$ (take, $tOOk$, taken)"

**B.** line 123: "🇩🇪 geben, $gAb$, gegeben (give, $gAve$, given)"

CONFIRMED and SHARPENED from Phase 0's note. Phase 0 flagged $nahm$ as looking wrong on its face. The internal-consistency form is stronger than that and needs no appeal to the app: nehmen and geben are the same case, an e-to-a strong preterite, presented in adjacent bullets of the same three-item list, and one marks its ablaut vowel while the other does not. Whichever value is right, the pair cannot both be. The list is also the essay's demonstration of the claim at 119 that PIE ablaut became the German alternations, so the unmarked $nahm$ is the one bullet where the demonstration does not demonstrate. Both languages carry byte-identical $…$ spans (verified: all 27 match exactly), so the defect is symmetric.

**Which gives way.** One of the two gives way and Phase 3 decides which, since it owns the span values against the app's own conjugation output. What is settled without Phase 3 is that leaving both as they are is not an option.

### H2 · contradiction · value-mismatch · row G14

**A.** line 80: "Generations of dying stars had seeded the cloud … some shed quietly on the winds of aging giants, the rest blasted outward by supernovae" and "elements that no star makes in its long middle age, forged instead in the crush of collapse, in the winds of dying giants, and, for the heaviest, in the collision of two neutron stars"; line 82: "those star-forged elements"

**B.** line 187: "all the way to that primordial cloud of supernova-enriched gas from which the Solar System was born"

CONFIRMED and EXTENDED. Phase 0 filed this as a one-word echo of P3 ("supernova-gifted" to "star-forged" at line 82). It is larger than that. P1 and P2 rewrote line 80 specifically so that no single site is crowned, naming three: collapse, the winds of dying giants, and neutron-star collisions for the heaviest elements. Line 187 does not merely disagree with line 82's adjective; it reasserts the exact framing the two largest patches in the run were applied to remove, and it does so in the essay's final sentence, which is the one a reader carries away. The neutron-star clause makes it flatly wrong on the essay's own terms: gold and uranium, named at line 80, are not supernova products there. Same in German: DE 48 "jene in Sternen geschmiedeten Elemente" against DE 153 "supernova-angereichertem Gas".

**Which gives way.** Line 187 gives way; it is the only unpatched occurrence and it sits downstream of three patches. Phase 4 forbids editing the German-specific half directly, so this belongs in the corrections document with prose for both languages. Cheapest correct form is the adjective already in the essay at line 82.

### H3 · contradiction · value-mismatch · row R2c, with A9

**A.** line 92: "The word “German”, in other words, may trace back to a five-thousand-year-old way of saying “us”."

**B.** line 130: "These Germanic-speaking peoples (known to the Romans as ~Germani~) developed a culture adapted to the forests and coastlines of northern Europe."

NEW, and it is the closest structural analogue in this essay to Conjugar's poder/puedo seam: a shared-half sentence makes a claim that a German-specific section silently refutes 38 lines later. The whole chain at line 92 derives Modern German *Deutsch* (*tewtéh₂ → *þeudō → þēod → theodiscus → Deutsch). The sentence then generalizes from *Deutsch* to "the word ‘German’", which is an English exonym, and line 130 supplies its actual source: Latin *Germani*. So the essay derives the English word "German" from the steppe autonym in one section and from Roman ethnography in another. The German localization does not have the problem: DE 58 reads „Das Wort ‚deutsch' geht also möglicherweise auf eine fünftausend Jahre alte Art zurück, ‚wir' zu sagen", which names the word the chain actually derives. This is therefore an English-only contradiction that the translator resolved correctly and invisibly.

**Which gives way.** Line 92 gives way, toward what the German already says. The sentence is inside the 79 to 125 range but is not a patch site (P1 through P10 land at 80, 80, 82, 85, 86, 86, 88, 102, 106, 107), so nothing pasted is at risk. The change is a referent fix, not a fact change, and R2c's verdict is not needed to make it.

### H4 · contradiction · value-mismatch · row R1

**A.** line 90: "the ancestor of languages spoken by nearly half of humans alive today"

**B.** line 90: "These languages include German, English, Ukrainian, Hindi, Persian, Cornish, Greek, and Latin."

NEW. This is a contradiction between a sentence and its own antecedent, one line apart, so no researcher reading either sentence in isolation would call it wrong: "These languages" refers back to a set explicitly defined as languages spoken by living people, and the list closes with Latin, which has no living speaker community, and includes Cornish, which had none for roughly two centuries. Phase 0 records that the "nearly half of humans alive today" figure survived its dismissal twice; that is about the arithmetic, not about the referent, so this is untouched by it. Identical in German (DE 56, "die heute von fast der Hälfte aller lebenden Menschen gesprochen werden … und Latein"), so it is not a translation artifact.

**Which gives way.** Line 90 gives way, and the essay has two ways to do it that do not require R1's verdict: widen the antecedent so the list is of descendant languages rather than currently spoken ones, or drop the two members that fail the antecedent. R1's owner should be told which was chosen, since the row is a list-membership check and the fix changes what the list is a list of.

### H5 · contradiction · value-mismatch · row G8, with D5

**A.** line 146: "Germanic had to rely on context or periphrastic constructions (combinations of auxiliary verbs with main verbs)"

**B.** line 180: "🇩🇪 ~Aspect~ is expressed periphrastically (er $lIest$ = he reads/is reading)"

NEW, and distinct from the factual point the inventory already has. G8 asks whether "periphrastically" is the right word for *er liest*. The internal question is sharper and needs no research: the essay defines periphrasis itself, at line 146, as combinations of auxiliary verbs with main verbs, and then at line 180 offers as its headline example of periphrasis a single synthetic finite form with no auxiliary in it. The essay fails its own definition, and it does so in the closing summary, where the definition given 34 lines earlier is the only one a reader has. The second half of the same bullet, "or through verbal prefixes and particles", is correctly listed as a separate mechanism, which shows the sentence is aware that prefixes are not periphrasis and still files *er liest* under it. Same in German: DE 112 "periphrastische Konstruktionen (Kombinationen von Hilfsverben mit Hauptverben)" against DE 146.

**Which gives way.** Line 180 gives way rather than line 146, because 146's parenthetical is the essay's only definition of the term and is used by D5's whole argument about what Germanic lost. If G8's owner concludes German has no periphrastic aspect worth naming, the bullet loses its first clause rather than its second.

### H10 · tension · hedge-mismatch · row R4, and P8/P9

**A.** line 102: "The system allowed for present, past (preterite), and arguably future expressions"

**B.** line 106: "🐄 ~Subjunctive~: intentions and things still to come"

NEW, and it is a collision between two patches rather than between patched and unpatched text. P8 rewrote line 102 and P9 rewrote line 106, four lines apart in the same section. The result: the tense paragraph hedges PIE futurity as "arguably", and the mood list four lines later asserts a PIE category whose defining job is futurity, flatly. Both sentences are pasted from Conjugar, where they were separated by much more text. Reporting rather than resolving, per the verbatim rule. Worth noting that German loses the mismatch in the other direction: DE 68 renders "arguably future" as "wohl auch Zukunft", which is closer to "probably" than to "arguably", so the German pair reads consistent and the English pair does not.

**Which gives way.** Neither site should be reworded: both are pasted patch text and the verbatim rule covers both. This is for Josh's judgement as an artifact of two independent patches landing in one short section, and it is the clearest example in the run of what the verbatim rule costs. If he wants it resolved, the resolution is a decision about which of two Conjugar sentences to override, not a rewording.

### H12 · tension · value-mismatch · row D5, F2, F8

**A.** line 146: "Germanic had to rely on context or periphrastic constructions (combinations of auxiliary verbs with main verbs)"

**B.** line 158: "This periphrasis, which began in Old High German and became fully established in Middle High German (1050–1350)"; line 164: "Beginning in Middle High German, the verb ~werden~ (to become) was grammaticalized as a future auxiliary"

NEW. Line 146 says Proto-Germanic, having lost the aspect system, relied on periphrastic constructions. The essay then dates both of its periphrases to Old High German and Middle High German, thousands of years later, and names no third. So the essay's own timeline says the constructions line 146 has Germanic relying on did not yet exist. This is a between-cluster tension by construction: D5 owns 146, F1 and F8 own 158 and 164, and neither range contains the other sentence. Identical in German (DE 112 against DE 124 and 130).

**Which gives way.** Line 146 gives way. Its "context or periphrastic constructions" is a compressed generalization that the essay's later dates undercut; the two later sentences are specific and dated and are what the reader is meant to keep.

### H13 · tension · value-mismatch · row D12; span values are Phase 3's

**A.** line 153: "the "-ed" ending in English ($mAde$, $saId$, played)"

**B.** the essay's own markup convention, stated in the extract header at line 31: "Inside $…$, every uppercase letter is an irregular letter shown red."

NEW. Three examples are offered of the regular English dental preterite. Two of them are wrapped in $…$ with uppercase letters, which the app renders red to mean irregular, and neither spells its suffix "-ed". The third, "played", is the only one that actually exhibits the ending the sentence is illustrating, and it is the only one with no span at all. So inside a single parenthesis the essay marks as irregular two of the three exemplars of its regular pattern, and leaves the regular one unmarked. Identical in German (DE 119).

**Which gives way.** Line 153's example list gives way. D12 owns whether made and said are usable examples of the dental preterite at all, which is the factual half; the internal half is that the sentence's own markup argues against its own claim, and that stands whatever D12 concludes.

### H14 · tension · promise-vs-delivery · row R6, R8, E12; the spans are Phase 3's

**A.** line 111: "Ablaut was not arbitrary sound change but a structured system of vowel grades", and line 157: "their ablaut patterns, while still systematic"

**B.** lines 121 to 123, where those same alternations are rendered inside $…$ with the changed vowels uppercased, which the app reddens to mean irregular

NEW. This is the Konjugieren analogue of Conjugar's poder/puedo seam, mediated by markup rather than by prose, and it is invisible to every researcher because no cluster reads prose and markup as one surface. The essay's argument is that these vowel alternations are systematic and inherited; the app's rendering of the essay's own examples tells the reader they are irregularities. Both are defensible on their own terms, since the app's "irregular" is synchronic and the essay's "systematic" is diachronic, but the essay never says so, and lines 121 to 123 are where the two meanings collide in one line of text.

**Which gives way.** Neither site is wrong and neither should simply give way. The place a bridging clause could go is line 157, which already contains the essay's only acknowledgement that the patterns are systematic and unpredictable at once. Flagging rather than resolving, because the fix is an editorial decision about whether the essay should explain its own red letters.

### H15 · tension · compression-loss · row R2c, E1

**A.** line 92: "it became Proto-Germanic *þeudō, then Old English þēod (“nation”), then, through Medieval Latin theodiscus (“of the people”), Modern German Deutsch"

**B.** line 156: "The Germanic dialects spoken in what is now southern Germany and Switzerland developed into Old High German (roughly 750–1050 AD)"

NEW. The essay's one etymological chain to a modern German word routes through Old English and Medieval Latin and never touches Old High German, which the essay itself establishes 64 lines later as German's direct ancestor and gives a section to. A reader who takes the chain literally learns that *Deutsch* came to German from Latin by way of Old English. This reads as a compressed version of a longer chain that had the Old High German link in it, which is exactly the signature the brief describes. Identical in German (DE 58 against DE 122).

**Which gives way.** Line 92 gives way. R2c's owner already has *diutisc* and the 786 attestation in its brief, so the missing link is inside the row's research rather than beyond it; the internal point is that the chain as written is inconsistent with the essay's own periodization regardless of what R2c concludes about *theodiscus*.

### H19 · tension · value-mismatch · row A6, A8, E1, G13

**A.** line 128: "as speakers moved into southern Scandinavia and northern Germany" and line 130: "a recognizable Proto-Germanic language had emerged in southern Scandinavia and along the North Sea and Baltic coasts"

**B.** line 156: "The Germanic dialects spoken in what is now southern Germany and Switzerland developed into Old High German"

NEW, and structural rather than factual. The essay locates Germanic in the far north twice, then without narrating any movement locates the ancestor of German in the far south. Nothing in between bridges roughly a thousand kilometres and a thousand years, and line 185's closing "journey from the Pontic steppe to the German-speaking lands of central Europe" implies a continuous path the body never draws. Identical in German (DE 94, 96, 122, 151).

**Which gives way.** Line 156 is where a bridging clause would go, since it is the sentence that silently relocates the story. Neither site is wrong, so this is a gap rather than a correction, and it should reach Josh as such rather than as a finding against A8 or E1.

### H6 · tension · promise-vs-delivery · row R9, G13, E12, D15

**A.** line 125: "These vowel changes are direct inheritances from Proto-Indo-European, preserved across five millennia of linguistic evolution." and line 185: "The ablaut patterns that once pervaded Proto-Indo-European morphology survive in the strong verbs, a living fossil of that 5,000-year journey"

**B.** line 155: "many originally strong verbs eventually became weak" and line 157: "Some verbs shifted classes; others became weak. The original phonological conditioning that determined class membership became opaque … Today, German strong verbs must largely be memorized individually"

NEW, and it PARTLY OVERTURNS Phase 0's finding that this trap is empty. Phase 0 is right that Konjugieren's opening makes no learner-memorization promise of Conjugar's kind, and I verified that: the shared half stops at "one of history's most consequential linguistic developments" and never tells a learner what to expect. But the seam exists in inverted form. The shared half promises preservation and system ("direct inheritances", "preserved", and at line 111 "not arbitrary sound change but a structured system"); the German-specific half delivers erosion, class blurring, strong-to-weak drift, and individual memorization; and then the closing at 185 reverts to "survive" and "living fossil" without carrying a word of the body's qualification forward. The damage is at the closing, not at the opening. Line 157's "while still systematic" is the essay's only bridge and it sits in the section being contradicted, not in the summary. Identical in German (DE 91, 121, 123, 151).

**Which gives way.** Line 185 gives way. The opening's "preserved" is defensible about descent; the closing's "survive … a living fossil" is the sentence that lets a reader leave without ever having met lines 155 and 157. Any replacement prose belongs in the corrections document, since 185 is in the half Phase 4 forbids editing.

### H7 · tension · summary-mismatch · row G6, G7

**A.** lines 172 to 177, the whole `The Subjunctive and Modern German` section, ending "the $wÜrde$ construction increasingly replaces synthetic subjunctive conjugations except for common verbs and in formal registers"

**B.** line 178: "Modern German retains the essential architecture established in Proto-Germanic: … and a distinction between indicative, subjunctive, and imperative moods", followed by bullets at 180 to 183 listing Aspect, Future, Perfect and Passive as the periphrastic things

NEW. The summary's structure is: here is what was retained, and here is what went periphrastic. The section immediately above it has just spent six lines establishing that the subjunctive went periphrastic. The summary puts it in the retained column and omits it from the periphrastic list, so the essay's own bullet list contradicts the section it directly follows, at the seam between two of cluster G's sections. Same in German (DE 143 against DE 144 and 147 to 149).

**Which gives way.** Line 178 and the 180 to 183 list give way. Either the mood distinction moves out of the retained clause, or the würde periphrasis joins the bullets. This is an editorial choice about the summary, not a factual question, so it does not depend on G6's verdict.

### H8 · tension · summary-mismatch · row G12, G7, R5

**A.** line 183: "🇩🇪 ~Passive~ is expressed with ~werden~ + past participle (dynamic) or ~sein~ + past participle (stative)" and line 178: "a distinction between indicative, subjunctive, and imperative moods"

**B.** the body, where the passive is named exactly once, at line 110, "with a developing passive", about PIE; and the imperative is named exactly once, at line 108, as a PIE mood bullet

NEW. The closing summary is the only place the German passive and the German imperative appear, and it summarizes them as though the essay had covered them. Meanwhile the body has two full sections, `Preterite-Present Verbs` (168 to 171) and `The Subjunctive and Modern German` (171 to 177), that the summary does not touch at all. So the summary omits two things the essay developed and asserts two things it never developed. This is the compression-loss signature the brief describes, visible without the longer original: an assertion whose own essay gives it no support. Identical in German.

**Which gives way.** The summary at 178 to 183 gives way, since the alternative is adding body material to a deliberately short essay. G12's owner should know the row is the only passive claim in the text, so a verdict of confirmed still leaves an unsupported summary line.

### H9 · tension · value-mismatch · row D8, D9, E9, E11

**A.** line 152: "~Verb classes proliferated based on the structure of the present stem~, leading to the complex system of "strong" verb classes (organized by ablaut patterns)"

**B.** line 157: "Old High German inherited seven classes of strong verbs from Proto-Germanic, organized by their ablaut patterns. … The original phonological conditioning that determined class membership became opaque as sound changes altered vowels."

NEW. Across two clusters the essay gives three answers to what determines strong-class membership: present-stem structure (152), ablaut pattern (152 and 157), and phonological conditioning (157). Line 152 gives two of them inside one sentence, main clause against parenthesis. A specialist can reconcile all three; a reader cannot, because the essay supplies no bridge and the three statements are 5 lines apart across a section boundary that puts them in different researchers' ranges. Identical in German (DE 118, DE 123).

**Which gives way.** Line 152 gives way, since it is the site that states two principles at once and the one filed under a heading (`Losses from Proto-Indo-European`) that its content does not fit. D9 and E9 are the same claim owned by two clusters via depends-on, so whichever verdict lands first should be told that 152's main clause is a third principle neither row quotes.

### H16 · nitpick · summary-mismatch · row F6, G7

**A.** line 163: "In modern spoken German, this perfect construction has largely replaced the simple preterite in everyday speech … The preterite survives primarily in writing, in northern dialects, and with high-frequency verbs."

**B.** line 178: "Modern German retains the essential architecture established in Proto-Germanic: two morphological tenses (present and preterite)"

NEW, and mild. The summary lists the preterite among retained architecture without any trace of the qualification the body gave it fifteen lines earlier. The two are reconcilable, since a tense can be morphologically present and pragmatically retreating, but the summary is written as an inventory of what modern German has, and "has" is doing different work in the two sentences. Same in German (DE 129 against DE 144).

**Which gives way.** Line 178's parenthetical gives way if anything does. Recording it because H7 and H8 are the same sentence failing in two other ways, and three independent problems in one summary sentence is a signal about the sentence rather than about any one of them.

### H17 · nitpick · value-mismatch · row R3, R6

**A.** line 93: "PIE verbs were built on roots (typically consisting of a consonant-vowel-consonant structure)"

**B.** line 115: "🐖 ~zero-grade~: absence of the vowel (as in *bʰr-)", with lines 116 and 117 citing *mḗh₁-n̥s and *n̥-péh₂-tōr

NEW, and small. The zero-grade bullet is defined as the absence of the vowel that the CVC generalization requires, so the essay's own ablaut list is a systematic counterexample to the shape it gave roots twenty-two lines earlier. "Typically" absorbs most of this, which is why it is a nitpick rather than a contradiction. The two lengthened-grade forms are also not CVC, though they are cited as affixed forms rather than as roots. Identical in German.

**Which gives way.** Line 93 gives way if anything does, since "typically" is already carrying the exception and could name it. R3's owner should be told the essay contradicts the generalization itself, so a verdict of confirmed on the handbook wording still leaves a reader with two incompatible pictures.

### H18 · nitpick · value-mismatch · row F14

**A.** line 169: "~dürfen~ (may)"

**B.** line 169: "~mögen~ (may/like)"

NEW, and small. Two members of a six-item gloss list are given the same English word as their primary translation, in the same parenthetical series, so the list does not distinguish the two verbs it exists to distinguish. Identical in German (DE 135), where the English glosses are also the vestigial ones described in germanSurfaceIssues.

**Which gives way.** Line 169 gives way. F14 owns whether each gloss is right in isolation; the internal point is that two of them are right and still collide, which a per-gloss check will not surface.

### The German as a second surface

Seven items. The first two change hedge strength, which is the failure the whole verbatim rule
exists to prevent, and both are in **patched** text: the hedge survived the port from Conjugar
and then did not survive the translation.

**`verb_history_de.txt` line 51** **hedge strength changed**

> DE: Vor 40.000 Jahren, womöglich früher, hatten Menschen die pontisch-kaspische Steppe erreicht

> EN: By 40,000 years ago, and quite possibly earlier, humans had reached the Pontic-Caspian steppe

Two changes in one clause, both weakening. "quite possibly" is an emphatic hedge asserting that earlier is a live reading; "womöglich" is a plain "possibly" and drops the emphasis. And English "By 40,000 years ago" states an upper bound, while German "Vor 40.000 Jahren … hatten … erreicht" reads as a point in time rather than a bound, because there is no "bis". The combined effect is that the German asserts a date the English only caps. This is patch text: P4 is what added "and quite possibly earlier", and the verbatim rule's whole point is that hedge strength survives the port. It did not survive the translation.

**`verb_history_de.txt` line 68** **hedge strength changed**

> DE: Das System erlaubte Ausdrücke für Gegenwart, Vergangenheit (Präteritum) und wohl auch Zukunft

> EN: The system allowed for present, past (preterite), and arguably future expressions

"Arguably" flags a contested reading and invites the reader to doubt it. "Wohl" does the opposite: in this construction it means presumably or no doubt, and "wohl auch Zukunft" reads as a mild affirmation rather than as a flag. So an English hedge that concedes a dispute becomes a German assertion that there probably was a future. This sits one sentence after S3, the patched augment hedge, in a paragraph whose entire job is to say that PIE tense was thin and contested, and it is the sentence in that paragraph the German firms up. Inventory row R4.

**`verb_history_de.txt` line 58**

> DE: Das Wort „deutsch“ geht also möglicherweise auf eine fünftausend Jahre alte Art zurück, „wir“ zu sagen.

> EN: The word “German”, in other words, may trace back to a five-thousand-year-old way of saying “us”.

Not a hedge change: both carry möglicherweise / may at equal strength. The referent differs. The German names the word its own etymological chain actually derives, and the English names an English exonym the essay elsewhere derives from Latin Germani at line 130. The translation is right and the source is wrong, which is the reverse of the direction this check usually runs, and it means the contradiction at H3 exists in only one of the two shipped languages. Recording it here as well as in contradictions because the German is the evidence that settles it.

**`verb_history_de.txt` line 122**

> DE: Das schweizerdeutsche Wort für "Küche" ist daher "Chuchi", im Gegensatz zum Hochdeutschen "Küche".

> EN: The Swiss German word for "kitchen" is therefore "Chuchi", contrasting with High German "Küche".

CONFIRMED from Phase 0, and sharpened. The English works because its head word is English and its contrast term is German, so "kitchen" and "Küche" are different words. The German translated the head word, producing a sentence that names Küche as both the item being translated and the item being contrasted against. It is not merely circular: it asserts that the Swiss German word for Küche stands in contrast to Küche, which a German reader will read as self-refuting rather than as a translation artifact. The English contains no defect, so this cannot be fixed by re-translating; the German sentence needs recasting around a different head word. Inventory row E6, whose owner does not own this but should see it.

**`verb_history_de.txt` line 124, 130, 135, 138**

> DE: der Hilfsverben ~haben~ (to have) und ~sein~ (to be) … das Verb ~werden~ (to become) … ~können~ (can), ~müssen~ (must), ~dürfen~ (may), ~sollen~ (shall), ~mögen~ (may/like) und ~wissen~ (to know) … mit ~würde~ (would) + Infinitiv

> EN: the auxiliaries ~haben~ (to have) and ~sein~ (to be) … the verb ~werden~ (to become) … ~können~ (can), ~müssen~ (must), ~dürfen~ (may), ~sollen~ (shall), ~mögen~ (may/like), and ~wissen~ (to know) … with ~würde~ (would) + infinitive

Ten English glosses of ordinary German verbs survive untranslated in the German essay, where they do no work: a German reader is told that haben means to have. These are parentheticals, not $…$ spans, so the German header's invariant („die englischen bleiben englisch, weil sie im Deutschen als Glosse stehen") does not cover them; that rule is written about the conjugation spans. The distinction matters because the German text elsewhere does use English content-bearingly and correctly: DE 122's "wo das Englische ~pound~, ~water~ und ~make~ hat" and DE 146's "er $lIest$ = he reads/is reading" both need the English, since the contrast is the point. So the German essay uses English in two different ways and only one of them is deliberate. Not a hedge issue and not a factual one; an editorial matter for Josh, of the same kind as the Küche sentence above.

**`verb_history_de.txt` line 110**

> DE: Der Aorist ging weitgehend verloren, seine Konjugationen verschmolzen gelegentlich mit dem neuen Präteritum.

> EN: The aorist was largely lost, its conjugations occasionally merging with the new preterite.

Minor, and correct German. The English uses a participial adjunct, which subordinates the merging to the loss and presents it as a qualification. The German promotes it to a coordinate independent clause joined by a bare comma, which German licenses and which the style doc explicitly discusses in the opposite direction. The effect on strength is small but real: an aside becomes a co-equal assertion, so the German states the merging slightly more firmly than the English. Flagging it because it is the only place in the essay where the German changes the grammatical rank of a qualification, and because D4's verdict is about a claim whose firmness now differs by language.

**`verb_history_de.txt` line 68**

> DE: ~Tempus~ war dem Aspekt untergeordnet. Vergangenheit wurde hauptsächlich durch die ~sekundären~ Endungen markiert

> EN: ~Tense~ was secondary to aspect. Past time was marked chiefly by the ~secondary~ endings

An asymmetry that runs in the German's favour, recorded so it is not later "fixed" the wrong way. English now uses "secondary" twice in consecutive sentences in two unrelated senses, subordinate and technical, with the second bolded by P8's added ~…~ span, so the emphasis makes a reader hear an echo that is not there. German renders the first sense as "untergeordnet" and has no collision. If anyone harmonizes the two languages here, the direction is English toward German, not the reverse, and the English half is pasted patch text that must not be reworded.

### Patch-site notes

Phase 0 pasted ten corrected sentences verbatim, by rule. A pasted sentence arrives in another
essay's voice and at another essay's length. These are observations about what Josh will be
looking at, not proposed rewordings: rewording the pasted text is the thing the verbatim rule
exists to prevent.

- **P1, line 80 (Phase 0's table is correct here).** Restatement inside one paragraph, and the clearest instance of the effect the brief predicts. The pasted opening clause names two forging sites, "some shed quietly on the winds of aging giants, the rest blasted outward by supernovae". Roughly ninety words later the pasted closing clause names them again, "forged instead in the crush of collapse, in the winds of dying giants, and, for the heaviest, in the collision of two neutron stars". Stellar winds are named twice, in near-identical wording ("winds of aging giants" / "winds of dying giants"), and the explosion is named twice. The paragraph now tells its enrichment story once at the top of the sentence and once at the bottom of the element list, with the element list itself in between. In Conjugar's longer opening the two clauses were separated by more material and did not read as a pair.
- **P2, line 80 (Phase 0's table is correct here).** Register. "elements that no star makes in its long middle age" is a lyrical periphrasis sitting among Konjugieren's terse appositive glosses, which run "carbon, the backbone of organic chemistry", "phosphorus, critical for cellular energy". It is the longest non-list clause in the paragraph and the only one that personifies a star. The gloss "supernovae, the explosive deaths of stars" is compatible with the paragraph's habit and reads native; the middle-age clause does not. Phase 0's divergence note 2 records that one word was added to close the list; the register cost of the clause itself is not recorded anywhere.
- **P3, line 82 (Phase 0's table is correct here).** No local redundancy and no register break: a one-word swap into a clause that already read that way. The whole cost of P3 is downstream, at line 187, and it is contradiction H2 rather than a patch-site note.
- **P4, line 85 (Phase 0's table says 83).** Hedge stacking. The sentence already opened with "By", which is itself a bound rather than a point, and P4 adds "and quite possibly earlier", so the date now carries two softeners. Its neighbours in the same paragraph carry one each: "Beginning around 70,000 years ago". Not wrong, and the hedge is the corrected one that must not be reworded; the observation is that this is now the least committed date in a paragraph of hedged dates, and it is the one a reader is least likely to expect to be uncertain. Also note the German drops half of it, which is germanSurfaceIssues item 1.
- **P5, line 86 (Phase 0's table is correct here).** No redundancy or register break; only a numeral changed. One consequence worth seeing: Phase 0's divergence note 3 deliberately kept Konjugieren's "approximately" rather than importing Conjugar's "roughly", which was the right call under the verbatim rule. The visible result is that the essay's three Yamnaya-era date hedges now read "approximately 3300 and 2500 BC" at 86, "around 3000 BC" at 126 and "approximately 5,000 years ago" at 126, three different words across two lines. Nothing is wrong; a reader may hear three degrees of confidence where only one was meant.
- **P6, line 86 (Phase 0's table is correct here).** The most visible register break in the essay. The pasted sentence runs 46 words across three coordinated clauses with an embedded appositive ("a reading some of their skeletons support and other specialists dispute"). It is immediately followed by two short declaratives of 15 and 14 words, "The Yamnaya were semi-nomadic pastoralists, herding cattle, sheep, and goats across the grasslands. They lived in small, mobile groups, following their herds to seasonal pastures." It is roughly triple the length of the sentences around it and it is the paragraph's opening sentence, so the paragraph now begins at a syntactic altitude it never returns to. Secondary echo: "a mobility no earlier people had enjoyed" is followed two sentences later by "small, mobile groups", which repeats the word to mean something else.
- **P7, line 88 (Phase 0's table says 86).** The largest redundancy in the diff, and it changes what the paragraph is about. Three consecutive sentences state the same fact: "What they could not do was digest unprocessed milk", then "not one carried a copy", then "They were dairy pastoralists who were lactose intolerant". The third restates the first two before pivoting to fermentation. This paragraph's topic sentence is "Their society appears to have been patriarchal and hierarchical", and every other subject in it, kurgans, grave goods, status, hunting, agriculture, gets one clause or one sentence. After the patch, lactose is 84 of the paragraph's 155 words. Phase 0's divergence note 4 records dropping Conjugar's fourth sentence as a scope decision; the three that were kept are still, in this shorter essay, the paragraph's dominant subject. Register: the cleft "What they could not do was…" is the only cleft in the essay, and "genotyped directly for the European lactase-persistence allele" is its only clause of technical genetics, arriving one sentence after Konjugieren's own softer "DNA evidence suggests". The two adjacent sentences now sit at different levels of evidentiary specificity about the same dataset.
- **P8, line 102 (Phase 0's table says 93).** A term collision the patch created and nothing else in the run would look for. The paragraph opens "~Tense~ was secondary to aspect", using secondary in its ordinary sense. The pasted next sentence introduces "the ~secondary~ endings" as a technical term, and Phase 0's divergence note 8 records that the ~…~ emphasis was added to it deliberately. So the word appears twice in two senses one sentence apart, and the markup puts a spotlight on the second occurrence. A reader who has just been told tense is secondary will read the bolded secondary as a callback. German has no collision, since it renders the first as "untergeordnet". Register, separately: "pinned an action to the here and now" is the most colloquial phrase in a paragraph that otherwise closes with "aspectual distinctions carried more semantic weight than temporal ones". Both belong to pasted text and neither should be reworded; this is a description of what Josh will be looking at.
- **P9, line 106 (Phase 0's table says 96).** Register, inside a tightly parallel list. The four mood bullets read "statements of fact", "intentions and things still to come", "wishes and possibilities", "direct commands". Three are bare noun phrases of two or three words; P9's is the only one with a trailing relative-flavoured phrase, and it is the only bullet whose gloss cannot be substituted into a sentence the way the other three can. Phase 0's divergence note 5 records that the container changed from a running clause to a bullet; this is the cost of that change, and it is visible only in the list, not in the sentence Conjugar wrote. See also H10: the futurity this bullet asserts flatly is hedged four lines earlier by the other patch in the same section.
- **P10, line 107 (Phase 0's table says 97).** Register is clean: "wishes and possibilities" matches the list's shape exactly and reads as if written for it. The observation is about what the list now covers rather than how it reads. Phase 0's divergence note 6 records the deliberate loss of "gentle commands", and the visible consequence is that the imperative bullet directly below now carries "direct commands" with no counterpart anywhere in the essay marking a softer command as a mood distinction. The list went from four glosses covering five semantic territories to four covering four. That is the recorded trade, not a new cost, and it is noted here only because the loss is now adjacent to the word direct, which draws attention to the missing contrast.

### Agent H's other notes

- INVENTORY LINE NUMBERS ARE WRONG FOR THE SHARED HALF, and this is the most operationally useful thing I found. Every German-specific row I spot-checked (A1 126, B1 131, C1 136, D1 143, D5 146, D7 150, D10 153, D13 155, E1 156, E8 157, F1 158, F5 163, F7 164, F10 168, F12 169, F15 171, G1 172, G4 174, G6 177, G7 178, G8 180, G13 185, G14 187, G17 187) is correct. The shared-half rows are not: S3 is at 102, not 93; R2 is at 92, not 90; R3 is at 93, not 92; R4 is at 102, not 93; R5 is at 110, not 102; R9 is at 125, not 123. S1, S2 and R1's line numbers: S1 is correct at 86, S2 is at 88 rather than 86, R1 is correct at 90. The offsets are not uniform, so this is not a header shift and cannot be fixed by adding a constant. The inventory anticipates the problem in its own How-to-read section, which is why this is a note rather than a finding, but a researcher owning R4 or R5 who trusts the number will read the wrong sentence: line 93 is about root structure, not about tense, and line 102 is about the augment, not about voice.
- THE PHASE 0 PATCH TABLE HAS THE SAME DEFECT. P1, P2, P3, P5 and P6 cite correct lines. P4 is at 85, not 83; P7 is at 88, not 86; P8 is at 102, not 93; P9 is at 106, not 96; P10 is at 107, not 97. The task brief that spawned me already used the correct 102 for the augment, so this appears to be known, but the table itself is what a future session will read.
- THE GERMAN EXTRACT'S HEADER CONTRADICTS ITS OWN BODY. docs/verb_history_de.txt line 26 says „Die 58 ~…~-Spannen…", and both bodies now contain 59. Phase 0's divergence note 8 records exactly this: P8 added ~secondary~ and ~sekundären~, taking the count from 58 to 59 in each language. The header was not updated with the patch. Verified by counting: 118 tilde characters in each body, 59 spans. Every other header count is correct in both files: 18 headings, 27 $…$ spans, 3 ^…^ spans, 20 asterisks, 0 links. The English header states no tilde count, so this is German-only.
- THE $…$ SPANS ARE BYTE-IDENTICAL BETWEEN THE TWO LANGUAGES. I extracted all 27 from each file and compared as ordered lists: they match exactly, in the same order, which confirms the German header's invariant claim and means every span-level finding is automatically symmetric. Sequence: sAng, gesUngen, sAng, sUng, nahm, genOMmen, tOOk, gAb, gAve, mAde, saId, crEw, gesUngen, sUng, cAme, kAnN, kAnN, kAnN, kÄme, cAme, wÜrde, wOUld, wÜrde, lIest, lIest, sAng, gesUngen.
- EVERY NUMERIC VALUE MATCHES ACROSS THE TWO LANGUAGES. I checked all fourteen date sites the brief named plus every other figure: 4.6 / 4,6 billion, 4.5 / 4,5 billion, 3.8 / 3,8 billion, 300,000 / 300.000, 70,000 / 70.000, 40,000 / 40.000, 3300 and 2500 BC, 3000 BC and 5,000 years, 2500 and 2000 BC, first millennium BC, 9 AD, three legions and 20,000 soldiers, some two millennia, 750–1050, 1050–1350, seven strong classes, five millennia / fünf Jahrtausende, five thousand years / fünftausend Jahre, 5,000-year / 5.000-jährigen, fifty centuries / fünfzig Jahrhunderten. No value-mismatch between surfaces. Internally the date set is also coherent: 3000 BC sits inside the 3300 to 2500 BC Yamnaya window, PIE at roughly 3000 BC to Proto-Germanic by roughly 1000 BC is the "some two millennia" of line 143, and 750–1050 abuts 1050–1350 exactly. The one thing to note is that P5's change from 4500 to 3300 BC did not orphan any downstream date; line 126's 3000 BC still falls inside the new window.
- THE ESSAY'S TWO EXPLICIT PERIPHRASIS COUNTS ARE CONSISTENT, WHICH IS EVIDENCE. Line 146's "only ~two tenses~", line 168's "three-way temporal system … from the original two-tense Proto-Germanic system", and line 178's "two morphological tenses" look like a value-mismatch and are not: line 168 explicitly says "through periphrasis rather than new morphological conjugations", which reconciles all three. I checked this expecting a finding and found the essay handling it correctly. Recording it so that the absence of a finding here is legible as a check performed.
- REDUNDANCY ACROSS AN UNPATCHED HEADING BOUNDARY, so it goes here rather than in patchSiteNotes. Line 152 ends `Losses from Proto-Indo-European` with "\"weak\" verbs (a Germanic innovation using a dental suffix for the preterite)", and line 153 opens `The Germanic Innovation: Weak Verbs` with "Proto-Germanic created something new: the ~weak verb~. Rather than using ablaut to mark the preterite, weak verbs added a dental suffix". The same three facts, consecutively, across a heading. The heading mismatch compounds it: an innovation is the last item in a section titled Losses, which the inventory notes at D8 as a filing question and which is also a redundancy question.
- 🏴󠁧󠁢󠁥󠁮󠁧󠁿, 🇦🇹 AND 🇨🇭 APPEAR ONLY IN THE HEADERS, NEVER IN EITHER BODY. Counted: 🏴󠁧󠁢󠁥󠁮󠁧󠁿 body=0 in both files, 🇦🇹 body=0, 🇨🇭 body=0. The livestock series and 🇩🇪 are used identically in both languages: 🐎 3, 🐄 3, 🐖 3, 🐐 2, 🐑 1, 🇩🇪 12. The English header's convention paragraphs at lines 46 and 64 to 66 describe 🏴󠁧󠁢󠁥󠁮󠁧󠁿 as though the essay uses it. The header is scrupulous about this elsewhere, saying outright that "The essay contains no links today, so the check is idle", so the silence here reads as coverage rather than as absence, which is the exact failure mode the inventory's coverage notes exist to prevent.
- QUOTATION TYPOGRAPHY IS INCONSISTENT, SYMMETRICALLY IN BOTH LANGUAGES. Exactly one paragraph per file uses curly quotes: English line 92 (18 curly characters, 0 straight) and German line 58 (18 curly, 0 straight). Every other quoting line in both files uses ASCII straight quotes: English 86, 113, 152, 153, 155, 156 and German 52, 79, 118, 119, 121, 122. Because the split is identical across languages it is a pre-existing authoring habit, not a translation defect. Worth flagging for a reason beyond consistency: CLAUDE.md's xcstrings rule identifies ASCII U+0022 as the one quote type that breaks the catalog under Edit-tool editing, and curly quotes as the safe kind. Eleven of the essay's twelve quoting lines use the dangerous kind. The sync script insulates the essay from that, but any hand-edit at those lines will not be insulated.
- STYLE-DOC COMPLIANCE, CHECKED AND CLEAN. Zero em dashes in either body. Two en dashes per body, both numeric ranges (750–1050, 1050–1350), which the style doc explicitly permits. No singular they. Logical punctuation is correct throughout, including line 92's “the people”. and line 156's \"Küche\". I confirm Phase 0's two English-only defects and found no third: the comma splice at 157 (the German uses a colon and is correct) and "The peculiar conjugations … reflects" at 171 (the German "spiegeln … wider" is correct). One habit worth naming since it recurs: at lines 133, 146 and 187 a fronted clause closes with a parenthesis and no comma before the main clause ("…(a fortified frontier) they never permanently conquered", "…(all through verb morphology) Germanic had to rely", "…ich habe $gesUngen$) you are participating"). It is consistent with itself, so it is a house habit rather than an inconsistency, but all three read as dropped commas. Separately: the prompt's Phase 4 requires replacement prose with "no parenthetical expressions", and this essay is heavily parenthetical, so a corrections author following that rule will produce prose that does not match the voice around it.
- NO SOUND LAW IS CITED TWICE WITH DIFFERENT VALUES, because no sound law is cited twice at all. The High German consonant shift appears only at line 156, with its three correspondences (p → pf or ff; t → ts or s; k → ch) stated once and qualified once at the same site by the Swiss and Kölsch examples. Grimm's law and Verner's law are absent from the essay entirely, which the inventory records at cluster D. The dental suffix is stated at 152 and 153 with the same value (*-d- or *-t- at 153, unspecified at 152), so no conflict. This category is genuinely empty and that is worth saying, because it was one of the brief's named checks.
- THE E6 GERMAN CIRCULARITY THAT PHASE 0 FLAGGED IS STILL LIVE AND IS WORSE THAN CIRCULAR. See germanSurfaceIssues. Recording here that I confirm rather than merely restate it, and that the same sentence has a second problem the English does not: DE 122 names Küche as both the word being translated and the word being contrasted against, so the sentence refutes itself rather than merely repeating itself.
- ON THE PROMISE-VERSUS-DELIVERY TRAP SPECIFICALLY, AS INSTRUCTED. Phase 0's claim is that Konjugieren's opening makes no learner-memorization promise. I verified this directly rather than accepting it, by reading every forward-looking sentence in the shared half. There are three: line 82's "awaiting … the emergence of life that would one day use them to speak, to write, and to conjugate verbs", which line 187 delivers; line 85's "would become the crucible of one of history's most consequential linguistic developments", which lines 86 to 92 deliver; and line 111's "Perhaps no feature of Proto-Indo-European has proven more enduring than ~ablaut~", which lines 119 to 125 and 185 deliver. None of the three names a learner or an act of memorization. Phase 0 is right about the trap it described. It is wrong that the seam is empty, and H6 and H14 are where it actually sits: the promise is about system and preservation rather than memorization, and it is the closing rather than the opening that fails to honour the body.

## Inventory gaps

Checkable claims the inventory has no row for. Researchers reported these rather than
researching them, per the rule that a gap is cheap to fill once and expensive to fill seven
times. Two of them, the Lehmann *ga-* counterposition at line 144 and the Wenskus objection to
kinship organisation at line 138, name live scholarly counterpositions and are the ones most
worth a row if the inventory is extended.

- **[A]** Line 128, "As they settled among or displaced existing populations, their speech diverged into regional varieties." The first clause is a checkable consensus attribution about admixture versus replacement, and it has no inventory row. A3 quotes only the "reshape the genetic and linguistic landscape" clause of the previous sentence, so this one is not covered by it. My impression from the A3 research is that it would survive, since "settled among or displaced" offers both mechanisms and commits to neither, but it should be somebody's row rather than nobody's.
- **[A]** Line 130, "developed a culture adapted to the forests and coastlines of northern Europe." Reported for completeness only. It is checkable in principle against the Nordic Bronze Age and Jastorf record, but it is too vague to settle either way, and I would not spend a search on it.
- **[B]** Line 133, 'While the Romans would launch punitive expeditions'. This clause sits between B9 and B10 and belongs to neither row's quoted span, so no row adjudicates it. It is checkable and not obviously right: Germanicus's operations of AD 14 to 16 were conducted with up to eight legions, reconquered the Lippe valley and the North Sea coast, and recovered two of the three lost eagles, which is more than punishment. Reference works do call them punitive, so the essay's word is defensible, but the question deserved a row rather than falling through a seam. Reported, not researched beyond what B9 required.
- **[B]** Line 131, 'an alliance of Germanic tribes'. The phrase falls inside B7's quoted text but B7's stated question is only whether Hermann is a name Arminius bore, so the composition of the coalition, the Cherusci with Marsi, Chatti, Bructeri, Chauci and others, is checkable and unadjudicated. I did not research it.
- **[B]** Line 135, second sentence: 'Instead, the Germanic languages (including what would become German, English, Dutch, and the Scandinavian languages) evolved independently, preserving ancient features and developing new ones according to their own internal logic.' B13's span stops at 'as did so many others within the Empire', so this sentence has no row at all. The parenthetical list is checkable, though trivially true; the rest of the sentence is close to unfalsifiable and may be why Phase 0 skipped it. Recording it so that its absence is a decision rather than an oversight.
- **[C]** Line 138, 'Society was organized around kinship groups and tribal affiliations'. This is a checkable claim with no inventory row: C5 begins at 'led by chieftains' and leaves the kinship clause unowned. It is worth a row because Germanic kinship organisation is itself a contested question rather than a settled background fact. The Sippe as a corporate descent group is a nineteenth-century construct that has been argued down, and Wenskus's Stammesbildung und Verfassung (1961) specifically holds that Germanic peoples were organised not on biological kinship but around small warrior elites carrying a core tradition, which is close to the opposite of what the essay's clause asserts. I have not researched it further, per the rule.
- **[D]** Line 144, "Germanic abandoned these distinctions almost entirely", meaning the three PIE aspects. No row covers it. D2, D3 and D4 each cover the fate of one aspect stem; none covers the summary judgement, and the summary is separately checkable and has a live counterposition. Lehmann's Grammar of Proto-Germanic argues the opposite, that "the distinction between imperfective and perfective aspect was maintained into Proto-Germanic, and was expressed by means of the ga- prefix", which is a minority but reputable view and is the reason German still has ge- on the participle. I encountered this incidentally while researching D5 and am reporting rather than researching it, per the rules. Whoever picks it up should note it is about aspect, not tense, so it does not disturb D5.
- **[D]** Line 146, "Germanic had to rely on context or periphrastic constructions (combinations of auxiliary verbs with main verbs)". No row. This asserts that periphrasis was available to Proto-Germanic as a repair for the lost aspect distinctions, which is a claim about the Proto-Germanic stage rather than about later German, and cluster F's F1 and F2 cover only the German haben and sein perfect from Old High German onward. Whether Proto-Germanic itself had such periphrases, and how early, is a real question and nobody owns it.
- **[D]** Line 144, "The most striking change was the ~collapse of the aspect system~". Superlative framing rather than a fact, and probably not worth a row, but it is the topic sentence the uncovered claim above depends on, so I list it here so that a decision gets made once rather than seven times.
- **[E]** Line 92, the sentence that closes the tewteh2 paragraph: 'The word "German", in other words, may trace back to a five-thousand-year-old way of saying "us".' No inventory row covers it, and it is checkable and looks wrong in English specifically. The etymology the paragraph has just given belongs to Deutsch. English 'German' comes from Latin Germani, which is the very word the essay itself uses at line 130, 'known to the Romans as ~Germani~'. The German localization at line 58 reads 'Das Wort "deutsch"' and is fine; the defect exists only in the source language. My R2c replacement stops at 'Modern German Deutsch' and leaves this sentence untouched, so if it is to be fixed it needs its own decision. Reporting rather than researching, per the rules.
- **[E]** Line 119, the clause 'When PIE *e and *o later developed into different vowels in the daughter languages'. R7 quotes only the first half of that line and R9 covers the closing sentence at 125, so this assertion about how the PIE vowels developed is unrowed. It is checkable and, as far as I can tell without opening research on it, sound, but it is also the clause that most directly contradicts R9's 'direct inheritances', so whoever resolves R9 will want it to have an owner.
- **[E]** Line 111, 'Ablaut was not arbitrary sound change but a structured system of vowel grades'. Unrowed. Probably not worth a row, since it is the framing sentence for R6 rather than an independent claim, but I flag it so its absence is a decision rather than an oversight.
- **[F]** Line 158, "created a new way to express completed action". F1 covers the auxiliaries and the participle and F2 covers the dating, but nothing owns the semantic characterization. It is checkable and it is arguably loose: the modern German Perfekt is a general past-reference form rather than an aspectual completive, which is precisely why it could displace the preterite in speech. The Old High German ancestor was resultative, so the clause describes the construction's starting point rather than what it became.
- **[F]** Line 171, "reflects their origin as old preterite conjugations that were reanalyzed as presents". This is the causal claim that both F15 and F16 lean on, and it has no row of its own. F12 states the class's origin in the previous paragraph, but the reanalysis clause is a separate sentence making a separate assertion, and any replacement prose for F15 or F16 sits inside it.
- **[F]** Line 163 and line 178 together. F5 says the perfect has largely replaced the simple preterite in everyday speech, and G7 says modern German retains two morphological tenses, present and preterite. Both are true and they do not conflict, but no row owns the relationship between them, and the essay never tells the reader that the preterite it lists as a surviving morphological tense is the same form it has just described as largely displaced in speech.
- **[G]** Line 185, 'The ablaut patterns that once pervaded Proto-Indo-European morphology survive in the strong verbs'. G13 quotes only the trailing clause about the 5,000-year journey, so the assertion that ablaut pervaded PIE morphology, meaning nominal as well as verbal, and that it survives specifically in the German strong verbs, has no row of its own. R9 (cluster E) covers the near-identical claim at line 125, so the fix is probably to point this at E rather than to open a new investigation.
- **[G]** Line 187, 'The heavy elements forged in dying stars became the Earth; the Earth brought forth life; life evolved the capacity for language'. Three checkable assertions with no rows. They restate the patched opening at lines 80 to 83, so they are probably meant to inherit those verdicts, but if the opening is ever re-edited this sentence has to move with it and nothing in the inventory records that.
- **[G]** Line 187, 'through Germanic warriors in their forest villages, through Yamnaya herders on the windswept steppe'. G15 covers only the Old High German scribes in the same list. The other two links echo C1 (cluster C) and the patched Yamnaya material, and are probably intended to inherit those verdicts, but the inventory does not say so.

## Cluster notes

Observations that are not findings: coverage facts, editorial matters, and things routed to
agent H.

**Cluster A**

- Coverage confirmation the brief asked for: Corded Ware, the Jastorf culture, and any appeal to a pre-Germanic substrate appear nowhere in lines 125 to 130. The essay names no archaeological culture at all between the Yamnaya at line 86 and the Cherusci at line 131. I did not search for any of the three. They did surface incidentally inside sources consulted for A5 through A8, and the incidental finding is that the essay's homeland account is the standard one with the culture names stripped out, not a different account.
- For agent H, the A7 and D1 seam. Line 130 read naturally puts Proto-Germanic in place by about 1000 BC. Line 143, cluster D's row D1, says Proto-Indo-European evolved into Proto-Germanic "over some two millennia", which from line 128's separation window of 2500 to 2000 BC lands the proto-language at 500 BC to the turn of the era. The two dates cannot both be right, and the handbook date is the one D1 implies. My A7 replacement resolves the seam in D1's favour without touching D1. If cluster D proposes to change D1 instead, the pair should be settled together rather than row by row.
- For agent H, on the German. The German at line 96 reads "Bis zum ersten Jahrtausend v. Chr.", which is less ambiguous than the English "By the first millennium BC" and lands squarely on the early reading. This is a case of the hazard the run's own prompt names, a hedge or an ambiguity flattened in translation, except that here the flattening picks the wrong side. Everywhere else in my range the German mirrors the English clause for clause with no hedge lost: line 94 carries "likely … sometime between" as "wahrscheinlich irgendwann zwischen", and line 92 carries the horse list verbatim as "Ausgestattet mit Pferden, Räderkarren und vielleicht Bronzewaffen".
- For agent H, on the A4 seam that Phase 0 flagged. Having researched it, I can report the seam is real rather than cosmetic, but it is narrower than it looks. S1's hedge is about riding and A4 is about equipment, so the two do not contradict each other in logic. What they do is agree on the wrong thing: the sentence at line 126 asserts, in a list, precisely the association that the study underlying the modern picture set out to reject. Correcting A4 leaves S1 untouched under either resolution of the riding question.
- Editorial, not a finding. Line 126 opens with a fronted participial phrase and no comma after the closing parenthesis: "Beginning around 3000 BC (approximately 5,000 years ago) the Yamnaya and their descendants began …". The same pattern recurs at lines 133 and 146, so it is a house habit across the essay rather than a slip in this section. Josh may want it consistent one way or the other; docs/english_writing_style.md does not rule on it. This is a third item for the list Phase 0 started with the line 157 comma splice and the line 171 subject-verb disagreement.
- On search economy. Thirteen searches over ten rows, weighted toward A4, A5 and A7 as the brief directed. A1, A2, A6, A8 and A9 were settled largely by sources already fetched for their neighbours, which is why the source lists overlap: the Librado 2021 abstract settles the date in A1 and the horse in A4, and the Ringe post settles geography in A6 and A8 and chronology in A7.

**Cluster B**

- Requested coverage confirmation: the essay names no legion numbers and does not quote Suetonius. Verified mechanically over docs/verb_history.txt, not by eye. 'XVII', 'XVIII', 'XIX', 'Suetonius' and 'legiones' each occur zero times in the whole file; 'Kalkriese' likewise zero. 'Varus', 'Cherusci', 'Hermann', 'Rhine', 'Danube' and 'limes' occur once each. Neither the three legion numbers nor the 'Quintili Vare, legiones redde' line is in the essay, so a later agent finding no report on them should read that as absence of claim, not absence of coverage.
- For agent H, an internal seam inside one sentence at line 133. The clause 'eventually establish the ~limes~ (a fortified frontier)' and the clause 'they never permanently conquered the lands beyond the Rhine and Danube' are describing the same ground from two directions. The Upper German-Raetian limes enclosed the Agri Decumates, which lies east of the Rhine and north of the Danube and was Roman for roughly 180 years. The sentence is true only because of the word 'permanently'. It is currently present in both languages, English 'permanently' and German 'dauerhaft' at de line 99, and if either is ever lost in an edit the sentence becomes false. Worth recording as a place where the two surfaces must stay in step.
- For agent H, a live inconsistency between two adjacent sentences that is the substance of my B12 finding. Line 133 says Romanization 'transformed Gaulish into French', which describes descent, and line 135 says the Germanic peoples 'might have adopted Vulgar Latin', which describes language shift. The second is right and the first is wrong, and they are two lines apart. If B12 survives the skeptic, the fix removes the inconsistency as a side effect; if it does not, the inconsistency is still there and belongs to H.
- For agent H, the same B12 framing is carried over intact into the German at line 99: 'die Gallisch zu Französisch, iberische Sprachen zu Spanisch und Portugiesisch und Dakisch zu Rumänisch transformierte'. The German verb transformierte states the descent relation at least as flatly as the English, so a correction landing in English must land in German or the German ships the error alone.
- Editorial, not factual, English only. Line 133 runs 'While the Romans would launch punitive expeditions and eventually establish the ~limes~ (a fortified frontier) they never permanently conquered the lands beyond the Rhine and Danube.' The introductory subordinate clause has no closing comma before 'they'. The German at line 99 punctuates it correctly: '…errichten sollten, eroberten sie nie dauerhaft…'. This joins the two English-only style defects Phase 0 already recorded at lines 157 and 171.
- Method note on B11, in case a skeptic wonders why the file is thin. Per the cluster brief I read Conjugar's cluster G 'Raised and dismissed' block before searching and deliberately did not re-run the two-Germanias research, which the adversarial pass there already settled. My searching went only to the one fact that block did not consider, the Agri Decumates, and to the dates that decide whether Roman tenure there was permanent. Two searches, not five.
- On the shape of my return. Eleven of thirteen rows came back confirmed. That is not a light pass: B6, B9 and B11 were each pressed hard against the specific objection the brief named, and each survived for a reason I have written out rather than asserted. B9 in particular is the one I would most expect a skeptic to want to convert into a finding, and my reasoning line names the strongest version of the case against the essay, Lendering's 'the fights were not the cause of this rift; they were a precondition', so that the skeptic is arguing with the evidence rather than with me.

**Cluster C**

- Cluster-level observation, the one the brief asked for. Of my fourteen rows, eleven trace to Tacitus's Germania in the first instance, and three of those reproduce him nearly verbatim: C9's absolutes echo Germania 16, C13 is Germania 9 compressed, and C6 uses his Latin word. The essay never names him. Six rows do have independent archaeological corroboration that would survive if the Germania vanished tomorrow: C3 (faunal assemblages and byre stalls), C4 (byre stalls plus the *fehu word-history), C8's no-cities half, C9's counterevidence, C14 (bog deposits), and C1's villages-and-farmsteads half. Three rows are Tacitus and nothing else: C5, C7, and C11's direct testimony. This is an editorial matter for Josh rather than a finding, but one clause naming Tacitus at the head of the section would let a reader weigh everything that follows, and it would cost the essay nothing it currently has.
- C7, recorded rather than proposed. 'Gifts of weapons, gold, and feasting' has weapons and feasting straight from Germania 14. Gold is the weak item at the Teutoburg horizon: Germania 5 says the gods denied them silver and gold, the Lübsow-horizon imports contemporary with the battle are bronze, silver and glass, and the gold arm-rings of Germanic archaeology belong mainly to the Late Roman Iron Age from about 150 AD and to the Migration Period. Germania 15's 'phalerae torquesque' is enough to keep the claim from being wrong, so I confirmed it. If agent H or Josh wants the paragraph tightened to its date, 'weapons, treasure, and feasting' would be the one-word fix.
- C5, recorded rather than proposed. The essay fuses Tacitus's own distinction in Germania 7 between hereditary kings, 'reges ex nobilitate', and elected war-leaders, 'duces ex virtute', into a single chieftain holding all three qualifications at once. Not wrong as a claim about where authority came from, but it flattens the one structural point Tacitus makes about Germanic leadership.
- C8, recorded rather than proposed. Maroboduus of the Marcomanni built a recognised kingdom in Bohemia with a drilled standing force, Rome acknowledged it in AD 6, and in 9 AD he declined to join Arminius. He is the standing exception to 'no centralized states', and he stands at precisely the essay's chosen date. The kingdom collapsed within a decade and left no located city, so the generalisation holds, but if the section ever grows a sentence, he is the obvious one.
- German-side observation for Phase 4. Line 106 renders the runic sentence with a pluperfect, 'obwohl sie das Runenalphabet ... entwickelt hatten', which places the development of runes before the 'committed little to writing' rather than after it. That sharpens the C10 chronology problem in German beyond what the English does.
- German-side observation for Phase 4. Line 104 has 'eine ~comitatus~'. Comitatus is a Latin masculine fourth-declension noun, so the article is wrong on any reading; German usage would want 'ein comitatus' or, better, the German term Gefolgschaft. Grammatical rather than factual, and inside the half Phase 0 could not edit.
- German-side observation for Phase 4. Line 108 closes the pantheon parenthesis and runs straight into the relative clause with no comma: 'und andere) die in heiligen Hainen statt in Tempeln verehrt wurden'. German requires the comma before a relative clause.
- Editorial thought for a German-language app, not a finding. The C12 list gives Old English and Old Norse reflexes and skips Old High German entirely: Wuotan, Donar and Ziu are the forms that lead to Donnerstag and Dienstag, and they are the branch this essay is otherwise about. Adding them would cost a clause and would connect the pantheon to the reader's own calendar.
- Search-cap observation for whoever runs the remaining clusters. Springer article PDFs redirect to an IdP authorisation host and are effectively unfetchable, so Behre 1992 and the Danish rye paper had to be read through search summaries and abstracts rather than full text. Nothing in my verdicts turns on a detail I could only have got from the full text, but a cluster needing precise archaeobotanical figures should budget for the Chrome route.

**Cluster D**

- COVERAGE, as the brief asked: Grimm's law and Verner's law are named nowhere in the essay, and this cluster confirms the inventory's observation. The consequence is worth stating plainly for agent H and for Josh. The only consonant shift the reader ever meets is the High German one at line 156, which is the second shift, and the essay introduces it as what distinguishes Old High German "from other Germanic languages" without ever mentioning that a first shift is what distinguishes all the Germanic languages from the rest of Indo-European. A reader who knows nothing will infer that the shift at line 156 is the shift. The gap sits squarely in this cluster's territory, between line 143 and line 152, where the essay lists what Germanic did to the inherited verb and lists only morphology. Adding it is an editorial decision, not a correction, so no row and no finding.
- CONTRADICTION FOR AGENT H, the one Phase 0 manufactured. Patched line 102 says the augment belongs to a few branches, was optional even in the oldest texts, and that its Proto-Indo-European antiquity is disputed. Unpatched line 150 says it "had marked past tense in PIE" and "was lost entirely in Germanic". These cannot both stand. My D7 finding fixes line 150 in the direction of line 102 and preserves the true half, that Germanic shows no augment at all. I did not touch line 102. Note that D6's fix and D7's fix are adjacent lines in the same short list of losses, so if both are applied they should be reviewed together for rhythm.
- EDITORIAL, D8's heading. The heading at line 143 reads `Losses from Proto-Indo-European` and the fifth item under it, at line 152, describes a proliferation of verb classes. The content of that sentence is sound, which is why I confirmed it, but the section is being asked to hold an innovation. The simplest repair is not to touch line 152 at all: the paragraph at line 152 is really the hinge into `The Germanic Innovation: Weak Verbs`, which begins on the same line, so moving the heading or splitting the sentence is an editing choice for Josh. Flagging it here rather than as a factual-error verdict, per the brief.
- INVENTORY LINE NUMBERS DRIFT for this cluster's residue rows, and Phase 4 will trip over it. The inventory gives R3 at 92, R4 at 93 and R5 at 102, and gives S3 at 93. In the patched docs/verb_history.txt the actual lines are R3 at 93, R4 at 102, R5 at 110, and S3's sentence at 102. The same drift is in docs/verb_history_phase0.md's residue table, so it is inherited rather than newly introduced. My verdicts cite the actual file lines. The D1 through D17 line numbers in the inventory are all correct as given, so the drift is confined to the shared-half rows.
- WHY D6 READS AS A FORMAL MERGER, for whoever writes the German. The patched mood list at lines 106 and 107 introduces the subjunctive and the optative as two distinct PIE moods with distinct jobs, in Conjugar's corrected wording. That list is what makes "merged" at line 148 land as a claim that two inherited categories became one, which is the error. The list itself is correct and settled and should not be touched; the fix belongs entirely on line 148. Phase 4 should also know that the German at line 114 states the merger at least as flatly as the English does, with no hedge to preserve, so the German replacement is a straight restatement rather than a hedge-strength problem.
- FOR PHASE 3, not for me. Two spans in this cluster's range are markup questions rather than factual ones. $mAde$ and $saId$ at line 153 redden the ablaut-looking vowels of two verbs that are weak, not strong, which is coherent only if the spans are being used to mean "unpredictable spelling" rather than "ablaut". $crEw$ at line 155 reddens the e of a genuine strong preterite, which is the intended sense. Whatever Phase 3 decides, my D12 replacement prose keeps both spans exactly as the essay writes them so it does not prejudge the question.
- SOURCE ROUTING. Ringe's own text was not directly reachable: both University of Pennsylvania handout PDFs returned 403. I routed around them via Lehmann's Grammar of Proto-Germanic at the Linguistics Research Center, which states the optative point in the same terms, and via Kim's 2019 Transactions of the Philological Society paper, which takes the same position as its premise. For the dental preterite I read Kiparsky's paper directly from the fetched PDF rather than relying on a summary, which is why D13's verdict quotes it verbatim; that fetch is the single most load-bearing source in this cluster.
- SEARCH ACCOUNTING for the shared cap. 16 distinct web searches plus 7 page fetches, of which 5 fetches were blocked. Roughly 0.8 searches per row, under the one-to-three budget, because several rows in this cluster settle from the same handful of sources: Lehmann's Proto-Germanic grammar covers D2, D3, D5, D6 and R5, and Kiparsky covers D10, D11, D13 and D14.

**Cluster E**

- Coverage confirmation the brief asked for: the essay assigns no date to the High German consonant shift itself. Line 156 dates only the Old High German period, 'roughly 750-1050 AD'. The shift is conventionally dated to between the 3rd and 5th centuries with completion before the 8th, but the essay never says so, so there is nothing to check and I opened no row.
- Coverage confirmation: Notker is absent from the essay. A search of the whole text for 'Notker' and for any named Old High German author or monastery returns nothing. Line 187's 'Old High German scribes in medieval monasteries' is the closest the essay comes, and that sentence belongs to cluster G (row G15).
- For agent H: the Phase 0 log records, under corrections deliberately not applied, that 'The essay uses no laryngeal notation anywhere', given as the reason for keeping the augment as *e- rather than *h₁e-. That is not true of the essay as it stands. Laryngeal notation appears four times in my rows alone: *tewtéh₂ at line 92, *mḗh₁-n̥s at line 116, *n̥-péh₂-tōr at line 117, and the h₂ inside that last form. The decision to keep *e- may still be right, since Conjugar's corrected prose keeps it, but the stated reason no longer holds and H should know before anyone relies on it.
- For agent H: an internal seam inside a single paragraph. Line 156 places the birth of Old High German in 'what is now southern Germany and Switzerland', then three sentences later uses Kolsch, spoken in Cologne, as its northern counter-example. Cologne is inside the Old High German area: Middle Franconian is one of the Central German dialects of Old High German, written at Trier, Echternach and Cologne. So the paragraph both excludes and relies on the same territory. My E1 finding fixes the first half; H should decide whether the Kolsch sentence needs any adjustment once E1 lands, since on its own merits E7 is correct and I confirmed it.
- The German localization defect at E6 is recorded and not mine: the German renders the Swiss example as das schweizerdeutsche Wort fuer 'Kueche' ist daher 'Chuchi', im Gegensatz zum Hochdeutschen 'Kueche', which contrasts Kueche with Kueche. The English works because its head word is 'kitchen'. Editorial matter for Josh, already in docs/verb_history_phase0.md.
- Inventory line numbers drift by two for the residue rows in the shared half. R2a through R2e are listed at line 90 but the tewteh2 paragraph is line 92; line 90 is the descendant-list paragraph that carries R1. R9 is listed at line 123 but the sentence 'These vowel changes are direct inheritances' is at line 125; line 123 is the third triad, which belongs to R8. R6 at 113-117 and R7 at 119 are correct. I have cited the true line in each verdict. Worth fixing in docs/verb_history_claims.md before Phase 2 skeptics start locating rows by number.
- E12's sentence also contains the comma splice Phase 0 recorded as a style note. I did not report it as a finding, per the brief. My replacement prose removes it as a side effect of recasting the sentence, because the second clause had to be rebuilt anyway. If Josh takes the linguistic fix he gets the punctuation fix for free; if he rejects the linguistic fix the splice is still there and still a style note.
- My R8 replacement changes a German verb, not only its English gloss, which is a larger edit than most of this run's findings. The alternative, keeping nehmen and dropping the implied parallel, cannot be done inside a bullet list without a parenthetical aside the house style forbids. If Josh prefers the smaller edit, leaving the line as it stands costs a reader nothing false; the nitpick grade reflects that.
- My E3 replacement adds 'after a vowel' to the k outcome and one new sentence about the voiced stops. It deliberately says 'the voiced stop d' rather than 'the voiced stops', because d hardened across all High German while b and g did so consistently only in Bavarian. Naming only d keeps the sentence true without needing a further qualification, and it sits comfortably with the next sentence's point that the south shifted more.

**Cluster F**

- The essay never names Early New High German, anywhere. It dates Old High German to 750-1050 and Middle High German to 1050-1350, then goes straight to "modern spoken German". Two of the developments this cluster covers land squarely in the unnamed gap: the werden future's grammaticalization culminates in the sixteenth century, and the perfect's semantic expansion into general past reference runs from about 1450 onward. Agent H should see this as a structural hole rather than as a local defect in any one sentence, since my F8 replacement prose has to introduce the period name cold.
- F10 and G7 are NOT a contradiction, and I want that on the record before agent H reads them side by side. F10 says the werden future "created a three-way temporal system" while G7 says modern German has "two morphological tenses". F11, the clause immediately after F10, reconciles them explicitly: the third slot was built "through periphrasis rather than new morphological conjugations of the verb itself". Do not flag.
- Editorial, for Josh rather than for a finding: the section heading `The Future Tense and Modal Verbs` at line 164 promises modal verbs that the section never delivers. The modals arrive one section later, at line 169, in their capacity as preterite-presents. Either the heading should shed "and Modal Verbs" or the two sections should be adjacent in a way that earns it.
- The Phase 0 notes already record the two English style defects in my range, and my replacement prose leaves both untouched because neither is in a row I own. Line 157 has a comma splice, and line 171 has "The peculiar conjugations ... reflects", a subject-verb disagreement whose German counterpart "spiegeln ... wider" is correct. If Josh takes the F16 replacement he is editing that sentence anyway, which makes it the cheapest moment to fix the verb agreement.
- $kAnN$ occurs three times in line 171 and its final capital N is hard to derive from any regular composition of können. Phase 0 already routed it to Phase 3, and my F16 replacement carries the span through verbatim rather than silently repairing it, so the two changes stay independent.
- On F5 and F6 I deliberately returned two confirmations where the brief anticipated the sentences might fail in opposite directions. Taken singly, F5 does understate the Upper German case, since in High Alemannic the preterite is gone outright rather than merely receding. But F5 and F6 are consecutive sentences and F6 supplies the north and the high-frequency verbs, so the pair is well calibrated. Splitting them and grading the halves separately would have manufactured a finding out of a correct paragraph.
- The oberdeutscher Präteritumschwund is never named in the essay. That is a defensible choice for a general-audience piece, but it is the one place in this cluster where a German term would carry real weight for a reader of a German-learning app, and Josh may want it. It is not a correction, so I am not proposing prose.

**Cluster G**

- Required coverage note, per the brief: the essay never uses the terms Konjunktiv I or Konjunktiv II, never discusses indirect speech or the decline of Konjunktiv I in speech, and never mentions Luther. Its entire subjunctive discussion is about Konjunktiv II. All four topics appear in this cluster's brief, and their absence is why the cluster has seventeen rows rather than thirty. Nobody failed to report them; there was nothing to report. Do not read this silence as coverage.
- For agent H, an internal contradiction inside my own range that I have also filed as finding G4: line 174 labels käme 'Old', and line 177, three lines later, exempts 'common verbs' from the würde takeover. Kommen is a common verb and käme is on Duden's list of surviving synthetic forms, so the example contradicts the rule the same section states. This is the only place in the cluster where the essay argues against itself.
- For agent H, a softer seam of the same kind: line 172 attributes the rise of würde to subjunctive forms becoming identical to indicative ones, and then illustrates it at line 174 with käme, whose form is not identical to anything. The causal claim is accurate for the weak verbs and for the syncretic slots of Konjunktiv I, so it is not an error, but the example chosen is the one verb class the cause does not reach. If G4's relabelling is applied, the tension is reduced but not removed.
- For agent H, on the round numbers: every '5,000 years' in the essay keys to line 126's 'around 3000 BC', not to S1's patched 3300 BC Yamnaya horizon. G13 and G16 are consistent with each other and with lines 92 and 125, so nothing needs changing, but H should know the two anchors coexist and that a future edit moving one of them has to move four sentences, at lines 92, 125, 185 and 187.
- Phase 0 already flagged two English style violations in my range and I confirm both are still there: line 187 is fine, but line 171, 'The peculiar conjugations ... reflects', has a subject-verb disagreement, and line 157 has a comma splice. Neither is an inventory row and neither is mine, but both sit at the edge of my sections and both remain unfixed.
- Editorial, for Josh rather than for a researcher: if G8's replacement is adopted, the German at line 146 gains a construction name, am-Progressiv, that has a settled German term and does not need translating. The German bullet already carries its English glosses ('he reads/is reading') unchanged from the English, so the counterpart sentence should keep that habit and gloss er ist am Lesen the same way.
- Method note on search economy: eleven distinct web searches plus eight page fetches covered all seventeen rows. Seven rows cost nothing, either because they are arithmetic against the essay's own dates (G13, G16), because they restate a claim another cluster owns (G10, G11), or because the research was already done and recorded (G14). Four IDS grammis pages and one Duden Sprachratgeber page carried most of the load and are worth reusing: grammis systematische-grammatik/315 on subjunctive syncretism, grammis fragen/4551 on the progressive, grammis terminologie/355 on the sein-passive, grammis systematische-grammatik/439 on the form inventory.

## Blocked sources

- **[A]** https://www.nature.com/articles/s41586-024-07597-5 returned a 303 to an idp.nature.com authorization gate. Routed around via the open-access author copy at ut3-toulouseinp.hal.science/hal-04607980v1/file/Librado_2024.pdf and the paper's own title claim, which carries the 2200 BC date.
- **[A]** https://pubmed.ncbi.nlm.nih.gov/34671162/ fetched but rendered without the abstract body, returning only title, authors and affiliations. Routed around via the PubMed Central full text, which gave the abstract verbatim.
- **[A]** https://www.ncbi.nlm.nih.gov/pmc/articles/PMC8550961/ issued a 301 cross-host redirect to pmc.ncbi.nlm.nih.gov, which the fetch tool does not follow automatically. Refetched at the redirect target successfully; not a block, recorded so the next agent does not repeat the round trip.
- **[B]** https://www.britannica.com/event/Battle-of-the-Teutoburg-Forest returned HTTP 403 Forbidden on direct WebFetch. Routed around it by using Wikipedia's Battle of the Teutoburg Forest article and Jona Lendering's Livius.org treatment, which is signed, dated and more explicit about historiographical caution than Britannica would have been, for B1, B5, B6 and B9.
- **[B]** https://www.britannica.com/place/Agri-Decumates was not fetched directly, since britannica.com had already 403ed on this host. Its statement that the Romans were displaced from the Agri Decumates by the Alamanni in about AD 260 was taken from the search summary and cross-checked against Imperium Romanum and Wikipedia's Limes Germanicus article, which independently give about 260 as the end of Roman tenure east of the Rhine.
- **[C]** https://link.springer.com/content/pdf/10.1007/BF00191554.pdf — 303 redirect to https://idp.springer.com/authorize, an authentication host. Behre's 'The history of rye cultivation in Europe' full text unreachable. Routed around it using the article's indexed abstract and summary content plus the independent Danish iron-smelting-furnace paper and the Overbygård granary paper for the same period.
- **[C]** https://academic.oup.com/book/61598/chapter/538746296 — Oxford Academic returned only site navigation and header markup, no chapter body, for 'The Earliest Period of Runic Writing'. Routed around it via the Vimose and Meldorf object records and the Barnes handbook's characterisation in the Medieval Review notice.
- **[D]** https://www.ling.upenn.edu/~kroch/courses/lx310/handouts/handouts-09/ringe/pie-pgmc-vb.pdf — 403 Forbidden. This was Ringe's own PIE-to-Proto-Germanic verb handout and would have been the best single source for D2 through D7. Routed around via Lehmann's Grammar of Proto-Germanic at lrc.la.utexas.edu and Kim 2019.
- **[D]** https://www.ling.upenn.edu/~rnoyer/courses/51/PIEVerbs.pdf — 403 Forbidden. Would have covered the PIE moods, the augment's distribution, the future question and root shape in one place. Routed around via the LRC Proto-Indo-European Syntax and Phonology volumes and the comparative literature on the augment.
- **[D]** https://eprints.nottingham.ac.uk/73689/1/FINAL.pdf — 301 to repository.nottingham.ac.uk, which then returned 405 Method Not Allowed. This is an open-access thesis on the Germanic dental preterite and would have been a second independent source for D13. Not needed in the end: Kiparsky's paper fetched successfully and states the consensus point verbatim.
- **[D]** https://www.merriam-webster.com/dictionary/crow — 403 Forbidden. Wanted for the usage label on the past tense crew for D17. Routed around via Wiktionary, which gives "crowed or (UK) crew" with the note that crew is confined to literary and metaphorical uses.
- **[D]** https://www.collinsdictionary.com/dictionary/english/crow — 403 Forbidden. Same purpose as the entry above, same workaround.
- **[E]** https://www.britannica.com/topic/Old-High-German returned HTTP 403 Forbidden. Routed around it by fetching https://en.wikipedia.org/wiki/Old_High_German for the dialect geography and by taking the periodization from a second search that surfaced the same '500/750 to 1050' convention, so nothing decisive was lost.
- **[E]** https://www.academia.edu/1819630/ (Salmons draft, 'The High German Consonant Shift and Language Contact') and the three Journal of Germanic Linguistics articles on the shift are paywalled or login-walled and were not fetched. Not decisive: the phase structure of the shift is uncontested and was established from Wikipedia's High German consonant shift article and Citizendium's Second Consonant Shift, which agree on which stops shifted where.
- **[E]** https://www.jstor.org/stable/40849304 ('From Reduplication to Ablaut: The Class VII Strong Verbs of Northwest Germanic') is behind JSTOR; cited from its title and abstract only, and only for the uncontested point that Northwest Germanic class VII reanalyzed reduplication as vowel alternation.
- **[F]** https://www.degruyterbrill.com/document/doi/10.1515/bgsl-2021-0028/html?lang=en returned HTTP 405 Method Not Allowed on the Hartmann "Diachronie der Zukunft" article. Routed around it via the search-result summary, which carried the ReM and Bonn corpus counts verbatim (143 against 39 in the thirteenth century, 9 against 502 in the sixteenth). The de Gruyter host also 301-redirects from degruyter.com to degruyterbrill.com, so the redirect and the 405 compound.
- **[F]** https://www.degruyterbrill.com/document/doi/10.1515/ZFSW.2009.027/html returned HTTP 405 on "Die Entstehung des periphrastischen Perfekts mit haben und sein im Deutschen". Routed around it for F2 via the Old High German Tatian and Otfrid participle-agreement evidence and the emergent-structure paper, which give the same OHG-to-MHG progression.
- **[F]** https://benjamins.com/catalog/slcs.207.07fis returned HTTP 403 on Fischer's "The Präteritumschwund in German dialects: How to get lost". Routed around it via the ZRS review of Fischer's 2018 monograph, which reports the north-south gradient and the sein-before-modals-before-weak-verbs hierarchy directly.
- **[F]** https://link.springer.com/chapter/10.1007/978-3-031-85292-3_7 issued a 303 redirect into an IdP authorization endpoint on "The Preterite Loss in Southern German". Not fetched. Its content was not decisive, since the German Wikipedia Präteritumschwund article and the Fischer review together settle F5 and F6.
- **[G]** https://opendata.uni-halle.de/bitstream/1981185920/8835/1/Diss_Mihajlovic.pdf — Anubis bot-verification interstitial returned instead of the PDF. This was Mihajlović's dissertation on the Middle High German Konjunktiv, which would have been the best single source for G1 and G2. Routed around via the IDS grammis systematic grammar page on Konjunktiv/Indikativ syncretism, which states the same facts about the modern language directly and is a stronger source for the synchronic half of G2.
- **[G]** https://www.degruyterbrill.com/document/doi/10.1515/bgsl-2016-0017/html — HTTP 405 Method Not Allowed. This was the Beiträge zur Geschichte der deutschen Sprache und Literatur article on the am-Progressiv and parallel am V-en sein constructions. Routed around via the IDS grammis question page on the Verlaufsform and the Duden-Redaktion's own Klosa paper hosted at ids-pub.bsz-bw.de, both of which cover G8's substance.
- **[G]** https://lib.chmnu.edu.ua/pdf/metodser/122/9.pdf — TLS certificate expired, fetch refused. A teaching text on the Old High German verb. Not decisive; the Braune/Reiffenstein-derived summary already gave the mood and tense inventory G1 needed, and grammis corroborated the paradigm shape.

## What Phase 2 does with this

Per the runbook: pipeline each cluster's findings into an independent skeptic instructed to
**refute** them, researching each proposed correction independently rather than re-reading the
first agent's sources. Default to skepticism. The inventory replaces the old hunt-the-range job
with a cheap check, since every row here has a verdict: confirm the coverage table above, and
challenge thin `confirmed` reasoning without opening fresh research on settled rows.

Four things in this document are worth pointing a skeptic at first.

1. **B12 leans on Wikipedia.** Its author says so and offers the downgrade to nitpick without
   being asked. The claim itself is elementary, so the exposure is the grading rather than the
   fact.
2. **R6 and R2a rest on Wiktionary reconstructions**, both at medium confidence. R6 asserts that
   `*n̥-péh₂-tōr` is not a reconstruction the handbooks give of anything, which is an argument
   from absence and is exactly the shape of finding the Conjugar skeptic pass killed most often.
3. **F8 argues the essay is right about the onset and wrong to stop there.** That is a finding
   about what the essay omits, and a skeptic should test whether the omission misleads.
4. **C9 and C13 both narrow an absolute.** Each turns on what counts as a monument and what
   counts as a temple, so each can be defended by reading the essay's word more charitably.

Phase 3, the app-internal agent, is untouched by all of this and can run independently. Agent H
has already handed it two spans to adjudicate: `$nahm$` against `$gAb$` at H11, where whichever
value is right the pair cannot both be, and the `$mAde$` / `$saId$` / played list at H13, where
the essay marks as irregular two of the three exemplars of its own regular pattern.
