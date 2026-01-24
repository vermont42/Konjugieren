// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

class AblautGroupParser: NSObject, XMLParserDelegate {
  private var parser: XMLParser?
  private let ablautGroupTag = "ag"
  private var ablautGroups: [String: AblautGroup] = [:]
  private var currentExemplar = ""
  private var currentAblauts = ""

  override init() {
    super.init()
    let bundle = Bundle(for: AblautGroupParser.self)
    if let url = bundle.url(forResource: "AblautGroups", withExtension: "xml") {
      parser = XMLParser(contentsOf: url)
      if parser == nil {
        return
      }
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
        fatalError("No exemplar specified.")
      }

      if let ablauts = attributeDict["a"] {
        currentAblauts = ablauts
      } else {
        fatalError("No ablauts specified.")
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
