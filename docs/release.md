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
([`plans/browse_and_verb_implementation.md`](../plans/browse_and_verb_implementation.md),
[`plans/pedagogy_implementation.md`](../plans/pedagogy_implementation.md)) and in the **Built on
`main`** lines of [`docs/pedagogy_research.md`](pedagogy_research.md), which are the raw material for the
release notes.

## Before Submitting

1. **Create the new version in App Store Connect.**
2. **Add the four per-level leaderboards to it, and test leaderboard access** on a development
   build before submitting the version for review. The leaderboards (pedagogy Phase 8) were not
   visible to a development build on 2026-11-14, probably because no app version existed to add
   them to. Once they are added, finish a quiz over all verbs and tap View Leaderboard; it should
   open that level's board with the score. Keep GameKit debug mode off in the scheme, since it
   hides every leaderboard. See [`game_center_setup.md`](game_center_setup.md) § Testing Before
   Release.
3. **Create the eight achievements** (pedagogy Phase 23) by the walkthrough in
   [`game_center_setup.md`](game_center_setup.md) § The Achievements, with the artwork Josh chose,
   add them to the version, and on the development build open View Achievements on the Quiz tab:
   the eight should be listed, with progress on any the build's record has begun.
4. **Write the release notes** in English and German in
   [`release_notes.txt`](release_notes.txt), as for 1.3 and 1.4.
5. **Redo the App Store description**, [`description.md`](description.md), in English and German
   (Josh, 2026-11-15). `main` has kept it current piece by piece (the levels, the per-level
   leaderboards, and the achievements are already in it), but the quiz became a practice hub with
   seven exercises, a practice record, a daily session, and a daily challenge, so the description
   wants rewriting as a whole rather than checking. Paste it into App Store Connect.
6. **Redo the screenshots** (Josh, 2026-11-15), 36 in all, by
   [`screenshot_playbook.md`](screenshot_playbook.md) and `scripts/take_screenshots.sh`. Revise
   the nine views in [`screenshot.md`](../plans/screenshot.md) first; the driver's `VIEWS`
   follows. As of 2026-11-15 the plan predates the pedagogy work: the Quiz tab now opens on the
   practice hub, not a quiz, so `quiz_mid` needs Start first and shows the answer frame (Phase 2);
   `quiz_results` asks for elapsed time, which a hidden Quiz Clock, the default since Phase 7,
   leaves off the results; and nothing shows the hub, Mastery, or an exercise. The playbook's
   hardware-keyboard mechanism has never been run here, so shoot `--view quiz_mid` alone first.
   Run `scripts/verify_store_media.sh` on the bundle before uploading.
7. **Redo the App Store previews** (Josh, 2026-11-15), the videos, by
   [`video_script.md`](video_script.md), in both languages and on both devices, 886 × 1920 and
   1200 × 1600, at 30.000 s. The fourth clip's caption, "Thirty timed questions", is now wrong:
   a round is ten questions, and the clock is hidden by default. Its clip shows a quiz begun from
   the old Quiz tab, so it changes too, and the hub may deserve a clip of its own. The fifth clip
   needs a real iPhone and iPad. Run `scripts/verify_store_media.sh` on the video folder before
   uploading.
8. **The store category** (Decision 10 of the pedagogy report): change the primary category from
   Education to Reference, in App Information, while the new version is being prepared. It cannot
   be done sooner: Apple's table of
   [required, localizable, and editable properties](https://developer.apple.com/help/app-store-connect/reference/app-information/required-localizable-and-editable-properties)
   does not mark Primary Category as editable without submitting a new version (checked
   2026-11-15, in the pedagogy plan's Closing). The change ships with the version.
9. **Submit the version with the four leaderboards and the eight achievements in the same
   submission.** On each one's page, click **Add for Review** and choose the draft submission that
   holds the version. Apple
   requires first-time Game Center components to go with an app version.

## On Release Day

1. **The privacy policy.** Analytics added on `main` since the last release need lines in the
   policy on the day the release ships, and not before. They wait in
   [`privacy_policy_pending.md`](privacy_policy_pending.md), which says how to apply them.
2. **Archive the old leaderboard**, `Leaderboard`, once the release is live, and consider making
   Beginner the default. See [`game_center_setup.md`](game_center_setup.md) § On Release Day.

## Afterward

Delete this document and `CLAUDE.md` § No Release Before 2027, and remove the reminders that
point here.
