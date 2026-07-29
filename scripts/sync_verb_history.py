#!/usr/bin/env python3
"""Push the verb-history essay into Localizable.xcstrings as Info.verbHistoryText.

Consumes:  docs/verb_history.txt (en) or docs/verb_history_de.txt (de), each a header
           block followed by a dashed separator and then the article body verbatim.
Produces:  the matching localization of Info.verbHistoryText in
           Konjugieren/Assets/Localizable.xcstrings, rewritten in place.
Run:       python3 scripts/sync_verb_history.py                # validate, then write en
           python3 scripts/sync_verb_history.py --check        # validate only
           python3 scripts/sync_verb_history.py --lang de      # ditto for the German

Ported from Conjugar's script of the same name. Three things changed on the way across,
and each of them is a way the naive port would have been wrong:

1. **The marker table is different.** Conjugar heads a section with ^…^ and links with
   %…%. Here ^…^ means emoji, links use ‡…‡, and headings use a backtick. Only $…$ means
   the same thing in both apps.
2. **Bad markup crashes this app.** Conjugar's parser drops an unterminated marker
   silently; `StringExtensions.richTextBlocks` and `parseBodyToSegments` call
   `Current.fatalError.fatalError("Unterminated delimiter: …")` instead. So validation is
   not a nicety here, and the balance check has to be per block rather than per essay:
   the backtick pass splits the text first, and each body block is parsed on its own, so
   a stray `~` that happens to be cancelled by another one three headings later still
   crashes.
3. **The link check has no heading table to consult.** Conjugar's %…% could name an Info
   article; ‡…‡ here is only ever a URL, and a payload `URL(string:)` rejects degrades to
   plain text with no warning.

Problems exit 1. Warnings are conventions rather than correctness, so they print and let
the run continue; see the header of docs/verb_history.txt for what each one is protecting.

Every validator here has a negative test in scripts/test_sync_verb_history.py. Run it after
touching `validate`, `check_inline_markers`, `check_link` or `split_blocks`, because a check
that silently stops firing looks exactly like a clean essay.
"""

import json
import pathlib
import re
import sys
import unicodedata
from urllib.parse import urlsplit

REPO = pathlib.Path(__file__).resolve().parent.parent
SOURCES = {
    "en": REPO / "docs/verb_history.txt",
    "de": REPO / "docs/verb_history_de.txt",
}
CATALOG = REPO / "Konjugieren/Assets/Localizable.xcstrings"
KEY = "Info.verbHistoryText"

SUBHEADING = "`"
# The four markers parsed inside a body block. They share one markupStart index in
# parseBodyToSegments, which is why nesting corrupts the enclosing span rather than the
# nested one.
INLINE = {"~": "emphasis", "‡": "link", "$": "conjugation", "^": "emoji"}
SEPARATOR = re.compile(r"^-{20,}$")

# EmojiAsset.assetNames in Konjugieren/Views/RichTextView.swift. BodyTextView substitutes
# an asset for any of these whether it arrives wrapped in ^…^ or bare inside plain text,
# so wrapping is a convention rather than a mechanism. WRAPPED lists the two the catalog
# wraps anyway; the regional-indicator flags are written bare roughly 1,522 times.
MAPPED_EMOJI = {
    "\U0001F1E6\U0001F1F9": "EmojiAustrianFlag",
    "\U0001F1E8\U0001F1ED": "EmojiSwissFlag",
    "\U0001F1E9\U0001F1EA": "EmojiGermanFlag",
    "\U0001F3F4\U000E0067\U000E0062\U000E0065\U000E006E\U000E0067\U000E007F": "EmojiEnglandFlag",
    "\U0001F40E": "EmojiHorse",
}
WRAPPED_BY_CONVENTION = {"\U0001F3F4\U000E0067\U000E0062\U000E0065\U000E006E\U000E0067\U000E007F", "\U0001F40E"}


def body_of(source: pathlib.Path) -> str:
    """The article: everything after the dashed separator line in the header."""
    lines = source.read_text(encoding="utf-8").splitlines(keepends=True)
    for i, line in enumerate(lines):
        if SEPARATOR.match(line.rstrip("\n")):
            return "".join(lines[i + 1:]).strip("\n")
    sys.exit(f"{source}: no dashed separator line found; cannot tell header from body.")


def split_blocks(body: str) -> tuple[list[str], list[str], bool]:
    """`(body_blocks, headings, unterminated)`, mirroring `String.richTextBlocks`.

    That pass walks the whole essay toggling on each backtick, so the segments alternate:
    body, heading, body, heading. Only the body segments reach `parseBodyToSegments`,
    which is why a `~` inside a heading is literal text and not markup.
    """
    segments = body.split(SUBHEADING)
    return segments[0::2], segments[1::2], len(segments) % 2 == 0


def check_inline_markers(block: str, problems: list[str]) -> None:
    """Balance and nesting for one body block, simulating `parseBodyToSegments`.

    The Swift parser keeps a separate `in*` flag per marker but one shared `markupStart`,
    so an inner marker does not fail on its own line. It silently relocates the enclosing
    span's start index, and the damage surfaces when the OUTER marker closes.
    """
    open_marker = None
    for i, char in enumerate(block):
        if char not in INLINE:
            continue
        if open_marker is None:
            open_marker = char
        elif open_marker == char:
            open_marker = None
        else:
            context = block[max(0, i - 60):i + 30].replace("\n", " ")
            problems.append(
                f"{INLINE[open_marker]} contains {INLINE[char]} "
                f"(markers cannot nest): …{context}…"
            )
            open_marker = None
    if open_marker is not None:
        tail = block[-70:].replace("\n", " ")
        problems.append(
            f"unterminated {INLINE[open_marker]} marker {open_marker} in a body block, "
            f"which is a fatalError at render time: …{tail}"
        )


def check_link(payload: str, problems: list[str]) -> None:
    """A ‡…‡ payload must be an absolute http(s) URL.

    The app percent-encodes any payload not starting with "http" and hands it to
    `URL(string:)`, so a relative or malformed one becomes a link to nowhere or, when the
    initializer returns nil, plain text. Neither says anything at build time.
    """
    if not payload.startswith(("http://", "https://")):
        problems.append(f"link ‡{payload}‡ is not an absolute http(s) URL")
        return
    parts = urlsplit(payload)
    if not parts.netloc:
        problems.append(f"link ‡{payload}‡ has no host")
    if any(char.isspace() or unicodedata.category(char) == "Cc" for char in payload):
        problems.append(f"link ‡{payload}‡ contains whitespace or a control character")


def validate(body: str) -> tuple[list[str], list[str]]:
    problems: list[str] = []
    warnings: list[str] = []

    blocks, headings, unterminated_subheading = split_blocks(body)
    if unterminated_subheading:
        problems.append(
            f"unterminated subheading marker {SUBHEADING} "
            f"({body.count(SUBHEADING)} occurrences), which is a fatalError at render time"
        )

    for block in blocks:
        check_inline_markers(block, problems)

    for payload in re.findall(r"‡([^‡]*)‡", body):
        check_link(payload, problems)

    for span in re.findall(r"\$([^$]*)\$", body):
        if span[:1].isupper() and span[1:2].islower():
            problems.append(
                f"conjugation span ${span}$ starts with a lone capital. Uppercase means "
                "'irregular, shown red', not 'sentence start'"
            )

    for payload in re.findall(r"\^([^^]*)\^", body):
        if payload not in MAPPED_EMOJI:
            # Truncated because a dropped ^ makes the "payload" everything up to the next
            # one, which can be several paragraphs and buries the rest of the report.
            shown = payload if len(payload) <= 30 else payload[:30] + "…"
            warnings.append(
                f"emoji span ^{shown}^ names no asset in EmojiAsset, so the markup "
                "renders the literal glyph and does nothing"
            )

    for emoji in WRAPPED_BY_CONVENTION:
        bare = body.count(emoji) - body.count(f"^{emoji}^")
        if bare:
            warnings.append(
                f"{bare} occurrence(s) of {emoji} outside ^…^; the catalog wraps this one"
            )
    for emoji in MAPPED_EMOJI.keys() - WRAPPED_BY_CONVENTION:
        if body.count(f"^{emoji}^"):
            warnings.append(
                f"{body.count(f'^{emoji}^')} occurrence(s) of {emoji} inside ^…^; "
                "the catalog writes the regional-indicator flags bare"
            )

    for match in re.finditer(r"\n\s*" + re.escape(SUBHEADING), body):
        if match.start() == 0:
            continue
        context = body[max(0, match.start() - 40):match.end() + 30].replace("\n", "⏎")
        warnings.append(
            f"newline before an opening {SUBHEADING}; RichTextView adds its own margin, "
            f"so this renders as a blank line: …{context}…"
        )

    for heading in headings:
        if heading != heading.strip():
            warnings.append(f"subheading {heading!r} has leading or trailing whitespace")

    return problems, warnings


def localization_blocks(lines: list[str], start: int) -> list[tuple[str, int, int]]:
    """The `(lang, first_line, last_line)` of each localization under KEY, in file order.

    Xcode's formatting is regular enough to walk by indentation: the localizations live
    at eight spaces inside `"localizations" : {`, and each one's closing brace sits at the
    same indent. `last_line` is inclusive and is the `        }` or `        },` line.
    """
    opener = next(i for i in range(start, start + 4)
                  if lines[i] == '      "localizations" : {\n')
    blocks, i = [], opener + 1
    while lines[i] != "      },\n" and lines[i] != "      }\n":
        match = re.match(r'        "([\w-]+)" : \{\n$', lines[i])
        if not match:
            sys.exit(f"{CATALOG}: unexpected line in {KEY} localizations: {lines[i]!r}")
        end = next(j for j in range(i + 1, len(lines))
                   if lines[j] in ("        }\n", "        },\n"))
        blocks.append((match.group(1), i, end))
        i = end + 1
    return blocks


def write(body: str, lang: str) -> bool:
    """Set KEY's `lang` value in place, preserving Xcode's formatting.

    Line surgery rather than json.load plus json.dump on purpose: Xcode writes
    `"key" : value` and json.dump writes `"key": value`, so a round trip churns all
    ~5,400 lines of the catalog without changing a single value. CLAUDE.md makes
    `git diff --stat` the check that catches it, since the churned file is still valid
    JSON. A correct write shows insertions and zero deletions, or one of each here.
    """
    lines = CATALOG.read_text(encoding="utf-8").splitlines(keepends=True)
    try:
        start = lines.index(f'    "{KEY}" : {{\n')
    except ValueError:
        sys.exit(f"{CATALOG}: key {KEY} not found.")

    blocks = localization_blocks(lines, start)
    value_line = '            "value" : ' + json.dumps(body, ensure_ascii=False) + "\n"
    existing = next((b for b in blocks if b[0] == lang), None)

    if existing:
        _, first, last = existing
        value = next(i for i in range(first, last)
                     if lines[i].startswith('            "value" : '))
        if lines[value] == value_line:
            return False
        lines[value] = value_line
    else:
        after = [b for b in blocks if b[0] < lang]
        block = [
            f'        "{lang}" : {{\n',
            '          "stringUnit" : {\n',
            '            "state" : "translated",\n',
            value_line,
            "          }\n",
            "        }\n",
        ]
        if after:
            # Splice in after the last earlier-sorting localization, which must now
            # carry a comma, while the new block ends the list only if nothing follows.
            insert = after[-1][2] + 1
            lines[after[-1][2]] = "        },\n"
            if insert < blocks[-1][2] + 1:
                block[-1] = "        },\n"
        else:
            insert = blocks[0][1]
            block[-1] = "        },\n"
        lines[insert:insert] = block

    CATALOG.write_text("".join(lines), encoding="utf-8")

    catalog = json.loads(CATALOG.read_text(encoding="utf-8"))
    unit = catalog["strings"][KEY]["localizations"][lang]["stringUnit"]
    assert unit["value"] == body, "catalog round-trip mismatch after write"
    assert unit["state"] == "translated", f"{lang} localization is not marked translated"
    return True


def language() -> str:
    if "--lang" not in sys.argv:
        return "en"
    lang = sys.argv[sys.argv.index("--lang") + 1]
    if lang not in SOURCES:
        sys.exit(f"unknown language {lang!r}; expected one of {', '.join(SOURCES)}")
    return lang


def main() -> None:
    lang = language()
    source = SOURCES[lang]
    if not source.exists():
        sys.exit(f"{source.relative_to(REPO)} does not exist.")
    body = body_of(source)

    problems, warnings = validate(body)
    for warning in warnings:
        print(f"  warning: {warning}", file=sys.stderr)
    if problems:
        print(f"{len(problems)} problem(s) in {source.relative_to(REPO)}:", file=sys.stderr)
        for problem in problems:
            print(f"  - {problem}", file=sys.stderr)
        sys.exit(1)

    _, headings, _ = split_blocks(body)
    spans = len(re.findall(r"\$([^$]*)\$", body))
    print(f"markup OK ({lang}): {len(body.split())} words, {len(headings)} headings, "
          f"{spans} conjugation spans, {len(warnings)} warning(s)")

    if "--check" in sys.argv:
        return
    if write(body, lang):
        print(f"wrote {KEY} ({lang}) into {CATALOG.relative_to(REPO)}")
    else:
        print(f"{CATALOG.relative_to(REPO)} already up to date ({lang})")


if __name__ == "__main__":
    main()
