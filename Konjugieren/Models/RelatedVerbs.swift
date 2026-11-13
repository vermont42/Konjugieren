// Copyright © 2026 Josh Adams. All rights reserved.

/// The verbs a verb page leads to: the verbs built on the same base (stehen, aufstehen,
/// verstehen, bestehen), the other bases that share its ablaut group, and its family's page.
struct RelatedVerbs: Equatable {
  /// The innermost base, which every verb built on it shares: stehen for aufstehen, and kennen
  /// for anerkennen, whose own base is erkennen. It need not be a verb of the corpus: beginnen's
  /// is ginnen.
  let root: String

  /// The verbs built on `root`, the root verb first when it is in the corpus, then by frequency.
  /// The verb whose page this is does not appear.
  let builtOnRoot: [Verb]

  let ablautGroup: String?

  /// One verb for each other base in the ablaut group, by frequency: its root verb when that is
  /// in the group, else the group's most frequent verb built on it.
  let ablautRelatives: [Verb]

  let families: [BrowseableFamily]

  var isEmpty: Bool {
    builtOnRoot.isEmpty && ablautRelatives.isEmpty && families.isEmpty
  }
}

extension Verb {
  @MainActor private static var cachedRootIndex: [String: [Verb]]?

  /// Every verb, keyed by its root, each list by frequency.
  @MainActor static var verbsByRoot: [String: [Verb]] {
    if let cachedRootIndex {
      return cachedRootIndex
    }
    let index = Dictionary(grouping: verbsSortedByFrequency) { $0.root }
    cachedRootIndex = index
    return index
  }

  /// The innermost base after peeling every prefix the corpus marks, following a base that is
  /// itself a prefixed verb of the corpus: an+erkennen gives erkennen, and er\*kennen gives kennen.
  @MainActor var root: String {
    var infinitiv = self.infinitiv
    var prefixes = primaryReading.prefixes
    // The bound guards against a cycle in the data, which no verb has today.
    for _ in 0..<4 {
      let base = String(infinitiv.dropFirst(prefixes.totalLength))
      guard base != infinitiv else {
        break
      }
      infinitiv = base
      guard let baseVerb = Verb.verbs[base] else {
        break
      }
      prefixes = baseVerb.primaryReading.prefixes
    }
    return infinitiv
  }

  @MainActor func related(readingIndex: Int = 0) -> RelatedVerbs {
    let reading = self.reading(at: readingIndex) ?? primaryReading
    let root = self.root
    let rootVerb = Verb.verbs[root]
    let builtOnRoot = (Verb.verbsByRoot[root] ?? [])
      .filter { $0 != self && $0 != rootVerb }
    let ablautGroup = reading.ablautGroup
    return RelatedVerbs(
      root: root,
      builtOnRoot: (rootVerb.map { $0 == self ? [] : [$0] } ?? []) + builtOnRoot,
      ablautGroup: ablautGroup,
      ablautRelatives: ablautGroup.map { Verb.ablautRelatives(in: $0, excludingRoot: root) } ?? [],
      families: BrowseableFamily.families(of: reading)
    )
  }

  @MainActor private static func ablautRelatives(in group: String, excludingRoot: String) -> [Verb] {
    let members = verbsSortedByFrequency.filter { $0.ablautGroup == group }
    let byRoot = Dictionary(grouping: members) { $0.root }
    return byRoot
      .filter { $0.key != excludingRoot }
      .compactMap { root, verbs in
        verbs.first { $0.infinitiv == root } ?? verbs.first
      }
      .sorted { $0.frequency < $1.frequency }
  }
}

extension BrowseableFamily {
  /// The Families tab's pages that list this reading: its conjugation family, then its prefix's.
  static func families(of reading: Reading) -> [BrowseableFamily] {
    let conjugationFamily: BrowseableFamily
    switch reading.family {
    case .strong:
      conjugationFamily = .strong
    case .weak:
      conjugationFamily = .weak
    case .mixed:
      conjugationFamily = .mixed
    case .ieren:
      conjugationFamily = .ieren
    }
    switch reading.prefix {
    case .separable:
      return [conjugationFamily, .separable]
    case .inseparable:
      return [conjugationFamily, .inseparable]
    case .none:
      return [conjugationFamily]
    }
  }
}
