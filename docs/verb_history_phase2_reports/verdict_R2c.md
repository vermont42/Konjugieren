# R2c — verdict: partly · grade: factual-error (survivor), Phase 1's fix rejected

## Why

The sentence at line 92 reads:

> its echoes are still audible: it became Proto-Germanic *þeudō, then Old English þēod (“nation”), then, through Medieval Latin theodiscus (“of the people”), Modern German Deutsch.

Three "then"s in a row, with no branching and with "through" naming a route, is a line of descent. Read
that way, the sentence tells a reader that Modern German Deutsch descends from Old English by way of
Latin. Nobody holds that. Old English þēod is a sister reflex of Proto-Germanic *þeudō, not an
ancestor of any German word, and the German adjective is an -isk formation on the Germanic noun,
not on an Old English noun. The paragraph's closing hedge, "may trace back to a five-thousand-year-old
way of saying 'us'", hedges the PIE end of the chain, which is the part that needs it least; it does
nothing to qualify the middle links. So the core of the finding stands, and I grade the survivor
factual-error: a reader is actively misinformed about where Deutsch comes from.

What does not survive is Phase 1's flat treatment of the *Latin* link as a second, equal error, and
its replacement prose.

Two corrections to Phase 1's framing:

1. **The 786 attestation is Old English, not Old High German.** George of Ostia's letter to Hadrian I
   reports that the decrees of the English synods were read out "tam Latine quam theodisce". Etymonline
   states the point flatly: the 786 Latin form "refers to Old English". The second attestation, the 788
   Frankish annal "quod theodisca lingua herisliz dictum", is the Frankish one. Phase 1's "What is
   actually true" does mention the English synods, but its replacement prose then hands 786 to Old High
   German anyway.
2. **The Latin-to-German routing is a live minority position, not a plain error.** Medieval Latin
   theodiscus is attested from 786; the native Old High German adjective is not attested until much
   later, "ahd. thiutisk (um 1000)" per DWDS, and per EWA/Kluge-derived accounts first in the
   tenth-century Tegernsee Virgil glosses and then in Notker. That roughly two-century gap is the basis
   of a real scholarly argument that the German word followed the Latin one as a Lehnübersetzung rather
   than the other way round. Phase 1 relegates this to a parenthetical "minority position"; it is the
   reason the essay's third arrow is a hedging problem rather than a falsehood. Only the Old English
   arrow is simply wrong.

So: defect real, grade factual-error, cause narrower than Phase 1 says, fix unusable as written.

## What is actually true

Proto-Germanic *þeudō 'people' has reflexes across West Germanic: Old English þēod, Old Saxon thiod,
Old High German diot. From it, with the ordinary Germanic adjective suffix *-iskaz, comes the adjective
*þiudiskaz 'of the people, vernacular', whose reflexes are Old English þēodisc, Old Saxon thiudisk, and
Old High German diutisc. Modern German Deutsch continues diutisc through Middle High German diutisch,
diutsch, tiutsch. DWDS presents the German word as inherited, from germ. *þeuðō with the -isk- suffix,
not as a borrowing.

Medieval Latin theodiscus is a Latinization of that West Germanic adjective and is used in Latin only
of languages. Its earliest attestation, 786, is in the papal legate's report on the English synods and
refers to the vernacular of England, that is, to Old English. Its earliest Frankish use is 788. Because
the Latin form is attested some two centuries before the German one, the direction of influence at the
German end is disputed; what is not disputed is that the German adjective is a Germanic -isk formation
and that Old English lies on no line of descent to German.

Phase 1's "What is actually true" is correct on every point it makes. Its defect is one of emphasis: it
presents the inherited account as settled and the loan account as a footnote, and that footnote is
exactly what its own replacement then contradicts.

## Phase 1's replacement prose

> it became Proto-Germanic *þeudō, which gave Old English þēod (“nation”) and, with an adjective suffix,
> Old High German diutisc, the word Latin scribes recorded as theodiscus (“of the people”) in 786 and
> the ancestor of Modern German Deutsch.

Markup is clean: no `~`, `$`, backtick, `‡` or `^`, the single asterisk on *þeudō is unpaired as the
convention requires, the curly quotes match the essay, and both glosses are carried over from the
original rather than newly added. The branching structure is the right repair.

It fails on content. "Old High German diutisc, the word Latin scribes recorded as theodiscus in 786"
asserts that the 786 record is a record of the German word. It is not; it is a record of the English
vernacular's name for itself. The sentence also silently closes the attestation gap that drives the
scholarship, presenting a word first attested around 1000 as the thing a scribe wrote down in 786. That
is a new error introduced in the course of fixing an old one, and it is a more specific error than the
one it replaces.

## Revised replacement prose

English, for line 92, replacing from "it became" to the end of that sentence:

> it became Proto-Germanic *þeudō, which gave Old English þēod (“nation”) and, with a Germanic
> adjective suffix, Old High German diutisc, the ancestor of Modern German Deutsch. Latin scribes were
> writing the Germanic adjective as theodiscus (“of the people”) by 786, some two centuries before the
> German form itself is attested.

This branches instead of chaining, keeps both existing glosses, adds no parenthetical and no em dash,
leaves the following sentence ("The word 'German', in other words, may trace back…") intact and still
true, and converts the essay's flat Latin routing into a dated observation that is compatible with both
sides of the live dispute. Markup unchanged: no delimiters introduced, asterisk unpaired.

German counterpart, `docs/verb_history_de.txt` line 58. Phase 4 will need to rebuild the same clause,
which currently runs "Daraus wurde protogermanisch *þeudō, dann altenglisch þēod („Nation“), dann, über
mittellateinisch theodiscus („des Volkes“), neuhochdeutsch Deutsch." The German must lose the "dann …
dann … über" chain in favour of the same branching, must keep þēod and diutisc as sister reflexes
rather than successive stages, must carry the added dating sentence about 786 and the attestation gap,
and must keep *þeudō, þēod, diutisc and theodiscus unlocalized while using the German low quotes
„…“ already in the line. The trailing sentence "Das Wort „deutsch“ geht also möglicherweise auf eine
fünftausend Jahre alte Art zurück, „wir“ zu sagen." needs no change.

## Strongest case for the finding, and my answer

The strongest case for Phase 1 grading both links as errors is that the essay routes German through
Latin flatly, and the handbook of record, DWDS, does not: it presents deutsch as an inherited Germanic
formation and mentions theodiscus only as the Latinized shape in which the adjective first surfaces.
On that reading the essay contradicts the standard reference and is simply wrong twice.

My answer: DWDS's presentation is a choice of emphasis in a dictionary that does not litigate
controversies, not a demonstration that the loan account is dead. The attestation facts DWDS itself
prints, Latin from 786 against ahd. thiutisk um 1000, are precisely the evidence the loan account rests
on, and the specialist literature has not closed the question. A claim a serious minority defends is a
hedging failure when stated flatly, not a falsehood. The Old English link is different in kind: no
account of any stripe derives German Deutsch from Old English, so that one is a real error and it is
enough on its own to carry the factual-error grade.

The strongest case against my own position is that I am splitting a sentence a reader consumes whole,
and that whether the misinformation arrives via the second arrow or the third, it arrives. I accept
that, which is why the verdict is partly and not refuted, and why the grade stays at factual-error
rather than dropping to needs-hedging. The split matters only for the fix, and there it matters a great
deal, because Phase 1's fix repairs the arrow that was wrong by asserting something else that is wrong.

## Sources

- Etymologisches Wörterbuch des Deutschen (Pfeifer), s.v. *deutsch*, DWDS
  <https://www.dwds.de/wb/deutsch>
  > Gives "ahd. thiutisk (um 1000), mhd. diutisch, diutsch, tiutsch, tiusch" with West Germanic
  > cognates, derives the adjective from "germ. *þeuðō 'Volk'" with the -isk- suffix, and reports that
  > the Latinized form appears "already at the time of Charlemagne (since 786)". The German word is
  > presented as inherited, not borrowed. Load-bearing here for the ~1000 date, which sets the gap.
- Online Etymology Dictionary, s.v. *Dutch* <https://www.etymonline.com/word/Dutch>
  > The language name appears in Latin as *theodice* in a 786 document, in "correspondence between
  > Charlemagne's court and the Pope, in reference to a synodical conference in Mercia; thus it refers
  > to Old English." Also gives Proto-Germanic *theudō as the "source of Modern German Deutsch."
  > Tertiary, but the 786-is-Old-English point is uncontested and independently corroborated below.
- Wikipedia, "Theodiscus" <https://en.wikipedia.org/wiki/Theodiscus>
  > "Theodiscus was a word borrowed directly from West Germanic itself", from Proto-Germanic
  > *þiudiskaz, stem *þeudō 'people' plus adjectival *-iskaz; first attested c. 786 in the bishop of
  > Ostia's letter to Pope Adrian I reporting that synod decisions in England were read "tam Latine
  > quam theodisce". Tertiary; cited only for the 786 wording and the *-iskaz formation, both of which
  > the handbook sources also carry. Phase 1 leaned on this article for a share of its case, which is
  > worth naming plainly.
- Reichsannalen 788, as reported in the same literature: "quod theodisca lingua herisliz dictum",
  the earliest Frankish use, two years after the English one. Establishes that 786 and the first
  continental use are distinct events, which is what defeats Phase 1's replacement.
- Secondary German summaries of the Rückentlehnung argument, e.g.
  <https://www.julifaber.de/post/woher-kommt-das-wort-deutsch>
  > "Es wurden erst 200 Jahre nach dem Auftreten dieser Form Belege für die entsprechende deutsche
  > Form diutisc gefunden… wir können davon ausgehen, dass es eine Lehnübersetzung, also eine
  > 'Eindeutschung' des lateinischen theodisce war." A popular essay, not scholarship, and I do not
  > rest the verdict on it; it is cited only as evidence that the loan account circulates as a live
  > reading, alongside the attestation dates DWDS prints independently. The same summaries report EWA's
  > dating: "Einheimisches ahd. diutisc tritt erst in den Tegernseer Vergilglossen des 10. Jh.s, dann
  > öfters bei Notker auf; seit dem Annolied um 1080 ist diutisc in der dt. literarischen Überlieferung
  > fest etabliert."

## Blocked sources

- Etymologisches Wörterbuch des Althochdeutschen (EWA, SAW Leipzig), article *diutisc*,
  <https://ewa.saw-leipzig.de/articles/diutisc/de> — returns HTTP 404 to WebFetch on two attempts,
  apparently a JavaScript-rendered single-page app rather than a real 404, since search indexing shows
  the article exists and reports that "the Old High German term diutisc is much later attested than
  the Medieval Latin theodiscus." This would have been the best single source for the attestation gap.
  Routed around via DWDS's own um-1000 dating, which carries the same weight for my purposes.
- Reallexikon der Germanischen Altertumskunde / Germanische Altertumskunde Online, "Theodiscus"
  (Haubrichs and Wolfram), <https://www.degruyter.com/database/GAO/entry/RGA_5710/html> — De Gruyter
  paywall. This is the standard specialist treatment and would settle the state of the debate
  definitively. Not decisive for the verdict, since the verdict turns on the Old English arrow, which
  no source disputes.
