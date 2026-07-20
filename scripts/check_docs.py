#!/usr/bin/env python3
"""Assert the checkable claims this repo's documentation makes about itself.

Consumes:  the repo's Markdown files, Konjugieren/Models/{Verbs,AblautGroups}.xml,
           Konjugieren/Assets/Localizable.xcstrings, KonjugierenTests/**.swift, and `git`.
Produces:  a report on stdout. Exit 0 if every claim holds, 1 otherwise.
Run:       python3 scripts/check_docs.py

Why this exists
---------------
`docs/verb-sources.md` § "Verify counts, do not trust them" was written after three documents
claimed 989 verbs while the corpus held 990, one of them `docs/description.md`, which shipped the
wrong number to the App Store. That section asked future sessions to verify by set difference.
Five days later all four claim sites were stale again, `description.md` among them, so the App
Store count was wrong twice. Prose asking to be re-read does not get re-read. This does the check.

Caches assert, journals narrate
-------------------------------
The design constraint is that a naive grep for "N verbs" across the repo is ~90% false positives.
`docs/blog_notes.md` is *supposed* to say 990 in an entry written when the corpus held 990;
`docs/roadmap.md` records "corpus 3,383 → 3,572" as history; `docs/verb-sources.md` quotes
Conjuguer's 6,200 and a 9,217-candidate pool, neither of which is Konjugieren's corpus.

So the count checks are scoped **by file, not by pattern**, using a distinction the repo already
draws in prose: CLAUDE.md calls `project-structure.md` a cache, `roadmap.md` opens by calling
itself one, and `blog_notes.md` is dated project memory whose value is preserving what was true
then. Only files that describe the app *as it is now* are checked. That set is deliberately tiny
and is listed in CACHE_FILES; adding a file to it is a promise that the file makes no historical
claims about corpus size.

Link and commit-hash checks need no such exemption: a link either resolves or does not, whenever
it was written.
"""

import json
import re
import pathlib
import subprocess
import sys
import xml.etree.ElementTree as ET

REPO = pathlib.Path(__file__).resolve().parent.parent

# Files that describe the app as it is now. A verb count in one of these is a claim about the
# current corpus, so it must equal len(Verbs.xml). Every other Markdown file in the repo may
# state any count it likes, because it is narrating history.
CACHE_FILES = [
    "README.md",
    "CLAUDE.md",
    "docs/description.md",
    "docs/project-structure.md",
]

# Directories whose Markdown is not this repo's documentation.
SKIP_DIRS = {".git", "node_modules", ".build", "DerivedData"}


def markdown_files():
    """Every tracked-ish Markdown file, in a stable order for reproducible reports."""
    return sorted(
        p for p in REPO.rglob("*.md")
        if not (SKIP_DIRS & set(p.relative_to(REPO).parts))
    )


def rel(path):
    return path.relative_to(REPO).as_posix()


# ---------------------------------------------------------------------------
# Check 1: corpus counts in the cache files
# ---------------------------------------------------------------------------

# Matches "3,572 verbs", "3.572 Verben" (the German App Store copy uses a period as the
# thousands separator), and "3,572 verb definitions". The {2,} on the digit tail requires at
# least three characters, which keeps "14 German conjugationgroups" out without an allowlist.
VERB_COUNT_RE = re.compile(
    r"\b(\d[\d.,]{2,})\s+(?:German\s+|deutsche\s+)?(?:verbs?|Verben)\b", re.IGNORECASE
)

# README's XMLParser bullet claims an ablaut-group count alongside the verb count.
PATTERN_COUNT_RE = re.compile(r"\b(\d[\d.,]{1,})\s+patterns\b", re.IGNORECASE)

# README claims a test count in two places, in both cases counting @Test functions.
TEST_COUNT_RE = re.compile(r"\b(\d[\d.,]{1,})\s+tests?\b(?!\s*/)", re.IGNORECASE)

# A count is checkable only when its subject is the whole thing. "3,572 verbs" is unambiguous
# because the app has one corpus, but prose routinely scopes a test count to a single suite:
# CLAUDE.md says ConjugatorTests contains "~25 test functions" and project-structure.md says
# "~50", both true and both about one file. The discriminator is that a scoped claim names the
# file it is scoped to, so a line mentioning a .swift file is left alone.
SCOPED_TO_FILE_RE = re.compile(r"\.swift\b")


def parse_count(text):
    """'3,572' and '3.572' both mean 3572. No count in this repo is a decimal fraction."""
    return int(text.replace(",", "").replace(".", ""))


def check_corpus_counts():
    failures = []

    verbs = len(ET.parse(REPO / "Konjugieren/Models/Verbs.xml").getroot())
    groups = len(ET.parse(REPO / "Konjugieren/Models/AblautGroups.xml").getroot())
    # Counting the @Test attribute is the same proxy README's prose uses: a parameterized
    # @Test(arguments:) is one function reporting many cases, and README says "test functions".
    tests = sum(
        len(re.findall(r"@Test", p.read_text()))
        for p in (REPO / "KonjugierenTests").rglob("*.swift")
    )

    expectations = [
        (VERB_COUNT_RE, verbs, "verb count", "Konjugieren/Models/Verbs.xml"),
        (PATTERN_COUNT_RE, groups, "ablaut-group count", "Konjugieren/Models/AblautGroups.xml"),
        (TEST_COUNT_RE, tests, "test count", "@Test occurrences in KonjugierenTests"),
    ]

    for name in CACHE_FILES:
        path = REPO / name
        for lineno, line in enumerate(path.read_text().splitlines(), 1):
            if SCOPED_TO_FILE_RE.search(line):
                continue
            for regex, actual, label, source in expectations:
                for match in regex.finditer(line):
                    claimed = parse_count(match.group(1))
                    if claimed != actual:
                        failures.append(
                            f"{name}:{lineno}: {label} claims {match.group(1)}, "
                            f"but {source} has {actual}"
                        )
    return failures


# ---------------------------------------------------------------------------
# Check 2: relative links resolve
# ---------------------------------------------------------------------------

# [text](target) with an optional #fragment. Bare autolinks and reference-style links are not
# used in this repo, so the simple form suffices.
LINK_RE = re.compile(r"\[[^\]]*\]\(([^)#\s]+)(?:#[^)]*)?\)")


def check_links():
    """Every relative Markdown link points at a file that exists.

    Checked in all Markdown, journals included: unlike a count, a link is not true-as-of-a-date.
    This is the check that would have caught `verb-sources.md` pointing at `etymology-pipeline.md`
    while calling it nonexistent, and README pointing at Models/GameState.swift after the file
    moved to Models/Game/.
    """
    failures = []
    for path in markdown_files():
        for lineno, line in enumerate(path.read_text().splitlines(), 1):
            for match in LINK_RE.finditer(line):
                target = match.group(1)
                if target.startswith(("http://", "https://", "mailto:")):
                    continue
                if not (path.parent / target).exists():
                    failures.append(f"{rel(path)}:{lineno}: broken link to {target}")
    return failures


# ---------------------------------------------------------------------------
# Check 3: cited commit hashes resolve
# ---------------------------------------------------------------------------

# Backtick-quoted hex of git-abbreviation length. The 40 ceiling excludes the 64-character
# SHA-256 in verbdata/README.md, which pins the kaikki snapshot and is not a commit; the 7 floor
# excludes hex colors. `git cat-file` is the arbiter, so a false positive here is harmless
# unless the token happens to also name a real object.
HASH_RE = re.compile(r"`([0-9a-f]{7,40})`")


# Checked in roadmap.md alone, and this scoping is load-bearing rather than cautious. This
# repo's docs legitimately cite commits that live in *other* repositories and can never resolve
# here: `52e4d6f` is an ios-build-verify marketplace commit, `1f359d4` is Conjuguer's, and
# `ee61032` / `c2e9632` are Conjugar's. Nothing in the text distinguishes those from a local
# hash, so a repo-wide check reports four sibling-app citations as broken forever. roadmap.md's
# "Done, for the record" table is this repo's own provenance by construction, which makes it the
# one place where an unresolvable hash means a rebase orphaned a citation.
HASH_FILES = ["docs/roadmap.md"]


def check_commit_hashes():
    """Commit hashes in roadmap.md's provenance table still resolve."""
    failures = []
    seen = {}
    for path in (REPO / name for name in HASH_FILES):
        for lineno, line in enumerate(path.read_text().splitlines(), 1):
            for match in HASH_RE.finditer(line):
                sha = match.group(1)
                if sha not in seen:
                    result = subprocess.run(
                        ["git", "cat-file", "-e", f"{sha}^{{commit}}"],
                        cwd=REPO, capture_output=True,
                    )
                    seen[sha] = result.returncode == 0
                if not seen[sha]:
                    failures.append(f"{rel(path)}:{lineno}: no such commit {sha}")
    return failures


# ---------------------------------------------------------------------------
# Check 4: the attribution invariant
# ---------------------------------------------------------------------------

def check_attribution():
    """If kaikki-derived verbs ship, the Credits article must credit kaikki.org.

    `verbdata/README.md` stated this as a condition in prose on 2026-07-18 ("attribution belongs
    in the Credits article if derived data ships"). The condition went true with tranche 1 on
    2026-07-19 and nobody re-read the row; the credit landed 2026-07-20, a day and two tranches
    late. Written as an assertion it would have failed the whole time.

    `hp="y"` is the marker: it means the hit count is an editorial estimate, which is true of
    every verb imported from kaikki and of nothing in the original 990.
    """
    failures = []
    verbs = ET.parse(REPO / "Konjugieren/Models/Verbs.xml").getroot()
    imported = [v for v in verbs if v.get("hp") == "y"]
    if not imported:
        return failures

    catalog = (REPO / "Konjugieren/Assets/Localizable.xcstrings").read_text()
    credits = catalog.split('"Info.creditsText"')[1].split('"Info.dedication')[0]
    for token, why in [
        ("kaikki", "names kaikki.org, the extraction the data came through"),
        ("Wiktionary", "names Wiktionary, the CC BY-SA licensor"),
        ("CC BY-SA", "names the license"),
    ]:
        if token not in credits:
            failures.append(
                f"{len(imported)} verbs carry hp=\"y\" (kaikki-derived), but Info.creditsText "
                f"never {why}"
            )
    return failures


# ---------------------------------------------------------------------------

def check_etymology_completeness():
    """docs/etymology-pipeline.md may not claim completeness while coverage is short.

    That file led with "COMPLETE — every verb in Verbs.xml is translated" from 2026-07-19 until
    2026-07-20, during which the corpus went 990 → 3,572 and 2,582 verbs acquired no etymology.
    What makes it worth a check rather than a one-time fix is that the same file, two lines
    below the false headline, warns against trusting a count in prose and supplies the exact
    coverage command that disproves it. The recipe was right and nobody ran it.

    Phrased as a conditional so it self-clears: when roadmap step 10 fills the gap, the claim
    becomes true and the check goes quiet without anyone editing this script.
    """
    failures = []
    doc = REPO / "docs/etymology-pipeline.md"
    # Match the bolded status headline, not the word. A plain substring test fails twice over on
    # the current text: "INCOMPLETE" contains "COMPLETE", and the paragraph explaining the
    # correction quotes the old headline verbatim. The claim is specifically a line beginning
    # "**COMPLETE", so that is what is asserted against.
    if not re.search(r"^\*\*COMPLETE\b", doc.read_text(), re.MULTILINE):
        return failures

    verbs = {
        re.sub(r"[+*^]", "", v.get("in"))
        for v in ET.parse(REPO / "Konjugieren/Models/Verbs.xml").getroot()
    }
    sections = json.loads((REPO / "Konjugieren/Models/Etymologies.json").read_text())
    for lang, section in sections.items():
        missing = verbs - set(section)
        if missing:
            failures.append(
                f"docs/etymology-pipeline.md claims COMPLETE, but {len(missing)} verbs "
                f'have no "{lang}" etymology (e.g. {", ".join(sorted(missing)[:3])})'
            )
    return failures


CHECKS = [
    ("corpus counts in cache files", check_corpus_counts),
    ("relative links", check_links),
    ("cited commit hashes", check_commit_hashes),
    ("kaikki attribution invariant", check_attribution),
    ("etymology completeness claim", check_etymology_completeness),
]


def main():
    total = 0
    for label, check in CHECKS:
        failures = check()
        total += len(failures)
        status = "FAIL" if failures else "ok"
        print(f"[{status}] {label}" + (f" ({len(failures)})" if failures else ""))
        for failure in failures:
            print(f"       {failure}")
    print()
    print(f"{total} problem{'' if total == 1 else 's'}")
    return 1 if total else 0


if __name__ == "__main__":
    sys.exit(main())
