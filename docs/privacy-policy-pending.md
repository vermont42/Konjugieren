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
