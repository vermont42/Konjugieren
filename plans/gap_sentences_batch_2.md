# Prompt: Phase 18's Remaining Sentences

For a fresh Claude Code session. Paste everything below the line as its first message. Written
2026-11-15, after the pedagogy plan's Closing, from Josh's decision that day not to review the
sentences himself.

---

Please finish Phase 18 of plans/pedagogy_implementation.md: the Sentences exercise's remaining sentences, about 625, for the verbs ranked 26 to 300 by frequency.

Read first: Phase 18 in that plan, above all its **How it differed** (the counts, the format, what the machine check requires, the drafting rules, American English); `Konjugieren/Models/GapSentences.json` (the 117 shipped sentences are your style model); `KonjugierenTests/Models/GapSentenceTests.swift`; and `scripts/gap_sentences.py`. Also read the plan's "How to Work This Plan", whose finishing steps apply.

**A new decision from Josh (2026-11-15): he will not review these sentences.** This replaces the 2026-11-13 decision that he reviews every sentence before it ships. The review is now yours: the machine check settles each conjugation, and you settle everything else by reading every sentence yourself, not just sampling. Check that the German is grammatical and natural, that the English says what the German says in American English, that the cell is the one the sentence actually needs, and that the level fits. Fix or drop what fails, then mark the rest reviewed with `python3 scripts/gap_sentences.py approve`. Record this decision and its date in Phase 18's How it differed.

**The counts, as Josh set them:**
- Verbs 26 to 100: three sentences each, one for each of three level groups: the Präsens or the Imperativ; the Perfekt; then the Präteritum or a Konjunktiv.
- Verbs 101 to 300: two sentences each, from cells Elementary and above ask, since Beginner never asks these verbs.
- Take the ranking from the app's own frequency data, the order `FrequencyBand.top300` uses. anfangen, ankommen, and einladen already have sentences; top them up to their count only if they fall short.

**Drafting with Sonnet subagents.** Delegate the drafting to subagents on Sonnet (`model: "sonnet"` on the Agent tool, as the plan requires). Split the verbs into ranges of about 25 and launch the subagents in parallel. Give each one a self-contained brief:
- the JSON format, with three real entries copied from the file;
- the id scheme (`gehen.perfekt.1`);
- the brace rule: each word of the conjugation in braces, including the wir or Sie of an Imperativ;
- the rules from the phase notes: modals never in the Perfekt; stehen and liegen never in a compound cell; no weil or other subordinate clause with a compound conjugationgroup; a separable verb after a conjunction written joined;
- short sentences a learner at the cell's level can read;
- American English;
- the exact ranked verb list for its range.

Each subagent writes its drafts to its own file in your scratchpad, not to the repo. You merge them into `GapSentences.json` with `"reviewed": false`, writing only through `json.dumps(indent=2, ensure_ascii=False)`, as the script's header explains.

**Then:**
1. Run the machine check:
   `xcodebuild -project Konjugieren.xcodeproj -scheme Konjugieren -destination 'platform=iOS Simulator,name=iPhone 17' -testLanguage en test -only-testing:KonjugierenTests/GapSentenceTests`
   Read the test count, not the exit status.
2. Fix every failure, then do your full reread, then approve.
3. `python3 scripts/gap_sentences.py status` should show no drafts.
4. Run the full suite with `-testLanguage en`, as CLAUDE.md now says.
5. Look at Sentences in the app: at Elementary and at Advanced on the iPhone 17 (German, then English), and on the iPad Pro 11-inch (M5) in English. Confirm that no card says "Draft" and that rounds now draw from many verbs.

Finish as the plan's phases do:
- Phase 18's Status row and Status line become Done.
- The plan's "The plan is finished" paragraph loses its exception.
- The report's Phase 18 line in `docs/pedagogy_research.md` becomes **Built on `main`**.
- Append a journal entry to `docs/blog_notes.md`.
- Run `python3 scripts/check_docs.py`.
- Stop before git and tell Josh how to try it.
