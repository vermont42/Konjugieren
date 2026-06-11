# Konjugieren App Store Nomination

Nomination type: **App Enhancements**. Submit ≥ 3 weeks before the scheduled public release of the new version.

The three texts below paste directly into the Description, Helpful Details, and Supplemental Materials fields in App Store Connect. Verify counts in App Store Connect's character counter before submitting — em-dashes and curly quotes can shift counts by a few characters.

---

## Description (≤ 1,000 chars)

Konjugieren teaches German verb conjugation. The app was created as a tribute to the developer's grandfather, Clifford Schmiesing (1904–1944), an Army doctor from German-speaking Minster, Ohio, who died serving in WWII Algeria.

This is the polish release. Every screen got a second pass: typography, micro-interactions, and iPad layouts that fill the screen.

The on-device Apple Intelligence tutor is retuned for German-UI users: aligned grammar terminology, localized refusal copy, and fallback UI when the model is unavailable.

Accessibility: VoiceOver switches between German and English pronunciation per UI element, mid-sentence, with semantic announcement of ablaut vowel changes. Careful VoiceOver treatment is rare in apps with multilingual content.

Literary excerpts from Goethe, Kafka, and Mann. A 3,000-word essay traces verb conjugation from Proto-Indo-European to modern German.

Bilingual EN/DE. iPad multitasking. Game Center. 990 verbs.

---

## Helpful Details (≤ 500 chars)

Built solo by Josh Adams, also creator of Conjuguer (French) and Conjugar (Spanish).

The Tutor isn't freeform chat: it calls the same Conjugator engine that the quiz uses, so every conjugation it cites comes from the engine, not the model's guess.

Version 1.2 adds the Rückumlaut weak verbs: bringen / brachte, denken / dachte, and kennen / kannte. These verbs have unexpected conjugations that trip up native and non-native speakers alike.

---

## Supplemental Materials (≤ 5 URLs)

Replace each placeholder with the live URL once the asset is hosted on racecondition.software (or, for TestFlight, the public join link).

1. **`konjugieren-verbs.pdf`** — https://racecondition.software/konjugieren-verbs.pdf
   1005-page printed reference. Every verb gets a full page: complete conjugation tables, etymology through Middle High German, Old High German, Proto-West Germanic, and Proto-Indo-European, plus a literary citation (Mann, Goethe, Luther, Grimm, et al.).

2. **Apple Intelligence tutor screen recording** — https://racecondition.software/ConjugationTutor.mov
   Short walkthrough of the on-device Apple Intelligence tutor explaining a conjugation error and drilling the weak form.

3. **Before/after iPhone UI gallery** — https://racecondition.software/konjugieren-ui-gallery/#iphone
   Side-by-side comparison of the launch-era UI vs. the May 2026 card-elevation overhaul.

4. **Before/after iPad UI gallery** — https://racecondition.software/konjugieren-ui-gallery/#ipad
   iPad equivalent of the iPhone gallery.

5. **TestFlight build link** — https://testflight.apple.com/join/FFFaBaWK

---

## Submission Status (as of 2026-05-20)

Konjugieren 1.2 (build 2) is uploaded to App Store Connect. Description, Helpful Details, screenshots, and App Preview videos are finalized in both English and German locales. Test Information is complete.

**Beta App Review approved.** The Public Link is live and populated in supplemental #5 above.

**Editorial nomination submitted** via App Store Connect's nomination form with all five supplemental URLs in place. Now in Apple's editorial review window.

**App Store Review** (submitted via Distribution tab) remains in Apple's queue: 1–5 days typical. When approved, the build enters "Pending Developer Release" because the release setting is "Manually release this version" — visibility stays under developer control.

**Scheduled public release: 2026-06-11** (22 days from nomination submission, just past the ≥ 3 weeks editorial lead-time minimum).

## Next Steps

1. **Wait for App Store Review approval** (1–5 days from upload). When approved, the build sits in "Pending Developer Release" — fully reviewed but not publicly visible.
2. **Hold the approved build until 2026-06-11**. Apple's editorial review window plays out during this period; no developer action is required.
3. **Manually release on 2026-06-11**: App Store Connect → version 1.2 page → "Release this version" button. Konjugieren 1.2 goes public at that moment.

---

## WWDC2026 Editorial Angle (for the next nomination)

The 1.2 nomination above is submitted and locked. This section is for the *next* nomination cycle. It captures how WWDC2026 strengthens Konjugieren's editorial case. See `docs/wwdc2026-platforms-sotu.md` for the full analysis.

**Apple keeps choosing language and education apps as Foundation Models exemplars.** The WWDC2026 Platforms State of the Union cited "educational apps like CellWalk" as a Foundation Models showcase; the WWDC2025 cycle showcased Grammo, a grammar-learning app (see `docs/platform-features-plan.md`). Konjugieren is a German-conjugation app whose Tutor already runs on the on-device Foundation Models framework, which places it squarely in the category Apple repeatedly spotlights. The 1.2 Description and Supplemental #2 (the Tutor screen recording) already lead with this; the next nomination should keep it front and center.

**The on-device-AI story is honest and grounded, which editorial review rewards.** Konjugieren's Tutor is not freeform chat: it calls the same Conjugator engine the quiz uses (already stated in Helpful Details), so its conjugations are computed, not guessed. "Privacy-preserving on-device intelligence, grounded in a real conjugation engine" is a clean, defensible editorial line.

### Forward-looking hooks (require adopting the 27-era APIs)

None of these ship in 1.2. They become available on the fall iOS 27 releases, and several require an Apple-silicon Mac to build (see the WWDC report, section 5). Each would strengthen a future nomination. Adopt first, then nominate the version that ships them; do not nominate on the promise.

- **Private Cloud Compute, at no cloud cost.** Re-lighting the two AI surfaces that ship dark in 1.0 (`explainError`, `recommendPractice`; see `docs/cloud-llm-tier.md`) through Apple's free Private Cloud Compute model would let the nomination claim frontier-level AI with Apple-grade privacy and no third-party data sharing. Strong, and uniquely on-brand for Apple's own infrastructure.
- **Image input plus on-device Vision OCR.** Photograph German text in the wild, extract it, then conjugate or explain it. A novel, demoable feature that connects the app to real-world German, and a screenshot-friendly one for the Supplemental Materials.
- **Dynamic Profiles and the Evaluations framework.** Less user-visible, but they signal serious, current adoption of the newest framework surface, which editorial and developer-relations reviewers notice.

### Timing

Apple's editorial appetite for apps demonstrating a new framework is highest around the release of that framework. A nomination for the version that adopts the 27-era Foundation Models capabilities, submitted in the window around the fall releases, aligns with that appetite. Keep the ≥ 3-week editorial lead-time rule (top of this doc) in mind when scheduling.

### Honest caveat

A nomination should describe only what ships in the nominated build. The strongest AI surfaces are dark in 1.0 for good reason: on-device hallucination on the long tail (see `docs/cloud-llm-tier.md`). Until they re-light, lean the AI pitch on the on-device Tutor that ships live, plus the App Intents / Siri / Spotlight integration and the VoiceOver work, all of which are real today.
