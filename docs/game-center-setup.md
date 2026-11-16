# Game Center Setup

What Konjugieren's Game Center configuration is, where it lives, and how to change it. Written
2026-11-14 for Phase 8 of the [pedagogy plan](../plans/pedagogy-implementation.md#phase-8-leaderboards-by-level),
which gave each quiz level its own leaderboard. [Phase 23](../plans/pedagogy-implementation.md#phase-23-personal-bests-and-achievements)
added the achievements on 2026-11-15; see [The Achievements](#the-achievements) below.

## Where the Configuration Lives

In two places, which should agree:

- **App Store Connect**, under **Apps** › Konjugieren › **Distribution** › **Game Center** (in the
  sidebar, under Growth & Marketing). This is the configuration players see.
- **`GameCenterResources.gamekit/`** in the repo, Xcode's local copy of the configuration. The
  build copies it into the app, and Xcode's Game Progress Manager reads it to test leaderboards on
  a device before App Store Connect has them. Apple's docs describe configuring leaderboards in
  Xcode and pushing them to App Store Connect. Removing a leaderboard from this file does not
  remove it from App Store Connect.

The four level leaderboards were created in App Store Connect first, by a Claude Code session
driving Chrome on 2026-11-14, and then added to `gameCenterResources.json` by hand, mirroring
App Store Connect's API attributes as the file's existing entry does. **Open the `.gamekit` in Xcode
once to confirm its editor reads the new entries**; the build only copies the file and would not
notice a schema mistake.

## The Leaderboards

| Reference name | Leaderboard ID | English name | German name |
|---|---|---|---|
| Leaderboard | `Leaderboard` | Leaderboard | Bestenliste |
| Beginner | `konjugieren.level.beginner` | Beginner | Einstieg |
| Elementary | `konjugieren.level.elementary` | Elementary | Grundstufe |
| Intermediate | `konjugieren.level.intermediate` | Intermediate | Mittelstufe |
| Advanced | `konjugieren.level.advanced` | Advanced | Oberstufe |

`Leaderboard` is the original, live since release 1.x, and retired on `main` by Phase 8: nothing
on `main` posts to it. The other four belong to the levels, and the code takes their IDs from
`QuizLevel.leaderboardID` in `Konjugieren/Utils/GameCenter.swift`.
`QuizLeaderboardTests.eachLevelHasItsOwnLeaderboard` pins each ID literally.

**Leaderboard IDs are permanent.** App Store Connect will not edit one after creation, and a
leaderboard can no longer be deleted once it has been submitted for review. A level renamed later
keeps its ID. The `konjugieren.` prefix keeps the IDs distinct from the sibling apps', which may
get level leaderboards of their own (`conjuguer.level.beginner`).

Each level leaderboard has the same settings:

| Setting | Value | Why |
|---|---|---|
| Type | Classic | Scores never reset. Josh chose not to use recurring boards (2026-11-14). |
| Score Format | Integer | Scores are whole points. |
| Score Range | 0 to 100 | A ranked score is the first ten questions' points, at most 10 each, so Game Center rejects anything else. |
| Score Submission Type | Best Score | A player's best session stands. |
| Sort Order | High to Low | **The form defaults to Low to High.** Check it. |
| Hidden | No | |
| Score Format Suffix | None | The live `Leaderboard` has none either. |
| Image | None | Optional. The live `Leaderboard`'s image is in the `.gamekit` (1024 × 1024 PNG) if Josh wants the same on each. |

Each localization has a description of at most 120 characters:

- English: "The first ten questions of a quiz over all verbs at the Beginner level" (and so on per level)
- German: "Die ersten zehn Fragen eines Quiz über alle Verben auf der Stufe Einstieg" for Beginner, and
  "… auf der Grundstufe", "… auf der Mittelstufe", "… auf der Oberstufe" for the others

**What posts.** A default quiz over every verb posts the points of its first ten questions,
second-attempt half points included and re-asks not, to the leaderboard of the level it was
started at. Ten More posts nothing. A quiz over My Verbs, a collection, or one verb's page posts
nothing. See [`feature-architecture.md`](feature-architecture.md#game-center-integration).

**Ties.** Many players will tie at 100. Josh decided on 2026-11-14 that nothing breaks ties,
which suits practice over examination and the hidden-by-default clock. Apple's documentation does
not say how Game Center orders equal scores.

## Creating a Leaderboard

As App Store Connect presented it on 2026-11-14:

1. **Apps** › Konjugieren. The app opens on Distribution.
2. In the sidebar, under Growth & Marketing, click **Game Center**.
3. Click the **+** beside **Leaderboards (n)**.
4. **Add Leaderboard:** enter the Reference Name (up to 255 characters, internal only) and the
   Leaderboard ID (up to 100). Click **Next**.
5. **Choose Leaderboard Type:** Classic Leaderboard. Click **Next**.
6. **Choose Score Format:** set Score Format, Score Range, Score Submission Type, and Sort Order as
   in the table above. Click **Create**. The leaderboard opens with the status "Prepare for
   Submission".
7. Under **Leaderboard Localization**, click **Add Localization**. Choose the language, enter the
   Display Name (up to 30 characters) and the description, and click **Save**. Repeat with the
   **+** beside the heading for the second language. Leave Score Format (Optional) on "Choose...",
   so that the localization inherits Integer.
8. Do **not** click **Add for Review** until the release that uses the leaderboard is being
   submitted (below).

Leave **Leaderboard Sets** alone. Once an app has one set, App Store Connect requires every future
leaderboard to belong to a set, and four leaderboards gain nothing from one.

## On Release Day

The four level leaderboards are in "Prepare for Submission" and reach players only when Apple
approves them. Apple says to submit Game Center components in the same submission as the app
version the first time they are added:

1. On each level leaderboard's page, click **Add for Review** and add it to the draft submission
   that holds the new app version. Then submit.
2. After the release is live, archive the old `Leaderboard`: on its page, **Archive Leaderboard** ›
   **Archive**. App Store Connect cannot delete a live leaderboard, and archiving removes it from
   Game Center's interface within about 24 hours. Josh decided on 2026-11-14 to wait until the
   release, since the shipped app still posts to it and opens it. An older install that is never
   updated will then post to an archived board, which Game Center hides.
3. `Leaderboard` is the app's **Default** leaderboard, per the Game Center page's Default column.
   Consider making Beginner the default. Apple's docs say the default is set in App Store Connect
   but do not name the control, and this session did not look for it.

## Testing Before Release

Apple's docs say that a development-signed build sees leaderboards that are not yet live, marked
with a prerelease indicator, in the same server environment as released apps. So a debug build on
Josh's iPhone, signed in to Game Center, should post to `konjugieren.level.*` and show it, and
friends can see those scores. Apple suggests a separate test account and removing test data when
finished.

To try it: build to the iPhone from Xcode, sign in to Game Center in the iPhone's Settings if not
already, finish a ten-question quiz over all verbs at some level, and tap **View Leaderboard** on
the results. It should open that level's board with the score. In Settings, **View Leaderboards**
should open Game Center's list of all the app's boards.

**Tried on 2026-11-14, and blocked.** Two findings:

- **GameKit debug mode hides every leaderboard.** The shared scheme had `enableGameKitDebugMode`
  on, from the original Game Center commit. With it on, Game Center offered the app no leaderboards
  at all ("Leaderboards 0 / 0 Ranked"), the live `Leaderboard` included, and View Leaderboard
  showed "Cannot Connect". Phase 8 turned it off in the scheme.
- **With it off, the build saw only the live board** ("1 / 1 Ranked"), and opening an Elementary
  quiz's board still showed "Cannot Connect". The four level boards were not visible to a
  development build. The likely reason is that Apple's testing steps have you add leaderboards to
  the app version under test, and Konjugieren had no version to add them to: only 1.4, live. This
  is unconfirmed; a propagation delay is the other possibility.

So the test waits for the next version. Once it is created in App Store Connect, add the four
boards to it, then run the test above **before** submitting the version for review. [`release.md`](release.md)
carries the reminder.

Two curiosities of a development build, seen the same day, are expected: Game Center's leaderboard
screen says "Download the game to rank on this leaderboard", since the installed app is not the
App Store's, and its View button says "This app is not available in the Games app", which seems
to list only apps in the Games category.

## The Achievements

Eight achievements, approved by Josh on 2026-11-15, each for a mastery milestone rather than
for volume of play. An item counts once it is **mastered**, as the app's Mastery page counts it:
in the third box of the review ladder, a week or more from its next review. The code is
`Konjugieren/Models/Achievement.swift`; `AchievementTests.eachAchievementHasItsID` pins each ID
literally. **None of them exists in App Store Connect yet.** Create them by the steps below.
They are in `GameCenterResources.gamekit` with their artwork (2026-11-15), added by hand in the
shape of App Store Connect's API attributes (`vendorIdentifier`, `points`, `showBeforeEarned`,
`repeatable`, `beforeEarnedDescription`, `afterEarnedDescription`), as the leaderboards were.
Josh opened it in Xcode on 2026-11-15, and the editor listed all eight with their IDs, points,
both localizations, and images, and left the file unchanged.

| # | Reference name | Achievement ID | Points | Milestone |
|---:|---|---|---:|---|
| 1 | Patterns Beginner | `konjugieren.achievement.patterns.beginner` | 10 | All 9 weak-verb patterns that Beginner asks |
| 2 | Patterns Elementary | `konjugieren.achievement.patterns.elementary` | 25 | All 17 that Elementary asks |
| 3 | Patterns Intermediate | `konjugieren.achievement.patterns.intermediate` | 50 | All 47 that Intermediate asks |
| 4 | Patterns Advanced | `konjugieren.achievement.patterns.advanced` | 100 | All 66 that Advanced asks |
| 5 | Pillars | `konjugieren.achievement.verbs.pillars` | 25 | The three key conjugations of sein, haben, werden, and the six modals |
| 6 | Ten Strong | `konjugieren.achievement.verbs.core10` | 25 | The three key conjugations of 10 of the 50 most frequent strong and mixed verbs |
| 7 | Twenty-Five Strong | `konjugieren.achievement.verbs.core25` | 50 | The same, of 25 |
| 8 | Fifty Strong | `konjugieren.achievement.verbs.core50` | 100 | The same, of all 50, both strong readings of fahren and ziehen included |

385 of Apple's 1,000 points, so there is room for more. Apple's limits, from its GameKit article
"Rewarding players with achievements" (read 2026-11-15): "a maximum of 100 achievements, 100
points per achievement, and 1000 points total for all achievements." A point value cannot change
once the achievement has been live, and the ID never can.

The four pattern achievements count each level's patterns whatever level the learner has chosen.
The strong-verb achievements ask for **all three** key conjugations (Präsens, Präteritum,
Perfekt) whatever the level, so a learner cannot earn one by switching to Beginner, which asks
only the Präsens. The 50 verbs are the Mastery page's (`Mastery.coreVerbs`), and the pillars are
among them.

Each has the same settings: **Hidden** No (a learner should see what to aim for), **Achievable
More Than Once** No.

### Names and Descriptions

The titles follow two themes. The patterns build a stone arch, from the foundation to the
keystone that locks it. The strong verbs borrow the old idiom for a company's size, "fifty
strong", since Jacob Grimm named the strong and weak verbs (*starke* and *schwache Verben*) in his
*Deutsche Grammatik* of 1819. Apple's help pages state no character limits for these fields; each
is short regardless.

| # | English name | Pre-earned description | Earned description |
|---:|---|---|---|
| 1 | Foundation Stones | Master all 9 weak-verb patterns that Beginner asks. A pattern is mastered once its next review is a week or more away. | Every weak-verb pattern of Beginner, mastered. |
| 2 | Masonry | Master all 17 weak-verb patterns that Elementary asks. A pattern is mastered once its next review is a week or more away. | Every weak-verb pattern of Elementary, mastered. |
| 3 | Vault | Master all 47 weak-verb patterns that Intermediate asks. A pattern is mastered once its next review is a week or more away. | Every weak-verb pattern of Intermediate, mastered. |
| 4 | Keystone | Master all 66 weak-verb patterns that Advanced asks. A pattern is mastered once its next review is a week or more away. | Every weak-verb pattern of Advanced, mastered. |
| 5 | The Pillars | Master the three key conjugations, as in ist · war · ist gewesen, of sein, haben, werden, and the six modal verbs. | sein, haben, werden, and the modals, mastered. |
| 6 | Ten Strong | Master the three key conjugations, as in fährt · fuhr · ist gefahren, of 10 of the 50 most used strong verbs. | 10 of the 50 most used strong verbs, mastered. |
| 7 | Twenty-Five Strong | Master the three key conjugations, as in fährt · fuhr · ist gefahren, of 25 of the 50 most used strong verbs. | 25 of the 50 most used strong verbs, mastered. |
| 8 | Fifty Strong | Master the three key conjugations, as in fährt · fuhr · ist gefahren, of all 50 of the most used strong verbs. | All 50 of the most used strong verbs, mastered. |

| # | German name | Beschreibung vorher | Beschreibung nachher |
|---:|---|---|---|
| 1 | Grundsteine | Beherrsche alle 9 Muster der schwachen Verben, die die Stufe Einstieg abfragt. Beherrscht ist, was frühestens in einer Woche wieder ansteht. | Alle Muster der schwachen Verben auf der Stufe Einstieg beherrscht. |
| 2 | Mauerwerk | Beherrsche alle 17 Muster der schwachen Verben, die die Grundstufe abfragt. Beherrscht ist, was frühestens in einer Woche wieder ansteht. | Alle Muster der schwachen Verben auf der Grundstufe beherrscht. |
| 3 | Gewölbe | Beherrsche alle 47 Muster der schwachen Verben, die die Mittelstufe abfragt. Beherrscht ist, was frühestens in einer Woche wieder ansteht. | Alle Muster der schwachen Verben auf der Mittelstufe beherrscht. |
| 4 | Schlussstein | Beherrsche alle 66 Muster der schwachen Verben, die die Oberstufe abfragt. Beherrscht ist, was frühestens in einer Woche wieder ansteht. | Alle Muster der schwachen Verben auf der Oberstufe beherrscht. |
| 5 | Die Säulen | Beherrsche bei sein, haben, werden und den sechs Modalverben je die drei Konjugationen wie ist · war · ist gewesen. | sein, haben, werden und die Modalverben beherrscht. |
| 6 | Zehn Starke | Beherrsche bei 10 der 50 häufigsten starken Verben je die drei Konjugationen wie fährt · fuhr · ist gefahren. | 10 der 50 häufigsten starken Verben beherrscht. |
| 7 | Fünfundzwanzig Starke | Beherrsche bei 25 der 50 häufigsten starken Verben je die drei Konjugationen wie fährt · fuhr · ist gefahren. | 25 der 50 häufigsten starken Verben beherrscht. |
| 8 | Fünfzig Starke | Beherrsche bei allen 50 der häufigsten starken Verben je die drei Konjugationen wie fährt · fuhr · ist gefahren. | Alle 50 der häufigsten starken Verben beherrscht. |

"Strong verbs" here includes the mixed verbs (bringen, denken, kennen), as the Mastery page's
heading does not; the descriptions keep it short.

### The Artwork

Apple requires an image for each achievement, in each localization: "a `.jpeg`, `.jpg`, or `.png`
file that's 1024 x 1024 pixels, at least 72 ppi, and in the RGB color space." Game Center shows it
in a circle, so each image is a round medallion with everything important inside the middle 80%.
The same image serves both languages, since none has words; the strong-verb badges carry only a
numeral.

The drafts were made with the `gpt-image` skill on 2026-11-15, two per achievement, every prompt
giving the colors of `Konjugieren/Assets/Assets.xcassets` as hex values, as Josh decided:
`customBackground` #000000 (dark) and #FFFFFF (light), `customCardBackground` #1C1C1E and #F2F2F7,
`customYellow` #FFCE00 (dark) and #665300 (light), `customRed` #DD0000, and `customForeground`
white for glints. `customCardBorder` is `customYellow` at 8% opacity, and `AccentColor` has no
value of its own (the system blue), so neither was named. Black, #DD0000, and #FFCE00 are the
German flag's colors, which is why the badges look of a piece with it.

Josh picked on 2026-11-15: the first draft of each but Vault and Ten Strong, whose second he
chose. The images are in `GameCenterResources.gamekit/<locale>/AchievementImage-<ID>-<locale>.jpg`,
the same image under `en-US` and `de-DE`, and these are the files to upload. They are **JPEGs at
quality 92**, 1024 × 1024, RGB, 72 ppi, about 0.2 MB each. The build copies the `.gamekit` into the
app, and as PNGs the sixteen came to 17 MB; Josh chose JPEG on 2026-11-15, and no difference
showed at twice the size.

### Creating an Achievement

As Apple's "Manage achievements" help page gave the steps on 2026-11-15 (not yet followed in
App Store Connect itself, so check each step against what the page shows):

1. **Apps** › Konjugieren › **Game Center** in the sidebar, as for a leaderboard.
2. Click **Add Achievement**, or the **+** beside Achievements once one exists.
3. Enter the Reference Name and the Achievement ID from the first table. Click **Create**.
4. Enter the Point Value, and leave Hidden and Achievable More Than Once off.
5. Under **Achievement Localization**, click **Add Localization**. Choose English (U.S.), enter
   the name, both descriptions, and the image. Click **Save**. Repeat for German.
6. Click **Save** again.
7. Do **not** add it for review until the release that reports it (below).

Game Center lists the achievements in App Store Connect's order; **Edit Order** changes it. Keep
the table's order: the patterns by level, then the verbs.

### How the App Reports Them

`Current.reportAchievements()` computes each achievement's progress from the practice record and
passes it to `GameCenter.reportAchievementProgress(_:)` as a percentage, so Game Center shows an
unearned achievement's progress. It is called at launch, when any quiz finishes or is quit, and
when a review card is revealed, the moments an item can reach the third box. `GameCenterReal`
holds what it is given until the player is signed in and Game Center has said what it already
holds (`GKAchievement.loadAchievements`), then sends only what has risen. The record can fall, a
wrong answer sending an item back down the ladder, but an achievement once earned stays earned.
Game Center shows its own banner when one completes (`showsCompletionBanner`).

The hub's **View Achievements** and Settings' row of the same name open Game Center's
achievements (`GKAccessPoint.shared.trigger(state: .achievements)`). Both appear only while signed
in.

### Release Day and Testing

Add the eight achievements for review with the version, as for the level leaderboards. Apple says
achievements "must be approved before they are available to players", and that a development
build sees unreleased ones with a prerelease indicator. Given what Phase 8 found with the
leaderboards, expect them to be visible to a development build only once they are added to the
version under test. Then, on Josh's iPhone signed in to Game Center: finish a quiz, open **View
Achievements**, and check that the eight are listed with any progress. Earning one for real takes
at least three days of practice (a first right answer, then another when it is due).
