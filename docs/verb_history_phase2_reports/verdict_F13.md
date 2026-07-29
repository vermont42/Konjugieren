# F13 · verdict: partly · grade: factual-error

The diagnosis and the grade are upheld in full: the essay calls ~wissen~ a modal verb, it is
not one, and a learner is actively misinformed. What does not survive is the replacement prose.
It is factually correct but it lands a new sentence about ~wollen~ directly in front of a
sentence whose subject is "these verbs" and whose explanation is false of ~wollen~.

## Why

Essay line 169, second sentence:

> These include the modal verbs ~können~ (can), ~müssen~ (must), ~dürfen~ (may), ~sollen~ (shall), ~mögen~ (may/like), and ~wissen~ (to know).

There are no hedges here to read charitably. "These include" hedges exhaustiveness, not category
membership: whatever is in the list is asserted to be a modal verb. The one escape available is a
coordination reading, "These include [the modal verbs A, B, C, D, E] and [wissen]", and it does
not survive contact with the punctuation. All six items are formatted identically as
`~verb~ (gloss)`, and the comma before "and ~wissen~" is the same comma that separates the five
preceding items. Nothing marks a shift from apposition to a second conjunct. The dominant
reading, and for a learner the only reading, is that ~wissen~ is being named a modal verb.

It is not. IDS grammis puts the modal inventory at six and puts ~wissen~ outside it in the same
breath: "Sechs Modalverben (dürfen, können, mögen, müssen, sollen, wollen) und das Vollverb
wissen." Duden's definition of Modalverb requires government of a bare infinitive, which ~wissen~
does not do; the German that would correspond takes ~zu~ ("er weiß sich zu helfen"), and a reader
who takes the essay at its word will produce "ich weiß schwimmen".

That is why this is a factual error and not a nitpick. "Modal verb" is not a specialist's label
in a German course. It is a live syntactic class with a rule attached, taught in the first year,
and the essay ships inside an app whose users are exactly the people who will apply the rule.
The German localization at `docs/verb_history_de.txt` line 135 reads "die Modalverben … und
~wissen~", which is if anything worse, because a German reader knows Modalverben as a closed set
of six and will read the sentence as claiming a seventh.

What the finding gets right and is right to say out loud: the *list* is correct, and the absence
of ~wollen~ is correct rather than an oversight. The defect is one word, "modal", not the
membership.

## What is actually true

Phase 1's account holds on all three points, and I reached each independently.

Six preterite-presents survive in modern German: dürfen, können, mögen, müssen, sollen, wissen.
grammis describes a small inflectional class comprising the six modals plus the full verb
~wissen~, inflecting "nach dem Muster der sog. Präteritopräsentia", of which ~wollen~ is the one
member that is not historically a preterite-present.

Of the six, all but ~wissen~ function as modal verbs; ~wissen~ is the class's only full verb.
grammis states this twice over: its Bestand of Modalverben is "müssen, sollen, dürfen,
mögen/möchte-, wollen, können", with ~wissen~ absent, and elsewhere it labels ~wissen~ "das
Vollverb". Duden's definitional test, government of a reiner Infinitiv, excludes it.

~wollen~ is the sixth modal and is not a preterite-present. Its present continues an old optative
reanalyzed as an indicative already in Proto-Germanic; Wright's Gothic grammar states this
flatly for the paradigm wiljáu / wileis / wili, which carries optative endings. The inflectional
resemblance to the preterite-presents is a secondary adaptation on the strength of shared modal
semantics, which is the shape of the claim in the finding.

One caveat about Phase 1's evidence base, which the verdict does not turn on but a reader should
know. Of its three sources, one is German Wikipedia, one is a Middle High German teaching site,
and one is grammis. Only grammis carries weight. The conclusion is right, but it was right on
thinner ground than "high confidence" implies, and it took a handbook-level check to earn that
confidence.

## Phase 1's replacement prose

> Six survive in modern German: the modal verbs ~können~ (can), ~müssen~ (must), ~dürfen~ (may), ~sollen~ (shall), and ~mögen~ (may/like), together with ~wissen~ (to know), which shares their history but is not a modal. ~Wollen~ is a modal that stands outside the class, its present continuing an old optative.

Markup is clean: six balanced `~…~` pairs, no `$…$`, no stray `‡` or `^`. No em dashes and no new
parentheticals beyond the glosses the sentence already carried. Every factual assertion in it is
true. The problem is placement, not content.

The paragraph that follows at line 171 opens:

> The peculiar conjugations of these verbs (with no endings in 1s and 3s (ich $kAnN$, er $kAnN$) and vowel differences between singular and plural (ich $kAnN$ vs. wir können)) reflects their origin as old preterite conjugations that were reanalyzed as presents.

~wollen~ has both of those peculiarities. Ich will, er will, no ending; ich will against wir
wollen, vowel difference. And it has them for a different reason, not from old preterites but
from an old optative, as the replacement itself has just said. So the replacement leaves ~wollen~
as the last verb named before "these verbs" and hands the reader an antecedent that makes the
next sentence's explanation false of the nearest example. The paragraph break and the phrase
"stands outside the class" soften it, but the essay ends up half-inviting a reading it elsewhere
denies. A fix should not require the reader to carry a disclaimer across a paragraph boundary.

Two lesser points. "Six survive in modern German" converts the original's open "These include"
into a flat exhaustive count. The count is correct, so this is not an error, but it is a new
claim taken on for no reason, and it sits oddly against the preceding sentence's "German
preserves a distinctive class", which has already said the surviving part. And the whole thing is
two sentences of new material where the defect is one word, which pushes past the brief to match
the essay's approximate length and gives Phase 4 a German sentence to invent rather than repair.

## Revised replacement prose

English, replacing only the second sentence of line 169:

> These include the modal verbs ~können~ (can), ~müssen~ (must), ~dürfen~ (may), ~sollen~ (shall), and ~mögen~ (may/like), together with ~wissen~ (to know), which shares their history but is a full verb, not a modal.

This fixes the one defective word, keeps "These include" so no new exhaustiveness claim is
incurred, preserves the original glosses and list order, adds one clause rather than a sentence,
and leaves ~mögen~ and ~wissen~ as the last verbs named, so that "these verbs" in the following
paragraph picks up only preterite-presents. Markup: six `~…~` pairs, balanced.

If Josh wants the ~wollen~ fact kept, it belongs after the following paragraph's explanation of
the peculiar conjugations, not before it, so that "these verbs" is already resolved when ~wollen~
arrives. A one-sentence tail on line 171 would do it. Placing it at line 169, as Phase 1 does, is
the part I would not ship.

German counterpart, `docs/verb_history_de.txt` line 135, currently:

> Dazu gehören die Modalverben ~können~ (can), ~müssen~ (must), ~dürfen~ (may), ~sollen~ (shall), ~mögen~ (may/like) und ~wissen~ (to know).

What it needs, for Phase 4 to write: ~wissen~ pulled out of the scope of "die Modalverben" and
named a Vollverb, which is the term German grammars actually use for it, so that the sentence
lands as five Modalverben plus ~wissen~ rather than six Modalverben. The English glosses in
parentheses are a pre-existing convention across this German localization and should be left
alone rather than fixed here. Six `~…~` pairs, balanced, and no `$…$` in this sentence.

## Strongest case for the finding, and my answer

Since I uphold the diagnosis, the case that needs answering is the case *against* the finding.
There are three, and none of them holds.

First, the coordination reading: "These include the modal verbs A, B, C, D, E, and F" can be
parsed as two conjuncts, a set of modals and then ~wissen~. Answer: it can be parsed that way
only by a reader who already knows ~wissen~ is not a modal, which is precisely the reader the
sentence is not written for. The six items are typographically identical and separated by
identical commas, and in the German the same structure with "und ~wissen~" reads as a single list
even more strongly.

Second, the harm may be small, because plenty of teaching material groups ~wissen~ with the
modals. Answer: it groups ~wissen~ *with* them, and that phrasing is the standard way of
*excluding* it. grammis writes "Sechs Modalverben … und das Vollverb wissen"; the conjunction is
doing the separating. The essay's sentence does the opposite, folding ~wissen~ inside the label.

Third, the paragraph is about preterite-presents, so "modal" is incidental and misleads nobody.
Answer: this is the objection that would carry weight in a general history essay and does not
carry it here. The essay is the Info screen of a conjugation app. Its readers are learning the
modal class as a rule with a syntactic consequence, and the error tells them a common verb takes
a bare infinitive when it does not. Incidental to the paragraph's argument, load-bearing for the
reader.

Where I part company with Phase 1 is the fix, and the strongest case for its version is that
naming ~wollen~ inoculates the passage against a future editor "correcting" the list. That is a
real benefit. My answer is that it is a benefit to the repository, not to the reader, and it is
bought with a sentence that misaligns the antecedent of the next paragraph. A note in the working
docs protects against the editor at no cost to the prose.

## Sources

- grammis, Leibniz-Institut für Deutsche Sprache, progr@mm, "Flexion der Modalverben"
  <https://grammis.ids-mannheim.de/progr@mm/4075>
  > "Sechs Modalverben (dürfen, können, mögen, müssen, sollen, wollen) und das Vollverb wissen"
  > "Die Vertreter dieser kleinen Flexionsklasse flektieren nach dem Muster der sog. Präteritopräsentia, deren Synkretismus im Präsens auf die Tatsache zurückzuführen ist, dass es sich dabei ursprünglich um Präteritalformen handelte."

- grammis, Leibniz-Institut für Deutsche Sprache, progr@mm, "Modalverb"
  <https://grammis.ids-mannheim.de/progr@mm/5202>
  > "Modalverben regieren im Verbalkomplex den Infinitiv eines Vollverbs."
  > Bestand: "müssen, sollen, dürfen, mögen/möchte-, wollen, können" — ~wissen~ absent.

- Duden, "Modalverb" <https://www.duden.de/rechtschreibung/Modalverb>
  > "Verb, das in Verbindung mit einem reinen Infinitiv ein anderes Sein oder Geschehen modifiziert" (examples given: "sie darf, kann, will fahren")

- Joseph Wright, *Grammar of the Gothic Language* (1910), chapter on the verb, section on wiljan
  <https://jtauber.github.io/gothica/wright-1910-grammar/html/chapter13.html>
  > "The present tense of this verb was originally an optative (subjunctive) form of a verb in -mi, which already in prim. Germanic came to be used indicatively."
  > Present forms given: wiljáu, wileis, wili, wileits, wileima, wileiþ, wileina; infinitive wiljan; participle wiljands.

- Wiktionary, Reconstruction:Proto-Germanic/wiljaną — tertiary, corroborative only
  <https://en.wiktionary.org/wiki/Reconstruction:Proto-Germanic/wiljan%C4%85>
  > present derives from "the optative of *wḗlh₁-ti ~ *wélh₁-n̥ti, Narten present from *welh₁-"

## Blocked sources

None. Every page fetched returned content. Ringe, *From Proto-Indo-European to Proto-Germanic*,
is available as a full PDF at archive.org but was not fetched: at roughly 500 pages it exceeds
what the fetch tool returns usefully, and Wright settles the ~wollen~ optative point at handbook
level without it.
