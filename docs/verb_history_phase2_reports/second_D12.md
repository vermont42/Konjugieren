# D12 · final verdict: partly · grade: nitpick

Essay line 153; German counterpart line 119. Phase 1: nitpick, medium confidence. Phase 2 skeptic:
refuted, none. My disposition: the skeptic wins the argument it actually had, and loses a smaller
one it did not know it was having. The prose stays exactly as written. One character of markup
inside the span D12 quotes is wrong, and the skeptic's own defense of the sentence leans on that
character.

The sentence:

> This is the origin of the "-te" ending in German preterites (machte, sagte, spielte) and the
> "-ed" ending in English ($mAde$, $saId$, played).

## What the skeptic got right

Three things, and they are the load-bearing three.

**The sentence asserts an origin, not a spelling, and the origin claim is true of all three
examples.** *Made*, *said* and *played* are all descendants of the Proto-Germanic weak preterite:
Old English *macode* (from *macian*, weak class 2), *sægde* (from *secgan*, weak class 3), *plegode*
(from *plegian*, weak class 2). Every one of them carries the dental suffix the paragraph is about.
Phase 1 conceded this in its own "Why" paragraph, which is close to conceding the finding.

**"The -ed ending" is the ordinary name of the English past suffix, not a claim about how any
particular verb is spelled.** The suffix has three spoken allomorphs, /d/, /t/ and /ɪd/, and the
whole set is conventionally called "-ed". *Played* /pleɪd/, *made* /meɪd/ and *said* /sɛd/ all end
in the /d/ allomorph, and in *made* and *said* that /d/ is the suffix itself, not a stem consonant:
the stem consonants are what disappeared (*mac-*'s `c`, *sæg-*'s `g`), and the dental survived. So
the examples are examples of the thing the sentence names them for, and the only thing missing is
the digraph.

**Phase 1's replacement prose should not be applied.** I agree with the outcome and only half agree
with the reason. The skeptic's decisive objection is the second one it raises: replacing `the "-ed"
ending` with "the English dental preterite" takes away the one handle an English-speaking learner
already owns, and it kills the `-te` / `-ed` symmetry that makes the sentence land. That objection
is right and by itself settles it.

## Where the skeptic is wrong, or is not

**Not wrong: the charge of uncharitable reading does not stick, mostly.** I went looking for the
usual Phase 2 failure mode, a sentence lifted out of its paragraph and read as though it were a
definition. The skeptic did the opposite. It put the sentence back into a paragraph whose subject
is the Proto-Germanic dental suffix and read the parenthesis as illustration rather than as
orthographic inventory. That is the right reading, and the surrounding text supports it: the
previous sentence names the suffix, and the next paragraph goes on to the *dō-* compound theory.
Nothing in the neighborhood invites a letter-matching reading.

**Wrong on "worn down".** The skeptic calls Phase 1's replacement "a worse error than the one it
was written to fix" because "worn down" supposedly predicates erosion of the suffix, which did not
erode. But Phase 1's head noun is "the English dental preterite", not "the dental suffix", and the
dental preterites *made* and *said* genuinely are worn down: *macode* to *made* is exactly wearing
down. The skeptic picked the reading that makes the sentence false when a natural reading makes it
true. This does not change the outcome, because the "-ed" handle objection kills the replacement on
its own, but a kill should not be recorded on a misreading.

**Wrong on the cognates.** The skeptic's account of what the trio buys is that *machen/make*,
*sagen/say* and *spielen/play* are "cognate pairs", so the parenthesis shows the same three verbs
taking the same dental preterite on both sides of the North Sea. Two of the three are cognate. The
third is not. English *play* is Old English *plegan/plegian*, from Proto-West-Germanic
*plegōjanan, whose German cognate is *pflegen*, not *spielen*; German *spielen* is Old High German
*spilōn*, whose Old English cognate is *spilian*, which died out in Middle English. *Spielte* and
*played* are a translation pair, not an etymological one. Nobody should build a rewrite on a
premise that is one third false, and this is the kind of supporting claim that gets promoted into
essay prose two phases later if it is left standing in a verdict file.

**Wrong on "a claim nobody reported", and this is the one that matters.** The skeptic's third
pillar is that the essay's markup already handles the distinction, since `$mAde$` and `$saId$`
redden a letter apiece and red means irregular. It then sets aside, in a parenthesis, whether `A`
is the right letter to redden in *made*, on the ground that this is "a separate question about a
claim nobody reported". Somebody reported it. Phase 1's internal-tensions agent filed H13
(`docs/verb_history_phase1.md` line 1926) against this exact span, and its cluster-D researcher
filed a note at line 2202 saying the same thing in different words. The skeptic therefore leaned
its third argument on an element that was already under review, and treated as an asset the thing
another agent had flagged as a liability. Had it known, its "the markup handles it" move would have
been visibly circular.

And the letter is in fact wrong, which I establish below. That does not resurrect Phase 1's
complaint about spelling. It leaves a different, smaller true thing standing inside the same
parenthesis.

## My own research

I took neither prior agent's sources. Four searches plus three fetches, and one check that needed
no source at all because it is visible in the file.

**The philology is uncontested and both agents state it correctly.** *Macian* is the standard
Old English weak class 2 paradigm verb, *macian / macode / macod*; Middle English keeps *makede*
and *maked* beside the contracted *made*. *Secgan* is one of the four members of weak class 3
(*habban*, *libban*, *secgan*, *hycgan*), a class that attaches the dental directly to the root
with no medial vowel, giving *sægde*. So the skeptic is right that the two words did not get to
their modern shape by one and the same syncope, and Phase 1's "loss of the medial vowel" is exact
for *made* and wrong for *said*. Neither point moves the verdict, and I flag it only because Phase
1's "What is actually true" section would otherwise be copied forward as if it were.

**The essay's markup convention is recoverable from the essay itself, and it is letter-precise.**
There are seventeen distinct `$…$` spans in `docs/verb_history.txt`. Every one of them that
uppercases anything uppercases the letters that differ from the base form, and it does not restrict
itself to vowels:

- `$cAme$` (come), `$gAve$` (give), `$tOOk$` (take), `$crEw$` (crow), `$wOUld$` (will), `$gAb$`
  (geben), `$kÄme$`, `$sAng$`, `$sUng$`: the changed vowel, and only the changed vowel.
- `$genOMmen$` (nehmen): `O` for the vowel and `M` for the consonant that replaced `h`. So
  consonants are reddened when they change.
- `$lIest$` (lesen): the inserted `i`.
- `$kAnN$` (können): `A` for `ö`, and the final `N` because it stands where the regular `könne`
  would have `e`. Positional comparison against the expected form, again letter by letter.

Now run the same comparison on the two words in D12's span:

    say   s a y        make   m a k e
    said  s a i d      made   m a d e

*Said* changes at position 3, `y` to `i`, and the essay reddens position 3. `$saId$` is correct.
*Made* changes at position 3, `k` to `d`, and the essay reddens position 2. The `a` of *made* did
not change from anything: *make* is /meɪk/ and *made* is /meɪd/, the same vowel and the same letter,
and against a hypothetical regular *maked* the `a` is equally untouched. `$mAde$` therefore reddens
a letter that is not irregular, in an app where red means "this letter is irregular". It is the one
letter-imprecise span in the essay's seventeen, unless you also count `$nahm$`, which Phase 1's H11
flagged for the opposite fault of reddening nothing where *nehmen* to *nahm* changed the vowel. So
hand-written markup errors in this essay are an established category, not a category I am inventing
to save a finding.

**Cognacy.** Etymonline's *play* entry gives Old English *plegan, plegian*, Proto-Germanic
*plegōjanan, and lists Old Saxon *plegan*, Old Frisian *plega*, Middle Dutch *pleyen* and German
*pflegen* as cognates. It does not list *spielen*. Its *spiel* entry derives German *spielen* from
Old High German *spilon* and gives Old English *spilian* as the cognate. Two independent entries,
no overlap.

## Final disposition, and what Phase 4 should do

**Partly upheld, graded nitpick, and the action is one character, not one sentence.**

1. **The prose of line 153 does not change.** Phase 1's complaint that two of the three examples do
   not display the letters `e` and `d` is not a factual error and is not worth a hedge. The
   sentence names an origin, the origin is right for all three, and "the -ed ending" is the standard
   name for the suffix. Do not apply Phase 1's replacement. The skeptic's kill of the finding as
   Phase 1 framed it is upheld, and I would not have written this section any other way.

2. **`$mAde$` becomes `$maDe$`,** in all four sites, because the essay's own convention reddens the
   letter that changed and in *made* that letter is the `d`. Sites: `docs/verb_history.txt` line
   153, `docs/verb_history_de.txt` line 119, and both the `de` and `en` localizations of
   `verbHistoryText` in `Konjugieren/Assets/Localizable.xcstrings`, which today contain `mAde`
   twice. The German file's own header states the invariant that its 27 `$…$` spans are taken
   character for character from the English and currently match exactly, so the two docs files must
   move together or that invariant breaks.

3. **Route it through Phase 3, not around it.** Phase 1 routed span values to the app-internal
   agent, and H13 already owns this parenthesis with a broader question attached: whether it is
   coherent to redden two of the three exemplars of the essay's *regular* pattern at all. If Phase 3
   decides the spans should come off *made* and *said* entirely, item 2 is moot and that is a fine
   outcome. My contribution is the conditional: **if the span on *made* stays, it must be `$maDe$`.**
   Phase 4 should not make this edit blind, in isolation from H13, and should not make it at all if
   H13 has already resolved the span some other way. What Phase 4 must not do is record D12 as a
   clean kill, because that files the parenthesis as inspected and sound when one character in it
   is not.

Why nitpick and not none: red in this app is a claim, the claim is false of the `a` in *made*, and
the fix costs one character in four files with no prose risk and no translation risk. Why not
higher: no reader's understanding of German verb history turns on it, and the coarse signal the red
letter sends, "this verb is irregular", is true even where the letter it lands on is not.

## Replacement prose

None for the prose. The sentence's words are correct as written. The only edit is the span, shown
here in place so Phase 4 can see the exact target line.

English, `docs/verb_history.txt` line 153, tail of the sentence:

> This is the origin of the "-te" ending in German preterites (machte, sagte, spielte) and the "-ed" ending in English ($maDe$, $saId$, played).

German, `docs/verb_history_de.txt` line 119, tail of the sentence:

> Dies ist der Ursprung der "-te"-Endung in deutschen Präterita (machte, sagte, spielte) und der "-ed"-Endung im Englischen ($maDe$, $saId$, played).

Markers stay balanced, one `$…$` pair per word, one uppercase letter per span, no asterisks
touched, no em dashes, no new parenthetical. Length is identical to the character.

## Sources

- Etymonline, *play* <https://www.etymonline.com/word/play>
  > Old English *plegan, plegian*, from Proto-Germanic *plegōjanan; cognates listed: Old Saxon
  > *plegan*, Old Frisian *plega*, Middle Dutch *pleyen*, German *pflegen* "take care of,
  > cultivate". German *spielen* is not among them.
- Etymonline, *spiel* <https://www.etymonline.com/word/spiel>
  > "from German *spielen* 'to play,' from Old High German *spilon* (cognate with Old English
  > *spilian* 'to play')."
  Taken together with the previous entry, this settles that *spielen* and *play* are not cognate,
  contrary to the skeptic's supporting argument.
- Old English Online, weak verbs, class III <https://oldenglish.info/wv6.html>
  > Class III is reduced in Old English to *habban*, *libban*, *secgan* and *hycgan*; the dental is
  > attached with no medial vowel, giving *secgan* the preterite *sægde*.
  Confirms the skeptic's correction of Phase 1: *said* is not a syncopated form in the way *made*
  is, because there was never a medial vowel there to lose.
- Wiktionary, *made* <https://en.wiktionary.org/wiki/made>
  > "From Middle English *made*, *makede*, *makode* (preterite) and *maad*, *mad*, *maked* (past
  > participle), from Old English *macode* (first and third person preterite) ... from *macian*."
  Tertiary, and cited only for the form chain, which is uncontested and appears identically in
  Campbell and in Hogg and Fulk. The load-bearing observation about *made* in this report needs no
  source: it is that /meɪk/ and /meɪd/ share their vowel, which any reader can check.
- Konjugieren's own essay, `docs/verb_history.txt`, all seventeen `$…$` spans, and
  `docs/verb_history_de.txt` lines 20 to 26 for the German header's span invariant.
  > "Die 27 $…$-Spannen werden zeichenweise aus dem Englischen übernommen und stimmen derzeit exakt
  > mit ihm überein."
  This is the primary source for the markup convention, and it is better evidence than anything
  external, because the question is what this essay's red letters mean in this essay.
- `docs/verb_history_phase1.md` lines 1926 to 1934 (finding H13) and line 2202 (cluster D's note to
  Phase 3), which are what the skeptic's "a claim nobody reported" overlooks.

Note on prior source quality: Phase 1 rested on Wikipedia plus a Kiparsky paper cited for
syllable-weight-conditioned syncope, which does not bear on the point. The skeptic rested on
Etymonline, Wiktionary and one blog post on allomorphy. Neither reached a handbook, and neither
needed to, because the philology here is not disputed by anyone. The question that actually decides
D12 was never philological. It was what this essay's markup means, and that question is answered
inside the repository.
