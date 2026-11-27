# Timed Workarounds

**Written:** 2026-11-27, for finding S7 of [`verb_browse_review.md`](verb_browse_review.md), in the
Closing of [`plans/verb_browse_fixes.md`](../plans/verb_browse_fixes.md).

A timed workaround waits a fixed time, or polls, because iOS gives no event for the moment the code
needs. Each one is a bet about how long iOS takes, and a new iOS can win it or lose it. This list
exists so that each can be retried on each new iOS, and removed when iOS no longer needs it.

Code is named by type and function, not line, since lines drift. Each wait is also commented in the
code as a hack, with what was tried first.

## How to Retry One

Set the wait to zero (or make the poll return at once), build, and do what the last column says. If
the failure in the third column does not appear, on the iPhone and the iPad simulators and ideally
on a device, the workaround can go. Record the iOS version and the result here either way.

## The List

| Where | Waits | What iOS does without it | How to tell |
|---|---|---|---|
| `VerbBrowseView.searchFocusChanged` (`searchLingering`) | 700 ms after the search field loses focus, before the recent verbs and the letter row go | On iPad, a tap outside an empty search field ends the search at touch-down, so the views that followed the focus vanish under the finger, and the tap lands on nothing. | iPad: focus the empty field while Recent has verbs, then tap a recent verb, and again tap ä. Each must work. |
| `ViewControllerTransitions.waitUntilIdle`, called by `VerbBrowseView.pushFromSearch` and `insertLetter` | Polls every 50 ms, for at most a second, until no view controller is presenting or dismissing | UIKit drops a navigation push made while the search is animating away ("the navigation stack will not be updated"), and a letter set meanwhile is lost or shows in the results but not the field. | iPad: from the focused empty field, tap a recent verb; then tap ä after a tap has ended the search. Watch the console for the message. |
| `VerbBrowseView.showSearch` | 500 ms after popping the Verbs tab to its root, before focusing the field | Focus requested while the pop animates sets the focus state without making the field first responder, so typing goes nowhere. | From a verb page pushed on the Verbs tab, press Command-F on the iPad, or use the Search quick action or control. Type, and the letters must appear. |
| `ConjugationgroupArticleSheet.open(_:)` in `VerbView.swift` | 400 ms after dismissing the article sheet, before handling a verb link from the article | SwiftUI drops a navigation change made while a sheet is still animating away, so the new verb's page never appears. | On a verb page, open a conjugationgroup's article and tap a link to a verb in it. The new verb's page must replace the old one. |
| `FamilyDetailView`'s `.task` | 300 ms before scrolling to a requested collection | The expanded group is not yet laid out, so the scroll cannot find it. | Open an ablaut group from a quiz correction's group link. The Strong page must land on that group's header. |
| `InfoBrowseView`'s `.task(id: shouldNavigateToTutor)` | 500 ms before pushing the Tutor | Not recorded. It dates from 2026-03-07 (`5d48183`), when onboarding's Tutor page began switching to the Info tab and pushing the Tutor; the wait most likely lets the tab switch settle. | Needs Apple Intelligence, so a device or an Apple Silicon Mac: from onboarding's Tutor page, open the Tutor. It must be pushed. |
| `QuizView`'s focus waits | 100 ms when a session starts from the hub and when a choice question gives way to a typed one; 450 ms after Ten More's results sheet goes and after returning from a page opened from a correction; 50 ms in `refocusAnswer` and after an incomplete recognition answer | Focus set before the answer field is on screen, or while a sheet or a pop is still animating, does not take, so the keyboard does not come up and Return does nothing. | With a hardware keyboard and without one: start a session from the hub, answer a choice question, take Ten More, and open a verb from a correction and come back. Each time the keyboard must be in the answer field. |
| `Quiz.announceQuestion` and the results announcement | 0.5 to 1.5 s before VoiceOver speaks the question, the "asked again" note, or the results | VoiceOver's own announcement of the screen change cuts off speech posted at once. The gaps between the verb and its translation are pacing, not a workaround. | On a device with VoiceOver: answer questions, including a re-ask, and finish a quiz. Nothing must be cut off. |

## Timers That Are Not Workarounds

These wait on purpose and need no retrying: the four seconds the copied-address note stays in
`FailedSearchHelp`, the 300 ms highlight of `SpeakOnTap`, and the quiz's 0.6 s check and flash
and 80 ms shake steps. The review counted the note among the workarounds; it is a display duration.

## Superseded Tasks

The plan asked that a task be cancelled when a newer one supersedes it, where that is one line.
None is.

- **The note in `FailedSearchHelp`.** A second tap on the mail link within four seconds shows the
  note again, and the first tap's task then hides it early. Cancelling needs the task stored in
  state and a check after the sleep, since `try? await Task.sleep` swallows the cancellation.
  Left.
- **`searchLingering`.** If the field regains focus and loses it again within 700 ms, the first
  task lets the views go early, which is the failure the wait exists to prevent. The same stored
  task would fix it. Left, since it needs a refocus and blur inside 0.7 s.
- **`FamilyDetailView` and `InfoBrowseView`** use `.task`, which SwiftUI cancels on its own.
- **`showSearch`, the article sheet, and `QuizView`'s refocus** do the same thing however many
  times they run, so a superseded run is harmless.

## Retry Log

| Date | iOS | Workaround | Result |
|---|---|---|---|
| | | | |
