// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

struct AblautGroup: Hashable {
  @MainActor static var ablautGroups: [String: AblautGroup] = [:]
  let exemplar: String
  var ablauts: [Conjugationgroup: String] = [:]

  init(exemplar: String, xmlString: String) {
    self.exemplar = exemplar
    let separator = "|"
    let components = xmlString.components(separatedBy: separator)
    var ablautArray: [Ablaut] = []
    components.forEach {
      ablautArray.append(Ablaut(xmlString: $0))
    }
    for ablaut in ablautArray {
      for conjugationgroup in ablaut.appliesTo {
        ablauts[conjugationgroup] = ablaut.lettersToUse
      }
    }
  }
}
