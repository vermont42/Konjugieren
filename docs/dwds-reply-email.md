# Reply to DWDS

Draft of a reply to Franziska Nojack at BBAW, answering the permission grant of 2026-08-26.
The request that prompted her mail, and a summary of what her reply settled, are in
[`dwds-permission-email.md`](dwds-permission-email.md).

Having shipped version 1.4, Josh sent this reply to Franziska on 2026-08-30.

**Before sending:**

- **The version claim is ahead of reality.** The body says the data shipped in version 1.4.
  As of this draft it has not shipped at all: the counts are in `Verbs.xml` on `main` and the
  credit is in `Localizable.xcstrings`, but no build has gone to App Review. Either ship 1.4
  first or change the sentence. This is the one factual claim in the letter that is not true
  when written.
- Send the German. The English below it is a translation for Josh's reference, following the
  same convention as the original request, not a second version to send alongside.
- The query figures are measured: 3,572 lemmas in the first pass, 230 in each of two probe
  passes, and roughly 20 by hand, so "gut 4.000" is accurate and slightly conservative.
- The three API observations are offered as a user's feedback, not a bug report, and the
  second one is the substantive one. If she wants the full list, it regenerates from
  `verbdata/dwds/quarantine-round2.json`.
- The question at the end is genuine and she invited it ("Melden Sie sich mit Rückfragen
  immer gern bei uns!"). Do not cut it for brevity; it is the part she is best placed to
  answer and the part that treats her as a colleague rather than a permissions desk.

Both bodies below contain no Markdown, so either can be pasted directly into a mail client.

---

An: Franziska Nojack
Betreff: Re: Konjugieren


Liebe Frau Nojack,

haben Sie herzlichen Dank für Ihre Genehmigung und für die Mühe, die Sie sich mit Ihrer Antwort gemacht haben. Sie hat mehr geklärt, als ich gefragt hatte.

Die Häufigkeitsdaten sind inzwischen in Version 1.4 von Konjugieren enthalten. Die Danksagungsseite der App trägt nun einen eigenen Abschnitt „Verbhäufigkeit“ mit genau der von Ihnen vorgeschlagenen Formulierung:

„Häufigkeitsrangfolge der Verben abgeleitet aus den Worthäufigkeitsangaben des Digitalen Wörterbuchs der deutschen Sprache, https://www.dwds.de/, abgerufen am 26.08.2026.“

Daneben steht Ihr Hinweis auf https://www.dwds.de/d/worthaeufigkeit, denn die Frage, wie die Zahlen zustande kommen, dürfte manche Nutzer ebenso interessieren wie mich. Ausgeliefert wird weiterhin allein die abgeleitete Rangzahl; die Trefferzahlen selbst bleiben außerhalb des öffentlichen Repositorys.

Zum Umfang: Am 26.08.2026 habe ich gut 4.000 Abfragen gestellt, mit zwei parallelen Verbindungen und einer halben Sekunde Pause je Abfrage, also etwa 1,6 Abfragen pro Sekunde. Eine Blockade gab es nicht, und die Antwortzeiten lagen durchgehend bei ungefähr 0,7 Sekunden. Sie hatten um Nachricht gebeten, falls Probleme aufträten. Es sind keine aufgetreten.

Eine Beobachtung am Rande, die Ihre Sorgfalt bestätigt: Ich habe den gesamten Bestand neu abgefragt, statt nur die fehlenden Verben zu ergänzen. Der Grund stand in Ihren eigenen Antworten. Im Juli meldete die API ein Korpus von 53.203.990.582 Token, im August eines von 53.303.287.841. Zahlen aus zwei Korpusständen lassen sich nicht in eine gemeinsame Rangfolge bringen, und der Fehler wäre an keiner Stelle sichtbar geworden.

Drei Dinge sind mir bei den Abfragen aufgefallen, die für Sie vielleicht von Interesse sind. Ich schildere sie als Rückmeldung eines dankbaren Nutzers, nicht als Beschwerde.

Erstens lemmatisiert die API einen bloßen Infinitiv, der zugleich ein Adjektiv ist, auf das Adjektiv: runden auf rund, bleichen auf bleich, lauten auf laut. Die zurückgegebene Zahl ist echt, gehört aber einem anderen Wort, und nichts in der Antwort weist darauf hin. Abhilfe schafft eine eindeutig verbale Form, also rundet statt runden. Das ist mir früh genug aufgefallen; ich erwähne es nur, weil es andere ebenso treffen dürfte.

Zweitens, und das ist der Punkt, der mich am meisten beschäftigt hat: Für 83 Verben meines Bestandes scheint das DWDS keinen Lemmaeintrag zu haben. Statt dies zu melden, gibt die API die Anfrage großgeschrieben zurück und nennt eine Zahl, die offenbar die Belege der Zeichenkette selbst zählt. So wird starkmachen zu „Starkmachen“ mit 10.015 Treffern, und auch eine flektierte Form hilft nicht weiter, da starkgemacht zu „starkgemacht“ wird. Für eine automatisierte Auswertung ist das die schwierigste aller Antwortformen, weil sie sich von einem echten Lemmatotal nicht unterscheiden lässt: die eine Zahl zählt alle Flexionsformen, die andere nur eine Zeichenkette. Ein Feld, das eine gefundene Lemmaform von einer solchen Rückfallantwort trennt, wäre für Anwendungen wie meine außerordentlich hilfreich. Ich habe diese 83 Verben schließlich bei einer redaktionellen Schätzung belassen, gerade weil eine Zahl, die gemessen aussieht und es nicht ist, schlechter ist als eine offen gekennzeichnete Schätzung.

Drittens sind mir einige Lemmatisierungen begegnet, die ich mir nicht erklären kann. Ein eingeschobenes e nach dem Präfix bei entwerten zu „entewert“, entweichen zu „enteweich“, entgelten zu „entegelt“ und verdreschen zu „verderesch“; ein verkürzter Stamm bei austeilen zu „austeil“, bestreichen zu „bestreich“ und wägen zu „wäg“; und bei hinzubekommen die Deutung als zu-Infinitiv von hinbekommen. Falls es Ihnen nützt, schicke ich Ihnen gern die vollständige Liste mit den jeweiligen Antworten.

Ihre Auskunft zum Terminus hat es schließlich in die App selbst geschafft. Der Abschnitt „Conjugationgroup“ des Terminologie-Artikels endet nun mit Ihrem Hinweis auf das Flexionsparadigma, samt der Herkunft beider Bestandteile. Beim Nachschlagen ist mir aufgefallen, dass Flexion und Beugung dasselbe Bild zweimal zeichnen, einmal aus dem Lateinischen entlehnt und einmal zu biegen gebildet, und dass Paradigma wörtlich ein Nebeneinanderzeigen ist, also genau das, was die App auf dem Verb-Bildschirm tut. Dass ausgerechnet die Terminologie des Flektierens von einem starken Verb getragen wird, das die App selbst konjugiert, hat mich gefreut.

Eine Sache habe ich dabei behauptet, und ich wüsste gern, ob Sie sie unterschreiben würden. Ich beschreibe eine Conjugationgroup als wohl eine Teilmenge eines Flexionsparadigmas, da das Paradigma sämtliche Formen eines Wortes umfasst und die Conjugationgroup nur jene, die Tempus, Modus und Genus verbi teilen. Das „wohl“ steht dort, weil mir der Terminus in der Literatur sowohl für den vollständigen Formenbestand eines Lexems als auch für das Muster einer ganzen Flexionsklasse begegnet ist. Sollte die Beschreibung zu grob sein, korrigiere ich sie gern.

Konjugieren ist kostenlos und werbefrei und findet sich hier:

  https://apps.apple.com/us/app/konjugieren/id6758258747

Über eine Rückmeldung würde ich mich freuen, bin aber ebenso dankbar, wenn Sie Ihre Zeit für Wichtigeres verwenden.

Nochmals vielen Dank, und ebenso dafür, dass Sie eine Ressource pflegen, ohne die diese Arbeit nicht möglich gewesen wäre.

Herzliche Grüße

Josh Adams
vermontcoder@gmail.com


---

## English Translation

For Josh's reference. Not to be sent, and not to be sent alongside the German.

---

To: Franziska Nojack
Subject: Re: Konjugieren


Dear Ms. Nojack,

Thank you very much for your permission, and for the trouble you took over your reply. It settled more than I had asked.

The frequency data is now part of version 1.4 of Konjugieren. The app's acknowledgments page carries its own "Verbhäufigkeit" section with exactly the wording you proposed:

"Häufigkeitsrangfolge der Verben abgeleitet aus den Worthäufigkeitsangaben des Digitalen Wörterbuchs der deutschen Sprache, https://www.dwds.de/, abgerufen am 26.08.2026."

Beside it stands your pointer to https://www.dwds.de/d/worthaeufigkeit, since the question of how the numbers come about is likely to interest some users as much as it interested me. What ships is still only the derived rank; the hit counts themselves stay outside the public repository.

On volume: on 26.08.2026 I made a little over 4,000 queries, using two parallel connections and a half-second pause per query, so roughly 1.6 queries per second. There was no block, and response times were consistently around 0.7 seconds. You had asked to be told if problems arose. None did.

An observation in passing that vindicates your care: I re-queried the entire corpus rather than merely filling in the verbs I was missing. The reason was in your own responses. In July the API reported a corpus of 53,203,990,582 tokens, and in August one of 53,303,287,841. Figures from two corpus states cannot be brought into a common ranking, and the error would not have been visible anywhere.

Three things struck me during the queries that may be of interest to you. I offer them as feedback from a grateful user, not as a complaint.

First, the API lemmatizes a bare infinitive that is also an adjective to the adjective: runden to rund, bleichen to bleich, lauten to laut. The number returned is real, but it belongs to a different word, and nothing in the response indicates this. An unambiguously verbal form is the remedy, so rundet rather than runden. I noticed this early enough; I mention it only because it is likely to catch others too.

Second, and this is the point that occupied me most: for 83 verbs in my corpus, DWDS appears to have no lemma entry. Rather than reporting this, the API returns the query capitalized and gives a number that evidently counts occurrences of the string itself. So starkmachen becomes "Starkmachen" with 10,015 hits, and an inflected form does not help either, since starkgemacht becomes "starkgemacht". For automated use this is the most difficult of all response shapes, because it cannot be distinguished from a genuine lemma total: the one number counts every inflected form, the other only a string. A field separating a found lemma from such a fallback response would be extraordinarily helpful for applications like mine. In the end I left those 83 verbs with an editorial estimate, precisely because a number that looks measured and is not is worse than an openly marked estimate.

Third, I met some lemmatizations I cannot account for. An inserted e after the prefix, in entwerten to "entewert", entweichen to "enteweich", entgelten to "entegelt", and verdreschen to "verderesch"; a truncated stem, in austeilen to "austeil", bestreichen to "bestreich", and wägen to "wäg"; and, for hinzubekommen, a reading as the zu-infinitive of hinbekommen. If it is of use to you, I would gladly send the complete list with the responses in each case.

Your answer about the term, finally, made it into the app itself. The "Conjugationgroup" section of the terminology article now closes with your pointer to Flexionsparadigma, together with the origins of both halves. Looking them up, I noticed that Flexion and Beugung draw the same picture twice, once borrowed from Latin and once built on biegen, and that Paradigma is literally a showing side by side, which is exactly what the app does on the verb screen. That the terminology of inflection should rest on a strong verb the app itself conjugates was a pleasure to find.

There is one claim I made in the process, and I would like to know whether you would endorse it. I describe a Conjugationgroup as arguably a subset of a Flexionsparadigma, since the paradigm comprises all the forms of a word and the Conjugationgroup only those sharing a tense, a mood, and a voice. The "arguably" is there because I have met the term in the literature both for the complete set of forms of a lexeme and for the pattern of an entire inflection class. Should the description be too coarse, I would gladly correct it.

Konjugieren is free and carries no advertising, and can be found here:

  https://apps.apple.com/us/app/konjugieren/id6758258747

I would be delighted by any response, but equally grateful if you spend your time on more important things.

Thank you again, and thank you as well for maintaining a resource without which this work would not have been possible.

Warm regards,

Josh Adams
vermontcoder@gmail.com
