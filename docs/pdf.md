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
xcodebuild -project Konjugieren.xcodeproj -scheme Konjugieren -destination 'platform=iOS Simulator,name=iPhone 17' -parallel-testing-enabled NO test -only-testing:KonjugierenTests/VerbExportTests/exportAllVerbsAsJSON()
```

## Generate the PDF

```bash
python3 scripts/generate_verb_pdf.py
```

Output: `/tmp/konjugieren-verbs.pdf`

Use `--count N` to limit to the first N verbs for testing (e.g., `--count 5`).

## Structure

- **Page 1**: Fraktur title page — "Konjugieren" / "N German Verbs" / "Josh Adams and Claude Code"
- **Pages 2–~8**: Three-column verb index with page numbers
- **Remaining pages**: One verb per page (some overflow to two pages) with conjugations, etymology, and example sentences
