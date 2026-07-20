// Copyright © 2026 Josh Adams. All rights reserved.

// German's separable prefix slot is open class: it takes particles (weg-), but also
// adjectives (tot-, frei-) and nouns (heim-), so no curated list of etymologies can
// ever cover it. `.other` is the catch-all that keeps the listing total, and it is a
// separate case rather than a PrefixMeaning with empty fields because an uncurated
// prefix genuinely has no English meaning or PIE root to render.
enum PrefixSection: Identifiable {
  case curated(PrefixMeaning)
  case other

  var id: String {
    switch self {
    case .curated(let meaning):
      return meaning.id
    case .other:
      return "__other__"
    }
  }
}
