# Plan: Fix What the Pedagogy Review Found

**For:** a series of fresh Claude Code sessions, one phase per session as a rule. **Kind of work:**
quiz logic, the practice record, analytics, staged privacy text, tests, and prose. **Written:**
2026-11-27, in answer to [`prompts/pedagogy_review.md`](../prompts/pedagogy_review.md). Josh answered
its fifteen decisions the same day, and each answer is recorded under its decision.

This file is both the review and the plan. There is no separate review document, so the findings
are here in full: each has a label, its file and line, its evidence, how it was verified, and a
suggested fix. The phases at the end cite findings by label.

**Subject:** the code that [`plans/pedagogy_implementation.md`](pedagogy_implementation.md) built
from [`docs/pedagogy_research.md`](../docs/pedagogy_research.md), in 24 phases and a Closing, from
`e385749` through `4d22060`. **Reviewed at:** `8f0c3db`, so the review covers the code as it
stands on `main`, including what [`verb_browse_fixes.md`](verb_browse_fixes.md) changed afterward.
Nothing was fixed. **Line numbers are those of `8f0c3db` and will drift as phases land, so find
code by the type and function each finding names.**

## Status

Each session that finishes a phase fills in its row, then writes a **How it differed** note under
that phase's heading. **Every phase waits for Josh before git.** A finished phase is "Awaiting
Josh", with the Commit cell empty, until he has tried the change and said to commit.

| Phase | Status | Date | Commit | Findings | Decisions, all answered 2026-11-27 |
|---:|---|---|---|---|---|
| 1 | Not started | | | L4 (but its ending rules), L20, L21, S4 | None |
| 2 | Not started | | | L8, L4 (the ending rules) | D4, D8. Josh still rules on the Duden list and reviews three new lines |
| 3 | Not started | | | L2, L3, L5, C6 | D2, D3, D5 |
| 4 | Not started | | | L6, L7, L19, P9, G4 (the schedule's comment, Mastery's intro) | D6, D7 |
| 5 | Not started | | | L1 | D1. Josh still reviews the list of verbs |
| 6 | Not started | | | L9, L10, L11, L16, T1, S5 (what a level asks) | D9, D10 |
| 7 | Not started | | | L12, L13, L14, C7, T2, G4 (the challenge's comment) | D10, D11, D12 |
| 8 | Not started | | | L15, L17, C1, C2, C3 | D13 |
| 9 | Not started | | | P1, P2, P3, P4, P8, P10 | D14 |
| 10 | Not started | | | P5, P6, P7, G1, G2, G3 | None; Josh reads the staged text |
| 11 | Not started | | | C4, C5, C8, C9, L18 | D15 |
| 12 | Not started | | | S1, S3, S6, S8 | None |
| 13 | Not started | | | S2, S7, S5 (the rest) | None |
| 14 | Not started | | | T3, T4, T5, T6, T7, T8, T9, G5 | None |
| Closing | Not started | | | The audit | None |

## Verdict

The work is sound in its construction. The tree is green: the run of `xcodebuild -testLanguage en` reports 1,062 tests in 107 suites
passed, two of them the environment-gated harnesses, which skip. SwiftLint reports 0 violations, and `check_docs.py` reports 0 problems. The phase notes are honest about what was
decided in a session rather than by Josh, which is what made most of the findings below findable.
No finding is a crash or a loss of data that a learner would meet.

What the review found is mostly of one kind. **Each feature was built to its phase, and several
later phases changed what an earlier one meant without revisiting it.** The second attempt was
built for a typing slip and then given to grammatical errors. The box of the ladder was built to
schedule reviews and then read as mastery, achievements, and the Speed Round's entry. The re-ask
was built before My Mistakes existed. Seven things deserve attention before the 2027 release, in
this order:

1. **The quiz asks for conjugations German does not have** ([L1](#l1)). Half of all Beginner
   rounds ask the Imperativ of a modal verb and expect "könn" or "müss".
2. **My Mistakes is emptied by the quiz's own re-ask** ([L2](#l2)). A missed question returns
   three questions later with its answer just shown, and a right answer there takes the miss off
   the list.
3. **A real error, once repaired, counts as known** ([L3](#l3), [L4](#l4)). "gehte", then "ging"
   after being told gehen is strong, moves the item up the ladder. "sung" for sang is called a
   typing slip.
4. **Mastery can be reached without producing the conjugation** ([L5](#l5), [L6](#l6)): by
   answering "wir fahren" for fährt, or by tapping Reveal on the review card twice.
5. **Opening a verb's page erases its mastery** ([L7](#l7)), from any screen, the correction's
   own link included.
6. **A signal names the verb asked** ([P1](#p1)) for a quiz over any of the 18 ablaut groups that
   hold one verb, and the browse fix for a correction's link left a second path open
   ([P2](#p2)).
7. **Several tests pass because of their seed** ([T1](#t1), [T3](#t3)): two assert a guarantee
   the code no longer makes, and five would pass more than half the time with their guarantee
   deleted.

The rest is edge cases, staged prose that the code has made untrue, duplication, and two files
that have grown past what one reader can hold.

## Method

I read `Quiz.swift`, `QuizView.swift`, the practice record (`PracticeRecord`, `ReviewSchedule`,
`PracticeStore`, `PracticeItemMapping`), the draw (`QuizDraw`, `QuizLevel`, `QuizDueItems`,
`QuizRecordSession`), and Verb Essentials' part of `Quiz` myself. Six Opus subagents each reviewed
one area independently, with no view of my conclusions: grading and feedback; levels, the draw,
and scope; the practice record and what reads it; the new exercises; analytics, privacy, and the
docs; and the tests. I then ran or re-read the code behind every finding of theirs that I ranked
above "small". Each finding carries one of these labels:

| Label | Meaning |
|---|---|
| **Run** | Confirmed by running code: a temporary probe suite of 19 tests (since deleted), or a reviewer's Python over the bundled JSON and `Verbs.xml`. |
| **Read** | I traced it in the code myself. |
| **Reviewer** | A subagent reported it with file and line; I did not re-trace it. |
| **Suspected** | Plausible from the code, with the unchecked step named. |

What ran: the full suite as a baseline, and the probe suite, which drew 4,000 default rounds,
graded 40 wrong answers, drove quizzes through misses, re-asks, repairs, and a quit challenge,
moved items through the record with injected dates, and printed what each signal carried.

**Not covered:** the app was not launched. Every finding here comes from code and probes, so
layout, VoiceOver by ear, a real device, a real day passing, and the Tutor's surfaces (which this
Intel host cannot render) were not examined. The 736 sentences and 40 choice items were checked
mechanically, not read for idiom. `GameCenterReal`'s threading was read only at its call sites.

## What Holds Up

So that a later session knows what was examined and found sound:

- **Grading.** Pronoun stripping cannot cut into a verb or accept another person. Digraph
  expansion runs from umlaut to digraph only, so "baü" stays wrong. The second attempt shows only
  its one line: the marked difference and the right answer appear with the correction alone. A
  question gets one second attempt at most, and no question can score above 10.
- **The ladder.** A right answer climbs only when due. A wrong one restarts. A right re-ask leaves
  the item in the first box. No item can climb twice in a day, and none can be stranded: an item
  the level will not ask still reaches Review.
- **The re-ask's bookkeeping.** Nothing is skipped or asked a third time, and `questionReached`
  still excludes re-asks, so the Closing's privacy fix holds.
- **The floors of the mix.** "At least two core verbs" and "at least one prefixed verb" never
  failed in 20,000 simulated rounds a level.
- **Ranking.** What posts is the first ten questions of a default quiz's first round, to the
  level fixed at the start. The leaderboard and achievement IDs match
  `GameCenterResources.gamekit` and `docs/game_center_setup.md`.
- **The streak**, traced through consecutive days, a missed day with one and with two sessions,
  two missed days, and a clock set back.
- **Analytics.** No signal sends typed text, an answer, a score, a count of right or wrong
  answers, or a search query. Every signal, key, and value is staged somewhere, apart from the
  findings under Privacy.
- **Determinism inside a process.** No `Set` or `Dictionary` order reaches a seeded draw.
  `SeededRNG` is SplitMix64 with the standard constants, and its first outputs for seed 0 match
  the reference values.
- **Content.** 736 sentences with the distribution the plan claims, every verb in the corpus, no
  duplicates, and every blank checked against the conjugator by `GapSentenceTests`. The 40 choice
  items are consistent, and the right sentence's place is random.

## Findings

Severity is my judgment: **High** is wrong behavior a learner would meet or a promise broken,
**Medium** is wrong in an edge case or a real hazard for maintenance, and **Low** is tidying.

## What the Learner Is Taught

These are the places where a built feature undercuts the aim its suggestion stated.

<a id="l1"></a>
### L1. The quiz asks for conjugations German does not have (Run, High)

The app has no notion of a defective verb. `Conjugator` builds an Imperativ for every verb and
every person of every verb, and no pool entry excludes any (`QuizLevel.pool`,
`QuizLevel.swift:52-100`, where the Imperativ entries take `verbs: .all`). Phase 6 then made the
worst case common: `QuizDraw.mixedQuestions` (`QuizDraw.swift:210-278`) guarantees two questions
on sein, haben, werden, or a modal, six of those nine verbs are modals, and at Beginner two of the
pool's five weights are the Imperativ.

The probe drew 1,000 default rounds a level:

| Level | Rounds asking a modal's Imperativ | Rounds asking an impersonal verb in a person it lacks |
|---|---:|---:|
| Beginner | 509 | 62 |
| Elementary | 93 | 57 |
| Intermediate | 84 | 27 |
| Advanced | 95 | 25 |

The expected answers are "könn" (or "könne"), "müss", "dürf", "soll", "woll", and "mög". The
impersonal column counted only gelingen (rank 84, so in the Beginner band), geschehen, regnen,
schneien, passieren, misslingen, and glücken: the quiz asks "ich gelinge" and "geling!".
The daily challenge inherits it. The probe's draw for 2026-11-15 opens the Beginner challenge
with sollen's ihr Imperativ, which is also what the quiz widget shows that day, and gives
Intermediate können's wir Imperativ.

The research report criticized Conjuguer for exactly this ("it can ask for the imperative of
faillir and for persons of falloir that do not exist"), and `docs/feature_architecture.md:1164`
uses "the Imperativ of the modal verbs" as its example of a practice set.

**Fix.** Give the corpus a way to say which cells a reading lacks, and have the draw refuse them
everywhere a question is drawn (`QuizDraw.questions`, `recordQuestions`, the Speed Round's draw,
and so the challenge and the widget). A `QuizVerbs` case is the smallest change for the modals.
A marker on the reading in `Verbs.xml` is the durable one, since the list of impersonal verbs is a
fact about each verb. See [D1](#d1).

<a id="l2"></a>
### L2. A right re-ask takes the miss out of My Mistakes (Run, High)

`PracticeRecord.recordAnswer` (`Shared/PracticeRecord.swift:130-136`) sets
`entry.lastAnswerWasRight = isCorrect` on every answer, and `missedItems()` (`:179-191`) keeps
only entries where it is false. `Quiz.holdCorrection` (`Quiz.swift:428-442`) inserts a re-ask of
every missed question, `reaskGap` questions later, and `submitAnswer` records the re-ask's answer
like any other (`:298-300`).

The probe missed the first question of a Beginner quiz. `missedItems()` held its item. It
answered the next three right, then the re-ask at index 4, and `missedItems()` was empty, with
the item in box 0. So a learner who finishes her rounds finds My Mistakes almost always empty:
only a miss whose re-ask is also missed, a quit before the re-ask, or a challenge question stays.
The worst case is the round's last question, whose re-ask is the very next thing asked (index 9
missed, index 10 its re-ask), one tap after the correction showed the answer.

Josh's rule of 2026-11-13 is "an item leaves the list once answered right". Phase 12 took that
literally and never tried it with a re-ask: its device check found two misses waiting only
because that quiz was quit, and `aMistakeLeavesOnceAnsweredRight` involves no re-ask.

**Fix.** Tell `recordAnswer` what kind of answer it is. A right re-ask, and a right second
attempt ([L3](#l3)), leave `lastAnswerWasRight` alone. See [D2](#d2).

<a id="l3"></a>
### L3. A diagnosed error, once repaired, counts as right in the record (Run, High)

`Quiz.submitAnswer` gives a second attempt to a slip or to any diagnosed error
(`Quiz.swift:285-296`), and the final answer goes to `recordPractice(of:isCorrect:)` with no
word of how it was reached (`:298-300`, `:444-454`). The comment there gives Phase 11's reason:
"A slip's right second attempt counts as right, since one letter was all that stood between the
learner and the conjugation." Phase 14 then routed every diagnosis through the same second
attempt, and the comment is no longer the whole truth.

The probe typed "gehte" for gehen's Präteritum, was told "That is a weak verb's conjugation, and
gehen is strong. Try once more.", and typed "ging". The item went to box 1 with
`lastAnswerWasRight == true`, and nothing reached My Mistakes or `QuizErrorHistory`. With the item
due in box 1, the same exchange would have made it mastered. "hat gegangen", then "ist gegangen"
after "the auxiliary is sein, not haben", takes the same path, and that line states the answer.

**Fix.** Record a repaired diagnosis as something other than right. See [D3](#d3). Correct the
comment on `recordPractice` either way.

<a id="l4"></a>
### L4. The slip rule calls grammatical errors typing slips (Run, High)

`QuizItem.isSlip` (`AnswerSlip.swift:37-49`) calls an answer a slip when it is one edit from an
accepted spelling and is not itself another cell of the verb. Four kinds of real error get
through, each of which earns "Almost! Try once more." and, repaired, half points and a right
answer in the record.

- **The stem vowel is one letter.** For a strong verb the vowel is the lesson, and a wrong one is
  a single substitution. The probe: "sung" for sang, "gesangen" for gesungen, "gehelfen" for
  geholfen, "gefinden" for gefunden, "trunk" for trank, "sproch" for sprach, "nohm" for nahm,
  "geschreiben" for geschrieben, "gebleiben" for geblieben, and "kame" for käme are all slips.
- **The cell check does not know the spellings grading accepts.** `Verb.conjugations(matching:)`
  (`ConjugationMatch.swift:25-55`) compares with the conjugator's own cells only, without
  digraphs or `StandardVariants`. So "fährt" for du fährst is named ("That is the conjugation for
  er."), while the same error typed "faehrt" is a slip. Likewise "laeuft" for läufst, "stünden"
  for ich stände (the wir conjugation under an accepted variant), and "kämt" for du kämest. A
  learner who writes digraphs, which Phase 1 invited, never has a person error caught.
- **Ending rules.** "arbeitst" for arbeitest and "reisst" for reist are slips. Both are rules of
  the conjugation (`Conjugator.needsEpentheticE`, the s-stem's du), not of typing.
- **The four-letter minimum is measured on the digraph spelling.** `AnswerSlip.isSlip`
  (`AnswerSlip.swift:15-20`) counts the target's letters, and the targets include digraph
  expansions. "neh" for näh is a slip, because "naeh" has four letters. That is the vowel error
  the minimum exists to exclude.

**Fix.** Three changes, the first two with no decision to make.

1. One function gives a cell's lenient spellings (every region, both clauses, variants,
   digraphs), and `makeQuizItem`, the cell check, and `AnswerDiagnoser` all call it. This also
   removes [S4](#s4)'s third copy of the region-by-clause loop.
2. An edit that falls inside the letters the conjugator marks as irregular is not a slip. The
   conjugator already writes sAng and gesUngen, with the changed letters in capitals, so the slip
   check can ask it rather than guess. A wrong letter elsewhere ("sanf") stays a slip. Count the
   minimum on the conjugation's own spelling.
3. The ending rules need a ruling. See [D4](#d4).

<a id="l5"></a>
### L5. An answer credits a key conjugation it never showed (Run, Medium)

`PracticeItem.Stem.init?(_ table:)` (`PracticeItemMapping.swift:65-76`) maps every cell of the
Präsens Indikativ, the Imperativ, the Präsens Konjunktiv I, and the Präsenspartizip to the
Präsens key conjugation, and every Perfekt and Plusquamperfekt cell, with the bare participle, to
the Perfekt one. Phase 11's note names the cost on the miss side only ("a slip in wir fahren
counts against fährt").

The probe answered "wir fahren" on day 0 and the ihr Imperativ "fahrt" on day 3. fährt was then
mastered, in box 2, and among the Speed Round's items. The learner never wrote the ä. At
Beginner only two of the six Präsens persons, and none of the three Imperativ persons asked, show
fahren's vowel. The same holds for the participle: "geblieben" right twice masters "ist
geblieben", though that question never asks for the auxiliary. The Präsenspartizip shows as
little of a strong verb as the Futur does, which the code already makes a pattern for that
reason.

**Fix.** See [D5](#d5). The option I would choose: a cell that does not show what the key
conjugation shows can demote the item but not promote it.

<a id="l6"></a>
### L6. Revealing the review card twice masters a verb never typed (Run, Medium)

`ReviewCardHost.reveal()` (`ReviewCardHost.swift:81-91`) calls `practice.recordReview`, which
moves every due item of the card up a box (`PracticeRecord.swift:154-156`,
`ReviewSchedule.reviewed`). There is no step at which the learner says whether he knew them.

The probe looked bleiben up on day 1, revealed its card on day 2, and revealed it again on day 5.
`Mastery.isFullyMastered` was true, the Speed Round had three more items, and the Ten Strong
achievement stood at 1 of 10. Fifty Strong can therefore be earned by opening fifty verb pages
and tapping Reveal a hundred times, typing nothing. Phase 17 decided that recognizing fuhr "is
not evidence of producing it" and moves nothing. A reveal is weaker evidence than that. The
card's rule comes from browse Phase 15, before the box meant anything but a due date.

**Fix.** See [D6](#d6).

<a id="l7"></a>
### L7. Opening a verb's page erases what the quiz recorded about it (Run, Medium)

`VerbVisitTracker.begin()` (`VerbVisitTracker.swift:87-100`) calls `practice.recordLookup` for
every visit that is not a return to the same page, and `PracticeStore.recordLookup`
(`PracticeStore.swift:63-70`) sends all of the verb's key conjugations back to the first box
unless the source is the review card. The probe put gehen's Präteritum in box 3 and opened the
page from a correction, the widget, and search: box 0 each time.

Josh set "a later lookup sends a verb back to the first box" on 2026-11-13 and kept it for the
widget on 2026-11-25. Both rulings predate, or did not weigh, what now reads the box. The
consequences as built:

- A mastered verb opened from My Verbs to read its etymology loses its mastery, leaves the Speed
  Round (which can lock again below five items), and needs two right answers a stem over four or
  more days to return.
- A miss of fuhr already resets that stem. Tapping the correction's own link to the verb then
  resets fährt and ist gefahren as well.
- Test Me can never promote. Opening the page puts the items in box 0, due tomorrow, so the three
  right answers find nothing due and change nothing.
- Phase 20 knew the mechanism and removed the Mastery page's links because of it. The other ways
  in were not reconsidered.

**Fix.** See [D7](#d7).

<a id="l8"></a>
### L8. Some diagnoses are untrue, and one hides the commonest modal error (Run, Medium)

Phase 14's rule was "a wrong diagnosis is worse than none". `AnswerDiagnoser.weakConjugation()`
(`AnswerDiagnosis.swift:286-307`) conjugates the asked cell as if the reading were weak and, on a
match, says so. It is checked before `otherCell()`.

- **könnte for konnte** gets "That is a weak verb's conjugation, and können is mixed: its stem
  changes too." It is the Präteritum Konjunktiv II, the confusion the research report itself
  uses as its example, and the line never says so. The same for müsste and dürfte.
- **solle for ich soll** gets the same line. solle is the Konjunktiv I, and sollen's stem does
  not change.
- **gehaut and gebackt** get "its stem changes too". hauen's and backen's stems never change:
  only the participle's ending differs.
- **webte, saugte, glimmte** get "…and weben is strong." The corpus has these three as strong
  only. Duden, as I recall it, gives webte as the ordinary Präteritum with wob elevated, and
  saugte and glimmte as standard beside sog and glomm. If so, the quiz marks the commoner
  conjugation wrong and then explains why. **The Duden entries are from memory and were not
  checked**, which is why Phase 1's audit left these verbs open.
- **A smaller point.** `otherCell()` names the first matching conjugationgroup in page order, not
  the nearest one. "fahre" for er führe is called the Präsens Indikativ of ich, where the
  Konjunktiv I of er is the nearer error.

**Fix.** Skip `weakConjugation()` when the weak cell is itself a real cell of the reading, so
that `otherCell()` names it, which is certain. Say "its stem changes too" only where the asked
cell's stem changes. Prefer a group whose persons include the asked one. The doublets and the
ending-only line need rulings: see [D8](#d8).

<a id="l9"></a>
### L9. A round can ask the same question twice (Run, Medium)

Nothing in `QuizDraw.questions` (the unmixed path, `QuizDraw.swift:74-77`) or `mixedQuestions`
(`:266-277`) keeps a round's questions distinct, and `Quiz.continueSession` (`Quiz.swift:229`)
excludes only record items, sentences, and choices. The probe counted rounds of ten that repeat
a verb, cell, and reading:

| Scope | Rounds with a repeat |
|---|---:|
| Default quiz, Beginner | 18 of 300 |
| Default quiz, Elementary | 8 of 300 |
| The modals collection, at Beginner | 65 of 100 |
| A one-verb ablaut group (bitten), at Beginner | 50 of 50 |

A repeat follows its first asking closely, so it tests short-term memory, and the re-ask can add
a third. `DailyChallenge.draw(for:)` retries until no verb repeats, so Phase 24 treated a repeat
as a defect where it noticed one.

**Fix.** Draw without replacement over verb, cell, and reading within a round, and across a
session's rounds while unasked questions remain. What a scope with fewer than ten distinct
questions should do is [D9](#d9).

<a id="l10"></a>
### L10. A custom quiz that chooses only verbs still lifts the level's restrictions (Run, Medium)

`Quiz.generateQuestions` passes `relaxesRestrictions: scope.custom != nil` (`Quiz.swift:667`),
and `QuizDraw.questions` then asks a restricted kind of every verb when none of the scope's
verbs qualifies (`QuizDraw.swift:60-63`). The doc comment and Phase 9's note both describe the
relaxation as being for a conjugationgroup the learner chose.

With a custom quiz of singen's ablaut group alone, at Elementary, the probe's 20 rounds asked 32
Präteritum Indikativ questions of 200. Elementary keeps the Präteritum to sein, haben, and the
modals. The same group started as a collection asked none. By the same path a weak-only list at
Advanced is asked machte as a Konjunktiv II, which Josh ruled out on 2026-11-13. Practice sets
inherit it. `aVerbSetAloneAsksTheLevelsTables` runs only at Beginner, which restricts nothing.

**Fix.** Relax only where the learner chose the conjugationgroup:
`scope.custom?.tables.isEmpty == false`. Better, mark the relaxation on the `QuizPoolEntry` that
`CustomQuiz.pool` builds from a chosen table, so the draw takes no flag.

<a id="l11"></a>
### L11. The mix is guaranteed for the questions drawn, not for the round (Run, Medium)

`generateQuestions` draws `scope.questionCount - due.count - (choice == nil ? 0 : 1)` mixed
questions (`Quiz.swift:660-670`), and `mixedQuestions` makes `count / 2` of them strong
(`QuizDraw.swift:259`). From Elementary up every default round has a choice question, so the
draw is nine and the guarantee is four. The probe's 200 rounds a level:

| Level | 4 strong | 5 strong | 6 strong |
|---|---:|---:|---:|
| Beginner | 0 | 200 | 0 |
| Elementary | 47 | 153 | 0 |
| Intermediate | 74 | 126 | 0 |
| Advanced | 57 | 141 | 2 |

Phase 11's note covers what due items do to the mix. Nothing covers the choice question, and
`docs/pedagogy_research.md:756-759` still says, without qualification, that half of each quiz's
questions ask a strong or mixed reading and that exactly one to three ask a rare prefixed verb.
Two tests assert the five ([T1](#t1)).

**Fix.** See [D10](#d10), then correct the report's paragraph to say what holds.

<a id="l12"></a>
### L12. A quit challenge can be taken again with its answers seen (Run, Medium)

`PracticeStore.recordChallenge` is called only from `finishQuiz` (`Quiz.swift:1180-1182`), so
`Quiz.quit()` leaves no trace of a challenge, and the hub's row offers it again
(`QuizView.challengeRow`, `:1080-1105`). The draw depends on the key alone. The probe answered
four of five questions wrongly, each correction showing its answer, and quit. No result was kept,
and the second start asked the same four questions in the same order. The shared text then
reports 50 of 50.

Josh's rule is that a challenge is taken once (2026-11-15). Phase 24's note lists "a quit
challenge keeps nothing and can be started again" under "decided in the session, not asked", and
`aQuitChallengeKeepsNothing` pins it.

A related point, by design: the quiz widget shows the challenge's first question, with its
answer among three, before the challenge asks it typed. Josh kept it on 2026-11-27: the widget is
the challenge's invitation, and choosing among three is not typing.

**Fix.** See [D11](#d11).

<a id="l13"></a>
### L13. "The same on every device" holds within one build and one corpus (Read, Medium)

`DailyChallenge.draw(for:)` (`DailyChallenge.swift:144-156`) seeds `SeededRNG` from the day and
the level and then runs the default draw. Two things besides the seed decide the questions: the
corpus, since any verb import re-ranks the bands, and the standard library's `Int.random`,
`randomElement`, and `shuffled`, whose use of a generator Swift does not promise to keep.
`VerbDraw.swift:64-65` already avoids the library's sampling for this reason, so the two daily
draws follow different policies.

Phase 24's note says all of this. The report does not: its paragraph says "the same on every
device on the same date" and "a link that opens the same challenge"
(`docs/pedagogy_research.md:1041-1046`). After the release, two friends on different versions
will open one link, be asked different questions, and compare scores over them. Nothing in the
link says which corpus it came from.

**Fix.** See [D11](#d11). Whatever he chooses, write a bounded-integer pick, a shuffle, and an
element pick over `SeededRNG.next()` and use them on the challenge's path, so that a toolchain
cannot move the draw.

<a id="l14"></a>
### L14. The choice question: a coin flip in the ranked score, and English that answers it (Read, Low)

- **The score.** A choice question counts toward `firstRoundScore` (`Quiz.swift:90-92`), the
  leaderboard, and the level's best. It is one of two, from a bank of 12 at Elementary, and
  nothing remembers across sessions which items were asked, so a returning learner soon knows
  them. That is 10 of a ranked round's 100 points. Phase 19 decided "a ranked round still scores
  out of 100". See [D10](#d10).
- **The English** (Reviewer). `ChoiceQuestionView` shows the sentence's English before the
  choice (`ChoiceQuestionView.swift:27-33`). For several items it gives the answer: "Have you
  read the book yet?" points at the Perfekt, "Could you help me, please?" at könntest, and the
  Konjunktiv I items' English is backshifted where the Indikativ items' is not. One distractor,
  "Last du das Buch schon?", differs in meaning, not register. See [D12](#d12).
- **What was checked and is fine.** The probe looked for a choice card showing the answer to a
  question typed later in its round. Of 900 rounds, 50 asked the choice's verb again, and none
  asked either of its two cells.

<a id="l15"></a>
### L15. The Speed Round's clock counts ticks, not time (Read; the scrolling part Suspected, Medium)

`Quiz.startTimer` (`Quiz.swift:1083-1089`) schedules a repeating one-second `Timer`, and
`clockTicked` adds one to `elapsedSeconds` (`:1093-1108`). The round ends when sixty ticks have
arrived.

- **Pausing** (Read). `QuizView` pauses the timer when the scene is inactive or in the background
  and resumes it when active (`QuizView.swift:224-233`). So pulling down Control Center stops the
  clock with the question still in view, and leaving the app to look an answer up costs nothing.
  Each resume also starts a fresh second.
- **Scrolling** (Suspected). `Timer.scheduledTimer` runs in the run loop's default mode, which
  does not fire while a scroll view is being dragged, and the question sits in a `ScrollView`.
  The unchecked step is holding a finger on the card during a round and watching Time Left.

Only the Speed Round's best is at stake, and it stays on the device. But the round is "the one
place where the clock counts".

**Fix.** Keep a deadline as a `Date` and compute the seconds left from the injected clock. Let
the timer only refresh the display, added in the common run-loop modes. What backgrounding should
do is [D13](#d13).

<a id="l16"></a>
### L16. A ranked round mixes in the learner's own due items (Read, Low)

`QuizScope.isRanked` and `mixesDueItems` are the same test (`Quiz.swift:1476-1500`). A learner
with three items due answers three of her own weak points in place of three balanced draws, in
the round that posts to the level's board and sets her best. The comment at `Quiz.swift:655-656`
says the choice question is always there "so that every ranked round of a level asks the same
mix". See [D10](#d10).

<a id="l17"></a>
### L17. The reminder counts items its session will not ask (Run, Low)

`DailyReminderPlan.reminders` (`DailyReminder.swift:44-63`) puts
`record.dueItems(at: date).filter(\.isAskable).count` into the reminder's body. The daily session
asks only what the level's pool and band admit (`QuizDraw.dailyQuestions`, through
`dueQuestions(pool:verbs:)`). The probe had a Beginner look up bleiben, fahren, geben, and
nehmen. The next day's reminder read "Your daily session is ready, with 15 conjugations due for
review.", and a Beginner session asks 5 of them.

**Fix.** Give the plan the level and count with the session's own admissibility, capped at the
session's length. A helper that answers "would the level ask this item" needs no generator and
serves [S5](#s5) too.

<a id="l18"></a>
### L18. Small points in the sentences (Reviewer, Low)

- `bringen.imperativ.1`, "{Bring} mir bitte ein Glas Wasser!", has the English "Please bring me
  a glass of water!", which is the answer but for its capital.
- 359 of the 736 sentences ask er, sie, or es, and 523 ask the Perfekt or the Präsens. That
  follows what short sentences say most easily. It is recorded here so that the next batch can
  lean the other way.

<a id="l19"></a>
### L19. Dismissing the review card hides its items from today's Review (Read, Low)

`ReviewCardHost.dismiss()` snoozes an unrevealed card's items to tomorrow
(`ReviewCardHost.swift:95-105`, `PracticeRecord.snooze`). The items leave today's Review count
and today's daily session with it. Browse Phase 15 wrote the rule when the card was the items'
only reader. See [D6](#d6).

<a id="l20"></a>
### L20. The correction marks an accepted digraph as a wrong letter (Run, Low)

`QuizItem.difference(from:)` (`AnswerDifference.swift:101-122`) aligns the answer with the
conjugation as the conjugator spells it. The probe compared "faehrts" with fährst: the a and the
e are marked along with the swapped letters, and VoiceOver would read the ä among the letters
that differ. The learner is told that a spelling grading accepts was part of her error. The same
for ss in Germany.

**Fix.** Before aligning, rewrite a digraph or ss in the given answer that sits where the target
has ä, ö, ü, or ß.

<a id="l21"></a>
### L21. The frame's own word, typed into the blank, is wrong (Run, Low)

For a Sie Imperativ the frame supplies "Sie" after the blank
(`AnswerFrame.quizFrame`, `AnswerFrame.swift:145`). A learner who types "gehen Sie" has "gehen
Sie Sie" graded (`answer(filling:)`, `:36-54`): wrong, not a slip, no diagnosis. A finite cell
forgives the same habit, since "ihr kommt an" in the blank is accepted. A trailing "!" copied
from the frame is not stripped either: "komm!" is a slip and "geh!" is wrong outright.

**Fix.** In `answer(filling:)`, drop a blank's last word when it equals the word that follows the
blank. Strip a trailing "!" or "." in `AnswerSpelling.normalized`.

## Correctness

<a id="c1"></a>
### C1. Each reschedule of the reminder runs as its own unordered task (Suspected, Medium)

`ReminderSchedulerReal.schedule` (`ReminderSchedulerReal.swift:27-51`) starts a `Task` that
fetches the pending requests, removes the reminder's, and adds the new ones, awaiting between
steps. The time picker's setter, the On and Off switch, and scene changes each call it, so two
tasks can interleave: an older plan's `add` can land after a newer plan's removal. On then
quickly Off can leave reminders scheduled while the setting reads Off. The unchecked step is the
order in which the notification center completes the calls, which I did not observe.

**Fix.** The identifiers are deterministic (`identifierPrefix` plus the day key), so remove them
by name without the fetch, or keep one stored task and cancel it before starting the next.

<a id="c2"></a>
### C2. The store keeps the calendar of the moment it was made (Read; the effect Suspected, Low)

`PracticeStore.init(getterSetter:calendar: = .current)` (`PracticeStore.swift:37-39`) stores a
snapshot, and `Current.practice` lives for the process. `DailyReminderPlan`
(`DailyReminder.swift:44`) and the scheduler (`ReminderSchedulerReal.swift:34`) read
`Calendar.current` afresh. After a change of time zone with the app suspended, the streak's days
and the reminder's days can disagree until the next launch.

**Fix.** Store `Calendar.autoupdatingCurrent`, and pass the store's calendar to the plan and the
scheduler.

<a id="c3"></a>
### C3. A daily session that crosses midnight counts for the day it ends (Read, Low)

`finishQuiz` records the session at `now()` (`Quiz.swift:1173-1177`). A session begun at 23:58
and finished at 00:02 is keyed to the new day, so the day it was begun on reads as missed and the
hub says one more session will save the streak.

**Fix.** Record the session for the day it began.

<a id="c4"></a>
### C4. In the Swiss region, Name the Conjugation misses the other verbs that write its prompt (Run, Low)

`RecognitionQuestion.cells(writing:asked:map:)` (`Recognition.swift:124-143`) looks the prompt up
in the conjugation map, whose keys keep ß (`ConjugationMap.swift:173-175`), while the prompt is
spelled for the learner's region. The probe asked wissen's ich Präsens. In the north the prompt
"weiß" is right for wissen and for weißen. In Switzerland the prompt "weiss" is right for wissen
alone, so "weißen, Imperativ, du" is graded wrong. Phase 17 claimed that every cell of every verb
that writes the prompt is right.

**Fix.** Fold ß to ss on both sides of the lookup in `ConjugationMap.entries(for:)`.

<a id="c5"></a>
### C5. A record that fails to decode is replaced by an empty one (Read, Low)

`PracticeStore.init` falls back to `PracticeRecord()` when `PracticeRecord.init?(json:)` returns
nil (`PracticeStore.swift:40`), and the next answer saves over the stored JSON
(`save()`, `:202-206`). The record's own comment warns that a new field that is not optional
would fail every older record. `DailyStreak`, the level bests, and the last result behave alike
through `getCodable`. Nothing has shipped, so nothing is at risk today.

**Fix.** On a failed decode, copy the stored string to a second key before anything writes, and
log it. Add a test that decodes a pinned JSON string of today's format, so that a change to the
format fails a test rather than a learner.

<a id="c6"></a>
### C6. The quiz's injected clock reaches only the streak (Run, Medium)

`Quiz` takes `now: () -> Date` and uses it for the daily session's due items and its streak
(`Quiz.swift:623`, `:1174-1177`). Everything else reads the wall clock: `recordPractice` (`:447`,
through `recordAnswer(at: .now)`), the default round's `dueItems()` (`:653`), a record session's
items (`:609`), `canContinue` (`:122`), `startDate` (`:200`), and the error history's timestamp
(`:321`). The probe gave a quiz a clock of 2026-11-02 and missed a question: the miss was
recorded on 2026-11-27.

In the app the two clocks agree. In a test they do not, so no test can ask "is a miss on day 0
due in day 1's session". `aStreakIsRepairedAcrossDays` passes only because every answer in it is
right, and `aShortReviewAsksWhatIsDueAndDoesNotContinue` would ask three questions rather than
two if its run crossed midnight.

**Fix.** Pass `now()` to every one of those calls. The fixes for [L2](#l2), [L3](#l3), and
[L5](#l5) need this to be tested honestly, so it belongs to their phase.

<a id="c7"></a>
### C7. Smaller holes in the daily challenge (Reviewer; the first two Read, Low)

- **Twelve results.** `DailyChallengeResult.keptCount` is 12 (`DailyChallenge.swift:164`).
  Twelve challenges taken from links, of any date and level, push today's result out, and today's
  can then be taken again.
- **Future dates.** `Key(dayString:level:)` accepts any date (`:37-42`), so a hand-made link
  previews tomorrow's challenge, and tomorrow's widget question, and marks it taken.
- **A stale row.** The hub computes the key from `.now` when it renders
  (`QuizView.challengeRow`). Left open across midnight, the row starts yesterday's challenge. The
  hub's due counts and streak go stale the same way.
- **A silent link.** A link to a challenge already taken, other than today's at the learner's
  level, opens the hub and shows nothing about it.

**Fix.** Keep results by key with a cap far above what links can fill. Refuse a date after
today. Compute the key at the tap, and refresh the hub when the day changes. Show a taken
challenge's result when its link is opened.

<a id="c8"></a>
### C8. The cap on a shared list does not keep its QR code coarse (Reviewer, Low)

`PracticeSet.maximumListCount` is 100, "to keep a projected QR code coarse enough to scan from
the back of a classroom" (`PracticeSet.swift:31-32`). A reviewer measured the links: the 100
longest infinitives with every conjugationgroup make 2,213 bytes, which needs the largest code
there is (177 modules a side) and sits within 5% of its capacity at the correction level the app
uses. A typical 100-verb list is about 1,230 bytes, a code of about 135 modules. Neither is
coarse, and a corpus with longer infinitives can pass the capacity, at which `QRCode.image(for:)`
returns nil. `theLongestListFitsACode` checks only that an image came back. See [D15](#d15).

<a id="c9"></a>
### C9. A shared My Verbs carries the sharer's recent lookups (Read, Low)

`PracticeSet.init(sharing:level:myVerbs:)` (`PracticeSet.swift:22-29`) shares the first 100 of
My Verbs, and `LearnerVerbs.myVerbs` is the starred verbs followed by up to 20 opened lately and
not starred (`Shared/LearnerVerbs.swift:83-85`). A teacher who starred this week's verbs also
hands the class whatever else she looked up, and the share menu says only "My Verbs". Beyond 100
the oldest stars are dropped without a word. See [D15](#d15).

## Privacy

Decision 5: no signal may carry an answer, a score, an accuracy, or a verb.

<a id="p1"></a>
### P1. A quiz over a one-verb ablaut group sends the verb it asks (Run, Medium)

`Quiz.start` puts `scope.collectionKey` into `startQuiz` (`Quiz.swift:212-214`), and an ablaut
group's key is `ablaut-` plus its exemplar verb (`VerbCollection.key`,
`VerbCollection.swift:28-29`). Eighteen groups hold one verb: bitten, erscheinen, essen, gebären,
gelingen, gewinnen, können, müssen, schlafen, schreiten, sein, sieden, sollen, tun, verlieren,
werden, wissen, and wollen. `CustomQuizAblautGroupList` offers each of them
(`CustomQuizView.swift:123`).

The probe started a custom quiz over bitten's group. Every question asked bitten, and `startQuiz`
carried `collection: ablaut-bitten`, with `source: custom`. A practice set and a collection's own
quiz do the same. `tapShareCollection` sends the key too.

`docs/feature_architecture.md:1837` says "No signal carries a verb", the Closing's audit said
the same, and the staged policy says of a custom quiz "(not which)". Browse fix P1 closed this
for one signal and one source. See [D14](#d14).

<a id="p2"></a>
### P2. The browse fix for a correction's link left Share open (Read, Medium)

Phase 2 of the browse fixes made `VerbCollection.signalView` omit the key when the source is a
quiz correction (`VerbCollection.swift:158-166`). The page that link opens still shows the
group's bar, and `VerbCollectionBar` hides only its quiz button beneath a quiz
(`VerbCollectionView.swift:88`). Its Share button is unconditional, and `share()` sends
`tapShareCollection` with the key (`:122-125`). So after a wrong answer, the correction's link
and one tap name the group of the verb just missed, which for 18 groups is the verb. The staged
text at `docs/privacy_policy_pending.md:276-278` says the leak is closed.

**Fix.** Carry the request's source to the bar, so that the one rule (no key after a correction)
lives in one place. Hiding Share beneath a quiz, as the quiz button is hidden, would also do.

<a id="p3"></a>
### P3. A second round of My Mistakes says that more than ten were missed (Read, Low)

A record session sends no counts (`QuizScope.sendsQuestionCounts`, `Quiz.swift:1522-1524`). But
`finishQuiz` sends `completeQuiz` for every round, and `canContinue` offers Ten More only while
unasked items remain (`:114-123`). A second `completeQuiz` with `source: mistakes` in one session
therefore means more than ten items were missed, and a third more than twenty. The staged text
says such a session "reports neither how many questions it asked nor how far you got". See
[D14](#d14).

<a id="p4"></a>
### P4. Two sources exist only after the record says something about accuracy (Read, Low)

The Speed Round's row is a button only once five items are mastered
(`QuizView.swift:1161-1172`), and an ablaut group's Mixed button only once another group is known
(`AblautPracticeCard`). So `startQuiz` with `source: speedRound` says at least five items are
mastered, and `ablautMixed` says at least one group is known. Josh ruled on 2026-11-15 that
`mistakes` and `quizCorrection` are surfaces, not counts. These two are of the same kind and were
never put to him. See [D14](#d14).

<a id="p5"></a>
### P5. A staged paragraph says nothing on the screen is sent (Read, Medium)

`docs/privacy_policy_pending.md:36` (English) and `:52` (German) stage this, and no later section
revises it: "A screen visit or a tap is recorded only as having happened, apart from the details
about verb pages and searches listed above. Nothing you type and nothing on the screen is sent
with any event."

Later sections add details to taps and screens that concern neither verb pages nor searches:
whether a verb was starred, which collection was shared or viewed, how a practice set was shared,
whether the reminder was turned on, and the level of a shared challenge. A collection's name, the
level, and a star are on the screen. On release day this paragraph would be pasted as written.

**Fix.** Restage it: "…recorded only as having happened, apart from the details listed above.
Nothing you type is sent with any event." Both languages.

<a id="p6"></a>
### P6. The staged paragraph about the practice record omits what it keeps (Read, Low)

The last staged version (`docs/privacy_policy_pending.md:966`, with its German) lists what the
device keeps. It leaves out two things.

- **The wrong answers themselves.** `QuizErrorHistory` keeps up to 200 records, each with the
  verb, what was typed, and the right answer (`Quiz.swift:314-324`). The policy never says the
  app keeps what the learner typed.
- **Lookups.** Opening a verb's page puts its key conjugations into the record. The paragraph
  says "practiced in quizzes and on review cards".

Handoff has no line in the policy either: a verb page on screen, one opened from a correction
included, is offered to the learner's own devices. That predates this work.

**Fix.** A sentence for each, in both languages, for Josh to read.

<a id="p7"></a>
### P7. "(Not which)" is untrue of a collection (Reviewer, Low)

The staged bullets for a custom quiz and a practice set say the app records that verbs were
chosen, "(not which)" (`docs/privacy_policy_pending.md:414`, `:428`, `:444`, and later copies).
A custom quiz or practice set over the modals sends `collection: modals`, which
`PracticeSetTests.startQuizNamesTheLinkAndTheSetsLevel` pins. The developer's note at `:404`
admits it, and the published bullet does not. The fix follows [P1](#p1)'s answer.

<a id="p8"></a>
### P8. Decision 5 is held by vigilance, not by construction (Read, Medium)

The API is `signal(name:parameters: [String: String])`, and `AnalyticsSpy` records without
checking. The tests pin particular absences at particular call sites. A new key, or an infinitive
passed as a collection, would pass every test in the suite, which is how [P1](#p1) survived two
audits.

**Fix.** In order of cost:

1. An allow-list of every parameter key and its values (integers as a pattern), with
   `AnalyticsSpy.signal` recording an issue for anything outside it. Every test that drives a
   quiz, a search, or a page then guards Decision 5 for free.
2. A closed `enum Signal` whose cases carry typed payloads and encode themselves in one file, so
   that a collection's parameter cannot be built from an ablaut group and a record session
   cannot express a count.
3. `check_docs.py` asserting that every signal name and value appears in the policy or its
   pending file.

<a id="p9"></a>
### P9. The analytics vocabulary decides what the app does (Read, Low)

`PracticeStore.recordLookup` reschedules unless the `AnalyticsSource` is `.reviewCard`
(`PracticeStore.swift:68`). `VerbVisitTracker.begin` records an open unless it is `.resume`
(`VerbVisitTracker.swift:95`). `VerbCollection.signalView` branches on `.quizCorrection`.
Renaming or splitting a reporting value would silently change review scheduling. The browse
plan's Closing met the same thing in a practice-set link.

**Fix.** Pass what the behavior depends on by name, such as whether a visit reschedules, and keep
`AnalyticsSource` for reporting. [L7](#l7)'s fix rewrites this code and should carry it.

<a id="p10"></a>
### P10. A comment says the right answer reaches telemetry (Read, Low)

`QuizItem.correctAnswer`'s comment (`Quiz.swift:1586-1587`): "This is what reaches results,
`QuizErrorHistory`, telemetry, and the VoiceOver readout." No signal carries it. A later session
could read the comment as permission. Delete the word.

## Gaps and Docs

<a id="g1"></a>
### G1. The report states two guarantees the code qualifies (Read, Low)

`docs/pedagogy_research.md:756-759` on the mix ([L11](#l11)) and `:1041-1046` on the challenge
([L13](#l13)). The phase notes are accurate, and the report is what a reader meets first.

<a id="g2"></a>
### G2. `feature_architecture.md` § Analytics says things the code does not do (Read, Low)

- `:1837`: "No signal carries a verb". See [P1](#p1).
- `:1852`: a collection's key "names a fixed list, not anything the learner chose". Not so for a
  custom quiz or a practice set.
- `:1864`: the Speed Round is missing from the modes that send no counts. `questionCount` is
  given as 10, 20, 30, or 3, and it is also 5 for a challenge and 15 for Verb Essentials.
  `startQuiz`'s `collection` omits practice sets.
- `:1865`: `abandonQuiz`'s `questionNumber` is also absent for the Speed Round and a mixed ablaut
  round.

<a id="g3"></a>
### G3. `docs/release.md` lacks the Camera's QR check (Run, Low)

The plan left Josh one task on a real phone: whether the Camera app offers to open a
`konjugieren://` code (Phase 10's note, and "Tasks for Josh Outside the Code"). A search of
`docs/release.md` for "QR" and "camera" finds nothing. A development build suffices, so it need
not wait for the release.

<a id="g4"></a>
### G4. Three comments and one string say what the code does not (Read, Low)

- `ReviewSchedule`'s header (`Shared/ReviewSchedule.swift:9-10`) says an item missed late in the
  evening "waits until the next morning". It is due at midnight, so a miss at 23:58 is drawn as a
  due review by a Ten More at 00:01.
- `DailyChallenge.questions(for:)`'s comment (`DailyChallenge.swift:129-132`) says
  `DailyChallengeTests` pins the draw against a toolchain's change. The test cannot
  ([T2](#t2)).
- `recordPractice`'s comment gives the slip's reason for a rule that now covers diagnoses
  ([L3](#l3)).
- `Mastery.intro` (the string) says an item is mastered "once its next review is a week or more
  away". The code asks only whether the box is the third or later (`Mastery.swift:14-22`), so an
  item overdue by a month is mastered, and the string does not say that a lookup starts it over
  (Reviewer).

<a id="g5"></a>
### G5. `StandardVariants`' tables are keyed by strings that nothing checks (Reviewer, Low)

`konjunktivIIVowels`, `doublets`, and `anerkennenVariants` (`StandardVariants.swift:148-196`) are
keyed by infinitive or suffix. A reviewer swept `Verbs.xml` and found every key valid today, and
every row the audit ruled is built. No test makes the same sweep, so a renamed or reclassified
verb would drop its variants silently.

**Fix.** A test that every key names a verb of the expected family.

## Smells, Duplication, and Elegance

<a id="s1"></a>
### S1. Every mode is a parallel path through `Quiz` (Read, Medium)

`Quiz.swift` is 1,812 lines. It has four submit paths (`submitAnswer`, `submitRecognition`,
`submitChoice`, `submitSpeedRoundAnswer`), and `generateQuestions(excluding:)` is a 130-line
chain of `if scope.isX`. `QuizItem` carries `recognition`, `sentence`, `choice`, `stepID`,
`firstAttemptRecognition`, and `chosenOption`, of which at most one applies to any item. Some 280
lines are debug fixtures, and 120 are VoiceOver announcements. A new mode means edits to
`QuizScope.Kind`, each `isX`, `continues`, `sendsQuestionCounts`, `generateQuestions`,
`LastQuizResult.Kind`, `QuizView.tabSessionTitle`, and a submit path.

Most of this review's findings are of that shape: a rule written for one mode and reached by
another.

**A simpler shape.** `QuizScope.Kind` gives a mode value that answers the questions now asked by
boolean algebra: its questions, title, whether it continues, ranks, re-asks, records practice,
and sends counts. `QuizItem` takes a `Prompt` enum (a conjugation, a sentence, a recognition, a
choice) in place of its optionals, and one `grade(_:)` returns right, second attempt with its
line, or wrong with its correction, so that `Quiz` keeps one submit path over the three helpers
it already has. Short of that, moving the fixtures and the announcements to their own files
would cost an hour and take 400 lines out of the file.

<a id="s2"></a>
### S2. `QuizView` is the question, the hub, and the hub's rows (Read, Medium)

1,561 lines: the question (to about line 640), the practice hub (to 1,225), and five private
views. The hub does model work in `body`, on every render: `Mastery(level:record:)`,
`session.askableCount(from:)`, `SpeedRound.masteredItems(in:)`, `GapSentences.askable(at:)`, and
`streakStatus()`, each reading `.now` itself, which is also why the hub goes stale at midnight
([C7](#c7)). `QuizHubRow`, `LastQuizResultRow`, and `QuizFactTile` each spell out the same card
(yellow at 6%, a 16-point corner, a 25% stroke).

**Fix.** A `QuizHubView` with a small model that computes the rows from one injected date, and
one card modifier. The browse fixes did the same for `VerbBrowseView`.

<a id="s3"></a>
### S3. `QuizScope`'s kind and its stored fields can disagree (Read, Low)

Browse fix Phase 11 gave the scope a `kind` and stopped there, which was right for what it
named. What is left:

- `.collection` carries no collection: it lives in a stored optional beside the kind. `.custom`
  and `.practiceSet` carry a `CustomQuiz`, with `verbs` and `collection` stored again.
- `continues` asks `questionCount == Quiz.questionCount` to mean "not a verb page"
  (`Quiz.swift:1543-1545`), and `mixesVerbs` asks `verbs == nil`.
- `distinctCells: !scope.continues` (`:665`) ties "three distinct cells and no participle" to
  "has no Ten More". The daily session and the challenge do not continue either and are spared
  only because they return earlier in the function.

The comment on `Kind` says "each mode's own state rides in its case". Make it so, and ask the
kind, not a count.

<a id="s4"></a>
### S4. One spelling rule, written four times (Read, Low)

Four tables map umlauts: `AnswerSpelling.digraphs`, `AnswerSpelling.orthographicKey`,
`AnswerSlip.bareSpelling`, and `VerbSearch`'s fold. Each differs on purpose. The loop over every
region and clause appears three times, in `makeQuizItem`, `Verb.conjugations(matching:)`, and
`AnswerDiagnoser`, and the difference between them is [L4](#l4). `diagnosis(of:)` also runs twice
on every wrong final answer (`Quiz.swift:289`, `:310`).

**Fix.** One type that names the maps, one function for a cell's lenient spellings, and the
diagnosis passed along once computed.

<a id="s5"></a>
### S5. "Would this level ask it", "is it due", "is it mastered", each answered more than once (Read, Low)

- **What a level asks:** `recordQuestions`' `admits` (`QuizDueItems.swift:39-44`),
  `GapSentence.isAskable(at:)`, and `Mastery.stems(askedAt:)` each write
  `pool.contains { $0.cells.contains(cell) && $0.verbs.admits(verb, reading:) }`. The reminder
  needs a fourth ([L17](#l17)).
- **Mastered:** `MasteryState.init` and `SpeedRound.masteredItems` restate the test on the box.
  The Speed Round's lock counts every mastered entry of any level, so "3 of 5 mastered" can sit
  beside a Mastery row reading 0.
- **Days:** `DailyStreak.dayNumber` and `PracticeRecord.daysBetween` are two helpers for the
  same arithmetic.
- `QuizDraw.questions(level:…)` (`QuizDraw.swift:93-103`) has no caller outside the tests.

<a id="s6"></a>
### S6. One set of strings holds three kinds of key (Read, Low)

`continueSession` unions practice-item keys, sentence ids, and choice ids into
`excluded: Set<String>` (`Quiz.swift:229`), and three draws each read it as their own kind.
Nothing collides today. A struct with three typed sets would make a collision impossible.

<a id="s7"></a>
### S7. `PracticeStore` holds six things, and Reset Practice lives in a view (Read, Low)

The store persists the record, the last result, the Speed Round's best, the streak, the level
bests, and the challenge results. `SettingsView.resetPractice()` (`SettingsView.swift:329-336`)
clears three stores and reschedules the reminder, and the row's condition (`:257`) restates by
hand what a reset clears. It omits first opens, so a learner who has only opened weak verbs has
collection progress and no way to reset it.

**Fix.** `Current.resetPractice()` and a `hasPracticeToReset` beside it, owned by the model.

<a id="s8"></a>
### S8. Small things (Read, Low)

- `Quiz.finalScore` (`Quiz.swift:181-183`) returns `score`. Its comment explains a multiplier
  that no longer exists.
- `makeQuizItem` falls back to an unseeded `randomElement()` for a nil reading (`:709`). No
  seeded path reaches it, and the next caller to omit the reading would bypass the seed. Make
  the parameter required.
- `SeededRNG` now seeds the challenge and the verb of the day, and lives in
  `Shared/WidgetQuizShuffle.swift`.
- `DailyChallenge.dayFormatter` builds a `DateFormatter` on each call, and
  `LastQuizResultRow.relativeDay` a `RelativeDateTimeFormatter` on each render.
- `Quiz.submitAnswer` has no guard against a choice question (`:273-276`). The view cannot reach
  it, and several tests do ([T6](#t6)).

## Tests

Josh asked whether the tests that use `SeededRNG` prove what they claim. Of 522 tests in the 29
pedagogy test files, about 172 reach a seeded generator. About 155 of those are sound, and
roughly 100 use the seed only to obtain some quiz and then check scoring, signals, or holds that
are true of any draw. `QuizVerbMixTests` and `QuizLevelTests` are the model: 40 seeds or 5,000
draws, tolerances several standard deviations wide, and guarantees that an unconstrained draw
would almost never meet. The findings are the exceptions.

<a id="t1"></a>
### T1. Two tests assert five strong questions that the code no longer guarantees (Run, High)

`QuizTests.theDefaultQuizDrawsFromTheLevelsBand` (`QuizTests.swift:65-73`, seed 11) and
`RoundTests.eachRoundOfTenMoreIsMixedLikeTheFirst` (`QuizRoundTests.swift:150-160`, seed 19)
expect `Quiz.questionCount / 2` strong questions in a round. Since Phase 19 the guarantee is four
of nine ([L11](#l11)), and the tenth is the choice item, whose verb may be weak. The probe ran
the second test's check over seeds 1 to 40: 32 pass and 8 fail (2, 4, 16, 21, 28, 32, 33, and
40). Seed 19 is among the lucky.

Because the choice is drawn from the generator before the mixed draw, adding one item to
`ChoiceQuestions.json` reshuffles every seeded default quiz, and either test can then fail with
no change to the code.

**Fix.** After [D10](#d10): assert what is guaranteed, over many seeds, on rounds from
`Quiz.start`.

<a id="t2"></a>
### T2. The determinism tests cannot see what they are said to guard (Run, Medium)

`DailyChallengeTests.theSameKeyDrawsTheSameChallenge` (`:48-55`) draws twice in one process. It
cannot detect a toolchain that samples differently, and it cannot detect the removal of `.sorted`
from `Quiz.defaultVerbs`, since a dictionary's order is fixed within a process.
`theSeedIsPinned` pins the hash of the key and not the generator's output, so a changed mixer
would move every challenge and every widget shuffle with no test failing.
`theWidgetsQuestionAgreesWithTheChallenge` compares the widget with the function the widget
calls.

**Fix.** Three pins, whose values the probe printed on this toolchain:

- `SeededRNG(seed: 0)` yields `0xE220A8397B1DCDAF`, `0x6E789E6AA1B965F4`, `0x06C45D188009454F`.
- With `SeededRNG(seed: 1)`, five calls of `Int.random(in: 0..<1_000)` give 566, 745, 971, 444,
  444, and the same generator then shuffles 0 to 9 into 7, 8, 6, 4, 1, 0, 3, 2, 9, 5. If
  [L13](#l13)'s fix replaces the library's sampling on the challenge's path, pin the replacement
  instead.
- `Quiz.defaultVerbs(for:)` is sorted, at every level.

Then pin one challenge's draw over a small made-up corpus, as `AblautPracticeTests`' `madeGroup`
builds one, so that a verb import does not break it.

<a id="t3"></a>
### T3. Five single-seed tests would pass with their guarantee deleted (Run, Medium)

Each checks "distinct", "new", or "never twice running" on one seed against a pool large enough
that chance usually obliges. The probe modelled each draw without its guarantee, over 1,000
seeds:

| Test | Guarantee | Passes without it |
|---|---|---:|
| `SpeedRoundTests.itemsComeRoundInTurnAndNeverTwiceRunning` (`:70`) | No item twice running | 509 |
| `VerbEssentialsTests.aRoundDrawsDistinctStrongVerbsFromTheBand` (`:54`) | Five distinct verbs | 846 |
| `VerbEssentialsTests.fiveMoreVerbsAreNewWhileTheBandLasts` (`:295`) | Fresh verbs first | 600 |
| `GapSentenceTests.aRoundAsksOneSentenceAVerbWhereItCan` (`:227`) | One sentence a verb | 900 |
| `ChoiceQuestionTests.tenMoreAsksAnotherChoiceNotYetAsked` (`:354`) | A choice not yet asked | 919 |

A reviewer adds `AblautPracticeTests.practiceAloneDrawsFiveDistinctVerbsOfTheGroupInItsReadings`
(`:195`), at about 30%, whose assertion about readings cannot fail because no member of the group
it uses has a reading outside the group.

**Fix.** Loop over 100 or more seeds, or shrink the pool until chance cannot oblige: ten strong
verbs for the Essentials tests, the sentences of two verbs, every choice of the level across as
many rounds.

<a id="t4"></a>
### T4. Four tests cannot fail for what their names claim (Read for the first two, Reviewer for the rest, Medium)

- `SpeedRoundTests.pausingStopsTheClock` (`:349`) ticks the clock by hand, calls `pauseTimer()`
  and `resumeTimer()`, and expects 40 seconds left. Nothing between could have moved the clock,
  so the test passes with `pauseTimer()` empty.
- `QuizPracticeTests.aDefaultRoundTakesAtMostThreeDueItems` (`:111`) checks that the quiz has ten
  questions, which holds for any number of due items, and then calls `dueQuestions` directly
  with its default limit. Passing `limit: 10` in `generateQuestions` leaves it green.
- `DailySessionTests.finishingReschedulesTheReminderWhileItIsOn` (`:318`) runs on the real
  clock. After 18:00 local time, today's reminder is absent because its time has passed, whether
  or not finishing the session removed it.
- `AblautPracticeTests.aRoundAnsweredWrongLeavesTheGroupUnknown` (`:427`) also passes if the
  round asks nothing.

<a id="t5"></a>
### T5. Six assertions are tied to today's corpus (Reviewer, Low)

`QuizVerbMixTests.swift:37` hard-codes 3,572. `AblautPracticeTests` asserts 18 one-verb groups
(`:66`), fewer than ten verbs in singen's group (`:51`), two in werfen's (`:210`), 24 key
conjugations (`:415`), and three fresh verbs after `prefix(9)` (`:437`). The next import breaks
each. Compute the expectation, build the group with `madeGroup`, or say in a comment that the
number is a tripwire, which is the standard browse fix T4 applied.

<a id="t6"></a>
### T6. Shared state is set up by hand and restored unevenly (Reviewer, Low)

- `Current.practice = PracticeStore(getterSetter: GetterSetterFake())` appears 72 times,
  `freshPractice()` is defined 11 times, and the helpers for reading signals 8 times.
- `quizLevel` is left changed by several suites, one of them at Advanced.
- Suites that never reset `Current.practice` leave wrong answers in the shared store, which come
  due at the next midnight.
- `Quiz.generateQuestions` reads the `KONJUGIEREN_QUIZ_FIXTURE` default in debug builds
  (`Quiz.swift:551`), and the test host shares the simulator's defaults. The journal records a
  run that failed because "sentences" had been left set. Nothing guards against it.
- `RoundTests`' helper answers a choice item through `submitAnswer`, a path the app never takes,
  so those tests never exercise `submitChoice`.
- Three tests compare `QuizErrorHistory`'s count before and after. The history keeps 200
  records, so the count stops moving once it is full (Suspected: I did not count how many a full
  run records before them).

**Fix.** One helper file with a scoped fresh practice that restores the level, a driver that
answers each kind of question as the app would, and the signal reader. Skip the fixture switch
under `World.isRunningUnitTests`.

<a id="t7"></a>
### T7. The suite depends on the simulator's language (Read, Low)

Five pedagogy tests assert English text, and the scheme sets no test language, which is why the
suite must be run with `-testLanguage en`. Setting the language and region on the scheme's test
action would make `run_tests.sh` right on any simulator and retire that instruction from
`CLAUDE.md`. Asserting on the `L.` accessor instead would make each of these a tautology.

<a id="t8"></a>
### T8. Both content checks fold ß on both sides (Reviewer, Low)

`GapSentenceTests.everyBlankIsTheConjugatorsConjugation` and
`ChoiceQuestionTests.bothSentencesAreTheConjugatorsConjugations` compare a folded answer with a
folded conjugation in every region. An authored "{muß}" or "{weiss}" would pass for a learner in
the north. Every ss now in the data is legitimate. The two checks are also one loop written
twice.

**Fix.** Compare the north's and Austria's spellings exactly and fold for Switzerland alone, in
one shared helper.

<a id="t9"></a>
### T9. One duplicate, and what has no test (Reviewer, Low)

`QuizVerbMixTests.aTenQuestionQuizMixesToo` (`:118`) repeats two other tests' Intermediate case.
Behavior that no test reaches, by risk, beyond what the findings above name:

1. A miss, then a right re-ask, and what My Mistakes holds ([L2](#l2)).
2. A repaired diagnosis and the record ([L3](#l3)).
3. The Speed Round's no-repeat rule across a batch boundary in a running quiz.
4. The challenge's key around midnight and a change of time zone.
5. Choice exclusion across more than one Ten More, and the wrap once every choice is asked.
6. `DailyChallenge.draw` when all twenty attempts repeat a verb.
7. A mixed ablaut round when the known groups change between rounds.

## Decisions for Josh

Each was a question the code cannot settle. **Josh answered all fifteen on 2026-11-27**, and the
answer follows each decision. The options are kept so that a later reader can see what was
weighed. Build to the answer. Where an answer leaves a list or a line for Josh to review, the
phase says so, and its session brings him that before building on it.

<a id="d1"></a>
**D1. Which conjugations should the quiz never ask?** ([L1](#l1))

- (a) Neither a modal's Imperativ nor an impersonal verb's first and second persons and
  Imperativ, in any quiz, the challenge and the widget included. The corpus marks them on the
  reading, from a list Josh reviews.
- (b) The modals' Imperativ only, by a rule in the code, leaving impersonal verbs for later.
- (c) As now.

**Answered (Josh, 2026-11-27): (a).** Wollen is excluded with the other five modals, though
"wolle" survives in elevated German. The verb page is left alone: this plan changes what the
quiz asks, not what the tables show.

<a id="d2"></a>
**D2. When does a miss leave My Mistakes?** ([L2](#l2))

- (a) On a right answer that is neither a re-ask nor a repaired second attempt: in a later
  question on the same item, or in My Mistakes itself.
- (b) As now, on any right answer, the re-ask's included.

**Answered (Josh, 2026-11-27): (a).** A right re-ask and a right second attempt, a slip's
included, leave the miss on the list.

<a id="d3"></a>
**D3. What does a repaired diagnosis do to the record?** ([L3](#l3))

- (a) It counts as wrong for the record: the item starts over and enters My Mistakes. The half
  points stay.
- (b) It counts as neither: the item keeps its box and its due date, and enters My Mistakes.
- (c) As now, it counts as right.

**Answered (Josh, 2026-11-27): (a).** A slip's repair still counts as right for the box, once
[L4](#l4) has made a slip mean a typing slip. The ruling does not say whether a repaired
diagnosis goes into `QuizErrorHistory`, which today records only a wrong final answer. Leave
that as it is, and say so to Josh when the phase is handed over.

<a id="d4"></a>
**D4. Are "arbeitst" and "reisst" slips?** ([L4](#l4))

- (a) Leave them as slips. Simplest.
- (b) Name them, with two new lines for Josh to review in both languages, such as "A stem
  ending in t or d takes -est." and "After s, ß, x, or z, du adds only -t."
- (c) Wrong at once, with no second attempt.

**Answered (Josh, 2026-11-27): (b).** They prompt a repair like any diagnosis, so under
[D3](#d3) a repaired one counts as wrong for the record. Josh reviews the two lines in both
languages before they ship.

<a id="d5"></a>
**D5. Which answers may raise a strong verb's key conjugation?** ([L5](#l5))

- (a) A wrong answer on any cell of the stem still sends the item back. A right answer raises it
  only on a cell that shows what the key conjugation shows: for the Präsens, a person or
  Imperativ whose stem differs from the infinitive's, or any person where the verb has no such
  change; for the Perfekt, a cell with its auxiliary.
- (b) The cells that show nothing (the Präsenspartizip, and persons that keep the infinitive's
  vowel) become patterns, as the Futur already is.
- (c) As now.

**Answered (Josh, 2026-11-27): (a).**

<a id="d6"></a>
**D6. How far can the review card raise an item, and what does dismissing it do?**
([L6](#l6), [L19](#l19))

- (a) A reveal raises an item no further than the second box, so that only a typed answer
  reaches mastery.
- (b) After the reveal the card asks "Knew them" or "Didn't", and only the first raises.
- (c) A reveal reschedules and never raises, as Name the Conjugation moves nothing.
- (d) As now.

And for a card dismissed unrevealed: (i) hide the card for the day and leave its items due for
Review and the daily session, or (ii) as now, snooze the items.

**Answered (Josh, 2026-11-27): (a), and (i).** An item already in the second box or above is
rescheduled by a reveal at its own box. This replaces browse Phase 15's rules that a revealed
card always moves an item up and that a dismissal snoozes it.

<a id="d7"></a>
**D7. When does opening a verb's page send its key conjugations back to the first box?**
([L7](#l7))

Josh set this rule on 2026-11-13 and kept it for the widget on 2026-11-25, in both cases before
anything read the box as mastery.

- (a) Never. A lookup only enters items that are not yet in the record.
- (b) Only from search, the one route that says "I had to look this up". Not from a correction's
  link, My Verbs, a related verb, a collection, the widget, or a link.
- (c) From any route, but one box down rather than to the start.
- (d) As now.

**Answered (Josh, 2026-11-27): (b).** This replaces the rulings of 2026-11-13 and 2026-11-25,
the widget's included. Every other route enters a verb's items if they are new and demotes
nothing. The Mastery page's verbs link to their pages again, by a route that does not demote,
and Test Me's right answers can raise an item.

<a id="d8"></a>
**D8. Two rulings on the weak-verb line.** ([L8](#l8))

- **Doublets.** Should webte, saugte, and glimmte be accepted beside wob, sog, and glomm? This
  needs Duden's entries read, which the review did not do. The audit's E3 row also left open a
  weak doublet's Konjunktiv II (melkte beside mölke).
- **hauen and backen.** Their stems never change, so "its stem changes too" is false. A new line
  for a verb that is irregular only in its participle, or no line?

**Answered (Josh, 2026-11-27).** Doublets: the session reads Duden's entries and brings Josh a
list to rule on, as Phase 1 of the pedagogy plan did. Nothing about these verbs is built before
he rules. hauen and backen: a new line, such as "hauen's participle ends in -en: gehauen.",
which Josh reviews in both languages.

<a id="d9"></a>
**D9. What does a round do when its scope has fewer than ten distinct questions?** ([L9](#l9))

- (a) It is shorter. A one-verb group at Beginner asks its nine.
- (b) It repeats to reach ten, with repeats as far apart as the round allows.

And should Ten More avoid the questions of the session's earlier rounds while others remain?

**Answered (Josh, 2026-11-27): (a), and yes.**

<a id="d10"></a>
**D10. What is the mix a promise about, and what does a ranked round hold?**
([L11](#l11), [L14](#l14), [L16](#l16))

- **The mix.** (a) The whole round of ten: draw ten, then let due items and the choice take
  slots of matching role and strength where they can, and count the choice's verb. (b) The drawn
  questions alone, with the report corrected to say so.
- **Due items in a ranked first round.** (a) Keep them. (b) Mix them in from Ten More on, so
  that every ranked round is the level's own mix. (c) Rank only a round with none.
- **The choice question's ten points.** (a) Keep the round out of 100, as Phase 19 decided. (b)
  Leave the choice out of the posted score and scale the nine.

**Answered (Josh, 2026-11-27): the mix (a), due items (b), the points (a).** The second answer
narrows his ruling of 2026-11-13 that a default session mixes in up to three due items: the
first round now has none, and Ten More, the daily session, and Review ask them.

<a id="d11"></a>
**D11. Two rulings on the daily challenge.** ([L12](#l12), [L13](#l13))

- **A quit challenge.** (a) It is taken, with its unanswered questions counted wrong. (b) It may
  be taken again, and its result cannot be shared. (c) As now.
- **Across versions.** (a) Accept "the same within a version", say so in the report, and put a
  content version in the link, so that the app can say when a friend's link comes from another
  version. (b) Freeze a list of verbs for each level, versioned, so that an import leaves
  challenges alone. (c) Put the five questions in the link.

**Answered (Josh, 2026-11-27): (a), and (a).** A challenge is taken from its first answer, and
leaving the app during one counts as quitting it.

<a id="d12"></a>
**D12. Should a choice question's English show before the choice?** ([L14](#l14))

- (a) After it, with the reason.
- (b) As now.

**Answered (Josh, 2026-11-27): (a).**

<a id="d13"></a>
**D13. Does leaving the app pause the Speed Round?** ([L15](#l15))

- (a) No. The minute is a minute.
- (b) Yes, as now, with the clock measured in time rather than ticks.

**Answered (Josh, 2026-11-27): (a).**

<a id="d14"></a>
**D14. Three rulings under Decision 5.** ([P1](#p1), [P3](#p3), [P4](#p4))

- **An ablaut group's key.** (a) No quiz or share signal names an ablaut group. It sends the
  class, `ablautGroup`, and the three fixed lists keep their keys. (b) Only the 18 one-verb
  groups are withheld. (c) Keep the keys, and say in the docs and the policy that a group's name
  is sent.
- **A record session's rounds.** (a) One `completeQuiz` for a Review or My Mistakes session, at
  its first round. (b) Accept "more than ten" as coarse enough, and correct the staged sentence.
- **`speedRound` and `ablautMixed`.** Extend the ruling of 2026-11-15 on `mistakes` and
  `quizCorrection` to these two, as surfaces, and record it? Or stop sending them?

**Answered (Josh, 2026-11-27): (a), (a), and yes, they are surfaces.** The first answer covers
`startQuiz` and `tapShareCollection`. It was not asked of `viewCollection`, which keeps an
ablaut group's key outside a correction, as the browse plan decided.

<a id="d15"></a>
**D15. Two rulings on a shared practice set.** ([C8](#c8), [C9](#c9))

- **What a shared My Verbs carries.** (a) The starred verbs alone. (b) As now, with the menu
  saying how many verbs go and how many were left out.
- **The cap.** A list of 30 makes a code a classroom can scan. A list of 100 does not. Which
  matters more for a QR code, and should a link, which has no such limit, keep 100?

**Answered (Josh, 2026-11-27): (a), and 30 verbs for a QR code, 100 for a link.** The QR screen
says so when the list is longer than its code carries.

## How to Work This Plan

**Choosing a phase.** Take the lowest-numbered phase that is not done and whose dependencies
are done. Each phase names its dependencies. If a phase proves
too large for one session, split it, say so in its row, and leave the remainder "Partly done".

**Find code by name.** Every finding gives a type and a function with its line. The line is that
of `8f0c3db`.

**A finding labelled Suspected or Reviewer is not yet a fact.** Confirm it in the code, or by
running something, before fixing it. If it turns out not to be real, say so under the finding and
in **How it differed**, and move on.

**Ask Josh rather than guess.** His answers of 2026-11-27 are under Decisions for Josh, and each
phase restates the ones it builds. Where an answer does not settle a question that comes up,
ask him before building the part that depends on it, and record his answer and its date in
**How it differed** and under the decision above.

**What this plan leaves to you.** The phases say what to fix and what must hold afterward. Each
finding suggests a fix, and a better one is welcome. Record in **How it differed** anything that
departs from the phase as written. A later session relies on that note more than on the phase
text.

**Every phase finishes the same way.**

1. Each fix gets a test that fails without it, following
   [`KonjugierenTests/CLAUDE.md`](../KonjugierenTests/CLAUDE.md). Run the new test against the old
   code first and see it fail. Where a property is guaranteed by construction, test it over many
   seeds or on a pool small enough that chance cannot pass it ([T3](#t3) is what happens
   otherwise). Inject dates, and do not read the wall clock.
2. Build and run the suite with the `ios-build-verify` skill, as `CLAUDE.md` describes, in
   English: `xcodebuild … -testLanguage en test`, until Phase 14 makes that the scheme's own
   setting. **Read the run's test count, not only its exit status.** The baseline at `8f0c3db` is
   1,062 tests in 107 suites, the two skipped harnesses among them.
3. Run `swiftlint` from the repo root. The tree stays at zero violations.
4. For a change a learner can see, launch the app and look, on the Konjugieren iPhone 17 in
   German and in English and on the Konjugieren iPad Pro 11, as `CLAUDE.md` § Konjugieren's own
   simulators describes. The quiz's `KONJUGIEREN_QUIZ_FIXTURE` default gives fixed questions.
   Remove the default afterward. Say in **How it differed** what was tried on each device.
5. Localize any new string in English and German, following `CLAUDE.md`'s rules for
   `Localizable.xcstrings`. A new state needs a VoiceOver announcement a learner can act on
   ([`docs/voiceover.md`](../docs/voiceover.md)).
6. A change to a signal, a parameter, or a value is staged in
   [`docs/privacy_policy_pending.md`](../docs/privacy_policy_pending.md) in both languages and
   reflected in [`docs/feature_architecture.md`](../docs/feature_architecture.md) § Analytics.
   No signal may carry an answer, a score, an accuracy, or a verb.
7. Update [`docs/project_structure.md`](../docs/project_structure.md) for new, renamed, or
   repurposed files, correct any other doc the fix makes untrue, and run
   `python3 scripts/check_docs.py`. A task left for release time goes in
   [`docs/release.md`](../docs/release.md).
8. Under each finding fixed, in this file, add a line saying it was fixed on `main`, with the
   date and the phase, and how if not as suggested. Fill in the Status row with "Awaiting Josh",
   write **How it differed**, and append a journal entry to `docs/blog_notes.md`.
9. **Stop before git.** Do not run `git add`, `git commit`, or `git push`. Tell Josh what
   changed and how to try it: which screens to open, and what to type or tap. When he says he
   has tried it and to commit, commit and push to `main`, set the row to "Done", and record the
   hash in the Commit cell with a one-line follow-up commit, since a commit cannot contain its
   own hash. This holds for every phase and the Closing (Josh, 2026-11-27).

**A probe is not a test.** A temporary suite that prints what the code does is a good way to
confirm a finding. Delete it before the phase's final run, since it changes the test count that
`check_docs.py` compares with `README.md`.

**No release before 2027.** Everything accumulates on `main`. Nothing here has reached a
learner, so no stored format needs a migration unless the code already promises one.

**Konjugieren only.** Do not port a fix to Conjuguer or Conjugar. The Closing lists what would
carry over.

## Decisions Already Made

These bound the fixes. Each is Josh's, with its date, from the pedagogy plan and the browse
fixes.

- **Practice, not examination** (Decision 2). Where a choice between the two arises, choose
  practice.
- **No signal carries an answer, a score, an accuracy, or a verb** (Decision 5). `mistakes` and
  `quizCorrection` are surfaces and stay (2026-11-15).
- **A right second attempt and a right re-ask earn half points** (T1.6, 2026-11-13). No fix here
  changes points.
- **Re-ask once, not until correct** (T3.1).
- **Every class of diagnosis prompts a repair**, and one line serves the prompt and the
  correction (2026-11-14). [D3](#d3) asks what the repair does to the record, not whether to
  prompt.
- **Levels are chosen, not earned**, and what was opened does not shape the default quiz (T2.4).
- **A challenge is taken once**, and it asks no re-ask (2026-11-15).
- **The Speed Round records nothing in the practice record** (2026-11-13, 2026-11-15).
- **Recognition and choice answers move neither the record nor the error history**
  (2026-11-15).
- **Reset Practice keeps the challenge results** and clears the error history and first opens
  (2026-11-14, 2026-11-25).
- **No "principal parts" label**, in the interface or in a code name.

Josh's fifteen answers of 2026-11-27 are under [Decisions for Josh](#decisions-for-josh). Three
of them replace an earlier ruling: [D6](#d6) the review card's, [D7](#d7) the lookup's, and
[D10](#d10) the due items' place in a default quiz's first round.

Defaults this plan chose without asking, because the review left one reasonable course. Josh may
overrule any of them:

- **[L4](#l4).** An edit inside the letters the conjugator marks irregular is not a slip. The
  cell check takes the spellings grading takes.
- **[L10](#l10).** A custom quiz relaxes a restriction only for a conjugationgroup the learner
  chose.
- **[L21](#l21).** The frame's own word, typed into the blank, is forgiven, as a pronoun is in a
  finite cell.
- **[C3](#c3).** A daily session counts for the day it began.
- **[T7](#t7).** The scheme's test action runs in English.

## Phase 1: A Slip Is a Typing Slip

**Findings:** [L4](#l4) except its ending rules, [L20](#l20), [L21](#l21), [S4](#s4).
**Depends on:** nothing. **Decisions:** none.

- One function returns a cell's lenient spellings: every region, both clauses,
  `StandardVariants`, and digraphs. `Quiz.makeQuizItem`, the cell check that `QuizItem.isSlip`
  and `AnswerDiagnoser` use, and `AnswerDiagnoser.cell(of:)` call it. `Verb.conjugations(matching:)`
  keeps its strict behavior for search, which names cells of the conjugator's own tables.
- `QuizItem.isSlip` refuses an edit that falls inside the letters the conjugator writes in
  capitals for the asked cell, and counts `AnswerSlip.minimumLetterCount` on the conjugation's
  own spelling.
- `QuizItem.difference(from:)` does not mark a digraph or ss that grading accepts.
- `AnswerFrame.answer(filling:)` drops a blank's last word when it is the word that follows the
  blank, and `AnswerSpelling.normalized` strips a trailing "!" or ".".
- Name the umlaut maps in one place, and compute a wrong answer's diagnosis once in
  `Quiz.submitAnswer`.

**Done when** tests pin, each failing on the old code: "sung", "gesangen", "gehelfen", "kame",
and "geschreiben" are not slips, and "sanf" and "komst" still are; "faehrt" for du fährst and
"laeuft" for du läufst get the diagnosis "fährt" and "läuft" get; "stünden" and "kämt" are not
slips; "neh" for näh is not a slip; "faehrts" has neither its a nor its e marked; "gehen Sie" in
a Sie Imperativ's blank and "komm!" are right. `AnswerSlipTests`, `AnswerDiagnosisTests`,
`AnswerDifferenceTests`, and `AnswerFrameTests` pass, with any changed expectation explained.

**How it differed:**

## Phase 2: Diagnoses That Are True

**Findings:** [L8](#l8), and [L4](#l4)'s ending rules. **Depends on:** Phase 1.
**Decisions:** [D4](#d4), [D8](#d8), both answered. Two things still come to Josh during the
phase: the Duden list, and three new lines.

- `AnswerDiagnoser.weakConjugation()` returns nothing when the weak cell is itself a cell of the
  reading, so that `otherCell()` names it.
- The mixed line says the stem changes only where the asked cell's stem does.
- `otherCell()` prefers a conjugationgroup whose matching persons include the asked person.
- **The ending rules ([D4](#d4)).** Two new classes of diagnosis, each an exact construction as
  `weakConjugation()` is: the asked cell conjugated without its epenthetic e (arbeitst), and
  without the s-stem's reduction (reisst). They are checked before the slip and prompt a repair.
  Draft a line for each in English and German and bring them to Josh.
- **hauen and backen ([D8](#d8)).** A third new line, for a mixed reading whose asked cell
  differs from the weak one only in the participle's ending. Bring it to Josh with the other
  two.
- **The doublets ([D8](#d8)).** Read Duden's entries for weben, saugen, and glimmen, and for a
  weak doublet's Konjunktiv II, the row the variant audit left open. Write the list beside
  [`pedagogy_phase1_variant_audit.md`](pedagogy_phase1_variant_audit.md), bring it to Josh, and
  build only what he rules standard.

**Done when** tests pin: "könnte" for konnte is named the Präteritum Konjunktiv II, and the same
for müsste and dürfte; "solle" for ich soll is named the Konjunktiv I; "gehaut" and "gebackt" get
the new line and none that says the stem changes; "fahre" for er führe is named the Konjunktiv I;
"arbeitst" and "reisst" get their lines and are not called slips; and webte, saugte, and glimmte
are graded as Josh ruled.

**How it differed:**

## Phase 3: What an Answer Does to the Record

**Findings:** [L2](#l2), [L3](#l3), [L5](#l5), [C6](#c6). **Depends on:** Phase 1, which decides
what a slip is. It does not wait for Phase 2: a diagnosis class added later takes the
diagnosis's row below without further work. **Decisions:** [D2](#d2), [D3](#d3), [D5](#d5), all
answered.

- Thread `Quiz`'s injected clock to every read and write of the record first: `recordPractice`,
  the default round's due items, a record session's items, `canContinue`, `startDate`, the last
  result's date, and the error history's timestamp. The tests below need it.
- `PracticeRecord.recordAnswer` learns what kind of answer it records. What each does:

  | Answer | The box | `lastAnswerWasRight` |
  |---|---|---|
  | Right at the first attempt | Up when due, as now | True, which takes a miss off My Mistakes |
  | Wrong | Back to the first, as now | False |
  | A slip's right repair | Up when due, as now | Left as it was ([D2](#d2)) |
  | A diagnosis's right repair | Back to the first ([D3](#d3)) | False ([D3](#d3)) |
  | A right re-ask | Unchanged, as now, since the item is not due | Left as it was ([D2](#d2)) |

  A re-ask's own second attempt follows the re-ask's row when it is right. The half points are
  untouched throughout.
- `PracticeItem.exercised(by:of:readingIndex:)` says, with the item, whether a right answer on
  that cell may raise it ([D5](#d5)). A wrong answer on any cell of the stem still sends the
  item back. A right one raises it only on a cell that shows what the key conjugation shows.
  The rule should come from the conjugator, by comparing the cell's stem with the infinitive's
  and by whether the cell carries the auxiliary, and not from a list of persons.
- A right answer on a cell that may not raise the item still counts as a right first answer for
  My Mistakes.
- `QuizErrorHistory` is not covered by [D3](#d3). Leave it recording only a wrong final answer,
  and tell Josh so at the hand-over.
- Correct `recordPractice`'s comment.

**Done when** tests pin, with injected dates: a miss, then a right re-ask, leaves the item in My
Mistakes, and a right first answer on it in a later round takes it off; the same for a miss
whose re-ask is the round's last question; "gehte" then "ging" leaves the item in the first box
and in My Mistakes, with 5 points; a slip's repair raises a due item and does not clear a miss;
"wir fahren" right twice, three days apart, does not master fährt, and "er fährt" right twice
does; "geblieben" twice does not master the Perfekt item, and "ist geblieben" twice does; a
wrong "wir fahren" sends fährt back; a miss on day 0 is due in day 1's daily session.
`aShortReviewAsksWhatIsDueAndDoesNotContinue` no longer depends on the hour of the run.

**How it differed:**

## Phase 4: Lookups and the Review Card

**Findings:** [L6](#l6), [L7](#l7), [L19](#l19), [P9](#p9), and from [G4](#g4) the schedule's
comment and Mastery's intro. **Depends on:** nothing, though it edits `PracticeRecord` as Phase 3
does, so take them in order. **Decisions:** [D6](#d6), [D7](#d7), both answered.

- `PracticeStore.recordLookup` and `VerbVisitTracker.begin` take what they need by name (whether
  this visit reschedules, whether it is a return), not an `AnalyticsSource` to compare.
- **A lookup ([D7](#d7)).** Only a verb opened from search sends its key conjugations back to
  the first box. That is the search list's result, its guess, and Look Up a Verb: name the
  routes in one place and say which count as search. Every other route enters a verb's items if
  they are new and changes nothing else. The review card's open keeps its rule.
- **A reveal ([D6](#d6)).** It raises a due item to the second box at most. An item already
  there or above is rescheduled at its own box.
- **A dismissal ([D6](#d6)).** A card dismissed unrevealed is hidden for the day, and its items
  stay due. The card must not return the same day, so the day's dismissal needs remembering
  somewhere other than the items' due dates.
- **The Mastery page's verbs link to their pages again**, by a route that does not demote.
  Phase 20 of the pedagogy plan removed the links, and its note says where they were.
- Reword `ReviewSchedule`'s header and `Mastery.intro` (both languages) to say what the code now
  does. Correct `docs/feature_architecture.md` § The Review Card and § The Practice Record, and
  the Suppress Review Card and review-card strings if any of them states the old rules.

**Done when** tests pin: a verb in the fourth box keeps its box when opened from a correction,
My Verbs, a related verb, a collection, the widget, Spotlight, and a link, and returns to the
first when opened from search; a correction's link leaves the two stems that were not missed
where they were; Test Me's right answers on a verb just opened from its page raise a due item;
a lookup and two reveals leave a verb in the second box, not mastered, and Ten Strong at 0; a
card dismissed unrevealed leaves today's Review count unchanged and does not return that day;
the Mastery page opens a verb's page without demoting it.

**How it differed:**

## Phase 5: Conjugations German Lacks

**Findings:** [L1](#l1). **Depends on:** nothing. **Decisions:** [D1](#d1), answered. Josh still
reviews the list of verbs.

- **What is excluded ([D1](#d1)).** The Imperativ of all six modals, wollen's included. For an
  impersonal verb, the first and second persons of every conjugationgroup and the whole
  Imperativ. The participles and the third persons stay.
- **The list.** Draft the impersonal verbs of the corpus, with the source for each, and bring
  the list to Josh before marking any. Some verbs are impersonal in one reading only, so the
  mark belongs on the reading. Start from the top 1,000, which is what three of the four levels
  ask.
- **The mark.** A new attribute on the reading in `Verbs.xml`, through its DTD and the parser,
  documented in [`docs/adding_verbs.md`](../docs/adding_verbs.md). The modals may take the same
  mark or a rule, whichever leaves one place that answers "does this reading have this cell".
- **The verb page is left alone ([D1](#d1)).** Its tables, the widget's verb, search's reverse
  lookup, and the conjugation map keep every cell the conjugator builds.
- Every draw refuses an excluded cell: `QuizDraw.questions` and `mixedQuestions`,
  `recordQuestions` (a due item whose cell the verb lacks is skipped), the Speed Round's draw, a
  custom quiz and a practice set (the Imperativ of the modals asks nothing, and the screen says
  why), the challenge, and the widget's question. Sentences and choice items are authored, so
  check that none asks an excluded cell.
- Name the Conjugation is the reverse direction. A prompt that is right only as an excluded cell
  should not be offered that cell as an answer. Say in the note what was done there.
- Correct `docs/feature_architecture.md`'s example of a practice set.

**Done when** a test draws 1,000 default rounds a level and finds no excluded cell, a custom
quiz of the Imperativ over the modals starts nothing and says so, and the challenge's draw over
60 days has none. The core guarantee still holds at Beginner: two core questions a round, the
modals' in the Präsens.

**How it differed:**

## Phase 6: The Draw

**Findings:** [L9](#l9), [L10](#l10), [L11](#l11), [L16](#l16), [T1](#t1), and from [S5](#s5)
one answer to "would this level ask it". **Depends on:** Phase 5, which edits the same draw.
**Decisions:** [D9](#d9), [D10](#d10), both answered.

- A custom quiz relaxes a restriction only for a chosen conjugationgroup.
- **Distinct questions ([D9](#d9)).** A round's questions are distinct in verb, cell, and
  reading. Ten More avoids the session's earlier questions while unasked ones remain, and is not
  offered once the scope has none left. A scope with fewer than ten distinct questions gets a
  shorter round. The results, the progress dots, and the Live Activity already cope with a short
  Review.
- **A short round and the signals.** `completeQuiz`'s `questionCount` can then be below ten for
  a small scope. That says how small the scope is, not how the learner did, so it is within
  Decision 5. It is a new value all the same: stage it in
  `docs/privacy_policy_pending.md` and `docs/feature_architecture.md` § Analytics.
- **The mix is of the whole round ([D10](#d10)).** Draw ten slots with their roles and
  strengths, then let the choice question and, in Ten More, the due items take slots that match
  their role and strength where they can, counting the choice's verb as strong or weak. Extract
  the default round's composition into one pure function in `QuizDraw` that tests can call.
- **Due items join from Ten More on ([D10](#d10)).** A default quiz's first round has none, so
  that every ranked round is its level's own mix. This narrows the ruling of 2026-11-13. Correct
  the comments that give that ruling's reason, `docs/feature_architecture.md`, and the report's
  "Built on `main`" paragraph for Phase 11, which says each round of ten asks up to three.
- **The choice question keeps its ten points ([D10](#d10)).** Nothing changes there.
- One `QuizLevel` function answers whether the level asks a cell of a verb's reading, with and
  without the band, and `recordQuestions`, `GapSentence.isAskable(at:)`, and
  `Mastery.stems(askedAt:)` call it. Phase 8's reminder count will too.
- Rewrite the two tests of [T1](#t1) to assert what is guaranteed, over 40 or more seeds, and
  delete `aTenQuestionQuizMixesToo`.
- Correct `docs/pedagogy_research.md`'s paragraph on the mix.

**Done when** tests pin, over many seeds: singen's group as a custom quiz at Elementary asks no
Präteritum, and a chosen Präteritum Konjunktiv II over weak verbs still asks machte; no round of
any scope repeats a question; a one-verb group at Beginner asks nine questions and offers no Ten
More; Ten More over the modals collection asks none of round one's questions while others
remain; a round from `Quiz.start` has exactly five strong questions of ten at every level,
choice included, with at least two core and the level's prefixed-verb rule intact; a first round
with items due asks none of them, and its Ten More asks up to three.

**How it differed:**

## Phase 7: The Daily Challenge and the Choice Question

**Findings:** [L12](#l12), [L13](#l13), [L14](#l14), [C7](#c7), [T2](#t2), and from [G4](#g4)
the challenge's comment. **Depends on:** Phases 5 and 6, which change what the challenge draws.
**Decisions:** [D10](#d10) (the choice's points, which stay), [D11](#d11), [D12](#d12), all
answered.

- A bounded-integer pick, a shuffle, and an element pick over `SeededRNG.next()`, used on the
  challenge's path in place of the standard library's. `VerbDraw` has the precedent. Move
  `SeededRNG` to a file of its own.
- The three pins of [T2](#t2), and one challenge's draw pinned over a small made-up corpus.
- **A challenge is taken from its first answer ([D11](#d11)).** Keep its result as it goes. A
  quit, or the next launch after the app was left during one, closes it with the unanswered
  questions counted wrong, and that result shows on the hub and can be shared. A challenge
  started and quit before any answer is not taken.
- **A content version ([D11](#d11)).** The link carries it, and a link from another version
  opens a note saying the questions may differ, then the learner's own challenge for that day.
  A version that someone must remember to bump will be forgotten at a verb import, so derive it:
  a stable hash of what the draw reads (the band's infinitives in order) with a number for the
  draw's own code. Say in the note what was chosen and what changes it.
- Results kept by key, a date after today refused, the hub's key computed at the tap, and a
  taken challenge's result shown when its link is opened.
- **The choice's English shows after the choice ([D12](#d12))**, with the reason. VoiceOver
  reads it there too. Reword or replace `lesen.perfekt.1`'s distractor.
- The widget keeps showing the challenge's first question (Josh, 2026-11-27).
- Qualify `docs/pedagogy_research.md`'s paragraph on the challenge ("the same within a
  version"), and correct the comment on `DailyChallenge.questions(for:)`. Stage the link's new
  parameter where the shared text is described.

**Done when** tests pin: a challenge quit after one answer is taken, with four questions wrong,
and cannot be started again; one quit before any answer can; twelve challenges from links do
not reopen today's; a link dated tomorrow starts nothing; a link with another content version
is recognized; the generator's outputs; the replacement sampling's outputs; a pinned draw over
the made-up corpus; a choice card shows no English until a sentence is chosen.

**How it differed:**

## Phase 8: Clocks, Calendars, and the Reminder

**Findings:** [L15](#l15), [L17](#l17), [C1](#c1), [C2](#c2), [C3](#c3). **Depends on:** Phase 3
for the injected clock, and Phase 6 for the level's admissibility function.
**Decisions:** [D13](#d13), answered.

- The quiz's clock is a start date and, for the Speed Round, a deadline, read from the injected
  clock. The timer refreshes the display and runs in the common run-loop modes. Before fixing
  the scrolling part of [L15](#l15), confirm it: start a Speed Round on the simulator, hold the
  card, and watch Time Left.
- **The minute runs ([D13](#d13)).** Leaving the app does not pause a Speed Round. A round
  whose deadline passed while the app was away ends when it returns, with the question on
  screen dropped as at any time-up. Every other quiz still pauses its clock.
- The reminder's count is what the daily session would ask, capped at its length.
- `ReminderSchedulerReal.schedule` cannot be overtaken by an earlier call.
- `PracticeStore` holds `Calendar.autoupdatingCurrent`, and the reminder's plan and scheduler
  take the store's calendar.
- A daily session counts for the day it began.

**Done when** tests pin: a Speed Round ends at its deadline whatever the ticks and whatever
the scene's phase, and `pausingStopsTheClock` is rewritten to say that pausing does not stop a
Speed Round and does stop a default quiz; the reminder says 5 for the
Beginner of [L17](#l17); two plans scheduled in quick succession leave only the second's
requests (through a scheduler that the test can order); a session from 23:58 to 00:02 extends
the first day's streak.

**How it differed:**

## Phase 9: Privacy in the Code

**Findings:** [P1](#p1), [P2](#p2), [P3](#p3), [P4](#p4), [P8](#p8), [P10](#p10).
**Depends on:** nothing. **Decisions:** [D14](#d14), answered.

- Build the guard of [P8](#p8) first, at least its first step: the allow-list, and `AnalyticsSpy`
  recording an issue for a key or value outside it. Run the suite and see what it catches before
  changing a call site. If the suite shows the second step, the closed enum of signals, to be
  within a session's reach, take it. Otherwise leave it for the Closing to weigh.
- **No quiz or share signal names an ablaut group ([D14](#d14)).** `startQuiz` and
  `tapShareCollection` send `collection: ablautGroup` for any ablaut group, of one verb or of
  forty. `modals`, `sein`, and `top100` keep their keys. One function on `VerbCollection` gives
  the value a signal may carry, so that no call site reads `key` for a signal.
- **`viewCollection` was not part of the ruling.** It keeps an ablaut group's key outside a
  correction, as the browse plan decided. For a one-verb group that key is the verb viewed, and
  the policy says that which verb's page was opened is not recorded. If the session judges the
  two hard to hold together, ask Josh. Do not change it unasked.
- The collection bar's Share sends nothing that names the group on a page opened from a
  correction. With the ruling above it sends only the class, which settles [P2](#p2) for ablaut
  groups by itself. Carry the request's source to the bar anyway, so that the rule lives in one
  place.
- **One `completeQuiz` for a record session ([D14](#d14)),** at its first round. A later round
  of Review or My Mistakes sends none, and a quit during one still sends `quitQuiz` without a
  question number.
- **`speedRound` and `ablautMixed` are surfaces ([D14](#d14))** and stay. Phase 10 records the
  ruling in the pending policy's audit section, beside `mistakes` and `quizCorrection`.
- Delete "telemetry" from `QuizItem.correctAnswer`'s comment.

**Done when** a test starts a quiz over each one-verb ablaut group, by each route (a custom
quiz, a practice set, the collection's own quiz), and no signal's parameters contain the verb;
a test shares a group opened from a correction and finds no key; My Mistakes over two rounds
sends one `completeQuiz`; and every existing test passes under the allow-list.

**How it differed:**

## Phase 10: The Staged Policy and the Docs

**Findings:** [P5](#p5), [P6](#p6), [P7](#p7), [G1](#g1), [G2](#g2), [G3](#g3).
**Depends on:** Phase 9, since the text must say what the code then does, and Phases 6 and 7 for
[G1](#g1) if they have not already corrected the report. **Decisions:** none, but the staged
text will be published under Josh's name, so he reads every changed sentence in both languages
before the commit.

- Restage the "only as having happened" paragraph.
- The practice-record paragraph says that the app keeps the answers the learner got wrong, for
  the Tutor, and that opening a verb's page enters its conjugations in the record. One line for
  Handoff.
- The custom quiz's and practice set's bullets say what [D14](#d14) makes true: which of the
  three fixed lists, or that an ablaut group was chosen, and never which group.
- The audit section records that `speedRound` and `ablautMixed` are surfaces (Josh,
  2026-11-27), and that a Review or My Mistakes session reports its completion once.
- Correct the four rows of `docs/feature_architecture.md` § Analytics.
- Add the Camera's QR check to `docs/release.md`, under what a development build can settle.
- Re-run the Closing's audit of the pedagogy plan as a table in this phase's note: every signal,
  key, and value at HEAD, and the line of the policy or its pending file that covers it.

**Done when** every row of that table has its line in both languages, and `check_docs.py`
reports 0 problems.

**How it differed:**

## Phase 11: Sharing, Recognition, and the Record's Safety

**Findings:** [C4](#c4), [C5](#c5), [C8](#c8), [C9](#c9), [L18](#l18). **Depends on:** nothing.
**Decisions:** [D15](#d15), answered.

- `ConjugationMap.entries(for:)` folds ß to ss on both sides.
- A record that fails to decode is copied aside before anything overwrites it, and a test
  decodes a pinned string of today's format for the record, the streak, the level bests, the
  last result, and the challenge results.
- **A shared My Verbs is the starred verbs alone ([D15](#d15)).** The share menu and the set's
  summary say "starred verbs", so that the sharer knows what goes.
- **Two caps ([D15](#d15)).** A link carries up to 100 verbs, and a QR code the first 30. When
  the list is longer than its code carries, the QR screen says how many verbs the code holds.
  `theLongestListFitsACode` reads the densest code back and bounds its link's length.
- Reword `bringen.imperativ.1`'s English or replace the sentence, and run
  `scripts/gap_sentences.py` and `GapSentenceTests`.

**Done when** tests pin: in the Swiss region, "weiss" is right for weißen's Imperativ; a
malformed stored record leaves its bytes under the second key; a shared My Verbs holds no verb
that is not starred; a list of 40 makes a link of 40 and a code of 30; the worst-case code
decodes to its own link.

**How it differed:**

## Phase 12: One Shape for a Quiz's Modes

**Findings:** [S1](#s1), [S3](#s3), [S6](#s6), [S8](#s8). **Depends on:** Phases 3, 5, 6, 7, 8,
and 9, which all edit `Quiz.swift`. Refactoring under them would make each harder.
**Decisions:** none.

This phase changes no behavior. The suite's count and every expectation stay as they are, and a
test that must change is a sign that something moved.

- `QuizScope.Kind`'s cases carry their own state, and `continues`, `mixesVerbs`, and the
  distinct-cells rule ask the kind.
- `QuizItem` takes one `Prompt` in place of its optionals, and the exclusions become a struct of
  three typed sets.
- The fixtures and the announcements move to files of their own. Skip the fixture switch under
  `World.isRunningUnitTests`.
- If the session judges the mode value of [S1](#s1) to be within reach, build it, one mode at a
  time, with the suite green between. If not, say in the note how far it went and what the next
  step is.
- The small things of [S8](#s8).

**Done when** `Quiz.swift` holds `Quiz` and little else, no property of `QuizScope` infers the
mode from a count or a nil, and the suite passes unchanged.

**How it differed:**

## Phase 13: The Hub and the Store

**Findings:** [S2](#s2), [S7](#s7), and the rest of [S5](#s5). **Depends on:** Phase 12.
**Decisions:** none.

- `QuizHubView`, with a model that computes its rows from one injected date and refreshes when
  the day changes, which also settles the stale row of [C7](#c7) if Phase 7 left it. One card
  modifier for the hub's three kinds of row.
- `Current.resetPractice()` and `hasPracticeToReset`, covering first opens.
- One test of "mastered" on the record, which the Speed Round calls. One helper for days.
  Delete `QuizDraw.questions(level:…)` or give it a caller.
- This phase changes the Quiz tab's code and should not change its look. Compare screenshots of
  the hub before and after, in German and English, on both devices.

**Done when** `QuizView.swift` shows a question and nothing of the hub, the hub's rows are
tested through its model with an injected date, and a learner who has only opened weak verbs can
reset.

**How it differed:**

## Phase 14: Tests That Prove What They Claim

**Findings:** [T3](#t3), [T4](#t4), [T5](#t5), [T6](#t6), [T7](#t7), [T8](#t8), [T9](#t9),
[G5](#g5). **Depends on:** every phase before it, each of which took the tests of its own
findings. This phase takes what is left. **Decisions:** none.

- Rewrite the six tests of [T3](#t3) and the four of [T4](#t4). For each, break the code under
  test by hand, see the new test fail, and restore the code. Say in the note which mutation each
  was tried against.
- Compute, build, or mark as a tripwire each corpus-coupled number of [T5](#t5).
- One helper file for the fixtures of [T6](#t6): a scoped fresh practice that restores the
  level, a driver that answers a choice with `submitChoice`, and the signal reader. Add the
  guard to `Quiz.submitAnswer` once no test relies on its absence.
- Set the scheme's test language to English and its region to the United States. Confirm that
  `run_tests.sh` then passes on the German simulator, and take `-testLanguage en` out of
  `CLAUDE.md` and this plan's step 2.
- The content checks compare exactly outside Switzerland, in one helper.
- The untested behaviors of [T9](#t9) that no earlier phase covered, and the sweep of
  `StandardVariants`' keys.

**Done when** each rewritten test has failed against its mutation, the suite passes through
`run_tests.sh` with no language flag, and no test in the pedagogy files reads the wall clock for
a date it compares.

**How it differed:**

## Closing

- Run the full suite, `swiftlint`, and `check_docs.py`.
- Confirm that every finding in this file carries a line: fixed, found not to be real, or left
  with its reason.
- Re-read the phase notes of this plan for anything a phase deferred, and either do it or list
  it in [`docs/roadmap.md`](../docs/roadmap.md).
- Confirm that the Closing's privacy audit in the pedagogy plan and Phase 10's table here agree
  with `Analytics.swift` at HEAD.
- Write what would carry over to Conjuguer and Conjugar, as the two earlier plans' Closings did.
  Most of the findings under "What the Learner Is Taught" concern designs that the siblings will
  port, so the list is worth more here than it was for the browse fixes. Neither sibling is to
  be changed.
- Mark this plan finished in its Status section.

**How it differed:**
