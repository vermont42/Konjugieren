# FM Tutor Screen Recording Playbook

A practical plan for capturing the 15–30 second walkthrough of the on-device Foundation Models Tutor for the App Store nomination (supplemental material #2 in [`docs/nomination.md`](nomination.md)).

## Goal

A silent, 25-second clip (with a 15-second cut available) that shows three things in sequence:

1. The Tutor explaining a real conjugation error in real time
2. The streaming text feel that proves it's a live language model, not a static answer
3. A drill of the weak form, with the user getting it right after the explanation

If any one of those beats fails to land, the recording isn't doing its job — the reviewer has 25 seconds and won't rewatch.

## Hard constraints (read first)

| Constraint | Why |
|---|---|
| **Must record on a real Apple-Intelligence-capable iPhone** (iPhone 15 Pro or newer, on iOS 26.3+) — or an Apple Silicon Mac on macOS 26+ running the app. | iOS 26.3.1 tightened the host-eligibility gate. On Intel-Mac–hosted simulators, `SystemLanguageModel(guardrails:).availability` resolves to `.unavailable(.deviceNotEligible)` and the Tutor row, ErrorExplainerView card, and onboarding-Tutor page silently don't render. See the "App-specific friction: Apple Intelligence Tutor host-eligibility" section in `CLAUDE.md`. |
| **Record in English UI**, with the Tutor responding in English about a German verb. | App Store reviewers read English; the explanation is for them. The verb being learned is German — that's the authentic learner experience. |
| **No audio**. | Default-muted playback in the App Store Connect review UI. The streaming text is the demo. |
| **15–30 seconds, target 25.** | Per the nomination spec; 25s leaves headroom for breathing and a brief title card if desired. |

## Pre-flight checklist (device side)

Do these in order. Each one rules out a class of avoidable retake.

1. **App version**: Install the May 2026 build with the Tutor feature.
2. **Onboarding complete**: Walk through onboarding once on this device — otherwise the onboarding-Tutor page may intercept the flow.
3. **Language set to English**: Settings → Konjugieren → Language → English. Verify the Verbs tab heading reads "Verbs" not "Verben".
4. **Review prompt drained**: The custom review prompt in `Settings.swift` is gated by `promptActionCount` + `lastReviewPromptDate`. If it might fire on launch, tap "Not Now" once before recording starts (cooldown blocks subsequent prompts). Alternative: uninstall + reinstall for a clean slate (`xcrun simctl uninstall <UDID> biz.joshadams.Konjugieren` for the simulator equivalent).
5. **Tutor chat history cleared**: Settings (in-app) or Tutor view → Delete Chat History. A blank Tutor view starts clean. (Existing history would make the streaming response harder to read against prior turns.)
6. **Device chrome**: Charge to ≥ 90%, set time to a clean number (`9:41` is Apple's screenshot convention), connect to Wi-Fi (even though FM is on-device, the App Store-style polish matters), and enable Do Not Disturb so notifications don't appear mid-take.
7. **AssistiveTouch off**, **screen-record indicator hidden** (it won't show in the recording itself, but tapping it is one less risk).
8. **Verify the Tutor is actually available** before rolling: open InfoBrowseView, confirm the Tutor row renders (not hidden, not greyed). If the row isn't there, *stop* — your device isn't eligible and the recording can't proceed.

## The scenario: `singen` and the over-regularization mistake

The verb is `singen` (to sing). The user is asked for the **Präteritum 1. Person Singular** and types `singte` — the regular weak-verb past form they would get from rule-following. The correct answer is `sang` (i→a ablaut, Class III strong verb).

Why this verb specifically:

- **English cognate is one-to-one**: sing / sang / sung maps to singen / sang / gesungen. The reviewer's English brain recognizes the pattern in the first second.
- **The error is the textbook beginner mistake** in German verb learning — over-applying the weak-verb `-te` ending to a strong verb. It's not a contrived stumble.
- **Ablaut highlight pays off visually**: when "sang" appears, the `a` is uppercased in your conjugator output (per the `expectConjugation` mixed-case convention), which the eye reads as "*this* is the changed letter." Free pedagogical theater.
- **The Tutor's natural explanation references the i→a→u pattern, which is also the title of one of your conjugationgroup articles** (the strong-verb ablaut section). The feature ties back to the content.

## Shot list (25-second cut)

Times are *target* — actual streaming will vary by 2–3 seconds either direction; that's fine. The shot order is locked, the timing is approximate.

| t | What's on screen | What you do |
|---|---|---|
| **0.0 – 2.5** | App launch into Verbs tab. (Optional: 0.5s title card "Conjugation Tutor" overlaid on first frame in post.) | Tap **Quiz** tab. |
| **2.5 – 5.0** | Quiz config screen. | Set difficulty to **Regular**, tap **Start**. |
| **5.0 – 8.0** | Quiz prompt appears: `singen` infinitive at title weight, target conjugationgroup label "Präteritum, 1. Person Singular", pronoun "ich". | Tap the text field. |
| **8.0 – 12.0** | Keyboard appears. | Type `singte`. Pause for half a beat — let the wrong answer feel deliberate, not a slip. Tap **Submit** / Return. |
| **12.0 – 14.0** | Red wrong-answer state. "Correct Answer: s**A**ng" with the `a` uppercased per the ablaut convention. ErrorExplainerView card slides up below the answer. | Let it sit 1 beat so the reviewer registers the error. |
| **14.0 – 15.5** | ErrorExplainerView card visible — short summary text. | Tap the card to expand into TutorView, *or* (if the card has an "Ask Tutor" affordance) tap that. |
| **15.5 – 22.0** | TutorView open, a question pre-filled or auto-asked along the lines of "Why is *singte* wrong?". The model begins streaming a response. **This is the money beat.** A typical response: "*singen* is a strong verb of the i→a→u ablaut class — same pattern as English *sing, sang, sung*. The Präteritum is *sang*, not *singte*. Weak verbs take *-te*; strong verbs change their stem vowel instead." | Don't tap. Let it stream. Hold still. |
| **22.0 – 24.5** | Tap **Get Suggestions** (or equivalent "Practice this" button). A suggested drill appears: "Try *gesungen* — the Perfektpartizip." | Tap the suggestion. |
| **24.5 – 25.0** | Quiz returns with the suggested form. User types `gesungen`. Green correct state. Smile cut. | Done. Stop recording. |

If the model's response is much shorter than expected, the clip ends naturally earlier — closer to 18–20 seconds. That's still inside spec (15–30s).

If the response is much longer than expected, **don't wait for it to finish**. The reviewer doesn't need the whole lecture; they need to see streaming and substance. Cut at the end of the second sentence in post.

## Handling Foundation Models non-determinism

The model's exact words will change every take. Plan for it:

- **Shoot 8–12 takes.** Two or three will be unusable (overly long response, an awkward phrasing, the model pausing). One will be perfect. Don't be precious about the first take.
- **Pre-roll the same prompt twice before recording starts** to see what a typical response looks like for *this* device, *this* OS version, *this* day. Token sampling drifts subtly over time.
- **The shape that wins**: a response that mentions either (a) "strong verb" or "weak verb" terminology, (b) the i→a→u ablaut pattern, *or* (c) the English cognate. Any one of those lands the point. If a take has none of the three, retake.
- **What to discard immediately**: responses that hedge ("In some dialects…"), apologize ("I'm sorry you got that wrong"), or get the linguistics wrong. The model is usually accurate but not always; verify the content of your final take with the actual conjugation tables.
- **What to do if the model is unavailable mid-shoot**: the gate can flip if the device thermal-throttles or Apple Intelligence is in a "preparing" state. Plug in, wait two minutes, retry. If it persists, switch devices.

## Recording mechanics

| Question | Answer |
|---|---|
| **How to record on iOS** | Control Center → Screen Recording. iOS 26 produces a clean H.264 MP4 in Photos. Trim there or in iMovie. |
| **Mirroring to Mac for higher quality?** | Optional. QuickTime → New Movie Recording → select iPhone via USB. Slightly sharper export, adds a known iPhone bezel chrome in some workflows. Not required. |
| **Crop to portrait** | The recording captures the full screen. For the App Store, leave it portrait at the device's native aspect ratio. Don't letterbox into 16:9. |
| **Subtitles?** | No — the Tutor's streaming text *is* the on-screen text. Adding subtitles double-layers. |
| **Title card** | Optional 0.5-second cold-open frame: "Conjugation Tutor · Apple Intelligence" centered on the app's standard background. Helps a reviewer who skips the description. Don't add anything longer. |
| **Background music** | No. Silent. Audio-off review default; music adds nothing and a song-rights worry is not worth carrying. |
| **Export specs** | H.264 MP4, native resolution (1290×2796 for iPhone 15/16 Pro Max, 1320×2868 for iPhone 17 Pro Max), 30fps, max 30s. |

## Deliverable & hosting

- **Filename**: `konjugieren-tutor-demo.mp4`
- **Hosting**: `https://racecondition.software/konjugieren-tutor-demo.mp4` (mirrors the `/konjugieren-verbs.pdf` and `/konjugieren-ui-gallery/` convention from `docs/nomination.md`).
- **Replace the *URL TBD*** entry in `docs/nomination.md` once the file is live.

## The 15-second cut

If the App Store form's preview is the only place a reviewer watches and 25s feels long, here's the 15s shape (the same shot list, two beats removed):

- **0.0 – 2.0**: Quiz prompt for `singen`, Präteritum.
- **2.0 – 5.0**: Type `singte`, submit, wrong.
- **5.0 – 14.0**: Tap ErrorExplainer card, Tutor streams the explanation. **Hold for the full streaming response** — this is now the entire payload of the video.
- **14.0 – 15.0**: End on the final word of the explanation, dissolve to black.

The drill beat is dropped. The story becomes "real mistake → AI explanation streams in." Less complete, but still strong.

## Why this plan and not "just film it"

The Tutor is one feature of one screen; the recording is the App Store reviewer's only chance to *see* on-device Foundation Models doing something interesting in your app. Three things make or break it:

1. **The scenario is recognizable to the reviewer in the first 3 seconds.** `singen` accomplishes this; an obscure modal verb wouldn't.
2. **The streaming text is visibly streaming.** That's how the reviewer knows it's a live model and not a static help string. Don't accelerate or post-process the streaming.
3. **The drill closes the loop.** A model that explains is interesting; a model that *then* tailors a practice exercise to the specific mistake is what "tutor" actually means.

Hit those three, and 25 seconds is enough. Miss any one, and 60 seconds wouldn't help.
