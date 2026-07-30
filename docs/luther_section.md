# The Luther section: what shipped, what did not, and why

**Status: SHIPPED, 2026-07-29.** Both localizations are in `Localizable.xcstrings`. Written against
[`prompts/luther-bible-section.md`](../prompts/luther-bible-section.md), which briefed four candidate
claims and predicted a ranking. **Two shipped, two were refuted, and the ranking was wrong in both
directions**: the candidate rated strongest survived only after being reframed, and the candidate
rated weakest turned out to be the best-evidenced thing in the section.

Nine agents: five researchers, three skeptics, one adjudicator. About 1.9M subagent tokens.

## The section

Nineteenth heading, between `Preterite-Present Verbs` and `The Subjunctive and Modern German`, which
is where the brief preferred it. 248 English words including the heading, 241 German. Structure:
Luther did not create the standard and said so; the Bible supplied reach rather than grammar; his
verbs are evidence of a change he did not cause; and one letter carries his name.

## Verdicts on the four briefed candidates

| # | Candidate | Brief's rank | Outcome |
|---|---|---|---|
| 1 | Final `-e` on verb endings | strongest, "visible in every paradigm cell" | **Ships, reframed.** The paradigm-wide claim is false and the app disproves it |
| 4 | Strong-verb preterite leveling | weakest, "most likely to produce an error" | **Ships, and it is the best-evidenced claim in the section** |
| 2 | The narrative preterite in writing | "best earns its place" | **Refuted by a natural experiment** |
| 3 | Syntax, Luther resisting the Satzklammer | plausible | **Unsupported as framed** |

### Candidate 1, reframed

The brief wanted the standard's verbal `-e` credited to East Central German retention with the Bible
as its vehicle. Three things broke.

- **"Visible in every cell of every paradigm" is false**, and the researcher disproved it against this
  repo rather than against a book: `machen`'s singular imperative is `mach`, and the strong preterite
  is `sAng`. Both are apocopated conjugations the app displays, and imperative *laufe → lauf* is one
  of the literature's canonical examples of the apocope.
- **The direction reverses inside the verb system.** Reiffenstein records that the Upper German
  literary language *preserved* `-e` in the strong preterite 1sg and 3sg, *ich sahe*, *ware*, after
  the rest of German had dropped it. Standard *ich sah* is the apocopating outcome.
- **The Bible is not a sourceable vehicle for it.** König has the letter *associated with* Luther's
  translation in Catholic territories; the spelling prevailed by orientation toward Gottsched, more
  than two centuries later.

What survives is the name, which is the finding. The section says only that scholars call it the
*lutherisches e* and that Jesuit colleges still taught from grammars written without it in the 1760s.

### Candidate 4, promoted

Verified from 1545 page images (BSB digitization of the Regensburg copy of *Biblia … Deudsch*,
Wittemberg: Lufft, 1545): Revelation 5:9 prints `ſungen ein Newlied`, and Revelation 15:3 the same.
The skeptic then tried to break its own finding by pulling OCR for all **1,556 page images of both
volumes, 1,130,702 words**, and found **zero preterite *sangen***. Every raw hit resolved otherwise,
including two checked against the images: *Honig ſaugen* (OCR misreading *u* as *n*) and *Sangen* as
the noun, ears of parched grain, at Leviticus 23:14.

The adjudicator then page-verified the pair the skeptic had left resting on Keller's prose: John
19:19, **"PIlatus aber ſchreib eine Vberſchrifft"**, preterite, coordinated with weak *ſetzte*, with
*geſchrieben* three verses later fixing the *ie* stem.

## Declined, with reasons, so nobody re-litigates them

### Candidate 2 was refuted by a natural experiment, not merely left unattested

Seiler and Weber measured the perfect's share of past-narrative contexts across twelve German Bibles.
Luther 1545 scores **0.04**, so the premise that his narrative is wall-to-wall preterite is true and
quantified. But the Zurich Bible *began as a revision of Luther's own text*: it scored 0.06 while
still copying him in 1524 and 1534, jumped to **0.63 in 1557** once it went its own way, held near
0.75 for two centuries, and returned to 0.07 only by 1860. A high-prestige Bible, printed and read
aloud for two hundred years in the most extreme *Präteritumschwund* region there is, did not hold the
narrative preterite.

Corroborating: Hans Sachs, a Nuremberg Lutheran and Luther's public champion, narrated in the perfect
about two thirds of the time throughout Luther's lifetime with no trend. Sapp puts **Saxony**,
Luther's own region, in the rising-perfect group. Fischer 2018 mentions Luther zero times in the
chapters that explain the change, and says at p. 132 that the tense-aspect history of the emerging
written standard is simply under-researched.

The Catholic-south objection was also sustained. Eck's 1537 translation took its New Testament from
Emser, who had changed roughly every tenth word of Luther's, and Eck's title page advertises it as
recast *"auf hochteutsch"*, in markedly Bavarian Upper German. **Dependence on Luther's text did not
transmit his morphology.**

### Candidate 3 had nothing to resist

In the sixteenth century the sentence brace was already fully formed in **80.1 percent** of main
clauses, partial in 16.9, absent in 3.0 (Kudo 1994). Its spread is attributed to the
grammaticalization of compound verb conjugations, since a brace presupposes an analytic verb, not to
chancery Latinism. Kudo is the one real measurement of Luther and it says something narrower:
*"die Klammer in der Bibel ist kurz"*, short braces with heavy material extraposed, and he positions
himself as **refining** Schildt's chronology rather than opposing it. His own causal reading kills the
plain-speech premise: *"Lutherdeutsch und die Umgangssprache lassen sich miteinander nicht ganz
gleichsetzen… Das ist wohl auf eine stilistische Absicht Luthers zurückzuführen."*

Two structural killers besides. **No study compares Luther against chancery prose at all.** And the
*Sendbrief vom Dolmetschen* never mentions the chancery; its targets are Latin-literalist translators,
and Luther aligned himself *with* the Saxon chancery. The verified fragment is "die mutter jhm hause,
die kinder auff der gassen, den gemeinen man auff dem marckt" (WA 30/II, 637). **The popular
*"dem Volk aufs Maul schauen"* is not Luther's wording.** He also contradicts his own programme about
110 lines later: "ich habe eher wollen der deutschen Sprache Abbruch tun, denn von dem Wort weichen."

### Four things cut from the draft itself

- **The staged scene.** The draft had "asked about his own German, he answered". No question exists in
  the record: the remark sits inside a monologue on Luther's competence in Greek and Hebrew, WA TR 1,
  524-525, and independently in Cordatus at WA TR 2, Nr. 2758a/b. The skeptic proved the absence
  rather than asserting it, since two entries earlier Nr. 1037 opens *"Quidam quaesivit Doctorem"*,
  so the tradition marks questioners when they existed. "At table" replaced it: two words restoring
  the true half of the scene after deleting the false half.
- **"wrote as the Saxon chancery wrote".** Luther's verb is *rede* and it stands in German in the
  manuscript; *schreiben* belongs to the next clause, whose subject is the imperial cities and
  princely courts. Four lines later he ranks Brandenburg speech above Saxon, which is unambiguously
  about speech. "Named the Saxon chancery his model" is true on either reading.
- **`ketzerisches e`.** The most vivid phrase in the draft, and it does not ship. No coiner is
  attributable, the earliest reachable attestation is an 1857 n-gram, the Deutsches Textarchiv and
  German Wikisource return zero, and the apparent source is a Wikipedia stub whose König footnote sits
  after the sentence that does not contain the name. Nobody in this run read König p. 101.
- **`ward` / "es ward Licht".** Cut for a subtler reason than its orthography (the 1545 print reads
  *Liecht*): *werden* is the one class III verb that generalized the **plural** vowel while its class
  generalized the singular, so yoking it to *sungen* with "and" presented one class moving two ways as
  one movement. And *ward* fails "his verbs are the older ones": still in *Buddenbrooks* in 1901,
  "veraltend" rather than *veraltet* in DWDS today, still printed in the Lutherbibel 2017.

## Two traps worth carrying forward

1. **German uses *Ausgleich* in two senses.** *Sprachausgleich*, the compromise written variety, **is**
   routinely credited to Luther. *Numerusausgleich*, the preterite leveling, is not. Conflating them
   produces exactly the indefensible claim this section exists to avoid.
2. **Modernized reprints will confirm a false morphology claim.** The archive.org "Luther Bibel 1545"
   and the widely mirrored `luther-bibel-1545.de` e-text are modernized or based on a nineteenth
   century edition. Verify Luther's morphology against page images or `stilkunst.de` (Volz/Blanke),
   never against those two.

## Adjudication

One neutral adjudicator, told to decide rather than attack, and told why: the previous run's
second-opinion pass moved 14 findings and **all 14 moved toward a stronger finding**, which measures
the instruction rather than the truth. This one moved in both directions.

**24 claims: 19 upheld, 3 moved stronger, 2 moved weaker.** The three strengthenings share a shape,
a skeptic reaching for the hedging bucket where no hedge repairs the defect, so a re-scoping, a
restructuring, and a deletion. The two weakenings share the opposite shape, a skeptic reaching for
the error bucket where the draft was narrow or loose but not false.

The budget and the evidence pointed at the same words. The nine words needed to fit the 250-word
ceiling came out of `ketzerisches e`, the material trusted least, so no verified claim was cut to make
room. The skeptic's proposed cut, the schoolchildren clause, was rejected: it is the only **uptake**
evidence in the paragraph, since print figures are supply-side and a book can be printed four hundred
times without entering anyone's competence.

## Mechanics

- **Zero new `$…$` spans**, deliberately, so the 25-span byte-identity invariant between the two files
  did not move. Historical conjugations (*sungen*, *sungum*, *schreib*) cannot be arbitrated by
  `Conjugator.conjugate(infinitiv:conjugationgroup:)` because the app conjugates no Early New High
  German, and regular ones (*mache*, *sagte*) come back with no uppercase, so a span would mark
  nothing. Everything cited stays in `~…~`.
- A temporary probe suite asked the app for 24 conjugations before drafting, then was deleted. Two
  results shaped the section: the weak conjugations came back entirely lowercase, and the app's
  marking is wider than the ablaut vowel (`wUrdE`, `gING`, `stÄNDe`), so reasoning a span out by hand
  would have produced `wUrde` and `gIng`, both wrong.
- Counts after the edit: **19 headings, 25 conjugation spans, 81 emphasis spans, 25 asterisks**. The
  German header's three count claims were updated; the English header states only the asterisk count,
  which did not change.
- One deliberate cross-language asymmetry: English `~lutherisches e~`, German `~lutherische e~`, weak
  declension after the article. Covered by the German header's existing rule that emphasis spans
  differ in wording while their count matches.

## Where the H19 gap stands

The brief hoped a Luther section might narrow agent H's item H19, the essay's unbridged jump from
Proto-Germanic in the far north to Old High German in the far south. **It does not, and the reason is
worth recording so nobody tries again on this route.** East Central German is a late settlement
variety formed by medieval eastward expansion, so it bridges west to east, not north to south. Besch's
"geographisch und sprachlich in der Mitte" is about prestige geography rather than migration. H19 is
still open.
