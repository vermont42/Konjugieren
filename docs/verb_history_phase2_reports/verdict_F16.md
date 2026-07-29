# F16 · verdict: upheld · grade: nitpick

## Why

I went looking for a way to kill this one and could not find it. The essay names six verbs in
line 169 (können, müssen, dürfen, sollen, mögen, wissen) and then, in the very next sentence,
attributes to "these verbs" two peculiarities. The first, no endings in 1s and 3s, is true of all
six. The second, vowel differences between singular and plural, is true of five and false of
sollen: ich soll, wir sollen. There is no hedge anywhere in the paragraph that rescues it. The
parenthetical is not marked as illustrative, and the surrounding sentences carry no "mostly", no
"typically", no "in most of them". The set is closed, explicit, and six members long, so a reader
who takes the sentence at face value acquires one false belief about one verb.

The obvious refutation, that the parenthesis quantifies nothing and merely supplies an example,
is weaker than it looks once you check how careful reference works handle the same sentence. The
IDS Grammis, describing exactly this feature, does not state it flatly either; it writes the
exception into the sentence itself: "Die Modalverben (außer sollen) und wissen besitzen getrennte
Präsensstammformen für Singular und Plural." When the standard German-language reference grammar
cannot state the generalization without a four-character parenthetical exception, an essay stating
it without one is imprecise, not merely brief.

What keeps this at nitpick rather than factual error is the cost of the mistake, which is close to
zero and self-correcting inside this particular app. Konjugieren is a conjugation app. A reader
puzzled by "vowel differences between singular and plural" can tap sollen and see soll/sollen laid
out. The false belief has a half-life of one screen. Nothing else in the essay depends on the
generalization, no historical claim is distorted by it, and the exception itself is a footnote to
the class rather than a counterexample to the class's origin story, which is what the sentence is
actually arguing. Phase 1 graded this nitpick at high confidence and reached that grade for
substantially the reasons I would give. I concur, independently, and I would not upgrade it.

Phase 1's exposure is that its three cited sources are two Wikipedia pages and a teaching site.
That is thin ground for a finding, and it deserves saying plainly. It happens that the finding is
right anyway; I established the same conclusion from Grammis and from Wright's two primers without
touching Phase 1's list.

## What is actually true

Six preterite-presents survive in modern standard German: dürfen, können, mögen, müssen, sollen,
wissen. Five show a stem-vowel difference between the present indicative singular and plural:
darf/dürfen, kann/können, mag/mögen, muss/müssen, weiß/wissen. Sollen is the sole exception, with
soll- throughout the present. The IDS Grammis states this in as many words.

Sollen once alternated like the others, and the essay is therefore describing a pattern sollen has
lost rather than a pattern it never had. Wright's Old High German Primer §198 gives the fourth
ablaut series preterite-present as skal, 2 sg. scalt, pl. sculun, and his Middle High German
Primer §93 still has sol, 2 sg. solt, infinitive and plural suln or süln. The paradigm was levelled
to the singular vowel on the way into New High German, which is why Grammis can list soll- as a
single present stem. Two details corroborate the levelling rather than a mere spelling change.
Wright's note at §198 records that the c-less forms appear already in Tatian, "e.g. Tatian sal,
solta, cp. the NHG. forms", so the o-vocalism of the modern paradigm has an Old High German
ancestor competing with sculun. And sollen is alone among the modal preterite-presents in taking
no umlaut in Konjunktiv II: sollte against könnte, dürfte, möchte, müsste, wüsste. The same verb
that levelled its present alternation also failed to develop the umlauted subjunctive that the
alternation would have fed.

One qualification Phase 1 does not make, and which does not change its verdict: the five surviving
alternations are not all straightforward inherited ablaut. Wright §200 gives Old High German muoȥ,
pl. muoȥun, with no alternation at all, so the modern muss/müssen contrast is a later umlaut
generalized out of the subjunctive, not a preterite singular against a preterite plural. Phase 1
does not claim otherwise, and its "What is actually true" section is correct as written. I mention
it only because Phase 1's closing aside gestures at calling this alternation "the old ablaut of the
strong preterite singular against its plural", and for müssen that gloss would be wrong. That aside
proposes no prose, so nothing needs fixing; it is a reason not to write the ablaut sentence Phase 1
declined to write.

## Phase 1's replacement prose

> and vowel differences between singular and plural in all of them but ~sollen~ (ich $kAnN$ vs. wir können)

Sound. I checked it for every failure mode I could think of and it survives all of them.

Markup: ~sollen~ opens and closes, $kAnN$ opens and closes, no nesting, no new markers, so the
Info screen will not fatalError. The emphasis marker is the right one: line 169 cites all six verbs
as ~können~, ~müssen~, ~dürfen~, ~sollen~, ~mögen~, ~wissen~, so a bare verb citation in this
paragraph takes ~…~ and a conjugated form takes $…$. A reader meeting ~sollen~ here has met it in
that exact typography one sentence earlier.

House style: it adds no parenthetical, no em dash, no gloss. It adds five words to a sentence that
already runs long, which is within tolerance.

Accuracy: "all of them but ~sollen~" is exactly the five-of-six fact, and it does not overcorrect.
It does not claim sollen never alternated, which would be false; it does not claim the other five
alternations are all inherited ablaut, which would be false for müssen; and it leaves the sentence's
main assertion, that these conjugations reflect an origin as old preterites, untouched and still
true of sollen. Nothing elsewhere in the essay contradicts it.

## Revised replacement prose

None needed. Ship Phase 1's English verbatim:

> and vowel differences between singular and plural in all of them but ~sollen~ (ich $kAnN$ vs. wir können)

The German counterpart is `docs/verb_history_de.txt` line 137, whose second parenthetical currently
reads "und Vokalunterschiede zwischen Singular und Plural (ich $kAnN$ vs. wir können)". Phase 4
will need to insert the same exception there, since both localizations ship as "translated" and the
German reader currently gets the unqualified claim. Two constraints for whoever writes it. The verb
must appear as ~sollen~ with emphasis markers, matching its citation in the German line 135, and it
must not be re-glossed, since the German line already glosses it once. And the German sentence's
subject is plural with "spiegeln", so the inserted phrase has to sit inside the parenthesis without
disturbing the agreement of the main clause, which the English insertion point also respects.

## Strongest case for the finding, and my answer

The strongest case for the finding is the closed set. This is not a generalization floating free
over the German lexicon, where an unstated exception would be ordinary. The preceding sentence
enumerates six verbs by name, and the offending sentence begins "The peculiar conjugations of these
verbs", binding the description to that enumerated six. A universal claim over an enumerated set of
six that fails on one of them is a one-sixth error rate, and no reader can be expected to treat an
explicit list as a sample. That case is good, and it is why I uphold rather than refute.

My answer to it, which is why I stop at nitpick, is that the sentence's actual argument is about
origin, not about paradigm coverage, and that argument is undamaged. The claim being made is that
these verbs conjugate oddly because their presents are old preterites. Sollen's presents are old
preterites too. It lost one of the two surface symptoms and kept the other, the endingless 1s and
3s, which the same sentence correctly attributes to it. So the reader's takeaway, the thing the
paragraph exists to convey, is true of all six including sollen. Only the illustrative detail is
over-broad, and the app itself corrects it on the next tap.

The strongest case against the finding, which I considered and rejected, is that handbooks routinely
characterize the class by singular/plural alternation and let the exception ride. That case dies on
Grammis, which does not let it ride.

## Sources

- IDS Grammis, kontrastive Grammatik, inflection of the modal verbs
  <https://grammis.ids-mannheim.de/kontrastive-grammatik/3571>
  > "Die Modalverben (außer sollen) und wissen besitzen getrennte Präsensstammformen für Singular
  > und Plural."
  The accompanying table gives sollen a single present stem soll-, against will-/woll- for wollen
  and kann-/könn- for können.

- Joseph Wright, An Old High German Primer, 2nd ed., Oxford, §194 and §198
  <https://archive.org/stream/oldhighgermanpri00wrigiala/oldhighgermanpri00wrigiala_djvu.txt>
  > §194: "These verbs have strong preterites with a present meaning, like Gk. οἶδα, Lat. novi,
  > I know, from which new weak preterites have been formed. The 2. sg. ends in -t and has the same
  > stem-vowel as the 1. and 3. sg."
  > §198, IV. Ablaut-series: "skal, I shall, 2. sg. scalt, pl. sculun, subj. sculi; pret. scolta,
  > inf. scolan, pres. part. scolanti."
  > §198 Note: "Some forms of this verb occur occasionally without c, e.g. Tatian sal, solta, cp.
  > the NHG. forms and OE. sceal, beside Mod. Northern Engl. dial., sal."
  > §200, VI. Ablaut-series: "muoȥ, I may, must, 2. sg. muost, pl. muozun" (no singular/plural
  > vowel alternation in Old High German).

- Joseph Wright, A Middle High German Primer, §93, Preterite-Presents
  <https://www.gutenberg.org/files/22636/22636-0.txt>
  > "sol, I shall, 2nd pers. sg. solt; inf. and pl. suln or süln; pret. solde or solte."
  > Compare, in the same list: "kan, I know, 2nd pers. sg. kanst; inf. and pl. kunnen or künnen"
  > and "darf, I need, 2nd pers. sg. darft; pl. durfen or dürfen".

- DWDS, Etymologisches Wörterbuch nach Pfeifer, s.v. sollen
  <https://www.dwds.de/wb/sollen>
  > Gives "ahd. scolan, sculan (8. Jh.), mhd. scholn, schuln" and traces the verb to the
  > preterite-present class and to an Indo-European root *(s)kel- 'to be guilty, to owe'.

## Blocked sources

None. Braune-Reiffenstein and Paul's Mittelhochdeutsche Grammatik are not freely available online,
so I used Wright's two primers, which give the same paradigms in the public domain, and anchored
the modern-German claim on Grammis rather than on either primer.
