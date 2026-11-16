# App Usage: TelemetryDeck and App Store Connect

A snapshot of every usage number TelemetryDeck and App Store Connect hold for the three
conjugation apps, pulled on **2026-11-10** as input to work on growth and engagement.
TelemetryDeck figures run through the end of 2026-11-10 UTC; App Store Connect's latest day was
2026-11-08. Nothing here is a recommendation; the "Observations" sections only point at what the
numbers say most loudly.

The two sources answer different questions. **TelemetryDeck** sees what people do inside the app,
from first launch onward, for every user. **App Store Connect** sees the store funnel upstream of
installation (impressions, product-page views, downloads, sources, territories) for each app's
whole life, but its in-app usage metrics cover only users who opted in to share analytics with
developers. The first half of this document is TelemetryDeck; the
[App Store Connect](#app-store-connect) half follows, and
[The China devices](#the-china-devices) reconciles the two.

TelemetryDeck data came from its dashboard (organization "Race Condition"), mostly via its
**Explore → Playground** TQL editor. App Store Connect data came from each app's **Analytics →
Metrics** explorer. There is no MCP server for either on this machine. The appendices record the
methods and gotchas, so a future session can refresh this document without re-deriving them.

| App | App Store ID | TelemetryDeck app ID | Language taught | On the App Store since | TelemetryDeck since |
|---|---|---|---|---|---|
| Konjugieren | `6758258747` | kept out of git, in `Konjugieren/Secrets.xcconfig` | German | 2026-03-13 | 2026-03-10 (pre-release) |
| Conjuguer | `1588624373` | kept out of git, in `Conjuguer/Secrets.xcconfig` | French | 2021-12-14 | July 2026 (commit 2026-06-30, replacing Amplify/AWS) |
| Conjugar | `1236500467` | kept out of git, in `Conjugar/Secrets.xcconfig` | Spanish | 2017-09-01 | August 2026 (commit 2026-07-18, replacing AWS Pinpoint) |

## Read this first: caveats

1. **The histories are different lengths.** Konjugieren has about eight months, Conjuguer about
   four, Conjugar about three and a half. All-time totals are therefore not comparable across apps.
   Prefer the per-month, last-30-day, and per-user figures. Conjuguer and Conjugar had years of
   users before TelemetryDeck; their earlier analytics (AWS) are not covered here.
2. **Konjugieren's TelemetryDeck history is complete.** App Store Connect dates Konjugieren's
   first day on the store to 2026-03-13. The first TelemetryDeck signal, on 2026-03-10, is one
   device sending 60 signals three days before release, which looks like App Review or Josh. An
   earlier draft of this document guessed that 2026-03-10 was a plan retention cutoff; the App
   Store date rules that out.
3. **Test-mode signals are excluded.** Debug builds send `isTestMode = true`, and every query
   here returned only `isTestMode = false` rows (the Explore page notes 94 hidden test-mode
   Konjugieren events in the last 30 days alone). App Store and TestFlight builds on Josh's own
   devices are **not** excluded. Konjugieren's single heaviest user (108 sessions on 49 distinct
   days, 2026-03-25 to 2026-10-30) holds 32.5% of all Konjugieren sessions. **If that is Josh's
   phone, Konjugieren's real usage is smaller still.** Josh is the only one who can confirm.
4. **"New installs" in the first month of Conjuguer and Conjugar are inflated.** TelemetryDeck's
   `TelemetryDeck.Acquisition.newInstallDetected` fires on the first launch of a build containing
   the SDK, so existing users who updated count as "new" that month.
5. **A "user" is a hashed device identifier.** One person with an iPhone and an iPad is two users.
   The same hash appears across all three apps for a given device (they share a vendor), which is
   what makes the cross-app overlap section possible.
6. **The Playground mislabels time buckets by one period** (see appendix). Every date in this
   document has been corrected to the true UTC period.
7. **20 of Konjugieren's 77 TelemetryDeck devices are not App Store users.** They are one-day
   visitors in China time (UTC+8) who tour every screen once and never return, and removing them
   leaves exactly App Store Connect's 57 lifetime downloads. See
   [The China devices](#the-china-devices). The TelemetryDeck tables below include them, as
   TelemetryDeck reports them; where it matters, the text gives the figure without them.
8. **None of the three apps can be released before 2027.** Josh said so on 2026-11-10: his
   present MacBook cannot cut a release, and he plans to replace it in 2027. From this snapshot
   until the next releases the apps do not change, so movement in these numbers reflects audience
   and season and not the apps. A refresh taken just before each release is the baseline to judge
   that release by.

## Headline numbers

| Metric | Konjugieren | Conjuguer | Conjugar |
|---|---:|---:|---:|
| Users, last 30 days (Oct 11 to Nov 10) | **10** | 96 | 77 |
| Users active since Nov 3 | **1** | 49 | 29 |
| Average daily active users, last 30 days | **0.60** | 10.4 | 7.43 |
| Days with zero users, last 30 days | **16** | 0 | 0 |
| Stickiness (avg DAU ÷ 30-day users) | 6% | 11% | 10% |
| Users, all retained history | 77 (57 without the China devices) | 192 | 178 |
| Sessions, all retained history | 332 | 1,060 | 915 |
| Signals, all retained history | 2,413 | 5,446 | 6,245 |
| Users who came back on a second day | 31.2% (42.1% without the China devices) | 56.8% | 44.9% |
| Users with exactly one session | 55.8% (42.1% without the China devices) | 33.9% | 47.8% |
| Median session length | 19 s | 11 s | 51 s |
| Quiz completions ÷ quiz starts | **0 of 45** (0 of 32 without the China devices) | 12 of 159 (7.5%) | 68 of 203 (33.5%) |
| New installs, Nov 1 to 10 | **0** | 15 | 11 |

## Observations

These are the patterns that stand out, stated as facts about the data.

- **Konjugieren's audience never grew.** Monthly users have sat between 11 and 17 since March, and
  monthly installs between 8 and 13 devices. October had 8 installs; November has had none so far. The
  1.3 corpus expansion (990 → 3,572 verbs) and 1.4 left no visible mark on installs.
- **Conjuguer and Conjugar each acquire roughly 4 to 7 times as many new users per month** as
  Konjugieren (40 to 68 versus 8 to 10, after their inflated first months).
- **No one has ever completed a Konjugieren quiz** in the retained data. The `completeQuiz`
  signal exists and its code path in `Quiz.finishQuiz()` looks correct, so the zero is real.
  The quiz is 30 questions long (`Quiz.questionCount`). Of 19 recorded quits, 13 came on question
  1, 5 on question 2, and 1 on question 4. The other 26 of 45 starts ended without either signal,
  which is what backgrounding or killing the app mid-quiz looks like. The China devices account
  for 13 of the 45 starts and 2 of the quits; the other 32 starts still produced no completion.
- **The first-question cliff is shared across all three apps.** 36% of Conjugar's quits and 49% of
  Conjuguer's happen on the first question. Conjugar is the only app where a meaningful fraction
  of quizzes finish, and almost all of those are on Easy difficulty.
- **Konjugieren's usage is concentrated in a handful of devices.** The top five users account for
  50.9% of sessions (versus 20.3% for Conjuguer and 31.1% for Conjugar). Of 77 users, 53 used the
  app on exactly one day (33 of 57 without the China devices).
- **Konjugieren's real audience is German-speaking and American.** By region: Germany 30, US 21,
  China 19 of 77. The China entries are not learners, though: 18 of them are the one-day UTC+8
  devices described in [The China devices](#the-china-devices), and Konjugieren is not sold in
  China at all. (The other two UTC+8 devices are set to region US.) Without the 20, Germany (30)
  and the US (19) make up 49 of 57 devices, which matches App Store
  Connect's download territories (Germany 29, US 13 of 52 first-time downloads). US installs
  stopped after August.
- **Conjuguer's audience is francophone, and much of it is African.** 92 of 192 users run their
  device in French. Ranked by users: US 51, Canada 21, France 17, DR Congo 16, Côte d'Ivoire 10,
  followed by a long tail of West and Central African countries (Mauritania, Mali, Cameroon,
  Republic of the Congo, Senegal, Nigeria, Guinea, and others).
- **Almost nobody uses more than one of the apps.** Only 2 devices appear in two apps, and none
  in all three.
- **The browse screens are the product.** In every app, verb browsing and the verb detail view
  dominate signal volume; quiz, game, tutor, and info screens trail far behind.

## Monthly trend

True UTC calendar months. November covers only Nov 1 to 10.

### Users and signals

| Month | Konjugieren users | Konjugieren signals | Conjuguer users | Conjuguer signals | Conjugar users | Conjugar signals |
|---|---:|---:|---:|---:|---:|---:|
| 2026-03 (from Mar 10) | 14 | 359 | | | | |
| 2026-04 | 17 | 421 | | | | |
| 2026-05 | 11 | 334 | | | | |
| 2026-06 | 11 | 179 | | | | |
| 2026-07 | 12 | 275 | 13 | 277 | | |
| 2026-08 | 12 | 374 | 67 | 1,049 | 54 | 1,030 |
| 2026-09 | 12 | 302 | 64 | 1,705 | 85 | 2,161 |
| 2026-10 | 11 | 165 | 96 | 1,769 | 78 | 2,422 |
| 2026-11 (1 to 10) | 1 | 4 | 54 | 646 | 32 | 632 |

### New installs and sessions

Each cell is *installs (devices)* / *sessions (devices with a session)*.

| Month | Konjugieren | Conjuguer | Conjugar |
|---|---|---|---|
| 2026-03 (from Mar 10) | 18 (12) / 49 (14) | | |
| 2026-04 | 14 (13) / 44 (17) | | |
| 2026-05 | 8 (8) / 12 (11) | | |
| 2026-06 | 9 (9) / 22 (10) | | |
| 2026-07 | 9 (9) / 47 (12) | 13 (13) / 27 (13) | |
| 2026-08 | 9 (9) / 72 (12) | 60 (60) / 175 (67), inflated | 54 (53) / 112 (54), inflated |
| 2026-09 | 10 (10) / 55 (12) | 42 (41) / 291 (64) | 68 (68) / 310 (85) |
| 2026-10 | 8 (8) / 30 (11) | 57 (57) / 413 (96) | 42 (42) / 380 (78) |
| 2026-11 (1 to 10) | 0 / 1 (1) | 15 (15) / 154 (54) | 11 (11) / 113 (32) |

Conjuguer's July row is probably also inflated by upgraders, since its first build with the SDK
shipped that month.

## Weekly trend, Aug 31 to Nov 10

ISO weeks starting Monday (UTC). Each cell is *signals / users*. The last row covers two days.

| Week of | Konjugieren | Conjuguer | Conjugar |
|---|---|---|---|
| Aug 31 | 79 / 5 | 298 / 23 | 615 / 28 |
| Sep 7 | 54 / 3 | 606 / 25 | 479 / 27 |
| Sep 14 | 98 / 4 | 356 / 27 | 429 / 30 |
| Sep 21 | 74 / 6 | 286 / 30 | 496 / 27 |
| Sep 28 | 31 / 1 | 374 / 28 | 559 / 31 |
| Oct 5 | 38 / 4 | 363 / 36 | 620 / 28 |
| Oct 12 | 11 / 4 | 447 / 33 | 268 / 22 |
| Oct 19 | 71 / 5 | 433 / 49 | 607 / 37 |
| Oct 26 | 14 / 3 | 358 / 38 | 680 / 27 |
| Nov 2 | 4 / 1 | 497 / 43 | 395 / 27 |
| Nov 9 (2 days) | 0 / 0 | 115 / 16 | 141 / 13 |

## Daily activity, last 90 days (Aug 12 to Nov 10)

| Metric | Konjugieren | Conjuguer | Conjugar |
|---|---:|---:|---:|
| Average DAU, last 30 days | 0.60 | 10.4 | 7.43 |
| Average DAU, last 90 days | 0.91 | 7.79 | 6.65 |
| Peak DAU, last 90 days | 4 | 18 | 13 |
| Zero-user days, last 30 | 16 | 0 | 0 |
| Zero-user days, last 90 | 34 | 1 | 0 |
| DAU, Oct 28 to Nov 10 | 1,0,2,0,0,0,0,0,0,0,1,1,0,0 | 6,15,10,18,8,11,11,9,12,11,6,12,10,8 | 13,12,7,8,4,7,11,6,3,2,5,8,11,5 |

## Retention and per-user engagement

Computed from one row per device over each app's whole retained history. "Active days" counts
distinct calendar days with any signal (device-local calendar).

| Metric | Konjugieren | Conjuguer | Conjugar |
|---|---:|---:|---:|
| Users | 77 | 192 | 178 |
| Median sessions per user | 1 | 2 | 2 |
| Mean sessions per user | 4.31 | 5.52 | 5.14 |
| Median signals per user | 23 | 14.5 | 14 |
| Median active days per user | 1 | 2 | 1 |
| Active on 1 day | 53 (69%) | 83 (43%) | 98 (55%) |
| Active on 2 days | 13 | 31 | 30 |
| Active on 3 to 4 days | 3 | 31 | 22 |
| Active on 5 to 9 days | 6 | 29 | 18 |
| Active on 10+ days | 2 | 18 | 10 |
| Came back on another day | 31.2% | 56.8% | 44.9% |
| Last seen ≥ 7 days after first seen | 22.1% | 43.8% | 34.8% |
| Last seen ≥ 30 days after first seen | 13.0% | 21.9% | 19.7% |
| Top user | 108 sessions, 49 days | 68 sessions, 50 days | 75 sessions, 34 days |
| Top user's share of signals | 12.9% | 4.0% | 6.5% |
| Top 5 users' share of signals | 27.4% | 15.6% | 26.2% |
| Top 5 users' share of sessions | 50.9% | 20.3% | 31.1% |

Konjugieren's longer history gives its users more time to accumulate days and spans, so its
retention figures are, if anything, flattered relative to the other two apps.

### Cohorts by month of first signal

Each cell is *users in cohort: came back another day / last seen ≥ 7 days later / ≥ 30 days later*.
Recent cohorts have had less time to reach the longer thresholds.

| First seen | Konjugieren | Conjuguer | Conjugar |
|---|---|---|---|
| 2026-03 | 14: 6 / 5 / 5 | | |
| 2026-04 | 13: 5 / 3 / 2 | | |
| 2026-05 | 8: 0 / 0 / 0 | | |
| 2026-06 | 9: 1 / 1 / 0 | | |
| 2026-07 | 9: 6 / 2 / 1 | 13: 7 / 6 / 3 | |
| 2026-08 | 8: 0 / 0 / 0 | 62: 40 / 35 / 24 | 54: 29 / 24 / 19 |
| 2026-09 | 10: 4 / 4 / 2 | 41: 28 / 20 / 12 | 69: 33 / 27 / 14 |
| 2026-10 | 6: 2 / 2 / 0 | 62: 30 / 22 / 3 | 43: 16 / 11 / 2 |
| 2026-11 | 0 | 14: 4 / 1 / 0 | 12: 2 / 0 / 0 |

The Conjuguer and Conjugar cohorts of their first month include long-standing users who merely
updated, which is why those cohorts retain best.

### Konjugieren's ten users in the last 30 days

| Sessions | Active days | Signals | First seen | Last seen |
|---:|---:|---:|---|---|
| 108 | 49 | 312 | 2026-03-25 | 2026-10-30 |
| 12 | 10 | 44 | 2026-09-14 | 2026-10-17 |
| 9 | 5 | 62 | 2026-03-31 | 2026-10-30 |
| 8 | 2 | 34 | 2026-10-24 | 2026-10-25 |
| 5 | 2 | 11 | 2026-04-09 | 2026-10-23 |
| 4 | 2 | 9 | 2026-10-13 | 2026-10-22 |
| 2 | 2 | 9 | 2026-09-06 | 2026-11-08 |
| 1 | 1 | 22 | 2026-10-11 | 2026-10-20 |
| 1 | 1 | 9 | 2026-10-28 | 2026-10-28 |
| 1 | 1 | 3 | 2026-10-15 | 2026-10-15 |

Three of the ten are long-tenure returners (first seen in March or April). The 2026-10-28 user is
a Mac (`Mac16,13`, the 15-inch M4 MacBook Air) running the iOS app.

## Session length

From `TelemetryDeck.Retention.previousSessionSeconds`, which TelemetryDeck attaches to each session
start, so it measures every session except each device's most recent one. TelemetryDeck ends a
session when the app goes to the background.

| Percentile | Konjugieren | Conjuguer | Conjugar |
|---|---:|---:|---:|
| 25th | 10 s | 5 s | 14 s |
| 50th (median) | 19 s | 11 s | 51 s |
| 75th | 65 s | 85 s | 211 s |
| 90th | 151 s | 278 s | 725 s |
| Sessions measured | 192 | 750 | 646 |

## Feature usage: all signals, all retained history

Each cell is *signals / distinct users*.

### Konjugieren

1.0 builds sent dotted names (`view.VerbView`), renamed to camelCase on 2026-03-19 (shipped in
1.1). Both are listed. Users cannot be summed across the two names, because a device that updated
appears under both.

| Signal | camelCase (1.1+) | dotted (1.0) |
|---|---|---|
| `viewVerbBrowseView` | 501 / 67 | 74 / 15 |
| `viewVerbView` | 369 / 47 | 64 / 10 |
| `viewSettingsView` | 141 / 46 | 29 / 10 |
| `viewInfoBrowseView` | 123 / 36 | 24 / 11 |
| `viewQuizView` | 123 / 40 | 31 / 10 |
| `viewInfoView` | 118 / 22 | 22 / 6 |
| `viewFamilyBrowseView` | 115 / 43 | 23 / 8 |
| `viewFamilyDetailView` | 85 / 27 | 19 / 5 |
| `startQuiz` | 32 / 27 | 13 / 6 |
| `quitQuiz` | 11 / 8 | 8 / 3 |
| `completeQuiz` | **0** | **0** |
| `startGame` | 14 / 11 | 3 / 1 |
| `tapPlayGame` | 13 / 11 | 1 / 1 |
| `loseGame` | 4 / 3 | 1 / 1 |
| `completeWave` | 0 | 13 / 1 |
| `tapRateOrReview` | 9 / 8 | |
| `tapShowOnboarding` | 4 / 4 | |
| `tapViewLeaderboard` | 4 / 4 | |
| `viewTutorView` | 3 / 1 | |
| `tapSendTutorMessage` | 2 / 1 | |
| `TelemetryDeck.Session.started` | 332 / 77 | |
| `TelemetryDeck.Acquisition.newInstallDetected` | 85 / 76 | |

Defined in `Analytics.swift` but never received from a non-test build: `completeQuiz`,
`completeWave` (camelCase), `tapDeleteChatHistory`, `tapExplainError`.

### Conjugar

| Signal | Signals / users |
|---|---|
| `viewVerbBrowseView` | 1,689 / 178 |
| `viewVerbView` | 1,355 / 119 |
| `viewModelBrowseView` | 321 / 83 |
| `viewQuizView` | 307 / 92 |
| `viewInfoBrowseView` | 234 / 68 |
| `startQuiz` | 203 / 68 |
| `viewModelView` | 201 / 41 |
| `viewOnboardingView` | 195 / 176 |
| `viewInfoView` | 150 / 35 |
| `viewSettingsView` | 150 / 68 |
| `quitQuiz` | 85 / 44 |
| `viewResultsView` | 82 / 14 |
| `completeQuiz` | 68 / 14 |
| `gameCenterAuthSucceeded` | 47 / 30 |
| `startGame` | 19 / 18 |
| `viewTutorView` | 15 / 12 |
| `tapPlayGame` | 12 / 11 |
| `tapShowOnboarding` | 11 / 9 |
| `tapSendTutorMessage` | 5 / 4 |
| `completeStage` | 4 / 4 |
| `tapRateOrReview` | 2 / 2 |
| `TelemetryDeck.Session.started` | 915 / 178 |
| `TelemetryDeck.Acquisition.newInstallDetected` | 175 / 174 |

### Conjuguer

Conjuguer sends one generic `viewAppeared` signal with a `viewName` parameter instead of one signal
per screen.

| Signal | Signals / users |
|---|---|
| `viewAppeared` (all screens) | 3,619 / 191 |
| … `VerbView` | 1,053 / 151 |
| … `VerbBrowseView` | 890 / 190 |
| … `MainTabView` | 707 / 191 |
| … `QuizView` | 217 / 85 |
| … `ModelBrowseView` | 191 / 82 |
| … `ModelView` | 168 / 54 |
| … `InfoBrowseView` | 146 / 66 |
| … `SettingsView` | 116 / 62 |
| … `InfoView` | 112 / 29 |
| … `QuizResultsView` | 12 / 7 |
| … `TutorView` | 7 / 5 |
| `gameCenterAuthSucceeded` | 260 / 78 |
| `quizStart` | 159 / 56 |
| `quizQuit` | 118 / 41 |
| `quizCompletion` | 12 / 7 |
| `gameCenterAuthFailed` | 10 / 7 |
| `tapPlayGame` | 10 / 7 |
| `tapShowOnboarding` | 11 / 7 |
| `TelemetryDeck.Session.started` | 1,060 / 192 |
| `TelemetryDeck.Acquisition.newInstallDetected` | 187 / 184 |

## Quiz funnel

| | Konjugieren | Conjuguer | Conjugar |
|---|---:|---:|---:|
| Quiz starts | 45 | 159 | 203 |
| Quits | 19 | 118 | 85 |
| Completions | 0 | 12 | 68 |
| Neither (app left mid-quiz) | 26 | 29 | 50 |
| Completion rate | 0% | 7.5% | 33.5% |
| Devices that ever completed | 0 | 7 | 14 |
| Quits on the first question | 13 (68%) | 58 (49%) | 31 (36%) |

**By difficulty** (signals / users):

- **Konjugieren:** every recorded quit was on `regular`. Starts carry no difficulty parameter.
- **Conjuguer:** Regular: 156 starts (54), 117 quits (41), 12 completions (7). Ridiculous: 3 starts
  (3), 1 quit, 0 completions.
- **Conjugar:** Easy: 158 starts (61), 75 quits (40), 38 completions (13). Moderate: 34 starts (8),
  8 quits (5), 22 completions (3). Difficult: 11 starts (3), 2 quits (2), 8 completions (1).

**Where quits happen** (question number, 1-based):

- **Konjugieren** (30 questions): Q1 13, Q2 5, Q4 1.
- **Conjuguer** (from `lastQuestionIndex`, converted to 1-based): Q1 58, Q2 18, Q3 19, Q4 5, Q5 3,
  Q6 2, Q7 1, Q8 2, Q9 2, Q10 1, Q12 1, Q13 2, Q14 1, Q16 1, Q17 1, Q26 1.
- **Conjugar:** Q1 31, Q2 14, Q3 8, Q4 6, Q5 3, Q6 1, Q7 4, Q8 2, Q9 2, Q10 1, Q11 3, Q12 1, Q13 1,
  Q14 2, Q16 1, Q17 1, Q20 1, Q21 1, Q22 1, Q30 1.

## Audience

All retained history, distinct users. A user who changes region or language mid-history counts in
both rows.

### Region (`TelemetryDeck.UserPreference.region`)

| Konjugieren | | Conjuguer | | Conjugar | |
|---|---:|---|---:|---|---:|
| DE | 30 | US | 51 | US | 110 |
| US | 21 | CA | 21 | ES | 20 |
| CN | 19 | FR | 17 | GB | 20 |
| AT | 2 | CD | 16 | CA | 6 |
| CH | 1 | CI | 10 | AU | 2 |
| LU | 1 | AU | 8 | CL | 2 |
| TR | 1 | GB | 8 | IE | 2 |
| UA | 1 | BE | 6 | MX | 2 |
| 001 (World) | 1 | CN | 5 | PH | 2 |
| | | MR | 4 | RU | 2 |
| | | CG, CM, MA, ML, NG, SN | 3 each | AO, BR, CR, DO, JP, PR, QA, SE, SG, SN, UA | 1 each |
| | | CH, DZ, GN, IE, IR, TN, UG | 2 each | | |
| | | AE, AZ, BF, BJ, BZ, CO, ET, HK, HT, IN, LB, MM, MU, TD, TR, TW | 1 each | | |

### Device language (`TelemetryDeck.UserPreference.language`)

| Konjugieren | | Conjuguer | | Conjugar | |
|---|---:|---|---:|---|---:|
| en | 33 | fr | 92 | en | 155 |
| zh | 19 | en | 86 | es | 12 |
| de | 16 | zh | 5 | fr | 4 |
| ru | 5 | ru | 3 | ru | 4 |
| fr | 2 | fa, tr | 2 each | zh | 2 |
| tr | 2 | de, es, nl, ti, uk, vi, yue | 1 each | tr | 1 |
| hu, pt | 1 each | | | | |

### Device family

| | Konjugieren | Conjuguer | Conjugar |
|---|---:|---:|---:|
| iPhone | 67 | 186 | 154 |
| iPad | 7 | 6 | 24 |
| Mac (iOS app on Mac) | 3 | 1 | 0 |

Konjugieren's 30-day model list, with TelemetryDeck's friendly names: iPhone 12 Pro (2), and one
each of MacBook Air 15-inch M4 (2025), iPad Air 11-inch (7th gen), iPhone 12 Pro Max, iPhone 13,
iPhone 13 Pro Max, iPhone 14 Pro Max, iPhone 16e, iPhone 18 Pro Max.

### App version (`TelemetryDeck.AppInfo.version`)

Each cell is *users / signals*. A device that updated counts once per version.

| Konjugieren | | Conjuguer | | Conjugar | |
|---|---|---|---|---|---|
| 1.0 | 15 / 395 | 2.0 | 34 / 558 | 3.0 | 70 / 1,419 |
| 1.1 | 21 / 462 | 2.1 | 67 / 1,155 | 3.1 | 133 / 4,826 |
| 1.2 | 27 / 920 | 2.2 | 137 / 3,733 | | |
| 1.3 | 8 / 185 | | | | |
| 1.4 | 18 / 451 | | | | |

### Konjugieren installs by region and month

From `newInstallDetected`, counted in devices. The rows sum to 78 against 76 distinct install
devices, because a device that reinstalled in a later month, or changed region, counts twice.

| Month | Installs | Breakdown |
|---|---:|---|
| 2026-03 (from Mar 10) | 12 | US 6, DE 4, CN 2 |
| 2026-04 | 13 | US 5, CN 4, DE 3, AT 1 |
| 2026-05 | 8 | US 4, DE 2, CN 1, UA 1 |
| 2026-06 | 9 | DE 6, CN 3 |
| 2026-07 | 9 | DE 5, AT 1, CN 1, LU 1, US 1 |
| 2026-08 | 9 | US 4, CN 3, DE 1, TR 1 |
| 2026-09 | 10 | DE 5, CN 4, 001 1 |
| 2026-10 | 8 | DE 6, CH 1, CN 1 |
| 2026-11 (1 to 10) | 0 | |

## Cross-app overlap

Only two devices appear in more than one app:

- One used **Konjugieren** (9 sessions on 4 days, 2026-03-16 to 2026-07-11), then tried **Conjugar**
  once on 2026-08-16.
- One used **Conjugar** (3 sessions on 2 days, 2026-08-22 to 2026-08-28) and opened **Conjuguer**
  once on 2026-08-22.

## App Store Connect

Everything in this half comes from App Store Connect's Analytics for each app, lifetime range,
through **2026-11-08** (the latest day it had). App Store Connect days are UTC.

### How App Store Connect's numbers differ from TelemetryDeck's

- **Store metrics** (impressions, product-page views, conversion rate, downloads, updates) count
  every App Store user. An *impression* is the app appearing in search results, browse lists, or
  Today; a *product-page view* is someone opening its page; *conversion rate* is downloads divided
  by unique-device impressions, App Store sources only.
- **Usage metrics** (active devices, sessions, installations, deletions, crashes, "active last
  30 days") are **opt-in only**: they cover devices whose owners agreed to share analytics with
  developers. Comparing "active last 30 days" on Nov 8 with TelemetryDeck's 30-day users suggests
  an opt-in share of roughly a half for Konjugieren (5 of 10) and Conjuguer (47 of 96) and a third
  for Conjugar (24 of 77).
- **App Store Connect suppresses small values.** Referrer detail (which app or website sent a
  visitor) reports "Not Enough Data" for all three apps, and retention charts report "Not Enough
  Data" too, so TelemetryDeck remains the only source for retention.
- **TelemetryDeck counts more installs than App Store Connect counts downloads**, by roughly 1.3
  to 1.5 times (for example Conjugar in September: 68 TelemetryDeck installs against 46 App Store
  downloads). For Konjugieren the gap is fully explained by the China devices; for the other two
  the cause is unconfirmed (candidates are device migrations and restores, which launch the app
  for the first time without a download).

### Availability (a deliberate policy)

Each app is offered only in English-speaking countries and in countries that speak the language it
teaches, because Josh localizes each app into English and its target language only and will not
release an app where it is not localized. Of App Store Connect's 175 countries and regions:

| App | Available in | Of note |
|---|---:|---|
| Konjugieren | 43 | English-speaking countries, plus Germany, Austria, Switzerland, Luxembourg, Belgium, and the Netherlands |
| Conjuguer | 77 | English-speaking and francophone countries, including France, Belgium, Switzerland, Lebanon, Vietnam, and much of West, Central, and North Africa |
| Conjugar | 41 | English-speaking and Spanish-speaking countries, including Spain and most of Latin America |

None of the three is available in China.

### Lifetime totals

| Metric | Konjugieren (since 2026-03-13) | Conjuguer (since 2021-12-14) | Conjugar (since 2017-09-01) |
|---|---:|---:|---:|
| Impressions | 1,290 | 53,744 | 83,627 |
| Product-page views | 204 | 4,644 | 8,783 |
| Conversion rate | 7.05% | 5.40% | 5.93% |
| First-time downloads | 52 | 3,870 | 3,161 |
| Redownloads | 5 | 192 | 358 |
| Total downloads | 57 | 4,062 | 3,519 |
| Updates | 76 | 6,399 | 5,231 |
| Sessions (opt-in) | 736 | 6,978 | 10,330 |
| Installations (opt-in) | 21 | 726 | 1,618 |
| Deletions (opt-in) | 7 | 291 | 797 |
| Crashes (opt-in) | 0 | 7 (all in 2022) | 10 |

App Store Connect's "Sessions" counts foregroundings differently from TelemetryDeck's, so the two
session counts are not comparable: Konjugieren's opt-in subset alone shows 736 sessions against
TelemetryDeck's 332 for all devices.

### The funnel, per month

The last twelve full months for Conjuguer and Conjugar (Nov 2025 to Oct 2026); Konjugieren's
whole life (Mar 13 to Oct 31, 2026).

| Average per month | Konjugieren | Conjuguer | Conjugar |
|---|---:|---:|---:|
| Impressions | 157 | 904 | 450 |
| Product-page views | 25 | 68 | 52 |
| First-time downloads | 6.5 | 36 | 16.5 |
| Product-page views ÷ impressions | 16% | 7.5% | 12% |
| First-time downloads ÷ product-page views | 26% | 54% | 32% |

### Konjugieren by month

| Month | Impressions (unique devices) | Product-page views (unique) | Conversion | First-time downloads | Redownloads | Updates | Active devices, opt-in | Sessions, opt-in | Deletions, opt-in | Active last 30 days, month end |
|---|---|---|---:|---:|---:|---:|---:|---:|---:|---:|
| 2026-03 (from Mar 13) | 168 (79) | 47 (15) | 12.66% | 10 | 0 | 0 | 7 | 91 | 1 | 7 |
| 2026-04 | 154 (107) | 19 (11) | 10.28% | 9 | 2 | 9 | 5 | 99 | 0 | 5 |
| 2026-05 | 148 (92) | 26 (18) | 4.35% | 4 | 0 | 0 | 5 | 143 | 1 | 5 |
| 2026-06 | 145 (86) | 28 (16) | 6.98% | 6 | 0 | 20 | 4 | 51 | 1 | 4 |
| 2026-07 | 182 (107) | 30 (12) | 10.28% | 11 | 0 | 1 | 6 | 118 | 1 | 6 |
| 2026-08 | 142 (89) | 18 (6) | 2.25% | 2 | 2 | 43 | 3 | 126 | 2 | 3 |
| 2026-09 | 195 (114) | 30 (15) | 7.02% | 7 | 1 | 2 | 4 | 72 | 0 | 4 |
| 2026-10 | 122 (79) | 4 (4) | 3.80% | 3 | 0 | 1 | 5 | 33 | 1 | 5 |
| 2026-11 (1 to 8) | 34 (27) | 2 (2) | n/a | 0 | 0 | 0 | 1 | 3 | 0 | 5 |

### Conjuguer by year and by recent month

Calendar years; 2021 covers Dec 14 to 31, 2026 runs to Nov 8.

| Year | Impressions | Product-page views | First-time downloads | Redownloads | Updates | Sessions, opt-in | Deletions, opt-in |
|---|---:|---:|---:|---:|---:|---:|---:|
| 2021 | 1,018 | 168 | 46 | 1 | 61 | 35 | 6 |
| 2022 | 10,495 | 959 | 315 | 35 | 300 | 1,204 | 44 |
| 2023 | 12,832 | 1,155 | 454 | 46 | 464 | 1,418 | 74 |
| 2024 | 11,276 | 941 | **1,394** | 38 | 2,673 | 1,074 | 53 |
| 2025 | 9,281 | 736 | **1,278** | 27 | 739 | 1,263 | 43 |
| 2026 | 8,842 | 685 | 383 | 45 | 2,162 | 1,984 | 71 |

**The 2024 and 2025 download totals are dominated by two September spikes**: 1,118 first-time
downloads in September 2024 and 1,019 in September 2025, against a baseline of 15 to 45 a month.
September 2026 had 46. Lifetime, **2,110 of Conjuguer's 3,870 first-time downloads (55%) are
Institutional Purchases** (volume purchases through Apple School Manager or Apple Business
Manager), **2,031 first-time downloads came from Switzerland**, and **2,134 came on "Desktop"**,
that is, Macs running the iPad app. The three figures describe the same thing: a Swiss
institution installing Conjuguer on school Macs each autumn, which did not happen in 2026. Those
devices produced no opt-in sessions (Institutional Purchase has no row in the sessions-by-source
breakdown), and TelemetryDeck, adopted in July 2026, never saw them. Without the spikes, organic
first-time downloads were about 276 in 2024 and 259 in 2025, and 2026 has 383 so far, so the
organic trend is up.

A web search on 2026-11-10 for Swiss cantonal or school app lists naming Conjuguer found nothing.
Institutional purchases do not identify the buyer to the developer. Note that a different app,
"Conjuguer : conjugueur simple" (AppMeUp, App Store ID 1023882533), shares the name, so any list
that turns up needs checking against ID 1588624373.

Last 13 months, newest first (Nov 2026 covers Nov 1 to 8):

| Metric | Nov 26 | Oct | Sep | Aug | Jul | Jun | May | Apr | Mar | Feb | Jan 26 | Dec 25 | Nov 25 |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| Impressions | 219 | 1,005 | 1,004 | 739 | 1,016 | 799 | 890 | 916 | 759 | 709 | 786 | 1,323 | 901 |
| Product-page views | 27 | 90 | 87 | 61 | 51 | 56 | 64 | 88 | 46 | 54 | 61 | 62 | 94 |
| Conversion rate | 10.29% | 8.41% | 6.71% | 7.76% | 5.40% | 8.61% | 7.73% | 7.96% | 7.72% | 6.19% | 6.48% | 3.35% | 5.51% |
| First-time downloads | 11 | 40 | 46 | 32 | 33 | 39 | 43 | 45 | 35 | 27 | 32 | 33 | 31 |
| Redownloads | 3 | 12 | 4 | 4 | 4 | 5 | 4 | 3 | 4 | 1 | 1 | 2 | 2 |
| Active devices, opt-in | 18 | 53 | 44 | 38 | 46 | 37 | 37 | 39 | 39 | 35 | 26 | 33 | 26 |
| Sessions, opt-in | 48 | 271 | 206 | 215 | 187 | 373 | 149 | 106 | 165 | 158 | 106 | 125 | 110 |
| Deletions, opt-in | 1 | 8 | 7 | 6 | 6 | 8 | 8 | 4 | 6 | 14 | 3 | 8 | 4 |

"Active last 30 days" (opt-in) sat between 20 and 27 from mid-2024 to autumn 2025, reached 33 at
the end of 2025, 37 to 38 in the first half of 2026, 38 to 44 over the summer, and 53 at the end
of October 2026 (47 on Nov 8).

### Conjugar by year and by recent month

Calendar years; 2017 covers Sep 1 to Dec 31, 2026 runs to Nov 8. Redownloads and updates read
zero before 2021, which looks like a gap in Apple's history rather than real zeros.

| Year | Impressions | Product-page views | First-time downloads | Redownloads | Updates | Sessions, opt-in | Deletions, opt-in |
|---|---:|---:|---:|---:|---:|---:|---:|
| 2017 | 7,423 | 151 | 57 | 0 | 0 | 97 | 0 |
| 2018 | 11,095 | 1,234 | **717** | 0 | 0 | 2,019 | 0 |
| 2019 | 9,741 | 1,107 | 546 | 0 | 0 | 1,485 | 57 |
| 2020 | 11,289 | 1,187 | 421 | 0 | 0 | 1,211 | 418 |
| 2021 | 9,468 | 1,019 | 306 | 24 | 475 | 1,013 | 110 |
| 2022 | 8,575 | 933 | 264 | 44 | 690 | 916 | 55 |
| 2023 | 9,658 | 1,169 | 320 | 52 | 808 | 1,380 | 61 |
| 2024 | 5,819 | 785 | 183 | 158 | 1,327 | 731 | 31 |
| 2025 | 6,443 | 678 | 167 | 43 | 60 | 558 | 36 |
| 2026 | 4,116 | 520 | 180 | 37 | 1,871 | 920 | 29 |

First-time downloads peaked in 2018 and have fallen by about three quarters since; impressions fell
from about 11,000 a year to about 6,000 over the same period. Conjugar has no institutional
purchases.

Last 13 months, newest first (Nov 2026 covers Nov 1 to 8):

| Metric | Nov 26 | Oct | Sep | Aug | Jul | Jun | May | Apr | Mar | Feb | Jan 26 | Dec 25 | Nov 25 |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| Impressions | 75 | 288 | 544 | 503 | 409 | 317 | 270 | 305 | 399 | 423 | 583 | 836 | 521 |
| Product-page views | 14 | 48 | 94 | 47 | 44 | 32 | 34 | 63 | 43 | 61 | 40 | 63 | 55 |
| Conversion rate | 24.24% | 20.92% | 15.59% | 5.19% | 5.51% | 5.08% | 5.59% | 9.94% | 8.33% | 8.51% | 5.98% | 2.87% | 5.29% |
| First-time downloads | 8 | 27 | 39 | 14 | 14 | 8 | 6 | 12 | 16 | 21 | 15 | 11 | 15 |
| Redownloads | 0 | 5 | 7 | 0 | 2 | 2 | 5 | 4 | 3 | 3 | 6 | 8 | 3 |
| Active devices, opt-in | 12 | 25 | 29 | 18 | 17 | 14 | 10 | 13 | 7 | 13 | 18 | 17 | 16 |
| Sessions, opt-in | 35 | 169 | 186 | 58 | 231 | 76 | 19 | 23 | 20 | 36 | 67 | 50 | 81 |
| Deletions, opt-in | 0 | 2 | 3 | 3 | 1 | 3 | 4 | 3 | 7 | 3 | 0 | 5 | 2 |

Conversion jumped from about 5% to 15.6% in September and 20.9% in October 2026, the months after
the 3.x releases (updates spiked to 513 in August and 537 in September). "Active last 30 days"
(opt-in) was 24 to 29 at the end of 2021 to 2023, fell to 7 to 16 through 2024 to mid-2026, and is
back to 22 to 29 since September 2026.

### Where downloads come from (lifetime)

| Source type | Konjugieren impressions / first-time downloads | Conjuguer impressions / first-time downloads | Conjugar impressions / first-time downloads |
|---|---|---|---|
| App Store search | 1,073 / 37 | 49,645 / 1,512 | 66,367 / 2,510 |
| App Store browse | 170 / 5 | 3,531 / 91 | 16,133 / 351 |
| App referrer | 34 / 7 | 301 / 86 | 465 / 142 |
| Web referrer | 7 / 1 | 217 / 49 | 617 / 109 |
| Institutional purchase | 0 / 0 | 0 / **2,110** | 0 / 0 |
| Unavailable | 0 / 2 | 22 / 20 | 45 / 49 |

Search supplies 83% of Konjugieren's impressions and 71% of its first-time downloads. Conversion
rate by source, where captured: Konjugieren app referrer 24.1%, web referrer 14.3%, browse 6.0%,
search 5.4%; Conjuguer app referrer 38.8%, web referrer 23.1%, browse 9.5%, search 4.6%. Referred
visitors convert at four to eight times the rate of searchers, but referrals are a small share of
traffic, and App Store Connect will not say which apps or sites they came from.

### Where downloads come from: territory (lifetime)

**Konjugieren.** Impressions: Germany 663, US 300, Switzerland 105, Austria 85, Canada 29, UK 24,
India 13, Ghana 12, Pakistan 9, Philippines 9, Nigeria 7, Sri Lanka 6, Luxembourg 5, Australia 4,
Kenya 4, Netherlands 3, Singapore 3, Israel 2, Belgium 1. Product-page views: US 87, Germany 73,
Switzerland 14, Canada 12, Austria 9, and 9 more. First-time downloads: **Germany 29**, US 13,
Austria 4, New Zealand 2, Switzerland 2, Australia 1, Luxembourg 1. US visitors convert from page
view to download far less often than German ones (13 of 87 against 29 of 73).

**Conjuguer.** Impressions: US 11,326, France 10,816, DR Congo 4,517, Canada 3,459, Côte d'Ivoire
2,937, Senegal 2,712, Mali 1,371, Morocco 1,368, India 1,183, UK 1,164, Republic of the Congo
1,141, Switzerland 1,033, Mauritania 973, Belgium 863. First-time downloads: **Switzerland 2,031**
(institutional), US 388, France 260, Canada 217, DR Congo 163, Côte d'Ivoire 99, Morocco 64,
Senegal 54, Republic of the Congo 46, Mali 44, UK 44, India 33, Mauritania 33, Vietnam 33.

**Conjugar.** Impressions: US 63,601, UK 6,549, Canada 5,098, Australia 2,896, Spain 1,386, Mexico
993, Dominican Republic 451, Ireland 313, New Zealand 305, Chile 259. First-time downloads: **US
2,692** (85%), UK 122, Canada 112, Spain 75, Australia 51, Mexico 23, Dominican Republic 21,
Cyprus 12.

### Device (lifetime first-time downloads)

| Device | Konjugieren | Conjuguer | Conjugar |
|---|---:|---:|---:|
| iPhone | 41 | 1,654 | 2,800 |
| iPad | 6 | 80 | 306 |
| Mac ("Desktop") | 5 | 2,134 (institutional) | 50 |
| iPod | 0 | 0 | 5 |

### Benchmarks against peer apps

App Store Connect compares each app with free apps without in-app purchases in its category, for
the week of **Oct 12 to 18, 2026** (a single, small week, so treat it as indicative). Konjugieren
is listed in **Education**; Conjuguer and Conjugar are in **Reference**.

| Metric | Konjugieren | Conjuguer | Conjugar | Peer 25th / 50th / 75th percentile |
|---|---:|---:|---:|---|
| Conversion rate | 18.18% | 10.24% | 19.05% | Education 1.12% / 3.60% / 10.44%; Reference 1.10% / 3.14% / 7.91% |
| Day 1 retention | insufficient data | 16.67% | insufficient data | Reference 15.25% / 24.26% / 34.37% |
| Day 7 retention | insufficient data | 16.67% | insufficient data | Reference 3.39% / 8.11% / 14.61% |

All three convert above the 75th percentile of their peers.

### Observations from App Store Connect

- **Konjugieren's bottleneck is being seen, not being chosen.** It averages 157 impressions a
  month, a sixth of Conjuguer's and a third of Conjugar's, while converting above the 75th
  percentile of Education peers. Search supplies 83% of its impressions.
- **Conjuguer's headline download growth was one Swiss institution**, and that institution did not
  return in September 2026. Its organic downloads and opt-in active devices are both rising.
- **Conjugar's acquisition has declined since 2018**, roughly in step with its impressions, but
  its conversion rate and opt-in active devices rose sharply after the 3.x releases.

## The China devices

Josh has long found Konjugieren's Chinese usage puzzling. TelemetryDeck counts 19 Konjugieren
devices with region China and 19 with a Chinese device language. App Store Connect shows **no**
impressions, page views, or downloads from China, and Konjugieren is not available there. The
devices behind the puzzle share a signature:

- **20 devices** report the UTC+8 time zone: 18 with region China and 2 with region US. Nearly all
  run in Chinese. All report App Store builds, not TestFlight.
- **Every one was active on exactly one day**, 19 of them in a single session, with 9 to 77
  signals each, on 20 different days between mid-March and late September 2026. None ever came
  back, against 42% of Konjugieren's other devices.
- **In that single session each one tours the app.** Counting both signal-naming schemes (three
  of the devices ran 1.0), all 20 reached verb browsing, settings, and verb families; 19 the quiz
  screen; 18 the info list; 17 a verb and a family detail; 16 an info article. 13 started a quiz,
  4 started the game, 4 tapped rate-or-review, and 2 opened the leaderboard.
- **Removing them reconciles the two sources exactly.** TelemetryDeck's 77 Konjugieren devices
  minus these 20 leaves 57, which is App Store Connect's lifetime total of 57 downloads (52
  first-time plus 5 redownloads). If these devices had downloaded through foreign-storefront
  Apple IDs, App Store Connect would have counted them, and its US downloads (13) are too few to
  hide 20 of them.

The behavior looks like systematic exploration of the app, one device at a time, roughly every ten
days, by something that installs it without an App Store download. A re-signed or sideloaded copy
(from an IPA-mirror site or an app-testing or app-intelligence service) fits: TelemetryDeck
reports a build without a sandbox receipt as "App Store". Which service it is cannot be determined
from this data. The pattern is specific to Konjugieren. Conjuguer's four China-region devices
returned on several days each, as real users do, and Conjugar has none.

### Three follow-up checks (2026-11-10)

TelemetryDeck rounds signal timestamps to the hour, so tap-by-tap rhythm is not recoverable.
`TelemetryDeck.Retention.averageSessionSeconds`, which the SDK attaches to every signal and which is
populated even during a device's first session, stands in for session length.

1. **Session length is nearly constant.** 15 of the 20 sessions lasted between 120 and 139 seconds
   (120, 122, 125, 126, 131, 131, 132, 133, 133, 134, 134, 135, 136, 137, 139). Konjugieren's 19
   ordinary single-session devices with a value spread from 9 to 346 seconds, and only one of them
   falls in that band. A fixed two-minute budget per run is what a script looks like. The
   exceptions include both region-US devices (252 s with 63 signals, and the only device with
   three sessions), which may be different visitors. Ordinary users also show a cluster near 250
   to 255 seconds, so values there may be an SDK ceiling and say little.
2. **The hours are round the clock.** In China time, first signals fall at 0, 0, 2, 2, 3, 6, 7, 8,
   9, 11, 13, 13, 13, 16, 18, 21, 22, 22, 22, 22 o'clock: six between midnight and 7 a.m., six in
   office hours (9 to 18), and seven of twenty on a weekend, about the share uniform timing gives.
   Nothing suggests a staffed day shift.
3. **New versions get visited within days of release.** Taking each version's first appearance
   among ordinary devices as its release, the first China-time visit on that version came 3.8 days
   after 1.0, 0.1 after 1.1, 0.7 after 1.2, 3.0 after 1.3, and 5.2 after 1.4. At the observed rate
   of one visit per 9.6 days, all five landing that fast by chance has a probability around 1 in
   40,000 (about 1 in 400 leaving out 1.1, whose first ordinary sighting may have been Josh's own
   device). Three visits ran an older version than the current one (1.0 on Apr 9, 1.2 on Sep 6,
   1.3 on Sep 24), so whatever supplies the copies also keeps old builds.

Together these point away from human learners and toward **an automated service that notices each
Konjugieren update, obtains a copy, and runs a scripted two-minute exploration**, with further
runs in between, from an archive that holds past versions. Update-triggered capture is the core
business of app-monitoring and app-intelligence services; a GUI-dataset collector would explain
the touring but not the release timing as well. Which service it is remains unknowable from this
data.

**Consequences for the TelemetryDeck figures above.** Konjugieren's real device count is 57, not
77. Its second-day return rate is 42%, not 31%. Its quiz starts are 32, not 45 (still with no
completion), and its rate-or-review taps are 4, not 9.

## Appendix A: how the TelemetryDeck data was pulled

**Access.** The dashboard's own TQL endpoint (`api.telemetrydeckapi.com/api/v4/query/tql/`)
requires the session's bearer token, and lifting that token out of the page is off-limits. Every
query here went through **Explore → Playground → JSON Editor**, typed into the editor as a
user would. Results render as an HTML table. For large results, a short JavaScript snippet that
reads the rendered `<tr>` cells and summarizes them in-page is far cheaper than `get_page_text`.

**The one-period label shift.** The Playground renders each bucket's UTC start timestamp in the
browser's local time zone. In Pacific time, midnight UTC on the 1st is the afternoon of the last
day of the previous month, so a bucket labelled "October 2026" holds **November's** data, "Week 44"
holds ISO week 45, and "Mon, October 19" holds Oct 20. This was confirmed by matching a daily
query against the timestamped Recent Events list. Add one period to every label.

**TQL gotchas found by trial.**

- `dimensions` takes objects, not strings: `{"type": "default", "dimension": "appID", "outputName": "app"}`.
- `"baseFilters": "thisOrganization"` scopes to all three apps and appears to exclude test-mode data.
- `eventCount` and `userCount` are TQL shorthands. Inside a `filtered` aggregator they are not
  expanded, so write raw Druid instead: `{"type": "longSum", "fieldName": "count"}`.
- `cardinality` requires both `"byRow": false` and `"round": true`.
- `longMin` / `longMax` on `__time` give first-seen and last-seen per group.
- Parameters are stored as STRING, and numeric aggregators silently see nothing. Cast through a
  virtual column: `"virtualColumns": [{"type": "expression", "name": "pss", "expression":
  "CAST(\"TelemetryDeck.Retention.previousSessionSeconds\", 'DOUBLE')", "outputType": "DOUBLE"}]`,
  then aggregate `pss` with `quantilesDoublesSketch` plus a `quantilesDoublesSketchToQuantiles`
  post-aggregation.
- The editor re-runs the query on every keystroke. With a large result table on screen (a few
  hundred rows), typing the next query freezes the renderer. Reload the Playground page between
  heavy queries.

**Representative queries.**

All-time signals and users per app and signal type:

```json
{"queryType": "groupBy", "granularity": "all",
 "dimensions": [{"type": "default", "dimension": "appID", "outputName": "appID"},
                {"type": "default", "dimension": "type", "outputName": "type"}],
 "intervals": ["2026-01-01T00:00:00.000Z/2026-11-11T00:00:00.000Z"],
 "aggregations": [{"type": "eventCount", "name": "signals"}, {"type": "userCount", "name": "users"}],
 "baseFilters": "thisOrganization"}
```

One row per device, for retention and engagement distributions:

```json
{"queryType": "groupBy", "granularity": "all",
 "dimensions": [{"type": "default", "dimension": "appID", "outputName": "a"},
                {"type": "default", "dimension": "clientUser", "outputName": "u"}],
 "intervals": ["2026-01-01T00:00:00.000Z/2026-11-11T00:00:00.000Z"],
 "aggregations": [
   {"type": "eventCount", "name": "n"},
   {"type": "filtered",
    "filter": {"type": "selector", "dimension": "type", "value": "TelemetryDeck.Session.started"},
    "aggregator": {"type": "longSum", "fieldName": "count", "name": "s"}},
   {"type": "cardinality", "fields": ["TelemetryDeck.Calendar.dayOfYear"], "byRow": false, "round": true, "name": "d"},
   {"type": "longMin", "fieldName": "__time", "name": "f"},
   {"type": "longMax", "fieldName": "__time", "name": "l"}],
 "baseFilters": "thisOrganization"}
```

Other queries used the same shape with different dimensions: `TelemetryDeck.UserPreference.region`,
`TelemetryDeck.UserPreference.language`, `TelemetryDeck.Device.modelName`,
`TelemetryDeck.AppInfo.version`, `TelemetryDeck.Device.platform`, `difficulty`, `questionNumber`,
`lastQuestionIndex`, and `viewName`, with `granularity` set to `month`, `week`, or `day` for trends.
The Parameters page under Explore lists every available dimension.

## Appendix B: how the App Store Connect data was pulled

**Where.** `appstoreconnect.apple.com/apps/<App Store ID>/analytics/metrics`. The explorer has a
metric menu (App Store, Downloads, and Usage submenus), a grouping menu ("By Date", or By App Store
→ App Version, Device, Platform Version, Product Page, Page Type, Region, Territory, Source Type,
App Referrer, Web Referrer, Campaign), a date-range picker whose presets include **Lifetime**
(`dateSpec=ltd`), and a Days / Weeks / Months frequency menu. The rendered table is plain `<tr>`
rows, so reading `document.querySelectorAll('tr')` gives the numbers directly. Benchmarks live at
`…/analytics/benchmarks`, availability at `…/distribution/pricing/availability` (read only; its
"Manage Availability" button edits it).

**Automation that worked.** With roughly 25 metric selections per app, the menus were driven by
in-page JavaScript that clicks the same controls a person would, started without `await` so the
loop outlives the 45-second tool timeout, with results stored on `window` and polled. Gotchas:

- Submenus open on a synthetic `mouseenter`/`mouseover` in some menus and only on a `click` of the
  parent item in others; try one, then the other.
- Button labels include an SF Symbols glyph after the text, so match them with a prefix regex such
  as `/^(Days|Weeks|Months)\b/`, never an exact `$` anchor.
- After a metric switch, wait for rows to appear and then a little longer. A fixed 4-second wait
  returned empty tables on the nine-year Conjugar history, where each switch took about 25 seconds.
- "Active Last 30 Days" is a rolling daily metric and silently resets frequency to Days; select it
  last, or switch frequency back afterwards.
- Unique-device metrics and conversion rate are not additive. Their "Total" row is not the sum of
  the months, so yearly figures in this document sum only additive metrics.
- The browser tool redacts URL query parameters whose names end in `Key`
  (`measureKey`, `groupByDimensionKey`) and blocks reading `location.search`, so selections have to
  be made through the UI rather than by constructing URLs.
