Script and Playbook for iOS App Store Previews

Ensure that videos are exactly 33 seconds *without* transitions. Inserting half-second transitions between clips shrinks the length by four seconds, to 29.

**Aim for 29 seconds, not 30.** 30 s is the App Store's hard *maximum*, and landing on it exactly leaves no margin. The evidence is on disk: `~/Desktop/Final/Konjugieren/English iPad 2 - 1200x1600.mov` is **30.015 s** — over the limit — while its siblings sit at 29.93–30.00. Nothing in the old "exactly 34 seconds → 30 seconds" arithmetic left room for a rounding error, so one file drifted past the cap unnoticed.

STATUS: Videos are in Final folder on desktop.

## App Store preview specifications

Sizes, which are **not** the screenshot sizes — conflating the two got all four of
Conjuguer's 2.0 previews rejected with *"The app preview dimensions should be:
886 × 1920px or 1920 × 886px"*:

| Device | Preview size | Notes |
|---|---|---|
| iPhone | **886 × 1920** | One file serves *every* current iPhone class (6.9″, 6.5″, 6.3″, 6.1″). |
| iPad | **1200 × 1600** | Covers 13″, 12.9″, 11″, 10.5″. |

Konjugieren's iPhone previews were already correct at 886 × 1920. Its iPad previews were
not: `English iPad 2.mov` and `German iPad 2.mov` are **2048 × 2732** — a screenshot size
— and had to be re-rendered as the `- 1200x1600.mov` variants. Record at native simulator
resolution and let the Final Cut project scale down; the project resolution is what gets
delivered.

Other requirements, and how the shipped files actually measure up:

| Requirement | Spec | Konjugieren 1.2 as shipped |
|---|---|---|
| Duration | 15 s min, 30 s max | 29.93–**30.015** s (one over) |
| H.264 profile/level | High, ≤ Level 4.0 | iPhone 4.0 ✅, iPad **5.0/5.1** |
| Video bit rate | 10–12 Mbps target | — |
| Audio | 256 kbps stereo AAC, 44.1/48 kHz | **125 kbps** |
| Tracks | video + audio | **3** (stray timecode track) |

Useful calibration: those level, audio, and stream-count deviations **shipped anyway**, so
App Store Connect does not enforce them the way it enforces dimensions. Treat them as
cleanup, not as blockers — that is exactly how `scripts/verify_store_media.sh` grades them.

To normalize any master into a fully conformant file:

```bash
# iPhone: W=886  H=1920      iPad: W=1200 H=1600
ffmpeg -y -i "master.mov" \
  -map 0:v:0 -map 0:a:0 -dn -sn \
  -vf "scale=${W}:-2,setsar=1,crop=${W}:${H}" \
  -frames:v 870 -shortest \
  -c:v libx264 -profile:v high -level 4.0 -pix_fmt yuv420p -r 30 \
  -b:v 11M -maxrate 12M -bufsize 24M \
  -c:a aac -b:a 256k -ar 48000 -ac 2 \
  -map_metadata -1 -movflags +faststart \
  "preview.mp4"
```

Three flags that are easy to miss:

- **`setsar=1`** — without it, `scale=W:-2` rounds the height to an even number and
  compensates by writing a **non-square pixel aspect ratio**. The file then reports
  `1200 × 1600` to any casual check while its *display* aspect is 512:683 instead of 3:4,
  and App Store Connect rejects it with the identical "dimensions are wrong" message a
  genuinely mis-sized file gets. Konjugieren's accepted previews are all `SAR 1:1`; check
  with `ffprobe -v error -select_streams v:0 -show_entries stream=sample_aspect_ratio,display_aspect_ratio -of csv=p=0 file.mov`.
- **`-dn`** — removes the timecode track; `-map 0:v:0 -map 0:a:0` alone leaves it.
- **`-frames:v 870`** — pins duration to exactly 29.000 s at 30 fps. Re-encoding a
  30.000 s master without it produced 30.014 s.

Verify before uploading:

```bash
scripts/verify_store_media.sh ~/Desktop/Final/Konjugieren
```

First Clip
Starts out at top of VerbBrowse view. Sort by frequency. Slowly scroll down for five seconds.
Label:
990 German verbs — from abbauen to zwingen, sorted alphabetically or by frequency.
990 deutsche Verben — von abbauen bis zwingen, alphabetisch oder nach Häufigkeit sortiert.

Second Clip
Starts out at top of werden's Verb view. Slowly scroll down for five seconds.
Label:
Every conjugation of every verb — fourteen conjugationgroups at a glance.
Jede Konjugation jedes Verb — vierzehn Conjugationgroups auf einen Blick.

Third Clip
Starts out on FamilyBrowseView. Wait two seconds. Tap Strong. Wait one second. Slowly scroll down for two seconds.
Label:
Strong, weak, mixed, -ieren — explore every verb family and prefix type.
Starke Verben, schwache Verben, gemischte Verben, Verben die auf -ieren enden — erkunde jede Verbfamilie und jeden Präfixtyp.

Fourth Clip
Starts out on QuizVew. Start. Type answer. Submit. Repeat once.
Label:
Quiz mode: Thirty timed questions to sharpen your conjugation skills.
Quizmodus: Dreißig Fragen auf Zeit, um deine Konjugationskenntnisse zu schärfen.

Fifth Clip
Because of a simulator bug, these clips require actual iPhone and iPad.
Starts out on InfoBrowseView just below dedication. Scroll down so that Präsens Indikativ is centered. Tap it. Slowly scroll down.
Label:
From Proto-Indo-European to modern German — the story behind every conjugationgroup.
Vom Proto-Indoeuropäischen bis zum modernen Deutsch — die Geschichte hinter jeder Conjugationgroup.