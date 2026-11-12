// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

class AblautGroupParser: NSObject, XMLParserDelegate {
  private var parser: XMLParser?
  private let ablautGroupTag = "ag"
  private var ablautGroups: [String: AblautGroup] = [:]
  private var currentExemplar = ""
  private var currentAblauts = ""

  convenience override init() {
    self.init(contentsOf: Bundle(for: AblautGroupParser.self).url(forResource: "AblautGroups", withExtension: "xml"))
  }

  init(contentsOf url: URL?) {
    super.init()
    if let url {
      parser = XMLParser(contentsOf: url)
      parser?.delegate = self
    }
  }

  func parse() -> [String: AblautGroup] {
    parser?.parse()
    return ablautGroups
  }

  func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String]) {
    if elementName == ablautGroupTag {
      if let exemplar = attributeDict["e"] {
        currentExemplar = exemplar
      } else {
        Current.fatalError.fatalError("No exemplar specified for ablaut group at position \(AblautGroup.ablautGroups.count + 1).")
      }

      if let ablauts = attributeDict["a"] {
        currentAblauts = ablauts
      } else {
        Current.fatalError.fatalError("No ablauts specified for ablaut group '\(currentExemplar)'.")
      }
    }
  }

  func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
    if elementName == ablautGroupTag {
      ablautGroups[currentExemplar] = AblautGroup(
        exemplar: currentExemplar,
        xmlString: currentAblauts
      )

      currentExemplar = ""
      currentAblauts = ""
    }
  }
}
