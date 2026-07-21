#!/usr/bin/env python3
"""Build an inverted verb→occurrences index over the German example corpus.

This is the cheap, deterministic *retrieval* half of the etymology-and-example pipeline
(`prompts/uses_etymologies.md` § Phase 2). It locates candidate sentences for every verb so that
the Phase 4 subagents only do the expensive *select + translate* judgment on a handful of
pre-found sentences, instead of each one re-reading a ~6.5 MB corpus.

Ported from Conjugar's `corpus/working/build_corpus_index.py`, keeping its constants
(MAX_OCCURRENCES, PER_DOC_CAP), its tier priority, and its round-robin merge with a per-verb
rotating lead work. Four things had to change for German; each is marked GERMAN: below.

Conjugar's `SNIPPET_WIDTH = 200` did not survive. It sized a *preview*, and Phase 4 needs a
*quotation*; see MAX_QUOTE_CHARS below for why that distinction cost about 45% of a mining shard.

Inputs
  - corpus/working/forms.json : { "<surface form>": [{verb, contiguous, particle?}, …] }, written
    by the `CorpusFormsDumpTests` Swift harness driving the app's own Conjugator over all verbs ×
    conjugationgroups × persons. Exact whole-token matching against this map handles irregular
    stems (hing/hängte) and avoids substring false positives.
  - corpus/{modern,government,government2,technology}/*.txt

Output
  - corpus/working/corpus_index.json : { "<infinitive>": [ {doc, line, token, text, …}, … ] }
  - a coverage + balance report to stdout, scoped to the pipeline's target verbs.

Run: python3 corpus/working/build_corpus_index.py

GERMAN 1 — Exclude the English translations. `corpus/modern/` ships each work in German *and*
English (`kafka-prozess-en.txt`). Ten common English words are also German verb forms in
forms.json — war→sein, will→wollen, hat→haben, sang→singen, band→binden, sank→sinken,
fall→fallen, rang→ringen, fang→fangen, sing→singen — so indexing the translations would attest
German verbs from English prose. Any file ending `-en.txt` is skipped.

GERMAN 2 — Index sentences, not physical lines. Conjugar could scan line-at-a-time because
Spanish never strands a particle. German splits separable prefixes in main clauses ("er fängt neu
an"), so the particle must be sought in the same *sentence* — and these sources are hard-wrapped
(Kafka ~68 chars/line, the government PDFs ~43), which puts a typical German sentence across two
to four physical lines. So each document is reflowed into paragraphs, split into sentences, and
matched sentence-wise. Physical line numbers are carried through the reflow, so the reported
`line` is the line holding the matched verb and `doc:line` opens on the attestation.

GERMAN 3 — Score capitalized mid-sentence tokens as nominal. Conjugar's worst recurring bug was
noun homographs draining candidate slots (*cocina* for *cocinar*). German capitalizes nouns, so
`das Ringen` is mechanically distinguishable from `ringen`. A token that is capitalized and not
sentence-initial is dropped. Nominalized infinitives are extremely common in exactly the
administrative German that makes up the government tier, so this is load-bearing, not a nicety.

GERMAN 4 — Split-form candidates, ranked below contiguous ones. A form flagged `contiguous:false`
in forms.json (the synthesized bare stem of a separable verb) is accepted only when its `particle`
also occurs as a later whole token in the same sentence. Because particles are homographs of very
common prepositions (`nach`, `an`, `vor`, `zu`), these are inherently weaker evidence: they sort
after every contiguous hit, and a split hit whose particle sits at a clause boundary — where a
stranded particle actually belongs — sorts ahead of one where it does not. The subagent is told to
verify. This subsumes the "split-form rescue" pass the phase spec contemplated: a verb with good
contiguous hits never sees a split candidate, and a verb with none is rescued in the same pass.
"""
import bisect
import json
import os
import re
import sys
import unicodedata
from collections import defaultdict

HERE = os.path.dirname(os.path.abspath(__file__))
CORPUS = os.path.dirname(HERE)
ROOT = os.path.dirname(CORPUS)
FORMS_JSON = os.path.join(HERE, "forms.json")
OUT_JSON = os.path.join(HERE, "corpus_index.json")

# Final distinct sentences kept per verb, and the per-document ceiling gathered before balancing.
MAX_OCCURRENCES = 5
PER_DOC_CAP = 4
# Stored quote width (chars). A sentence shorter than this is stored whole; longer ones are
# trimmed around the matched token and flagged `truncated`.
#
# This was 200, inherited from Conjugar, where a snippet's job was to let a reader *judge* a
# candidate's relevance. Phase 4 uses it for a different job — *quoting* the sentence into the
# app — and a preview may be lossy where a quotation may not. At 200 chars, 36% of candidates
# arrived truncated, so MINING_SPEC told every subagent to re-open the source file at `doc:line`
# and recover the sentence by hand. That reopen was measured as roughly 45% of a mining shard's
# cost, and it put the subagent in the business of reassembling sentences across two-column PDF
# extractions, which is exactly where a misquote gets manufactured.
#
# The sentence was already computed here and then thrown away. Storing it whole costs about
# 10 KB per shard and removes the reopen for all but the runaways.
MAX_QUOTE_CHARS = 600

# The word band a quoted sentence should land in to read well on a phone screen. Candidates
# inside the band sort ahead of those outside it, within their rank tier.
#
# Added 2026-07-20 after two shard-runs independently reported walking past one to three
# candidates per verb on length alone. The cause is that `_rank` encodes only contiguous-vs-split,
# so the round-robin merge hoists whatever each work offered first — and the literary sources
# (Kafka, Mann, Nietzsche) offer periods. Measured over the whole index: the median candidate is
# 25 words but the 90th percentile is 59, and for 402 verbs (15% of those with candidates) the
# lead candidate ran past 45 words while a clean 8-30 word one sat below it.
TARGET_WORDS = (8, 30)

# Defects that sort a candidate last instead of removing it. See `is_defective` for why an
# unbalanced quotation mark is usually a sentence inside a longer quotation rather than damage.
DEMOTE_ONLY = {"unbalanced", "leading-dash"}

# Party affiliations as the Bundestag protocols print them, inside square brackets after a
# speaker's name. Their presence means the sentence is a heckle carrying its own attribution.
PARTY_TAG = re.compile(
    r"\[(?:SPD|CDU/CSU|CDU|CSU|AfD|FDP|GRÜNE|BÜNDNIS[^\]]*|DIE LINKE|LINKE|fraktionslos)\]"
)


TERMINAL_PUNCT = (".", "!", "?", "…", ":")
TRAILING_CLOSERS = "\"'»«“”„)]›‹’ "
# A MediaWiki list item or namespace link that survived extraction as raw markup.
WIKI_MARKUP = re.compile(
    r"^\s*[*#:]+\s|"
    r"\b(?:Hilfe|Datei|Kategorie|Vorlage|Wikipedia|Spezial|Diskussion|Portal|Benutzer):[A-ZÄÖÜ]"
)
# A verse number between a clause boundary and the lowercase word resuming the sentence.
VERSE_NUMBER = re.compile(r"[;:,.]\s+\d{1,3}\s+[a-zäöüß]")

# Content that should not ship into a learner app even though it is mechanically perfect German.
#
# Scoped to the government tier on purpose, and that scope is the whole design. Those documents
# are contemporary parliamentary speech: the people named are alive, the attacks are partisan,
# and a sentence advocating violence against a named official is not something Konjugieren should
# print under a citation because it happened to contain `androhen`. The literary tier is exempt
# because violence there is centuries old and is context rather than advocacy --- Luther's God
# smites, Kafka's `Prozess` ends in an execution, and filtering those would gut the best source
# of clean sentences the corpus has while protecting nobody.
#
# Added 2026-07-20 after a shard-run refused `androhen`'s sole candidate on these grounds and
# argued, correctly, that the judgment should be made once here rather than re-made by taste in
# each of 104 shards. A per-shard decision is not reproducible and not reviewable; this is both.
#
# Deliberately narrow: it targets explicit advocacy of physical harm, not political anger,
# insult, or disagreement, all of which are ordinary parliamentary register and are a subagent's
# call to make on readability grounds.
UNSUITABLE_CONTENT = re.compile(
    r"\b(?:ver)?prügel\w*|\bSchläge\b|\bzusammenschlag\w*|\bniederknüppel\w*"
    r"|\berschieß\w*|\baufhäng\w*|\bvergas\w*|\berschlag\w*|\babstech\w*",
    re.IGNORECASE,
)

# Works whose orthography predates modern spelling by enough to mislead a learner. The
# Westphalian peace instruments (1648) print `Vhrkunden`, `Creditorn`, `restituirt` --- fluent
# and quotable, but nobody should learn German from them. Demoted rather than dropped, since a
# verb attested only there still deserves its one attestation, and a subagent can still reject it.
#
# Added 2026-07-20: a shard-run found the 1648 text leading `abzwingen`'s candidate list while
# Kafka's eight-word "Das zwang ihm nun doch eine Antwort ab." sat two places below it.
ARCHAIC_WORKS = {"westphalia-de"}


def is_defective(text, rel="", truncated=False):
    """Name the mechanical defect in a candidate's text, or None if it is clean.

    These are the defects that make a candidate unusable *without judgment*, and every one of
    them was reported by a mining subagent as a recurring rejection before it was filtered here.
    They are cheap to detect and expensive to leave in: a subagent pays to read the candidate,
    reason about it, and reject it, and a tired one might not reject it.

    Each tell corresponds to an upstream extraction failure the indexer cannot repair:

    - `starts-lowercase`: the sentence splitter cut mid-sentence, so the quote has no Vorfeld
      and cannot stand alone. Note this is safe *only* because German capitalizes all nouns and
      every sentence's first word; the same rule would be wrong for English.
    - `unbalanced`: an unclosed paren or quotation mark. In the Bundestag protocols this means a
      speaker attribution was severed from its heckle, which is fatal; in Luther and Grimm it
      usually means a complete sentence sits inside a longer quotation, which is not. Demoted
      rather than dropped for that reason --- see the severity note below.
    - `gutter-hyphen`: a word severed mid-token across a two-column PDF gutter
      (`praxistauglicheren Strafver-` + `in den Ländern`). Fluent-looking and entirely wrong.
    - `column-marker`: a bare `(A)`/`(B)` column label from a two-column protocol landed inside
      the prose.
    - `speaker-tag`: a Bundestag heckle printed with its own attribution inline
      (`– Kay Gottschalk [AfD]: Wie wär's denn …`). The attribution cannot be quoted and cannot
      be trimmed away, so the candidate is dead however carefully it is read. Caught by the
      party bracket rather than by punctuation, because such a line is often otherwise
      well-formed --- one led its verb's candidate list through two rounds of filtering.
    - `leading-dash`: the text opens on a dash. Demoted, not dropped: Nietzsche writes
      continuation dashes that head what is nonetheless a complete sentence, so this is a
      presentational wart rather than damage.
    - `no-terminal-punct`: the text stops without `.`, `!`, `?` or `…`, so the splitter cut it
      short — a Bundestag fragment ending on a comma is the reported case. This escapes
      `starts-lowercase` whenever the fragment happens to begin on a capitalized noun, which
      German supplies constantly, so the two rules are complements rather than duplicates.
      Skipped for `truncated` candidates, whose ellipsis is the snippet window's doing.
    - `wiki-markup`: a MediaWiki list item or namespace link that reached the text as markup
      (`* Hilfe:Unterseiten – …`). Unquotable, and not repairable by stripping, because the
      content itself is a navigation stub rather than prose.
    - `verse-number`: a Luther verse number sitting *inside* the sentence between clauses
      (`…wäre; 24 aber es ist…`). The leading-number rule in `LEADING_FURNITURE` catches these
      only at the head; mid-sentence they cannot be stripped, since edits below the head are
      forbidden. Scoped to the Luther documents, where a bare integer between a clause boundary
      and a lowercase word is unambiguously versification and never prose.

    - `unsuitable-content`: government-tier prose advocating physical harm, typically at a named
      and living official. Not a mechanical defect but an editorial one, and the only entry here
      that is about meaning rather than damage. It lives in this function anyway because the
      alternative is 104 subagents each deciding it by taste. See `UNSUITABLE_CONTENT` for why
      the literary tier is exempt.

    Deliberately *not* filtered: candidates whose furniture would have to be stripped to reach
    the matched verb. Subagents reject those visibly, which is better than a silent edit --- see
    Phase 4's note in `prompts/uses_etymologies.md`.

    Severity matters, and `DEMOTE_ONLY` below says which defects merely sort last rather than
    disqualify. `unbalanced` is not always damage: German quoted speech spans sentences freely
    (`„Erstens dies. Zweitens das.“`), so the splitter hands back two complete sentences each
    holding one half of the quotation marks. Luther and Grimm are saturated with such speech and
    are two of the three largest lead sources, so hard-dropping every imbalance costs real
    coverage for verbs attested only there. Demoting keeps them reachable when they are a verb's
    only evidence, and the subagent can still reject one.
    """
    if not text:
        return "empty"
    if PARTY_TAG.search(text):
        return "speaker-tag"
    if text[0].islower():
        return "starts-lowercase"
    if re.match(r"[–—-]\s", text):
        return "leading-dash"
    for opener, closer in (("(", ")"), ("„", "“")):
        if text.count(opener) != text.count(closer):
            return "unbalanced"
    if text.count('"') % 2:
        return "unbalanced"
    if re.search(r"[a-zäöüß]-\s+[a-zäöüß]", text):
        return "gutter-hyphen"
    if re.search(r"\((?:A|B|C|D)\)", text):
        return "column-marker"
    if WIKI_MARKUP.search(text):
        return "wiki-markup"
    if "luther-bible" in rel and VERSE_NUMBER.search(text):
        return "verse-number"
    if rel and bucket_of(rel).startswith("government") and UNSUITABLE_CONTENT.search(text):
        return "unsuitable-content"
    # Closing marks and brackets trail legitimate terminal punctuation (`… gesagt.“`), so they
    # come off before the test; otherwise every quoted sentence in Grimm reads as a fragment.
    if not truncated and not text.rstrip().rstrip(TRAILING_CLOSERS).endswith(TERMINAL_PUNCT):
        return "no-terminal-punct"
    return None


# How often the corpus must attest a rejoined word before a candidate is thrown away over it.
SEVERED_JOIN_MIN = 5


def hyphenation_defect(text, counts, rel):
    """Name a de-hyphenation defect in a candidate, or None.

    Catches `split-word`: a word broken across a line whose hyphen did not survive extraction,
    leaving two tokens (`Hauptschul abschluss`, `Bruttoinlands produkts`, `Leistungsfähig keit`).
    Detected by rejoining a capitalized token with the lowercase one after it and asking whether
    the corpus knows the result as a frequent word. These read fluently and are entirely wrong,
    which is what makes them worth machine-detecting rather than leaving to a subagent's eye.

    The corpus is its own dictionary here, which is what makes this cheap and self-maintaining:
    no word list to ship, and the frequency table falls out of the pass the indexer already makes.

    Scoped to the PDF-derived tiers, since the literary sources are clean transcriptions rather
    than column extractions. Sentence-initial tokens are exempt because `Die selbe` legitimately
    capitalizes at a sentence start while joining to a frequent word.

    A SECOND RULE WAS TRIED HERE AND REMOVED --- do not re-add it without new evidence. The
    remaining known defect is the *severed* word, where the head of the break was lost entirely
    and only a tail survives: `… soll wieder tionäre abwerfen`, from `… Dividenden an Ak|tionäre`.
    The obvious test is "a token that is near-absent from the corpus while being the ending of a
    word that is common in it." Measured on 2026-07-20 it dropped 250 candidates at visibly poor
    precision, taking clean sentences like "Haben Förderprogramme die erwünschten Wirkungen
    gebracht?" with it.

    The reason is structural and worth knowing before anyone tries again: German compounding
    makes "is the ending of some frequent word" very nearly vacuous. Almost every German word is
    the tail of some longer compound, so the test fires on ordinary vocabulary and the rarity
    threshold cannot separate the cases. Detecting a severed head needs a real lexicon with
    morpheme boundaries, not a frequency table --- and until then, a subagent rejecting the
    occasional `tionäre` by eye is the cheaper error.
    """
    if bucket_of(rel) not in {"government", "government2", "technology"}:
        return None
    tokens = TOKEN_RE.findall(text)
    for index, token in enumerate(tokens):
        lowered = token.lower()
        if index and token[0].isupper() and index + 1 < len(tokens):
            nxt = tokens[index + 1]
            if nxt[0].islower() and counts.get((lowered + nxt.lower()), 0) >= SEVERED_JOIN_MIN:
                return "split-word"
    return None


def archaic_tier(candidate):
    """0 for modern orthography, 1 for a work that predates modern spelling.

    Sorts after `_rank` and `_demoted` but before `length_tier`, so a modern sentence of any
    length outranks 1648 chancery German. Never removes: a verb attested only in the Westphalian
    instruments keeps its one candidate.
    """
    return 1 if bucket_of(candidate["doc"]) in ARCHAIC_WORKS else 0


def length_tier(text):
    """0 when the candidate sits in the phone-screen word band, 1 otherwise.

    Used as a sort key *after* `_rank`, so it breaks ties within a tier and never promotes a
    split-form candidate over a contiguous one.
    """
    return 0 if TARGET_WORDS[0] <= len(text.split()) <= TARGET_WORDS[1] else 1

# Tier priority: literature → government → technology, as in Conjugar. `modern/` is this corpus's
# literature tier (it also holds the constitutional texts, which read as literature-adjacent legal
# prose). `government2` is the batch-2 government sources and shares the government bucket.
#
# `corpus/medieval/` is deliberately NOT indexed here. It yielded 14 candidates out of ~10,600, and
# inspecting all 14 showed most were not usable text: some were lines of scholarly glossary
# ("rıtun (rītan) — ritten (Eng: rode) → NHD reiten"), and others were modern encyclopedia prose
# *about* the manuscript that would have shipped under a "(ca. 830)" citation — fluent German that
# passes review while attributing a 2010s Wikipedia sentence to a ninth-century poem. Those files
# mix primary text, translation, and commentary, so citing them needs a policy this indexer does
# not have. Conjugar reached the same conclusion and built its medieval pass as a separate program.
TIERS = (
    ("modern", "literature"),
    ("government", "government"),
    ("government2", "government"),
    ("technology", "technology"),
)

# Unicode-aware word tokens: runs of letters only, so digits/punctuation separate. ß and umlauts
# are letters. Apostrophes split ("geht's" → ["geht", "s"]), which is what we want.
TOKEN_RE = re.compile(r"[^\W\d_]+", re.UNICODE)

GUTENBERG_START = re.compile(r"\*\*\* ?START OF THE PROJECT GUTENBERG EBOOK.*?\*\*\*", re.S)
GUTENBERG_END = re.compile(r"\*\*\* ?END OF THE PROJECT GUTENBERG EBOOK")

# German abbreviations whose trailing period does not end a sentence. The legal and administrative
# sources are dense in "Art. 5 Abs. 2 Satz 1" and "z. B."; without these the splitter shreds them
# into fragments and the split-particle search loses the rest of the clause.
ABBREVIATIONS = {
    "abb", "abs", "abschn", "art", "aufl", "bd", "bearb", "bes", "betr", "bspw", "bzgl", "bzw",
    "ca", "d", "dgl", "dr", "ebd", "eig", "einschl", "entspr", "erg", "etc", "evtl", "f", "ff",
    "geb", "gem", "ggf", "ggfs", "hrsg", "i", "inkl", "insb", "insbes", "jh", "kap", "lt", "max",
    "min", "mio", "mrd", "nr", "o", "od", "og", "prof", "rd", "s", "sog", "str", "tab", "u", "usw",
    "v", "vgl", "vgl", "vs", "z", "zb", "zit", "zzgl",
}

# PDF-extraction debris: soft hyphens and the control characters pdftotext emits for tabs and
# figures. \x0c (form feed) is deliberately absent — it marks page breaks, which de-columnization
# needs — and is removed only after that step.
SOFT_JUNK = re.compile(r"[­​⁠\x00-\x08\x0b\x0e-\x1f]")
DOT_LEADER = re.compile(r"\.{4,}")

# --- Two-column PDF recovery -------------------------------------------------------------------
# The Bundestag Plenarprotokolle were converted with `pdftotext -layout`, which preserves a
# two-column page as side-by-side text: one physical line holds a fragment of the left column, a
# run of padding spaces, then a fragment of the right column. Reading such a line as running prose
# splices two unrelated sentences together ("…die mich konstruktiv begleitet   noch weiter gehen"),
# which produced two thirds of the candidates from those three files as garbage.
#
# These are the corpus's only source of natural spoken German, so they are worth recovering rather
# than dropping. The gutter is found per page as the column offset that is blank on most lines, and
# the page is then read down the left column and down the right. Detection is by geometry, not by
# filename, so a future two-column source is handled without a code change.
MIN_GUTTER_SHARE = 0.6
MIN_PAGE_LINES = 6

# Display names for the `source` field, so Phase 4 subagents need not infer a citation from a
# filename. Keyed by filename prefix; longest match wins.
SOURCE_NAMES = {
    "goethe-werther": "Goethe — Die Leiden des jungen Werthers",
    "kafka-prozess": "Kafka — Der Proceß",
    "mann-venedig": "Mann — Der Tod in Venedig",
    "grimm-maerchen": "Grimm — Märchen",
    "nietzsche-zarathustra": "Nietzsche — Also sprach Zarathustra",
    "nietzsche-jenseits": "Nietzsche — Jenseits von Gut und Böse",
    "luther-bible": "Luther — Bibel",
    "grundgesetz": "Grundgesetz (1949)",
    "westphalia": "Westfälischer Friede (1648)",
    "weimar-verfassung": "Weimarer Verfassung (1919)",
    "berufsbildungsbericht-2024": "Berufsbildungsbericht (2024)",
    "bundesverkehrswegeplan-2030": "Bundesverkehrswegeplan (2030)",
    "raumfahrtstrategie-2023": "Raumfahrtstrategie (2023)",
    "raumordnungsbericht-2021": "Raumordnungsbericht (2021)",
    "bufi-kurzfassung-2024": "BuFI Kurzfassung (2024)",
    "digitale-strategie-2025": "Digitale Strategie 2025",
    "ki-strategie-2020": "KI-Strategie (2020)",
    "bfdi-datenschutz": "BfDI — Basiswissen zum Datenschutz",
    "bfs-ionisierende-strahlung": "BfS — Ionisierende Strahlung",
    "bmukn-kreislaufwirtschaft": "BMUKN — Kreislaufwirtschaft",
    "bmukn-recht-auf-reparatur": "BMUKN — Recht auf Reparatur",
    "bpb-medienpaedagogik": "BPB — Medienpädagogik",
    "bsi-social-media": "BSI — Sicherheit in Social Media",
    "bundesrechnungshof-bemerkungen-2025": "Bundesrechnungshof — Bemerkungen 2025",
    "bundestag-plenarprotokoll-20-207": "Bundestag — Plenarprotokoll 20/207",
    "bundestag-plenarprotokoll-20-210": "Bundestag — Plenarprotokoll 20/210",
    "bundestag-plenarprotokoll-20-214": "Bundestag — Plenarprotokoll 20/214",
    "ffa-filmfoerderung": "FFA — Filmförderung",
    "kfw-energetische-sanierung": "KfW — Energieeffizient sanieren",
    "bsi-accountschutz": "BSI — Accountschutz",
    "bsi-basisschutz-computer": "BSI — Basisschutz für Computer",
    "bsi-benutzerkonten": "BSI — Benutzerkonten einrichten",
    "bsi-passwoerter-2024": "BSI — Sichere Passwörter erstellen",
    "bsi-router-wlan-vpn": "BSI — Router, WLAN und VPN",
    "bsi-grundschutz-software-tests-2023": "BSI — IT-Grundschutz OPS.1.1.6",
    "bsi-grundschutz-patch-management-2023": "BSI — IT-Grundschutz OPS.1.1.3",
    "bsi-grundschutz-datensicherung-2023": "BSI — IT-Grundschutz CON.3",
    "wiki-datensicherung": "Wikipedia — Datensicherung",
    "wiki-firewall": "Wikipedia — Firewall",
    "wiki-hilfe-bearbeiten": "Wikipedia — Hilfe:Bearbeiten",
    "wiki-hilfe-dateien": "Wikipedia — Hilfe:Dateien",
    "wiki-installation": "Wikipedia — Installation (Software)",
    "wiki-softwaretest": "Wikipedia — Softwaretest",
    "wiki-verschluesselung": "Wikipedia — Verschlüsselung",
    "hildebrandslied": "Hildebrandslied (ca. 830)",
    "tatian": "Althochdeutscher Tatian (ca. 830)",
    "strasbourg-oaths": "Straßburger Eide (842)",
}


def source_name(name):
    """Filename → citation string, longest prefix wins."""
    stem = name[:-4] if name.endswith(".txt") else name
    best = ""
    for prefix in SOURCE_NAMES:
        if stem.startswith(prefix) and len(prefix) > len(best):
            best = prefix
    return SOURCE_NAMES.get(best, stem)


# German function words with no English homograph, used to tell a source's language from its
# content. Words like `in`, `was`, `will`, `hat`, `man`, `die` are excluded precisely because they
# are the collision cases: a detector built from those calls Nietzsche's "Was in uns will
# eigentlich zur Wahrheit?" English.
GERMAN_MARKERS = frozenset("""
und nicht ist ich sich auch werden oder aber wird dass daß eine einem einen für über durch sind
haben kann noch schon wenn wie nur bei aus vom zur zum dem den des ihre seine diese
""".split())
# Measured across every file in the corpus: the English translations score 0.00–0.04% and the
# German sources 9.27% (Westphalia, whose 17th-century spelling is the floor) to 22%. Three percent
# sits two orders of magnitude above the English maximum with ample room below the German minimum.
MIN_GERMAN_SHARE = 0.03
LANGUAGE_SAMPLE = 200_000


def is_german(abspath):
    """Whether a source is German, judged by content rather than by filename.

    The corpus ships each literary work in German and English, and ten common English words are
    German verb forms in forms.json — war→sein, will→wollen, hat→haben, sang→singen, band→binden
    among them — so an English file indexes as spurious attestations of German verbs. The `-en.txt`
    naming convention identifies today's translations, but a convention is not a guarantee, and
    nothing would report the mistake: bad candidates would simply appear, in fluent English, under
    a German citation.
    """
    with open(abspath, encoding="utf-8", errors="replace") as handle:
        sample = handle.read(LANGUAGE_SAMPLE)
    words = [word.lower() for word in TOKEN_RE.findall(sample)]
    if len(words) < 50:
        return False
    return sum(1 for word in words if word in GERMAN_MARKERS) / len(words) >= MIN_GERMAN_SHARE


def ordered_docs():
    """(tier, work, relpath, abspath) for every German source, in tier priority order.

    `work` is the balancing bucket: the file slug for the literature tier (so the rotating lead
    spreads across Kafka / Grimm / Luther / …) and the tier name elsewhere.
    """
    docs = []
    for folder, tier in TIERS:
        tier_dir = os.path.join(CORPUS, folder)
        if not os.path.isdir(tier_dir):
            continue
        for name in sorted(os.listdir(tier_dir)):
            # GERMAN 1: the parallel English translations are not evidence of German usage.
            if not name.endswith(".txt"):
                continue
            path = os.path.join(tier_dir, name)
            if not is_german(path):
                continue
            stem = name[:-4]
            work = stem if tier == "literature" else tier
            rel = os.path.join("corpus", folder, name)
            docs.append((tier, work, rel, os.path.join(tier_dir, name)))
    return docs


def find_gutter(lines):
    """Column offset splitting a two-column page, or None if the page is single-column.

    The gutter is the offset that is whitespace on nearly every line of the page. Only the middle
    of the page is considered, so an indented block does not read as a column boundary.
    """
    body = [line for line in lines if line.strip()]
    if len(body) < MIN_PAGE_LINES:
        return None
    width = max(len(line) for line in body)
    if width < 60:
        return None
    best, best_score = None, 0
    for offset in range(int(width * 0.3), int(width * 0.7)):
        score = sum(1 for line in body if line[offset: offset + 1].strip() == "")
        if score > best_score:
            best, best_score = offset, score
    if best is None or best_score < len(body) * MIN_GUTTER_SHARE:
        return None
    # A true gutter is a band of blank columns, not one lucky offset, and lines must actually use
    # both sides of it — otherwise this is just a page whose text stops short of the right margin.
    band = all(
        sum(1 for line in body if line[o: o + 1].strip() == "") >= len(body) * MIN_GUTTER_SHARE
        for o in range(best, min(best + 3, width))
    )
    two_sided = sum(1 for line in body if line[best:].strip()) >= len(body) * 0.25
    return best if band and two_sided else None


def logical_lines(abspath):
    """[(physical_line_number, text)] for a document, de-columnizing two-column pages.

    Line numbers are carried through rather than recomputed so that the `doc:line` a subagent
    re-opens still lands on the passage, even where columns were reordered.
    """
    with open(abspath, encoding="utf-8", errors="replace") as handle:
        text = unicodedata.normalize("NFC", handle.read())
    # Numbering starts after any Gutenberg header but counts the lines it skipped, so the reported
    # line is the one in the file on disk. Kafka's header alone is 24 lines: numbering the stripped
    # text from 1 puts every citation in that file 24 lines off.
    first_line = 1
    start = GUTENBERG_START.search(text)
    if start:
        first_line += text[: start.end()].count("\n")
        text = text[start.end():]
    end = GUTENBERG_END.search(text)
    if end:
        text = text[: end.start()]
    text = DOT_LEADER.sub(" ", SOFT_JUNK.sub("", text))

    numbered = list(enumerate(text.split("\n"), start=first_line))
    out = []
    page = []
    for entry in numbered + [(None, "\x0c")]:
        if "\x0c" in entry[1]:
            head, _, tail = entry[1].partition("\x0c")
            if head.strip():
                page.append((entry[0], head))
            out.extend(split_page(page))
            page = [(entry[0], tail)] if tail.strip() else []
            continue
        page.append(entry)
    return out


def split_page(page):
    """A page's lines in reading order: down the left column, then down the right."""
    if not page:
        return []
    gutter = find_gutter([line for _, line in page])
    if gutter is None:
        return [(number, line.strip()) for number, line in page]
    left, right = [], []
    for number, line in page:
        # A line whose text runs across the gutter is full width (a heading or a speaker line);
        # it belongs to the left stream whole rather than being cut in two.
        if line[max(0, gutter - 2): gutter + 2].strip():
            left.append((number, line.strip()))
            continue
        left.append((number, line[:gutter].strip()))
        right.append((number, line[gutter:].strip()))
    return left + [(None, "")] + right


def paragraphs(lines):
    """Yield (reflowed_text, marks) for each blank-line-delimited paragraph.

    The sources are hard-wrapped, so lines are joined with a space to recover running prose.
    `marks` is [(offset_into_reflowed_text, physical_line_number)], which lets each *sentence*
    report the line it starts on. Reporting the paragraph's first line instead is off by however
    deep into the paragraph the sentence sits — 15 lines, in a Luther paragraph measured while
    debugging this — and Phase 4 subagents are told to re-open the source at that line.
    """
    buffer = []
    for number, line in lines:
        if line.strip():
            buffer.append((number, line.strip()))
        elif buffer:
            yield reflow(buffer)
            buffer = []
    if buffer:
        yield reflow(buffer)


# A hyphen ending a line is usually a word broken across lines by the PDF extractor, but German
# also writes a suspended hyphen in coordinations ("Ein- und Ausgang", "Vor- oder Nachteil"), where
# the hyphen is real and the word must not be rejoined.
SUSPENDED = ("und", "oder", "bzw", "sowie", "wie")


def reflow(buffer):
    """Join hard-wrapped lines into running prose, healing words broken across the break.

    Returns (text, marks) where marks pairs each source line with its offset in the joined text.
    Rejoining matters for recall as well as readability: a wrapped "ab-\\ngeholt" tokenizes as
    `ab` + `geholt` and never matches the form `abgeholt` in forms.json.
    """
    out = ""
    marks = []
    for number, line in buffer:
        if not out:
            marks.append((0, number))
            out = line
            continue
        head = re.search(r"[^\W\d_]-$", out)
        follows = re.match(r"[^\W\d_]+", line)
        if head and follows and follows.group(0)[:1].islower() and follows.group(0) not in SUSPENDED:
            out = out[:-1]
            marks.append((len(out), number))
            out += line
        else:
            out += " "
            marks.append((len(out), number))
            out += line
    return out, marks


def line_at(marks, offset):
    """Physical line number containing `offset` in the reflowed paragraph."""
    index = bisect.bisect_right(marks, (offset, float("inf"))) - 1
    return marks[max(0, index)][1]


def sentences(text):
    """Split reflowed prose into sentences, honoring German abbreviations.

    A period/!/? followed by whitespace ends a sentence unless the preceding word is a known
    abbreviation or a single letter (initials, and the "z. B." / "d. h." pattern whose first half
    tokenizes as a lone letter).

    Returns [(offset_of_sentence_in_text, sentence)].
    """
    parts, start = [], 0
    for match in re.finditer(r"[.!?…](?=[\s\"»«„“”]|$)", text):
        head = text[start: match.end()]
        word = re.search(r"([^\W\d_]+)[.!?…]$", head)
        if word and word.group(1).lower() in ABBREVIATIONS:
            continue
        if word and len(word.group(1)) == 1:
            continue
        stripped = head.strip()
        if stripped:
            parts.append((start + head.index(stripped[0]), stripped))
        start = match.end()
    tail = text[start:]
    if tail.strip():
        parts.append((start + tail.index(tail.strip()[0]), tail.strip()))
    return parts


# GERMAN: extraction furniture, stripped from the stored quotation.
#
# Roughly a quarter of candidates carried debris that is not part of the sentence at all: verse
# numbers, legal paragraph numbers, plenary heckles, two-column page markers, Gutenberg emphasis
# underscores. Phase 4 subagents were rejecting otherwise-good sentences over it, and a rejected
# candidate is unrecoverable — nothing records which sentence was passed over — so cleaning here
# raises yield in a way a later cleanup pass cannot.
#
# Every rule is scoped to the documents where the artifact is unambiguous, because the same
# pattern is legitimate text elsewhere. A leading integer is a verse number in the Luther bible
# and a plain numeral in a ministry report, so 1,689 of the 1,711 leading-number candidates are
# stripped and the other 22 are left alone.
#
# Two lessons from measuring before writing these, both of which would have caused silent damage:
#
#   * A "speaker label" rule keyed on `^Name:` decapitates ordinary German. "Deshalb: Nach der
#     Ampel links abbiegen." and "Nur: Seit über zwei Jahren…" both match, and neither is a
#     label. The real artifact is a speaker name followed by a column marker — `Schrodi (A)` —
#     so that is what the rule matches.
#   * Only *leading* runs are stripped, never mid-sentence parentheticals. A heckle at the head
#     precedes the sentence; one in the middle may be something the speaker said.
#
# The underscore rule is the sole exception to leading-only, because Gutenberg's `_word_` is
# emphasis markup rather than content and would otherwise ship into the app as literal
# underscores. It removes the delimiters and keeps the word.
HECKLE = r"Beifall|Zuruf|Lachen|Heiterkeit|Widerspruch|Unruhe|Gegenruf|Zurufe"
LEADING_FURNITURE = (
    # (compiled pattern, predicate on the document's relative path)
    (re.compile(r"^\d{1,3}\s+(?=[A-ZÄÖÜ])"), lambda rel: "luther-bible" in rel),
    (re.compile(r"^\(\d+\)\s*"), lambda rel: "grundgesetz" in rel or "verfassung" in rel),
    (re.compile(rf"^\((?:{HECKLE})[^)]*\)\s*"), lambda rel: "plenarprotokoll" in rel),
    # A heckle with an attributed speaker: "(Filiz Polat [BÜNDNIS 90/DIE GRÜNEN]: Sagen Sie …)"
    (re.compile(r"^\([^)]*\[[^\]]*\][^)]*\)\s*"), lambda rel: "plenarprotokoll" in rel),
    # Speaker name immediately before a column marker, and the bare marker itself.
    (re.compile(r"^[A-ZÄÖÜ][\wÄÖÜäöüß.\-]*(?:\s+[A-ZÄÖÜ][\wÄÖÜäöüß.\-]*){0,3}\s*\(\s*[A-D]\s*\)\s*"),
     lambda rel: "plenarprotokoll" in rel),
    (re.compile(r"^\(\s*[A-D]\s*\)\s*"), lambda rel: "plenarprotokoll" in rel),
    # Page-header debris left by de-columnizing: a running page number before the speaker.
    (re.compile(r"^\d{4,6}\s+"), lambda rel: "plenarprotokoll" in rel),
    (re.compile(r"^\+\+\+[^+]*\+\+\+\s*"), lambda rel: True),
    # An orphaned quotation mark the splitter carried over from the *previous* sentence
    # (`« Der Teufel …`, `“ K. dachte …`). The whitespace is what identifies it: a real opening
    # mark hugs its first word (`„Wort`), so a mark followed by a space opened nothing here.
    # `„` is excluded deliberately — it is German's opening mark and never an orphan at the head.
    (re.compile(r"^[«»“”]\s+"), lambda rel: True),
)
GUTENBERG_EMPHASIS = re.compile(r"_([^_\n]{1,60})_")


def strip_furniture(sentence, rel, token_offset):
    """
    Remove extraction artifacts from a sentence before it is stored as a quotation.
    Returns (cleaned_sentence, offset_of_the_matched_token_within_it).

    Leading runs are stripped repeatedly until the text stops changing, since a single
    sentence routinely carries several — a page number, then a speaker name, then a
    column marker — before the speech itself begins.

    **The matched token is inviolable, and the caller's offset is what protects it.**
    A first version stripped blindly and then searched the result for the token, which
    failed two ways at once: thirteen sentences were stripped past their own verb (three
    of them to the empty string), and on long sentences `find` located a *different*
    occurrence of the token, so the stored window jumped to an unrelated clause. Both
    failures produced plausible-looking text, which is what makes them worth this much
    care. Now no rule may cut into the token's position, and the offset is carried
    through the edits rather than rediscovered.
    """
    if "/modern/" in rel or rel.startswith("modern/"):
        # Mid-sentence edit, so the token's offset shifts by the delimiters removed ahead of it.
        removed_before = sum(2 for match in GUTENBERG_EMPHASIS.finditer(sentence)
                             if match.end() <= token_offset)
        sentence = GUTENBERG_EMPHASIS.sub(r"\1", sentence)
        token_offset -= removed_before

    changed = True
    while changed:
        changed = False
        for pattern, applies in LEADING_FURNITURE:
            if not applies(rel):
                continue
            match = pattern.match(sentence)
            # Refuse any strip that would reach the matched verb; leave the artifact
            # rather than damage the attestation.
            if not match or match.end() == 0 or match.end() > token_offset:
                continue
            sentence = sentence[match.end():]
            token_offset -= match.end()
            changed = True

    lead = len(sentence) - len(sentence.lstrip())
    return sentence.strip(), max(token_offset - lead, 0)


def snippet(sentence, token_start, token):
    """
    Return (text, truncated). The sentence whole when it fits under MAX_QUOTE_CHARS,
    else MAX_QUOTE_CHARS centered on the match with ellipses.

    `truncated` is reported explicitly rather than left to be inferred from a leading
    or trailing "…", because a sentence can legitimately *contain* an ellipsis — the
    Bundestag protocols use them for interruptions — and a consumer that guessed from
    the glyph would quote a fragment believing it complete.
    """
    if len(sentence) <= MAX_QUOTE_CHARS:
        return sentence, False
    half = MAX_QUOTE_CHARS // 2
    lo = max(0, token_start - half)
    hi = min(len(sentence), token_start + len(token) + half)
    text = ("…" if lo > 0 else "") + sentence[lo:hi].strip() + ("…" if hi < len(sentence) else "")
    return text, True


# Punctuation that closes a German clause. A Satzklammer never spans one of these.
CLAUSE_BREAK = set(",;:.!?()[]—–…\"«»„“”")
# Generous ceiling on the Mittelfeld — the material a stranded particle may sit behind.
MAX_BRACKET_TOKENS = 12


def strand_position(sentence, tokens, lowered, verb_position, particle, forms):
    """Index of `particle` closing the verb's Satzklammer, or None.

    German brackets a separable verb around its clause: the finite verb opens the bracket and the
    particle closes it ("er *fängt* neu *an*"). Four constraints follow, and each was added because
    sampling found it violated. A sentence-wide search — merely "the particle occurs later" — was
    roughly seventy percent spurious.

    * **No clause boundary between them.** In "trat beiseite, ging aber nicht weg" the `weg`
      belongs to `ging`, in the next clause; a comma proves `trat` cannot own it.
    * **The particle closes its clause.** In "liefen sie voll Zorn und Wut hinaus" the `voll`
      governs the noun after it, so it is an adjective, not a stranded particle of `volllaufen`.
    * **The particle is not capitalized.** Corpus tokens are lowercased to match forms.json, which
      makes the noun `Weg` in "auf einen Acker am Weg" indistinguishable from the particle `weg`.
      A stranded particle is never clause-initial, so it is never legitimately capitalized.
    * **No intervening verb claims the same particle.** In "gräbt eine Grube und deckt sie nicht
      zu" the `zu` closes the bracket of `zudecken`, not of `zugraben`; `deckt` sits between them
      and takes `zu` itself. When two verbs can claim one particle the nearer one wins, so this
      drops the candidate rather than guessing.

    A distance ceiling guards against a long clause accidentally spanning a plausible homograph.
    """
    for where in range(verb_position + 1, min(len(tokens), verb_position + 1 + MAX_BRACKET_TOKENS)):
        start = tokens[where][1]
        gap = sentence[tokens[where - 1][1] + len(tokens[where - 1][0]): start]
        if CLAUSE_BREAK & set(gap):
            return None
        if lowered[where] != particle:
            if any(
                not other.get("contiguous") and other.get("particle") == particle
                for other in forms.get(lowered[where], ())
            ):
                return None
            continue
        if tokens[where][0][:1].isupper():
            return None
        after = sentence[start + len(particle):].lstrip()
        return where if after[:1] in ("", ",", ";", ".", "!", "?") else None
    return None


def scan_sentence(sentence, forms):
    """Find every verb attested by this sentence.

    Returns {verb: candidate-fields}. The first match for a verb in a sentence wins, matching
    Conjugar's one-occurrence-per-line rule.
    """
    tokens = [(m.group(0), m.start()) for m in TOKEN_RE.finditer(sentence)]
    lowered = [t.lower() for t, _ in tokens]
    found = {}
    for position, (surface, offset) in enumerate(tokens):
        low = lowered[position]
        if len(low) < 2:
            continue
        entries = forms.get(low)
        if not entries:
            continue
        # GERMAN 3: a capitalized token that is not sentence-initial is a noun (das Ringen), not a
        # verb. Position 0 is the only place a genuine verb form is legitimately capitalized.
        if position > 0 and surface[:1].isupper():
            continue
        for entry in entries:
            verb = entry["verb"]
            if verb in found:
                continue
            if entry.get("contiguous"):
                found[verb] = {
                    "token": low,
                    "offset": offset,
                    "contiguous": True,
                    "rank": 0,
                }
                continue
            # GERMAN 4: a split form counts only if its particle closes the verb's Satzklammer.
            particle = entry.get("particle")
            if not particle:
                continue
            where = strand_position(sentence, tokens, lowered, position, particle, forms)
            if where is None:
                continue
            found[verb] = {
                "token": low,
                "offset": offset,
                "contiguous": False,
                "particle": particle,
                # Ranked below every contiguous hit: particles are homographs of very common
                # prepositions, so even a well-formed bracket is weaker evidence than one word.
                "rank": 1,
            }
    return found


def merge_balanced(by_work, lit_works, gov, tech, rank):
    """Round-robin the per-work literature lists from a verb-specific rotated lead, then top up
    from government and finally technology."""
    if lit_works:
        rotation = rank % len(lit_works)
        order = lit_works[rotation:] + lit_works[:rotation]
        queues = [list(by_work.get(work, [])) for work in order]
    else:
        queues = []
    out, position = [], 0
    while len(out) < MAX_OCCURRENCES and any(queues):
        queue = queues[position % len(queues)]
        if queue:
            out.append(queue.pop(0))
        position += 1
    for fallback in (gov, tech):
        if len(out) < MAX_OCCURRENCES:
            out.extend(fallback[: MAX_OCCURRENCES - len(out)])
    return out


def target_verbs():
    """The verbs this pipeline exists to fill: those with no etymology yet. Re-derived from the
    corpus rather than restated, per the phase spec."""
    import xml.etree.ElementTree as ET
    ety_path = os.path.join(ROOT, "Konjugieren", "Models", "Etymologies.json")
    xml_path = os.path.join(ROOT, "Konjugieren", "Models", "Verbs.xml")
    if not (os.path.exists(ety_path) and os.path.exists(xml_path)):
        return set()
    with open(ety_path, encoding="utf-8") as handle:
        have = set(json.load(handle)["en"])
    every = {re.sub(r"[+*^]", "", verb.get("in")) for verb in ET.parse(xml_path).getroot()}
    return {verb for verb in every if verb not in have}


def main():
    with open(FORMS_JSON, encoding="utf-8") as handle:
        forms = json.load(handle)

    docs = ordered_docs()
    lit_works = [work for tier, work, _, _ in docs if tier == "literature"]

    raw = defaultdict(lambda: defaultdict(list))
    per_doc_seen = defaultdict(set)
    nominal_skipped = 0
    defective_skipped = defaultdict(int)
    defective_demoted = defaultdict(int)
    sentence_count = 0
    # The corpus doubles as the dictionary `hyphenation_defect` consults. Counted over every
    # sentence in the pass below, then applied afterwards, since a candidate cannot be
    # judged against a table that is still being filled.
    token_counts = defaultdict(int)

    for _tier, work, rel, abspath in docs:
        for paragraph, marks in paragraphs(logical_lines(abspath)):
            for offset, sentence in sentences(paragraph):
                sentence_count += 1
                for word in TOKEN_RE.findall(sentence):
                    token_counts[word.lower()] += 1
                for verb, hit in scan_sentence(sentence, forms).items():
                    # The line holding the matched verb itself, not the sentence or paragraph
                    # start, so `doc:line` opens exactly on the attestation.
                    start_line = line_at(marks, offset + hit["offset"])
                    seen = per_doc_seen[(verb, rel)]
                    key = (start_line, hit["token"])
                    if key in seen or len(seen) >= PER_DOC_CAP:
                        continue
                    seen.add(key)
                    # Furniture is stripped from the stored quotation only, after matching
                    # and after `start_line`. Cleaning before the scan would shift every
                    # offset and put `doc:line` on the wrong line; this way the matching
                    # logic is untouched and only the presented text changes. The token is
                    # re-located in the cleaned sentence, which matters solely for the ~3%
                    # that are long enough to need centering.
                    cleaned, where = strip_furniture(sentence, rel, hit["offset"])
                    text, truncated = snippet(cleaned, where, hit["token"])
                    # Drop the mechanically unusable before a subagent pays to read it. The
                    # check runs on the stored text, after furniture stripping, because that is
                    # the string the subagent would actually have been asked to quote.
                    defect = is_defective(text, rel, truncated)
                    if defect and defect not in DEMOTE_ONLY:
                        defective_skipped[defect] += 1
                        continue
                    if defect:
                        defective_demoted[defect] += 1
                    candidate = {
                        "doc": rel,
                        "line": start_line,
                        "token": hit["token"],
                        "text": text,
                        "truncated": truncated,
                        "contiguous": hit["contiguous"],
                        "source": source_name(os.path.basename(rel)),
                        "_rank": hit["rank"],
                        "_demoted": 1 if defect else 0,
                    }
                    if not hit["contiguous"]:
                        candidate["particle"] = hit["particle"]
                    raw[verb][work].append(candidate)

    for works in raw.values():
        for work, candidates in works.items():
            kept = []
            for candidate in candidates:
                defect = hyphenation_defect(candidate["text"], token_counts, candidate["doc"])
                if defect:
                    defective_skipped[defect] += 1
                else:
                    kept.append(candidate)
            works[work] = kept

    targets = target_verbs()
    all_verbs = sorted({entry["verb"] for entries in forms.values() for entry in entries})

    index = {}
    for rank, verb in enumerate(all_verbs):
        by_work = raw.get(verb)
        if not by_work:
            continue
        # Contiguous evidence first, then clause-final split forms, then the rest. Within a
        # tier, a candidate that fits a phone screen sorts ahead of a 60-word literary period.
        for candidates in by_work.values():
            candidates.sort(key=lambda c: (c["_rank"], c["_demoted"], archaic_tier(c), length_tier(c["text"])))
        merged = merge_balanced(
            by_work,
            [w for w in lit_works if w in by_work],
            by_work.get("government", []),
            by_work.get("technology", []),
            rank,
        )
        merged.sort(key=lambda c: (c["_rank"], c["_demoted"], archaic_tier(c), length_tier(c["text"])))
        for candidate in merged:
            candidate.pop("_rank", None)
            candidate.pop("_demoted", None)
        if merged:
            index[verb] = merged

    out = {verb: index[verb] for verb in sorted(index)}
    with open(OUT_JSON, "w", encoding="utf-8") as handle:
        json.dump(out, handle, ensure_ascii=False, indent=1)

    report(forms, docs, out, targets, sentence_count, defective_skipped, defective_demoted)


def report(forms, docs, out, targets, sentence_count, defective_skipped=None, defective_demoted=None):
    covered_targets = [v for v in sorted(targets) if v in out]
    zero_targets = [v for v in sorted(targets) if v not in out]
    split_only = [v for v in covered_targets if not any(c["contiguous"] for c in out[v])]

    print(f"documents indexed         : {len(docs)}  (English translations excluded)")
    print(f"sentences scanned         : {sentence_count}")
    print(f"forms.json forms          : {len(forms)}")
    print(f"verbs with >=1 candidate  : {len(out)}")
    if defective_skipped:
        total = sum(defective_skipped.values())
        detail = ", ".join(f"{k} {v}" for k, v in sorted(defective_skipped.items(), key=lambda kv: -kv[1]))
        print(f"defective candidates dropped: {total}  ({detail})")
    if defective_demoted:
        total = sum(defective_demoted.values())
        detail = ", ".join(f"{k} {v}" for k, v in sorted(defective_demoted.items(), key=lambda kv: -kv[1]))
        print(f"defective candidates demoted: {total}  ({detail})")
    print()
    print(f"TARGET verbs (no etymology): {len(targets)}")
    if targets:
        share = 100 * len(covered_targets) / len(targets)
        print(f"  with >=1 candidate      : {len(covered_targets)}  ({share:.1f}%)")
        print(f"  contiguous evidence     : {len(covered_targets) - len(split_only)}")
        print(f"  split-form only         : {len(split_only)}  (weaker; subagent must verify)")
        print(f"  zero candidates         : {len(zero_targets)}  (-> corpus expansion, phase 5)")
    print(f"\nJSON written to {os.path.relpath(OUT_JSON, ROOT)}")

    lead = defaultdict(int)
    total = defaultdict(int)
    for occurrences in out.values():
        lead[bucket_of(occurrences[0]["doc"])] += 1
        for occurrence in occurrences:
            total[bucket_of(occurrence["doc"])] += 1
    print("\nLEAD candidate by work (what a subagent reaches for first):")
    for bucket, count in sorted(lead.items(), key=lambda kv: -kv[1]):
        print(f"  {count:5d}  {bucket}")
    print("\nAll candidates by work:")
    for bucket, count in sorted(total.items(), key=lambda kv: -kv[1]):
        print(f"  {count:5d}  {bucket}")

    if zero_targets:
        print(f"\nZero-candidate target verbs ({len(zero_targets)}), first 40:")
        print("  " + ", ".join(zero_targets[:40]) + (" …" if len(zero_targets) > 40 else ""))


def bucket_of(rel):
    parts = rel.split(os.sep)
    folder, name = parts[1], parts[-1]
    if folder == "modern":
        return name[:-4]
    return folder


if __name__ == "__main__":
    sys.exit(main())
