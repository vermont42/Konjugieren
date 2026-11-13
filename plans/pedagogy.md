# Pedagogy: Findings and Suggestions for the Quiz

Research and ideation in response to [`prompts/pedagogy.md`](../prompts/pedagogy.md), written on
2026-11-10. Nothing in the app was changed. The subject is Konjugieren's quiz, with notes on
Conjugar and Conjuguer where their quizzes differ. It was revised the same day, after the usage
snapshot gained App Store Connect data and a correction to Konjugieren's device count. A section
on release timing, [No Release Before 2027](#no-release-before-2027), was added later that day
by the session that wrote [`docs/browse-and-verb-ideas.md`](../docs/browse-and-verb-ideas.md).

Parts of what this report suggests were built on `main` between 2026-11-12 and 2026-11-13 by
[`plans/browse-and-verb-implementation.md`](browse-and-verb-implementation.md), the browse plan,
because the browse ideas needed them. Each is noted under its tier with a **Built on `main`**
or **Partly built** line. None has reached a learner, since no release is possible before 2027.

The suggestions Josh accepted, and his answers to [Decisions for Josh](#decisions-for-josh), are
built by [`plans/pedagogy-implementation.md`](pedagogy-implementation.md), written 2026-11-13. Its
phases add further **Built on `main`** lines here as they finish.

Four inputs went into this document:

1. **The code.** `Quiz.swift`, `QuizView.swift`, `ResultsView.swift`, `QuizErrorHistory.swift`,
   `Conjugator.swift`, `WidgetSnapshotWriter.swift`, and the verb corpus, read directly.
2. **A played session.** A build of the current `main` was launched in the iPhone 17 simulator, and
   one full 30-question quiz was played, plus part of a second.
3. **Usage data.** [`docs/telemetry-usage.md`](../docs/telemetry-usage.md), the snapshot of the same date
   from TelemetryDeck (what people do inside the apps) and App Store Connect (how they arrive).
4. **The literature.** Thirteen research passes over cognitive psychology, second-language
   acquisition, curricula, competing tools, and engagement, plus a read-only survey of the Conjugar
   and Conjuguer repositories.

## How to Read This Document

Claims carry different weights, and the difference matters when deciding what to build. Each claim
in the evidence sections is labeled.

| Label | Meaning |
|---|---|
| **observed** | Seen in this repository's code, in the simulator, or in `telemetry-usage.md`. |
| **read** | A researcher read the primary source, or its abstract on the publisher's or a repository's page, during this project. |
| **secondhand** | Known only from a search summary, a review article, or another secondary source. Verify before relying on it. |
| **vendor** | A company's report about its own product. |
| **inference** | Reasoning from the above. Mine unless stated. |
| **background** | General knowledge that was not verified during this project. |

Two warnings apply throughout. First, almost no controlled research exists on verb-conjugation
trainers as such. Most of the evidence concerns vocabulary, facts, or classroom grammar, and its
application to a conjugation app is extrapolation. Second, publisher paywalls blocked many primary
sources, so several well-known findings appear here at secondhand strength. The section
[Limits of This Research](#limits-of-this-research) lists what could not be established.

On terminology: "conjugationgroup" is used for Konjugieren's categories, following
[`docs/terminology.md`](../docs/terminology.md). The word "tense" appears only where a cited study or a
sibling app uses it.

## Short Answers

**Is Konjugieren's method pedagogically sound?** In part. The single question is defensible:
typing a conjugation from memory and then seeing the correct one is retrieval practice with
feedback, which is among the best-supported techniques in the science of learning. The system
around the question is not sound. The quiz draws verbs uniformly at random from a 3,572-verb
reference corpus, so it asks mostly about verbs a learner will rarely meet. It draws
conjugationgroups uniformly, so it asks about them in proportions unrelated to their usefulness or
to the order in which learners can acquire them. Nothing is ever asked twice, nothing carries from
one session to the next, a missed question is never revisited, and the correction for a wrong
answer appears beside the next question. It also marks several kinds of correct German wrong. In
form it is an examination over the reference corpus, and the usage data show that no one has ever
finished it: 32 quizzes started by real users, none completed.

**What methods work?** Practice the right things, more than once, with feedback that is noticed.
In the research this means: choosing material by frequency and by the learner's level; teaching a
pattern before testing it; retrieving each item to a criterion within a session and again in later,
spaced sessions; giving the correct answer after an error with time to absorb it, and saying what
kind of error it was; tying conjugations to meaning; and treating speed as a late goal for material
that is already accurate.

**What should change?** The suggestions fall into six tiers, detailed under
[Suggestions](#suggestions). In order of leverage:

1. Stop marking correct German wrong.
2. Change what the quiz asks: frequent verbs first, conjugationgroups in levels, sessions of about
   ten questions.
3. Give the quiz a memory: revisit missed questions within the session and again on later days.
4. Hold the screen on a wrong answer and say what kind of error it was, using the conjugator's own
   knowledge.
5. Add meaning and new directions of practice: principal parts, families, recognition, sentences.
6. Rebuild motivation around visible personal progress in place of a global score.

**If only three things are done:** accept the answers that are correct (tier 1), make the default
session ten questions on the 100 most frequent verbs at a beginner's set of conjugationgroups
(tier 2), and re-ask missed questions before the session ends (tier 3). Each is small, and together
they address the most likely causes of the first-question exodus.

One caution about the secondary goal belongs up front. Better pedagogy can raise the share of
people who stay. It cannot raise the number who arrive, and for Konjugieren arrival is the
constraint. The app has had 52 first-time downloads in eight months. The App Store shows it about
157 times a month, a sixth as often as Conjuguer. The people who do see it download it at about
twice the rate of a typical free education app, and 42% of its real users return on a second day,
close to Conjugar's 45%. Konjugieren is chosen and kept at respectable rates. It is rarely seen.
The figures are under [What the Usage Data Add](#what-the-usage-data-add).

## No Release Before 2027

Added on 2026-11-10, after the rest of this document was written. Josh cannot cut a release of
Konjugieren, Conjuguer, or Conjugar from his present MacBook and plans to replace it in 2027.
`CLAUDE.md` records the constraint. What it changes here (**inference**):

- **Nothing below can reach a learner, or be measured, before then.** The six tiers still order
  the work. Tiers 1 to 3, and the "three things" of the Short Answers, can all be ready for the
  first release.
- **No app can be the place to try something first.** The advice under
  [Conjugar and Conjuguer](#conjugar-and-conjuguer) to try session-level changes in a sibling
  early rested on the siblings' numbers arriving sooner. They still will, after each app ships.
  Before that, no app's numbers can respond to anything. Build shared changes into all three.
- **The signals under [What to Measure](#what-to-measure) ship with that release.** The months
  before it are a baseline in which none of the three apps changes.
- **Conjuguer's minimum OS is on a clock.** Lowering it needs a release, and the Swiss
  institution installed each September. Checking the operating systems behind the 2024 and 2025
  purchases in App Store Connect needs no release and is worth doing before the new Mac arrives.
- **Watching learners needs no release.** This research interviewed nobody. Sitting beside a few
  learners while they use the present quiz, or giving them a ten-question session on paper, is
  the evidence that can be gathered in the meantime.

## What the Quiz Does Today

All **observed**, from the code unless noted.

| Aspect | Behavior |
|---|---|
| Length | 30 questions per quiz. |
| Verb choice | Uniformly random over all 3,572 verbs, with replacement. Frequency is not consulted. |
| Conjugationgroup choice | 1 Präsenspartizip and 2 Perfektpartizip questions per quiz. The other 27 are drawn uniformly from a set fixed by the difficulty setting. |
| Regular difficulty | Präsens Indikativ, Perfekt Indikativ, Futur Indikativ, Imperativ: about 6.75 questions each. |
| Ridiculous difficulty | The four above plus Präsens Konjunktiv I, Präteritum Indikativ, Präteritum Konjunktiv II, Perfekt Konjunktiv I, Plusquamperfekt Indikativ, Plusquamperfekt Konjunktiv II, Futur Konjunktiv I, and Futur Konjunktiv II: about 2.25 questions each. Seven of the twelve are compound. |
| Person choice | Uniformly random over six persons, or over du, ihr, wir, and Sie for the Imperativ. |
| Prompt | Infinitive, English gloss of one reading, pronoun, conjugationgroup name (German by default), running score, elapsed time. |
| Answer | Typed. Graded by exact match after trimming and lowercasing, against the conjugation in each of the three regional varieties. |
| After a right answer | Chime, checkmark, next question. |
| After a wrong answer | Buzz, shake, and the rows "Last Answer" and "Correct Answer" appear on the card that already shows the next question. Irregular letters in the correct answer are red. |
| Retry, hint, re-asking | None. |
| Score | 10 points per correct answer, doubled at Ridiculous. Time is shown and does not count. |
| Results | Score, count correct, difficulty, time, and all 30 questions with correct answers. A Game Center leaderboard button. |
| Memory | The last 200 wrong answers are stored in `QuizErrorHistory`. The quiz never reads them. Nothing else persists. |
| Before starting | The Quiz tab shows a title and a Start button and nothing else (simulator). |
| Sounds | A gunshot at the start, applause at the end, and a sad trombone when the learner quits. |

One documentation note: `docs/feature-architecture.md` lists three conjugationgroups for Regular
and four additions for Ridiculous. The code has four and eight. The same document says that the
arcade game's players shoot "by conjugating verbs", and the game's code contains no conjugation at
all.

### A Real Session

The first quiz played in the simulator, at Regular difficulty, asked the following. Rank is the
verb's position among the 3,572 by the corpus's DWDS frequency counts, 1 being the most frequent.

| # | Verb | Rank | Pronoun | Conjugationgroup | Expected answer |
|---:|---|---:|---|---|---|
| 1 | anschmeißen | 2,658 | ihr | Futur Indikativ | werdet anschmeißen |
| 2 | meistern | 749 | ich | Präsens Indikativ | meistere |
| 3 | ferngucken | 3,528 | ihr | Perfekt Indikativ | habt ferngeguckt |
| 4 | übernehmen | 76 | ich | Präsens Indikativ | übernehme |
| 5 | stoßen | 296 | er | Perfekt Indikativ | ist gestoßen |
| 6 | abliegen | 3,256 | ich | Futur Indikativ | werde abliegen |
| 7 | entstammen | 1,518 | ihr | Futur Indikativ | werdet entstammen |
| 8 | vorlegen | 465 | sie (3p) | Perfekt Indikativ | haben vorgelegt |
| 9 | abneigen | 2,109 | du | Futur Indikativ | wirst abneigen |
| 10 | anklagen | 1,244 | wir | Perfekt Indikativ | haben angeklagt |
| 11 | verschauen | 3,381 | Sie | Imperativ | verschauen Sie |
| 12 | hinausbringen | 3,253 | er | Futur Indikativ | wird hinausbringen |
| 13 | nachsteigen | 3,301 | wir | Imperativ | steigen wir nach |
| 14 | hinziehen | 1,466 | du | Imperativ | zieh hin |
| 15 | überwerfen | 2,396 | ihr | Futur Indikativ | werdet überwerfen |
| 16 | entgegenschlagen | 2,576 | ich | Futur Indikativ | werde entgegenschlagen |
| 17 | anprüfen | 982 | ihr | Präsens Indikativ | anprüft |
| 18 | wegführen | 2,769 | ihr | Perfekt Indikativ | habt weggeführt |
| 19 | verreden | 3,541 | | Perfektpartizip | verredet |
| 20 | mitfahren | 1,556 | wir | Imperativ | fahren wir mit |
| 21 | reiten | 1,173 | er | Präsens Indikativ | reitet |
| 22 | bedeuten | 101 | sie (3p) | Futur Indikativ | werden bedeuten |
| 23 | verantworten | 906 | wir | Präsens Indikativ | verantworten |
| 24 | zuschießen | 2,462 | wir | Imperativ | schießen wir zu |
| 25 | ausreichen | 796 | du | Futur Indikativ | wirst ausreichen |
| 26 | einfallen | 851 | sie (3p) | Futur Indikativ | werden einfallen |
| 27 | entscheiden | 62 | | Perfektpartizip | entschieden |
| 28 | voraushaben | 3,141 | ich | Perfekt Indikativ | habe vorausgehabt |
| 29 | vorgreifen | 2,417 | | Präsenspartizip | vorgreifend |
| 30 | umstoßen | 2,433 | Sie | Imperativ | stoßen Sie um |

Two of the thirty verbs are among the 100 most frequent. The median rank is about 2,100. Ten of
the thirty questions are Futur Indikativ, which is above the expected 6.75 and within ordinary
variation. This is one draw, shown as an illustration. The expected values in the next section do
not depend on it. A second quiz opened with abkehren, eintauchen, zusammenhalten, wegdrängen,
anwerben, draufstehen, auferlegen, entzaubern, hersagen, zuerkennen, fortschaffen,
darniederliegen, folgen, rücküberweisen, and hinunterhalten, the last being the least frequent
verb in the corpus.

Behaviors confirmed by typing answers in the simulator:

- `werden anschmeissen` for question 1 was marked wrong, correctly. The correction appeared under a
  card headed `meistern / ich / Präsens Indikativ`, with no trace of the question it belonged to.
- `ihr habt ferngeguckt` was marked wrong. The expected answer omits the pronoun.
- `uebernehme` was marked wrong. The expected answer needs `ü`.
- `ist gestoßen` was marked right while the app displayed Swiss `ss` spellings. Cross-variety
  tolerance works as designed.
- `halten hinunter` for `hinunterhalten / wir / Präsens Indikativ` was marked wrong. The expected
  answer was `hinunterhalten`.
- `stossen Sie um` was marked right. The Sie-Imperativ answer includes the pronoun.

## What the Usage Data Add

All **observed**, from `telemetry-usage.md`: TelemetryDeck through 2026-11-10 and App Store Connect
through 2026-11-08.

### A Correction First

Twenty of the 77 devices in Konjugieren's TelemetryDeck history are not learners. Each appeared
once, in the UTC+8 time zone, toured nearly every screen in a single day, and never returned.
Konjugieren is not offered in China, and removing the twenty leaves 57 devices, exactly App Store
Connect's count of lifetime downloads. The snapshot's best guess is a re-signed copy explored by an
automated service. Those devices started 13 of the 45 quizzes on record, so the Konjugieren figures
below are for the 57 real devices wherever the snapshot allows. An earlier draft of this report
took the Chinese-language devices for a quarter of Konjugieren's learners. That reading was wrong.

### Inside the Apps

| | Konjugieren, real devices | Conjuguer | Conjugar |
|---|---:|---:|---:|
| Devices | 57 | 192 | 178 |
| Returned on a second day | 42.1% | 56.8% | 44.9% |
| Quiz starts | 32 | 159 | 203 |
| Completions | 0 | 12 (7.5%) | 68 (33.5%) |
| Recorded quits | 17 | 118 | 85 |
| Quits on question 1 | 11 to 13 | 58 (49%) | 31 (36%) |
| Median session length | 19 s, all devices | 11 s | 51 s |

Four readings of these numbers shape everything that follows.

**Interest in the quiz is real.** Between 14 and 20 of the 57 real devices started at least one
quiz, a quarter to a third. The range reflects how the snapshot counts devices across two naming
schemes. People try it.

**Most people who start never answer.** A quit "on question 1" means that no answer had been
submitted. Of the 19 quits on record, 13 were of that kind, five came after exactly one answer, and
one came after three, so those 19 quizzes drew at most eight answers in all. Two of the 19 belong
to the automated devices, and the snapshot does not say which, so among real users at least 11 of
17 quits came before any answer. Fifteen more real starts ended with the app being left. Whatever
drives people away does so before or at the first answer, which points at the first prompt and the
commitment it implies more than at discouraging feedback later on (**inference**).

**The cliff is shared, and the depth differs.** All three apps lose many learners at question 1,
which suggests a cause in the design they share: a Start button that leads at once to a typed
question with a running clock. The apps differ greatly in how many learners finish. Conjugar, where
a third finish, draws its Easy quiz from short hand-curated lists of common verbs in three tenses.
This comparison is suggestive and no more, because the three apps also differ in language,
audience, and history (**inference**).

**The reference is the product.** Verb browsing and the verb page dominate every app's signals.
A median session of 19 seconds is a lookup. A 30-question typed quiz takes five to ten minutes,
which is a different kind of visit from the one people make.

### How People Arrive

| Average per month | Konjugieren | Conjuguer | Conjugar |
|---|---:|---:|---:|
| App Store impressions | 157 | 904 | 450 |
| Product-page views | 25 | 68 | 52 |
| First-time downloads | 6.5 | 36 | 16.5 |

Konjugieren's column covers its whole life since 2026-03-13. The siblings' columns cover their last
twelve full months.

- **Konjugieren is chosen when seen, and it is rarely seen.** In eight months it has had 1,290
  impressions, 204 product-page views, and 52 first-time downloads. Its lifetime conversion rate of
  7.05% is about twice the median that Apple reports for comparable free education apps in its one
  benchmark week (3.60%). Search supplies 83% of its impressions.
- **Its store audience is mostly in German-speaking countries.** Germany, Switzerland, and Austria
  supply 853 of the 1,290 impressions, and Germany supplies 29 of the 52 first-time downloads
  against 13 from the United States. American visitors open the product page more often than German
  ones (87 views against 73) and go on to download less than half as often.
- **Availability is narrow by design.** Each app is offered only where it is localized: in
  English-speaking countries and in those that speak the language it teaches. For Konjugieren that
  is 43 of 175 storefronts.
- **A school was Conjuguer's largest source of downloads.** Of its 3,870 lifetime first-time
  downloads, 2,110 were institutional purchases, nearly all in two bursts: 1,118 in September 2024
  and 1,019 in September 2025, from Switzerland, onto Macs. No burst came in September 2026.
  Conjuguer's other downloads are rising, at 383 so far in 2026 against about 259 in 2025.
- **Conjugar's arrivals fell for years, and its conversion has just risen.** First-time downloads
  peaked at 717 in 2018 and were 167 in 2025. After the 3.x releases its conversion rate rose from
  about 5% to 15.6% in September and 20.9% in October 2026.
- **Referred visitors convert far better than searchers.** For Konjugieren, 24.1% of visitors sent
  by another app downloaded, against 5.4% of those who came from search. Referrals are a small
  share of traffic, and App Store Connect does not say where they came from.

### Who the Users Are

Konjugieren's 57 real devices are set to these regions: Germany 30, the United States 19, Austria
2, Switzerland 1, Luxembourg 1, and 4 elsewhere. By device language, 16 run in German, 11 in
Russian, Turkish, French, Hungarian, or Portuguese, and nearly all the rest in English. The
snapshot reports region and language separately. Even so, 34 devices are set to German-speaking
countries or Luxembourg, and only 16 devices anywhere run in German, so at least 18 belong to
people in German-speaking countries whose phones are set to another language (**inference**). That
group is about as large as the American one.

Conjuguer's users are largely francophone: 92 of 192 devices run in French, many of them in West
and Central Africa. Conjugar's are mostly English-speaking, and 85% of its downloads are American.
What these audiences need is taken up under
[Related Questions](#related-questions-asked-and-answered).

## Assessment

### What the Quiz Gets Right

- **Typed recall.** Producing an answer from memory strengthens memory more than rereading does.
  One meta-analysis puts the advantage at g = 0.50 over restudy across 61 studies (Rowland 2014,
  **secondhand**), and recall formats appear to do at least as well as recognition formats once
  feedback is given (Kang, McDermott & Roediger 2007, **secondhand**).
- **The correct answer after an error.** In the cleanest study found, supplying the correct answer
  after an error raised retention a week later by 494% over no feedback, while telling the learner
  only "right" or "wrong" did no better than saying nothing (Pashler et al. 2005, **read**).
  Konjugieren supplies the answer.
- **No delay after a right answer.** The same study recommends moving on at once after a correct
  response, which the quiz does.
- **Principled grading across varieties.** A learner who types a correct conjugation from another
  standard variety is never marked wrong, and a two-reading verb such as hängen is asked about one
  reading with that reading's gloss. (When this was written, 44 verbs had more than one reading.
  Since the defect plan of 2026-11-10, 120 do, so the quiz asks about many more second meanings,
  each with its own gloss and auxiliary.)
- **Accuracy, not speed, is scored.** The clock is visible and does not affect the score.
- **A strong reference behind it.** Full paradigms with irregular letters highlighted, families and
  ablaut groups, an article for each conjugationgroup, and an etymology and example sentence for
  every one of the 3,572 verbs. This is what people use.

### Where It Falls Short

In order of consequence.

#### 1. It Samples the Reference, Not the Learner's Need

The corpus was built to be comprehensive, which suits a reference. The quiz inherits its
distribution, and a learner's needs are distributed nearly oppositely. All figures **observed**
from `Verbs.xml` unless noted.

- The 100 most frequent verbs carry 66.7% of the corpus's total frequency count and make up 2.8% of
  its entries. A 30-question quiz is expected to contain 0.84 of them.
- The ten most frequent verbs (sein, werden, haben, können, geben, müssen, sollen, kommen, machen,
  gehen) carry 41.7% of the frequency count. The chance that a quiz contains even one of them is
  8.1%.
- 3,084 of the 3,572 verbs (86.3%) carry a prefix. A prefixed verb conjugates like its base, so
  drawing hinunterhalten in place of halten adds unfamiliar vocabulary without adding anything to
  learn about conjugation, apart from prefix behavior.
- At Regular, a quarter of the 27 drawn questions are Futur Indikativ. The infinitive is on screen,
  so each tests only the six Präsens Indikativ conjugations of werden. Curricula place the Futur late,
  at B1 in the one complete progression found (ALP Dillingen 2022, **read**), and one study of
  spoken German found future time expressed with the Futur in 4.6% of cases and with the Präsens in
  76.0% (Brons-Albert 1982, **secondhand**, quoted through Wikipedia).
- The Präteritum of sein, haben, and the modal verbs is beginner material in that progression, and
  modals and auxiliaries make up about 60% of Präteritum occurrences in speech (Sieberg 2003,
  **read**). The quiz offers no Präteritum at all at Regular.
- At Ridiculous, Futur Konjunktiv I and Plusquamperfekt Indikativ each appear as often as Präsens
  Indikativ. Futur II, which the app does not quiz, gives a sense of scale for the rare end: 0.06%
  of 59,000 counted verb occurrences in one corpus of drama (Latzel 2004, **secondhand**).
- All persons are equally likely. No corpus figures for person frequency were located, so the
  claim that ihr deserves less than a sixth of the questions is a judgment (**inference**).

The names of the conjugationgroups add a trap of their own. "Futur Konjunktiv II" sounds like the
most exotic item on the list. It is the everyday würde construction (ich würde gern ...), which the
same progression introduces at A2. "Plusquamperfekt Konjunktiv II" is the hätte and wäre
construction of unreal wishes (Hätte ich doch mehr gelernt!), listed at B1. Meanwhile the
plain-sounding "Präsens Konjunktiv I" is the one largely confined to reported speech in formal
writing. Ordering by name misleads, and ordering by use does not (**inference** from the
progression and the app's own articles).

#### 2. Nothing Is Ever Practiced Twice

A given verb has a 0.84% chance of appearing in a given quiz, and a given verb in a given
conjugationgroup and person far less. A missed question is gone. The research on durable learning
points the other way.

- The best-developed prescription is to practice each item until it has been recalled correctly
  three times in the first session, and then to relearn it in three later sessions at wide
  intervals (Rawson & Dunlosky 2011, **read** as abstract). Relearning sessions mattered more than
  a higher first-session criterion, and they become quick. The studies used definitions, not
  conjugations.
- Re-asking items that were missed is where repetition within a session pays most (Pyc & Rawson
  2007, **read** as abstract).
- After an item has been recalled once, further testing of it produces a large gain in delayed
  recall and further study of it produces none (Karpicke & Roediger 2008, **read** as abstract).
- Retrieval practice benefits mainly what is retrieved. A meta-analysis found moderate transfer
  overall (d = 0.40) and the weakest transfer to material that was studied and never tested (Pan &
  Rickard 2018, **read** as abstract).
- Spacing practice over time is one of the most robust findings in the field, and for second
  languages a meta-analysis reports a medium-to-large advantage (Kim & Webb 2022, **secondhand**).

A distinction matters here. For weak verbs, the thing being learned is a pattern, and a pattern is
exercised by every weak verb. Variety of verbs is harmless there and may help. For a strong verb,
the thing being learned is that verb's own vowel changes, and only repeated retrieval of that verb
will fix them. Uniform sampling over 3,572 verbs cannot deliver that repetition (**inference**,
consistent with the usage-based account of morphology, which was reached only at **secondhand**
strength).

#### 3. Feedback Arrives at the Wrong Moment and Says Too Little

`Quiz.submitAnswer` advances to the next question before the view redraws. The learner therefore
sees the correction for question n on a card that describes question n + 1, with the pronoun and
conjugationgroup of the missed question no longer visible, while the clock runs.

- The study that established the value of correct-answer feedback displayed it alone for five
  seconds and advises giving "time to process the feedback" after an error (Pashler et al. 2005,
  **read**). No study was found that tests a correction shown beside the next question. That the
  arrangement weakens the correction is likely and unproven (**inference**).
- Feedback that explains the error outperforms feedback that only supplies the answer: g = 0.49 for
  elaborated feedback, 0.32 for the correct answer, and 0.05 for right-or-wrong alone, across 40
  studies of computer-based learning (Van der Kleij, Feskens & Eggen 2015, **secondhand**).
- In Trude Heift's studies of a German tutoring system, learners attended to error-specific
  feedback on 79.5% of 4,405 submitted sentences, 85% of students tried to correct their own errors
  when prompted, and feedback that both explained the error and highlighted it drew the most
  correction (Heift 2001, 2002, 2004, **read** as abstracts). Whether that last advantage was
  statistically significant is unresolved.
- The red letters in Konjugieren's correct answer mark what is irregular about the verb. They do
  not mark where the learner's answer went wrong. In question 1 above, the error was the ending
  (-n for -t), and the red letter was the e before it.

The automatic AI explanation of errors was switched off because the on-device model invented
grammar rules. That decision is supported: prompted directly, GPT-4 found only 60.2% of the true
errors in German learner text and explained 67.5% of those correctly (Song et al. 2023, **read**).
The same study shows the way back. When a separate step first established exactly what had
changed, two German teachers judged 93.9% of 1,986 explanations fully correct, and 12 of the 15
invented errors traced to mistakes in that first step. Konjugieren's conjugator can supply those
facts with certainty.

#### 4. It Marks Correct German Wrong

These are defects of grading, independent of any pedagogical view. Each one both corrupts the
score and teaches the learner that a right answer is wrong.

| Case | Status | Detail |
|---|---|---|
| Main-clause conjugation of a separable verb | **observed** in the simulator | For `hinunterhalten / wir / Präsens Indikativ`, the quiz rejects `halten hinunter` and expects `hinunterhalten`. The conjugator returns the joined conjugation, the one used in subordinate clauses, for every finite conjugationgroup except the Imperativ, which it splits (`zieh hin`). The app's own Präsens Indikativ article teaches the split: "ich komme ... an". Separable verbs are 61.4% of the corpus, so a Regular quiz expects about four such questions, and a Ridiculous quiz five or six. |
| Answer that includes the pronoun | **observed** in the simulator | `ihr habt ferngeguckt` is rejected. The prompt displays "Pronoun: ihr" and does not say to leave it out. |
| Imperativ answers that need the pronoun | **observed** in the simulator | The wir and Sie Imperativ answers include the pronoun (`steigen wir nach`, `stoßen Sie um`), the reverse of every other conjugationgroup. |
| Umlaut written as a digraph | **observed** in the simulator | `uebernehme` is rejected. `ss` for `ß` is accepted, as a side effect of accepting the Swiss variety. Learners without a German keyboard must find the long-press. |
| Alternative standard conjugations | **inference** from the code, not tested | The conjugator yields one du-Imperativ per verb (`zieh hin`). Standard German also accepts the conjugation with -e for most verbs (`ziehe hin`) (**background**). Only regional variants are added to the accepted set, so the alternative is presumably rejected. Other optional variants deserve the same audit. |
| Near misses | **observed** in the code | Any typing slip is a full error. There is no "almost" state. |

**A further source, in the verb data, fixed on 2026-11-10.** The rows above are defects of the
grader. When this report was written, the reference the quiz draws on also held errors, and the
quiz inherited every one: about 130 verbs had the wrong auxiliary or lacked a reading
(aufstehen "get up" with haben), three lost their prefix in some conjugations (bedürfen gave ich
darf), and backen, hauen, and salzen generated weak participles (gebackt). A Perfekt question on
aufstehen therefore expected *habe aufgestanden* and rejected the right answer. The browse and
verb research found these, and
[`plans/fix-reference-defects.md`](../plans/fix-reference-defects.md) fixed them on `main` the
same day. They reach learners with the next release. Nothing in this table was touched by that
work.

The first row deserves a decision more than a patch. Showing the joined conjugation in a reference
table is a reasonable convention, because a table has no clause to put a split verb in. As the only
accepted answer in a quiz that supplies no clause, it penalizes the conjugation that learners are
taught first and that the app's articles teach. Among the 100 most frequent verbs none is
separable, so this defect grows with exactly the rare-verb sampling described above.

#### 5. The Question Carries No Meaning

The prompt maps labels to a conjugation. A learner can answer without knowing what the verb means,
what the conjugationgroup is for, or when a German speaker would use it. This is the exercise type
at the center of a long debate, summarized under [The Debate over Drills](#the-debate-over-drills).
In short: critics and defenders agree that practice which never links a conjugation to a meaning is
the weak kind, and they disagree about whether it has any role. Its strongest defender grants it a
role only as an early step that should be left "as soon as possible" (DeKeyser 2010, **read**).

Two practical consequences follow. The quiz never asks a learner to choose a conjugationgroup, and
choosing (Perfekt or Präteritum, a one-word Konjunktiv II or würde) is where much real difficulty
lies. And the default prompt presumes the metalanguage. A beginner who does not yet know what
"Präsens Indikativ" names cannot begin, and the coined word "Conjugationgroup" in the prompt's
label is unfamiliar by design.

#### 6. The Session Is Shaped Like an Exam

Thirty typed questions, a clock, a score, a global ranking, and a results sheet describe a test.
The onboarding page for the quiz is titled "Test Your Knowledge", and its text speaks of timed
quizzes, points, and competing on the leaderboard. A test measures. It suits someone who already
knows the material and wants to prove it, and that is not who opens a conjugation app.

- The blank Quiz tab gives no reason to begin and no thread to earlier effort: no description, no
  length, no level, no last result.
- The first quiz of a newcomer is likely to go badly, because of sampling and grading both. In the
  played session, three answers that a competent writer of German might give (the pronoun
  included, ue for ü, the split conjugation of a separable verb) were each marked wrong.
- Leaving costs everything, since nothing is kept, and it is accompanied by a sad trombone.
- Rankings tend to motivate those near the top and discourage those near the bottom, and
  comparisons with one's own past do better for weaker performers (several studies, **secondhand**,
  mostly working papers). In one semester-long classroom study, the section with a leaderboard and
  badges ended less motivated and scored lower on the final examination (Hanus & Fox 2015,
  **secondhand**).
- The difficulty names frame the choice as normal versus a joke. There is no easy setting. Conjugar
  has one, and it is where nearly all completed quizzes occur.

#### 7. The Engagement Features Sit Apart from the Learning

The arcade game contains no conjugation. The daily widget question is a reasonable touchpoint and
connects to nothing. The leaderboard records a number whose meaning changes with the luck of the
draw. None of these accumulates into a sense of getting better at German verbs, which is the only
engagement that also serves the primary goal.

### The Size of the Thing to Be Learned

The corpus holds 3,572 verbs with 72 conjugations each: 257,184 conjugations. A learner does not
face that number, because nearly all of it is derivable. All counts **observed** from `Verbs.xml`.

- Only 488 verbs are unprefixed, and they carry 73.9% of the corpus's frequency count.
- Of those 488, 250 are weak and 82 end in -ieren. One set of endings and a handful of spelling
  rules covers all of them.
- 156 are strong or mixed. These are the verbs with something individual to learn, and the app
  already sorts them into 73 ablaut groups.
- Add the conjugations of sein, haben, and werden, the modal verbs, the choice between haben and
  sein, and the behavior of separable and inseparable prefixes.

The whole table follows from a few hundred facts. The traditional name for the facts about a single
strong verb is its Stammformen, or principal parts, and the Goethe-Institut's B1 word list prints
them for every irregular verb in exactly that way: "abfahren, fährt ab, fuhr ab, ist abgefahren"
(**read**). Irregularity is also concentrated where frequency is: 35 of the 50 most frequent verbs
and 56 of the 100 most frequent are strong or mixed.

A quiz that samples the table uniformly spends most of its questions on derivable cells of rare
verbs. A quiz that samples the facts, weighted by frequency, would spend them on what there is to
learn. This reframing is the single most useful idea in this document (**inference**).

## What the Research Says

### Principles and Their Support

| # | Principle | Best evidence found | Strength |
|---:|---|---|---|
| 1 | Retrieve, do not reread. | Testing beats restudy, g = 0.50 across 61 studies (Rowland 2014). Practice testing and distributed practice were the two techniques rated most useful in a review of ten (Dunlosky et al. 2013). | **secondhand**; evidence is on facts and vocabulary |
| 2 | Supply the correct answer after an error, and allow time for it. | +494% retention at one week over no feedback; right-or-wrong alone no better than nothing; little effect of feedback after correct answers (Pashler et al. 2005). | **read** |
| 3 | Say what kind of error it was. | Elaborated 0.49, correct answer 0.32, right-or-wrong 0.05 (Van der Kleij et al. 2015). Heift's German tutor studies on uptake. | **secondhand** and **read** as abstracts |
| 4 | Practice each item to a criterion, then relearn it on later days. | Three correct recalls, then three spaced relearning sessions (Rawson & Dunlosky 2011). In a course, over 60% recalled 24 days after the examination, against under 20% for material students learned on their own (Dunlosky et al. 2023, the authors' guide). | **read** as abstract and guide; material was definitions |
| 5 | Space practice over time. | Medium-to-large advantage in second-language learning (Kim & Webb 2022). Spacing beat massing for 90% of participants in one study (Kornell 2009). | **secondhand** and **read** as abstract |
| 6 | Teach and practice a pattern alone first, then mix. | Mixing two Spanish past tenses from the start trended worse than blocking (d = 0.42 favoring blocking, p = .057). Mixing after a blocked introduction, across two weekly sessions, was better (d = 0.53 and 0.79) (Pan et al. 2019). | **read** in full |
| 7 | Performance during practice misleads. | In the same study the blocked group did better during practice and worse a week later. | **read** in full |
| 8 | Learners misjudge what helps them. | 78% did better with spaced presentation, and 78% judged massed presentation as good or better (Kornell & Bjork 2008). 90% and 72% in Kornell 2009. Only showing learners their own results on both schedules side by side changed a majority's view (Yan, Bjork & Bjork 2016). | **read** |
| 9 | Order material by what learners can acquire. | German verb morphology was acquired in a fixed order regardless of the syllabus: agreement, then modal plus infinitive, then Perfekt, then Präteritum, then the rest "without too much difficulty" (Diehl 1999, the Geneva DiGS project, about 220 learners). | **read** |
| 10 | Tie conjugations to meaning. | Agreed by both sides of the drill debate (below). Practice that resembles real use transfers better in principle (transfer-appropriate processing, reviewed in Nikouee & Oba 2025). | **read** for the debate; no direct experiment found |
| 11 | Practice in the direction that will be needed. | Comprehension practice and production practice developed separately in an eight-week study of 61 learners (DeKeyser 1997). Production practice was better on delayed tests of production (Shintani, Li & Ellis 2013). | **secondhand** |
| 12 | Explain with facts from a deterministic source. | 93.9% of explanations correct when a separate step supplied the edits, against roughly two in five errors both found and correctly explained by direct prompting (Song et al. 2023). | **read** in full |
| 13 | Give learners control of scope. | Every well-regarded dedicated trainer examined lets the learner choose conjugationgroups and verb sets. Praise in reviews centers on this, and complaints center on forced order. | **read** on store pages; anecdote for the reviews |
| 14 | Prefer repairable streaks and personal progress to rankings. | An intact streak raises later engagement, and a broken one lowers it unless it can be repaired (Silverman & Barasch 2023). Duolingo reports +3.3% day-14 retention from separating the streak from the daily goal. | **secondhand** and **vendor** |

### The Debate over Drills

Josh's own doubt about his method has a formal counterpart in the literature, and it is worth
stating both sides accurately, because the debate is often summarized as "drills are bad" and that
is not what either side says.

Wong and VanPatten (2003, **read**) argued that mechanical drills, defined narrowly as exercises
that can be completed without attending to meaning, "are not necessary or beneficial for foreign
language acquisition" and are "at best a waste of time" for building the ability to communicate.
They exempted meaningful and communicative drills explicitly, and they did not oppose teaching
grammar. Their evidence was two classroom studies from 1972 and 1983 and a series of experiments in
which an input-based method without drills equaled or beat traditional instruction. Konjugieren's
question, as it stands, is a mechanical drill in their sense.

The reply came from teachers of Russian and from Robert DeKeyser. Leaver, Rifkin and Shekhtman
(2004, **read**) argued from the experience of intensive programs that drilling builds accuracy and
automaticity, and the drills they held up as good were meaningful ones. DeKeyser (2010, **read**)
agreed with the critics that audiolingual drills are "of limited use because they do not teach the
students to engage in the target behavior of conceptualizing a meaning and expressing it through
linguistic means". What he defended was practice more broadly: systematic, deliberate, ordered
from knowing a rule to using it fluently, and linked to meaning.

Three points of agreement can be built on:

- Practice with no link to meaning is the weak kind.
- Some deliberate work on conjugations has a place. Paul Nation, whose framework is widely used in
  course design, counts drills within "language-focused learning" and holds that this strand
  "should not make up more than one-quarter of the time spent on the whole course" (Nation 2007,
  **read**). The figure is a designer's rule of thumb, not an experimental result.
- A conjugation trainer is therefore a supplement by nature. It can do its quarter well. It cannot
  be the course.

The input-based alternative, called processing instruction, has a design rule worth borrowing:
build exercises in which the verb ending is the only carrier of the meaning being asked about, so
the learner must attend to it (VanPatten, **read** in a 2000 chapter). Its evidence is strongest
for comprehension. For production, practice that involves producing does as well or better
(Shintani 2015, **secondhand**).

No study was found that compares isolated conjugation drills with sentence-based practice on a
later test of free production. The gap cuts both ways. Nothing shows that Konjugieren's kind of
question fails to transfer, and nothing shows that it succeeds.

### What Competing Tools Do

From store pages and the tools' own sites (**read**), with ratings as of November 2026.

| Tool | Language | What is distinctive |
|---|---|---|
| ConjuGato | Spanish | Rated 4.9 from 4,300 ratings. Answer by typing, or say it aloud and reveal. Spaced repetition. Filters by irregularity, ending, and popularity. Free tier of 250 verbs in three tenses. |
| Ella Verbs | Spanish | Rated 4.9. Fifty levels tracked against the CEFR. Typing, multiple choice, listening, and sentences in context. Spaced-repetition quizzes aimed at weak spots in the paid tier. Reviewers complain of being locked into its order. |
| Conjuguemos | Several, including German | Web-based. Filters by tense and by verb type. Built around teachers: custom lists, grading, class reports. |
| Linguno | Several, including German | Conjugations practiced inside sentences with audio. Claims spaced repetition and tracking of mistakes. |
| Kwiziq | French, Spanish | Begins with multiple choice and moves a learner to free typing once answers are consistently right. |
| Verben | German | Self-graded reveal. Filters for 16 tenses, persons, and regular or irregular. Explicitly no games or streaks. About 500 verbs. One rating. |
| Conjuu | German | About 500 verbs. Says that it "intelligently tests you on the verbs you need to practise the most". Rated 4.6 from 59 ratings. |

Three patterns stand out. Choice of scope is nearly universal among real trainers, and Konjugieren
offers none. Memory across sessions, sentence context, and explanation of errors are rare, found
together only in the leading Spanish apps. And the German field on iOS is thin: small corpora and
few ratings, beside Spanish apps with thousands. Konjugieren's corpus is about seven times the size
of the practice corpora in the two German trainers described above, with an etymology and an
example for every verb. That is a real
distinction for the reference. For practice, the comparison suggests that learners want a few
hundred verbs done well.

### What Could Not Be Established

Stated plainly, so that no suggestion below is mistaken for settled science:

- Whether any particular spacing interval is best for conjugation practice. The studies of grammar
  conflict: longer gaps helped on tests of judgment, and shorter or equal gaps did as well on tests
  of production (reviewed by Serrano 2022, **read**). A game-based study of French verb endings with 113 children found minimal
  difference between gaps of 3.5 and 7 days (Kasprowicz, Marsden & Sephton 2019, **read**).
- Whether teaching strong verbs in vowel-pattern families helps. The tradition is strong and the
  theory is friendly. No controlled study with adult learners was found. The seven historical
  classes are also not the modern picture: two analyses count 39 and 42 patterns in today's German
  (**secondhand**), close to the app's 73 finer-grained groups.
- Whether a hard first session causes people to leave. Early performance predicts dropout in
  online courses. No experiment was found.
- Whether a visible clock raises anxiety in language practice. Anxiety and achievement correlate
  negatively (r = -.36 across 105 samples, Teimouri et al. 2019, **secondhand**). No study of
  timers in conjugation practice was found.
- Whether progress displays, widgets, or Live Activities improve persistence in learning apps. No
  usable evidence was found. The one widget figure located was an uncontrolled vendor report.
- The frequency of each German conjugationgroup and person in corpora. The often-quoted table of
  shares could not be traced to a source and is omitted here.
- How small language utilities are discovered. The literature search found nothing usable on App
  Store search, ratings, editorial featuring, or adoption by teachers. The apps' own App Store
  Connect figures, summarized under [How People Arrive](#how-people-arrive), are the best
  evidence available.

## Suggestions

These are ideas to analyze and iterate on. Effort is a rough guess: S for hours to a day, M for
several days, L for weeks. "Basis" names the principle from the table above, or says when a
suggestion rests on judgment.

### Tier 1: Stop Marking Correct German Wrong

| Suggestion | Basis | Effort | Verdict |
|---|---|---|---|
| Decide the separable-verb convention on purpose, then make the quiz, the verb page, and the articles agree. The least disruptive choice is to accept both the split and the joined conjugation in the quiz. | Correctness | S | Yes, accept both. |
| Show the shape of the expected answer. A frame such as `ihr ______` with the pronoun fixed outside the field, or `______ Sie ______!` for a Sie-Imperativ of a separable verb, settles the pronoun question and the word-order question together. | Correctness; 10 | M | Yes. |
| Strip a leading pronoun from the answer before grading. | Correctness | S | Yes. |
| Accept ae, oe, ue, and ss, and add ä, ö, ü, and ß keys above the keyboard. Consider showing the proper spelling when a digraph is accepted. | Correctness | S | Yes. The umlaut keys have been implemente. |
| Audit optional variants (the du-Imperativ with and without -e first) and accept every standard one. | Correctness | S to M | Yes. |
| Treat a one-letter slip as "almost" and allow one more attempt. How lenient to be is a judgment. No evidence on thresholds was found. | Judgment | M | Yes. But if the player gets the second attempt right, half points. |

**Built on `main` 2026-11-12** by [Phase 4](browse-and-verb-implementation.md#phase-4-separable-verbs-as-a-main-clause-writes-them)
of the browse plan: the separable-verb convention, as decision 1 has it. The verb page, the
widget, the shortcut, and the quiz's shown answer use the split conjugation (ich stehe auf), and
the quiz accepts the split and the joined conjugation alike. Grading moved into
`QuizItem.accepts`, which also collapses runs of spaces now that an answer can be two words. It
does not accept the subordinate order of a compound conjugation (angekommen bin). The Info
articles already taught the split order and needed no change.

**Partly built 2026-11-12** by [Phase 1](browse-and-verb-implementation.md#phase-1-search-finds-what-people-type):
the ä, ö, ü, and ß keys, as `GermanLetterKeyRow`, shown above the keyboard while the verb list's
search field is focused. The row takes an `insert` closure so that the quiz's answer field can
insert at the cursor, but as of 2026-11-13 the answer field does not show it. The quiz accepts ss
for ß, because it grades against every region's conjugation and Swiss spelling has no ß. It does
not accept ae, oe, or ue. Search folds all four digraphs (`VerbSearch`), and its folding is the
piece for the quiz to reuse.

**Built on `main` 2026-11-13** by [Phase 1](pedagogy-implementation.md#phase-1-accept-what-is-right)
of the pedagogy plan: stripping a leading pronoun, the digraphs, and the audit of optional
variants. The quiz ignores a leading pronoun of the asked person (`ihr habt ferngeguckt`) and
accepts ae, oe, and ue for ä, ö, and ü (`uebernehme`), showing the umlaut spelling quietly beside
a checkmark. It did not reuse search's folding after all, which reads fahrt as fährt: grading
expands each umlaut into its digraph instead, so a missing umlaut stays wrong. The answer field
shows the letter keys. The audit, [`pedagogy-phase1-variant-audit.md`](pedagogy-phase1-variant-audit.md),
checked Wiktionary's alternatives against Duden, and the quiz now accepts the variants Josh ruled
standard (komme, sammle, kämst, stünde, sandte, and others) while the verb page keeps the
conjugator's. The audit also found and fixed two wrong verbs, scheiden and vergleichen.

**Built on `main` 2026-11-13** by [Phase 2](pedagogy-implementation.md#phase-2-the-shape-of-the-answer)
of the pedagogy plan: the shape of the expected answer. The field sits inside a frame that
replaced the Pronoun row: `ihr [ ]` for a finite cell, `(du) [ ] !` for the du Imperativ, `[ ] Sie!`
for the Sie Imperativ, and `[ ] Sie [ ] !` with two fields when the verb is separable. A
participle is a bare field. A separable Präsens stays one field, so the joined ankommt is as easy
to type as kommt an. Return fills the next empty field before it submits.

### Tier 2: Change What the Quiz Asks

| Suggestion | Basis | Effort | Verdict |
|---|---|---|---|
| Draw from frequency bands and default to the core. The `hi` counts already exist. Bands of 100, 300, and 1,000 verbs, with the whole corpus as an explicit choice, would do. Note that 83 verbs still carry placeholder counts. | 9; observed sampling | S | Yes, top 300. |
| Prefer base verbs. Draw unprefixed verbs and frequent derivatives, and use rare derivatives sparingly, to practice prefix behavior. | The size argument | S | Yes. Every quiz should have one to three derivative verbs. |
| Replace the two difficulties with levels ordered by use. A sketch follows this table. | 9 | M | Yes. |
| Weight within a level. Give a newly opened conjugationgroup most of the questions at first, then fold it into the mix. | 6 | M | No. Which conjugationgroups have been opened should not impact quizzes. |
| Guarantee a mix. Fix the share of strong and weak verbs per session, as Conjugar's Easy quiz fixes regular and irregular, and make sure sein, haben, werden, and the modals recur. | 4; Conjugar's results | S | Yes. |
| Thin the Futur and other conjugationgroups whose only variable part is an auxiliary. | Observed sampling | S | Yes. |
| Shorten the default session to about ten questions, with an offer to continue. | Telemetry; Conjugar's precedent | S | Reluctantly, yes. I am reluctant because a ten-question quiz is far from comprehensive. But perhaps a shorter quiz will encourage more people to take and finish quizzes. Barely any do now. |
| Let the learner choose scope: conjugationgroups, verb sets, a family or ablaut group, "my verbs". | 13 | M | Yes, but the default is the classic-style quiz (with modifications from the plan.) "My verbs" an option if such verbs exist. |
| Make a chosen scope shareable as a link or a QR code, so that a teacher can hand a class one practice set without accounts or a server. The deeplink scheme already has a quiz route. | 13; Conjuguer's school downloads | M | Yes. |

**Partly built 2026-11-13** by the browse plan. [Phase 14](browse-and-verb-implementation.md#phase-14-a-verb-of-the-day-worth-opening)
defined the frequency bands once, as `FrequencyBand` (`.top100`, `.top300`, `.top1000`) with
`Verb.isIn(_:)` and `Verb.verbs(in:)`. The widget's verb and the random verb draw from the top
1,000, weighting strong and unprefixed verbs double, which is a start on "prefer base verbs"
outside the quiz. The quiz does not draw from the bands yet.
[Phase 13](browse-and-verb-implementation.md#phase-13-a-quiz-over-chosen-verbs) built the scope:
`QuizScope` carries a list of verbs, a reading, a question count, and an analytics source. The
Quiz tab offers All Verbs or My Verbs, with the classic quiz as the default, as the verdict asks.
[Phase 16](browse-and-verb-implementation.md#phase-16-collections) added a 30-question quiz over
each collection: the 100 most frequent verbs, the modal verbs, the verbs that take sein, and each
of the 76 ablaut groups. A collection can be shared as a `konjugieren://list/<key>` link, which
opens it with Quiz one tap away. A link that starts the quiz itself (`quiz/start?list=<key>`) was
not built, nor were scopes by conjugationgroup. Only a full quiz over every verb posts to the
leaderboard (`QuizScope.isRanked`), as Josh decided on 2026-11-13.

A possible ladder of levels, using the app's conjugationgroup names:

| Level | Roughly | Conjugationgroups added | Verbs |
|---|---|---|---|
| 1 | A1 | Präsens Indikativ; Imperativ for du, ihr, and Sie | sein, haben, werden, the modals, and the rest of the 100 most frequent |
| 2 | A1 to A2 | Perfekt Indikativ and the Perfektpartizip; Präteritum Indikativ of sein, haben, and the modals | The 300 most frequent |
| 3 | B1 | Präteritum Indikativ of all verbs; Plusquamperfekt Indikativ; Futur Konjunktiv II (the würde construction); Präteritum Konjunktiv II of sein, haben, werden, and the modals; Plusquamperfekt Konjunktiv II; Futur Indikativ | The 1,000 most frequent |
| 4 | B2 and above | Präsens Konjunktiv I, Perfekt Konjunktiv I, Futur Konjunktiv I; Präteritum Konjunktiv II of strong verbs; Präsenspartizip | The whole corpus, by choice |

The order follows the one complete curricular progression that was read (ALP Dillingen 2022) and
the acquisition order found in the Geneva study, which agree with each other. It is one sketch. The
progression is a single document for German as a second language in schools, and official
examination specifications were not reached.

### Tier 3: Give the Quiz a Memory

| Suggestion | Basis | Effort | Verdict |
|---|---|---|---|
| Re-ask a missed question a few questions later, until it has been answered correctly once. | 4 | S to M | Partial. Re-ask wrong question once. Since quizzes default to ten questions, reasking until correct could cause one question to dominate a quiz |
| Add "Practice my mistakes". `QuizErrorHistory` already stores the last 200 errors, so the data exist today. | 4 | S | Yes. |
| Keep a small record per item: a box number and a due date. Correct answers move an item up a ladder of intervals, and errors send it back. Offer a short "Review" session of whatever is due. | 4, 5 | M to L | Yes. |
| Start the ladder short (for example 1, 3, 7, 14, and 30 days) and do not agonize over the numbers. The evidence does not single out an interval. | 5; limits above | S | Yes. |
| Track two kinds of item. For strong and mixed verbs, the item is a verb's principal part. For weak verbs, the item is a pattern (a conjugationgroup and person), shared by all weak verbs. | The size argument | M | Yes. |

**Partly built 2026-11-13** by [Phase 15](browse-and-verb-implementation.md#phase-15-the-review-card)
of the browse plan: a due date per verb, not per item. `ReviewSchedule`, in `Shared/`, holds a box
and a due date on each entry of the learner's verb record (`LearnerVerbs`), on this report's
ladder of 1, 3, 7, 14, and 30 days, the last repeating. A lookup puts a verb in the first box, a
reveal on the review card above the verb list moves it up one, and a later lookup by any other
route sends it back to the first box. Nothing in the quiz reads or writes it yet. It was built so
that the quiz's practice record can take it over. Re-asking, "Practice my mistakes", and the two
kinds of item are not built.

The card-box scheduler suggested here is the Leitner system, from Sebastian Leitner's *So lernt man
lernen* (1972), and the spacing effect it exploits was first measured by Hermann Ebbinghaus in
*Über das Gedächtnis* (1885). The two ideas most needed by a German conjugation app were both first
written down in German (**background**).

Two items in [`docs/post-release-features.md`](../docs/post-release-features.md), a mastery chart and
spaced-repetition reminders, presuppose exactly this per-item record. It is the substrate that both
are waiting for.

### Tier 4: Make Feedback Land

| Suggestion | Basis | Effort | Verdict |
|---|---|---|---|
| After a wrong answer, stay on the missed question. Show the prompt, the learner's answer, the correct answer, and a Continue button. After a right answer, advance at once, as now. | 2 | S to M | Yes. |
| Diagnose the error from the conjugator's own knowledge and say it in one templated line. Candidate classes are listed below. | 3, 12 | M to L | Yess. |
| Try a prompt before the reveal for diagnosable errors ("Check the auxiliary. Try once more."). Prompts that lead learners to repair their own errors outperformed supplied corrections in classroom research (Lyster & Saito 2010, **secondhand**), and most of Heift's learners attempted the repair. Treat it as an experiment, since that research was oral and in classrooms. | 3 | M | Yes. |
| Mark where the learner's answer differs, in addition to what is irregular about the verb. | 3 | S to M | Yes. |
| Link each correction to the verb's page and its family. | 10 | S | Yes. |
| If AI explanation returns, have the model put a deterministic diagnosis into words and nothing more. | 12 | M | Not applicable at this time. |

**Partly built 2026-11-12** by [Phase 5](browse-and-verb-implementation.md#phase-5-the-conjugation-map-as-a-build-product)
of the browse plan: `Verb.conjugations(matching:)`, in `ConjugationMatch.swift`, answers "which
conjugations of this verb equal this text?" It grades as the quiz does (every region, both
clauses, case and spacing ignored) and marks a match that is only the finite part of a separable
reading. It is the check behind "another cell of the same verb" below. Reverse lookup in search
uses it, and the quiz does not yet.

**Built on `main` 2026-11-13** by [Phase 3](pedagogy-implementation.md#phase-3-a-correction-that-stays)
of the pedagogy plan: the first, fourth, and fifth suggestions above. A wrong answer now holds on
its own question with the clock stopped, showing the learner's answer and the right one, until
Continue or Return. The letters that differ are struck through in the learner's answer and
underlined in the right one, each on a tint, so they never read as the red letters of
irregularity. Two links sit under the correction: the verb's page, opened at the missed cell, and
its ablaut group or, for a weak verb, its family. Both push over the waiting quiz. The diagnosis
and the prompt to repair remain for Phase 14.

Error classes the conjugator could detect without any language model:

- **Another cell of the same verb.** Generate the verb's full paradigm and look the learner's
  answer up in it. "That is the Präteritum. The Perfekt was asked." or "That is the wir
  conjugation." This single check probably covers a large share of real errors, and it is always
  correct.
- **A strong verb conjugated as weak**, such as gehte for ging.
- **The wrong auxiliary**, such as hat gegangen. This diagnosis is only as good as the app's
  own auxiliaries. Since 2026-11-10 every verb the auxiliary audit lists is ruled against DWDS
  (`verbdata/auxiliary-rulings.tsv`); verbs to which kaikki gives one auxiliary were not all
  read, and two such errors (bereitstehen, näherstehen) were found and fixed afterwards.
- **A participle prefix error**: ge- missing, ge- added to an inseparable or -ieren verb, or ge-
  misplaced in a separable verb.
- **A separable prefix left attached, or detached, contrary to the frame.**
- **A wrong ending on a right stem**, or the reverse.
- **A spelling slip**: one letter off, or a missing umlaut.

No published taxonomy of German verb errors by English-speaking learners was located, so the list
is drawn from the structure of the conjugator and from experience (**inference**).

### Tier 5: Add Meaning and New Directions

| Suggestion | Basis | Effort | Verdict |
|---|---|---|---|
| A principal-parts exercise for strong verbs: given the infinitive, supply the third-person Präsens, the Präteritum, and the Perfekt with its auxiliary. This is how the Goethe-Institut list presents them. | The size argument; 9 | M | Yes. |
| Family practice from the Families tab: work through one ablaut group, then mix it with groups already known. | 6; unproven for families | M | Yes. |
| "Test yourself on this verb" on the verb page: three questions at the moment of a lookup, with the option to add the verb to "my verbs". | Telemetry; 13 | M | Yes. |
| Recognition questions: show a conjugation such as käme and ask for the infinitive and the conjugationgroup. This is the direction a reader needs, and the map from conjugation to lemma built by `CorpusFormsDumpTests` already exists. | 11 | M | Yes. |
| Sentence frames for the core verbs: short authored sentences with the verb blanked. The bundled literary examples exist for every verb and are mostly too hard for a beginner's blank. They suit a reward after a correct answer better than a prompt. | 10 | L | Yes. |
| Choice questions: a context and two conjugationgroups, with the learner picking the one a speaker would use. This needs authored content. | 10 | L | Yes. |
| A speed round for items already mastered, as the one place where the clock counts. | Nation's fluency strand | M | Yes. |

**Built on `main` 2026-11-13** by [Phase 13](browse-and-verb-implementation.md#phase-13-a-quiz-over-chosen-verbs)
of the browse plan: "Test me on this verb", a button in the verb page's navigation bar that opens
a sheet of three questions on three cells of the reading on screen. The star beside it adds the
verb to My Verbs ([Phase 12](browse-and-verb-implementation.md#phase-12-recents-and-my-verbs)).

**Partly built 2026-11-13** by [Phase 16](browse-and-verb-implementation.md#phase-16-collections):
an expanded ablaut group on the Families tab offers a quiz on that group, with a count of its
verbs looked up. Mixing it with groups already known is not built. For recognition questions, the
map from conjugation to infinitive now ships in the app, generated at build time by
`ConjugationMapTool`
([Phase 5](browse-and-verb-implementation.md#phase-5-the-conjugation-map-as-a-build-product)), and
`CorpusFormsDumpTests` is retired.

### Tier 6: Rebuild Motivation Around Progress

| Suggestion | Basis | Effort | Verdict |
|---|---|---|---|
| Turn the Quiz tab into a practice hub: what a session is, how long it takes, the current level, what is due for review, and the last result. | Telemetry; judgment | M | Yes. |
| Show mastery: the core verbs against the conjugationgroups of the current level, filling in as items move up the ladder. | 14; unproven for persistence | M to L | Yes. |
| A short daily session with a streak that can be repaired, and an optional reminder at a time the learner picks. Roughly 37% of users of education apps on iOS allow notifications (**secondhand**, industry report), so the reminder cannot be the plan. | 14 | M | Yes. |
| Keep partial work. With a memory, a learner who stops after six questions has still practiced six. Retire the sad trombone. | Telemetry | S | Partial. Keep the sad trombone, as it is fun and silly. I disagree that it humiliates learners. |
| Hide the clock by default. | Judgment; limits above | S | Yes. Make a setting that defaults to clock hidden. |
| Move the leaderboard out of the main path. Offer personal bests and Game Center achievements for mastery milestones. | 14 | S to M | Yes. Josh will need help mucking with leaderboards in App Store Connect. |
| Rename the levels. "Ridiculous" tells a learner that part of the app is a joke. | Judgment | S | Yes. |
| A daily shared challenge built on the existing daily widget question, with a result that can be shared. The evidence for this format is a designer's testimony and one survey. | Speculative | M | Yes. |
| Either make the arcade game depend on conjugating, as the architecture document already says it does, or accept it as an amusement. | Judgment | L or none | In future, yes. Improving the game is outside the scope of the quiz-improvement project. |

Nothing in this tier was built by the browse plan. Its one step in this direction was to keep
quizzes over My Verbs, a collection, or a single verb off the leaderboard.

A warning about this tier. Meta-analysis finds the effects of gamification on learning small, and
its effects on motivation and behavior less stable than its effects on test scores (Sailer & Homner
2020, **secondhand**). Streaks and badges laid over the present quiz would decorate a loop that
does not work. Tiers 1 through 3 come first.

## Related Questions, Asked and Answered

**Who is using these apps, and what does each kind of user need?** Four kinds can be made out
(**inference** throughout).

- *Residents of German-speaking countries with phones in another language.* At least 18 of
  Konjugieren's 57 real devices. Their owners are most plausibly learning the language they live
  in. They meet German daily and are likely to look up verbs they have just encountered, so
  practice seeded by their own lookups fits them better than any fixed list. The one curricular
  progression read in full for this report was written for this population, learners of German as
  a second language in Germany, which supports the ladder of levels sketched above. Eleven devices
  run in Russian, Turkish, French, Hungarian, or Portuguese, and for their owners the English
  glosses are a second foreign language.
- *English-speaking learners abroad.* The audience the quiz was imagined for: 19 American devices
  in Konjugieren and most of Conjugar's users. In Konjugieren's store funnel they are the visitors
  who look and decline.
- *Speakers of the language itself.* Sixteen of Konjugieren's devices run in German, and
  Conjuguer's users are largely francophone. A French speaker does not need to learn that a verb
  has a passé simple. What such a user needs is the written language: endings that sound alike and
  are spelled differently, agreement, and the literary tenses that French schools teach
  (**background**). The German counterpart is the Präteritum of strong verbs and the Konjunktiv in
  writing. For these users the "Ridiculous" content is the useful part, and half credit for a
  missing accent rewards the very error they came to fix.
- *Schools.* One Swiss institution accounts for more than half of Conjuguer's lifetime downloads.
  A class needs what no version of the quiz offers: practice that a teacher can point at this
  week's lesson.

**Why do people leave at the first question?** The data cannot say, and four explanations are
consistent with it. The tap on Start was exploration, since the tab says nothing about what will
happen. The first question was unanswerable, an unknown verb or an unfamiliar label. Typing was a
barrier, especially without a German keyboard. Or the thirty dots and the clock announced a
commitment longer than the visit. Telling them apart needs slightly richer signals, described
under [What to Measure](#what-to-measure). The suggestions in tiers 1 and 2 address all four.

**Should answers be typed or chosen?** Typed, for the main practice. Recall is the stronger
exercise, and typing is the skill a writer needs. Choosing has two good uses: as a gentle first
step for a newcomer, in the way Kwiziq moves learners from choosing to typing, and on surfaces such
as the widget where typing is impossible.

**Should the quiz be timed and ranked?** Not by default. Speed matters once accuracy is secure, and
researchers treat falling variability in response time, more than raw speed, as the sign that a
skill has become automatic (**secondhand**). A separate speed round over mastered items would use
the clock honestly. Conjuguer's quiz shows the failure mode: its time bonus of up to 450 points
exceeds the 300 available for accuracy, so 15 right answers in two minutes outscore 25 in five, and
the clock runs while the learner reads a correction.

**Is the quiz the right centerpiece?** Probably not as a destination that people must choose to
visit. People come to look up a verb and leave within seconds. The moment of lookup is when
interest in a particular verb is highest, so the most promising place for practice is the verb page
itself, with a personal list as the bridge to later review (**inference**).

**Does more engagement mean more learning?** No, and the two can pull apart. Easy, repetitive,
blocked practice feels productive and is less effective, and learners prefer it by large majorities
even after benefiting from the alternative (principle 8). In tutoring software, students who found
ways to satisfy the system without thinking, by guessing systematically or leaning on hints, scored
substantially lower afterward than their prior knowledge predicted (Baker et al. 2004, **read**).
An app tuned only to what keeps people tapping would drift toward the easy kind. The defense is to measure learning directly, which a quiz
with a memory can do: the share of items answered correctly when they return after a week is a
retention figure in the scientific sense.

**Should strong verbs be taught by ablaut family?** It is a reasonable bet and an unproven one. The
app's Families tab and 73 ablaut groups make it cheap to try, and the principle of practicing a
pattern alone before mixing it has direct support. Expect the benefit, if any, to come from
repeated retrieval within a small set more than from the grouping itself.

**Can an AI model explain errors safely?** Only as a speaker of facts that the conjugator
establishes. The 1.0 decision to switch off free explanation is consistent with the one careful
study found. A templated line needs no model at all and cannot invent a rule.

**Will better pedagogy fix low usage?** For Konjugieren, not by itself. Its real users return about
as often as Conjugar's, and its store page converts well. What it lacks is exposure. The literature
offered nothing usable on how small language utilities are discovered, and the apps' own numbers
point at three levers that lie outside pedagogy (**inference**). The first is search, which
supplies 83% of Konjugieren's impressions. Two thirds of those impressions come from
German-speaking storefronts, so the German store listing and its keywords matter at least as much
as the English ones. The second is referral: visitors sent by another app convert four to eight
times as often as searchers in the two apps with data, and they are few. The third is
institutions: one school brought Conjuguer more downloads than every other source combined in its
five years. Pedagogy touches the third directly, because scope that a teacher can set and share
(tier 2) is what makes a practice tool usable in a class. For Conjuguer and Conjugar, with seven to
ten daily users each, better retention is also worth having for its own sake.

## Conjugar and Conjuguer

A read-only survey of both repositories found the same skeleton as Konjugieren: thirty typed
questions, no retry, no re-asking, no memory, a leaderboard. Tiers 3 through 6 apply to all three.
The differences are instructive. All **observed** in the sibling code by a researcher, with file
references in the session's notes.

**What the siblings already do better.** Both draw verbs from hand-curated lists and fix the number
of questions per tense. Conjugar's Easy quiz is ten questions in each of three tenses, five regular
and five irregular. Conjuguer's Regular quiz guarantees être, avoir, and aller once each. Both
rotate persons evenly. This is most of tier 2, done by hand, and Conjugar is the app where quizzes
get finished.

**Findings specific to Conjugar.**

- An accent error earns half credit, including where the accent distinguishes two tenses: hablo for
  habló scores 5 of 10 with no sign that the error was grammatical.
- In tú mode, the negative imperative (no hables) and regular tú imperatives are never asked,
  because every general imperative draw skips tú.
- The negative imperative must be typed with its "no", and nothing says so.
- The "regular" lists include verbs the conjugation engine classes as non-base models, among them
  buscar, leer, and romper.
- The score is scaled by difficulty and by region, so one leaderboard mixes incomparable scores,
  and the default settings cap a perfect run at 208 points.

**Findings specific to Conjuguer.**

- Speed outranks accuracy in the score, as described above.
- A half-credit answer is not corrected during the quiz. The learner who types parle for parlé sees
  a success haptic and no correct answer until the results sheet.
- A dropped circumflex earns full credit.
- The expected answer for être-verb compound tenses follows the pronoun-gender setting, which
  defaults to feminine. A learner who types suis allé for a question expecting suis allée is marked
  wrong.
- The quiz ignores the app's own data on defective verbs. It can ask for the imperative of faillir
  and for persons of falloir that do not exist. The researcher estimated that about one Regular
  quiz in five contains such a question.
- Ridiculous is the same thirty verb-and-tense pairs on every run.
- Neither sibling trims whitespace from answers.

**The Swiss institution.** More than half of Conjuguer's lifetime downloads were volume purchases
by one institution in Switzerland, installed on Macs each September in 2024 and 2025 and not in
2026. Apple does not identify the buyer. One possible cause of the absence can be checked
(**inference**). Conjuguer's minimum iOS version rose from 18.0 to 26.0 in a commit of 2026-05-30,
four weeks before the version was bumped to 2.0 (**observed** in the Conjuguer repository), and an
iPad app running on a Mac requires the corresponding macOS (**background**). A school fleet on an
older macOS could not have installed any 2.x release. App Store Connect can group downloads by
platform version, so the operating systems behind the 2024 and 2025 purchases would support or
sink this explanation. Whatever the cause, the episode shows that a school can adopt one of these
apps on a scale that no other channel has matched.

**Order of work.** Because the siblings have ten times Konjugieren's traffic, changes to the shared
session design (length, memory, feedback) would show their effect in the sibling apps' numbers long
before they could in Konjugieren's. That is an argument for trying session-level changes there
early, even though the prompt places them later (**inference**). Conjugar is a good candidate:
its conversion rate and its active devices both rose after the 3.x releases. No release of any
of the three apps is possible before 2027, so "early" now means which app is released first. See
[No Release Before 2027](#no-release-before-2027).

## What to Measure

Konjugieren's privacy policy states that the app "does not record your quiz answers, your scores,
the verbs you look up, or any text you type". Anything below that touches scores would require
revising that promise first, and nothing below needs answers, verbs, or typed text.

Within the present policy:

- Send the difficulty with `startQuiz`. Today only quits and completions carry it.
- On the next launch after a quiz was abandoned by leaving the app, report the question number
  reached. Fifteen of the 32 real starts currently end in silence.
- Report the time from start to quit in coarse bands. A quit within three seconds is exploration,
  and a quit after forty is a struggle.

**None of these three is built.** `startQuiz` still carries no difficulty. What the browse plan
added to the quiz signals instead is `source` on `startQuiz`, `quitQuiz`, and `completeQuiz`
(`tab`, `myVerbs`, `verbPage`, or `list`), built on `main` 2026-11-13 by
[Phase 13](browse-and-verb-implementation.md#phase-13-a-quiz-over-chosen-verbs), and `collection`
on `startQuiz` for a collection's quiz, by
[Phase 16](browse-and-verb-implementation.md#phase-16-collections). Without `source`, three-question
quizzes would inflate the completion rate of the 30-question quiz. The policy lines for both wait
in [`docs/privacy-policy-pending.md`](../docs/privacy-policy-pending.md).

With a revised policy, in aggregate only:

- Questions answered and questions correct per session.
- For reviewed items, the share answered correctly by interval since last seen. This is the
  measure of whether the app teaches.

Four cautions. With 57 real devices in eight months, Konjugieren cannot support a controlled
experiment, so judge changes by the shape of the funnel before and after. Exclude the one-day
UTC+8 devices from every such comparison. They supplied 13 of the 45 quiz starts on record, enough
to hide or to fake a real change. Konjugieren's heaviest user holds a third of its sessions and
may be Josh's own phone. And a rise in sessions is not a rise in learning, for the reasons given
above.

A fifth caution was added the same day. None of these signals can ship before 2027, so the
funnel "before" is every month until then, measured with the signals that exist now.

## Decisions for Josh

1. **Separable verbs.** Should the app's standard conjugation be the joined one, the split one, or
   both, and should the quiz accept both? Answer: both. Built on `main` 2026-11-12 by
   [Phase 4](browse-and-verb-implementation.md#phase-4-separable-verbs-as-a-main-clause-writes-them)
   of the browse plan: the app shows the split conjugation, and the quiz accepts either.
2. **Purpose of the quiz.** Is it an examination to be passed or practice to be accumulated? Most
   suggestions here assume practice. Answer: practice.
3. **Primary audience.** Residents of German-speaking countries, English-speaking learners abroad,
   native speakers, or schools? The answer sets the default level, the prompt language, and how
   much weight "my verbs" deserves. The usage data favor the first group. Answer: serve both.
4. **The leaderboard.** Keep it in the main path, move it aside, or re-scope it by level? Answer: re-scope by level.
5. **Privacy policy.** Is aggregate accuracy worth a revision? Answer: no.
6. **Where to try things first.** Konjugieren, where the code is freshest, or a sibling, where the
   numbers would speak sooner? With no release before 2027, this is now a question of which app
   is released first. Answer: Konjugieren.
7. **The game.** Tie it to conjugation or leave it as play? Answer: leave for now. A future project might make the game conjugation-focused.
8. **Schools.** Is the classroom a channel to design for? Shareable practice sets are the smallest
   step toward it. Answer: yes, that is one channel, and shareable practice sets could be helpful.
9. **Conjuguer's minimum OS.** Is it worth checking whether the move to iOS 26 shut out the Swiss
   institution, and lowering the minimum if it did? The check needs no release. Lowering the
   minimum does, and the institution's installs came each September. Answer: no. I don't want to worry about whether certain OS or SwiftUI features are available. I'll leave the minimum version at 26 for now, not increasing to 27.
10. **Store category.** Konjugieren is listed under Education and its siblings under Reference,
    while people use all three as references. Whether the category affects discovery is unknown. Answer: given the better download numbers of Conjuguer and Conjugar, the plan should include changing Konjugieren's category to reference. That said, this likely isn't a big lever.

## Limits of This Research

- **Depth of reading.** Each research pass was short, and publisher paywalls blocked most primary
  articles. Of the sources cited, a minority were read in full: Pashler et al. 2005, Kornell &
  Bjork 2008, Pan et al. 2019, Kasprowicz et al. 2019, Wong & VanPatten 2003 and the replies,
  DeKeyser 2010, Nation 2007, Diehl 1999, Sieberg 2003, Song et al. 2023, Baker et al. 2004, and
  the curricular documents. The labels in the text mark the rest.
- **Distance from the question.** No controlled study of a conjugation app was found. The nearest
  are Pan et al. on Spanish verb endings, Kasprowicz et al. on French verb endings in a game, and
  Heift's German tutor.
- **One played session.** The simulator session illustrates and does not estimate. The expected
  values come from the corpus and the code.
- **Small numbers.** Konjugieren's telemetry covers 57 real devices and 32 quiz starts. The
  cross-app comparison confounds design with audience.
- **Frequency data.** Verb frequencies are the corpus's own DWDS counts. No published figure for
  how much German text the top verbs cover was located, and none for person or conjugationgroup
  frequency.
- **French and Spanish.** Official level placements could not be reached (the Instituto Cervantes
  site was down for maintenance, and the French inventory blocked automated access). Level ladders
  for the siblings should be drawn from those sources when they are available. Two university
  syllabi for Spanish and one for French were read and broadly agree with common practice.
- **Competitors.** Described from their own store pages and sites. None was used hands-on.
- **Not attempted.** Interviews with learners or teachers. The App Store Connect figures are taken
  from the usage snapshot and were not re-derived.

The raw research notes, fourteen files with per-claim source links, are in the session scratchpad
and are not part of the repository.

## Sources

Grouped by topic. The label after each entry shows how it was verified.

**Retrieval, feedback, and relearning**

- Rowland, C. A. (2014). The effect of testing versus restudy on retention: A meta-analytic review of the testing effect. *Psychological Bulletin*, 140(6), 1432-1463. secondhand
- Dunlosky, J., Rawson, K. A., Marsh, E. J., Nathan, M. J., & Willingham, D. T. (2013). Improving students' learning with effective learning techniques. *Psychological Science in the Public Interest*, 14(1), 4-58. secondhand
- Pashler, H., Cepeda, N. J., Wixted, J. T., & Rohrer, D. (2005). When does feedback facilitate learning of words? *Journal of Experimental Psychology: Learning, Memory, and Cognition*, 31(1), 3-8. <https://www.yorku.ca/ncepeda/publications/PCWR2005.pdf>. read
- Kang, S. H. K., McDermott, K. B., & Roediger, H. L. (2007). Test format and corrective feedback modify the effect of testing on long-term retention. *European Journal of Cognitive Psychology*, 19(4-5), 528-558. secondhand
- Karpicke, J. D., & Roediger, H. L. (2008). The critical importance of retrieval for learning. *Science*, 319, 966-968. <https://doi.org/10.1126/science.1152408>. read (abstract)
- Pyc, M. A., & Rawson, K. A. (2007). Examining the efficiency of schedules of distributed retrieval practice. *Memory & Cognition*, 35. <https://doi.org/10.3758/bf03192925>. read (abstract)
- Rawson, K. A., & Dunlosky, J. (2011). Optimizing schedules of retrieval practice for durable and efficient learning: How much is enough? *Journal of Experimental Psychology: General*, 140(3). <https://doi.org/10.1037/a0023956>. read (abstract)
- Dunlosky, J., Greve, M., Badali, S., Wissman, K. T., & Rawson, K. A. (2023). Successive relearning: An introduction and guide for educators. <https://www.unh.edu/teaching-learning-resource-hub/sites/default/files/media/2023-06/itow-successive-relearning-dunlosky-greve-badali-wissman-rawson.pdf>. read
- Pan, S. C., & Rickard, T. C. (2018). Transfer of test-enhanced learning: Meta-analytic review and synthesis. *Psychological Bulletin*, 144(7). <https://doi.org/10.1037/bul0000151>. read (abstract)
- Van der Kleij, F. M., Feskens, R. C. W., & Eggen, T. J. H. M. (2015). Effects of feedback in a computer-based learning environment on students' learning outcomes: A meta-analysis. *Review of Educational Research*, 85(4), 475-511. <https://doi.org/10.3102/0034654314564881>. secondhand

**Spacing, interleaving, and learners' judgments**

- Kim, S. K., & Webb, S. (2022). The effects of spaced practice on second language learning: A meta-analysis. *Language Learning*, 72(1), 269-319. <https://doi.org/10.1111/lang.12479>. secondhand
- Serrano (2022). A review of research on the distribution of practice in second-language learning, in *Studies in Second Language Learning and Teaching* (exact title not recorded). <https://pressto.amu.edu.pl/index.php/ssllt/article/download/35602/30649/76142>. read. The source for the grammar-spacing studies by Bird (2010), Rogers (2015), Suzuki & DeKeyser (2017), and Suzuki (2017).
- Kasprowicz, R. E., Marsden, E., & Sephton, N. (2019). Investigating distribution of practice effects for the learning of foreign language verb morphology in the young learner classroom. *Modern Language Journal*, 103(3), 580-606. <https://eprints.whiterose.ac.uk/141710/14/KASPROWICZ_et_al_2019_The_Modern_Language_Journal.pdf>. read
- Pan, S. C., Tajran, J., Lovelett, J., Osuna, J., & Rickard, T. C. (2019). Does interleaved practice enhance foreign language learning? The effects of training schedule on Spanish verb conjugation skills. *Journal of Educational Psychology*, 111(7), 1172-1188. <https://sc-pan.github.io/pdf/PTLOR_2019W.pdf>. read
- Kornell, N., & Bjork, R. A. (2008). Learning concepts and categories: Is spacing the "enemy of induction"? *Psychological Science*, 19(6), 585-592. read
- Kornell, N. (2009). Optimising learning using flashcards: Spacing is more effective than cramming. *Applied Cognitive Psychology*, 23(9), 1297-1317. <https://doi.org/10.1002/acp.1537>. read (abstract)
- Yan, V. X., Bjork, E. L., & Bjork, R. A. (2016). On the difficulty of mending metacognitive illusions. *Journal of Experimental Psychology: General*, 145(7). <https://doi.org/10.1037/xge0000177>. read (abstract)

**Grammar instruction and the drill debate**

- Wong, W., & VanPatten, B. (2003). The evidence is IN: Drills are OUT. *Foreign Language Annals*, 36(3), 403-423. <https://web.pdx.edu/~fischerw/courses/advanced/methods_docs/pdf_doc/wbf_collection/0351_0400/0385_FLA_Wong_DrillsAreOUT.pdf>. read
- Leaver, B. L., Rifkin, B., & Shekhtman, B. (2004). Apples and oranges are both fruit, but they don't taste the same. *Foreign Language Annals*, 37(1), with Wong and VanPatten's reply. <https://web.pdx.edu/~fischerw/courses/advanced/methods_docs/pdf_doc/wbf_collection/0351_0400/0396_FLA_2004_ContComment.pdf>. read
- DeKeyser, R. (2010). Practice for second language learning: Don't throw out the baby with the bathwater. *International Journal of English Studies*, 10(1), 155-165. <https://revistas.um.es/ijes/article/download/114021/108011/452651>. read
- DeKeyser, R. (1997). Beyond explicit rule learning: Automatizing second language morphosyntax. *Studies in Second Language Acquisition*, 19, 195-221. secondhand
- Nation, I. S. P. (2007). The four strands. *Innovation in Language Learning and Teaching*, 1(1), 2-13. <https://www.wgtn.ac.nz/lals/resources/paul-nations-resources/paul-nations-publications/publications/documents/2007-Four-strands.pdf>. read
- VanPatten, B. (2000, authorship inferred). Processing instruction as form-meaning connections. In Lee & Valdman (Eds.), *Form and Meaning: Multiple Perspectives*. <https://scholarspace.manoa.hawaii.edu/server/api/core/bitstreams/f85e0408-7b67-47ed-9364-4875c06a4750/content>. read
- Shintani, N. (2015). The effectiveness of processing instruction and production-based instruction on L2 grammar acquisition: A meta-analysis. *Applied Linguistics*, 36(3), 306-325. <https://doi.org/10.1093/applin/amu067>. secondhand
- Shintani, N., Li, S., & Ellis, R. (2013). Comprehension-based versus production-based grammar instruction: A meta-analysis. *Language Learning*, 63(2), 296-329. secondhand
- Nikouee, M., & Oba, T. (2025). Beyond drills: Optimizing grammar practice for transfer. *TESL Canada Journal*, 42(1), 183-192. <https://teslcanadajournal.ca/index.php/tesl/article/download/1841/1471/6183>. read
- Lyster, R., & Saito, K. (2010). Oral feedback in classroom SLA: A meta-analysis. *Studies in Second Language Acquisition*, 32, 265-302. secondhand

**German: curriculum, acquisition, and frequency**

- Akademie für Lehrerfortbildung und Personalführung Dillingen (2022). Grammatikprogression in DaZ: Niveaustufen A1, A2 und B1. <https://alp.dillingen.de/fileadmin/user_upload/Themen/unterstuetzungsangebote/2022_12_07_Grammatikprogression_DaZ.pdf>. read
- Goethe-Institut. Goethe-Zertifikat B1 Wortliste. <https://www.goethe.de/pro/relaunch/prf/da/Goethe-Zertifikat_B1_Wortliste.pdf>. read
- Diehl, E. (1999). Schulischer Grammatikerwerb unter der Lupe: Das Genfer DiGS-Projekt. *Bulletin VALS-ASLA*, 70, 7-26. <https://libra.unine.ch/bitstreams/a9e42fe5-85a6-417c-bad9-b6586213c1f4/download>. read
- Sieberg, B. (2003). Regelhafte und normale Anwendung von Perfekt und Präteritum. *Jahrbuch der Ungarischen Germanistik 2003*, 291-315. <https://epa.hu/04800/04880/00012/pdf/EPA04880_JUG_2003_291-315.pdf>. read
- Gärtig-Bressan, A.-K. Das zukunftsbezogene Futurperfekt. *Linguistik online*. <https://bop.unibe.ch/linguistik-online/article/download/13170/16168/62927>. read. The source for Latzel (2004).
- Brons-Albert, R. (1982). *Die Bezeichnung von Zukünftigem in der gesprochenen deutschen Standardsprache*. Tübingen: Narr. secondhand, quoted through German Wikipedia's article "Futur".

**Computer feedback and language models**

- Heift, T. (2001). Error-specific and individualised feedback in a Web-based language tutoring system: Do they read it? *ReCALL*, 13(1), 99-109. <https://doi.org/10.1017/S095834400100091X>. read (abstract)
- Heift, T. (2002). Learner control and error correction in ICALL: Browsers, peekers, and adamants. *CALICO Journal*, 19(2), 295-313. <https://eric.ed.gov/?id=EJ641227>. read (abstract)
- Heift, T. (2004). Corrective feedback and learner uptake in CALL. *ReCALL*, 16(2), 416-431. <https://doi.org/10.1017/S0958344004001120>. read (abstract)
- Song, Y., Krishna, K., Bhatt, R., Gimpel, K., & Iyyer, M. (2023). GEE! Grammar error explanation with large language models. <https://arxiv.org/abs/2311.09517>. read

**Motivation and engagement**

- Sailer, M., & Homner, L. (2020). The gamification of learning: A meta-analysis. *Educational Psychology Review*, 32, 77-112. <https://link.springer.com/article/10.1007/s10648-019-09498-w>. secondhand
- Hanus, M. D., & Fox, J. (2015). Assessing the effects of gamification in the classroom. *Computers & Education*, 80, 152-161. secondhand
- Silverman, J., & Barasch, A. (2023). On or off track: How (broken) streaks affect consumer decisions. *Journal of Consumer Research*, 49(6), 1095-1117. secondhand
- Duolingo. Improving the streak. <https://blog.duolingo.com/improving-the-streak>. vendor
- Teimouri, Y., Goetze, J., & Plonsky, L. (2019). Second language anxiety and achievement: A meta-analysis. *Studies in Second Language Acquisition*, 41(2), 363-387. secondhand
- Baker, R. S., Corbett, A. T., Koedinger, K. R., & Wagner, A. Z. (2004). Off-task behavior in the Cognitive Tutor classroom: When students "game the system". *CHI 2004*, 383-390. <https://hci.rwth-aachen.de/materials/conferences/CHI2004/1p383.pdf>. read
- OneSignal (2024). Mobile app benchmarks. <https://onesignal.com/mobile-app-benchmarks-2024>. secondhand, industry report

**Competing tools** (store pages and sites, read 2026-11-10)

- ConjuGato: <https://apps.apple.com/us/app/id1388189747>
- Ella Verbs: <https://apps.apple.com/app/id1405230721>
- Conjuguemos: <https://www.conjuguemos.com/>
- Linguno: <https://www.linguno.com/practice/conjugations/demo/>
- Kwiziq: <https://french.kwiziq.com/tour>
- Verben: <https://apps.apple.com/us/app/id327587675>
- Conjuu: <https://apps.apple.com/app/id756938403>
