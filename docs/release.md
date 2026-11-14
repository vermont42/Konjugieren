# The 2027 Release

What the next App Store release of Konjugieren must do, gathered in one place. `CLAUDE.md` §
No Release Before 2027 points here. Add to this document whenever work on `main` leaves a task
for release time, and delete it, along with that `CLAUDE.md` section, once the release has
shipped and every item below is done.

## Why There Is No Release Before 2027

Josh cannot cut an App Store release of Konjugieren, Conjuguer, or Conjugar from his present
MacBook, and he plans to replace it in 2027. He said so on 2026-11-10. TestFlight builds are
probably blocked too, since they need the same upload. Until then, work accumulates on `main` and
the shipped versions do not change. When planning, do not sequence work around a near release,
and do not count on shipping a fix or an analytics signal in order to learn from it. Text hosted
outside the apps, such as the privacy policy, can still change at any time.

The shipped version is 1.4. What has accumulated since is recorded in the plans' Status tables
([`plans/browse-and-verb-implementation.md`](../plans/browse-and-verb-implementation.md),
[`plans/pedagogy-implementation.md`](../plans/pedagogy-implementation.md)) and in the **Built on
`main`** lines of [`plans/pedagogy.md`](../plans/pedagogy.md), which are the raw material for the
release notes.

## Before Submitting

1. **Create the new version in App Store Connect.**
2. **Add the four per-level leaderboards to it, and test leaderboard access** on a development
   build before submitting the version for review. The leaderboards (pedagogy Phase 8) were not
   visible to a development build on 2026-11-14, probably because no app version existed to add
   them to. Once they are added, finish a quiz over all verbs and tap View Leaderboard; it should
   open that level's board with the score. Keep GameKit debug mode off in the scheme, since it
   hides every leaderboard. See [`game-center-setup.md`](game-center-setup.md) § Testing Before
   Release.
3. **Write the release notes** in English and German in
   [`release_notes.txt`](release_notes.txt), as for 1.3 and 1.4.
4. **Check the App Store description**, [`description.md`](description.md), which `main` keeps
   current (the levels and the per-level leaderboards are already in it), and paste it into App
   Store Connect if it changed.
5. **The store category** (Decision 10 of the pedagogy report): change the primary category from
   Education to Reference, if App Store Connect did not already allow it without a version. The
   pedagogy plan's Closing checks which.
6. **Submit the version with the four leaderboards in the same submission.** On each leaderboard's
   page, click **Add for Review** and choose the draft submission that holds the version. Apple
   requires first-time Game Center components to go with an app version.

## On Release Day

1. **The privacy policy.** Analytics added on `main` since the last release need lines in the
   policy on the day the release ships, and not before. They wait in
   [`privacy-policy-pending.md`](privacy-policy-pending.md), which says how to apply them.
2. **Archive the old leaderboard**, `Leaderboard`, once the release is live, and consider making
   Beginner the default. See [`game-center-setup.md`](game-center-setup.md) § On Release Day.

## Afterward

Delete this document and `CLAUDE.md` § No Release Before 2027, and remove the reminders that
point here.
