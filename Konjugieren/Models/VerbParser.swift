// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

class VerbParser: NSObject, XMLParserDelegate {
  private var parser: XMLParser?
  private let verbTag = "verb"
  private let readingTag = "reading"
  private var verbs: [String: Verb] = [:]

  private var currentVerb = ""
  private var currentMarkedInfinitiv = ""
  private var currentHits = 0
  private var currentHitsAreProvisional = false
  private var currentIconSuffix = ""
  private var currentReadings: [Reading] = []

  override init() {
    super.init()
    let bundle = Bundle(for: VerbParser.self)
    if let url = bundle.url(forResource: "Verbs", withExtension: "xml") {
      parser = XMLParser(contentsOf: url)
      if parser == nil {
        return
      }
      parser?.delegate = self
    }
  }

  func parse() -> [String: Verb] {
    parser?.parse()
    return Self.ranked(verbs)
  }

  /// Assigns each verb its dense frequency rank, 1 being the most common.
  ///
  /// `Verbs.xml` stores raw DWDS hit counts because a rank is a property of the corpus
  /// rather than of the verb: were ranks stored, adding one verb would renumber every
  /// verb below it, turning a one-line change into a 990-line diff. Deriving the rank
  /// here costs one sort per launch and keeps the file additive.
  ///
  /// The sort is descending by hits, so that the rank counts the same direction the
  /// hand-maintained ranks did and every existing ascending sort on `frequency` still
  /// means most-common-first. Ties break on the infinitive to keep the order total; the
  /// shipping corpus has none, but an imported tranche may.
  private static func ranked(_ verbs: [String: Verb]) -> [String: Verb] {
    let ordered = verbs.values.sorted {
      $0.hits == $1.hits ? $0.infinitiv < $1.infinitiv : $0.hits > $1.hits
    }
    var ranked: [String: Verb] = [:]
    ranked.reserveCapacity(ordered.count)
    for (index, verb) in ordered.enumerated() {
      ranked[verb.infinitiv] = verb.withFrequency(index + 1)
    }
    return ranked
  }

  func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String]) {
    switch elementName {
    case verbTag:
      startVerb(attributeDict)
    case readingTag:
      startReading(attributeDict)
    default:
      break
    }
  }

  private func startVerb(_ attributeDict: [String: String]) {
    guard let markedInfinitiv = attributeDict["in"] else {
      Current.fatalError.fatalError("No infinitive specified for verb at position \(verbs.count + 1).")
      return
    }
    currentMarkedInfinitiv = markedInfinitiv
    currentVerb = Self.strippedInfinitiv(markedInfinitiv)

    if
      let hits = attributeDict["hi"],
      let hitsInt = Int(hits)
    {
      currentHits = hitsInt
    } else {
      Current.fatalError.fatalError("No hit count specified for verb '\(currentVerb)'.")
    }

    // The DTD admits only "y", so presence is the whole signal; absence means the count is a
    // measured DWDS value, mirroring how an absent `ay` means haben.
    currentHitsAreProvisional = attributeDict["hp"] != nil

    if let iconSuffix = attributeDict["ic"] {
      currentIconSuffix = iconSuffix
    }
  }

  private func startReading(_ attributeDict: [String: String]) {
    // A reading may respell `in` to change prefix separability (über+setzen beside
    // über*setzen) or to move the ablaut region, but it inherits the verb's spelling
    // otherwise. Stripping to a different key would create a verb nothing could reach,
    // since Verb.verbs and Conjugator both resolve on the marker-free infinitive.
    let markedInfinitiv = attributeDict["in"] ?? currentMarkedInfinitiv
    let infinitiv = Self.strippedInfinitiv(markedInfinitiv)
    if infinitiv != currentVerb {
      Current.fatalError.fatalError("Reading '\(markedInfinitiv)' of verb '\(currentVerb)' resolves to '\(infinitiv)', which is a different verb.")
      return
    }

    guard let parsed = parseMarkedInfinitiv(markedInfinitiv) else {
      return
    }

    guard let translation = attributeDict["tn"] else {
      Current.fatalError.fatalError("No translation specified for verb '\(currentVerb)'.")
      return
    }

    guard let familyCode = attributeDict["fa"] else {
      Current.fatalError.fatalError("No family specified for verb '\(currentVerb)'.")
      return
    }

    let ablautGroup = attributeDict["ag"] ?? ""
    if ["w", "i"].contains(familyCode) && !ablautGroup.isEmpty {
      Current.fatalError.fatalError("Ablaut group \(ablautGroup) was provided for weak or ieren verb \(currentVerb).")
    }
    if ["s", "m"].contains(familyCode) && ablautGroup.isEmpty {
      Current.fatalError.fatalError("No ablaut group was provided for strong or mixed verb \(currentVerb).")
    }
    if ["w", "i"].contains(familyCode) && parsed.hasAblautRegion {
      Current.fatalError.fatalError("Verb \(currentVerb) has carets but is weak or ieren.")
    }
    if ["s", "m"].contains(familyCode) && !parsed.hasAblautRegion {
      Current.fatalError.fatalError("Strong or mixed verb \(currentVerb) must have exactly 2 carets.")
    }

    let family: Family
    switch familyCode {
    case "i":
      family = .ieren
    case "w":
      family = .weak
    case "m":
      family = .mixed(ablautGroup: ablautGroup, ablautStartIndex: parsed.ablautStartIndex, ablautEndIndex: parsed.ablautEndIndex)
    case "s":
      family = .strong(ablautGroup: ablautGroup, ablautStartIndex: parsed.ablautStartIndex, ablautEndIndex: parsed.ablautEndIndex)
    default:
      Current.fatalError.fatalError("Unrecognized family \(familyCode) was provided for \(currentVerb).")
      return
    }

    // ay="r" marks an auxiliary that varies by region rather than a third auxiliary verb.
    // The stored value stays haben, the German standard, so that Conjugator and the
    // classify-and-verify oracle see exactly what they saw before this attribute existed.
    let auxiliaryCode = attributeDict["ay"]
    let auxiliaryIsRegional = auxiliaryCode == "r"
    let auxiliary: Auxiliary
    if let auxiliaryCode, !auxiliaryIsRegional {
      guard let parsedAuxiliary = Auxiliary(rawValue: auxiliaryCode) else {
        Current.fatalError.fatalError("Invalid Auxiliary \(auxiliaryCode).")
        return
      }
      auxiliary = parsedAuxiliary
    } else {
      auxiliary = .haben
    }

    currentReadings.append(
      Reading(
        infinitiv: infinitiv,
        translation: translation,
        family: family,
        auxiliary: auxiliary,
        prefixes: parsed.prefixes,
        auxiliaryIsRegional: auxiliaryIsRegional
      )
    )
  }

  func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
    guard elementName == verbTag else {
      return
    }

    if currentReadings.isEmpty {
      Current.fatalError.fatalError("Verb '\(currentVerb)' has no readings.")
      return
    }

    if verbs[currentVerb] != nil {
      Current.fatalError.fatalError("Duplicate verb '\(currentVerb)' in Verbs.xml.")
    }

    verbs[currentVerb] = Verb(
      infinitiv: currentVerb,
      hits: currentHits,
      hitsAreProvisional: currentHitsAreProvisional,
      // Filled in by `ranked` once every verb is parsed, since a rank cannot be known
      // until the whole corpus is.
      frequency: 0,
      frequencyIcon: currentIconSuffix.isEmpty ? "figure" : "figure.\(currentIconSuffix)",
      readings: currentReadings
    )

    resetState()
  }

  private func resetState() {
    currentVerb = ""
    currentMarkedInfinitiv = ""
    currentHits = 0
    currentHitsAreProvisional = false
    currentIconSuffix = ""
    currentReadings = []
  }

  // MARK: The `in` grammar

  private static let separableMarker: Character = "+"
  private static let inseparableMarker: Character = "*"
  private static let ablautMarker: Character = "^"

  /// The dictionary key for a marked infinitive: every marker removed.
  static func strippedInfinitiv(_ marked: String) -> String {
    String(marked.filter { $0 != separableMarker && $0 != inseparableMarker && $0 != ablautMarker })
  }

  private struct ParsedInfinitiv {
    let prefixes: [Prefix]
    let ablautStartIndex: Int
    let ablautEndIndex: Int
    let hasAblautRegion: Bool
  }

  /// Splits a marked infinitive into its prefixes and its ablaut region.
  ///
  /// Each `+` or `*` terminates one prefix, so markers may repeat: *an+ge\*hören* is a
  /// separable prefix over an inseparable one, which is why its participle is *angehört*
  /// rather than *angegehört*. Before this grammar existed a second marker was rejected
  /// outright, and 1,186 incoming verbs of this shape were unrepresentable.
  ///
  /// The two `^` mark the ablaut region, and their indices are measured against the
  /// prefix-marker-free spelling because that is what `Conjugator` mutates. The end index
  /// subtracts one to account for the opening caret, which is not part of the stem.
  private func parseMarkedInfinitiv(_ marked: String) -> ParsedInfinitiv? {
    var prefixes: [Prefix] = []
    var segment = ""

    for character in marked {
      switch character {
      case Self.separableMarker, Self.inseparableMarker:
        let value = segment.filter { $0 != Self.ablautMarker }
        if value.isEmpty {
          Current.fatalError.fatalError("Verb '\(marked)' has an empty prefix.")
          return nil
        }
        prefixes.append(character == Self.separableMarker ? .separable(value) : .inseparable(value))
        segment = ""
      default:
        segment.append(character)
      }
    }

    if segment.filter({ $0 != Self.ablautMarker }).isEmpty {
      Current.fatalError.fatalError("Verb '\(marked)' has prefixes but no stem.")
      return nil
    }

    let withoutPrefixMarkers = marked.filter { $0 != Self.separableMarker && $0 != Self.inseparableMarker }
    let caretCount = withoutPrefixMarkers.filter { $0 == Self.ablautMarker }.count
    if caretCount != 0 && caretCount != 2 {
      Current.fatalError.fatalError("Verb \(marked) has \(caretCount) carets but must have 0 or 2.")
      return nil
    }

    var ablautStartIndex = 0
    var ablautEndIndex = 0
    if caretCount == 2, let firstCaretIndex = withoutPrefixMarkers.firstIndex(of: Self.ablautMarker) {
      ablautStartIndex = withoutPrefixMarkers.distance(from: withoutPrefixMarkers.startIndex, to: firstCaretIndex)
      let afterFirstCaret = withoutPrefixMarkers.index(after: firstCaretIndex)
      if let secondCaretIndex = withoutPrefixMarkers[afterFirstCaret...].firstIndex(of: Self.ablautMarker) {
        ablautEndIndex = withoutPrefixMarkers.distance(from: withoutPrefixMarkers.startIndex, to: secondCaretIndex) - 1
      }
    }

    return ParsedInfinitiv(
      prefixes: prefixes,
      ablautStartIndex: ablautStartIndex,
      ablautEndIndex: ablautEndIndex,
      hasAblautRegion: caretCount == 2
    )
  }
}
