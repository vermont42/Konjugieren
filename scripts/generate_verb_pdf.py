#!/usr/bin/env python3
"""Generate a PDF reference of German verb conjugations from exported JSON."""

import argparse
import json
import re
import tempfile
from pathlib import Path

from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.units import inch
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import (
    BaseDocTemplate,
    Flowable,
    Frame,
    FrameBreak,
    HRFlowable,
    KeepTogether,
    NextPageTemplate,
    PageBreak,
    PageTemplate,
    Paragraph,
    Spacer,
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
    text = text.replace("--", "—")

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
        Paragraph(escape_xml(" · ".join(meta_parts)), STYLE_METADATA)
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
        f'<b>Perfektpartizip / Präsenspartizip:</b> '
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
        if ex["en"].get("source") and ex["en"]["source"] != ex["de"].get("source"):
            source_parts.append(ex["en"]["source"])
        if source_parts:
            elements.append(
                Paragraph(escape_xml(" / ".join(source_parts)), STYLE_SOURCE)
            )

    return elements


def build_verb_flowables_grouped(verb: dict) -> list:
    """Build flowables for a verb, using KeepTogether for the conjugation block.

    The header + conjugations are wrapped in KeepTogether so they stay on one
    page. If the etymology/example push beyond the page, they flow naturally
    onto page two.
    """
    all_flowables = build_verb_flowables(verb)

    # Find the split point: after the last conjugation line, before Etymology.
    # The etymology section starts with a Spacer after the conjugation lines.
    # We look for the second HRFlowable (the one before Etymology).
    hr_indices = [i for i, f in enumerate(all_flowables) if isinstance(f, HRFlowable)]

    if len(hr_indices) >= 2:
        split = hr_indices[1]
        conjugation_block = all_flowables[:split]
        remainder = all_flowables[split:]
        return [KeepTogether(conjugation_block)] + remainder
    else:
        return [KeepTogether(all_flowables)]


def build_title_page(verb_count: int) -> list:
    """Build flowables for the Fraktur title page.

    Note: no trailing PageBreak. The caller is responsible for the transition
    to the next page template via NextPageTemplate + PageBreak.
    """
    fraktur_font = "Fraktur" if FRAKTUR_PATH.exists() else "TNR-Bold"
    elements = []
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
    elements.append(Paragraph("Nearly 1,000 German Verbs", subtitle_style))
    elements.append(Spacer(1, 3.0 * inch))
    author_style = ParagraphStyle(
        "author",
        fontName=fraktur_font,
        fontSize=24,
        leading=30,
        alignment=1,
        textColor=COLOR_BLACK,
    )
    elements.append(Paragraph("Josh Adams", author_style))
    return elements


def build_index_flowables(verbs: list) -> list:
    """Build flowables for the index.

    The "Index" heading goes into the heading frame at the top of the first
    index page. FrameBreak then moves layout into the first column frame.
    Entries flow column-by-column (col0 → col1 → col2 → next page), filling
    each page before moving on.
    """
    index_heading_style = ParagraphStyle(
        "indexHeading",
        fontName="TNR-Bold",
        fontSize=22,
        leading=26,
        alignment=1,
        textColor=COLOR_BLACK,
        spaceAfter=12,
    )
    index_entry_style = ParagraphStyle(
        "indexEntry",
        fontName="TNR",
        fontSize=9,
        leading=11.5,
        textColor=COLOR_BLACK,
    )

    elements = []
    elements.append(Paragraph("Index", index_heading_style))
    elements.append(FrameBreak())

    for verb in verbs:
        name = escape_xml(verb["infinitiv"])
        page = verb.get("_page_number", 0)
        elements.append(
            Paragraph(
                f'{name} <font color="{COLOR_GRAY}">... {page}</font>',
                index_entry_style,
            )
        )

    return elements


def add_page_number(canvas, doc):
    """Draw centered page number at bottom of each page."""
    canvas.saveState()
    canvas.setFont("TNR", 10)
    page_num = str(doc.page)
    canvas.drawCentredString(letter[0] / 2, 0.5 * inch, page_num)
    canvas.restoreState()


def no_page_number(canvas, doc):
    """No-op page-decoration callback for the title page."""
    pass


class VerbPageTracker:
    """Captures the page on which each verb starts during pass 1."""

    def __init__(self):
        self.page_numbers: dict[int, int] = {}


class VerbMarker(Flowable):
    """Zero-size flowable that records the page on which it is drawn.

    Placed immediately before a verb's flowables, it captures the verb's
    starting page during pass 1 so the index in pass 2 can reference it.
    """

    width = 0
    height = 0

    def __init__(self, verb_idx: int, tracker: VerbPageTracker):
        super().__init__()
        self.verb_idx = verb_idx
        self.tracker = tracker

    def draw(self):
        self.tracker.page_numbers[self.verb_idx] = self.canv.getPageNumber()


def make_doc(output_path: str) -> BaseDocTemplate:
    """Build a BaseDocTemplate with title, index, and verb page templates.

    Templates:
      title       — single frame, no page number (page 1 only)
      indexFirst  — heading frame on top + 3 column frames below
                    (autoNextPageTemplate=indexCont)
      indexCont   — 3 column frames spanning full content height
      verb        — single frame, with page number
    """
    doc = BaseDocTemplate(
        output_path,
        pagesize=letter,
        leftMargin=0.75 * inch,
        rightMargin=0.75 * inch,
        topMargin=0.8 * inch,
        bottomMargin=0.8 * inch,
    )

    content_width = doc.width
    content_height = doc.height

    def make_single_frame(frame_id: str) -> Frame:
        return Frame(
            doc.leftMargin,
            doc.bottomMargin,
            content_width,
            content_height,
            id=frame_id,
            leftPadding=0,
            rightPadding=0,
            topPadding=0,
            bottomPadding=0,
        )

    col_count = 3
    col_gap = 0.15 * inch
    col_width = (content_width - col_gap * (col_count - 1)) / col_count

    def make_column_frames(y_bottom: float, height: float, suffix: str) -> list[Frame]:
        frames = []
        for i in range(col_count):
            x = doc.leftMargin + i * (col_width + col_gap)
            frames.append(
                Frame(
                    x,
                    y_bottom,
                    col_width,
                    height,
                    id=f"col{i}{suffix}",
                    leftPadding=2,
                    rightPadding=2,
                    topPadding=0,
                    bottomPadding=0,
                )
            )
        return frames

    heading_height = 0.7 * inch
    index_first_frames = [
        Frame(
            doc.leftMargin,
            doc.bottomMargin + content_height - heading_height,
            content_width,
            heading_height,
            id="indexHeading",
            leftPadding=0,
            rightPadding=0,
            topPadding=0,
            bottomPadding=0,
        ),
    ] + make_column_frames(
        doc.bottomMargin, content_height - heading_height, "_first"
    )

    index_cont_frames = make_column_frames(doc.bottomMargin, content_height, "_cont")

    doc.addPageTemplates(
        [
            PageTemplate(
                id="title", frames=[make_single_frame("titleMain")], onPage=no_page_number
            ),
            PageTemplate(
                id="indexFirst",
                frames=index_first_frames,
                onPage=add_page_number,
                autoNextPageTemplate="indexCont",
            ),
            PageTemplate(
                id="indexCont", frames=index_cont_frames, onPage=add_page_number
            ),
            PageTemplate(
                id="verb", frames=[make_single_frame("verbMain")], onPage=add_page_number
            ),
        ]
    )
    return doc


def build_all_flowables(verbs: list, tracker: VerbPageTracker | None = None) -> list:
    """Build the complete flowable sequence: title, index, then per-verb pages.

    If ``tracker`` is provided, a ``VerbMarker`` is inserted before each verb's
    flowables to capture its starting page number.
    """
    verb_count = len(verbs)
    elements: list = []

    elements.extend(build_title_page(verb_count))

    elements.append(NextPageTemplate("indexFirst"))
    elements.append(PageBreak())
    elements.extend(build_index_flowables(verbs))

    elements.append(NextPageTemplate("verb"))
    elements.append(PageBreak())

    for i, verb in enumerate(verbs):
        if tracker is not None:
            elements.append(VerbMarker(i, tracker))
        elements.extend(build_verb_flowables_grouped(verb))
        if i < verb_count - 1:
            elements.append(PageBreak())

    return elements


def generate_pdf(
    input_path: str = "/tmp/konjugieren-export.json",
    output_path: str = "/tmp/konjugieren-verbs.pdf",
    count: int = 0,
):
    """Read exported JSON and generate the PDF.

    Two-pass build:
      Pass 1: real index entries with placeholder page numbers (0); a
              ``VerbPageTracker`` records each verb's starting page. Because
              entry text fits on one line regardless of digit count, pagination
              in pass 1 matches pass 2 exactly.
      Pass 2: real page numbers from pass 1 substituted into the index.
    """
    with open(input_path, "r", encoding="utf-8") as f:
        verbs = json.load(f)

    if count > 0:
        verbs = verbs[:count]

    verb_count = len(verbs)
    print(f"Generating PDF for {verb_count} verb(s) from {input_path}")

    for verb in verbs:
        verb["_page_number"] = 0

    tracker = VerbPageTracker()
    with tempfile.NamedTemporaryFile(suffix=".pdf", delete=False) as tmp:
        tmp_path = tmp.name
    pass1_doc = make_doc(tmp_path)
    pass1_doc.build(build_all_flowables(verbs, tracker=tracker))
    Path(tmp_path).unlink(missing_ok=True)

    for i, verb in enumerate(verbs):
        verb["_page_number"] = tracker.page_numbers.get(i, 0)

    final_doc = make_doc(output_path)
    final_doc.build(build_all_flowables(verbs))

    for verb in verbs:
        verb.pop("_page_number", None)

    print(f"Generated PDF: {output_path} ({verb_count} verb(s), {final_doc.page} page(s))")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate verb conjugation PDF")
    parser.add_argument("input", nargs="?", default="/tmp/konjugieren-export.json")
    parser.add_argument("output", nargs="?", default="/tmp/konjugieren-verbs.pdf")
    parser.add_argument("--count", type=int, default=0, help="Limit to first N verbs (0 = all)")
    args = parser.parse_args()
    generate_pdf(args.input, args.output, args.count)
