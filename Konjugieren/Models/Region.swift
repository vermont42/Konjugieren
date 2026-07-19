// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

// Semantic ordering: the three codified standard varieties, ordered as they appear in the
// settings picker, with the default first.
enum Region: String, CaseIterable {
  case north
  case austria
  case switzerland

  var localizedRegion: String {
    switch self {
    case .north:
      return L.Region.north
    case .austria:
      return L.Region.austria
    case .switzerland:
      return L.Region.switzerland
    }
  }

  nonisolated var flag: String {
    switch self {
    case .north:
      return "🇩🇪"
    case .austria:
      return "🇦🇹"
    case .switzerland:
      return "🇨🇭"
    }
  }

  /// Swiss Standard German abolished ß in the 1970s. Every ß is written ss, with no
  /// exceptions and no dependence on vowel length, so this is a property of the variety
  /// rather than of any individual word.
  nonisolated var writesSharpS: Bool {
    switch self {
    case .north, .austria:
      return true
    case .switzerland:
      return false
    }
  }

  /// Which auxiliary a regionally conditioned verb (stehen, sitzen, liegen and their
  /// prefixed derivatives) takes in the Perfekt. Austria and Switzerland say
  /// "ist gestanden" where the northern standard says "hat gestanden".
  nonisolated var regionalAuxiliary: Auxiliary {
    switch self {
    case .north:
      return .haben
    case .austria, .switzerland:
      return .sein
    }
  }

  /// The variety a fresh install starts in, inferred from the device locale so that an
  /// Austrian or Swiss user is not told their German is wrong before finding Settings.
  /// Only consulted when no stored value exists.
  nonisolated static func seeded(from locale: Locale) -> Region {
    switch locale.region?.identifier {
    case "AT":
      return .austria
    case "CH", "LI":
      return .switzerland
    default:
      return .north
    }
  }
}
