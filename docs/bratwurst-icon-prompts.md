# Bratwurst Icon — Nano Banana Prompts

The game currently uses the hotdog emoji (`🌭`) for bratwurst in two gameplay roles: a health-restoring power-up (`PowerUpKind.bratwurst`) and the Bratwurstkette (sausage chain). These three prompts produce a bratwurst icon harmonious with the existing illustrated-icon family (Hat, Bundestag, Pretzel, Stein, Dachshund, Clock, Nutcracker).

## Shared Visual DNA of Existing Icons

All existing icons share: **bold dark outlines**, **cartoon/illustrated style** (not photorealistic), **centered on solid black background**, **warm palette** (golden-ambers, browns, reds, greens), **German-flag colors** woven in (red, gold/yellow, black), **clear silhouette readable at 30px**, **square 1024x1024 format**.

The custom colors are: **customRed** = `#DD0000` (221, 0, 0) and **customYellow** = `#FFCE00` (255, 206, 0).

---

## Prompt 1: Anthropomorphic Bratwurst in Lederhosen (Power-Up Character)

> A cheerful cartoon bratwurst character standing upright on two stubby legs, centered on a solid black background. The bratwurst has a plump, gently curved body with golden-brown skin showing subtle grill marks. It has a cute smiling face with simple round eyes and a cheerful grin. It wears traditional Bavarian lederhosen — brown leather shorts with ornamental stitching and suspender straps decorated in red (#DD0000) and gold (#FFCE00). Small brown leather boots with gold buckles on its feet. One arm waves hello while the other gives a thumbs-up. Bold dark outlines on every element. Cartoon illustrated style — flat color with gentle shading, matching a family of icons that includes a pretzel character in lederhosen, a green Bavarian hat with feather, and a Reichstag dome in stained-glass style. Square 1024x1024 format. Color palette: warm golden-amber and toasted-brown tones for the bratwurst body, chocolate brown for the lederhosen, red (#DD0000) and bright gold-yellow (#FFCE00) for accent details, matching the German flag. Strong clear silhouette that reads well when scaled down to 30x30 pixels.

**Concept:** Matches the Pretzel's whimsical personality. Friendly, inviting — perfect for a health-restoring collectible.

---

## Prompt 2: Bratwurst im Brötchen with Mustard Drizzle (General-Purpose / App Icon)

> A beautifully illustrated bratwurst nestled in a sliced German bread roll (Brötchen), centered on a solid black background. The bratwurst is a plump, golden-brown grilled sausage with subtle dark char marks, poking out from both ends of the warm crusty roll. A generous zigzag drizzle of bright yellow mustard (#FFCE00) runs along the top of the sausage. The bread roll has a warm golden-tan color with a slightly darker toasted crust and a few sesame seeds. Bold dark outlines on every element. Cartoon illustrated style — flat color with gentle gradients, not photorealistic — matching a family of icons that includes a golden beer stein with green bands, a red-coated nutcracker soldier, and a wooden cuckoo clock. Square 1024x1024 format. Color palette: rich warm golden-amber and brown tones for the sausage, lighter golden-tan for the bread, bright yellow-gold (#FFCE00) for the mustard, with small red (#DD0000) accents — a tiny pretzel emblem stamped into the bread roll. Strong clear silhouette that reads well when scaled down to 30x30 pixels.

**Concept:** Classic German street-food still life. Appetizing, iconic, works as a potential alternate app icon.

---

## Prompt 3: Grilled Bratwurst on a Two-Pronged Meat Fork with Steam (Chain / Game Element)

> A single plump grilled bratwurst speared at a slight diagonal on a traditional long two-pronged meat fork, centered on a solid black background. The bratwurst has rich golden-brown skin with pronounced dark grill marks and a gentle curve. Two small wisps of white steam rise from the hot sausage. The meat fork has polished steel-gray prongs and a dark wooden handle with decorative rings in red (#DD0000) and gold (#FFCE00). A small sprig of parsley rests at the base of the sausage where it meets the fork. Bold dark outlines on every element. Cartoon illustrated style — flat color with gentle shading, not photorealistic — matching a family of icons that includes a green Bavarian hat with feather and tricolor cord, a cute reddish-brown dachshund, and a stained-glass Reichstag dome. Square 1024x1024 format. Color palette: warm golden-amber and toasted-brown for the bratwurst, dark steel-gray for the fork tines, warm chocolate-brown for the handle, red (#DD0000) and bright gold-yellow (#FFCE00) accent rings, small green parsley accent. Strong bold silhouette that reads well when scaled down to 30x30 pixels.

**Concept:** Dynamic, action-oriented — a bratwurst ready for the grill or the battlefield. Works well as a chain segment or standalone game element.

---

## Verification Checklist

After generating images with Nano Banana:

1. Compare side-by-side with Hat, Bundestag, and Pretzel icons at 1024px — check style harmony
2. Scale to 30x30 in a preview tool — verify silhouette readability
3. Check that red and gold tones match customRed (`#DD0000`) and customYellow (`#FFCE00`)
4. Test on black background to confirm no fringing or halo artifacts

## Asset Integration

Once a bratwurst icon is chosen, add it to the asset catalog following the existing pattern:

- Create `Bratwurst.imageset/` in `Assets.xcassets/` with both `Bratwurst.png` (dark) and `Bratwurst-light.png` (light) variants
- Update `PowerUpKind.bratwurst` in `GameState.swift` to use `Image("Bratwurst")` instead of `Text("🌭")`
- Update `GameView.swift` to render the image asset
