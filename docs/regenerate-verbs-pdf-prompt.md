# Regenerate `konjugieren-verbs.pdf` — session prompt

Self-contained prompt for a fresh Claude Code session tasked with regenerating the printed verb reference PDF. Open the new session at the project root and paste the prompt below.

---

Regenerate `konjugieren-verbs.pdf`. Apply only the changes listed below; preserve everything else exactly.

Project root: `/Users/josh/Desktop/workspace/Konjugieren`
Generator playbook: [`docs/pdf.md`](pdf.md) — read first; contains the prerequisite steps, the generator command, and the title-page template
Current PDF: `/Users/josh/Desktop/apps/Konjugieren/konjugieren-verbs.pdf` (1,018 pages, 989 verbs)

The PDF will be linked as Supplemental Material for an upcoming App Store featuring nomination — clean replacement, no rendering regressions.

## Changes

1. **Title-page byline.** Currently renders "Josh Adams and Claude Code." Change to **"Josh Adams"** only. The byline string lives in `scripts/generate_verb_pdf.py` (per `docs/pdf.md` the title page renders as `Konjugieren / N German Verbs / Josh Adams and Claude Code`).

2. **Title-page subtitle.** Currently renders "989 German Verbs" (templated as "N German Verbs"). Change to a **literal "Nearly 1,000 German Verbs"** — do not parameterize from the verb count. (Decision from a prior session: keeps a future "1,000 verbs" milestone available as a separate marketing beat once the count actually reaches 1,000.)

3. **Verb coverage.** Total **990 verbs**. The previous PDF covered 989; at least one new verb exists in the project's verb data that isn't yet in the PDF. Re-run the JSON export test (`VerbExportTests/exportAllVerbsAsJSON()`, per `docs/pdf.md`) to refresh `/tmp/konjugieren-export.json` — new verbs will be picked up automatically by the generator.

## Must preserve

- **Red rendering of irregularities.** Ablaut vowel changes inside conjugations render in red. Verify on a strong verb such as `singen` (i→a→u) or `werden`.
- **Page breaks between verb entries.** Multi-page verbs like `sein` and `haben` span 2–3 pages; the next alphabetical verb starts on a fresh page after them. Do not break this behavior.
- **Fraktur title page.** "Konjugieren" on the cover stays in blackletter/Fraktur (UnifrakturMaguntia-Book.ttf, per `docs/pdf.md`); body pages stay in serif.

## Workflow

Per [`docs/pdf.md`](pdf.md):

1. Verify Fraktur font at `/tmp/UnifrakturMaguntia-Book.ttf` (download if missing — command in `pdf.md`).
2. Re-run the JSON export test to refresh `/tmp/konjugieren-export.json` so the new verb(s) are included.
3. Edit `scripts/generate_verb_pdf.py` for the byline and subtitle changes.
4. Run `python3 scripts/generate_verb_pdf.py` — outputs to `/tmp/konjugieren-verbs.pdf`.
5. Copy the output over the existing file at `/Users/josh/Desktop/apps/Konjugieren/konjugieren-verbs.pdf`.

## Done when

- [ ] Cover reads "Konjugieren" (Fraktur) / "Nearly 1,000 German Verbs" / "Josh Adams" — no "and Claude Code" anywhere in the document
- [ ] Body covers all 990 verbs in the project's data, alphabetized as before
- [ ] Spot-check a strong verb's page: red ablaut letters still render
- [ ] Spot-check `sein`: multi-page entry ends, next verb starts on a fresh page
- [ ] PDF copied to `/Users/josh/Desktop/apps/Konjugieren/konjugieren-verbs.pdf`, overwriting the existing file
