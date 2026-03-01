---
name: export-pdf
allowed-tools: Bash(python3:*), Bash(ls:*), Bash(wc:*), Bash(open:*)
description: Export a Markdown file as a formatted PDF, converting Konjugieren rich-text markup to real typography
argument-hint: [path/to/file.md]
---

# Export Markdown to PDF

## Task

Convert a Markdown file to a professionally typeset PDF, handling Konjugieren's custom rich-text markup.

**Input file:** $ARGUMENTS (default: `docs/etymologies.md` if no argument provided)

## Markup Conversion

Konjugieren uses custom markup that must be converted to real PDF formatting:

| Markup | Meaning | PDF rendering |
|--------|---------|---------------|
| `~word~` | Emphasis | Italic |
| `*~word~` | Reconstructed form | *Italic with leading asterisk |
| `--` or ` -- ` | Em dash | — |

Do NOT process these (they are for other contexts): `$...$` (ablaut), backtick (headings), `%...%` (URLs).

## Font Requirements — CRITICAL

Reportlab's built-in PostScript fonts (Times-Roman, Helvetica, Courier) only cover Latin-1 (~250 glyphs). This project's etymologies contain subscript digits (₁₂₃), IPA characters (ʰ ʷ), and combining diacritics (ǵ ḱ ē ō þ ŋ) that WILL render as black squares with built-in fonts.

**Always register TrueType fonts:**

```python
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.pdfbase.pdfmetrics import registerFontFamily

pdfmetrics.registerFont(TTFont('TNR', '/System/Library/Fonts/Supplemental/Times New Roman.ttf'))
pdfmetrics.registerFont(TTFont('TNR-Bold', '/System/Library/Fonts/Supplemental/Times New Roman Bold.ttf'))
pdfmetrics.registerFont(TTFont('TNR-Italic', '/System/Library/Fonts/Supplemental/Times New Roman Italic.ttf'))
pdfmetrics.registerFont(TTFont('TNR-BoldItalic', '/System/Library/Fonts/Supplemental/Times New Roman Bold Italic.ttf'))
registerFontFamily('TNR', normal='TNR', bold='TNR-Bold', italic='TNR-Italic', boldItalic='TNR-BoldItalic')
```

**Belt-and-suspenders:** Even with TNR TTF, convert Unicode subscript digits to `<sub>` tags since Times New Roman lacks ₁₂₃:
```python
text = text.replace('₁', '<sub>1</sub>')
text = text.replace('₂', '<sub>2</sub>')
text = text.replace('₃', '<sub>3</sub>')
```

## Page Layout

- **Page size:** US Letter
- **Margins:** 0.9" left/right, 0.8" top/bottom
- **Body font:** TNR (registered TTF), 9.5pt, justified, 13pt leading
- **Headings:** TNR-Bold, 13pt, color #2c3e50
- **Bullet indent:** 18pt left, 6pt bullet indent

## Document Structure

1. **Title page** with document name, subtitle, and metadata
2. **Entries** parsed from `### heading` markers:
   - `### verb` → bold heading
   - Body paragraphs → justified text
   - `- item` → bulleted list
3. Use `KeepTogether` for short entries (≤4 flowables) to prevent orphaned headings
4. For longer entries, at minimum keep heading with first paragraph together

## XML Escaping Order

When converting markup to reportlab's XML-based Paragraph format, escape in this order:
1. `&` → `&amp;` (FIRST — before any tags are inserted)
2. `<` → `&lt;`
3. `>` → `&gt;`
4. Then insert `<i>`, `<sub>`, etc. tags

## Output

- Write the PDF to the same directory as the source file, with `.pdf` extension
- Report: entry count, page count, file size
- Offer to open with `open <path>`

## Error Handling

- If reportlab is not installed: `pip3 install reportlab`
- If the source file does not exist: inform the user
- If font files are missing: fall back to `/Library/Fonts/Arial Unicode.ttf` (12/12 glyph coverage, sans-serif)
