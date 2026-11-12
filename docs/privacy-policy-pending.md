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

Adds `source` to `viewVerbView`, and the signals `finishSearch` and `leaveVerbView`. See
[`feature-architecture.md`](feature-architecture.md#analytics) for the vocabulary.

### English

New bullets for the list in section 2:

```
- How you reached a verb's page: for example from a search, the verb list, a family page, a widget, Spotlight, or a shortcut
- How far down a verb's page you scrolled (its top, the conjugation tables, the etymology, or the example sentence), and roughly how long the page was open (under 5 seconds, 5 to 15 seconds, 15 to 60 seconds, or longer)
- When a search ends: whether you opened a verb, the kind of match that found it (for example the infinitive, a spelling without umlauts, or an English meaning), and rough counts: the length of what you typed (1 to 2 letters, 3 to 5, 6 to 9, or 10 or more), how many verbs matched (none, 1, 2 to 10, or more), and where the verb you opened stood in the list (first, second to fifth, or lower)
```

The paragraph after the list now reads:

```
A screen visit or a tap is recorded only as having happened, apart from the details about verb pages and searches listed above. Nothing you type and nothing on the screen is sent with any event. That you searched is recorded, with the rough counts above; what you typed is not. That you opened a verb's page is recorded; which verb is not.
```

### German

Neue Punkte für die Liste in Abschnitt 2:

```
- Wie Sie die Seite eines Verbs erreicht haben: zum Beispiel über die Suche, die Verbliste, eine Familienseite, ein Widget, Spotlight oder einen Kurzbefehl
- Wie weit Sie auf der Seite eines Verbs nach unten gescrollt haben (ihr Anfang, die Konjugationstabellen, die Etymologie oder der Beispielsatz) und ungefähr, wie lange die Seite geöffnet war (unter 5 Sekunden, 5 bis 15 Sekunden, 15 bis 60 Sekunden oder länger)
- Wenn eine Suche endet: ob Sie ein Verb geöffnet haben, welche Art von Treffer es gefunden hat (zum Beispiel der Infinitiv, eine Schreibung ohne Umlaute oder eine englische Bedeutung) und grobe Zahlen: die Länge Ihrer Eingabe (1 bis 2 Buchstaben, 3 bis 5, 6 bis 9 oder 10 und mehr), wie viele Verben passten (keines, 1, 2 bis 10 oder mehr) und an welcher Stelle der Liste das geöffnete Verb stand (an erster, an zweiter bis fünfter oder an späterer Stelle)
```

Der Absatz nach der Liste lautet nun:

```
Ein Bildschirmbesuch oder ein Antippen wird nur als Ereignis erfasst, abgesehen von den oben genannten Angaben zu Verbseiten und Suchen. Nichts, was Sie eingeben, und nichts, was auf dem Bildschirm steht, wird mit einem Ereignis gesendet. Erfasst wird, dass Sie gesucht haben, mit den oben genannten groben Zahlen, nicht aber, was Sie eingegeben haben. Erfasst wird, dass Sie die Seite eines Verbs geöffnet haben, nicht aber, welches Verb.
```
