I had Claude research how Konjugieren teaches conjugation and suggest improvements. That research, with my verdicts on each suggestion and my answers to its "Decisions for Josh", is in docs/pedagogy_research.md . I then had Claude implement the accepted suggestions using plans/pedagogy_implementation.md , in 24 phases and a Closing, from e385749 (the commit before Phase 1) through 4d22060 (the Closing). A lot of code got added: about 25,800 lines across some 118 files, covering grading, levels, a practice record, Review and My Mistakes, the practice hub, recognition, sentences with a blank, mastery, the speed round, the daily session and streak, achievements, and the daily challenge. Please review that code for correctness, smells, gaps, duplication, and elegance. Output your findings to plans/pedagogy_fixes.md . That file should act as a plan to fix the findings, in proposed phases. Implementing sessions will mark each phase as done and note how their implementations differed from the plan.

Because there is no separate review document, the plan must hold the findings themselves. Give each finding a label (C1, P1, and so on), its file and line, its evidence, how it was verified, and a suggested fix, and have the phases cite findings by label. Line numbers will drift as phases land, so tell implementing sessions to find code by name.

Where a finding needs a decision from me, list it under "Decisions for Josh", and mark the phases that depend on it as waiting for my answer. Implementing sessions should ask me rather than guess, and record my answer and its date in the phase's note.

Every phase waits for me before git. An implementing session finishes its work, runs the build and tests, marks the phase "Awaiting Josh", and does not run git add, git commit, or git push until I have tried the change and said to commit. Give the plan's Status table a Commit column that stays empty until then, as plans/verb_browse_fixes.md does.

Some guidance:

- Review the code as it stands on main, not as each phase left it. Later work changed some of it.
- docs/verb_browse_review.md already reviewed the Browse and verb code, and plans/verb_browse_fixes.md fixed what it found. Some of that touched pedagogy code, such as the quiz correction's group link and QuizScope. Don't re-report those findings, but do say if a fix there is incomplete or broke something here.
- Each phase's "How it differed" note records what departed from the plan and why. Read the notes before calling something a gap, and check whether the code matches what the notes claim.
- Besides code quality, note any place where the built feature undercuts the pedagogical aim its suggestion in docs/pedagogy_research.md stated, such as a retry that leaks the answer or a schedule that never resurfaces an item.
- Decision 5 says no analytics signal may carry an answer, a score, an accuracy, or a verb. Check that it still holds, and that docs/privacy_policy_pending.md covers every signal.
- Quiz generation is random. Judge whether the tests that use SeededRNG prove what they claim.
- The iPhone simulator's system language is German, so run the suite with xcodebuild -testLanguage en, as the Closing's note explains. Read the test count, not just the exit status.

If running the app to try the new functionality is helpful, please do so using ios-build-verify . If you choose to launch subagents, please use Opus subagents.
