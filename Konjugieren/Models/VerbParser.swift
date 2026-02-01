// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

class VerbParser: NSObject, XMLParserDelegate {
  private var parser: XMLParser?
  private let verbTag = "verb"
  private var verbs: [String: Verb] = [:]
  private var currentVerb = ""
  private var currentTranslation = ""
  private var currentFamily = ""
  private var currentAuxiliary: String?
  private var currentFrequency = 0
  private var currentPrefix: Prefix = .none
  private var currentAblautGroup = ""
  private var currentAblautStartIndex = 0
  private var currentAblautEndIndex = 0
  private var currentIconSuffix = ""

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
    return verbs
  }

  func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String]) {
    if elementName == verbTag {
      if let currentVerb = attributeDict["in"] {
        self.currentVerb = currentVerb
        let separableSeparator = "+"
        let inseparableSeparator = "*"
        if currentVerb.contains(separableSeparator) {
          let components = currentVerb.components(separatedBy: separableSeparator)
          currentPrefix = .separable(components[0])
          self.currentVerb = currentVerb.replacing(separableSeparator, with: "")
        } else if currentVerb.contains(inseparableSeparator) {
          let components = currentVerb.components(separatedBy: inseparableSeparator)
          currentPrefix = .inseparable(components[0])
          self.currentVerb = currentVerb.replacing(inseparableSeparator, with: "")
        } else {
          self.currentVerb = currentVerb
        }
      } else {
        fatalError("No infinitive specified.")
      }

      if let translation = attributeDict["tn"] {
        currentTranslation = translation
      } else {
        fatalError("No translation specified.")
      }

      if let family = attributeDict["fa"] {
        currentFamily = family
      } else {
        fatalError("No family specified.")
      }

      if let ablautGroup = attributeDict["ag"] {
        currentAblautGroup = ablautGroup
      }

      if let auxiliary = attributeDict["ay"] {
        currentAuxiliary = auxiliary
      }

      if
        let frequency = attributeDict["fr"],
        let frequencyInt = Int(frequency)
      {
        currentFrequency = frequencyInt
      } else {
        fatalError("No frequency specified.")
      }

      if let iconSuffix = attributeDict["ic"] {
        currentIconSuffix = iconSuffix
      }
    }
  }

  func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
    if elementName == verbTag {
      let auxiliary: Auxiliary

      if let currentAuxiliary = currentAuxiliary {
        guard let computedAuxiliary = Auxiliary(rawValue: currentAuxiliary) else {
          fatalError("Invalid Auxiliary \(currentAuxiliary).")
        }
        auxiliary = computedAuxiliary
      } else {
        auxiliary = .haben
      }

      if ["w", "i"].contains(currentFamily) && currentAblautGroup != "" {
        fatalError("Ablaut group \(currentAblautGroup) was provided for weak or ieren verb \(currentVerb).")
      }
      if ["s", "m"].contains(currentFamily) && currentAblautGroup == "" {
        fatalError("No ablaut group was provided for strong or mixed verb \(currentVerb).")
      }

      let caretCount = currentVerb.filter { $0 == "^" }.count
      if caretCount != 0 && caretCount != 2 {
        fatalError("Verb \(currentVerb) has \(caretCount) carets but must have 0 or 2.")
      }
      if ["w", "i"].contains(currentFamily) && caretCount > 0 {
        fatalError("Verb \(currentVerb) has carets but is weak or ieren.")
      }
      if ["s", "m"].contains(currentFamily) && caretCount != 2 {
        fatalError("Strong or mixed verb \(currentVerb) must have exactly 2 carets.")
      }

      if caretCount == 2 {
        if let firstCaretIndex = currentVerb.firstIndex(of: "^") {
          currentAblautStartIndex = currentVerb.distance(from: currentVerb.startIndex, to: firstCaretIndex)
          let afterFirstCaret = currentVerb.index(after: firstCaretIndex)
          if let secondCaretIndex = currentVerb[afterFirstCaret...].firstIndex(of: "^") {
            let secondPosition = currentVerb.distance(from: currentVerb.startIndex, to: secondCaretIndex)
            currentAblautEndIndex = secondPosition - 1
          }
        }
      }

      currentVerb = currentVerb.replacing("^", with: "")

      let family: Family
      switch currentFamily {
      case "i":
        family = .ieren
      case "w":
        family = .weak
      case "m":
        family = .mixed(ablautGroup: currentAblautGroup, ablautStartIndex: currentAblautStartIndex, ablautEndIndex: currentAblautEndIndex)
      case "s":
        family = .strong(ablautGroup: currentAblautGroup, ablautStartIndex: currentAblautStartIndex, ablautEndIndex: currentAblautEndIndex)
      case "":
        fatalError("No family was provided for \(currentVerb).")
      default:
        fatalError("Unrecognized family \(currentFamily) was provided for \(currentVerb).")
      }

      let frequencyIcon = currentIconSuffix.isEmpty ? "figure" : "figure.\(currentIconSuffix)"

      verbs[currentVerb] = Verb(
        infinitiv: currentVerb,
        translation: currentTranslation,
        family: family,
        auxiliary: auxiliary,
        frequency: currentFrequency,
        prefix: currentPrefix,
        frequencyIcon: frequencyIcon
      )

      currentVerb = ""
      currentTranslation = ""
      currentFamily = ""
      currentAuxiliary = nil
      currentFrequency = 0
      currentAblautGroup = ""
      currentAblautStartIndex = 0
      currentAblautEndIndex = 0
      currentPrefix = .none
      currentIconSuffix = ""
    }
  }
}
