// Renders emoji glyphs to PNG assets in Konjugieren/Assets/Assets.xcassets.
//
// Why this script exists: iOS 26 simulators (and possibly real devices on this
// iOS) cannot render certain Apple Color Emoji glyphs through any text path:
// SwiftUI Text, AttributedString, UILabel, UITextView, and even SwiftUI's
// ImageRenderer all produce [?] tofu glyphs for the regional flag tag sequence
// (🏴󠁧󠁢󠁥󠁮󠁧󠁿) and 🐎. macOS's NSAttributedString → NSImage rendering pipeline
// resolves the glyphs correctly, so we render PNGs once on the host and ship
// them as image assets. See docs/emoji-assets.md for the full story.
//
// Run from the project root: swift scripts/render_emoji.swift
//
// To add a new emoji, append a (assetName, emojiString) tuple to `emojis`
// below, run the script, and add the assetName → emojiString mapping to
// EmojiAsset in Konjugieren/Views/RichTextView.swift. Wrap occurrences of
// the emoji in Localizable.xcstrings with the ^...^ markup so the parser
// emits .emoji segments for them.

import AppKit

let outDir = "Konjugieren/Assets/Assets.xcassets"

// The three country flags are regional-indicator pairs, which iOS 26 fails on the same way
// it fails the England tag sequence: each renders as two tofu boxes rather than one glyph.
// They render correctly on a physical device, so this was deferred for months; it was an App
// Store screenshot sweep that forced the issue, because the sweep runs on the simulator and
// SettingsView's Regional Variety picker is one of the nine captured screens. The double-width
// tofu also truncated "North 🇩🇪" to "North…", so the bug degraded the layout as well as the glyph.
let emojis: [(String, String)] = [
  ("EmojiAustrianFlag", "🇦🇹"),
  ("EmojiEnglandFlag", "🏴󠁧󠁢󠁥󠁮󠁧󠁿"),
  ("EmojiGermanFlag", "🇩🇪"),
  ("EmojiHorse", "🐎"),
  ("EmojiSwissFlag", "🇨🇭"),
]

func contentBounds(of rep: NSBitmapImageRep) -> NSRect {
  let width = rep.pixelsWide
  let height = rep.pixelsHigh
  var minX = width
  var maxX = -1
  var minY = height
  var maxY = -1
  for y in 0..<height {
    for x in 0..<width {
      guard let color = rep.colorAt(x: x, y: y), color.alphaComponent > 0 else { continue }
      if x < minX { minX = x }
      if x > maxX { maxX = x }
      if y < minY { minY = y }
      if y > maxY { maxY = y }
    }
  }
  guard maxX >= minX, maxY >= minY else { return .zero }
  return NSRect(x: minX, y: minY, width: maxX - minX + 1, height: maxY - minY + 1)
}

for (name, emoji) in emojis {
  let font = NSFont.systemFont(ofSize: 24)
  let attrs: [NSAttributedString.Key: Any] = [.font: font]
  let attrStr = NSAttributedString(string: emoji, attributes: attrs)
  let layoutSize = attrStr.size()

  let image = NSImage(size: layoutSize)
  image.lockFocus()
  attrStr.draw(at: .zero)
  image.unlockFocus()

  guard let tiff = image.tiffRepresentation,
        let rep = NSBitmapImageRep(data: tiff) else {
    print("\(name): failed to read rendered bitmap")
    continue
  }

  let bounds = contentBounds(of: rep)
  guard bounds.width > 0, bounds.height > 0,
        let cgImage = rep.cgImage,
        let cropped = cgImage.cropping(to: bounds) else {
    print("\(name): failed to crop to content bounds")
    continue
  }
  let croppedRep = NSBitmapImageRep(cgImage: cropped)
  guard let pngData = croppedRep.representation(using: .png, properties: [:]) else {
    print("\(name): failed to encode PNG")
    continue
  }

  let imagesetDir = "\(outDir)/\(name).imageset"
  try? FileManager.default.createDirectory(atPath: imagesetDir, withIntermediateDirectories: true)
  let pngURL = URL(fileURLWithPath: "\(imagesetDir)/\(name).png")
  try? pngData.write(to: pngURL)

  // Bootstrap Contents.json only for a new imageset, and never touch one that exists.
  // Xcode rewrites these files itself: opening the catalog adds empty 1x/2x slot entries
  // alongside the 3x one and terminates the file with a newline. Regenerating unconditionally
  // therefore reverted Xcode's edits on every run, so re-rendering one new emoji produced a
  // diff touching every imageset ever added. Only the 3x entry carries meaning here, and
  // deciding the rest is Xcode's business.
  let contentsURL = URL(fileURLWithPath: "\(imagesetDir)/Contents.json")
  if !FileManager.default.fileExists(atPath: contentsURL.path) {
    let contents = """
    {
      "images" : [
        {
          "filename" : "\(name).png",
          "idiom" : "universal",
          "scale" : "3x"
        }
      ],
      "info" : {
        "author" : "xcode",
        "version" : 1
      }
    }

    """
    try? contents.write(to: contentsURL, atomically: true, encoding: .utf8)
  }
  print("\(name): wrote \(pngData.count)-byte PNG (\(Int(bounds.width))×\(Int(bounds.height)) px) at \(pngURL.path)")
}
