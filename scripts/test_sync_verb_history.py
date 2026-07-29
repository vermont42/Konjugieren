#!/usr/bin/env python3
"""Negative-test every validator in scripts/sync_verb_history.py.

Consumes:  scripts/sync_verb_history.py and docs/verb_history{,_de}.txt.
Produces:  a report on stdout. Exit 0 if every validator caught its corruption, 1 otherwise.
Run:       python3 scripts/test_sync_verb_history.py

Nothing is written. Each case corrupts an in-memory copy of the English body one way and
asserts that `validate` names the corruption; the real files are never touched.

Why this exists
---------------
A validator nobody has seen fail is a validator nobody has seen. That is not an abstract
worry here: writing these cases is what revealed that a `^` removed mid-essay does NOT go
unterminated, because the next `^` pairs with it, so the failure surfaces several paragraphs
away as a cascade of nesting errors ending in an unterminated `~`. The first version of the
unterminated-emoji case therefore passed for the wrong reason and had to be rewritten to put
the stray marker at the very end of the text. Both shapes are now cases, so the next person
to touch the parser learns the same thing from a green run rather than from debugging.

The severity split mirrors the script's
---------------------------------------
`bucket` is "problem" or "warning" and must match where the script files the corruption.
Problems are crashes or broken renders and exit 1; warnings are conventions and do not.
Getting a case's bucket wrong is itself a finding about the script.

When a case fails to set up
---------------------------
Each corruption replaces a literal anchor string from the essay. Editing the essay can make
an anchor vanish, which reports as SETUP FAIL rather than silently passing with a no-op
corruption. **Repoint the anchor. Do not delete the case.** A validator whose test was
deleted because the prose moved is a validator nobody has seen.
"""

import importlib.util
import pathlib
import sys

REPO = pathlib.Path(__file__).resolve().parent.parent
SCRIPT = REPO / "scripts/sync_verb_history.py"

spec = importlib.util.spec_from_file_location("sync_verb_history", SCRIPT)
sync = importlib.util.module_from_spec(spec)
spec.loader.exec_module(sync)

HORSE = "\U0001F40E"
GERMAN_FLAG = "\U0001F1E9\U0001F1EA"

# (name, bucket, expected substring of the report, corruption)
CASES = [
    # One case per marker for the balance check, which is the one the app turns into a
    # fatalError rather than a render bug.
    ("unterminated subheading", "problem", "unterminated subheading",
     lambda b: b.replace("`The Long Road to Language`", "`The Long Road to Language", 1)),
    ("unterminated emphasis", "problem", "unterminated emphasis",
     lambda b: b.replace("~Homo sapiens~", "~Homo sapiens", 1)),
    ("unterminated conjugation", "problem", "unterminated conjugation",
     lambda b: b.replace("$sAng$, $gesUngen$", "$sAng$, $gesUngen", 1)),
    # The stray marker has to be the LAST one in the text. See the module docstring: a ^
    # dropped mid-essay is stolen by the next ^ and never reports as unterminated.
    ("unterminated emoji", "problem", "unterminated emoji", lambda b: b + " ^"),
    ("emoji marker stolen by the next one", "problem", "emoji contains emphasis",
     lambda b: b.replace(f"^{HORSE}^ ~Imperfective~", f"^{HORSE} ~Imperfective~", 1)),

    ("nested conjugation in emphasis", "problem", "emphasis contains conjugation",
     lambda b: b.replace("~Homo sapiens~", "~Homo $sAng$ sapiens~", 1)),
    # The reason balance is checked per body block rather than per essay: these two tildes
    # cancel across a heading boundary, so a whole-essay parity count would call it clean
    # while the app crashes on the first block.
    ("balanced across headings but not within a block", "problem", "unterminated emphasis",
     lambda b: b.replace("~Homo sapiens~", "~Homo sapiens", 1)
                .replace("~Aspect~ was paramount", "~Aspect~ was~ paramount", 1)),

    # Three ways a ‡…‡ payload fails. The essay currently has no links at all, so every one
    # of these has to be injected; that is the point of keeping them.
    ("relative link", "problem", "not an absolute http(s) URL",
     lambda b: b.replace("~kurgans~", "~kurgans~ ‡Ablaut: The Heart‡", 1)),
    ("link with no host", "problem", "has no host",
     lambda b: b.replace("~kurgans~", "~kurgans~ ‡https:///wiki/Yamnaya‡", 1)),
    ("link with a space", "problem", "whitespace or a control character",
     lambda b: b.replace("~kurgans~", "~kurgans~ ‡https://example.com/a b‡", 1)),

    ("lone capital in a conjugation span", "problem", "starts with a lone capital",
     lambda b: b.replace("$sAng$, $gesUngen$", "$Sang$, $gesUngen$", 1)),

    # The four convention checks. None of these breaks the app, which is why they warn.
    ("emoji span with no asset", "warning", "names no asset in EmojiAsset",
     lambda b: b.replace("🐄 ~Perfective~", "^🐄^ ~Perfective~", 1)),
    ("horse written bare", "warning", "outside ^…^",
     lambda b: b.replace(f"^{HORSE}^ ~Imperfective~", f"{HORSE} ~Imperfective~", 1)),
    ("country flag wrapped", "warning", "the catalog writes the regional-indicator flags bare",
     lambda b: b.replace(f"{GERMAN_FLAG} singen,", f"^{GERMAN_FLAG}^ singen,", 1)),
    ("newline before a heading", "warning", "renders as a blank line",
     lambda b: b.replace("conjugate verbs.`The Long Road", "conjugate verbs.\n`The Long Road", 1)),
    ("padded heading", "warning", "leading or trailing whitespace",
     lambda b: b.replace("`The Long Road to Language`", "`The Long Road to Language `", 1)),
]


def run_cases(body: str) -> int:
    failures = 0
    for name, bucket, expected, corrupt in CASES:
        corrupted = corrupt(body)
        if corrupted == body:
            print(f"SETUP FAIL  {name}: the corruption did not change the text; "
                  "repoint the anchor rather than deleting the case")
            failures += 1
            continue
        problems, warnings = sync.validate(corrupted)
        reported = problems if bucket == "problem" else warnings
        other = warnings if bucket == "problem" else problems
        if any(expected in line for line in reported):
            # A corruption often trips more than one check. Reporting the count of
            # collateral hits keeps that visible without asserting on it, since which
            # extra checks fire is an artifact of where in the text the damage lands.
            noise = f", plus {len(other)} in the other bucket" if other else ""
            print(f"ok          {name}{noise}")
        else:
            print(f"FAIL        {name}: expected {expected!r} in the {bucket} list")
            print(f"            problems={problems}")
            print(f"            warnings={warnings}")
            failures += 1
    return failures


def check_shipping_extracts() -> int:
    """Both extracts must validate clean, which is a regression check on the prose too.

    Problems fail. Warnings are printed and tolerated, because a warning is a convention
    Josh may legitimately decide against in a later edit and the test should not veto that.
    """
    failures = 0
    for lang, path in sorted(sync.SOURCES.items()):
        if not path.exists():
            print(f"FAIL        {path.relative_to(REPO)} does not exist")
            failures += 1
            continue
        problems, warnings = sync.validate(sync.body_of(path))
        for warning in warnings:
            print(f"  note      {lang}: {warning}")
        if problems:
            print(f"FAIL        {path.relative_to(REPO)}: {len(problems)} problem(s)")
            for problem in problems:
                print(f"            - {problem}")
            failures += 1
        else:
            print(f"ok          {path.relative_to(REPO)} validates clean")
    return failures


def main() -> None:
    body = sync.body_of(sync.SOURCES["en"])
    failures = run_cases(body) + check_shipping_extracts()
    total = len(CASES) + len(sync.SOURCES)
    print(f"\n{total} checks, {failures} failure(s)")
    sys.exit(1 if failures else 0)


if __name__ == "__main__":
    main()
