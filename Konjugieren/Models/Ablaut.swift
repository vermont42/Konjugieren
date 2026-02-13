// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

struct Ablaut: Hashable {
  let lettersToUse: String
  var appliesTo: [Conjugationgroup]

  private static let groupConstructors: [Character: (PersonNumber) -> Conjugationgroup] = [
    "a": Conjugationgroup.präsensIndicativ,
    "b": Conjugationgroup.präteritumIndicativ,
    "c": Conjugationgroup.präsensKonjunktivI,
    "d": Conjugationgroup.präteritumKonjunktivII,
    "i": Conjugationgroup.imperativ,
  ]

  private static let personNumberCodes: [String: PersonNumber] = [
    "1s": .firstSingular,
    "2s": .secondSingular,
    "3s": .thirdSingular,
    "1p": .firstPlural,
    "2p": .secondPlural,
    "3p": .thirdPlural,
  ]

  init(xmlString: String) {
    let separator = ","
    let components = xmlString.components(separatedBy: separator)
    if components.count < 2 {
      Current.fatalError.fatalError("Ablaut xmlString \(xmlString) lacked sufficient comma-separated components.")
    }
    lettersToUse = components[0]
    appliesTo = []
    for code in components[1 ..< components.count] {
      if code == "pp" {
        appliesTo.append(.perfektpartizip)
      } else if let prefix = code.first, let constructor = Self.groupConstructors[prefix] {
        let suffix = String(code.dropFirst())
        if suffix == "A" {
          let numbers = prefix == "i" ? PersonNumber.imperativPersonNumbers : PersonNumber.allCases
          numbers.forEach { appliesTo.append(constructor($0)) }
        } else if let personNumber = Self.personNumberCodes[suffix] {
          appliesTo.append(constructor(personNumber))
        } else {
          Current.fatalError.fatalError("Unrecognized Conjugationgroup \(code) was encountered.")
        }
      } else {
        Current.fatalError.fatalError("Unrecognized Conjugationgroup \(code) was encountered.")
      }
    }
  }
}
