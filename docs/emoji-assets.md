# Emoji Assets — Why Some Emoji Ship as PNG Assets

## The bug

On iOS 26.3 (and likely the iOS 26 line generally), **no SwiftUI or UIKit text rendering path correctly resolves Apple Color Emoji glyphs for the regional flag tag sequence and certain other emoji**. Affected glyphs render as `[?]` tofu boxes — including, surprisingly, in standalone `Text("🐎")` views that should be the simplest possible case.

Every approach attempted produced `[?]`:

- `Text(AttributedString(...))` (the original code in `RichTextView.BodyTextView`)
- `Text + Text` composition with the emoji as a separate `Text(verbatim:)` chunk
- `NSAttributedString.draw(at:)` into a `UIGraphicsImageRenderer` context (rendered as a UIImage)
- `UILabel.layer.render(in:)` offscreen
- SwiftUI's `ImageRenderer` (its own snapshot pipeline)
- `UITextView` via `UIViewRepresentable`
- Standalone `Text("🐎")` in an `HStack` (the audit assumed this worked; it doesn't)

The bug appears to live in iOS 26's font-substitution pipeline for certain emoji codepoint sequences. macOS's CoreText, by contrast, handles these glyphs correctly.

## The fix

**Pre-render the affected emoji as PNG assets on macOS, ship them in `Assets.xcassets`, and substitute them inline at render time.**

### Affected emoji

| Codepoints | Glyph | Asset name |
|---|---|---|
| `U+1F3F4 U+E0067 U+E0062 U+E0065 U+E006E U+E0067 U+E007F` | 🏴󠁧󠁢󠁥󠁮󠁧󠁿 (England flag tag sequence) | `EmojiEnglandFlag` |
| `U+1F40E` | 🐎 (horse) | `EmojiHorse` |

The horse is a single codepoint, so its inclusion was unexpected. The hypothesis: iOS 26's emoji-rendering bug is contextual — when the tag-sequence flag fails in a text run, font fallback for nearby characters (including 🐎) breaks too.

### Markup syntax

In `Localizable.xcstrings`, wrap inline occurrences of the affected emoji with carets:

```
^🏴󠁧󠁢󠁥󠁮󠁧󠁿^   ^🐎^
```

`Konjugieren/Utils/StringExtensions.swift` parses `^...^` as a new `TextSegment.emoji(String)` case alongside the existing `~bold~`, `%link%`, `$conjugation$`, and `` `subheading` `` markers. The carets do not nest with other markup — `~^🐎^~` would render as bold text containing literal carets. (Verified safe at adoption time: `^` was unused in any localization value.)

### Renderer wiring

`Konjugieren/Views/RichTextView.swift` defines an `EmojiAsset` enum with the codepoint-to-asset-name lookup. `BodyTextView`'s per-segment `text(for:)` function, when it sees `.emoji(content)`, calls `EmojiAsset.assetName(for:)` and renders the result via SwiftUI's `Text("\(Image(name).renderingMode(.original))")` baseline-aligned interpolation. Unmapped emoji fall back to `Text(verbatim:)`, preserving the markup as a no-op.

The same lookup is used in:

- `Konjugieren/Views/RichTextView.swift` — `BodyTextView`, the long-form prose renderer
- `Konjugieren/Views/InfoBrowseView.swift` — `previewText`, the first-block previews on the Info tab
- `Konjugieren/Views/FamilyDetailView.swift` — `PrefixHeaderView`, the bullet rows in family detail screens

## Adding a new emoji

1. Append a `(assetName, emoji)` tuple to the `emojis` array in `scripts/render_emoji.swift`.
2. Run `swift scripts/render_emoji.swift` from the project root. The script renders the glyph via macOS's `NSAttributedString` → `NSImage` pipeline (where the bug doesn't exist), crops to the content bounds, and writes the PNG plus a `Contents.json` to `Konjugieren/Assets/Assets.xcassets/<assetName>.imageset/`.
3. Add the codepoint-to-asset-name mapping to `EmojiAsset.assetNames` in `Konjugieren/Views/RichTextView.swift`.
4. In `Localizable.xcstrings`, wrap each inline occurrence of the emoji with `^...^`. (Bullet emoji used as standalone characters in `PrefixHeaderView` use the asset name directly via `Image(...)` — see the existing England-flag and horse cases as a template.)
5. Build and verify on the simulator. The emoji should render as the glyph at body-font-baseline.

## Why the rendering script crops

The script renders at 24pt font and crops the result to the content's alpha bounding box. The crop is load-bearing for visual correctness:

SwiftUI's `Text("\(image)")` interpolation **baseline-aligns the bottom of the image to the surrounding text's baseline**. NSAttributedString's rendered bounding box includes the font's full line-height envelope (ascent + descent + leading), which positions the glyph in the middle of the box with whitespace below. Without cropping, the image bottom is below the visual emoji bottom, so the glyph sits visibly above the text baseline. Cropping to the alpha bbox makes the visual emoji bottom *be* the image bottom — and SwiftUI's baseline alignment then puts the emoji glyph at the text baseline naturally, where it reads as just another character.

## Why other paths don't work (recorded so future attempts don't repeat them)

- **`AttributedString` segments** — original code path. Hit the bug.
- **`Text + Text` composition** — SwiftUI flattens the chain into a single text run for layout, applying one font-fallback resolution. Per-segment `Text(verbatim: emoji)` still hits the bug.
- **`UIGraphicsImageRenderer` + `NSAttributedString.draw`** — offscreen rendering can't reach Apple Color Emoji for these glyphs. Renders `[?]` characters at default text color.
- **`UILabel.layer.render(in:)`** — same offscreen-rendering limitation as `UIGraphicsImageRenderer`.
- **SwiftUI `ImageRenderer`** — uses SwiftUI's own snapshot pipeline; same offscreen-rendering limitation.
- **`UITextView` via `UIViewRepresentable`** — renders on-screen via UIKit and resolves the emoji correctly *for the rendering pipeline*, but UITextView's accessibility behavior collapses the surrounding view hierarchy's AXTree, breaking accessibility throughout the screen. Also requires manual sizing to avoid horizontal clipping inside SwiftUI layouts.

## Risk: this might be specific to the iOS 26 simulator

The bug was first reported by Josh on the iOS 26 simulator and reproduced consistently throughout the May 2026 fix work. It's possible the bug is simulator-only and real iOS 26 devices render the emoji correctly — in which case the PNG assets are unnecessary on real devices, but harmless (they ship a few KB of additional assets). If a future iOS update fixes the underlying font issue, removing the workaround is straightforward: delete the imagesets, drop `EmojiAsset` and the `.emoji` switch arms in the renderers, and unwrap the `^...^` markup in `Localizable.xcstrings`.
