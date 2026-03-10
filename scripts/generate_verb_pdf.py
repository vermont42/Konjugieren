#!/usr/bin/env python3
"""Generate a PDF reference of German verb conjugations from exported JSON."""

import argparse
import json
import re
from pathlib import Path

from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.units import inch
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import (
    SimpleDocTemplate,
    Paragraph,
    Spacer,
    HRFlowable,
    KeepTogether,
    PageBreak,
    NextPageTemplate,
    PageTemplate,
    Frame,
    BaseDocTemplate,
)

# --- Font Registration ---

FONT_DIR = Path("/System/Library/Fonts/Supplemental")
pdfmetrics.registerFont(TTFont("TNR", str(FONT_DIR / "Times New Roman.ttf")))
pdfmetrics.registerFont(TTFont("TNR-Bold", str(FONT_DIR / "Times New Roman Bold.ttf")))
pdfmetrics.registerFont(TTFont("TNR-Italic", str(FONT_DIR / "Times New Roman Italic.ttf")))
pdfmetrics.registerFont(
    TTFont("TNR-BoldItalic", str(FONT_DIR / "Times New Roman Bold Italic.ttf"))
)
pdfmetrics.registerFontFamily(
    "TNR",
    normal="TNR",
    bold="TNR-Bold",
    italic="TNR-Italic",
    boldItalic="TNR-BoldItalic",
)

# Fraktur font for title page
FRAKTUR_PATH = Path("/tmp/UnifrakturMaguntia-Book.ttf")
if FRAKTUR_PATH.exists():
    pdfmetrics.registerFont(TTFont("Fraktur", str(FRAKTUR_PATH)))

# --- Colors ---

COLOR_BLACK = "#000000"
COLOR_DARK_RED = "#BF0000"
COLOR_GRAY = "#888888"

# --- Styles ---

STYLE_INFINITIV = ParagraphStyle(
    "infinitiv",
    fontName="TNR-Bold",
    fontSize=22,
    leading=26,
    textColor=COLOR_BLACK,
)
STYLE_TRANSLATION = ParagraphStyle(
    "translation",
    fontName="TNR",
    fontSize=14,
    leading=18,
    textColor=COLOR_BLACK,
    spaceBefore=2,
)
STYLE_METADATA = ParagraphStyle(
    "metadata",
    fontName="TNR",
    fontSize=10,
    leading=13,
    textColor=COLOR_BLACK,
    spaceBefore=2,
)
STYLE_CONJUGATION = ParagraphStyle(
    "conjugation",
    fontName="TNR",
    fontSize=10,
    leading=13,
    textColor=COLOR_BLACK,
    spaceBefore=1,
)
STYLE_HEADING = ParagraphStyle(
    "heading",
    fontName="TNR-Bold",
    fontSize=13,
    leading=16,
    textColor=COLOR_BLACK,
    spaceBefore=6,
    spaceAfter=3,
)
STYLE_ETYMOLOGY = ParagraphStyle(
    "etymology",
    fontName="TNR",
    fontSize=10,
    leading=13,
    textColor=COLOR_BLACK,
    alignment=4,  # justified
)
STYLE_SENTENCE = ParagraphStyle(
    "sentence",
    fontName="TNR-Italic",
    fontSize=10,
    leading=13,
    textColor=COLOR_BLACK,
)
STYLE_SOURCE = ParagraphStyle(
    "source",
    fontName="TNR",
    fontSize=9,
    leading=12,
    textColor=COLOR_GRAY,
)

# --- Conjugationgroup display order and labels ---

CONJUGATIONGROUP_ORDER = [
    ("präsensIndicativ", "Präsens Indikativ"),
    ("präteritumIndicativ", "Präteritum Indikativ"),
    ("präsensKonjunktivI", "Präsens Konjunktiv I"),
    ("präteritumKonjunktivII", "Präteritum Konjunktiv II"),
    ("imperativ", "Imperativ"),
    ("perfektIndikativ", "Perfekt Indikativ"),
    ("perfektKonjunktivI", "Perfekt Konjunktiv I"),
    ("plusquamperfektIndikativ", "Plusquamperfekt Indikativ"),
    ("plusquamperfektKonjunktivII", "Plusquamperfekt Konjunktiv II"),
    ("futurIndikativ", "Futur Indikativ"),
    ("futurKonjunktivI", "Futur Konjunktiv I"),
    ("futurKonjunktivII", "Futur Konjunktiv II"),
]


def escape_xml(text: str) -> str:
    """Escape XML special characters."""
    return text.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")


def is_formal_sie_start(chars: list[str], index: int) -> bool:
    """Check if position is the start of formal 'Sie'."""
    if index + 2 >= len(chars):
        return False
    if chars[index] != "S" or chars[index + 1] != "i" or chars[index + 2] != "e":
        return False
    if index > 0 and chars[index - 1] != " ":
        return False
    if index + 3 < len(chars) and chars[index + 3].isalpha():
        return False
    return True


def mixed_case_to_xml(text: str) -> str:
    """Convert mixed-case string to colored XML for reportlab.

    Lowercase/non-letter → black (output lowercased)
    Uppercase → dark red (output lowercased)
    Special: 'Sie' at word boundary → always black, preserve case
    """
    chars = list(text)
    result = []
    current_regular = []
    current_irregular = []
    in_irregular = False

    def flush_regular():
        if current_regular:
            result.append(
                f'<font color="{COLOR_BLACK}">{"".join(current_regular)}</font>'
            )
            current_regular.clear()

    def flush_irregular():
        if current_irregular:
            result.append(
                f'<font color="{COLOR_DARK_RED}">{"".join(current_irregular)}</font>'
            )
            current_irregular.clear()

    for i, char in enumerate(chars):
        part_of_sie = (
            is_formal_sie_start(chars, i)
            or (i > 0 and is_formal_sie_start(chars, i - 1))
            or (i > 1 and is_formal_sie_start(chars, i - 2))
        )
        is_regular = char.islower() or not char.isalpha() or part_of_sie
        canonical = char if part_of_sie else char.lower()
        # Escape XML entities
        canonical = escape_xml(canonical)

        if is_regular:
            if in_irregular:
                flush_irregular()
                in_irregular = False
            current_regular.append(canonical)
        else:
            if not in_irregular:
                flush_regular()
                in_irregular = True
            current_irregular.append(canonical)

    flush_regular()
    flush_irregular()

    return "".join(result)


def parse_etymology_markup(text: str) -> str:
    """Convert etymology markup to reportlab XML.

    ~word~ → <i>word</i>
    *~word~ → *<i>word</i>  (reconstructed forms)
    -- → em-dash
    $conjugation$ → mixed-case coloring
    %url% → plain text (strip markers)
    Unicode subscripts → <sub>N</sub>
    """
    # Escape XML first
    text = escape_xml(text)

    # $conjugation$ → mixed-case coloring
    def replace_ablaut(m):
        return mixed_case_to_xml(m.group(1))

    text = re.sub(r"\$([^$]+)\$", replace_ablaut, text)

    # *~word~ → *<i>word</i> (must come before ~word~ replacement)
    text = re.sub(r"\*~([^~]+)~", r"*<i>\1</i>", text)

    # ~word~ → <i>word</i>
    text = re.sub(r"~([^~]+)~", r"<i>\1</i>", text)

    # -- → em-dash
    text = text.replace("--", "\u2014")

    # %url% → plain text
    text = re.sub(r"%([^%]+)%", r"\1", text)

    # Unicode subscripts
    subscript_map = {"₁": "<sub>1</sub>", "₂": "<sub>2</sub>", "₃": "<sub>3</sub>"}
    for uni, xml in subscript_map.items():
        text = text.replace(uni, xml)

    # Newlines → <br/>
    text = text.replace("\n", "<br/>")

    return text


def format_imperativ(rows: list[dict]) -> str:
    """Format imperativ conjugations with optional pronoun prefixes."""
    parts = []
    for row in rows:
        form_xml = mixed_case_to_xml(row["form"])
        if row.get("pronoun"):
            parts.append(f'<font color="{COLOR_BLACK}">({row["pronoun"]})</font> {form_xml}')
        else:
            parts.append(form_xml)
    return f'<font color="{COLOR_BLACK}">, </font>'.join(parts)


def format_conjugation_line(forms: list[str]) -> str:
    """Format a list of conjugation forms as comma-separated colored XML."""
    xml_parts = [mixed_case_to_xml(f) for f in forms]
    return f'<font color="{COLOR_BLACK}">, </font>'.join(xml_parts)


def build_verb_flowables(verb: dict) -> list:
    """Build reportlab flowables for a single verb."""
    elements = []

    # Header: infinitive
    elements.append(Paragraph(escape_xml(verb["infinitiv"]), STYLE_INFINITIV))

    # Translation
    elements.append(Paragraph(escape_xml(verb["translation"]), STYLE_TRANSLATION))

    # Metadata line
    family_display = verb["family"].capitalize()
    if family_display == "Ieren":
        family_display = "-ieren"
    meta_parts = [family_display, verb["auxiliary"]]
    meta_parts.append(f'#{verb["frequency"]}')
    if verb["prefix"] != "none":
        prefix_label = verb["prefix"]
        if verb.get("prefixValue"):
            prefix_label += f': {verb["prefixValue"]}'
        meta_parts.append(prefix_label)
    if verb.get("ablautGroup"):
        meta_parts.append(verb["ablautGroup"])
    elements.append(
        Paragraph(escape_xml(" \u00b7 ".join(meta_parts)), STYLE_METADATA)
    )

    # Thin rule
    elements.append(Spacer(1, 4))
    elements.append(HRFlowable(width="100%", thickness=0.5, color=COLOR_BLACK))
    elements.append(Spacer(1, 4))

    # Partizipien
    conj = verb["conjugations"]
    perfekt_pp = mixed_case_to_xml(conj["perfektpartizip"])
    präsens_pp = mixed_case_to_xml(conj["präsenspartizip"])
    partizip_xml = (
        f'<b>Perfektpartizip / Pr\u00e4senspartizip:</b> '
        f'{perfekt_pp}'
        f'<font color="{COLOR_BLACK}"> / </font>'
        f'{präsens_pp}'
    )
    elements.append(Paragraph(partizip_xml, STYLE_CONJUGATION))

    # Each conjugationgroup
    for key, label in CONJUGATIONGROUP_ORDER:
        data = conj.get(key)
        if data is None:
            continue

        if key == "imperativ":
            forms_xml = format_imperativ(data)
        else:
            forms_xml = format_conjugation_line(data)

        line_xml = f"<b>{escape_xml(label)}:</b> {forms_xml}"
        elements.append(Paragraph(line_xml, STYLE_CONJUGATION))

    # Etymology
    etymology = verb.get("etymology")
    if etymology:
        elements.append(Spacer(1, 4))
        elements.append(HRFlowable(width="100%", thickness=0.5, color=COLOR_BLACK))
        elements.append(Paragraph("Etymology", STYLE_HEADING))
        etym_xml = parse_etymology_markup(etymology)
        elements.append(Paragraph(etym_xml, STYLE_ETYMOLOGY))

    # Example sentences
    ex = verb.get("exampleSentences")
    if ex:
        elements.append(Paragraph("Example Sentence", STYLE_HEADING))
        elements.append(
            Paragraph(escape_xml(ex["de"]["sentence"]), STYLE_SENTENCE)
        )
        elements.append(
            Paragraph(escape_xml(ex["en"]["sentence"]), STYLE_SENTENCE)
        )
        source_parts = []
        if ex["de"].get("source"):
            source_parts.append(ex["de"]["source"])
        if ex["en"].get("source"):
            source_parts.append(ex["en"]["source"])
        if source_parts:
            elements.append(
                Paragraph(escape_xml(" / ".join(source_parts)), STYLE_SOURCE)
            )

    return elements


def add_page_number(canvas, doc):
    """Draw centered page number at bottom of each page."""
    canvas.saveState()
    canvas.setFont("TNR", 10)
    page_num = str(doc.page)
    canvas.drawCentredString(letter[0] / 2, 0.5 * inch, page_num)
    canvas.restoreState()


def build_verb_flowables_grouped(verb: dict) -> list:
    """Build flowables for a verb, using KeepTogether for the conjugation block.

    The header + conjugations are wrapped in KeepTogether so they stay on one
    page. If the etymology/example push beyond the page, they flow naturally
    onto page two.
    """
    all_flowables = build_verb_flowables(verb)

    # Find the split point: after the last conjugation line, before Etymology
    # The etymology section starts with a Spacer after the conjugation lines.
    # We look for the second HRFlowable (the one before Etymology).
    hr_indices = [i for i, f in enumerate(all_flowables) if isinstance(f, HRFlowable)]

    if len(hr_indices) >= 2:
        # Split before the second HR (which precedes Etymology)
        split = hr_indices[1]
        conjugation_block = all_flowables[:split]
        remainder = all_flowables[split:]
        return [KeepTogether(conjugation_block)] + remainder
    else:
        # No etymology — keep everything together
        return [KeepTogether(all_flowables)]


def build_title_page(verb_count: int) -> list:
    """Build flowables for the Fraktur title page."""
    fraktur_font = "Fraktur" if FRAKTUR_PATH.exists() else "TNR-Bold"
    elements = []
    # Vertical centering: push title down ~3.5 inches
    elements.append(Spacer(1, 3.0 * inch))
    title_style = ParagraphStyle(
        "title",
        fontName=fraktur_font,
        fontSize=60,
        leading=72,
        alignment=1,  # center
        textColor=COLOR_BLACK,
    )
    elements.append(Paragraph("Konjugieren", title_style))
    elements.append(Spacer(1, 0.3 * inch))
    subtitle_style = ParagraphStyle(
        "subtitle",
        fontName=fraktur_font,
        fontSize=24,
        leading=30,
        alignment=1,
        textColor=COLOR_BLACK,
    )
    elements.append(Paragraph(f"{verb_count} German Verbs", subtitle_style))
    # Push author line to the bottom
    elements.append(Spacer(1, 3.0 * inch))
    author_style = ParagraphStyle(
        "author",
        fontName=fraktur_font,
        fontSize=24,
        leading=30,
        alignment=1,
        textColor=COLOR_BLACK,
    )
    elements.append(Paragraph("Josh Adams and Claude Code", author_style))
    elements.append(PageBreak())
    return elements


def build_index_pages(verbs: list, index_start_page: int) -> list:
    """Build a multi-column index of verbs with page numbers.

    Each verb gets one page (plus possible overflow), so we do a two-pass build:
    first pass without index to learn actual page numbers, then rebuild with index.
    We use a simpler approach: since the index itself takes pages, we estimate
    the index page count, then compute verb page numbers accordingly.
    """
    # We'll use a 3-column layout via a single paragraph with tab-like spacing
    elements = []
    index_heading = ParagraphStyle(
        "indexHeading",
        fontName="TNR-Bold",
        fontSize=22,
        leading=26,
        alignment=1,
        textColor=COLOR_BLACK,
        spaceAfter=12,
    )
    elements.append(Paragraph("Index", index_heading))

    index_entry = ParagraphStyle(
        "indexEntry",
        fontName="TNR",
        fontSize=9,
        leading=11.5,
        textColor=COLOR_BLACK,
    )

    # Build entries as a simple list: verb .... page
    # Page numbers will be filled in by the caller after a two-pass build
    entries = []
    for verb in verbs:
        infinitiv = escape_xml(verb["infinitiv"])
        entries.append((infinitiv, verb.get("_page_number", 0)))

    # Arrange in 3 columns using a table-like approach with Paragraphs
    col_count = 3
    col_width = 2.1 * inch
    rows_per_col = (len(entries) + col_count - 1) // col_count

    from reportlab.platypus import Table, TableStyle
    from reportlab.lib import colors

    # Build column data
    table_data = []
    for row_idx in range(rows_per_col):
        row = []
        for col_idx in range(col_count):
            entry_idx = col_idx * rows_per_col + row_idx
            if entry_idx < len(entries):
                name, page = entries[entry_idx]
                cell = Paragraph(
                    f'{name} <font color="{COLOR_GRAY}">{"." * 3} {page}</font>',
                    index_entry,
                )
                row.append(cell)
            else:
                row.append("")
        table_data.append(row)

    table = Table(table_data, colWidths=[col_width] * col_count)
    table.setStyle(TableStyle([
        ("VALIGN", (0, 0), (-1, -1), "TOP"),
        ("LEFTPADDING", (0, 0), (-1, -1), 2),
        ("RIGHTPADDING", (0, 0), (-1, -1), 2),
        ("TOPPADDING", (0, 0), (-1, -1), 0),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 0),
    ]))
    elements.append(table)
    elements.append(PageBreak())
    return elements


def generate_pdf(
    input_path: str = "/tmp/konjugieren-export.json",
    output_path: str = "/tmp/konjugieren-verbs.pdf",
    count: int = 0,
):
    """Read exported JSON and generate the PDF."""
    with open(input_path, "r", encoding="utf-8") as f:
        verbs = json.load(f)

    if count > 0:
        verbs = verbs[:count]

    verb_count = len(verbs)
    print(f"Generating PDF for {verb_count} verb(s) from {input_path}")

    doc = SimpleDocTemplate(
        output_path,
        pagesize=letter,
        leftMargin=0.75 * inch,
        rightMargin=0.75 * inch,
        topMargin=0.8 * inch,
        bottomMargin=0.8 * inch,
    )

    # Two-pass approach:
    # Pass 1: build without index to measure how many pages the index takes,
    #          and learn each verb's starting page.
    # Pass 2: rebuild with correct page numbers in the index.

    # First, estimate index page count. ~50 entries per column, 3 columns = ~150 per page.
    entries_per_page = 150
    estimated_index_pages = max(1, (verb_count + entries_per_page - 1) // entries_per_page)
    # Title page = page 1, index starts at page 2
    # Verbs start after title + index pages
    verb_start_page = 1 + estimated_index_pages + 1  # +1 for title page

    # Pass 1: build verb content to learn actual page numbers per verb
    # We use a tracking doc template to record page numbers
    class PageTracker(SimpleDocTemplate):
        def __init__(self, *args, **kwargs):
            super().__init__(*args, **kwargs)
            self.verb_pages = {}
            self._current_verb_idx = -1

        def afterPage(self):
            super().afterPage()

    # For simplicity, assign page numbers based on the assumption that each
    # verb starts on a new page (due to PageBreak between verbs).
    # We'll do a single-pass build and track pages via a custom canvas callback.
    verb_page_map = {}

    class VerbPageTracker:
        def __init__(self):
            self.verb_indices = []  # (flowable_index, verb_index) markers
            self.page_numbers = {}  # verb_index -> page_number

    tracker = VerbPageTracker()

    from reportlab.platypus import Flowable

    class VerbMarker(Flowable):
        """Zero-size flowable that records which page a verb starts on."""
        width = 0
        height = 0

        def __init__(self, verb_idx):
            super().__init__()
            self.verb_idx = verb_idx

        def draw(self):
            tracker.page_numbers[self.verb_idx] = self.canv.getPageNumber()

    # Build elements with markers
    elements = []
    # Title page (page 1, no page number)
    elements.extend(build_title_page(verb_count))
    # Placeholder index (will be rebuilt in pass 2)
    # Skip index in pass 1 — just add blank pages as spacer
    for _ in range(estimated_index_pages):
        elements.append(Spacer(1, 1))
        elements.append(PageBreak())

    for i, verb in enumerate(verbs):
        elements.append(VerbMarker(i))
        elements.extend(build_verb_flowables_grouped(verb))
        if i < verb_count - 1:
            elements.append(PageBreak())

    def no_page_number(canvas, doc):
        pass

    def add_page_number_offset(canvas, doc):
        """Draw page number, not counting the title page."""
        add_page_number(canvas, doc)

    # Pass 1 build (to /dev/null-like temp file)
    import tempfile
    with tempfile.NamedTemporaryFile(suffix=".pdf", delete=False) as tmp:
        tmp_path = tmp.name

    doc_pass1 = SimpleDocTemplate(
        tmp_path,
        pagesize=letter,
        leftMargin=0.75 * inch,
        rightMargin=0.75 * inch,
        topMargin=0.8 * inch,
        bottomMargin=0.8 * inch,
    )
    doc_pass1.build(elements, onFirstPage=no_page_number, onLaterPages=add_page_number)
    Path(tmp_path).unlink(missing_ok=True)

    # Now tracker.page_numbers has {verb_idx: actual_page_number}
    # Assign page numbers to verbs
    for i, verb in enumerate(verbs):
        verb["_page_number"] = tracker.page_numbers.get(i, 0)

    # Pass 2: rebuild with correct index
    elements2 = []
    elements2.extend(build_title_page(verb_count))
    elements2.extend(build_index_pages(verbs, 2))
    for i, verb in enumerate(verbs):
        elements2.extend(build_verb_flowables_grouped(verb))
        if i < verb_count - 1:
            elements2.append(PageBreak())

    doc2 = SimpleDocTemplate(
        output_path,
        pagesize=letter,
        leftMargin=0.75 * inch,
        rightMargin=0.75 * inch,
        topMargin=0.8 * inch,
        bottomMargin=0.8 * inch,
    )
    doc2.build(elements2, onFirstPage=no_page_number, onLaterPages=add_page_number)
    # Clean up temp keys
    for verb in verbs:
        verb.pop("_page_number", None)

    print(f"Generated PDF: {output_path} ({verb_count} verb(s), {doc2.page} page(s))")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate verb conjugation PDF")
    parser.add_argument("input", nargs="?", default="/tmp/konjugieren-export.json")
    parser.add_argument("output", nargs="?", default="/tmp/konjugieren-verbs.pdf")
    parser.add_argument("--count", type=int, default=0, help="Limit to first N verbs (0 = all)")
    args = parser.parse_args()
    generate_pdf(args.input, args.output, args.count)
