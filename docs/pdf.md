# Generate Full Verb PDF

## Prerequisites

1. The Fraktur font must be at `/tmp/UnifrakturMaguntia-Book.ttf`. If missing, download it:

```bash
python3 -c "
import urllib.request
url = 'https://github.com/google/fonts/raw/main/ofl/unifrakturmaguntia/UnifrakturMaguntia-Book.ttf'
data = urllib.request.urlopen(url).read()
with open('/tmp/UnifrakturMaguntia-Book.ttf', 'wb') as f:
    f.write(data)
print(f'Downloaded {len(data)} bytes')
"
```

2. The JSON export must be at `/tmp/konjugieren-export.json`. If missing or stale, regenerate it:

```bash
xcodebuild -project Konjugieren.xcodeproj -scheme Konjugieren -destination 'platform=iOS Simulator,name=iPhone 17' -parallel-testing-enabled NO test -only-testing:KonjugierenTests/VerbExportTests/exportAllVerbs\(\)
```

Note: Swift Testing's `--only-testing` filter silently runs zero tests if the method name doesn't match exactly. The real test is `exportAllVerbs()`, and the trailing `()` is required. A run that reports "Test Succeeded" with `0 tests in 1 suite` is the signal that the filter matched the suite but not any method.

3. `reportlab` must be importable by `python3`. On a Homebrew Python install (which marks itself PEP 668 externally-managed), the install command is:

```bash
python3 -m pip install --user --break-system-packages reportlab
```

`--user` puts the package in `~/Library/Python/3.12/lib/python/site-packages`, outside Homebrew's tree; `--break-system-packages` is the PEP 668 escape hatch the error message itself recommends in combination with `--user`.

## Generate the PDF

```bash
python3 scripts/generate_verb_pdf.py
```

Output: `/tmp/konjugieren-verbs.pdf`

Use `--count N` to limit to the first N verbs for testing (e.g., `--count 5`).

## Structure

- **Page 1**: Fraktur title page — "Konjugieren" / "Nearly 1,000 German Verbs" / "Josh Adams"
- **Pages 2–~7**: Three-column verb index with page numbers
- **Remaining pages**: One verb per page (some overflow to two pages) with conjugations, etymology, and example sentences

The index columns fill in snake order — column 1 of a page fills top-to-bottom, then column 2 of the *same* page, then column 3, then the next page's column 1. This is the natural reading order for a printed index, not the row-major order that `Table` flowables produce.

## Layout architecture

The generator uses `BaseDocTemplate` with four `PageTemplate`s, switched via `NextPageTemplate` + `PageBreak`:

| Template | Frames | Page numbers? | Used for |
|---|---|---|---|
| `title` | 1 single full-page frame | no | page 1 |
| `indexFirst` | heading frame on top + 3 column frames below | yes | first index page |
| `indexCont` | 3 column frames spanning full height | yes | subsequent index pages |
| `verb` | 1 single full-page frame | yes | one per verb |

`indexFirst.autoNextPageTemplate = "indexCont"` automatically switches to the continuation template once the first index page fills — no bookkeeping required in the flowable list. The flowable list itself is just `[Paragraph("Index"), FrameBreak(), entry1, entry2, …]`; the `FrameBreak` skips past the heading frame so entries land in the first column frame.

## Two-pass page-numbering algorithm

Each verb's index entry needs to reference the page where that verb actually starts, but the verb pages don't exist until layout runs. The generator solves this with two passes:

1. **Pass 1**: build the document with placeholder page numbers (`0`) in every index entry. A zero-size `VerbMarker` flowable is inserted before each verb's content; its `draw()` method records `canv.getPageNumber()` into a `VerbPageTracker`. Output is written to a temp file that's immediately deleted.
2. **Pass 2**: replace the placeholders with the recorded page numbers and rebuild to the real output path.

This works **only if pass 1 and pass 2 produce identical pagination**. The invariant holds because every index entry fits on a single line regardless of whether its page number is `0` (1 character) or `1015` (4 characters) — the longest German verb name plus the longest expected page-number text comfortably fits within the 2.1-inch column width. If a future change widens the entry text (e.g., a longer leader, larger font) so that some entries wrap, pagination between passes will diverge and the recorded page numbers will be wrong. Watch for that.

## History

The earlier version of this generator had two bugs that the multi-frame architecture fixes:

- **Off-by-one page numbers in the index**: pass 1 reserved space for the index with `estimated_index_pages` empty pages (`Spacer + PageBreak`); the estimate `(verb_count + 149) // 150` overshot the real index by one page for the 990-verb dataset, so every recorded page number was one too high.
- **Index columns continuing on the next page instead of filling the current one**: the old code built a single `Table` with `rows_per_col = ceil(verb_count / 3)` rows. Reportlab paginates tables by splitting rows, so row 0 of all three columns landed on page 1, row 1 of all three columns landed on page 1, etc. — meaning column 2 of the table started ~330 entries deep into the alphabet, and column 2 of *page 1* held entries from column 2 of the *table*, not the continuation of column 1.

Both bugs shared the same root cause: the placeholder-driven pass 1 didn't match the real pass 2. Using real frames as the layout primitive (instead of approximating with spacers and tables) eliminates the impedance mismatch in both directions.
