// Copyright © 2026 Josh Adams. All rights reserved.

enum BrowseableFamily: String, CaseIterable, Identifiable {
  case strong
  case weak
  case mixed
  case ieren
  case separable
  case inseparable

  var id: String { rawValue }

  var displayName: String {
    switch self {
    case .strong:
      return L.Family.strong
    case .weak:
      return L.Family.weak
    case .mixed:
      return L.Family.mixed
    case .ieren:
      return L.Family.ieren
    case .separable:
      return L.BrowseableFamily.separable
    case .inseparable:
      return L.BrowseableFamily.inseparable
    }
  }

  var shortDescription: String {
    switch self {
    case .strong:
      return L.FamilyBrowse.strongShort
    case .weak:
      return L.FamilyBrowse.weakShort
    case .mixed:
      return L.FamilyBrowse.mixedShort
    case .ieren:
      return L.FamilyBrowse.ierenShort
    case .separable:
      return L.FamilyBrowse.separableShort
    case .inseparable:
      return L.FamilyBrowse.inseparableShort
    }
  }

  var longDescription: String {
    switch self {
    case .strong:
      return L.FamilyDetail.strongLong
    case .weak:
      return L.FamilyDetail.weakLong
    case .mixed:
      return L.FamilyDetail.mixedLong
    case .ieren:
      return L.FamilyDetail.ierenLong
    case .separable:
      return L.FamilyDetail.separableLong
    case .inseparable:
      return L.FamilyDetail.inseparableLong
    }
  }

  var hasPrefixList: Bool {
    self == .separable || self == .inseparable
  }

  var prefixes: [PrefixMeaning] {
    switch self {
    case .separable:
      return PrefixMeaning.separablePrefixes
    case .inseparable:
      return PrefixMeaning.inseparablePrefixes
    default:
      return []
    }
  }

  var verbs: [Verb] {
    Verb.verbsSortedAlphabetically.filter { verb in
      switch self {
      case .strong:
        if case .strong = verb.family {
          return true
        }
        return false
      case .weak:
        return verb.family == .weak
      case .mixed:
        if case .mixed = verb.family {
          return true
        }
        return false
      case .ieren:
        return verb.family == .ieren
      case .separable:
        if case .separable = verb.prefix {
          return true
        }
        return false
      case .inseparable:
        if case .inseparable = verb.prefix {
          return true
        }
        return false
      }
    }
  }

  var verbCount: Int {
    verbs.count
  }

  var verbsByPrefix: [(prefix: PrefixMeaning, verbs: [Verb])] {
    guard hasPrefixList else { return [] }

    return prefixes.compactMap { prefixMeaning in
      let prefixString = String(prefixMeaning.prefix.dropLast())
      let matchingVerbs = verbs.filter { verb in
        switch verb.prefix {
        case .separable(let p), .inseparable(let p):
          return p == prefixString
        case .none:
          return false
        }
      }.sorted { $0.infinitiv < $1.infinitiv }

      guard !matchingVerbs.isEmpty else { return nil }
      return (prefix: prefixMeaning, verbs: matchingVerbs)
    }
  }

  var systemImageName: String {
    switch self {
    case .strong:
      return "bolt.fill"
    case .weak:
      return "leaf.fill"
    case .mixed:
      return "arrow.triangle.merge"
    case .ieren:
      return "globe.europe.africa.fill"
    case .separable:
      return "arrow.left.arrow.right"
    case .inseparable:
      return "link"
    }
  }
}
