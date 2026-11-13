# How Often Each Conjugationgroup Occurs

The verb page orders its tables by these counts: the simple conjugationgroups first, then the
compound ones, each block from most to least frequent. Measured on 2026-11-12 for Phase 7 of
[`plans/browse-and-verb-implementation.md`](../plans/browse-and-verb-implementation.md), as Josh's
verdict on idea B3 in [`browse-and-verb-ideas.md`](browse-and-verb-ideas.md) asked.
`ConjugationTable` in `Konjugieren/Models/ConjugationTable.swift` holds the resulting order.

To reproduce:

```bash
python3 scripts/count_conjugationgroups.py               # builds ConjugationMapTool first
python3 scripts/count_conjugationgroups.py --examples imperativ   # the words behind one count
```

## The Sample

The German texts in four folders of `corpus/`, as the plan names them, about 14 MB in all. The
English translations are skipped. The texts are gitignored; [`corpus/README.md`](../corpus/README.md)
lists them.

| Folder | What it holds | Register |
|---|---|---|
| `modern` | Goethe, Grimm, Kafka, Mann, Nietzsche, the Luther Bible, the Grundgesetz, the Weimar constitution, the Peace of Westphalia | Literary and legal; the Bible is a third of the sample |
| `government` | Seven federal reports | Administrative |
| `government2` | Three Bundestag plenary protocols and nine short agency pages | Mostly parliamentary speech |
| `technology` | BSI guides and German Wikipedia articles | Technical |

## The Method

`ConjugationMapTool --cells-json` writes every one-word conjugation of every verb in the app with
its conjugationgroup and its verb's Perfekt auxiliary. The script reads that table, so it and the
verb page agree on what each conjugation is.

1. **Cleaning.** Project Gutenberg boilerplate is dropped. The Bundestag protocols, which are
   two-column `pdftotext -layout` pages, are split into their columns. Words hyphenated across a
   line break are rejoined.
2. **Which words can be verbs.** German capitalizes nouns, so a capitalized word mid-sentence is
   never counted. A capitalized word at the start of a sentence counts unless the corpus
   capitalizes it mid-sentence more often than not (Ziel, Reich, Werte are nouns, not Imperativ
   forms of zielen, reichen, werten). A stoplist removes about fifty words that are nearly always
   something else: während, the articles einen and eine, the possessives meine and seine, and
   particles such as halt and mal.
3. **Compounds.** Within a clause, a form of haben or sein paired with a participle is a Perfekt
   or Plusquamperfekt, in the mood of the auxiliary (hat, habe, hatte, hätte). The pairing counts
   only if the participle's verb takes that auxiliary, which tells "ist gegangen" (Perfekt) from
   "ist gemacht" (Zustandspassiv). A form of werden paired with an infinitive is a Futur (wird,
   werde, würde). werden with a participle is a passive, and werden with a participle and haben or
   sein is a Futur II. The page shows neither, so they are counted apart.
4. **Simple conjugationgroups.** Every verb word left over counts under its own conjugationgroup.
   Where a spelling belongs to two, the indicative wins unless a rule says otherwise: habe and
   werde are Konjunktiv I unless ich stands beside them, and an -e form beside er, es, or man is
   Konjunktiv I. An Imperativ must start its sentence, must not be followed by a pronoun, and, if
   its spelling is also another conjugation (geht, mache), must end in an exclamation mark.
   Luther's archaic ihr forms (sehet, wisset), which match the Konjunktiv I spelling, are dropped
   rather than credited to it.

## The Results

Shares within each block. "Balanced" averages the four folders' shares, so that the Bible does not
outvote the other registers. It is the measure the page uses (Josh's choice, 2026-11-12).

### Simple

| Conjugationgroup | modern | government | government2 | technology | Pooled | Balanced |
|---|---:|---:|---:|---:|---:|---:|
| Präsens Indikativ | 59% | 67% | 81% | 75% | 64% | 70.5% |
| Präteritum Indikativ | 33% | 14% | 8% | 7% | 26% | 15.3% |
| Perfektpartizip | 3% | 13% | 6% | 11% | 5% | 8.5% |
| Präsenspartizip | 1% | 6% | 2% | 5% | 2% | 3.5% |
| Präteritum Konjunktiv II | 2% | 1% | 2% | 1% | 2% | 1.5% |
| Präsens Konjunktiv I | 2% | 0% | 0% | 0% | 1% | 0.6% |
| Imperativ | 0% | 0% | 0% | 0% | 0% | 0.1% |

Pooled counts: 140,184; 56,090; 10,767; 3,540; 3,887; 2,869; 594.

### Compound

| Conjugationgroup | modern | government | government2 | technology | Pooled | Balanced |
|---|---:|---:|---:|---:|---:|---:|
| Perfekt Indikativ | 46% | 61% | 72% | 65% | 52% | 61.0% |
| Futur Indikativ | 25% | 31% | 12% | 33% | 23% | 25.4% |
| Plusquamperfekt Indikativ | 17% | 5% | 2% | 0% | 13% | 5.9% |
| Futur Konjunktiv II | 2% | 2% | 5% | 2% | 3% | 3.0% |
| Plusquamperfekt Konjunktiv II | 3% | 1% | 5% | 0% | 4% | 2.3% |
| Perfekt Konjunktiv I | 5% | 0% | 3% | 0% | 4% | 2.0% |
| Futur Konjunktiv I | 1% | 0% | 0% | 0% | 1% | 0.4% |

Pooled counts: 10,384; 4,531; 2,608; 546; 704; 851; 221. Pooled, the three close ones reverse
(Perfekt Konjunktiv I, Plusquamperfekt Konjunktiv II, Futur Konjunktiv II), because literature
and the Bible are full of indirect speech. The technology folder holds only 43 compounds, so its
column is noise.

Counted apart: 4,708 passives and 62 Futur II.

## The Participles

The Perfektpartizip rows above count a participle that stands alone or as an adjective (die
geschriebenen Briefe, "Gesagt, getan"), not one inside a compound. Counting every participle,
including the 14,547 inside a Perfekt or Plusquamperfekt and the 4,770 inside a passive or Futur
II, would put the Perfektpartizip second in three of the four folders and third pooled. Josh chose
the standalone count on 2026-11-12. Later the same day he moved both participles to the end of
the simple block, below the Imperativ, for the page's look: a one-line card between six-row tables
broke the rhythm. That departs from frequency order on purpose, as keeping the compound block
below the simple one already does.

## The Page's Order

Simple: Präsens Indikativ, Präteritum Indikativ, Präteritum Konjunktiv II, Präsens Konjunktiv I,
Imperativ, then the participles, Perfektpartizip and Präsenspartizip.

Compound: Perfekt Indikativ, Futur Indikativ, Plusquamperfekt Indikativ, Futur Konjunktiv II,
Plusquamperfekt Konjunktiv II, Perfekt Konjunktiv I, Futur Konjunktiv I.

Only the verb page uses it. Info, the quiz, and the shortcuts keep their own order.

## Known Errors

Every figure is an estimate, and the errors run in known directions. None is large enough to move
the top three of either block.

- **The Imperativ is undercounted.** Weak verbs' du Imperativ (mache, sage) is spelled like the ich
  Präsens and counts as Präsens unless its sentence ends in "!". 627 sentences start with such a
  word and no pronoun; counting them all would raise the Imperativ to about 0.4%, still last. The
  sample is written text, and commands are rarer in writing than in speech.
- **Weak Konjunktiv II is invisible.** machte is both Präteritum Indikativ and Konjunktiv II, and
  counts as the indicative. Strong and modal forms (wäre, hätte, könnte, möchte, käme) carry the
  Konjunktiv II count.
- **Participles that look finite go to the finite group.** besucht and erklärt are both a
  participle and an er Präsens, and erklärte is both an adjective and a Präteritum. Outside a
  compound, the finite reading wins, which lowers the Perfektpartizip and raises the Präsens and
  Präteritum.
- **A compound split by a comma is missed.** "hat, wie er sagt, gesehen" loses its Perfekt, and
  each part counts as a simple conjugation.
- **Old spellings beyond ß are missed.** muß and daß fold to muss and dass, but gieng and thun do
  not match.
