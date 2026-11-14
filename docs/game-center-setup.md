# Game Center Setup

What Konjugieren's Game Center configuration is, where it lives, and how to change it. Written
2026-11-14 for Phase 8 of the [pedagogy plan](../plans/pedagogy-implementation.md#phase-8-leaderboards-by-level),
which gave each quiz level its own leaderboard. Phase 23 adds achievements here.

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
