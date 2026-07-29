# G8 — verdict: partly — grade: factual-error (narrowed)

## Why

The essay line under review, at `docs/verb_history.txt` line 180, is one of four parallel bullets
introduced by "Yet the system has been transformed by millennia of change":

> 🇩🇪 ~Aspect~ is expressed periphrastically (er $lIest$ = he reads/is reading) or through verbal prefixes and particles (er $lIest$ das Buch aus = he finishes reading the book)

The three sibling bullets each name an actual periphrasis: ~werden~ + infinitive, ~haben~/~sein~ +
past participle, ~werden~/~sein~ + past participle. The aspect bullet names none. Its parenthesis,
er $lIest$, is a single synthetic finite form. Periphrasis is by standard definition the expression
of a grammatical property "by a combination of words rather than by a single inflected form"
(Brown, Chumakina, Corbett and Hippisley in *Morphology*). So the one illustration the bullet
offers for the word "periphrastically" is the textbook counterexample to it. That defect is real
and Phase 1 identified it correctly.

Phase 1's second charge does not survive. It says the sentence "implies German has a
grammaticalized aspect device when the standard description is that it has none". The sentence
says nothing about grammaticalization, and the essay has already told the reader at line 144 that
Germanic "abandoned these distinctions almost entirely", so nobody reaches line 180 believing
German inflects for aspect. More to the point, the bullet's own second clause, prefixes and
particles, is the correct account of where the old Germanic perfectivizing device went, and Phase 1
keeps that clause verbatim. And the wider claim that aspectual meaning gets expressed by multi-word
constructions is not false about German: the ~am~-progressive is exactly such a construction, and
the peer-reviewed literature calls it "the most grammaticalized German construction for expressing
progressivity". The essay's sin is that it asserts the periphrasis and then fails to show one, not
that the assertion is false.

I considered refuting outright on a charitable reading: that "(er $lIest$ = he reads/is reading)"
is meant as a gloss showing the simple present is aspectually neutral, which is *why* periphrasis
is needed. That reading is defeated by the bullet's own parallelism. The second parenthesis,
"(er $lIest$ das Buch aus = ...)", unambiguously exemplifies the clause it follows, so a reader
takes the first parenthesis the same way, as the promised example of periphrastic aspect. Compressed
prose can be forgiven; a claim whose sole example contradicts it cannot.

Grade. I keep factual-error rather than downgrading to nitpick, because "periphrastic" is a
technical term this essay uses precisely three other times within ten lines (168, 172, 181 to 183),
and applying it to a one-word finite form actively teaches a reader the wrong meaning of the term
and the wrong analysis of er liest. It is a narrower error than Phase 1 described, but it is an
error a reader can be misled by, not a specialist's quibble.

## What is actually true

Standard German has no aspect opposition in the verb. The IDS grammar puts it flatly: "Allerdings
gibt es im deutschen Verbsystem keinen Aspekt-Gegensatz zu Formen, die Vollendung (Perfektivität)
ausdrücken." Er liest is therefore aspectually unmarked, and its habitual or ongoing reading comes
from context or from an adverbial (er liest gerade). This much of Phase 1's account is right.

Where Phase 1 is right but flatter than the literature: German does have periphrastic progressive
constructions, and they matter here because they are what the bullet was reaching for. The
~am~-progressive (er ist am Lesen) is the furthest grammaticalized of them; parallel beim + Infinitiv
and zum + Infinitiv constructions exist, the last with absentive force. Their status is genuinely
open. The IDS treats the am-form as a nominal construction rather than a verbal aspect and says
"Ob die Konstruktion sich grammatisch zu einem Verbalaspekt entwickelt, ist noch offen". The
*Journal of Germanic Linguistics* frames the same fact as "German lacks progressive aspect, that is,
there is no strongly grammaticalized category that obligatorily codes progressive aspectuality",
while calling the am-progressive the most grammaticalized construction available for it. On
register, the IDS records the am-form as "traditionell (z.B. Duden 1966, 1984) als umgangssprachlich
oder regional markiert", Rhenish in origin, now spread across the whole German-speaking area and
accepted by current dictionaries. Calling it colloquial is therefore accurate provided it is not
called dialectal or nonstandard.

One correction to the finding's framing worth recording: the German perfect is not available as a
rescue for "expressed periphrastically", because the haben-perfect underwent temporalization and now
reads as a past tense rather than an aspect. The am-progressive is the honest witness, and Phase 1
picked it.

## Phase 1's replacement prose

> 🇩🇪 ~Aspect~ is carried by context (er $lIest$ = he reads/is reading), by the colloquial ~am~-progressive (er ist am Lesen = he is reading), or by verbal prefixes and particles (er $lIest$ das Buch aus = he finishes reading the book)

Sound. Checked and it holds up on every axis I can test:

- Markup: ~Aspect~, ~am~ and both $lIest$ pairs are balanced, no nesting, no stray asterisk. The
  red-letter convention is preserved unchanged from the original, and lesen → liest genuinely is
  the irregular e → ie stem change, so the capital I is correctly placed.
- Example quality: er ist am Lesen is a well-chosen instance, not a lucky one. The am-progressive is
  restricted to intransitive or absolute uses and is commonest with objectless activity verbs, which
  is precisely the shape of this example. A transitive example would have been shaky.
- Orthography: am Lesen capitalized is the Duden spelling of the nominalized infinitive. The
  lowercase am lesen belongs to the more advanced, less standard end of the construction.
- Hedging: "colloquial" matches the IDS register label without overclaiming, and the prose stops
  short of calling the am-form a grammatical aspect, which is the claim the IDS says is still open.
- Consistency with the rest of the essay: nothing here contradicts line 144's account of the aspect
  collapse, and the bullet now names a periphrasis, restoring the parallel with the three bullets
  under it.
- House style: no em dashes.

One judgment call I flag rather than fix. The rule against new parenthetical asides is, on a strict
reading, touched by "(er ist am Lesen = he is reading)". I do not think it bites. The bullet is
built entirely out of parenthetical example glosses of exactly this form, so a third one is a gloss
in the established pattern, not an aside. If Josh reads the rule strictly, the fix is to drop that
one gloss, at a real cost in clarity for a reader who does not know the construction.

## Revised replacement prose

None needed. Ship Phase 1's line as written:

> 🇩🇪 ~Aspect~ is carried by context (er $lIest$ = he reads/is reading), by the colloquial ~am~-progressive (er ist am Lesen = he is reading), or by verbal prefixes and particles (er $lIest$ das Buch aus = he finishes reading the book)

German counterpart, `docs/verb_history_de.txt` line 146. That line currently reads "~Aspekt~ wird
periphrastisch ausgedrückt" and ships the same defect flat to German readers, so it needs the same
three-part restructuring: context, then the colloquial am-progressive, then prefixes and particles.
Two things Phase 4 should know before translating. First, "periphrastisch ausgedrückt" cannot simply
be patched with an added am-clause; the verb of the sentence has to change, because the am-form is
the periphrasis and context is not. Second, the existing German line carries its example glosses in
English ("he reads/is reading", "he finishes reading the book"), which is a pre-existing translation
question on that line, separate from this finding and not adjudicated here; whoever rewrites the line
will have to decide it rather than inherit it.

## Strongest case for the finding, and my answer

The strongest case for upholding G8 exactly as Phase 1 graded it: the bullet's sole illustration of
periphrasis contains no periphrasis, the essay uses the term correctly everywhere else, and German
genuinely has no verbal aspect category, so both the example and the implicature are wrong and
high-confidence factual-error is right.

I grant the first half and that is why my verdict is not "refuted". I do not grant the second. The
sentence never claims German inflects for aspect or has a grammaticalized aspect category; it claims
aspect is expressed periphrastically or by prefixes, and the second half of that disjunction is
correct, standard, and retained by Phase 1's own fix. The essay has also already stated the aspect
collapse at line 144, and the parenthesis itself, one German form glossed by two English readings,
demonstrates the neutrality correctly even while failing to demonstrate periphrasis. So a reader is
misinformed about one thing, the meaning of "periphrastically" as applied to er liest, not "twice
over" about German's aspect system. Real defect, correct fix, overdrawn indictment: partly.

## Sources

- Brown, Chumakina, Corbett and Hippisley, "Defining 'periphrasis': key notions", *Morphology* (peer-reviewed) <https://link.springer.com/article/10.1007/s11525-012-9201-5>
  > "Periphrasis" is most commonly used to denote a construction type in which a grammatical property or feature is expressed by a combination of words rather than by a single inflected form.
- grammis, Institut für Deutsche Sprache Mannheim, "Darf man Ich bin am Schreiben schreiben?" <https://grammis.ids-mannheim.de/fragen/4551> (fetched directly)
  > Allerdings gibt es im deutschen Verbsystem keinen Aspekt-Gegensatz zu Formen, die Vollendung (Perfektivität) ausdrücken.
  > Ob die Konstruktion sich grammatisch zu einem Verbalaspekt entwickelt, ist noch offen.
  and on register: the am-form is "traditionell (z.B. Duden 1966, 1984) als umgangssprachlich oder regional markiert", Rhenish in origin, "mittlerweile im ganzen deutschen Sprachgebiet verbreitet", and treated as a "nominale Konstruktion und nicht um einen verbalen Aspekt".
- *Journal of Germanic Linguistics*, "Pseudo-Coordinated Sitzen and Stehen in Spoken German: A Case of Emergent Progressive Aspect?" (peer-reviewed), open copy at <https://d-nb.info/1317580842/34>, journal page <https://www.cambridge.org/core/journals/journal-of-germanic-linguistics/article/pseudocoordinated-sitzen-and-stehen-in-spoken-german-a-case-of-emergent-progressive-aspect/A7A8B325956DE69BD6706A28395568BF>
  > German lacks progressive aspect, that is, there is no strongly grammaticalized category that obligatorily codes progressive aspectuality (or progressivity). However, the most grammaticalized German construction for expressing progressivity is the so-called am-progressive (for example, Krause 2002, Van Pottelberge 2004).
  and, on the example's fitness: the am-progressive "is subject to severe syntactic restrictions in that it typically features verbs in intransitive or absolute usage".
- Konjugieren essay, `docs/verb_history.txt` line 144 (internal consistency check)
  > The most striking change was the ~collapse of the aspect system~. … Germanic abandoned these distinctions almost entirely.

## Blocked sources

- Gárgyán, "Der am-Progressiv im heutigen Deutsch" (Szeged dissertation), <https://doktori.bibl.u-szeged.hu/id/eprint/788/6/2011_gargyan_gabriella_ger.pdf> — served as a scanned, non-text PDF; no extractable text. Routed around via the *Journal of Germanic Linguistics* article and grammis, which cover the same ground with quotable text.
- De Gruyter, "Der am-Progressiv und parallele am V-en sein-Konstruktionen", *PBB* 138 — paywalled, not consulted.
