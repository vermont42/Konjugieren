# C12 — verdict: partly — surviving grade: nitpick

## Why

Phase 1 makes two complaints about essay line 142. They deserve different answers.

**The asterisk complaint survives, barely.** Wōðanaz, Þunaraz and Tīwaz are Proto-Germanic
reconstructions, and every handbook that prints them prints them with an asterisk: Orel heads his
entries `*þunraz`, `*tīwaz`, `*wōđanaz`. The essay asterisks every other reconstruction it prints
(twenty asterisks, on *tewtéh₂, *tew-, *þeudō, *e-, *bʰer-, *bʰor-, *bʰr-, *ē, *mḗh₁-n̥s, *ō,
*n̥-péh₂-tōr, *-d-, *-t-, *dō-), and the source file's own header at lines 56 to 58 declares that
this is the convention. Three reconstructions printed bare inside an essay that marks the other
twenty is a genuine internal inconsistency.

It is also a very small one, smaller than Phase 1 allows. The header does not ship; the app reader
never reads a sentence explaining what the asterisks mean, so the inference Phase 1 fears ("a reader
who has learned that convention will take Wōðanaz for an attested form") requires a reader who
learned the convention elsewhere, which is a reader who already knows Proto-Germanic is unattested.
And the sentence itself is a sentence about religion, not about morphology: naming Germanic gods
bare in running prose, as "Wodan, Donar, Tiwaz", is ordinary usage in mythological writing, whereas
the essay's other asterisked items are all cited as lexemes and roots. Nobody is misinformed. Grade
nitpick, which is where Phase 1 put it, and I agree.

**The labelling complaint does not survive.** Phase 1 objects that only the first triple names its
languages, so "Thunor and Þórr" is Old English and Old Norse by position alone. That is not a defect,
it is an ellipsis of a pattern the first triple establishes precisely so the next two do not have to
repeat it; the parallel is exact and unmissable. The decisive evidence is that Phase 1's own
replacement prose keeps the asymmetry untouched, labelling Wōden and Óðinn and leaving Þunor, Þórr,
Tīw and Týr to positional inference. A fix that declines to fix the defect it alleges has conceded
the point. The nesting depth is a fair observation, and my prose flattens it, but that is a
readability tidy riding along with the asterisks, not a second finding.

## What is actually true

All three names are reconstructions and none is attested. Orel's *A Handbook of Germanic Etymology*
gives `*þunraz` (Old Norse theonym Þórr, Old English þunor 'thunder', Old Frisian thuner, Old Saxon
thunar, Old High German donar), `*tīwaz` (Gothic tyz the name of the z-rune, Old Norse theonym Týr,
Old English theonyms Tīg and Tīw, Old High German Ziu), and `*wōđanaz` (Old Norse theonym Óðinn, Old
English Wōden, Old Saxon Woden, Old High German Wuotan, derived from `*wōđaz`). So Phase 1's
descendant pairs are all correct, and its account of the standard forms is correct.

Two corrections to Phase 1's framing. First, `ð` versus `đ` versus plain `d` in *Wōðanaz is purely
notational for the same Proto-Germanic voiced dental fricative, as Phase 1 says; the essay's spelling
needs no change. Second, Phase 1 files *Þunaraz as "the less usual of two competing reconstructions"
and then silently replaces it with *Þunraz in its own prose. The disyllable is better supported than
that treatment implies: DWDS lists the Old Norse forms as "anord. Þōrr, älter Þunarr", an older
disyllabic Þunarr alongside Old Saxon Thunar and Old High German thonar, and Haukur Þorgeirsson's
2023 *Neophilologus* paper argues from Hymiskviða and Þórsdrápa metre that a disyllabic Old Norse
form is real. *Þunraz is the mainstream reconstruction and *Þunaraz is a live variant. Either may
stand; neither needs replacing, and a replacement that changes it without saying so is an unflagged
edit rather than a fix.

## Phase 1's replacement prose

> Their religion centered on a pantheon of gods whose names linguists reconstruct as *Wōðanaz, later
> Old English Wōden and Old Norse Óðinn; *Þunraz, later Þunor and Þórr; and *Tīwaz, later Tīw and
> Týr, among others,

Four problems, none fatal individually.

1. **It breaks the sentence's grammar.** The original reads "a pantheon of gods (…) worshipped in
   sacred groves rather than temples", with the parenthesis keeping "gods" and "worshipped" adjacent.
   The replacement drops the parenthesis, inserts a thirty-word relative clause with three
   semicolon-separated members, and leaves the participle "worshipped" stranded after "among others,"
   where its nearest available antecedent is "names". Names are not worshipped in groves.
2. **It changes three forms it never flagged**: Þunaraz to Þunraz, Thunor to Þunor, Tiw to Tīw. None
   of the three is a correction of an error, since the essay's spellings are all defensible, and the
   Þunaraz change contradicts Phase 1's own paragraph calling that form defensible.
3. **It leaves the second alleged defect in place**, as above.
4. **It makes the file header stale without saying so.** Line 57 reads "The twenty in this essay mark
   reconstructed forms". Adding three asterisks makes it twenty-three, and the header is a convention
   note nothing checks, so nothing will catch the slip.

Markup safety is fine in both versions: the sentence carries no `~ $ ‡ ^` markers and no backtick,
and asterisks are not markup here, so nothing about this edit can crash the Info screen.

## Revised replacement prose

English, replacing the parenthesis on line 142 and keeping the rest of the sentence:

> Their religion centered on a pantheon of gods (*Wōðanaz, later Wōden in Old English and Óðinn in
> Old Norse; *Þunaraz, later Thunor and Þórr; *Tīwaz, later Tiw and Týr; and others) worshipped in
> sacred groves rather than temples.

This adds the three asterisks, which is the whole of the surviving defect; drops the third level of
nested parentheses by turning the inner parentheses into commas and the separators into semicolons;
adds no new parenthetical aside and no em dash; keeps "gods" and "worshipped" bracketing the aside as
the original does; and leaves every form exactly as the essay already spells it.

Two follow-ons the editor must not forget. The header at line 57 should then read twenty-three rather
than twenty. And the German at `docs/verb_history_de.txt` line 108 needs the same three asterisks and
the same flattening, keeping its own Altenglisch and Altnordisch labels on the first triple only, so
that the two localizations agree; both ship as "translated", so an asterisk added on one side alone
would ship a bare Wōðanaz to German readers. Phase 4 owns the German wording.

If the editor would rather not touch the line at all, that is a defensible call. This is a nitpick,
and the sentence misinforms nobody as it stands.

## Strongest case for the finding, and my answer

The strongest case is that the essay does not merely name three gods, it names them in their
Proto-Germanic shapes rather than by any attested name. "Wodan", "Donar" and "Ziu" are attested Old
High German; "Wōden", "Þunor" and "Tīw" are attested Old English. The moment you write Wōðanaz,
Þunaraz and Tīwaz instead, you have stopped naming deities and started citing reconstructions, and
the asterisk is the field's universal mark for exactly that distinction. The essay has trained its
reader on five asterisked reconstructions before this paragraph and will show fifteen more after it.
So the omission is a real inconsistency, on the essay's own terms, in the one place where the
convention would carry information.

I accept all of that, which is why my verdict is partly and not refuted. What it does not establish
is any harm: the sentence supplies "later Wōden … and Óðinn", which tells the reader that Wōðanaz is
the ancestral form more plainly than an asterisk would, and no factual proposition in the sentence
changes whether the asterisks are there or not. A defect that is real, invisible to the target
reader, and carries no false proposition is the definition of a nitpick, and it does not climb to
needs-hedging, because nothing here is hedged or contested in the first place.

## Sources

- Vladimir Orel, *A Handbook of Germanic Etymology* (Brill, 2003), full text at
  <https://archive.org/stream/Orel-AHandbookOfGermanicEtymology/2003OrelV.-AHandbookOfGermanicEtymology_djvu.txt>
  > "*þunraz sb.m.: ON theon. Þórr, OE þunor 'thunder', OFris thuner id., OS thunar id., OHG donar
  > id. Related to Skt stánati 'to thunder', Gk στένω 'to moan, to sigh', Lat tonō id."
  > "*tīwaz sb.m.: Goth tyz 'name of z-rune', ON theon. Týr, OE theon. Tīg, Tīw id., OHG theon. Ziu
  > id. Related to Skt devá- 'god', Av daēvō 'demon', Lat deus 'god', Lith diēvas id. continuing IE
  > *deiuo-."
  > "*wōđanaz sb.m.: ON theon. Óðinn 'Odin, the highest god of the Germanic pantheon', OE Wōden id.,
  > OS Woden id., OHG Wuotan id. Derived from *wōđaz."
  (OCR mangles thorn and eth; the readings above are the obvious restorations of "*bunraz", "*tíwaz",
  "*w5čtanaz", "Pórr", "Sunor", "Trj", "Obinn".)
- DWDS, *Etymologisches Wörterbuch*, s.v. Donner <https://www.dwds.de/wb/Donner>
  > "anord. Þōrr, älter Þunarr, asächs. Thunar. Ahd. thonar (9. Jh.), mhd. doner, donre, dunre …
  > aengl. þunor, engl. thunder"; the god is named "Donar, vgl. anord. Þōrr"; root "ie. *(s)ten(ə)-
  > 'donnern, rauschen, dröhnen, stöhnen'".
- Haukur Þorgeirsson, "The Name of Thor and the Transmission of Old Norse Poetry", *Neophilologus*
  107.4 (December 2023), 701–713 <https://link.springer.com/article/10.1007/s11061-023-09773-w>
  > Abstract: the name "has the monosyllabic form Þórr in the extant manuscripts, but one Eddic poem
  > (Hymiskviða) and one skaldic poem (Þórsdrápa) have verses which metrically indicate a disyllabic
  > form with a short first syllable, hypothetically restored as *Þóarr, *Þóurr, *Þonarr or *Þunurr
  > … when the metrical question is examined in detail, there is a great deal of evidence for a
  > disyllabic form."
- The essay itself, `/Users/josh/Desktop/workspace/Konjugieren/docs/verb_history.txt`, header line 57
  > "Asterisks are linguistics, not markup. The twenty in this essay mark reconstructed forms:
  > *bʰer-, *e-, *dō-, *tewtéh₂, *þeudō. They do not pair, and balancing them would be an error."
  A count of the body confirms exactly twenty asterisks, all on reconstructed lexemes and roots, none
  on the three theonyms.

## Blocked sources

- <https://www.britannica.com/topic/Tiu> — HTTP 403. Wanted it only to sample how a general reference
  spells the god's name in running prose; Orel and DWDS settle the reconstructions without it.
