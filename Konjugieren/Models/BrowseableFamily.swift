// Copyright © 2026 Josh Adams. All rights reserved.

enum BrowseableFamily: String, CaseIterable, Identifiable {
  case ablaut
  case ieren
  case inseparable
  case mixed
  case separable
  case strong
  case weak

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
    case .ablaut:
      return L.BrowseableFamily.ablaut
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
    case .ablaut:
      return L.FamilyBrowse.ablautShort
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
    case .ablaut:
      return L.FamilyDetail.ablautLong
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
      case .ablaut:
        return verb.ablautGroup != nil
      }
    }
  }

  var verbCount: Int {
    verbs.count
  }

  var verbsByPrefix: [(section: PrefixSection, verbs: [Verb])] {
    guard hasPrefixList else { return [] }

    let curated = Set(prefixes.map { String($0.prefix.dropLast()) })

    var sections = prefixes.compactMap { prefixMeaning -> (section: PrefixSection, verbs: [Verb])? in
      let prefixString = String(prefixMeaning.prefix.dropLast())
      let matchingVerbs = verbs
        .filter { $0.prefix.name == prefixString }
        .sorted { $0.infinitiv < $1.infinitiv }

      guard !matchingVerbs.isEmpty else { return nil }
      return (section: .curated(prefixMeaning), verbs: matchingVerbs)
    }

    // Everything the curated list misses, appended as one flat section rather than
    // dropped. Until 2026-07-19 these verbs counted toward verbCount without appearing
    // anywhere on the screen, so the Separable card said 2,035 and listed 1,245.
    let uncurated = verbs
      .filter { verb in
        guard let name = verb.prefix.name else { return true }
        return !curated.contains(name)
      }
      .sorted { $0.infinitiv < $1.infinitiv }

    if !uncurated.isEmpty {
      sections.append((section: .other, verbs: uncurated))
    }

    return sections
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
    case .ablaut:
      return "waveform.path"
    }
  }

  var representativeInfinitiv: String {
    switch self {
    case .strong:
      return "singen"
    case .weak:
      return "machen"
    case .mixed:
      return "denken"
    case .ieren:
      return "studieren"
    case .separable:
      return "ankommen"
    case .inseparable:
      return "verstehen"
    case .ablaut:
      return "sehen"
    }
  }

  var topVerbs: [Verb] {
    Array(verbs.sorted { $0.frequency < $1.frequency }.prefix(3))
  }

  var hasAblautList: Bool {
    self == .ablaut
  }

  var ablautGroups: [AblautGroupInfo] {
    guard hasAblautList else { return [] }
    return AblautGroupInfo.allGroups
  }
}
