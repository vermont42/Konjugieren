# Browse and Verb Screens: Findings and Ideas

Research and ideation in response to
[`plans/browse-and-verb-ideation.md`](../plans/browse-and-verb-ideation.md), written on 2026-11-10.
Nothing in the app was changed. The subject is Konjugieren's verb list, its verb page, and the
ways into them from outside the app, with notes on how each idea would carry over to Conjuguer and
Conjugar. It is the companion to [`docs/pedagogy.md`](pedagogy.md), which covers the quiz. It was
revised the same day, after Josh said that no release of any of the three apps is possible before
2027.

Six inputs went into this document:

1. **The code.** `VerbBrowseView.swift`, `VerbView.swift`, `FamilyBrowseView.swift`,
   `FamilyDetailView.swift`, the App Intents, the widget, `World.swift`, `Analytics.swift`,
   `QuizErrorHistory.swift`, and the `CorpusFormsDumpTests` harness, read directly.
2. **The running app.** A build of the current `main` was launched in the iPhone 17 simulator.
   Searches were typed, four verb pages and one family page were opened and measured, the widget's
   stored snapshot was read, and Spotlight was tried from the Home Screen.
3. **The corpus.** `Verbs.xml` and the conjugation-to-infinitive map in
   `corpus/working/forms.json` (generated on 2026-07-25), analyzed with short scripts. The app's
   search rule was replayed over the corpus to find what it returns for a given query.
4. **Usage data.** [`docs/telemetry-usage.md`](telemetry-usage.md), for the 57 real devices.
5. **A survey.** Three research passes over other conjugation tools, dictionary and reading apps,
   Apple's platform documentation, and the literature on dictionary use.
6. **The sibling apps.** A read-only pass over the Conjuguer and Conjugar repositories.

## How to Read This Document

Claims carry the same labels as in `docs/pedagogy.md`.

| Label | Meaning |
|---|---|
| **observed** | Seen in this repository's code or data, in the simulator, or in `telemetry-usage.md`. For another product, a researcher loaded the page during this project. |
| **read** | A researcher read the primary source, a product's own listing, or Apple's documentation during this project. |
| **secondhand** | Known only from a search summary, a review, or another secondary source. Verify before relying on it. |
| **vendor** | A company's report about its own product. |
| **inference** | Reasoning from the above. Mine unless stated. |
| **background** | General knowledge that was not verified during this project. |

Three warnings apply throughout. Pages of other products were fetched through a tool that returns
a text summary, so what a page says is reliable and how it looks (bold, color, highlighting) is
not. Most of the literature is at secondhand strength. And no learner was watched or interviewed,
so every statement about what people want is an inference from code, numbers, and other tools.

Effort is a rough guess: S for hours to a day, M for several days, L for weeks.

On terminology: "conjugationgroup" and "conjugation" are used as
[`docs/terminology.md`](terminology.md) directs. The word "tense" appears only where a sibling app
or a cited source uses it.

## Short Answers

**Do the screens work?** For someone who types a German infinitive correctly, yes. The search
field is on the landing screen, results narrow with each letter, and the most frequent verb comes
first. For nearly every other way of asking, search returns nothing, or returns the wrong verbs
with no sign that they are wrong. A conjugation (ging, gefunden, kam, muss) finds nothing. An
infinitive typed without its umlaut (konnen, koennen) finds nothing. An English word (go) finds
nothing unless a setting has been changed. Typing war lists 17 verbs, led by erwarten and warten,
and sein is not among them. Each empty result plays a sad trombone.

The verb page is complete and slow to answer. It runs to nearly five screens. The Perfekt
Indikativ begins almost two screens down, the etymology and the example sentence sit at the very
bottom, a separable verb is shown as ich aufstehe, and nothing on the page leads anywhere else.

**What should come first?** Five things, in this order.

1. **Make search find what people type.** Fold umlauts and digraphs, search English glosses by
   default, put the exact match first, and replace the trombone with help. Each is small, and the
   sibling apps already do some of them.
2. **Record the lookup path**: whether a search ended in a verb, how a verb page was reached,
   and how far down it was read. Build the same signals into Conjuguer and Conjugar, so that
   each app's next release carries them. Their traffic is ten times Konjugieren's and will speak
   soonest once they ship.
3. **Put the answer at the top of the verb page.** A line of principal parts (aufstehen, steht
   auf, stand auf, ist aufgestanden), conjugations of separable verbs written as a main clause
   writes them, and sections ordered by use.
4. **Reverse lookup from a conjugation.** The corpus supports it today. The map holds 50,013
   conjugations, compresses to 164 KB, and has only 179 entries that truly belong to two verbs.
5. **Keep what people look up.** A recents list and a "My Verbs" list, built on this track and
   read by the quiz, with "test me on this verb" on the verb page.

**What does the wait for a release change?** Josh cannot cut a release of Konjugieren,
Conjuguer, or Conjugar before 2027, as `CLAUDE.md` records. Nothing here can reach a learner, and
nothing can be measured, until then. Four things follow.

- **The order above is an order of building.** The five items need no evidence beyond what this
  document holds, since the failures in item 1 are demonstrable by typing, and all five can be
  ready for one release.
- **The signals ship with the fixes, not ahead of them.** They will show how the corrected
  screens are used. They cannot show a before and an after for search, because no search signal
  exists today.
- **The larger bets wait for a second release.** A sentence mode, collections, and a browse view
  by base verb rest on guesses about how people reach a verb. They should wait for what the
  first release measures. Until then the only new evidence to be had is from watching people,
  which needs no release. See [Trying Ideas on Real People First](#trying-ideas-on-real-people-first).
- **The wait is a baseline.** None of the three apps will change, so the signals that exist
  today will describe a fixed product. A refresh of the usage snapshot just before the release
  is the figure to compare against.

**One caution, repeated from the quiz report.** None of this changes how many people find the app.
Konjugieren's constraint is discovery: about 157 App Store impressions and 6.5 first-time
downloads a month. Two ideas touch discovery at the edges and are marked where they appear:
reverse lookup is a claim a store screenshot can make, and sharing a verb is a small referral
channel.

**One finding outside the brief.** Checking the screens turned up conjugations that are wrong in
the shipping app. The page for aufstehen reads ich habe aufgestanden, bedürfen shows ich darf,
and vermögen shows ich mag. A reference that answers "haben or sein?" wrongly for a common verb
costs more trust than any feature here can earn back. See
[Defects Found Along the Way](#defects-found-along-the-way). **Fixed on `main` 2026-11-10**:
[`plans/fix-reference-defects.md`](../plans/fix-reference-defects.md) corrected these and the
larger class behind them, and is finished. The corrections ship with the next release.

## What the Screens Do Today

All **observed**, from the code and the iPhone 17 simulator unless noted.

### The Verb List

| Aspect | Behavior |
|---|---|
| Landing | The Verbs tab is the app's first screen. A large title, the search field directly under it, a count ("3,572 verbs"), and seven rows fit on the first screen. |
| Row | Infinitive, the English gloss of the first reading, the family (Strong, Mixed, Weak, -ieren), and the frequency rank. |
| Order | Frequency by default, or alphabetical, chosen with a control at the bottom. The choice is not remembered between launches. |
| Search rule | A case-insensitive substring match on the infinitive, with ß and ss treated alike. If the Search Scope setting is changed from its default, the gloss of the first reading is searched too. |
| Search default | Infinitives only. |
| Result order | The current sort order. An exact match gets no priority. |
| Empty result | "No verbs found", a magnifying glass, and a randomly chosen sad trombone. Nothing else. |
| Field behavior | The first letter is capitalized as typed (Ging). Autocorrection is not switched off in the code. |
| iPad | A grid of the same cells (code only; not run). |
| Signals | `viewVerbBrowseView` when the screen appears. Nothing about searches. |

### The Verb Page

Measured on aufstehen. The page is about 4,230 points tall on a screen 874 points tall.

| Distance from top | Section |
|---:|---|
| 130 | Infinitive, gloss, and pills: family, auxiliary, frequency rank, separable or inseparable, ablaut group |
| 340 | Perfektpartizip |
| 440 | Präsenspartizip |
| 540 | Präsens Indikativ |
| 760 | Präteritum Indikativ |
| 980 | Präsens Konjunktiv I |
| 1,200 | Präteritum Konjunktiv II |
| 1,420 | Imperativ |
| 1,590 | Perfekt Indikativ |
| 1,810 | Perfekt Konjunktiv I |
| 2,030 | Plusquamperfekt Indikativ |
| 2,250 | Plusquamperfekt Konjunktiv II |
| 2,470 | Futur Indikativ |
| 2,690 | Futur Konjunktiv I |
| 2,910 | Futur Konjunktiv II |
| 3,160 | Etymology |
| 3,920 | Example sentence |

Other facts about the page:

- Tapping a conjugation speaks it. Irregular letters are red, and nothing on the page says what
  red means.
- A verb with two readings has a picker, and every table follows the chosen reading.
- The pills are labels. The ablaut-group pill speaks its name when tapped. None of them, and
  nothing else on the page, leads to another screen.
- Separable verbs are shown joined in every finite conjugationgroup except the Imperativ:
  ich aufstehe, du aufstehst.
- The headings use the project's names. A textbook's "Partizip II" is Perfektpartizip here, and
  the würde construction is Futur Konjunktiv II (**background** for the textbook usage). Each of
  the 14 conjugationgroups has an article under Info, and the headings do not link to them.
- The page has no Futur II and no passive.
- There is no way to save a verb, copy a conjugation, or share the page.
- The page declares a Handoff activity and sends `viewVerbView` when it appears.

### Families

The Families tab lists the families, and a family's page shows its article followed by its verbs.
For Strong, the article says that German has about 170 strong verbs, and the list below it holds
all 1,532 strong entries in alphabetical order, beginning abbehalten, abbeißen, abbekommen.
Abbehalten is the second-rarest verb in the corpus. The list has no search and no frequency
order, so finding sein, gehen, or kommen in it means scrolling past several hundred derivatives.

### Surfaces Outside the App

| Surface | What it does today | What it does not do |
|---|---|---|
| Spotlight | All 3,572 verbs are indexed at each launch. Typing aufstehen on the Home Screen showed a Konjugieren result (simulator). | Typing aufgestanden or "get up" showed none. The top web result for aufgestanden was Wiktionary. |
| App Shortcuts | "Conjugate a Verb" answers with one conjugationgroup as text. "Open Verb" opens a verb page. "Start Quiz" and "Random Verb" do as named. | The spoken phrases exist only in English. The verb picker returns the first 25 substring matches in alphabetical order, so for 7 of the 50 most frequent verbs (kommen, machen, stehen, stellen, halten, setzen, ziehen) the verb is missing from the results for its own name. |
| Verb des Tages widget | Shows a daily verb in five sizes. A tap opens that verb. | The verb is chosen by stepping 127 places a day through the alphabetical list. See the table below. |
| Quiz widget | A daily multiple-choice question on the same verb. | Draws from the same sampling. Three of the next ten questions are Futur Indikativ. |
| Control Center | "Random Verb" and "Quick Quiz". | Random means uniform over the corpus: a 2.8% chance of one of the 100 most frequent verbs. |
| Deeplinks | `verb/<infinitive>`, `verb/random`, `quiz`, `family/<name>`, `info/<index>`. | No route opens search. |
| Handoff | Continues a verb page on another device. | |

No outside surface accepts a conjugation, and none opens the search field, which is what people
come to the app to use.

The widget's next ten verbs, read from the snapshot the app wrote on 2026-11-10:

| Day | Verb | Frequency rank |
|---:|---|---:|
| 1 | aufblasen | 2,160 |
| 2 | ausatmen | 2,358 |
| 3 | aussprechen | 496 |
| 4 | beisteuern | 1,382 |
| 5 | betätigen | 1,273 |
| 6 | dokumentieren | 649 |
| 7 | einherfahren | 3,527 |
| 8 | entfernen | 217 |
| 9 | erkaufen | 1,906 |
| 10 | festdrücken | 2,865 |

The sequence walks through the alphabet about once every 28 days. No verb in this stretch is
among the 200 most frequent.

### What the Usage Data Say About Lookups

All **observed** in `telemetry-usage.md` unless marked.

- Verb browsing and the verb page dominate every app's signals. A real Konjugieren session
  averages about 1.6 views of the verb list and 1.1 views of a verb page, and the median session
  lasts 19 seconds.
- **About a third of real devices have never opened a verb page.** On versions 1.1 and later, 67
  devices sent `viewVerbBrowseView` and 47 sent `viewVerbView`. Seventeen of those devices are the
  automated UTC+8 visitors, and 14 to 17 of them opened a verb. That leaves 50 real devices that
  saw the verb list, of which 30 to 33 ever opened a verb and 17 to 20 never did (**inference**
  from the snapshot's counts). They may have installed the app, glanced, and left. Or their first
  search may have failed. The signals cannot tell these apart, which is the strongest argument
  for recording search outcomes.
- An average of 1.1 verb pages per session is a mean, and one long session lifts it. It does not
  show that a typical session ends in a verb (**inference**).
- Nothing records what was searched, how a verb was reached, or what was read on its page.

## Where a Lookup Fails

### Step by Step

| Step | What has to go right | Where it goes wrong today |
|---|---|---|
| 1. Reach the app | Launch lands on the list with the search field showing. | From outside, Spotlight finds infinitives only, and no shortcut, control, or widget opens search. |
| 2. Say what is wanted | The learner types something the search understands. | Only a correctly spelled German infinitive works by default. Conjugations, missing umlauts, English, and verbs outside the corpus all end in "No verbs found". |
| 3. Pick the right row | The wanted verb is visible near the top. | The exact match is not ranked first. Typing essen puts essen sixth, and in alphabetical order kommen is 46th of 75. |
| 4. Find the conjugation | The learner scrolls to the right section. | The page is nearly five screens long, ordered by morphology and not by use. The Perfekt Indikativ is almost two screens down. Headings use names a textbook may not. Futur II and the passive are absent. |
| 5. Trust and use it | The conjugation is what a writer needs. | Separable verbs are shown joined. Red letters are unexplained. (Some verbs showed the wrong auxiliary and three showed wrong conjugations; fixed on `main` 2026-11-10 by the defect plan.) |
| 6. Leave, or stay | The visit ends, or leads somewhere. | Nothing on the page leads on, and nothing remembers the lookup. |

### What Search Returns

The app's matching rule was replayed over the corpus. Queries marked † were also typed into the
simulator, with the same result.

| Typed | Wanted | Default result | With glosses searched |
|---|---|---|---|
| ging † | gehen | No verbs found | zuerkennen, zersingen, zugraben |
| gefunden | finden | No verbs found | No verbs found |
| war † | sein | 17 verbs led by erwarten, warten, warnen. Sein is absent. | 56 verbs, led by the same |
| ist | sein | 16 verbs led by leisten | 65 verbs led by bestehen |
| kam, wurde, geht, muss, will, darf | kommen and so on | No verbs found | No verbs found |
| stand auf | aufstehen | No verbs found | No verbs found |
| weiß | wissen | weißen | weißen |
| konnen †, koennen | können | No verbs found | No verbs found |
| go † | gehen | No verbs found | 71 verbs, gehen first |
| to go | gehen | No verbs found | heimtrauen |
| eat | essen | beatmen | 66 verbs. Essen is fourth, after schlagen, erstellen, and drohen. |
| essen † | essen | 59 verbs. Essen is sixth, after schließen, genießen, beschließen, vergessen, and abschließen. | The same |
| kommen, alphabetical order | kommen | 75 verbs. Kommen is 46th. | The same |

Three mechanisms explain the table. The match is a substring, so eat matches the glosses beat,
create, and threaten, and war matches erwarten. The ß and ss rule that rescues schliessen also
makes schließen a match for essen. And results keep the list's order, so a frequent derivative
outranks the verb that was typed.

Some counts behind the failures:

- 545 of the 3,572 infinitives (15%) contain an umlaut, including 14 of the 100 most frequent:
  können, müssen, dürfen, mögen, führen, gehören, erklären, unterstützen, übernehmen, öffnen,
  erzählen, fühlen, wählen, hören.
- In alphabetical order, 72 of the 100 most frequent verbs are not the first result for their own
  infinitive. In frequency order the problem is rarer and still real: 176 of the 3,572 verbs are
  displaced, among them essen, and hören, which appears behind gehören.
- 44 verbs have a second reading (120 after the defect plan's Part 6). Its gloss is never searched, so "travel" does not find fahren
  and "migrate" does not find ziehen. **Fixed on `main` 2026-11-10** by Part 3b of the defect
  plan: both the verb list and the shortcut picker now match every reading's gloss.
- Everyday verbs are missing from the corpus: googeln, downloaden, chatten, einloggen, scrollen,
  joggen, recyceln, abspeichern, hinaufkommen, weiterschlafen.

### Four Kinds of Visit

All **inference**.

- **Reading.** A learner meets ging, stand ... auf, or gewesen in a text and wants the verb. This
  is the visit the app serves worst: every such search fails. The learner most likely turns to a
  web search, where the simulator's top result for aufgestanden was Wiktionary.
- **Writing.** A learner knows the meaning, or the infinitive, and needs one conjugation. Search
  by English fails by default. On the verb page, the Perfekt and its auxiliary are far down, and
  a separable verb is shown in the shape that a main clause does not use.
- **Homework.** A worksheet names a verb and a conjugationgroup, often several in a row. The
  infinitive search works. The names on the page may not match the worksheet's, a Futur II or a
  passive is not there to find, and each new verb means going back and searching again.
- **Checking.** A learner half-knows a conjugation and wants to confirm it: hat or ist, sang or
  sung. Spotlight's own suggestion for aufstehen in the simulator was "aufstehen perfekt". The
  answer exists on the page and takes scrolling to reach.

## What Other Tools Do

From pages loaded or read on 2026-11-10. Several products could not be reached, and they are
listed under [Limits of the Research](#limits-of-the-research).

| Tool | Reverse lookup from a conjugation | How the match is presented |
|---|---|---|
| verbformen.de | Yes. ging opens gehen, and gefunden opens finden (**observed**). | Silently. Nothing says why the page appeared. "fängt an" opened fangen, with anfangen only among the derived verbs. |
| Reverso Conjugation | Yes, including "fängt an", which opened anfangen (**observed**). | Silently. A misspelling opened the nearest verb, labeled "Approximate result". |
| DWDS | Yes (**observed**). | A banner says that gehen was judged the best match for ging. A misspelling gets a "Meinten Sie vielleicht" list. |
| Duden | Partly (**observed**). | A results list whose first line is "ging: siehe gehen", followed by nine pages of loose matches. |
| Wiktionary | Yes (**observed**). | Explicitly: "first/third-person singular preterite of gehen". "fängt an" has its own entry. |
| SpanishDict | Yes (**observed**). | For fue, a list of two results, ser and ir, each labeled with its conjugation. |
| WordReference | Yes (**observed**). | Opens ser with a note that fue is also a conjugation of ir. |
| Ella Verbs | Yes: "search by Spanish, English, or conjugated form" (**read**). | Not established. |
| VerbForms Deutsch (iOS) | Yes: "infinitives, verb forms or translations" (**read**). | Not established. Offline use is not stated. |

Patterns:

- **Reverse lookup is ordinary on the web and the explanation is rare.** Most tools open the
  infinitive's table without saying which conjugation was matched. Wiktionary, DWDS, and
  SpanishDict are the ones that say.
- **Separable verbs separate the careful tools from the rest.** A leading German conjugation site
  sent "fängt an" to the wrong verb without a sign.
- **Offline and conjugation search are seldom offered together** among German apps on iOS. One
  listing claims conjugation search without stating offline use, another sells offline use as a
  purchase, and a third claims offline use without conjugation search (**inference** from store
  listings).
- **Saving is standard, and feeding practice is rarer.** Favorites, lists, and history appear in
  most reference apps (**read**: Merriam-Webster, the Netzverb app, VerbForms Deutsch). Ella
  Verbs's "My Verbs" list feeds its quizzes (**read**), and reading tools such as Kindle,
  Readlang, and LingQ save every lookup without being asked (**secondhand**).
- **Return-visit features belong to practice apps.** No German reference tool that was loaded
  advertised a verb of the day or a widget. The one claim that widgets help retention is
  Duolingo's, about a streak widget, with no figure given (**vendor**).

Platform facts that bound the ideas:

- An indexed App Entity's attribute set has fields for alternate names and keywords, which is the
  documented route to making a conjugation lead to a verb in Spotlight (**read**). Developers
  report that keywords are matched less reliably than titles (**secondhand**), so it needs a test
  on a device. Apple's guide says to index into a named index, and calls the default index, which
  Konjugieren uses, suitable for prototyping (**read**).
- A widget can hold buttons and toggles and no text field (**read**), so a lookup cannot be typed
  into one.
- The system's Look Up panel shows Apple's dictionaries. No public way to add one was found
  (**read** for the panel's rule, **background** for the absence).
- `DataScannerViewController` reads printed text through the camera on iOS 16 and later
  (**read**).

## What the Research Says

| # | Finding | Source | Strength |
|---:|---|---|---|
| 1 | Failed dictionary searches are mostly problems of spelling and inflection, not missing entries. In 500 failed searches in Norwegian online dictionaries: spelling 46%, missing entries 15%, wrong language or variety 12%, compounds and spacing 11%. | Nygaard & Fjeld 2008 | **read** |
| 2 | The same dictionary redirected about 1.1 million searches for inflected words to their headwords. | Nygaard & Fjeld 2008 | **read** |
| 3 | In an online Swahili-English dictionary, 53.1% of Swahili searches found an entry. A module that decomposed unfound words by morphology raised the hit rate by a further 4%. | De Schryver et al. 2006 | **read** |
| 4 | Whether people look up frequent words is disputed. One study found a correlation of at most 0.3 between corpus rank and lookup rank, and only among the first few thousand words. A later study of German dictionaries reports a clear link. | De Schryver et al. 2006; Koplenig, Meyer & Müller-Spitzer 2014 | **read**; **read** as abstract |
| 5 | Looking a word up does not, in itself, make it stick. In a meta-analysis of 42 studies, the part of a task that involved evaluating a word contributed most to retention and the part that involved searching for it contributed nothing. | Yanagisawa & Webb 2021 | **secondhand** |
| 6 | Learners retain looked-up words better when the task makes the word matter, and not merely when a test is announced. | Peters 2007 | **secondhand** |
| 7 | No study of a quiz placed directly after a lookup was found. The nearest experiment found retrieval during reading no better than a rich context, and equal to it once feedback was added. | van den Broek et al. 2022 | **read** as abstract |
| 8 | Evidence that etymology aids memory concerns idioms. Nothing was found on etymology and irregular verbs. | Boers, Eyckmans & Stengers 2007 | **secondhand** |
| 9 | No evidence was found, from researchers or vendors, that a word of the day, a history list, or favorites brings people back to a reference app. | | Absence of evidence |

What these support (**inference**): accepting conjugations and near-misses in search is the
change with the firmest basis, because it addresses the commonest kinds of failed search
(findings 1 to 3). Frequency order is right for the head of the list and says little about the
tail (finding 4). A lookup is a weak learning event, so any hope that lookups teach depends on
adding a moment of evaluation or retrieval (findings 5 to 7). And every return-visit idea below
is a reasoned bet, not an application of evidence (finding 9).

## Ideas

Each idea gives its basis, its effort, the signal that would show whether it worked, and how it
carries over to Conjuguer and Conjugar. Signal names refer to
[What to Measure](#what-to-measure). The groups are in rough order of priority, as are the ideas
within each group. An overall ranking follows the groups.

Two facts about the siblings recur (**observed** in their code). Neither keeps any record of which
verbs a user viewed, and neither has App Shortcuts, App Entities, or Spotlight indexing. Both
have a widget of the day, Control Center controls, and deeplinks. Both fold diacritics in search
already. Conjugar searches the English gloss by default and Conjuguer searches the infinitive
only. Both play a sad trombone on an empty search.

Every idea here works offline. That is worth keeping, and it matters most for Conjuguer, whose
users in West and Central Africa are the likeliest to be reading on costly or unreliable
connections (**inference**).

### Group A: Let Search Find What People Type

#### A1. Fold Umlauts and Digraphs

Treat ä, ae, and a as the same letter when matching, and likewise ö, ü, and ß, so that konnen,
koennen, and können all find können. The rule that already equates ß with ss shows the way.

- **Basis.** The failure is observed, and it affects 15% of infinitives, including four modal
  verbs. Spelling is the largest class of failed search in the one study that counted (finding
  1). Nineteen of the 57 real devices are American, and more are set to languages without umlaut
  keys. Both siblings already fold diacritics.
- **Effort.** S.
- **Signal.** The share of searches that end with no result, and the share matched only after
  folding.
- **Conjuguer and Conjugar.** Already done in both.

#### A2. Search English Glosses by Default, in Every Reading, Whole Words First

Search the gloss without asking the learner to find a setting. Search the glosses of all
readings. Rank a whole-word match (eat) above a match inside a word (beat, create), and ignore a
leading "to". Either flip the setting's default, or retire the setting and show German matches
first and English matches after them.

- **Basis.** The default is observed, as is the result: go, have, know, and walk find nothing. A
  writer starts from a meaning. Conjugar already searches glosses by default. The reviews quoted
  on one German app's listing praise searching "in either German or English" (**read**, a single
  review).
- **Effort.** S.
- **Signal.** The share of searches matched by gloss, and the no-result share.
- **Conjuguer and Conjugar.** Conjugar has gloss search and could adopt the whole-word ranking.
  Conjuguer has none. Its 86 English-language devices would use it, and its francophone majority
  would not.

#### A3. Rank the Exact Match First

Order results as: the infinitive that equals the query, then infinitives that begin with it, then
the rest, each by frequency whatever the list's sort order.

- **Basis.** Observed. Essen is sixth for its own name, and 176 verbs are displaced in frequency
  order. In alphabetical order, 72 of the 100 most frequent verbs are displaced by their own
  derivatives.
- **Effort.** S.
- **Signal.** The position of the result that was opened.
- **Conjuguer and Conjugar.** Both use substring matching in the list's order (**observed**), so
  the same change probably applies, most visibly in alphabetical order (**inference**, not
  tested).

#### A4. A Useful Empty State

When nothing matches, say what search accepts, offer the nearest verbs by spelling, and retire
the trombone, which mocks the learner at the moment the app has failed. Add an "Ask for this
verb" link that opens a message to Josh with the query filled in.

- **Basis.** The empty state is observed. DWDS answers a misspelling with suggestions. The
  message link is the one way to learn what was typed with the learner's consent, since the
  privacy policy rules out recording it.
- **Effort.** S for the text, the link, and the trombone. M with spelling suggestions.
- **Signal.** The no-result share, taps on a suggestion, and the messages themselves.
- **Conjuguer and Conjugar.** The same change, trombone included.

#### A5. Reverse Lookup from a Conjugation

Let search find a verb from any of its conjugations. This is the first of the plan's ideas, and
its open questions now have answers.

*What the corpus supports.* The map written by `CorpusFormsDumpTests` on 2026-07-25 holds 50,013
single-word conjugations for all 3,572 verbs: the infinitive, the zu-infinitive, both participles,
the four simple conjugationgroups, the Imperativ, and the finite part that a separable verb leaves
behind in a main clause. Compound conjugationgroups need no entries, because their parts are
already there: hat gefunden resolves through gefunden.

*Size.* The map is 7.2 MB as indented JSON, 1.4 MB as a plain list of conjugations and their
infinitives, and 164 KB compressed. `Etymologies.json` is 7.4 MB. Building it on the device
instead would take roughly 107,000 calls to the conjugator. Conjuguer's version of the harness
reports about 1.25 million conjugations in 47 seconds (**observed** in its header), which suggests
a few seconds here (**inference**). A file generated at build time, with a test that fails when
it is stale, is the simpler choice.

*Ambiguity.* 45,633 of the 50,013 conjugations (91.2%) belong to one verb. The other 4,380 look
alarming and are mostly one phenomenon: halte is a conjugation of halten and also the stranded
part of 67 separable verbs built on it. Counting whole-word matches only, 179 conjugations are
shared, each by exactly two verbs, across 66 pairs of verbs.

| Typed | Belongs to |
|---|---|
| gehört | hören, gehören |
| gefallen | fallen, gefallen |
| gedacht | denken, gedenken |
| gestanden | stehen, gestehen |
| gelangt | gelangen, gelingen |
| führe | führen, and fahren in the Konjunktiv II |
| weiß | wissen, weißen |

*Presentation.* One row per verb, with a line that names the match, as Wiktionary and SpanishDict
do: "ging: Präteritum Indikativ, ich and er, of gehen". Opening the row lands on that section of
the verb page with the conjugation marked. The naming needs no stored data, because the app can
conjugate the candidate verb and see which cells equal the query. For a stranded part, show the
base verb first and then one folded row, "also the finite part of 67 separable verbs", ordered by
frequency when opened.

*Separable verbs.* A second word settles it: stand auf finds aufstehen, because auf is the
particle that one candidate needs. When the particle is half a sentence away, the learner cannot
know to type it, and idea A6 takes over.

*What the map lacks.* The map was tested against the app's own 3,572 German example sentences and
found each sentence's verb in 3,537 of them (99.0%). The 35 misses are the useful part, and
[the appendix](#appendix-what-the-map-misses) sorts them. Three kinds are cheap to add:

- **Older spellings.** The example sentences contain daß 305 times, muß 29 times, wußte 10
  times, and läßt 6 times. The map has muss and not muß. A reader of Kafka, whom the app quotes,
  meets these.
- **Participles with adjective endings**, such as geklebte and vorgeschlagenen.
- **Short imperatives**, such as halt beside halte.

The rest are second standard conjugations that the conjugator does not produce (wandte beside
wendete, schuf, hieb), which is corpus work the roadmap already describes.

- **Basis.** Reading is the visit the app serves worst. By the quiz report's reckoning, at least
  18 of the 57 real devices belong to people who live among German text. The best web tools do
  this, and the leading one gets separable verbs wrong. Findings 1 to 3 support it. The
  combination of offline use, conjugation search, and correct handling of separable verbs appears
  to be rare on iOS.
- **Effort.** M.
- **Signal.** The share of searches matched by conjugation, and the no-result share.
- **Discovery.** "Type any conjugation" is a claim a store screenshot and a keyword list can
  make. Whether it moves impressions is unknown.
- **Conjuguer and Conjugar.** Both repositories already contain the same harness, disabled,
  writing a map for the whole corpus, and Conjuguer's handles suis as être and suivre. Their maps
  will be larger (6,326 verbs at 99 conjugations each, and 4,811 at about 140), so measure the
  size first. Spanish shares more conjugations between verbs (fue), and accents distinguish
  conjugations (hablo, habló), so match with accents folded and show both. The value is highest
  for Conjugar, whose American learners read Spanish. For Conjuguer's francophone users, who know
  the infinitive already, it is lower.

#### A6. Paste a Sentence, Find Its Verbs

A second mode for search: paste or dictate a sentence, and the app shows it back with its verbs
marked and tappable. This answers the case that typing cannot, the separable verb whose particle
stands at the end of the clause.

Three facts from the example-sentence test shape it. German capitalizes nouns, and skipping
capitalized words inside a sentence removes most false matches: 8.7% of such words collide with a
conjugation, against 24.8% of lowercase words. The common collisions are a short list of function
words (sein as a possessive, schon, meine, gleich) that can be ranked down. And the pairing of a
finite verb with a particle at the end of its clause is already implemented in Python, in
`corpus/working/build_corpus_index.py`.

A camera mode through `DataScannerViewController`, and an entry in the share sheet, are later
steps on the same base.

- **Basis.** It is the only complete answer to split separable verbs. Pleco's free clipboard
  reader is the best-known model of the pattern (**secondhand**).
- **Effort.** M once A5 exists. The camera and the share sheet are M each.
- **Signal.** Sessions that use the mode, and verbs opened per such session.
- **Try first.** A single web page over `forms.json` would let a few learners try it on real
  text before any Swift is written.
- **Conjuguer and Conjugar.** No stranded particles, and no capitalized nouns to filter by.
  Attached pronouns (dámelo, l'ai) need handling instead. Highest value for Conjugar.

#### A7. Conjugate Verbs That Are Not in the Corpus

When an infinitive is unknown, try two things before giving up. If it is a known prefix on a
known verb (hinaufkommen, weiterschlafen, abspeichern), build its table from the base verb and
the prefix's rules. If it looks like an ordinary weak verb (googeln, chatten, joggen), build the
regular table. Label either as derived and unverified.

- **Basis.** Missing entries and compounds were 26% of failed searches in the Norwegian study
  (finding 1), and decomposition recovered searches in the Swahili one (finding 3). A competing
  German reference claims more than 23,000 verbs (**read**, store listing).
- **Risk.** The app's standard is that every shipped verb is verified. A derived table can be
  wrong about the auxiliary, and about prefixes that are separable in one sense and not in
  another (durch, über, um, unter). This is a decision for Josh.
- **Effort.** M.
- **Signal.** Views of derived tables. Their count per month is also a measure of what the corpus
  lacks.
- **Conjuguer and Conjugar.** Both assign each verb a model, so an unknown verb could be given
  the regular model for its ending, with the same label.

#### A8. Search-Field Hygiene

Turn off autocapitalization and autocorrection in the field, say in the placeholder what can be
typed, and offer the ä, ö, ü, and ß keys above the keyboard that the quiz report proposes for the
answer field.

- **Basis.** Capitalization is observed. Whether autocorrection alters German typed on an English
  keyboard was not tested, and it needs a check on a device.
- **Effort.** S.
- **Signal.** None of its own. It should show in the no-result share.
- **Conjuguer and Conjugar.** Worth the same check. Not verified.

#### A9. Ways to Browse Without Typing

Filters for the frequency bands and the families, a view that folds the 3,084 prefixed verbs
under their base verbs, and frequency order inside the Families lists.

- **Basis.** A simple parse of the corpus's prefix markers gives 609 base verbs. 3,343 of the
  3,572 verbs share a base with at least one other, and the largest groups are halten (80),
  kommen (74), gehen (70), and machen (66). Whether anyone finds verbs by scrolling is unknown.
- **Effort.** M.
- **Signal.** The share of verb pages reached by browsing. Wait for it before building.
- **Conjuguer and Conjugar.** Their Models tabs already group verbs by pattern.

### Group B: Make the Verb Page Answer in One Screen

#### B1. Principal Parts at the Top

Under the gloss, one line in the shape the Goethe-Institut's word list uses: aufstehen, steht
auf, stand auf, ist aufgestanden. Tapping a part jumps to its section.

- **Basis.** The line answers the questions of a checking visit (the Perfekt, the auxiliary, the
  Präteritum) without scrolling. Today the Perfekt Indikativ is almost two screens down. The quiz
  report argues that a strong verb is learned as these few facts.
- **Effort.** S to M.
- **Signal.** The share of verb views that end without scrolling, and time on the page.
- **Conjuguer and Conjugar.** Conjugar's page already opens with the participle, the gerund, and
  the future stem. Conjuguer's overview card shows the auxiliary and could add the participle and
  the traditional temps primitifs (**background**).

#### B2. Show Separable Verbs as a Main Clause Writes Them

Display ich stehe auf, and note the joined conjugation for subordinate clauses.

- **Basis.** The joined display is observed. Separable verbs are 61.4% of the corpus. The app's
  own article on the Präsens Indikativ teaches the split conjugation. The quiz report raises the
  same convention as its first decision, and the case is stronger here: a quiz that rejects
  halten hinunter marks an answer wrong, and a table that prints ich aufstehe teaches every
  writer who copies it.
- **Effort.** S to M. The conjugator already splits the Imperativ.
- **Signal.** None measurable. It is a matter of correctness.
- **Conjuguer and Conjugar.** No separable verbs. The nearest relative is the reflexive pronoun:
  Conjugar shows bare conjugations for its 114 reflexive-only verbs (**observed**).

#### B3. Order and Fold the Sections by Use, and Name Them Twice

Lead with the conjugationgroups a learner meets first (Präsens Indikativ, Perfekt Indikativ,
Präteritum Indikativ, Imperativ, then the würde and hätte constructions) and fold the rest under
"More", or add a row of jump links. Under each heading, give the name a textbook uses
("Perfektpartizip, also Partizip II") and link the heading to its Info article. Explain the red
letters once.

- **Basis.** The order and the missing links are observed. The quiz report's ladder of levels
  orders the conjugationgroups by use, from a curriculum and an acquisition study, and the same
  order serves a reader. Conjuguer hides its compound tenses behind a toggle and has a
  dismissible color key (**observed**).
- **Effort.** S to M.
- **Signal.** The deepest section reached, and Info articles opened from a verb page.
- **Conjuguer and Conjugar.** Conjugar shows 20 tenses in one list and would gain the most.

#### B4. Related Verbs

Give the page ways out: the base verb and its derivatives (stehen, aufstehen, verstehen,
bestehen), the other verbs of its ablaut group, and its family.

- **Basis.** The page is a dead end, observed. It is also the only screen seen by someone who
  arrives from Spotlight, a widget, or a shortcut. 94% of verbs have a relative in the corpus.
- **Effort.** S to M.
- **Signal.** Verb pages per session, and the share reached from another verb page.
- **Conjuguer and Conjugar.** Conjuguer's model row is tappable and Conjugar's is plain text.
  Making Conjugar's a link is S.

#### B5. Bring the Etymology and the Example Within Reach

A one-line teaser near the top that links to each. They are the app's most distinctive content,
present for every verb, and they sit 3,160 and 3,920 points down.

- **Basis.** No competing German tool that was surveyed offers both for every verb. Whether
  anyone scrolls to them is unknown, and the evidence that etymology aids memory does not reach
  verbs (finding 8).
- **Effort.** S to M. It needs a short version of each etymology.
- **Signal.** The deepest section reached. Measure before building.
- **Conjuguer and Conjugar.** The same, since both place them at the bottom.

#### B6. Copy and Share

A long press copies a conjugation. A share button sends the principal parts with a link.

- **Basis.** Visitors referred by another app download Konjugieren at 24.1%, against 5.4% for
  searchers. This is the only idea here that reaches people who do not have the app, and its
  effect will be small.
- **Effort.** S for copying and a text share with the App Store link. M for a link that opens the
  verb in the app, which needs universal links and a web domain (**background**).
- **Signal.** Taps on share, and the referrer rows in App Store Connect.
- **Conjuguer and Conjugar.** The same.

#### B7. The Sections the Page Lacks

Add Futur II, built from parts the conjugator already has. For the passive, which only some
verbs have, add a line that shows how it is built.

- **Basis.** Their absence is observed. That homework asks for them is an inference.
- **Effort.** S to M for Futur II.
- **Signal.** The deepest section reached.
- **Conjuguer and Conjugar.** Not applicable.

### Group C: Meet People Outside the App

#### C1. A Way to Open Search from Outside

Add a `search` deeplink that can carry text, an App Intent "Look Up a Verb" that takes a word and
answers "ging: Präteritum Indikativ of gehen" before opening the page, a Control Center control,
and a Home Screen quick action.

- **Basis.** Every outside surface today opens a random verb, a quiz, or a verb chosen from a
  picker. None opens the lookup.
- **Effort.** S, after A5 for the conjugation answer.
- **Signal.** The share of verb pages reached from each surface.
- **Conjuguer and Conjugar.** Their deeplinks and controls exist. App Shortcuts and entities do
  not, so Konjugieren's would be ported first, at M each.

#### C2. Spotlight That Finds Conjugations and Glosses

Add each verb's principal parts and gloss to its entry's keywords and alternate names, and move
to a named index.

- **Basis.** Observed in the simulator: aufstehen is found, and aufgestanden and "get up" are
  not. The fields and the advice about the index are in Apple's documentation.
- **Effort.** S to M, with a test on a device.
- **Signal.** The share of verb pages reached from Spotlight.
- **Conjuguer and Conjugar.** New work in both. Conjuguer's repository has a design note for it.

#### C3. Fix the Shortcut Picker and Add German Phrases

Rank the exact match first in the verb picker, and add German spoken phrases.

The first half is **done on `main` as of 2026-11-10**, by Part 3a of the defect plan: the picker
ranks the exact infinitive, then infinitives that begin with the text, then the rest, each by
frequency, before it keeps 25. The German phrases remain.

- **Basis.** Observed: seven of the 50 most frequent verbs cannot be found by their own names,
  and the phrases are English only, while 16 real devices run in German.
- **Effort.** S.
- **Signal.** The share of verb pages reached from a shortcut.
- **Conjuguer and Conjugar.** Follows C1.

#### C4. Keyboard Lookup on iPad and Mac

Command-F to focus search, Return to open the first result, arrow keys to move.

- **Basis.** The Swiss institution behind most of Conjuguer's downloads installed it on Macs.
- **Effort.** S.
- **Signal.** None specific.
- **Conjuguer and Conjugar.** Conjuguer first.

### Group D: Give People a Reason to Come Back

None of these has evidence behind it (finding 9). They are ordered by how little they cost and
how little they ask of the learner. None sends a notification.

#### D1. Recents

Keep the last 20 or so verbs opened, on the device only, and show them when the search field is
focused and empty.

- **Basis.** History is standard in reference apps. That learners look the same verb up
  repeatedly is plausible and was not established.
- **Effort.** S.
- **Signal.** The share of verb pages reached from recents.
- **Conjuguer and Conjugar.** A new store in each.

#### D2. My Verbs

A star on the verb page, and a list that holds starred verbs and recent lookups. The list is a
filter in the verb list and a scope in the quiz.

- **Basis.** This is the plan's third idea and the quiz report's "my verbs" scope. Peters's
  finding that relevance aids retention (finding 6) is the nearest support. Ella Verbs does this.
- **Effort.** S to M.
- **Signal.** Devices with a starred verb, and quizzes started on the list.
- **Conjuguer and Conjugar.** The same design. Neither quiz stores anything per verb today.

#### D3. "Test Me on This Verb"

A button on the verb page that asks three questions about the verb in view. The entry point
belongs to this track and the questions to the quiz track.

- **Basis.** A lookup alone teaches little (finding 5). No study of a quiz at the moment of
  lookup was found (finding 7), so this is a reasoned bet and should be tried on people first.
- **Effort.** S for the entry point. The questions are counted in the quiz report.
- **Signal.** Taps per verb view, and questions answered.
- **Conjuguer and Conjugar.** Their quizzes draw from fixed lists and would need a scope first.

#### D4. A Review Card on the Landing Screen

When someone opens the app for the next lookup, one card above the list offers a verb looked up
some days ago, with its principal parts hidden until tapped. One tap reveals them and one
dismisses the card.

- **Basis.** It turns a visit that already happens into a moment of retrieval at a spaced
  interval, which are principles 1 and 5 of the quiz report. It raises what a visit is worth more
  than how many visits there are.
- **Effort.** M. It needs D1 or D2 and a due date per verb.
- **Signal.** Reveals per session, and the second-day return rate of devices that have seen a
  card.
- **Conjuguer and Conjugar.** The same.

#### D5. A Verb of the Day Worth Opening

Draw the widget's verb and the random verb from the 1,000 most frequent verbs, favoring strong
and base verbs, and from My Verbs once it has entries.

- **Basis.** The next ten verbs are observed above. No evidence was found that a word of the day
  brings anyone back, so the aim is only that the surface not waste its chance.
- **Effort.** S.
- **Signal.** Verb pages reached from the widget.
- **Conjuguer and Conjugar.** Check how each chooses its verb. Not verified.

#### D6. Collections

Fixed lists as places to go: the 100 most frequent verbs, the modal verbs, the verbs that take
sein, each ablaut group. A list shows how many of its verbs have been opened, can be shared as a
link, and can start a quiz on itself.

- **Basis.** A finite list gives a self-studier something to finish and a teacher something to
  assign. The quiz report proposes shareable practice sets for the same reason.
- **Effort.** M.
- **Signal.** Lists opened, and quizzes started from a list.
- **Conjuguer and Conjugar.** Strongest for Conjuguer, because of schools.

### Smaller and Later Ideas

| Idea | Basis | Effort | Signal | Siblings |
|---|---|---|---|---|
| Open the app with the search field focused | Saves a tap on a visit that already succeeds | S | Time to first verb page | Same |
| "Missed in a quiz" marker on the verb page, from `QuizErrorHistory` | The data exist. Almost no device has any yet. | S | None until the quiz is used | New store needed |
| Case and preposition for each verb (warten auf, with the accusative) | A writer's question. The corpus has no such data. | L | Deepest section reached | Same gap |
| Example sentences at a learner's level for frequent verbs | The quiz report's sentence frames need the same content | L | Not applicable | Same |
| A verb card as the answer to "Conjugate a Verb", in place of text | Serves people who never open the app | M | Shortcut runs | After C1 |
| Sync My Verbs through iCloud | Listed in `post-release-features.md` | S | Not applicable | Same |
| "Often confused" links between verbs that share a conjugation | The 66 pairs fall out of the map | S to M | Share reached from another verb | Spanish has many |

Deliberately not proposed: streaks, badges, and reminders for lookups. Reminders to review belong
to the quiz track, and a reference app that nags gets deleted (judgment).

### Overall Ranking

With no release before 2027, the ranking orders the building and not a series of releases. Ranks
1 to 11 need no data and could share the first release. Ranks 12 and 15 wait for what that
release measures.

| Rank | Idea | Effort | Why it ranks here |
|---:|---|---|---|
| 1 | A1 to A4: the search fixes | S each | Observed failures, the firmest basis, the least work |
| 2 | The three signals in [What to Measure](#what-to-measure) | S | The later bets are judged by them. They ship with rank 1. |
| 3 | B1 and B2: principal parts, and main-clause conjugations | S to M | Answers the commonest questions on the first screen, and corrects what the page teaches |
| 4 | A5: reverse lookup | M | Serves the visit the app fails entirely |
| 5 | D1 and D2: recents and My Verbs | S to M | The shared piece the quiz track is waiting for |
| 6 | B3: section order, second names, article links | S to M | Shortens every visit to the page |
| 7 | B4: related verbs | S to M | Gives the page exits, and serves arrivals from outside |
| 8 | C1 to C3: search from outside, Spotlight, the picker | S to M | Cheap once A5 exists |
| 9 | D3: "test me" | S here | Depends on the quiz track |
| 10 | D5: the verb of the day | S | Cheap, with unproven return |
| 11 | D4: the review card | M | The best return-visit bet. Needs rank 5. |
| 12 | A6: sentence mode | M | Completes reverse lookup. Wait for signals. |
| 13 | B6: copy and share | S to M | The one idea that reaches non-users |
| 14 | A7: verbs outside the corpus | M | A decision about quality comes first |
| 15 | D6: collections | M | Wait for signals, and for the quiz's scopes |

### Trying Ideas on Real People First

The numbers cannot test anything quickly, and until a release in 2027 they cannot test anything
at all, so a few people must. Nothing below needs a release.

- **Search and reverse lookup.** Give three to five learners a short German text and the current
  app, and write down what each of them types. Twenty minutes of this would show which failures
  in the table above are common.
- **Sentence mode.** A web page over `forms.json`, as under A6.
- **The top of the verb page.** Two pictures of the same verb, today's page and one with
  principal parts. Ask "is it hat or ist aufgestanden?" and time the answer.
- **"Test me".** The three questions on paper, or a development build on a device in the room. A
  TestFlight build is probably out as well: it needs the same upload as a release, which the
  present Mac cannot make.
- **The verb of the day.** Lay ten days of today's sequence beside ten days drawn from the 1,000
  most frequent verbs, and ask which verbs a learner would tap.

## Coordination with the Quiz Track

The two tracks share more than a list of verbs. Each piece below should be built once.

| Shared piece | Exists today | This track needs | The quiz track needs | Suggested builder |
|---|---|---|---|---|
| Learner's verb list: verbs opened, with dates, and verbs starred | No | To write it (D1, D2) and filter by it | To read it as the "my verbs" scope | This track, with the record agreed first. It produces data before the quiz has any. |
| Record per practice item: a box and a due date (Tier 3) | No | To read what is due (D4) | To write it | Quiz track |
| `QuizErrorHistory` | Yes | To read it for a marker on the verb page | "Practice my mistakes" | No change |
| Frequency bands of 100, 300, and 1,000 verbs | The counts exist | Filters, the verb of the day, the random verb | The default session | Quiz track, defined in one place on `Verb` |
| Ladder of conjugationgroups by use (Tier 2) | No | Section order on the verb page (B3) | Levels | Quiz track defines it, and the verb page follows |
| Convention for separable verbs, and a function that returns the main-clause conjugation | Only for the Imperativ | Display (B2) and the map's stranded parts | What the quiz accepts | One owner, since it is conjugator work. Whichever track starts first. |
| Conjugation-to-infinitive map | As a test harness | Reverse lookup (A5, A6) | Recognition questions (Tier 5) | This track |
| A function that answers "which conjugations of this verb equal this text?" | No | Naming the match (A5) | Diagnosing "another cell of the same verb" (Tier 4) | Whichever track needs it first |
| A function that returns a verb's principal parts | No | The header (B1), sharing, Spotlight keywords | The principal-parts exercise and item | This track |
| Key row for ä, ö, ü, ß, and folding of digraphs | No | The search field (A1, A8) | The answer field (Tier 1) | One component, built by whichever track starts first |
| Deeplink grammar | Four routes | A search route and list links | Shareable quiz scopes | Agree on one grammar before either adds a route |
| The `source` parameter in analytics | No | On `viewVerbView` | On `startQuiz` | One vocabulary. See below. |
| A quiz that takes a list of verbs | No | Entry points on the verb page and on lists | The scope itself | Quiz track |

**Ideas handed to the quiz track**, because their substance is a better quiz:

- The questions behind "test me on this verb", and a quiz over My Verbs or a collection.
- Recognition questions that show a conjugation and ask for the verb. They are reverse lookup
  turned into practice and use the same map.
- The principal-parts exercise, which shares its function with the verb page's header.
- Scheduling and any reminder to review. The review card (D4) only displays what the schedule
  says is due.
- The widget's daily question. It inherits the quiz's sampling: three of the next ten are Futur
  Indikativ, on verbs such as einherfahren.

Who builds the shared pieces is a decision for Josh. The suggestion above is that this track
builds what lookups produce and the quiz track builds what practice produces.

## What to Measure

### The Privacy Policy First

[`docs/privacy_policy.txt`](privacy_policy.txt) says that the app "does not record your quiz
answers, your scores, the verbs you look up, or any text you type". Nothing below records a verb
or any typed text.

The policy also lists what analytics record (screens, quiz events, quiz difficulty, and the
question number reached) and ends the list with "That is all". Two consequences follow, both
**observed**. Any new signal, however harmless, needs a line added to that list. And the list is
already short: the app sends signals for starting and losing the game, for taps on rate, play,
leaderboard, and onboarding, and for tutor messages, none of which the list mentions.

The timing matters now that no release is possible before 2027. The policy describes what the
shipped app does. The lines for the signals it already omits can be deployed at once, and the
defect plan adds them. The line for a new signal belongs in the deployed policy on the day the
release that sends it ships, and not before.

**Corrected on `main` 2026-11-10** by Part 5a of the defect plan, ready for Josh to deploy. The
corrected list is derived from `Analytics.swift` and its call sites, and it found more than this
section did. The TelemetryDeck SDK (2.11.0, the version 1.4 ships) attaches about 30 parameters
to every signal: device model, OS version, screen size, locale, region format, time zone,
appearance, accessibility settings, run context, and session counts. It also sends a first-launch
signal and a session-start signal of its own. The policy now names all of it. So a new signal's
line is shorter than this section implied, because the device context needs no new mention, but
a new *parameter* still does.

### Signals

Names follow `Analytics.swift`: a verb first, in camelCase, with parameter keys in `ParameterKey`
and values in coarse bands. The names are proposals.

| Signal | Parameters | Sent | Answers |
|---|---|---|---|
| `finishSearch` | `outcome`: opened, abandoned, or noResult. `queryLength`: 1 to 2, 3 to 5, 6 to 9, 10 or more. `resultCount`: 0, 1, 2 to 10, 11 or more. `matchKind`: infinitive, folded, translation, conjugation, or none. `resultPosition`: 1, 2 to 5, 6 or more. | Once per search, when a result is opened, the field is cleared, or the app leaves with text in the field | How often search fails, and which kind of match rescues it |
| `viewVerbView` (existing) | `source`: search, browse, family, related, recent, myVerbs, list, widget, spotlight, shortcut, control, deeplink, handoff, or infoLink | As now | How verbs are reached, and how many arrivals never see the list |
| `leaveVerbView` | `deepestSection`: header, simple, compound, etymology, or example. `dwell`: under 5 s, 5 to 15 s, 15 to 60 s, over 60 s. | Once per verb view | Whether anyone reaches the Konjunktiv tables, the etymology, or the example |
| `tapStarVerb`, `tapTestVerb`, `tapShareVerb` | None | On the tap | Whether the new affordances are used |

Two flags were proposed for the case in which the signals ship before the fixes. When a search
finds nothing, the app can check on the device whether it would have matched with umlauts
folded, and whether it would have matched a gloss, and send `wouldMatchFolded` and
`wouldMatchTranslation`. That measures ideas A1 and A2 without sending a letter of what was
typed. With no release before 2027, the signals and the small fixes will ship together, and the
flags are worth building only if A1 or A2 is left out of that release.

### What Was Typed

The most valuable thing a reference app can learn is what people wanted and did not get. Four
ways to learn it, from most private to least:

1. **Bands and flags only**, as above. Within the policy once its list is extended.
2. **A class, decided on the device.** Once the map ships, a failed search can be classified
   (a misspelling of a known verb, a known prefix on a known verb, a word with a capital letter,
   more than one word) and only the class sent.
3. **Sent by the learner.** The "Ask for this verb" link in A4. It is a message, not telemetry.
4. **The text of failed searches**, under a revised policy. A search field accepts anything,
   including names, and most of the audience is in Germany. Not recommended.

Options 1 to 3 together recover most of what option 4 would give (**inference**).

### In Line with the Quiz Track

The quiz report proposes sending the difficulty with `startQuiz`, reporting the question reached
when a quiz is abandoned, and banding the time to a quit. Nothing above collides with those. One
addition joins the tracks: give `startQuiz` the same `source` key, with values such as tab,
verbPage, myVerbs, list, widget, and shortcut, so that a quiz begun from a verb page can be told
from one begun on the Quiz tab.

### Reading the Numbers

- **Baselines to move.** The share of real devices that have ever opened a verb page, now 60% to
  66%. The no-result share of searches, unknown today. Verb pages per session, now 1.1. Return on
  a second day, now 42.1%.
- **The siblings will answer first, once they ship.** Conjuguer and Conjugar have seven to ten
  daily users each. The same three signals there would describe lookups within weeks of a
  release. None of the three apps can be released before 2027, so the work for now is to build
  the signals into all three. Conjuguer's single `viewAppeared` signal takes a new parameter
  easily. Conjugar sends one signal name per screen and has no parameters on its views
  (**observed**).
- **The wait is a baseline.** Until the releases, no app changes, and movement in the existing
  numbers reflects audience and season. Refresh `telemetry-usage.md` just before each release.
- **The cautions of the quiz report apply.** Exclude the one-day UTC+8 devices. Remember that one
  device holds a third of Konjugieren's sessions. Judge direction over months, not differences
  between weeks.

## Decisions for Josh

1. **Search scope.** Flip the setting's default to include glosses, or retire the setting and
   always search both?
2. **The trombone.** Retire it on empty searches, here and in the siblings?
3. **Separable verbs.** Should the verb page show the main-clause conjugation? This is the quiz
   report's first decision, seen from the reference side.
4. **Section order.** Keep the morphological order, or order by use and fold the rest?
5. **The map.** Ship a generated file or build it on the device? Either way, regenerate it, since
   the copy analyzed here dates from July.
6. **Shared pieces.** Does this track build the learner's verb list, the map, and the
   principal-parts function, and the quiz track the bands, the ladder, and the practice record?
7. **The privacy policy.** Which of the four ways of learning what was typed is acceptable? The
   rest is settled. Josh decided on 2026-11-10 that the policy should list the signals the app
   sends, and the game and tap signals it omitted were added under the defect plan (Part 5a). The
   corrected text is on `main`, ready for Josh to deploy with both date lines set to the day he
   does. A new signal's line goes into the deployed policy when the release that sends it ships.
8. **Which app is released first in 2027.** The signals can be built into all three before then,
   and the siblings' numbers will arrive soonest after their releases.
9. **Verbs outside the corpus.** Is a derived table acceptable under a clear label, or must every
   table be verified?
10. **The verb of the day.** Draw it from frequent verbs, and later from My Verbs?
11. **Futur II and the passive.** Add them to the page?
12. **Sharing.** Is a web domain for universal links worth it for a small referral channel?
13. **Glosses.** Eleven real devices run in neither English nor German, and every gloss is
    English. This follows from the localization policy and is noted only so that it is a choice.
14. **The defects below.** Decided on 2026-11-10: they are fixed first, under
    [`plans/fix-reference-defects.md`](../plans/fix-reference-defects.md). **Done the same day.**

## Defects Found Along the Way

All **observed** in the simulator on the current `main`, on 2026-11-10. None was fixed during
this research, because the plan asked for no changes to the app. **All five were fixed on `main`
later that day**, under the defect plan below, which is finished. Each item keeps its original
observation and notes its fix.

**A plan to fix them exists, and it found more.**
[`plans/fix-reference-defects.md`](../plans/fix-reference-defects.md) was written the same day.
Preparing it meant comparing every shipped auxiliary with the kaikki snapshot, which showed that
item 1 below is far larger than one worklist: 37 verbs are contradicted outright, among them
stattfinden (er ist stattgefunden), reisen (er hat gereist), and umziehen (er hat umgezogen), and
141 more need a ruling. It also found that backen ships the participle gebackt. That plan's
Status section and the 2026-11-10 entries of `docs/blog_notes.md` are the record of what was
fixed and what was deliberately deferred. The deferrals are in the roadmap's "Known gaps".

1. **aufstehen shows haben.** The auxiliary pill reads haben and the Perfekt Indikativ reads
   ich habe aufgestanden, under the gloss "get up". In that sense the verb takes sein: ich bin
   aufgestanden (**background**). The verb is row 39 of `verbdata/tranche2-dual-auxiliary.txt`,
   the list of verbs that have two readings and ship one, which the roadmap then tracked (frozen as history since 2026-11-10; `verbdata/auxiliary-rulings.tsv` is the current record). That
   list has 194 rows, and 182 of them record haben. Several pair it with a gloss that describes
   motion or a change of state: abfahren "depart, leave", abfliegen "take off, fly away",
   abbiegen "turn, turn off", ausziehen "move out, vacate" (**inference** from the glosses, and
   only aufstehen was opened). Whichever of them reads this way is wrong in the same manner, and
   "haben or sein?" is among the questions people open such an app to settle. **Partly fixed
   on `main` 2026-11-10** by Part 1 of the defect plan: the 37 verbs kaikki contradicts outright,
   and zurücktreten, were ruled against DWDS and German Wiktionary. aufstehen and eight of the
   ten verbs in the plan's first table now read correctly; bedürfen and backen were fixed by Parts 2 and 7.
   12 verbs gained a second reading. **Fixed on `main` 2026-11-10** by Part 6: every verb the
   audit lists is ruled (254 verbs, 336 readings in `verbdata/auxiliary-rulings.tsv`), 120 verbs
   now have more than one reading, and all ten verbs of the plan's first table read correctly in
   the simulator. The importer that caused it now takes the auxiliary from the gloss's own sense
   and holds back what kaikki cannot settle. schaffen gained its strong reading the same day. Five
   family splits and seven verbs without a source are deferred; the roadmap's "Known gaps" lists
   them.
2. **Three verbs lose their prefix in some conjugations.** bedürfen shows ich darf, du darfst, er
   darf for bedarf, bedarfst, bedarf. vermögen shows ich mag, du magst, er mag for vermag,
   vermagst, vermag. entgelten shows du galtest and ihr galtet for entgaltest and entgaltet. All
   three sit on ablaut groups that replace the whole stem, and the replacement appears to drop
   the inseparable prefix (**inference** about the cause). A scan of the July map found no other
   verb with the symptom. **Fixed on `main` 2026-11-10** by Part 2 of the defect plan. The
   inference was right: `Conjugator` returned an override without the reading's prefixes, and
   now puts them back.
3. **Two tables disagree with the app's own example sentences.** hauen is classed as weak with
   the Perfektpartizip gehaut, and the example for zusammenhauen has zusammengehauen. The
   standard participle is gehauen (**background**). krauchen is classed as strong (kroch,
   gekrochen), and its example has krauchte. Which side is right in each case needs a ruling
   against a dictionary. **Fixed on `main` 2026-11-10** by Part 7 of the defect plan. The
   sentences were right both times. hauen, backen, and salzen now generate gehauen, gebacken,
   and gesalzen, with their derivatives, and krauchen is weak, as Duden and DWDS give it.
4. **35 example sentences do not contain a conjugation that the app generates for their verb.**
   Some quote a different verb: the sentence for greifen uses ergriff, the one for fertigen uses
   verfertigt, and the one for abstimmen has only the noun Abstimmung. The appendix lists the
   kinds. **The five that quote another verb were replaced on `main` 2026-11-10** by Part 4 of
   the defect plan, along with three authored sentences that illustrated senses the corrected
   glosses dropped. The scan found 29 after Part 4, 27 after Part 7, 26 at the plan's
   Closing, when übergehen's sentence found its new separable reading, and 25 once schaffen's
   *schuf* found its strong reading. Each is in a class the
   appendix names. The full list was written to the session scratchpad and can be regenerated in a minute.
5. **The map is stale.** `corpus/working/forms.json` dates from 2026-07-25 and matches the
   corpus's 3,572 verbs, but glosses and counts have changed since, and the counts in this
   document should be confirmed against a fresh run. **Fixed 2026-11-10** in Part 0 of the
   defect plan: the map was regenerated, and both scans reproduced their counts (3 verbs, 35
   sentences).

## Limits of the Research

- **No learners.** Nobody was watched using the app. Every claim about what people type or want
  is inferred.
- **One simulator.** An iPhone 17 simulator on an Intel Mac, set to the Swiss variety, so
  schließen displayed as schliessen. The iPad layout was read and not run. Tutor surfaces cannot
  render on this host and were not examined. Spotlight on a device may differ from the simulator.
- **A replayed search.** The search table comes from a script that applies the app's rule to the
  corpus. Five of its queries were confirmed in the simulator.
- **A July map.** See defect 5. The count of base verbs comes from a simple parse of the prefix
  markers and treats bound roots such as -ginnen as bases.
- **The survey.** Pages were fetched through a tool that summarizes them. LEO, PONS, bab.la,
  cactus2000, Le Conjugueur, L'Obs, and Bescherelle could not be reached. No competing app was
  installed or used. Reviews quoted on store pages were few and mostly old.
- **The literature.** Two sources were read in full (De Schryver et al. 2006, Nygaard & Fjeld
  2008). The IDS Mannheim studies of German dictionary logs were blocked. No figure was found for
  the share of searches that are inflected words, for why learners consult a conjugation table,
  or for session length in reference apps.
- **Platform facts.** Several Apple documentation pages failed to load. Share and Action
  extensions, App Clips, universal links, and Apple Intelligence integration are at background
  strength.
- **The siblings.** Read, not run. Whether their result ranking and their verb of the day share
  Konjugieren's behavior was not verified.

## Sources

**Dictionary use and lookup**

- De Schryver, G.-M., Joffe, D., Joffe, P., & Hillewaert, S. (2006). Do dictionary users really look up frequent words? On the overestimation of the value of corpus-based lexicography. *Lexikos*, 16, 67-83. <https://lexikos.journals.ac.za/pub/article/view/648/248>. read
- Nygaard, L., & Fjeld, R. V. (2008). A study of failed searches in Norwegian online dictionaries (title not recorded). *LexicoNordica*, 15, 57-72. <https://tidsskrift.dk/lexn/article/download/18521/16194/42274>. read
- Koplenig, A., Meyer, P., & Müller-Spitzer, C. (2014). Dictionary users do look up frequent words: A log file analysis. <https://euralex.org/?p=7503>. read (abstract)
- Lew, R., & Wolfer, S. (2024). A study of six years of English Wiktionary logs (title not recorded). *SAGE Open*, 14(1). secondhand
- Yanagisawa, A., & Webb, S. (2021). To what extent does the Involvement Load Hypothesis predict incidental L2 vocabulary learning? A meta-analysis. *Language Learning*. secondhand
- Peters, E. (2007). Manipulating L2 learners' online dictionary use and its effect on L2 word retention. *Language Learning & Technology*, 11(2), 36-58. <https://www.lltjournal.org/item/427/>. secondhand
- van den Broek, G. S. E., Wesseling, E., Huijssen, L., Lettink, M., & van Gog, T. (2022). Vocabulary learning during reading: Benefits of contextual inferences versus retrieval opportunities. *Cognitive Science*, 46(4), e13135. <https://pmc.ncbi.nlm.nih.gov/articles/PMC9285746>. read (abstract)
- Boers, F., Eyckmans, J., & Stengers, H. (2007). Presenting figurative idioms with a touch of etymology. *Language Teaching Research*, 11(1), 43-62. secondhand

**Other tools** (loaded or read 2026-11-10)

- verbformen.de: <https://www.verbformen.de/?w=ging>. Its iOS app: <https://apps.apple.com/app/id1522285301>
- Reverso Conjugation, German: its pages for ging, gefunden, and "fängt an"
- DWDS: <https://www.dwds.de/?q=ging>
- Duden: <https://www.duden.de/suchen/dudenonline/ging>
- Wiktionary: <https://en.wiktionary.org/wiki/ging> and <https://de.wiktionary.org/wiki/ging>
- SpanishDict: its conjugation page for fue
- WordReference conjugator: its Spanish page for fue and its French page for suis
- Ella Verbs: <https://ellaverbs.com/>
- VerbForms Deutsch: <https://apps.apple.com/us/app/-/id1046394251>
- German Dictionary + (VidaLingua): <https://apps.apple.com/us/app/german-dictionary/id323114649>
- Merriam-Webster for iOS: <https://apps.apple.com/us/app/merriam-webster-dictionary/id399452287> and <https://www.merriam-webster.com/help/faq-apple-apps>
- Pleco's clipboard reader, described at <https://www.sinosplice.com/life/archives/2016/09/06/plecos-hidden-gem-the-clipboard-reader>. secondhand
- Duolingo. Widget feature. <https://blog.duolingo.com/widget-feature>. vendor

**Apple documentation** (read 2026-11-10)

- IndexedEntity: <https://developer.apple.com/documentation/appintents/indexedentity>
- Making app entities available in Spotlight: <https://developer.apple.com/documentation/appintents/making-app-entities-available-in-spotlight>
- CSSearchableItemAttributeSet: <https://developer.apple.com/documentation/corespotlight/cssearchableitemattributeset>
- Adding interactivity to widgets and Live Activities: <https://developer.apple.com/documentation/widgetkit/adding-interactivity-to-widgets-and-live-activities>
- UIReferenceLibraryViewController: <https://developer.apple.com/documentation/uikit/uireferencelibraryviewcontroller>
- DataScannerViewController: <https://developer.apple.com/documentation/visionkit/datascannerviewcontroller>

## Appendix: What the Map Misses

The 35 example sentences in which the July map does not find the sentence's own verb, by kind.

**Status, 2026-11-10.** The defect plan took the count from 35 to 25. Ten left the list: the five
sentences that quoted another verb were replaced; bedürfen's *bedarf* is generated since its
prefix is restored; krauchen and zusammenhauen match since krauchen went weak and hauen's
participle went strong; übergehen's *geht ... über* found a new separable reading; and schaffen's
*schuf* found a new strong reading. The remaining 25 are the classes below that are limits of the
map or the dual-paradigm gap, not defects of the app.

| Kind | Count | Examples | Remedy |
|---|---:|---|---|
| The sentence uses a standard conjugation that the app's table for the verb lacks: a variant, or a second reading | 12 | schuf (schaffen), wandte (wenden), sandte (voraussenden), hieb (hauen, niederhauen), saugte (absaugen, einsaugen, festsaugen), verglomm (verglimmen), klob (klieben), krauchte (krauchen), zusammengehauen (zusammenhauen) | Corpus work, which the roadmap describes. Two of these are listed as defect 3. Fixed 2026-11-10: schaffen, krauchen, zusammenhauen. The rest are the dual-paradigm gap. |
| A participle with an adjective ending | 7 | geklebte, gestrichenen, vorgeschlagenen, hervorgehobenen, glänzende, existierendem, Verstorbenen | Strip the ending before matching |
| The sentence quotes a different verb, or no verb | 5 | ergriff for greifen, verfertigt for fertigen, ausschalten for schalten, nützen for nutzen, Abstimmung for abstimmen | Replace the sentence. Done 2026-11-10 (defect plan, Part 4). |
| A short imperative | 4 | halt (danebenhalten, runterhalten, warmhalten), red (daherreden) | Add the variant, as the quiz report's audit of the Imperativ also asks |
| An older spelling | 4 | interpretirte, spezialisiren, tödtet, einsehn | Add spelling variants where a rule exists |
| A particle written as two words, or a reading the corpus lacks | 2 | lebte ... wieder auf (wiederaufleben), geht ... über (übergehen) | Sentence mode must join particles. The second was a missing reading, added 2026-11-10. |
| A wrong conjugation in the app | 1 | bedarf (bedürfen) | Defect 2. Fixed 2026-11-10. |
