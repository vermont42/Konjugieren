// Copyright © 2025 Josh Adams. All rights reserved.

import Foundation

struct AblautGroup: Hashable, CustomStringConvertible {
  static var ablautGroups: [String: AblautGroup] = [:]
  let exemplar: String
  var ablauts: [ConjugationGroup: String] = [:]

  init(exemplar: String, xmlString: String) {
    self.exemplar = exemplar
    let separator = "|"
    let components = xmlString.components(separatedBy: separator)
    var ablautArray: [Ablaut] = []
    components.forEach {
      ablautArray.append(Ablaut(xmlString: $0))
    }
    for ablaut in ablautArray {
      for conjugationGroup in ablaut.appliesTo {
        ablauts[conjugationGroup] = ablaut.lettersToUse
      }
    }
  }

  var description: String {
    exemplar + " \(ablauts.count) ablauts"
  }
}
