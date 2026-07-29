# G14 · verdict: refuted · grade: none

Essay line 187, English: "that primordial cloud of supernova-enriched gas from which the Solar
System was born."

## Why

Three things sink this finding, in ascending order of importance.

**First, Phase 1 did no research.** It says so: "The research behind this one is already done and
settled, so I spent no searches on it." Its entire basis is that Conjugar's cluster A adjudicated
"the same epithet." Its only two sources are this repo's own Phase 0 patch log and the essay's own
line 80. Nothing outside the project was consulted, so nothing outside the project constrains the
verdict.

**Second, it is not the same epithet.** The Conjugar-derived patch P3 changed *"supernova-gifted
elements"* at line 82. That phrase attributes the *elements themselves* to supernovae, and the
elements enumerated one sentence earlier at line 80 include gold and uranium, which core-collapse
supernovae do not make in the required quantity. That claim was wrong, and the patch was right.
Line 187 says something structurally different: not that the elements came from supernovae, but
that the *cloud was enriched by* supernovae. That is a non-exclusive statement about one enrichment
channel, and it is true. Reading the second as settled by the first is a category slip between
"X made all of this" and "X contributed to this."

**Third, the epithet is if anything the technically pointed one.** The single best-documented fact
about the presolar nebula's distinctness from ordinary interstellar gas is its short-lived
radionuclide inventory, above all 60Fe, and 60Fe traces specifically to nearby core-collapse
supernovae. Gounelle and Meynet 2012 conclude that "60Fe in the solar system was synthesized by a
handful of SNe." A reader told the cloud was "supernova-enriched" has been told something that a
meteoriticist would defend without qualification.

**And the claimed internal disagreement does not exist.** Phase 0's note says the two lines "now
disagree." They do not. Line 80, as patched, still reads "the rest blasted outward by supernovae,
the explosive deaths of stars." Supernovae are one of the named enrichers in the essay's own
opening account. The closing paragraph compresses a multi-channel account to its most vivid
channel, which is what a peroration does, and the very next clause at line 187 immediately
re-broadens it: "The heavy elements forged in dying stars became the Earth." No reader arriving at
line 187 has been told anything the essay contradicts.

Phase 0's inventory note is a to-do flag, not an adjudication. It correctly identified an echo
worth a look. The look is what this pass is, and the echo turns out to be sound.

## What is actually true

The presolar cloud was enriched by more than one process. Core-collapse supernovae produce the bulk
of the elements between oxygen and silicon; AGB winds produce the main s-process component and are
required to reproduce solar carbon and nitrogen; the r-process elements, gold and uranium among
them, come predominantly from neutron-star mergers with a contested supernova contribution. All of
that is right, and Phase 1's "What is actually true" section states it accurately.

What that section does not establish, and does not attempt to establish, is that "supernova-enriched
gas" is *false*. It is not. It is a true partial description. Multi-channel enrichment and
supernova enrichment are not competing claims; the second is a subset of the first. Phase 1's truth
section is correct and its application of that truth to the sentence is a non sequitur.

If anything, the astrophysics cuts mildly the other way. By mass, supernovae dominate metal
production in the solar neighborhood: core-collapse supernovae for oxygen, magnesium and silicon,
thermonuclear supernovae for most iron. Compressing the enrichment story to one word and choosing
"supernova" is the choice the yields tables support.

## Phase 1's replacement prose

> that primordial cloud of star-seeded gas from which the Solar System was born

Unnecessary, and a small loss. It does not introduce a factual error, and its markup is clean, since
no marker touches this clause in either language. But "star-seeded gas" is vaguer than what it
replaces without being more accurate, and it is oddly redundant in position: the sentence
immediately following already says "forged in dying stars," so the paragraph would say "star" three
times in two clauses. It also does not buy the generality it claims, since a neutron-star merger is
a collision of stellar remnants and "star-seeded" covers it no better than the phrase it replaces.

Applying it would additionally oblige a re-translation of the German at
`docs/verb_history_de.txt` line 153, which currently ships "supernova-angereichertem Gas." Paying a
translation cost for a phrase that was not wrong is the wrong trade.

## Strongest case for the finding, and my answer

The strongest case is editorial, not factual, and it is this: an essay that opens by carefully
enumerating four enrichment channels and closes by naming one of them is uneven, and the unevenness
is an artifact of process rather than intent, since the closing survived only because it sat in the
half Phase 0 was forbidden to touch. A careful editor revising the whole essay at once would
plausibly have harmonized the two.

My answer is that harmony of that kind is not owed here, and the specific harmony proposed is not
an improvement. Openings enumerate and perorations compress; that is a normal rhetorical shape, not
a defect. The compression selects a channel the essay has already introduced by name, so the reader
resolves it correctly without effort. And the sentence following the epithet performs the
broadening on its own. The case for the finding survives only as "an editor might have written it
differently," which is below the threshold even for a nitpick, since a nitpick is defined here as
something a specialist would flag. A specialist in presolar nucleosynthesis would not flag "the
cloud was supernova-enriched." She would agree with it.

## Sources

- Gounelle & Meynet, "Solar system genealogy revealed by extinct short-lived radionuclides in
  meteorites," Astronomy & Astrophysics 545 (2012).
  https://www.aanda.org/articles/aa/full_html/2012/09/aa19031-12/aa19031-12.html
  > "60Fe in the solar system was synthesized by a handful of SNe on the GMC (10 s of pc) scale on a
  > 5 − 10 Myr timescale." and "60Fe comes from the SNe of the first generation of stars, while 26Al
  > comes from the wind of a *single* massive star belonging to a second star generation."

- Rauscher & Patkós, "Origin of the Chemical Elements," NASA/IPAC Extragalactic Database Level 5
  knowledgebase. https://ned.ipac.caltech.edu/level5/Sept16/Rauscher/Rauscher4.html
  > "AGB stars produce the majority of the s-process nuclei, the so-called main component." and, on
  > the heavy r-process elements, "the site of the r-process is controversial. Mostly favored are
  > core-collapse supernovae."

- Karakas & Lattanzio, "The Dawes Review 2: Nucleosynthesis and Stellar Yields of Low- and
  Intermediate-Mass Single Stars," PASA 31 (2014), arXiv:1405.0062.
  https://arxiv.org/pdf/1405.0062
  > Core-collapse supernovae are credited with the bulk of the elements from oxygen through silicon,
  > while AGB models are described as essential to reproducing the solar-system abundances of carbon,
  > nitrogen, and the neutron-rich isotopes of oxygen and neon.

- Konjugieren, `docs/verb_history.txt` line 80 (already patched by Phase 0):
  > "Generations of dying stars had seeded the cloud with heavy elements forged in stellar furnaces,
  > some shed quietly on the winds of aging giants, the rest blasted outward by supernovae, the
  > explosive deaths of stars."

  Cited here for the point that supernovae remain a named enricher in the essay's own opening, so
  line 187 echoes it rather than contradicting it.

## Blocked sources

None. The two search result sets and both fetched pages returned normally. The ScienceDirect and
Science.org items surfaced by search were not fetched, since the open-access sources above settled
the question.
