# Konjugieren App Store Nomination

Nomination type: **App Enhancements**. Submit ≥ 3 weeks before the scheduled public release of the new version.

The three texts below paste directly into the Description, Helpful Details, and Supplemental Materials fields in App Store Connect. Verify counts in App Store Connect's character counter before submitting — em-dashes and curly quotes can shift counts by a few characters.

---

## Description (≤ 1,000 chars)

Konjugieren teaches German verb conjugation. The app was created as a tribute to the developer's grandfather, Clifford Schmiesing (1904–1944), an Army doctor from German-speaking Minster, Ohio, who died serving in WWII Algeria.

Version 1.2 is the polish release. Following 1.1's card-elevation overhaul, every screen got a second pass: typography, micro-interactions, and iPad layouts that fill the screen.

The on-device Apple Intelligence tutor (introduced in version 1.1; fully private, no cloud calls) is retuned for German-UI users: aligned grammar terminology, localized refusal copy, and fallback UI when the model is unavailable.

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

5. **TestFlight build link** — *URL pending Beta App Review approval (see Submission Status below)*
   Optional; explicitly recommended in Apple's nomination docs for pre-release nominations.

---

## Submission Status (as of 2026-05-17)

Konjugieren 1.2 (build 2) is uploaded to App Store Connect. Description, Helpful Details, screenshots, and App Preview videos are finalized in both English and German locales. Test Information is complete.

Two parallel reviews are in Apple's queue:

- **App Store Review** (submitted via Distribution tab): 1–5 days typical. When approved, the build enters "Pending Developer Release" because the release setting is "Manually release this version" — visibility stays under developer control.
- **Beta App Review** (auto-submitted when build 1.2 (2) was assigned to the External TestFlight group "Public"): 24–48 hours typical. When approved, the Public Link toggle in the group's Settings tab becomes functional and generates the shareable TestFlight URL needed for supplemental #5.

## Next Steps

1. **Wait for Beta App Review approval** (~1–2 days). The External group's build status will change from "Waiting for Review" to something like "Ready to Test"; an email arrives at the Feedback Email address registered in Test Information.
2. **Enable the Public Link**: App Store Connect → TestFlight → Public group → Settings tab → toggle Enable Public Link. The URL is generated immediately.
3. **Paste the URL into supplemental #5 above**, replacing the *URL pending…* placeholder.
4. **Submit the editorial nomination** via App Store Connect's nomination form, using the five supplemental URLs above (1005-page PDF, Tutor screen recording, iPhone gallery, iPad gallery, TestFlight Public Link).
5. **Wait for App Store Review approval** (1–5 days, running in parallel with Beta App Review). When approved, the build sits in "Pending Developer Release" — fully reviewed but not publicly visible.
6. **Hold the approved build for ~3 weeks** to let Apple's editorial review window play out (per the nomination spec's "Submit ≥ 3 weeks before the scheduled public release" guideline at the top of this doc).
7. **Manually release** when the editorial window has closed: App Store Connect → version 1.2 page → "Release this version" button. Konjugieren 1.2 goes public at that moment.
