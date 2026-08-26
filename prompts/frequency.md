Please read `docs/dwds-permission-email.md` and files referenced in it.

Good news! I just got this email:

```
From: Franziska Nojack <franziska.nojack@bbaw.de>
To: Josh Adams <vermontcoder@gmail.com>
Subject: Re: Konjugieren

Lieber Herr Adams,

vielen Dank für Ihre gewissenhafte Anfrage bzgl. der Frequenzdaten.
Haben Sie ebenso Dank für Ihre wertschätzenden Worte und für Ihre
Geduld!

Sie können die DWDS-Häufigkeitsdaten gern für Ihre App abfragen und
nutzen. Die Menge der API-Abfragen scheint mir angemessen. Falls es mal
zu viele Abfragen auf einmal werden sollten, wird es ohnehin zu einer
vorübergehenden Blockade kommen. Falls solche Probleme auftreten
sollten, geben Sie mir gern Bescheid! Ich halte es aber bei dem von
Ihnen beschriebenen, behutsamen Vorgehen für unwahrscheinlich.

Sie können das DWDS als Quelle in der Danksagung folgendermaßen
zitieren: „Häufigkeitsrangfolge der Verben abgeleitet aus den
Worthäufigkeitsangaben des Digitalen Wörterbuchs der deutschen Sprache,
https://www.dwds.de/, abgerufen am xx.xx.2026“
Sie können das letzte Abrufdatum oder eine Zeitspanne nennen.

Zu den Hintergründen, wie wir die Worthäufigkeiten erschließen, kann ich
Ihnen diese Dokumentationsseite empfehlen, vielleicht kennen Sie sie
auch schon: https://www.dwds.de/d/worthaeufigkeit

Und Sie fragten noch, ob wir einen Hinweis hätten, was die Benennung der
Menge der Formen eines Wortes bzw. Verbs betrifft. Sie schrieben ja von
„Conjugationgroup“, was sicherlich eine passende und verständliche
Wortschöpfung ist. Wir nutzen im Projekt den Begriff
„Flexionsparadigma“. Aber dieser Terminus ist eben sehr fachsprachlich.

Melden Sie sich mit Rückfragen immer gern bei uns!

Herzliche Grüße
Franziska Nojack
```

Largely for my reference, here is the translation:

```
Dear Mr. Adams,

Thank you very much for your conscientious inquiry regarding the frequency
data. Thank you as well for your kind words and for your patience!

You are welcome to query and use the DWDS frequency data for your app. The
volume of API queries seems reasonable to me. Should it ever become too many
queries at once, a temporary block will occur in any case. If such problems do
arise, please let me know! Given the careful approach you describe, though, I
consider that unlikely.

You may cite DWDS as a source in your acknowledgments as follows: "Frequency
ranking of the verbs derived from the word-frequency data of the Digitales
Wörterbuch der deutschen Sprache, https://www.dwds.de/, accessed on xx.xx.2026."
You may give either the date of last access or a span of time.

On the background of how we derive word frequencies, I can recommend this
documentation page, which you may already know:
https://www.dwds.de/d/worthaeufigkeit

You also asked whether we had any guidance on what to call the set of forms of
a word, or of a verb. You wrote of "Conjugationgroup," which is certainly an apt
and comprehensible coinage. Within the project we use the term
"Flexionsparadigma" (inflectional paradigm). But that term is very much one of
specialist jargon.

Please feel free to contact us any time with further questions!

Warm regards,
Franziska Nojack
```

Question for you: Are we using DWDS frequency data already? If not, let's start using it.

After doing so, please add the attribution to creditsText , localizing.

In terminologyText, at the end of the Conjugationgroup section, put this new paragraph, localizing:

```
The Digitales Wörterbuch der deutschen Sprache has independently coined the term Flexionsparadigma for the Conjugationgroup concept. [Insert etymologies of flexion and paradigma here.]
```

You and I will workshop a reply to Franziska after Konjugieren changes are done.