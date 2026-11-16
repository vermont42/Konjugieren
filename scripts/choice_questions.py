#!/usr/bin/env python3
"""Review and approve the quiz's authored choice questions (Phase 19 of the pedagogy plan).

Consumes: Konjugieren/Models/ChoiceQuestions.json, a JSON array in which each item carries
  id, verb, reading (optional), person (a PersonNumber raw value), level (the QuizLevel from which
  the default quiz asks it), setting (conversation, news, or story), reason (a ChoiceReason raw
  value), right and other (each a table, a ConjugationTable.articleKey, and de, the German with
  each word of the conjugation in braces), en, and reviewed.

Produces, by subcommand:
  review [--all] [--out PATH]
      A Markdown sheet of the drafts (or, with --all, every item), grouped by contrast, with the
      right sentence first, each conjugation in bold, and the reason as the app words it in
      English, for Josh to read. Prints to stdout unless --out is given.
  approve ID [ID ...] | approve --all [--except ID ...]
      Marks items reviewed. The app's release build asks only reviewed items; a debug build asks
      drafts too and marks them "Draft" on the card (ChoiceQuestions.askable, which follows
      GapSentences.includesDrafts).
  status
      Counts of reviewed and draft items by level.

Run from the repo root:  python3 scripts/choice_questions.py review --out plans/choice_questions_batch_1.md

Why it rewrites the whole file: ChoiceQuestions.json is written by json.dumps(indent=2,
ensure_ascii=False) and nothing else, so a load-and-dump round trip reproduces it byte for byte
apart from the changed flags. That is NOT true of Localizable.xcstrings, which Xcode formats with
" : " separators; never point this pattern at that file (see CLAUDE.md).

The machine check lives in KonjugierenTests/Models/ChoiceQuestionTests.swift, which conjugates
both sentences' cells with the app's own conjugator and checks each item's level against the
quiz's levels. Run it after any edit to the file:
  xcodebuild ... -testLanguage en test -only-testing:KonjugierenTests/ChoiceQuestionTests
On its first run it caught "Lasest" for du's Präteritum of lesen, which the conjugator writes
"last"; a drafted conjugation is a guess until the check passes it.
"""

import argparse
import json
import pathlib
import re
import sys

PATH = pathlib.Path(__file__).resolve().parent.parent / "Konjugieren" / "Models" / "ChoiceQuestions.json"

# English names for the sheet. These mirror ConjugationTable.articleKey; a key missing here is
# printed raw, which the machine check would already have rejected as naming no cell.
TABLE_NAMES = {
    "praesens_indikativ": "Präsens Indikativ",
    "praeteritum_indikativ": "Präteritum Indikativ",
    "perfekt_indikativ": "Perfekt Indikativ",
    "plusquamperfekt_indikativ": "Plusquamperfekt Indikativ",
    "futur_indikativ": "Futur Indikativ",
    "imperativ": "Imperativ",
    "praesens_konjunktiv_i": "Präsens Konjunktiv I",
    "perfekt_konjunktiv_i": "Perfekt Konjunktiv I",
    "futur_konjunktiv_i": "Futur Konjunktiv I",
    "praeteritum_konjunktiv_ii": "Präteritum Konjunktiv II",
    "plusquamperfekt_konjunktiv_ii": "Plusquamperfekt Konjunktiv II",
    "futur_konjunktiv_ii": "Futur Konjunktiv II",
}

SETTINGS = {
    "conversation": "In conversation",
    "news": "In a news report",
    "story": "In a written story",
}

# The English of each reason as Localizable.xcstrings words it, with {right} and {other} for the
# conjugationgroup names the app fills in. Kept here by hand so that the sheet shows what the
# learner reads; if a reason is reworded in the catalog, reword it here too.
REASONS = {
    "perfekt_in_conversation": "In conversation, most verbs take the {right}.",
    "praeteritum_of_sein_haben": "Even in conversation, sein, haben, and the modal verbs usually take the {right}.",
    "praeteritum_in_writing": "A written story takes the {right}.",
    "wuerde_for_most_verbs": "For most verbs, speakers use würde with the infinitive, the {right}.",
    "one_word_konjunktiv_ii": "sein, haben, and the modal verbs keep their one-word {right}: wäre, hätte, könnte.",
    "praesens_for_future": "With a word for when, such as morgen, the {right} already speaks of the future.",
    "futur_without_time_word": "Without a word for when, the {other} says what is so now; the {right} makes it a prediction or a guess.",
    "konjunktiv_i_in_reports": "A news report passes on what someone said in the {right}.",
    "indikativ_in_conversation": "In conversation, speakers usually pass on what someone said in the {right}, not the {other}.",
}
LEVELS = ["elementary", "intermediate", "advanced"]


def load():
    return json.loads(PATH.read_text())


def save(items):
    PATH.write_text(json.dumps(items, ensure_ascii=False, indent=2) + "\n")


def bold(german):
    return re.sub(r"\{([^}]*)\}", r"**\1**", german)


def review(items, include_all, out):
    shown = [i for i in items if include_all or not i["reviewed"]]
    title = "Choice questions" if include_all else "Choice questions to review"
    lines = [f"# {title} ({len(shown)})", ""]
    lines.append("Both sentences of every item have passed the machine check, which confirms each")
    lines.append("conjugation against the conjugator. What it cannot judge is the choice itself:")
    lines.append("whether a German speaker or writer in that setting would use the first sentence")
    lines.append("over the second, whether the reason is true of it, and whether the English says")
    lines.append("the same thing. The right sentence is listed first here; the app shows the two")
    lines.append("in either order.")
    reason = None
    for item in sorted(shown, key=lambda i: (LEVELS.index(i["level"]) if i["level"] in LEVELS else 9, list(REASONS).index(i["reason"]) if i["reason"] in REASONS else 99)):
        if item["reason"] != reason:
            reason = item["reason"]
            lines += ["", f"## {item['level'].capitalize()}: {reason.replace('_', ' ')}", ""]
        right = TABLE_NAMES.get(item["right"]["table"], item["right"]["table"])
        other = TABLE_NAMES.get(item["other"]["table"], item["other"]["table"])
        why = REASONS.get(item["reason"], item["reason"]).format(right=right, other=other)
        lines.append(f"- `{item['id']}` · {SETTINGS.get(item['setting'], item['setting'])}")
        lines.append(f"  - ✓ {bold(item['right']['de'])} ({right})")
        lines.append(f"  - ✗ {bold(item['other']['de'])} ({other})")
        lines.append(f"  - *{item['en']}*")
        lines.append(f"  - Reason: {why}")
    text = "\n".join(lines) + "\n"
    if out:
        pathlib.Path(out).write_text(text)
        print(f"Wrote {len(shown)} items to {out}")
    else:
        sys.stdout.write(text)


def approve(items, ids, approve_all, excepted):
    known = {i["id"] for i in items}
    unknown = [i for i in ids + excepted if i not in known]
    if unknown:
        sys.exit(f"Unknown ids: {', '.join(unknown)}")
    chosen = known - set(excepted) if approve_all else set(ids)
    changed = 0
    for item in items:
        if item["id"] in chosen and not item["reviewed"]:
            item["reviewed"] = True
            changed += 1
    save(items)
    print(f"Approved {changed} items")


def status(items):
    for level in LEVELS:
        at = [i for i in items if i["level"] == level]
        print(f"{level}: {sum(i['reviewed'] for i in at)} reviewed, {sum(not i['reviewed'] for i in at)} drafts")
    print(f"total: {len(items)}")


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    sub = parser.add_subparsers(dest="command", required=True)
    review_parser = sub.add_parser("review")
    review_parser.add_argument("--all", action="store_true")
    review_parser.add_argument("--out")
    approve_parser = sub.add_parser("approve")
    approve_parser.add_argument("ids", nargs="*")
    approve_parser.add_argument("--all", action="store_true")
    approve_parser.add_argument("--except", dest="excepted", nargs="*", default=[])
    sub.add_parser("status")
    args = parser.parse_args()
    items = load()
    if args.command == "review":
        review(items, args.all, args.out)
    elif args.command == "approve":
        if not args.ids and not args.all:
            sys.exit("Name ids to approve, or pass --all")
        approve(items, args.ids, args.all, args.excepted)
    else:
        status(items)


if __name__ == "__main__":
    main()
