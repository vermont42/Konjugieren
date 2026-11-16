# Privacy-Policy Lines Waiting for a Release

[`privacy_policy.txt`](privacy_policy.txt) describes what the **shipped** app sends, and Josh may
deploy it at any time. A signal or parameter built on `main` gets its line in the deployed policy
on the day the release that sends it ships, not before. Until then the line waits here.

**On release day:** splice every section below into both languages of `privacy_policy.txt`, update
its effective date in both, deploy it, and empty this file back down to this introduction. Add the
lines in the order given, after the bullet about taps on buttons in section 2.

**When adding a signal or parameter on `main`:** add its lines here in English and German, in the
policy's plain register, naming the bands rather than the code's parameter keys. Name the plan and
phase that added it.

## Lookup signals (browse plan, Phase 3, 2026-11-12)

Adds `source` to `viewVerbView`, and the signals `finishSearch` and `leaveVerbView`. Phase 6 added
three `matchKind` values for matches by conjugation, which the search bullet's examples now name.
Phase 9 began sending the `related` source, which the first bullet's examples now name. Phase 11
added `source` to `finishSearch` (where the search began), which the search bullet now names. See
[`feature-architecture.md`](feature-architecture.md#analytics) for the vocabulary.

### English

New bullets for the list in section 2:

```
- How you reached a verb's page: for example from a search, the verb list, a family page, another verb's page, a widget, Spotlight, or a shortcut
- How far down a verb's page you scrolled (its top, the conjugation tables, the etymology, or the example sentence), and roughly how long the page was open (under 5 seconds, 5 to 15 seconds, 15 to 60 seconds, or longer)
- When a search ends: where it began (the verb list, Control Center, the app icon's menu, a shortcut, or a link), whether you opened a verb, the kind of match that found it (for example the infinitive, a conjugation, a spelling without umlauts, or an English meaning), and rough counts: the length of what you typed (1 to 2 letters, 3 to 5, 6 to 9, or 10 or more), how many verbs matched (none, 1, 2 to 10, or more), and where the verb you opened stood in the list (first, second to fifth, or lower)
```

The paragraph after the list now reads:

```
A screen visit or a tap is recorded only as having happened, apart from the details about verb pages and searches listed above. Nothing you type and nothing on the screen is sent with any event. That you searched is recorded, with the rough counts above; what you typed is not. That you opened a verb's page is recorded; which verb is not.
```

### German

Neue Punkte für die Liste in Abschnitt 2:

```
- Wie Sie die Seite eines Verbs erreicht haben: zum Beispiel über die Suche, die Verbliste, eine Familienseite, die Seite eines anderen Verbs, ein Widget, Spotlight oder einen Kurzbefehl
- Wie weit Sie auf der Seite eines Verbs nach unten gescrollt haben (ihr Anfang, die Konjugationstabellen, die Etymologie oder der Beispielsatz) und ungefähr, wie lange die Seite geöffnet war (unter 5 Sekunden, 5 bis 15 Sekunden, 15 bis 60 Sekunden oder länger)
- Wenn eine Suche endet: wo sie begann (die Verbliste, das Kontrollzentrum, das Menü des App-Symbols, ein Kurzbefehl oder ein Link), ob Sie ein Verb geöffnet haben, welche Art von Treffer es gefunden hat (zum Beispiel der Infinitiv, eine Konjugation, eine Schreibung ohne Umlaute oder eine englische Bedeutung) und grobe Zahlen: die Länge Ihrer Eingabe (1 bis 2 Buchstaben, 3 bis 5, 6 bis 9 oder 10 und mehr), wie viele Verben passten (keines, 1, 2 bis 10 oder mehr) und an welcher Stelle der Liste das geöffnete Verb stand (an erster, an zweiter bis fünfter oder an späterer Stelle)
```

Der Absatz nach der Liste lautet nun:

```
Ein Bildschirmbesuch oder ein Antippen wird nur als Ereignis erfasst, abgesehen von den oben genannten Angaben zu Verbseiten und Suchen. Nichts, was Sie eingeben, und nichts, was auf dem Bildschirm steht, wird mit einem Ereignis gesendet. Erfasst wird, dass Sie gesucht haben, mit den oben genannten groben Zahlen, nicht aber, was Sie eingegeben haben. Erfasst wird, dass Sie die Seite eines Verbs geöffnet haben, nicht aber, welches Verb.
```

## Taps on a verb page (browse plan, Phases 7 and 10, 2026-11-12)

Adds the signals `tapConjugationgroupArticle` (Phase 7), the ⓘ button beside a conjugationgroup's
heading on a verb page, and `tapShareVerb` (Phase 10), the share button on a verb page. Neither has
parameters, and neither says which verb. They change an existing bullet rather than adding one.

### English

The bullet about taps in section 2 now reads:

```
- Taps on a few buttons: playing the game, rating or reviewing the app, showing the introduction, viewing the leaderboard, sending a message to the tutor, asking for an error to be explained, deleting the chat history, opening a conjugationgroup's article from a verb's page, and sharing a verb's page
```

### German

Der Punkt über das Antippen in Abschnitt 2 lautet nun:

```
- Das Antippen einiger Schaltflächen: das Spiel starten, die App bewerten oder rezensieren, die Einführung anzeigen, die Bestenliste ansehen, dem Tutor eine Nachricht senden, einen Fehler erklären lassen, den Chatverlauf löschen, den Artikel über eine Conjugationgroup von der Seite eines Verbs aus öffnen und die Seite eines Verbs teilen
```

## My Verbs and quizzes (browse plan, Phases 12 and 13, 2026-11-13)

Adds the signals `tapStarVerb` (Phase 12), with a `starred` parameter saying whether the tap
starred the verb or removed its star, and `tapTestVerb` (Phase 13), and adds `source` to
`startQuiz`, `quitQuiz`, and `completeQuiz` (Phase 13): the Quiz tab, My Verbs, or a verb's page.
Phase 12 also began sending the `recent` and `myVerbs` sources for verb pages, which the first
bullet of the lookup section above covers with "for example". These lines replace the taps
bullet as given in the section above this one, and change the quiz bullets. The rest says that the
learner's verbs stay on the device, which changes the "That is all" sentence, and that only a full
quiz over every verb posts a score.

### English

The bullet about taps in section 2 now reads:

```
- Taps on a few buttons: playing the game, rating or reviewing the app, showing the introduction, viewing the leaderboard, sending a message to the tutor, asking for an error to be explained, deleting the chat history, opening a conjugationgroup's article from a verb's page, sharing a verb's page, starring a verb or removing its star, and testing yourself on a verb from its page
```

The first quiz bullet in section 2 now reads:

```
- Quiz lifecycle events (starting, quitting, or completing a quiz), and where the quiz was begun: the quiz screen, your own verbs, or a verb's page
```

The last paragraph of section 2, which begins "That is all.", now reads as follows. "record"
becomes "send", since the app now keeps the verbs you open on the device:

```
That is all. The app does not send your quiz answers, your scores, the verbs you look up, or any text you type.
```

A new paragraph follows it:

```
The app keeps a list of the verbs you have opened and the verbs you have starred, so that it can show your recent verbs and My Verbs. The list stays on your device and is never sent.
```

New sentence at the end of the first paragraph of section 6:

```
Only a quiz over all verbs posts a score; a quiz over your own verbs or a single verb does not.
```

### German

Der Punkt über das Antippen in Abschnitt 2 lautet nun:

```
- Das Antippen einiger Schaltflächen: das Spiel starten, die App bewerten oder rezensieren, die Einführung anzeigen, die Bestenliste ansehen, dem Tutor eine Nachricht senden, einen Fehler erklären lassen, den Chatverlauf löschen, den Artikel über eine Conjugationgroup von der Seite eines Verbs aus öffnen, die Seite eines Verbs teilen, ein Verb mit einem Stern markieren oder den Stern entfernen und sich auf der Seite eines Verbs zu diesem Verb abfragen lassen
```

Der erste Punkt über das Quiz in Abschnitt 2 lautet nun:

```
- Quiz-Lebenszyklus-Ereignisse (Starten, Abbrechen oder Abschließen eines Quiz) und wo das Quiz begonnen wurde: auf dem Quiz-Bildschirm, mit Ihren eigenen Verben oder auf der Seite eines Verbs
```

Der letzte Absatz von Abschnitt 2, der mit „Das ist alles.“ beginnt, lautet nun so. „zeichnet …
auf“ wird zu „sendet“, da die App die geöffneten Verben nun auf dem Gerät speichert:

```
Das ist alles. Die App sendet weder Ihre Quizantworten noch Ihre Ergebnisse, die von Ihnen nachgeschlagenen Verben oder eingegebenen Texte.
```

Ein neuer Absatz folgt:

```
Die App führt eine Liste der Verben, die Sie geöffnet, und der Verben, die Sie mit einem Stern markiert haben, damit sie Ihre zuletzt geöffneten Verben und „Meine Verben“ zeigen kann. Die Liste bleibt auf Ihrem Gerät und wird nie gesendet.
```

Neuer Satz am Ende des ersten Absatzes von Abschnitt 6:

```
Nur ein Quiz über alle Verben reicht ein Ergebnis ein; ein Quiz über Ihre eigenen Verben oder ein einzelnes Verb tut das nicht.
```

## The review card (browse plan, Phase 15, 2026-11-13)

Adds the signals `viewReviewCard`, sent when the review card above the verb list appears, and
`tapRevealReviewCard`, sent when a tap reveals its conjugations. Neither has parameters, and
neither says which verb. Phase 15 also began sending the `reviewCard` source for verb pages, which
the first bullet of the lookup section covers with "for example". These lines replace the taps
bullet as given in the My Verbs section above, and the paragraph about the list kept on the
device, since the list now also holds when each verb is due for review.

### English

The bullet about taps in section 2 now reads:

```
- Taps on a few buttons: playing the game, rating or reviewing the app, showing the introduction, viewing the leaderboard, sending a message to the tutor, asking for an error to be explained, deleting the chat history, opening a conjugationgroup's article from a verb's page, sharing a verb's page, starring a verb or removing its star, testing yourself on a verb from its page, and revealing the conjugations on a review card
```

A new bullet follows it:

```
- That a review card, which offers a verb you looked up earlier, was shown
```

The paragraph about the list kept on the device now reads:

```
The app keeps a list of the verbs you have opened and the verbs you have starred, with when each is next due for review, so that it can show your recent verbs, My Verbs, and review cards. The list stays on your device and is never sent.
```

### German

Der Punkt über das Antippen in Abschnitt 2 lautet nun:

```
- Das Antippen einiger Schaltflächen: das Spiel starten, die App bewerten oder rezensieren, die Einführung anzeigen, die Bestenliste ansehen, dem Tutor eine Nachricht senden, einen Fehler erklären lassen, den Chatverlauf löschen, den Artikel über eine Conjugationgroup von der Seite eines Verbs aus öffnen, die Seite eines Verbs teilen, ein Verb mit einem Stern markieren oder den Stern entfernen, sich auf der Seite eines Verbs zu diesem Verb abfragen lassen und die Konjugationen auf einer Wiederholungskarte aufdecken
```

Ein neuer Punkt folgt:

```
- Dass eine Wiederholungskarte angezeigt wurde, die ein früher nachgeschlagenes Verb anbietet
```

Der Absatz über die Liste auf dem Gerät lautet nun:

```
Die App führt eine Liste der Verben, die Sie geöffnet, und der Verben, die Sie mit einem Stern markiert haben, samt dem Tag, an dem jedes wieder zur Wiederholung ansteht, damit sie Ihre zuletzt geöffneten Verben, „Meine Verben“ und Wiederholungskarten zeigen kann. Die Liste bleibt auf Ihrem Gerät und wird nie gesendet.
```

## Collections (browse plan, Phase 16, 2026-11-13)

Adds the signals `viewCollection`, sent when a collection's page opens or an ablaut group is
expanded, with which collection and whether it was opened in the Families tab or from a link, and
`tapShareCollection`, with which collection. Adds `collection` to `startQuiz` for a quiz begun on
a collection, and the `list` value to the quiz signals' `source`. A collection is one of the app's
fixed lists, such as the modal verbs, so naming it says nothing the learner typed or chose beyond
opening it. Phase 16 also began sending the `list` source for verb pages, which the first bullet
of the lookup section covers with "for example". These lines replace the taps bullet as given in
the review-card section above, the first quiz bullet as given in the My Verbs section, and the
paragraph about the list kept on the device, since collections count the verbs in it.

### English

The bullet about taps in section 2 now reads:

```
- Taps on a few buttons: playing the game, rating or reviewing the app, showing the introduction, viewing the leaderboard, sending a message to the tutor, asking for an error to be explained, deleting the chat history, opening a conjugationgroup's article from a verb's page, sharing a verb's page, starring a verb or removing its star, testing yourself on a verb from its page, revealing the conjugations on a review card, and sharing a collection, with which collection
```

A new bullet follows the one about review cards:

```
- Which collection of verbs you opened, such as the modal verbs or an ablaut group, and whether you opened it in the app, from a shared link, or from another link
```

The first quiz bullet in section 2 now reads:

```
- Quiz lifecycle events (starting, quitting, or completing a quiz), and where the quiz was begun: the quiz screen, your own verbs, a verb's page, or a collection, and which collection
```

The paragraph about the list kept on the device now reads:

```
The app keeps a list of the verbs you have opened and the verbs you have starred, with when each is next due for review, so that it can show your recent verbs, My Verbs, review cards, and how many verbs of each collection you have looked up. The list stays on your device and is never sent.
```

### German

Der Punkt über das Antippen in Abschnitt 2 lautet nun:

```
- Das Antippen einiger Schaltflächen: das Spiel starten, die App bewerten oder rezensieren, die Einführung anzeigen, die Bestenliste ansehen, dem Tutor eine Nachricht senden, einen Fehler erklären lassen, den Chatverlauf löschen, den Artikel über eine Conjugationgroup von der Seite eines Verbs aus öffnen, die Seite eines Verbs teilen, ein Verb mit einem Stern markieren oder den Stern entfernen, sich auf der Seite eines Verbs zu diesem Verb abfragen lassen, die Konjugationen auf einer Wiederholungskarte aufdecken und eine Sammlung teilen, samt der Angabe, welche Sammlung
```

Ein neuer Punkt folgt dem über Wiederholungskarten:

```
- Welche Sammlung von Verben Sie geöffnet haben, etwa die Modalverben oder eine Ablautgruppe, und ob Sie sie in der App, über einen geteilten Link oder über einen anderen Link geöffnet haben
```

Der erste Punkt über das Quiz in Abschnitt 2 lautet nun:

```
- Quiz-Lebenszyklus-Ereignisse (Starten, Abbrechen oder Abschließen eines Quiz) und wo das Quiz begonnen wurde: auf dem Quiz-Bildschirm, mit Ihren eigenen Verben, auf der Seite eines Verbs oder in einer Sammlung, samt der Angabe, welche Sammlung
```

Der Absatz über die Liste auf dem Gerät lautet nun:

```
Die App führt eine Liste der Verben, die Sie geöffnet, und der Verben, die Sie mit einem Stern markiert haben, samt dem Tag, an dem jedes wieder zur Wiederholung ansteht, damit sie Ihre zuletzt geöffneten Verben, „Meine Verben“, Wiederholungskarten und die Zahl der nachgeschlagenen Verben jeder Sammlung zeigen kann. Die Liste bleibt auf Ihrem Gerät und wird nie gesendet.
```

## A correction's links (pedagogy plan, Phase 3, 2026-11-13)

Begins sending the `quizCorrection` source for verb pages opened from a quiz's held correction,
and for an ablaut group opened from it (`viewCollection`). The first bullet of the lookup section
covers the verb page with "for example", and the collection bullet's "in the app" covers the
ablaut group, so no line changes. The source says only that a link under a correction was
followed, never which verb or answer, as Decision 5 of the plan requires.

## Quiz levels (pedagogy plan, Phase 5, 2026-11-13)

Replaces the quiz's `difficulty` parameter (`regular`, `ridiculous`), sent with `quitQuiz` and
`completeQuiz`, with `level` (`beginner`, `elementary`, `intermediate`, `advanced`), and adds it to
`startQuiz` (the report's M1). A level is a setting the learner chose, like the difficulty before
it, so it says nothing about an answer or a score. The line changes rather than a new one being
added.

### English

The bullet about the quiz difficulty in section 2 now reads:

```
- The quiz level you chose (Beginner, Elementary, Intermediate, or Advanced) when you start, quit, or complete a quiz
```

### German

Der Punkt über den Quiz-Schwierigkeitsgrad in Abschnitt 2 lautet nun:

```
- Die gewählte Quizstufe (Einstieg, Grundstufe, Mittelstufe oder Oberstufe) beim Starten, Abbrechen oder Abschließen eines Quiz
```

## Ten-question rounds, abandoned quizzes, and time to quit (pedagogy plan, Phase 7, 2026-11-13)

Adds `questionCount` to `completeQuiz`, which is now sent at the results of each round of ten (10,
then 20 after Ten More, and so on), `duration` to `quitQuiz` (the time from the start to the quit,
in the bands below; the report's M3), and the signal `abandonQuiz`, sent at the next launch after
the app was closed during a quiz, with the level, where the quiz was begun, and the question
reached (M2). None says which verb was asked, what was answered, or how many answers were right
(Decision 5). The lines change the quiz bullets as given in the Collections section above, the
level bullet as given in the Quiz levels section above, and the existing bullet about progress in
a quiz.

### English

The first quiz bullet in section 2 now reads:

```
- Quiz lifecycle events (starting, quitting, completing a round of ten questions, and how many rounds the quiz has reached), and where the quiz was begun: the quiz screen, your own verbs, a verb's page, or a collection, and which collection
```

The bullet about the quiz level now reads:

```
- The quiz level you chose (Beginner, Elementary, Intermediate, or Advanced) when you start, quit, or complete a quiz, or close the app during one
```

The bullet about progress in a quiz now reads:

```
- How far you progressed in a quiz if you quit early or close the app during it (question number reached), and roughly how long after starting you quit (under 3 seconds, 3 to 15 seconds, 15 to 40 seconds, 40 seconds to 2 minutes, or longer)
```

The sentence added to section 6 in the My Verbs section above now reads:

```
Only the first ten questions of a quiz over all verbs post a score; a quiz over your own verbs or a single verb does not, and neither do the ten more questions you may add.
```

### German

Der erste Punkt über das Quiz in Abschnitt 2 lautet nun:

```
- Quiz-Lebenszyklus-Ereignisse (Starten, Abbrechen, Abschließen einer Runde von zehn Fragen und wie viele Runden das Quiz erreicht hat) und wo das Quiz begonnen wurde: auf dem Quiz-Bildschirm, mit Ihren eigenen Verben, auf der Seite eines Verbs oder in einer Sammlung, samt der Angabe, welche Sammlung
```

Der Punkt über die Quizstufe lautet nun:

```
- Die gewählte Quizstufe (Einstieg, Grundstufe, Mittelstufe oder Oberstufe) beim Starten, Abbrechen oder Abschließen eines Quiz oder wenn Sie die App währenddessen schließen
```

Der Punkt über den Fortschritt in einem Quiz lautet nun:

```
- Ihren Fortschritt in einem Quiz, falls Sie es vorzeitig abbrechen oder die App währenddessen schließen (erreichte Fragennummer), und ungefähr, wie lange nach dem Start Sie abgebrochen haben (unter 3 Sekunden, 3 bis 15 Sekunden, 15 bis 40 Sekunden, 40 Sekunden bis 2 Minuten oder länger)
```

Der in Abschnitt 6 ergänzte Satz aus dem Abschnitt über „Meine Verben“ oben lautet nun:

```
Nur die ersten zehn Fragen eines Quiz über alle Verben reichen ein Ergebnis ein; ein Quiz über Ihre eigenen Verben oder ein einzelnes Verb tut das nicht, ebenso wenig die zehn weiteren Fragen, die Sie anhängen können.
```

## Leaderboards by level (pedagogy plan, Phase 8, 2026-11-14)

No new signal or parameter. Each quiz level now has its own Game Center leaderboard, so section 6
names them, and the sentence the Phase 7 section above gives for section 6 changes again.

### English

The first sentence of section 6 now reads:

```
Konjugieren integrates with Apple Game Center for quiz leaderboards, one for each quiz level.
```

The sentence added to section 6 in the Phase 7 section above now reads:

```
Only the first ten questions of a quiz over all verbs post a score, to the leaderboard of the quiz's level; a quiz over your own verbs or a single verb does not, and neither do the ten more questions you may add.
```

### German

Der erste Satz von Abschnitt 6 lautet nun:

```
Konjugieren ist mit Apple Game Center für Quiz-Bestenlisten integriert, eine für jede Quizstufe.
```

Der im Abschnitt zu Phase 7 oben ergänzte Satz in Abschnitt 6 lautet nun:

```
Nur die ersten zehn Fragen eines Quiz über alle Verben reichen ein Ergebnis ein, und zwar in der Bestenliste der Stufe des Quiz; ein Quiz über Ihre eigenen Verben oder ein einzelnes Verb tut das nicht, ebenso wenig die zehn weiteren Fragen, die Sie anhängen können.
```

## Custom quizzes (pedagogy plan, Phase 9, 2026-11-14)

Adds the `custom` value to the quiz signals' `source`, for a quiz the learner put together on the
Quiz tab, and the parameter `customChoice` to `startQuiz`, which says whether the learner chose
conjugationgroups, verbs, or both, but not which. A custom quiz over a collection also sends the
collection, as a collection's quiz does. The lines change the first quiz bullet as given in the
Phase 7 section above. A custom quiz posts no score, which the section 6 sentence already implies
by naming only a quiz over all verbs; it is changed to say so.

### English

The first quiz bullet in section 2 now reads:

```
- Quiz lifecycle events (starting, quitting, completing a round of ten questions, and how many rounds the quiz has reached), and where the quiz was begun: the quiz screen, your own verbs, a verb's page, a collection, and which collection, or a quiz you put together, and whether you chose conjugationgroups, verbs, or both (not which)
```

The sentence added to section 6 in the Leaderboards section above now reads:

```
Only the first ten questions of a quiz over all verbs post a score, to the leaderboard of the quiz's level; a quiz over your own verbs, a single verb, or conjugationgroups and verbs you chose does not, and neither do the ten more questions you may add.
```

### German

Der erste Punkt über das Quiz in Abschnitt 2 lautet nun:

```
- Quiz-Lebenszyklus-Ereignisse (Starten, Abbrechen, Abschließen einer Runde von zehn Fragen und wie viele Runden das Quiz erreicht hat) und wo das Quiz begonnen wurde: auf dem Quiz-Bildschirm, mit Ihren eigenen Verben, auf der Seite eines Verbs, in einer Sammlung, samt der Angabe, welche Sammlung, oder in einem selbst zusammengestellten Quiz, samt der Angabe, ob Sie Conjugationgroups, Verben oder beides gewählt haben (nicht aber, welche)
```

Der im Abschnitt zu den Bestenlisten oben ergänzte Satz in Abschnitt 6 lautet nun:

```
Nur die ersten zehn Fragen eines Quiz über alle Verben reichen ein Ergebnis ein, und zwar in der Bestenliste der Stufe des Quiz; ein Quiz über Ihre eigenen Verben, ein einzelnes Verb oder selbst gewählte Conjugationgroups und Verben tut das nicht, ebenso wenig die zehn weiteren Fragen, die Sie anhängen können.
```

## Practice sets (pedagogy plan, Phase 10, 2026-11-14)

Adds the `qrCode` value to the quiz signals' `source`, beside the existing `sharedLink`, for a
quiz begun from a practice set that someone shared as a QR code or as a link, and three signals:
`tapSharePracticeSet`, with how it was shared (`link` or `qrCode`) and the kind of choice it holds
(`customChoice`, as Phase 9 sends it); `viewPracticeSet`, with whether it arrived as a link or a
QR code and whether the app could read it (`opened` or `invalid`); and `tapKeepPracticeSet`, which
carries nothing. None says which conjugationgroups or verbs the set holds. A practice set's quiz
sends the set's level as `level`, since that is the level it asks. The lines change the first quiz
bullet as given in the Phase 9 section above, and add to the taps bullet as last given. A shared
set's link holds the sharer's chosen verbs, but it goes only where the learner sends it, and the
app sends none of it, so no line is needed for that.

### English

The first quiz bullet in section 2 now reads:

```
- Quiz lifecycle events (starting, quitting, completing a round of ten questions, and how many rounds the quiz has reached), and where the quiz was begun: the quiz screen, your own verbs, a verb's page, a collection, and which collection, a quiz you put together, and whether you chose conjugationgroups, verbs, or both (not which), or a practice set someone shared with you, and whether it came as a link or a QR code
```

The taps bullet in section 2, as last given above, gains at its end:

```
, sharing a practice set, as a link or a QR code, and whether it holds conjugationgroups, verbs, or both (not which), and keeping a shared practice set as your own quiz
```

A new bullet follows the one about collections:

```
- That you opened a shared practice set, whether it came as a link or a QR code, and whether the app could read it, but not which conjugationgroups or verbs it holds
```

### German

Der erste Punkt über das Quiz in Abschnitt 2 lautet nun:

```
- Quiz-Lebenszyklus-Ereignisse (Starten, Abbrechen, Abschließen einer Runde von zehn Fragen und wie viele Runden das Quiz erreicht hat) und wo das Quiz begonnen wurde: auf dem Quiz-Bildschirm, mit Ihren eigenen Verben, auf der Seite eines Verbs, in einer Sammlung, samt der Angabe, welche Sammlung, in einem selbst zusammengestellten Quiz, samt der Angabe, ob Sie Conjugationgroups, Verben oder beides gewählt haben (nicht aber, welche), oder in einem Übungsset, das jemand mit Ihnen geteilt hat, samt der Angabe, ob es als Link oder als QR-Code kam
```

Der Punkt über das Antippen in Abschnitt 2, wie oben zuletzt angegeben, endet nun mit:

```
, ein Übungsset als Link oder QR-Code teilen, samt der Angabe, ob es Conjugationgroups, Verben oder beides enthält (nicht aber, welche), und ein geteiltes Übungsset als eigenes Quiz behalten
```

Ein neuer Punkt folgt dem über Sammlungen:

```
- Dass Sie ein geteiltes Übungsset geöffnet haben, ob es als Link oder als QR-Code kam und ob die App es lesen konnte, nicht aber, welche Conjugationgroups oder Verben es enthält
```

## The practice record (pedagogy plan, Phase 11, 2026-11-14)

Adds the signal `tapResetPractice`, sent when Reset Practice in Settings is confirmed, which carries
nothing. The practice record itself is kept on the device and never sent (Decision 5 of the
pedagogy plan): which conjugations the learner has practiced, how the last answer went, and when
each is due again. The section 2 sentence that the app "does not record your quiz answers, your
scores" already reads "does not send", as staged in the My Verbs section above; a new paragraph
says what the app keeps. The review card's list paragraph, as last given in the Collections section,
no longer says the verb list holds review dates, since the practice record does.

### English

The taps bullet in section 2, as last given above, now ends as follows, the "and" before keeping
a practice set moving to the new last item:

```
, keeping a shared practice set as your own quiz, and resetting your practice record
```

The paragraph about the list kept on the device now reads:

```
The app keeps a list of the verbs you have opened and the verbs you have starred, so that it can show your recent verbs, My Verbs, and how many verbs of each collection you have looked up. The list stays on your device and is never sent.
```

A new paragraph follows it:

```
The app also keeps a practice record: which conjugations you have practiced in quizzes and on review cards, whether your last answer to each was right, and when each is due for review, so that it can show review cards and bring back what you missed. The record stays on your device and is never sent. Reset Practice in Settings erases it.
```

### German

Der Punkt über das Antippen in Abschnitt 2, wie oben zuletzt angegeben, endet nun so; das „und“
vor dem Behalten eines Übungssets rückt zum neuen letzten Glied:

```
, ein geteiltes Übungsset als eigenes Quiz behalten und den Übungsstand zurücksetzen
```

Der Absatz über die Liste auf dem Gerät lautet nun:

```
Die App führt eine Liste der Verben, die Sie geöffnet, und der Verben, die Sie mit einem Stern markiert haben, damit sie Ihre zuletzt geöffneten Verben, „Meine Verben“ und die Zahl der nachgeschlagenen Verben jeder Sammlung zeigen kann. Die Liste bleibt auf Ihrem Gerät und wird nie gesendet.
```

Ein neuer Absatz folgt:

```
Die App führt außerdem einen Übungsstand: welche Konjugationen Sie im Quiz und auf Wiederholungskarten geübt haben, ob Ihre letzte Antwort darauf richtig war und wann jede wieder zur Wiederholung ansteht, damit sie Wiederholungskarten zeigen und Verfehltes wiederholen kann. Der Übungsstand bleibt auf Ihrem Gerät und wird nie gesendet. „Übungsstand zurücksetzen“ in den Einstellungen löscht ihn.
```

## Review and My Mistakes (pedagogy plan, Phase 12, 2026-11-14)

Adds the values `review` and `mistakes` to the quiz signals' `source`, for a Review session of the
practice record's due questions and a session of the questions last answered wrongly, both begun
from the Quiz tab. Neither session sends how many questions it asked (`completeQuiz`'s
`questionCount`) or the question reached (`quitQuiz`'s and `abandonQuiz`'s `questionNumber`), since
a session shorter than ten is exactly as long as the learner's due or missed questions, and that
would be a count of wrong answers (Decision 5). Neither posts a score. The lines change the first
quiz bullet as given in the Phase 10 section above, and add a sentence after it.

### English

The first quiz bullet in section 2 now reads:

```
- Quiz lifecycle events (starting, quitting, completing a round of ten questions, and how many rounds the quiz has reached), and where the quiz was begun: the quiz screen, your own verbs, a verb's page, a collection, and which collection, a quiz you put together, and whether you chose conjugationgroups, verbs, or both (not which), a practice set someone shared with you, and whether it came as a link or a QR code, or a review of your due questions or of your mistakes
```

A sentence follows the bullet's list, before the next bullet:

```
A review of your due questions or of your mistakes reports neither how many questions it asked nor how far you got, since either would tell how many answers you had missed.
```

The sentence in section 6, as last given in the Custom quizzes section above, now reads:

```
Only the first ten questions of a quiz over all verbs post a score, to the leaderboard of the quiz's level; a quiz over your own verbs, a single verb, conjugationgroups and verbs you chose, or your due questions or mistakes does not, and neither do the ten more questions you may add.
```

### German

Der erste Punkt über das Quiz in Abschnitt 2 lautet nun:

```
- Quiz-Lebenszyklus-Ereignisse (Starten, Abbrechen, Abschließen einer Runde von zehn Fragen und wie viele Runden das Quiz erreicht hat) und wo das Quiz begonnen wurde: auf dem Quiz-Bildschirm, mit Ihren eigenen Verben, auf der Seite eines Verbs, in einer Sammlung, samt der Angabe, welche Sammlung, in einem selbst zusammengestellten Quiz, samt der Angabe, ob Sie Conjugationgroups, Verben oder beides gewählt haben (nicht aber, welche), in einem Übungsset, das jemand mit Ihnen geteilt hat, samt der Angabe, ob es als Link oder als QR-Code kam, oder bei der Wiederholung Ihrer anstehenden Fragen oder Ihrer Fehler
```

Ein Satz folgt der Aufzählung dieses Punkts:

```
Eine Wiederholung Ihrer anstehenden Fragen oder Ihrer Fehler meldet weder, wie viele Fragen sie gestellt hat, noch, wie weit Sie gekommen sind, denn beides verriete, wie viele Antworten Sie verfehlt hatten.
```

Der Satz in Abschnitt 6, wie zuletzt im Abschnitt zu selbst zusammengestellten Quizzen angegeben, lautet nun:

```
Nur die ersten zehn Fragen eines Quiz über alle Verben reichen ein Ergebnis ein, und zwar in der Bestenliste der Stufe des Quiz; ein Quiz über Ihre eigenen Verben, ein einzelnes Verb, selbst gewählte Conjugationgroups und Verben oder Ihre anstehenden Fragen oder Fehler tut das nicht, ebenso wenig die zehn weiteren Fragen, die Sie anhängen können.
```

## The practice hub (pedagogy plan, Phase 13, 2026-11-14)

Adds the parameter `source`, with the one value `tab`, to the existing signal `tapViewLeaderboard`
when the leaderboard is opened from the Quiz tab rather than from Settings. The bullet already says
"viewing the leaderboard", so its wording does not change. The Quiz tab now shows the results of
the last quiz (how many answers were right, the score, the level, and the day), which the app keeps
on the device with the practice record and never sends, so the practice-record paragraph added in
the Phase 11 section above names it.

### English

The practice-record paragraph now reads:

```
The app also keeps a practice record: which conjugations you have practiced in quizzes and on review cards, whether your last answer to each was right, when each is due for review, and the results of your last quiz, so that it can show review cards, bring back what you missed, and show how your last quiz went. The record stays on your device and is never sent. Reset Practice in Settings erases it.
```

### German

Der Absatz über den Übungsstand lautet nun:

```
Die App führt außerdem einen Übungsstand: welche Konjugationen Sie im Quiz und auf Wiederholungskarten geübt haben, ob Ihre letzte Antwort darauf richtig war, wann jede wieder zur Wiederholung ansteht und das Ergebnis Ihres letzten Quiz, damit sie Wiederholungskarten zeigen, Verfehltes wiederholen und zeigen kann, wie Ihr letztes Quiz lief. Der Übungsstand bleibt auf Ihrem Gerät und wird nie gesendet. „Übungsstand zurücksetzen“ in den Einstellungen löscht ihn.
```

## Verb Essentials (pedagogy plan, Phase 15, 2026-11-14)

Adds the value `verbEssentials` to the quiz signals' `source`, for Verb Essentials, an exercise
begun from the Quiz tab that asks three conjugations of each of five strong verbs. Its rounds are
fifteen questions, so the bullet's "a round of ten questions" becomes "a round of questions". Its
`completeQuiz` carries `questionCount` as other quizzes do, since a round's length depends on no
answer. It posts no score. The lines change the first quiz bullet and the section 6 sentence as
given in the Phase 12 section above.

### English

The first quiz bullet in section 2 now reads:

```
- Quiz lifecycle events (starting, quitting, completing a round of questions, and how many rounds the quiz has reached), and where the quiz was begun: the quiz screen, your own verbs, a verb's page, a collection, and which collection, a quiz you put together, and whether you chose conjugationgroups, verbs, or both (not which), a practice set someone shared with you, and whether it came as a link or a QR code, a review of your due questions or of your mistakes, or the Verb Essentials exercise
```

The sentence in section 6 now reads:

```
Only the first ten questions of a quiz over all verbs post a score, to the leaderboard of the quiz's level; a quiz over your own verbs, a single verb, conjugationgroups and verbs you chose, or your due questions or mistakes does not, nor does Verb Essentials, and neither do the ten more questions you may add.
```

### German

Der erste Punkt über das Quiz in Abschnitt 2 lautet nun:

```
- Quiz-Lebenszyklus-Ereignisse (Starten, Abbrechen, Abschließen einer Fragerunde und wie viele Runden das Quiz erreicht hat) und wo das Quiz begonnen wurde: auf dem Quiz-Bildschirm, mit Ihren eigenen Verben, auf der Seite eines Verbs, in einer Sammlung, samt der Angabe, welche Sammlung, in einem selbst zusammengestellten Quiz, samt der Angabe, ob Sie Conjugationgroups, Verben oder beides gewählt haben (nicht aber, welche), in einem Übungsset, das jemand mit Ihnen geteilt hat, samt der Angabe, ob es als Link oder als QR-Code kam, bei der Wiederholung Ihrer anstehenden Fragen oder Ihrer Fehler oder in der Übung „Verb-Grundlagen“
```

Der Satz in Abschnitt 6 lautet nun:

```
Nur die ersten zehn Fragen eines Quiz über alle Verben reichen ein Ergebnis ein, und zwar in der Bestenliste der Stufe des Quiz; ein Quiz über Ihre eigenen Verben, ein einzelnes Verb, selbst gewählte Conjugationgroups und Verben oder Ihre anstehenden Fragen oder Fehler tut das nicht, ebenso wenig die Verb-Grundlagen und die zehn weiteren Fragen, die Sie anhängen können.
```

## Ablaut-group practice (pedagogy plan, Phase 16, 2026-11-15)

Adds the values `ablautAlone` and `ablautMixed` to the quiz signals' `source`, for the practice of
an ablaut group alone or mixed with the groups the learner knows. `startQuiz` carries the group's
`collection` key, as a collection's quiz already does; the key names a fixed list, not anything
the learner typed. A mixed session sends neither `questionCount` nor `questionNumber`, since its
length can depend on which groups the learner knows. Which groups are known is computed on the
device from the practice record and is never sent. Neither session posts a score. The lines change
the first quiz bullet and the section 6 sentence as given in the Phase 15 section above.

### English

The first quiz bullet in section 2 now reads:

```
- Quiz lifecycle events (starting, quitting, completing a round of questions, and how many rounds the quiz has reached), and where the quiz was begun: the quiz screen, your own verbs, a verb's page, a collection, and which collection, a quiz you put together, and whether you chose conjugationgroups, verbs, or both (not which), a practice set someone shared with you, and whether it came as a link or a QR code, a review of your due questions or of your mistakes, the Verb Essentials exercise, or the practice of an ablaut group, alone or mixed, and which group
```

The sentence in section 6 now reads:

```
Only the first ten questions of a quiz over all verbs post a score, to the leaderboard of the quiz's level; a quiz over your own verbs, a single verb, conjugationgroups and verbs you chose, or your due questions or mistakes does not, nor do Verb Essentials and the practice of an ablaut group, and neither do the ten more questions you may add.
```

### German

Der erste Punkt über das Quiz in Abschnitt 2 lautet nun:

```
- Quiz-Lebenszyklus-Ereignisse (Starten, Abbrechen, Abschließen einer Fragerunde und wie viele Runden das Quiz erreicht hat) und wo das Quiz begonnen wurde: auf dem Quiz-Bildschirm, mit Ihren eigenen Verben, auf der Seite eines Verbs, in einer Sammlung, samt der Angabe, welche Sammlung, in einem selbst zusammengestellten Quiz, samt der Angabe, ob Sie Conjugationgroups, Verben oder beides gewählt haben (nicht aber, welche), in einem Übungsset, das jemand mit Ihnen geteilt hat, samt der Angabe, ob es als Link oder als QR-Code kam, bei der Wiederholung Ihrer anstehenden Fragen oder Ihrer Fehler, in der Übung „Verb-Grundlagen“ oder in der Übung einer Ablautgruppe, allein oder gemischt, samt der Angabe, welche Gruppe
```

Der Satz in Abschnitt 6 lautet nun:

```
Nur die ersten zehn Fragen eines Quiz über alle Verben reichen ein Ergebnis ein, und zwar in der Bestenliste der Stufe des Quiz; ein Quiz über Ihre eigenen Verben, ein einzelnes Verb, selbst gewählte Conjugationgroups und Verben oder Ihre anstehenden Fragen oder Fehler tut das nicht, ebenso wenig die Verb-Grundlagen, die Übung einer Ablautgruppe und die zehn weiteren Fragen, die Sie anhängen können.
```

## Name the Conjugation (pedagogy plan, Phase 17, 2026-11-15)

Adds the value `recognition` to the quiz signals' `source`, for Name the Conjugation, an exercise
begun from the Quiz tab that shows a conjugation and asks for its verb, conjugationgroup, and
person. Its rounds are ten questions, so `completeQuiz` carries `questionCount` as the default quiz
does. It posts no score, and its answers are kept neither in the practice record nor anywhere else,
so the practice-record paragraph is unchanged. The lines change the first quiz bullet and the
section 6 sentence as given in the Phase 16 section above.

### English

The first quiz bullet in section 2 now reads:

```
- Quiz lifecycle events (starting, quitting, completing a round of questions, and how many rounds the quiz has reached), and where the quiz was begun: the quiz screen, your own verbs, a verb's page, a collection, and which collection, a quiz you put together, and whether you chose conjugationgroups, verbs, or both (not which), a practice set someone shared with you, and whether it came as a link or a QR code, a review of your due questions or of your mistakes, the Verb Essentials exercise, the practice of an ablaut group, alone or mixed, and which group, or the Name the Conjugation exercise
```

The sentence in section 6 now reads:

```
Only the first ten questions of a quiz over all verbs post a score, to the leaderboard of the quiz's level; a quiz over your own verbs, a single verb, conjugationgroups and verbs you chose, or your due questions or mistakes does not, nor do Verb Essentials, the practice of an ablaut group, and Name the Conjugation, and neither do the ten more questions you may add.
```

### German

Der erste Punkt über das Quiz in Abschnitt 2 lautet nun:

```
- Quiz-Lebenszyklus-Ereignisse (Starten, Abbrechen, Abschließen einer Fragerunde und wie viele Runden das Quiz erreicht hat) und wo das Quiz begonnen wurde: auf dem Quiz-Bildschirm, mit Ihren eigenen Verben, auf der Seite eines Verbs, in einer Sammlung, samt der Angabe, welche Sammlung, in einem selbst zusammengestellten Quiz, samt der Angabe, ob Sie Conjugationgroups, Verben oder beides gewählt haben (nicht aber, welche), in einem Übungsset, das jemand mit Ihnen geteilt hat, samt der Angabe, ob es als Link oder als QR-Code kam, bei der Wiederholung Ihrer anstehenden Fragen oder Ihrer Fehler, in der Übung „Verb-Grundlagen“, in der Übung einer Ablautgruppe, allein oder gemischt, samt der Angabe, welche Gruppe, oder in der Übung „Konjugationen bestimmen“
```

Der Satz in Abschnitt 6 lautet nun:

```
Nur die ersten zehn Fragen eines Quiz über alle Verben reichen ein Ergebnis ein, und zwar in der Bestenliste der Stufe des Quiz; ein Quiz über Ihre eigenen Verben, ein einzelnes Verb, selbst gewählte Conjugationgroups und Verben oder Ihre anstehenden Fragen oder Fehler tut das nicht, ebenso wenig die Verb-Grundlagen, die Übung einer Ablautgruppe, „Konjugationen bestimmen“ und die zehn weiteren Fragen, die Sie anhängen können.
```

## Sentences (pedagogy plan, Phase 18, 2026-11-15)

Adds the value `sentences` to the quiz signals' `source`, for Sentences ("Lückensätze"), an
exercise begun from the Quiz tab that asks a verb's conjugation in a short sentence. Its rounds are
ten questions, so `completeQuiz` carries `questionCount` as the default quiz does. It posts no
score. Its answers go into the practice record, which stays on the device, as every production
answer does, so the practice-record paragraph is unchanged. Opening a verb's example sentence on the
results screen sends nothing: only a right answer's row offers it, so a signal for it would count
right answers (Decision 5). The lines change the first quiz bullet and the section 6 sentence as
given in the Phase 17 section above.

### English

The first quiz bullet in section 2 now reads:

```
- Quiz lifecycle events (starting, quitting, completing a round of questions, and how many rounds the quiz has reached), and where the quiz was begun: the quiz screen, your own verbs, a verb's page, a collection, and which collection, a quiz you put together, and whether you chose conjugationgroups, verbs, or both (not which), a practice set someone shared with you, and whether it came as a link or a QR code, a review of your due questions or of your mistakes, the Verb Essentials exercise, the practice of an ablaut group, alone or mixed, and which group, the Name the Conjugation exercise, or the Sentences exercise
```

The sentence in section 6 now reads:

```
Only the first ten questions of a quiz over all verbs post a score, to the leaderboard of the quiz's level; a quiz over your own verbs, a single verb, conjugationgroups and verbs you chose, or your due questions or mistakes does not, nor do Verb Essentials, the practice of an ablaut group, Name the Conjugation, and Sentences, and neither do the ten more questions you may add.
```

### German

Der erste Punkt über das Quiz in Abschnitt 2 lautet nun:

```
- Quiz-Lebenszyklus-Ereignisse (Starten, Abbrechen, Abschließen einer Fragerunde und wie viele Runden das Quiz erreicht hat) und wo das Quiz begonnen wurde: auf dem Quiz-Bildschirm, mit Ihren eigenen Verben, auf der Seite eines Verbs, in einer Sammlung, samt der Angabe, welche Sammlung, in einem selbst zusammengestellten Quiz, samt der Angabe, ob Sie Conjugationgroups, Verben oder beides gewählt haben (nicht aber, welche), in einem Übungsset, das jemand mit Ihnen geteilt hat, samt der Angabe, ob es als Link oder als QR-Code kam, bei der Wiederholung Ihrer anstehenden Fragen oder Ihrer Fehler, in der Übung „Verb-Grundlagen“, in der Übung einer Ablautgruppe, allein oder gemischt, samt der Angabe, welche Gruppe, in der Übung „Konjugationen bestimmen“ oder in der Übung „Lückensätze“
```

Der Satz in Abschnitt 6 lautet nun:

```
Nur die ersten zehn Fragen eines Quiz über alle Verben reichen ein Ergebnis ein, und zwar in der Bestenliste der Stufe des Quiz; ein Quiz über Ihre eigenen Verben, ein einzelnes Verb, selbst gewählte Conjugationgroups und Verben oder Ihre anstehenden Fragen oder Fehler tut das nicht, ebenso wenig die Verb-Grundlagen, die Übung einer Ablautgruppe, „Konjugationen bestimmen“, „Lückensätze“ und die zehn weiteren Fragen, die Sie anhängen können.
```

## Mastery (pedagogy plan, Phase 20, 2026-11-15)

Adds the signal `viewMastery`, sent when the Mastery page, reached from the Quiz tab, appears. It
carries nothing: not the level, and nothing of what the page shows. The page shows, from the
practice record kept on the device, which conjugations the learner has mastered, so the
practice-record paragraph as last given in the Phase 13 section above names it. The screens bullet
in section 2 gains the page.

### English

The first bullet in section 2 now reads:

```
- Which screens you visit (verb browser, verb page, family browser, family page, info browser, info article, quiz, mastery, tutor, settings)
```

The practice-record paragraph now reads:

```
The app also keeps a practice record: which conjugations you have practiced in quizzes and on review cards, whether your last answer to each was right, when each is due for review, and the results of your last quiz, so that it can show review cards, bring back what you missed, show how your last quiz went, and show which conjugations you have mastered. The record stays on your device and is never sent. Reset Practice in Settings erases it.
```

### German

Der erste Punkt in Abschnitt 2 lautet nun:

```
- Welche Bildschirme Sie besuchen (Verbbrowser, Verbseite, Familienbrowser, Familienseite, Infobrowser, Infoartikel, Quiz, Lernstand, Tutor, Einstellungen)
```

Der Absatz über den Übungsstand lautet nun:

```
Die App führt außerdem einen Übungsstand: welche Konjugationen Sie im Quiz und auf Wiederholungskarten geübt haben, ob Ihre letzte Antwort darauf richtig war, wann jede wieder zur Wiederholung ansteht und das Ergebnis Ihres letzten Quiz, damit sie Wiederholungskarten zeigen, Verfehltes wiederholen, zeigen kann, wie Ihr letztes Quiz lief, und zeigen kann, welche Konjugationen Sie beherrschen. Der Übungsstand bleibt auf Ihrem Gerät und wird nie gesendet. „Übungsstand zurücksetzen“ in den Einstellungen löscht ihn.
```

## Speed Round (pedagogy plan, Phase 21, 2026-11-15)

Adds the value `speedRound` to the quiz signals' `source`, for the Speed Round ("Blitzrunde"), an
exercise begun from the Quiz tab that asks, for sixty seconds, conjugations the practice record says
the learner has mastered. **It sends no counts**: neither `completeQuiz`'s `questionCount` nor
`quitQuiz`'s and `abandonQuiz`'s `questionNumber`, since a round's length is how many questions the
learner answered in a minute, a measure of the answers (Decision 5). It posts no score. Its answers
go nowhere, not even into the practice record. The learner's best round, the most right answers in
one, is kept on the device beside the practice record and never sent, so the practice-record
paragraph names it. The lines change the first quiz bullet, the section 6 sentence, the Phase 12
sentence about counts, and the practice-record paragraph as last given above.

### English

The first quiz bullet in section 2 now reads:

```
- Quiz lifecycle events (starting, quitting, completing a round of questions, and how many rounds the quiz has reached), and where the quiz was begun: the quiz screen, your own verbs, a verb's page, a collection, and which collection, a quiz you put together, and whether you chose conjugationgroups, verbs, or both (not which), a practice set someone shared with you, and whether it came as a link or a QR code, a review of your due questions or of your mistakes, the Verb Essentials exercise, the practice of an ablaut group, alone or mixed, and which group, the Name the Conjugation exercise, the Sentences exercise, or the Speed Round
```

The sentence in section 6 now reads:

```
Only the first ten questions of a quiz over all verbs post a score, to the leaderboard of the quiz's level; a quiz over your own verbs, a single verb, conjugationgroups and verbs you chose, or your due questions or mistakes does not, nor do Verb Essentials, the practice of an ablaut group, Name the Conjugation, Sentences, and the Speed Round, and neither do the ten more questions you may add.
```

The sentence about counts now reads:

```
A review of your due questions or of your mistakes, and a Speed Round, report neither how many questions they asked nor how far you got, since either would tell how many answers you had missed, or how quickly you answered.
```

The practice-record paragraph now reads:

```
The app also keeps a practice record: which conjugations you have practiced in quizzes and on review cards, whether your last answer to each was right, when each is due for review, the results of your last quiz, and your best Speed Round, so that it can show review cards, bring back what you missed, show how your last quiz went, show which conjugations you have mastered, and show your best. The record stays on your device and is never sent. Reset Practice in Settings erases it.
```

### German

Der erste Punkt über das Quiz in Abschnitt 2 lautet nun:

```
- Quiz-Lebenszyklus-Ereignisse (Starten, Abbrechen, Abschließen einer Fragerunde und wie viele Runden das Quiz erreicht hat) und wo das Quiz begonnen wurde: auf dem Quiz-Bildschirm, mit Ihren eigenen Verben, auf der Seite eines Verbs, in einer Sammlung, samt der Angabe, welche Sammlung, in einem selbst zusammengestellten Quiz, samt der Angabe, ob Sie Conjugationgroups, Verben oder beides gewählt haben (nicht aber, welche), in einem Übungsset, das jemand mit Ihnen geteilt hat, samt der Angabe, ob es als Link oder als QR-Code kam, bei der Wiederholung Ihrer anstehenden Fragen oder Ihrer Fehler, in der Übung „Verb-Grundlagen“, in der Übung einer Ablautgruppe, allein oder gemischt, samt der Angabe, welche Gruppe, in der Übung „Konjugationen bestimmen“, in der Übung „Lückensätze“ oder in der „Blitzrunde“
```

Der Satz in Abschnitt 6 lautet nun:

```
Nur die ersten zehn Fragen eines Quiz über alle Verben reichen ein Ergebnis ein, und zwar in der Bestenliste der Stufe des Quiz; ein Quiz über Ihre eigenen Verben, ein einzelnes Verb, selbst gewählte Conjugationgroups und Verben oder Ihre anstehenden Fragen oder Fehler tut das nicht, ebenso wenig die Verb-Grundlagen, die Übung einer Ablautgruppe, „Konjugationen bestimmen“, „Lückensätze“, die „Blitzrunde“ und die zehn weiteren Fragen, die Sie anhängen können.
```

Der Satz über die Anzahl der Fragen lautet nun:

```
Eine Wiederholung Ihrer anstehenden Fragen oder Ihrer Fehler und eine „Blitzrunde“ melden weder, wie viele Fragen sie gestellt haben, noch, wie weit Sie gekommen sind, denn beides verriete, wie viele Antworten Sie verfehlt hatten oder wie schnell Sie geantwortet haben.
```

Der Absatz über den Übungsstand lautet nun:

```
Die App führt außerdem einen Übungsstand: welche Konjugationen Sie im Quiz und auf Wiederholungskarten geübt haben, ob Ihre letzte Antwort darauf richtig war, wann jede wieder zur Wiederholung ansteht, das Ergebnis Ihres letzten Quiz und Ihren Bestwert in der „Blitzrunde“, damit sie Wiederholungskarten zeigen, Verfehltes wiederholen, zeigen kann, wie Ihr letztes Quiz lief, welche Konjugationen Sie beherrschen und was Ihr Bestwert ist. Der Übungsstand bleibt auf Ihrem Gerät und wird nie gesendet. „Übungsstand zurücksetzen“ in den Einstellungen löscht ihn.
```

## A daily session and a streak (pedagogy plan, Phase 22, 2026-11-15)

Adds the values `daily` and `reminder` to the quiz signals' `source`: a daily session ("Tägliche
Übung") begun from the Quiz tab, and one begun by tapping the daily reminder, which opens the app
and starts the session. `completeQuiz` for a daily session also carries the new parameter `streak`,
the days in a row the learner has finished one, in bands (`1`, `2-6`, `7-29`, `30+`); a streak
awaiting repair is sent as the streak at stake. The daily session sends its question count as the
default quiz does, since it is always ten. Adds the signal `tapDailyReminder`, with the parameter
`enabled` (`true`, `false`, or `denied` when the learner turned the reminder on and refused the
system's request to send notifications). The reminder is a local notification, scheduled by the app
on the device; its text is written there and nothing about it leaves the device. The days on which
daily sessions were finished are kept on the device with the practice record and never sent but as
the band, so the practice-record paragraph names the streak. The lines change the first quiz
bullet, the taps bullet, the section 6 sentence, and the practice-record paragraph as last given
above.

### English

The first quiz bullet in section 2 now reads:

```
- Quiz lifecycle events (starting, quitting, completing a round of questions, and how many rounds the quiz has reached), and where the quiz was begun: the quiz screen, your own verbs, a verb's page, a collection, and which collection, a quiz you put together, and whether you chose conjugationgroups, verbs, or both (not which), a practice set someone shared with you, and whether it came as a link or a QR code, a review of your due questions or of your mistakes, the Verb Essentials exercise, the practice of an ablaut group, alone or mixed, and which group, the Name the Conjugation exercise, the Sentences exercise, the Speed Round, or the daily session, and whether you began it from its reminder. When you finish a daily session, roughly how many days in a row you have finished one (1, 2 to 6, 7 to 29, or 30 or more)
```

The taps bullet in section 2, as last given above, now ends as follows, the "and" before resetting
the practice record moving to the new last item:

```
, resetting your practice record, and turning the daily reminder on or off, and whether you allowed notifications
```

The sentence in section 6 now reads:

```
Only the first ten questions of a quiz over all verbs post a score, to the leaderboard of the quiz's level; a quiz over your own verbs, a single verb, conjugationgroups and verbs you chose, or your due questions or mistakes does not, nor do Verb Essentials, the practice of an ablaut group, Name the Conjugation, Sentences, the Speed Round, and the daily session, and neither do the ten more questions you may add.
```

The practice-record paragraph now reads:

```
The app also keeps a practice record: which conjugations you have practiced in quizzes and on review cards, whether your last answer to each was right, when each is due for review, the results of your last quiz, your best Speed Round, and the days on which you finished a daily session, so that it can show review cards, bring back what you missed, show how your last quiz went, show which conjugations you have mastered, show your best, and show your streak. The record stays on your device and is never sent. Reset Practice in Settings erases it. The daily reminder, if you turn it on, is scheduled on your device, which writes what it says from the record; nothing about it is sent.
```

### German

Der erste Punkt über das Quiz in Abschnitt 2 lautet nun:

```
- Quiz-Lebenszyklus-Ereignisse (Starten, Abbrechen, Abschließen einer Fragerunde und wie viele Runden das Quiz erreicht hat) und wo das Quiz begonnen wurde: auf dem Quiz-Bildschirm, mit Ihren eigenen Verben, auf der Seite eines Verbs, in einer Sammlung, samt der Angabe, welche Sammlung, in einem selbst zusammengestellten Quiz, samt der Angabe, ob Sie Conjugationgroups, Verben oder beides gewählt haben (nicht aber, welche), in einem Übungsset, das jemand mit Ihnen geteilt hat, samt der Angabe, ob es als Link oder als QR-Code kam, bei der Wiederholung Ihrer anstehenden Fragen oder Ihrer Fehler, in der Übung „Verb-Grundlagen“, in der Übung einer Ablautgruppe, allein oder gemischt, samt der Angabe, welche Gruppe, in der Übung „Konjugationen bestimmen“, in der Übung „Lückensätze“, in der „Blitzrunde“ oder in der täglichen Übung, samt der Angabe, ob Sie diese über ihre Erinnerung begonnen haben. Wenn Sie eine tägliche Übung abschließen, ungefähr, an wie vielen Tagen in Folge Sie eine abgeschlossen haben (1, 2 bis 6, 7 bis 29 oder 30 und mehr)
```

Der Punkt über das Antippen in Abschnitt 2, wie oben zuletzt angegeben, endet nun so; das „und“
vor dem Zurücksetzen des Übungsstands rückt zum neuen letzten Glied:

```
, den Übungsstand zurücksetzen und die tägliche Erinnerung ein- oder ausschalten, samt der Angabe, ob Sie Mitteilungen erlaubt haben
```

Der Satz in Abschnitt 6 lautet nun:

```
Nur die ersten zehn Fragen eines Quiz über alle Verben reichen ein Ergebnis ein, und zwar in der Bestenliste der Stufe des Quiz; ein Quiz über Ihre eigenen Verben, ein einzelnes Verb, selbst gewählte Conjugationgroups und Verben oder Ihre anstehenden Fragen oder Fehler tut das nicht, ebenso wenig die Verb-Grundlagen, die Übung einer Ablautgruppe, „Konjugationen bestimmen“, „Lückensätze“, die „Blitzrunde“, die tägliche Übung und die zehn weiteren Fragen, die Sie anhängen können.
```

Der Absatz über den Übungsstand lautet nun:

```
Die App führt außerdem einen Übungsstand: welche Konjugationen Sie im Quiz und auf Wiederholungskarten geübt haben, ob Ihre letzte Antwort darauf richtig war, wann jede wieder zur Wiederholung ansteht, das Ergebnis Ihres letzten Quiz, Ihren Bestwert in der „Blitzrunde“ und die Tage, an denen Sie eine tägliche Übung abgeschlossen haben, damit sie Wiederholungskarten zeigen, Verfehltes wiederholen, zeigen kann, wie Ihr letztes Quiz lief, welche Konjugationen Sie beherrschen, was Ihr Bestwert ist und wie lang Ihre Serie ist. Der Übungsstand bleibt auf Ihrem Gerät und wird nie gesendet. „Übungsstand zurücksetzen“ in den Einstellungen löscht ihn. Die tägliche Erinnerung wird, wenn Sie sie einschalten, auf Ihrem Gerät geplant, das ihren Text aus dem Übungsstand schreibt; nichts davon wird gesendet.
```

## Personal bests and achievements (pedagogy plan, Phase 23, 2026-11-15)

Adds the signal `tapViewAchievements`, with `source` `tab` when sent from the Quiz tab and none
from Settings, when View Achievements is tapped. Nothing about progress is sent with it. The app
now reports progress toward eight Game Center achievements, each earned by mastering conjugations,
to Game Center while the learner is signed in, so section 6 says so; the progress is a percentage
for each achievement, computed on the device from the practice record, which itself is never sent.
The best score of a quiz over all verbs at each level is kept on the device beside the practice
record and never sent, so the practice-record paragraph names it. The lines change the taps bullet
and the practice-record paragraph as last given above, and add a sentence to section 6.

### English

In the taps bullet in section 2, as last given above, "viewing the leaderboard" now reads:

```
viewing the leaderboard or the achievements
```

A new sentence for section 6, after the sentence about which quizzes post a score:

```
If you are signed in to Game Center, the app also reports your progress toward its achievements, which you earn by mastering conjugations, as a percentage for each achievement. It works that progress out on your device from your practice record, which is never sent.
```

The practice-record paragraph now reads:

```
The app also keeps a practice record: which conjugations you have practiced in quizzes and on review cards, whether your last answer to each was right, when each is due for review, the results of your last quiz, your best Speed Round, your best score at each quiz level, and the days on which you finished a daily session, so that it can show review cards, bring back what you missed, show how your last quiz went, show which conjugations you have mastered, show your bests, and show your streak. The record stays on your device and is never sent. Reset Practice in Settings erases it. The daily reminder, if you turn it on, is scheduled on your device, which writes what it says from the record; nothing about it is sent.
```

### German

Im Punkt über das Antippen in Abschnitt 2, wie oben zuletzt angegeben, lautet „die Bestenliste
ansehen“ nun:

```
die Bestenliste oder die Erfolge ansehen
```

Ein neuer Satz für Abschnitt 6, nach dem Satz darüber, welche Quiz ein Ergebnis einreichen:

```
Wenn Sie bei Game Center angemeldet sind, meldet die App außerdem Ihren Fortschritt bei ihren Erfolgen, die Sie durch das Beherrschen von Konjugationen erringen, als Prozentwert je Erfolg. Diesen Fortschritt berechnet sie auf Ihrem Gerät aus Ihrem Übungsstand, der nie gesendet wird.
```

Der Absatz über den Übungsstand lautet nun:

```
Die App führt außerdem einen Übungsstand: welche Konjugationen Sie im Quiz und auf Wiederholungskarten geübt haben, ob Ihre letzte Antwort darauf richtig war, wann jede wieder zur Wiederholung ansteht, das Ergebnis Ihres letzten Quiz, Ihren Bestwert in der „Blitzrunde“, Ihren Bestwert auf jeder Quizstufe und die Tage, an denen Sie eine tägliche Übung abgeschlossen haben, damit sie Wiederholungskarten zeigen, Verfehltes wiederholen, zeigen kann, wie Ihr letztes Quiz lief, welche Konjugationen Sie beherrschen, was Ihre Bestwerte sind und wie lang Ihre Serie ist. Der Übungsstand bleibt auf Ihrem Gerät und wird nie gesendet. „Übungsstand zurücksetzen“ in den Einstellungen löscht ihn. Die tägliche Erinnerung wird, wenn Sie sie einschalten, auf Ihrem Gerät geplant, das ihren Text aus dem Übungsstand schreibt; nichts davon wird gesendet.
```
