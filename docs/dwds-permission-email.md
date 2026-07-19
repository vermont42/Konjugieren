# Permission Request to DWDS

Draft of an email to `dwds@bbaw.de` requesting permission to derive Konjugieren's verb
frequency ranking from the DWDS frequency API.

**Why this email is necessary:** the DWDS Nutzungsbedingungen reserve BBAW's rights under
§ 44b UrhG and require explicit permission for automated queries not covered by § 60d, the
exception available to non-commercial research organizations. A shipping App Store app is
not one. See the correction in [`verb-sources.md`](verb-sources.md) for the full reasoning
and [`../verbdata/README.md`](../verbdata/README.md) for the snapshot the email refers to.

**Before sending:**

- Decide whether to disclose that the 990-lemma snapshot has already been fetched. The draft
  below does disclose it, on the theory that BBAW can see the requests in their logs anyway
  and that candor costs nothing when the ask is small and the answer is probably yes.
- Send one version, not both. A German translation follows the English body below; BBAW
  works in German, so it is likely the better choice.
- The proposed attribution line is a guess at house style. `dwds.de/d/zitieren` renders its
  citation templates with JavaScript, so the exact form was not readable when this was
  drafted. The email asks BBAW to specify the wording they prefer, which sidesteps the issue.
- Reconcile the verb count. The draft says 990, and `description.md` says 989 in one place
  and 990 in another.
- The conjugationgroup paragraph explains the coinage and invites correction, on the theory
  that BBAW lexicographers are the ideal audience for it and may know a standard term.
  See [`terminology.md`](terminology.md) for the settled German declension.

The email body below contains no Markdown, so it can be pasted directly into a mail client.

---

To: dwds@bbaw.de
Subject: Permission request: frequency data for a free German-learning app (Konjugieren)


Dear DWDS Team,

I am writing to request permission under your Nutzungsbedingungen to use the DWDS frequency
API as the source of a verb-frequency ranking in a free iOS app.

The app. Konjugieren is a German verb-conjugation reference and quiz app for learners of
German. It conjugates 990 verbs across fifteen conjugationgroups, quizzes the user on them,
and pairs each verb with an etymology and a literary example sentence. It is free, contains
no advertising, and has no in-app purchases or subscriptions. I am an independent developer,
not a company, and the app is not monetized in any form. Its source code and data files are
public. The App Store listing is at

  https://apps.apple.com/us/app/konjugieren/id6758258747

and the source code is at

  https://github.com/vermont42/Konjugieren

I wrote it as a tribute to my grandfather, who was born in Minster, Ohio, a town where German
was the language of daily life until the First World War.

A note on one word above. I use "conjugationgroup" because I could not find an established
English term for the concept, and coining one seemed better than misusing an existing one. A
conjugationgroup is the full set of forms a verb takes for a single combination of tense,
mood, and voice, so that Präsens Indikativ is one conjugationgroup and Präsens Konjunktiv I
is another. Materials for English-speaking learners generally call these "tenses", which is
plainly wrong: those two examples share a tense and differ only in mood. The German
localization borrows the coinage back unchanged, as die Conjugationgroup, plural die
Conjugationgroups: feminine by analogy with die Gruppe, but keeping the -s plural that German
tends to grant an unassimilated Anglicism. If a standard term does exist and I have simply
failed to find it, I would welcome the correction.

What I would like to do. Each verb in the app carries an integer indicating how common it is,
displayed to the user as a rank and used as the default sort order of the verb list, so that
a beginner meets sein and haben before verdrießen. The current ranking came from a frequency
list that stopped at 990 verbs. I am now expanding the corpus toward
roughly 7,000 verbs using Wiktionary, and that expansion needs a frequency source I can
extend and cite.

Concretely, I would like to issue one request per verb lemma to
https://www.dwds.de/api/frequency/ and store the resulting hit count, then compute an ordinal
rank across the corpus from those counts. The volume is approximately 990 requests today and
no more than about 7,000 in total, sent once per batch of verbs added rather than repeatedly,
at a deliberately modest rate. The app itself would make no requests to DWDS at any time: the
ranking is computed once during development and compiled into the app, so your servers would
see no traffic from users.

I should mention that I have already fetched the 990 lemmas currently in the app, to evaluate
whether DWDS ordering differed meaningfully from what the app ships. It does, which is why I
am writing. That snapshot is excluded from the public repository, and I will delete it if you
prefer.

What would be published. I would ship only the derived ordinal rank, an integer from 1 to n,
per verb. No hit counts, no corpus text, no citations, and no other DWDS content would appear
in the app. Because the app's data files live in a public GitHub repository, those ranks
would be publicly visible there. I want to be explicit about that, since it constitutes
redistribution of data derived from DWDS, and I would rather raise it than have you discover
it. If shipping only the ranks and not the underlying counts makes a difference to your
answer, I am happy to commit to that in writing. If publishing the derived ranks at all is a
problem, please say so, and I will look elsewhere.

Attribution. The app contains a Credits screen that names its sources, and I would add DWDS
there and in the repository README. My proposed wording is:

"Verb frequency ranking derived from the DWDS corpus. DWDS: Digitales Wörterbuch der
deutschen Sprache, herausgegeben von der Berlin-Brandenburgischen Akademie der
Wissenschaften, https://www.dwds.de/"

I would gladly use whatever form you prefer instead.

Alternatives, in case the answer is no. I recognize that a free app is still not a research
organization under § 60d, and that your reservation under § 44b is deliberate. If permission
is not something you can grant, a plain no is genuinely useful to me, and I will build the
ranking from an openly licensed corpus instead. I would rather ask first than assume that
attribution substitutes for permission.

Thank you for your time, and for maintaining a resource that makes work like this possible at
all.

Mit freundlichen Grüßen,

Josh Adams
vermontcoder@gmail.com

---

## Deutsche Fassung

Translation of the body above, for sending instead of (not alongside) the English. It follows
the English paragraph for paragraph, with three deliberate departures noted after the text.
Like the English body, it contains no Markdown.

---


An: dwds@bbaw.de
Betreff: Bitte um Genehmigung: Nutzung der DWDS-Frequenzdaten für eine kostenlose Lern-App (Konjugieren)

Sehr geehrte Damen und Herren,

hiermit bitte ich Sie nach Maßgabe Ihrer Nutzungsbedingungen um die Genehmigung, die DWDS-Frequenz-API als Quelle für eine Häufigkeitsrangfolge von Verben in einer kostenlosen iOS-App zu nutzen.

Zur App. Konjugieren ist eine Nachschlage- und Übungs-App zur deutschen Verbkonjugation für Deutschlernende. Sie konjugiert 990 Verben in fünfzehn Conjugationgroups, fragt den Nutzer dazu ab und stellt jedem Verb eine Etymologie sowie einen literarischen Beispielsatz zur Seite. Sie ist kostenlos, enthält keine Werbung und bietet weder In-App-Käufe noch Abonnements. Ich bin ein unabhängiger Einzelentwickler, kein Unternehmen, und die App wird in keiner Form monetarisiert. Ihr Quellcode und ihre Datendateien sind öffentlich. Der App-Store-Eintrag findet sich unter

  https://apps.apple.com/us/app/konjugieren/id6758258747

und der Quellcode unter

  https://github.com/vermont42/Konjugieren

Ich habe sie als Hommage an meinen Großvater geschrieben, der in Minster, Ohio, geboren wurde, einer Stadt, in der Deutsch bis zum Ersten Weltkrieg die Sprache des Alltags war.

Eine Anmerkung zu einem Wort weiter oben. Ich verwende „conjugationgroup“, weil ich keinen etablierten englischen Terminus für den Begriff finden konnte und mir eine Neuprägung angemessener erschien, als einen vorhandenen Terminus zweckzuentfremden. Eine Conjugationgroup ist die vollständige Menge der Formen, die ein Verb für eine bestimmte Kombination aus Tempus, Modus und Genus verbi annimmt; Präsens Indikativ ist demnach eine Conjugationgroup, Präsens Konjunktiv I eine andere. Englischsprachige Lehrmaterialien nennen diese Mengen gewöhnlich „tenses“, was schlicht falsch ist: Die beiden genannten Beispiele teilen dasselbe Tempus und unterscheiden sich allein im Modus. Die deutsche Lokalisierung übernimmt die Prägung unverändert als die Conjugationgroup, Plural die Conjugationgroups: feminin in Analogie zu die Gruppe, aber mit dem -s-Plural, den das Deutsche einem nicht assimilierten Anglizismus zuzugestehen pflegt. Sollte doch ein etablierter Terminus existieren und ich ihn schlicht übersehen haben, wäre ich für einen Hinweis dankbar.

Was ich vorhabe. Jedes Verb in der App trägt eine ganze Zahl, die angibt, wie häufig es ist. Sie wird dem Nutzer als Rang angezeigt und bestimmt die voreingestellte Sortierung der Verbliste, damit Anfänger zuerst auf sein und haben stoßen und erst viel später auf verdrießen. Die derzeitige Rangfolge stammt aus einer Häufigkeitsliste, die bei 990 Verben endete. Ich erweitere den Bestand derzeit mithilfe des Wiktionary auf etwa 7.000 Verben, und diese Erweiterung braucht eine Häufigkeitsquelle, die ich fortschreiben und zitieren kann.

Konkret möchte ich pro Verblemma eine Anfrage an https://www.dwds.de/api/frequency/ richten, die zurückgelieferte Trefferzahl speichern und daraus eine Rangfolge über den gesamten Bestand berechnen. Der Umfang beträgt heute etwa 990 Anfragen und insgesamt höchstens rund 7.000. Sie werden einmalig je hinzugefügtem Verbpaket gestellt, nicht wiederholt, und mit bewusst zurückhaltender Taktung. Die App selbst würde zu keinem Zeitpunkt Anfragen an das DWDS stellen: Die Rangfolge wird einmalig während der Entwicklung berechnet und fest in die App eingebaut. Ihre Server bekämen also keinerlei Datenverkehr durch Nutzer.

Ich sollte erwähnen, dass ich die 990 derzeit in der App enthaltenen Lemmata bereits abgerufen habe, um zu prüfen, ob sich eine DWDS-Rangfolge nennenswert von der ausgelieferten unterscheidet. Das tut sie, und genau deshalb schreibe ich Ihnen. Dieser Datenbestand ist vom öffentlichen Repository ausgenommen, und ich lösche ihn, wenn Ihnen das lieber ist.

Was veröffentlicht würde. Ausgeliefert würde je Verb allein die abgeleitete Rangzahl, eine ganze Zahl von 1 bis n. Weder Trefferzahlen noch Korpustexte, Belege oder sonstige DWDS-Inhalte würden in der App erscheinen. Da die Datendateien der App in einem öffentlichen GitHub-Repository liegen, wären diese Rangzahlen dort öffentlich einsehbar. Ich möchte das ausdrücklich ansprechen, denn es stellt eine Weitergabe von aus DWDS-Daten abgeleitetem Material dar, und ich lege es Ihnen lieber selbst offen, als dass Sie es entdecken. Falls es für Ihre Antwort einen Unterschied macht, nur die Rangzahlen und nicht die zugrunde liegenden Trefferzahlen auszuliefern, sage ich das gerne schriftlich zu. Sollte bereits die Veröffentlichung der abgeleiteten Rangzahlen problematisch sein, sagen Sie es mir bitte; dann sehe ich mich anderweitig um.

Quellenangabe. Die App enthält eine Danksagungsseite, die ihre Quellen nennt. Dort und in der README des Repositorys würde ich das DWDS ergänzen. Mein Formulierungsvorschlag lautet:

„Häufigkeitsrangfolge der Verben, abgeleitet aus dem DWDS-Korpus. DWDS: Digitales Wörterbuch der deutschen Sprache, herausgegeben von der Berlin-Brandenburgischen Akademie der Wissenschaften, https://www.dwds.de/“

Selbstverständlich verwende ich stattdessen gerne die von Ihnen bevorzugte Form.

Alternativen, falls die Antwort Nein lautet. Mir ist bewusst, dass eine kostenlose App gleichwohl keine Forschungsorganisation im Sinne des § 60d UrhG ist und dass Ihr Nutzungsvorbehalt nach § 44b UrhG bewusst gesetzt ist. Falls Sie die Genehmigung nicht erteilen können, ist mir auch ein schlichtes Nein von Nutzen; ich werde die Rangfolge dann aus einem frei lizenzierten Korpus aufbauen. Ich frage lieber vorher, als anzunehmen, eine Quellenangabe ersetze die Genehmigung.

Ich danke Ihnen für Ihre Zeit und dafür, dass Sie eine Ressource pflegen, die Arbeiten wie diese überhaupt erst möglich macht.

Mit freundlichen Grüßen

Josh Adams
vermontcoder@gmail.com


---

### Three departures from the English

1. **Salutation and closing follow German business convention, not the English original.**
   "Dear DWDS Team" becomes "Sehr geehrte Damen und Herren", the standard formal opening when
   the recipient is an institution rather than a named person; "Liebes DWDS-Team" would be too
   familiar for a permission request. Per German convention the body then begins lowercase
   ("hiermit bitte ich Sie"), and "Mit freundlichen Grüßen" drops the comma the English
   version carries.
2. **Quoted terms take German quotation marks,** „conjugationgroup“ and „tenses“, rather than
   the English pair.
3. **"Voice" is rendered as Genus verbi,** the ordinary German grammatical term, rather than a
   calque. Tempus and Modus carry over directly, so the triple reads as the standard German
   set it is.

A fourth difference: **the German version proposes the German credit wording, not the
English.** The earlier reasoning, that an identical attribution line in both versions
guarantees the same credit, was wrong for a bilingual app. Konjugieren ships German and
English localizations, so its Credits screen carries both, and the German email should
propose the German one. Both versions mark the proposed wording with quotation marks rather
than indentation, since a leading-space indent only marks the first physical line and so
degrades into a stray-looking space once a mail client rewraps the block. The two URL lines
keep their indentation, which survives because each fits on one line.
