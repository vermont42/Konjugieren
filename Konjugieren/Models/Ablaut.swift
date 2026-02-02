// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

struct Ablaut: Hashable {
  let lettersToUse: String
  var appliesTo: [Conjugationgroup]

  init(xmlString: String) {
    let separator = ","
    let components = xmlString.components(separatedBy: separator)
    if components.count < 2 {
      Current.fatalError.fatalError("Ablaut xmlString \(xmlString) lacked sufficient comma-separated components.")
    }
    lettersToUse = components[0]
    appliesTo = []
    for conjugationgroup in components[1 ..< components.count] {
      switch conjugationgroup {
      case "a1s":
        appliesTo.append(.präsensIndicativ(.firstSingular))
      case "a2s":
        appliesTo.append(.präsensIndicativ(.secondSingular))
      case "a3s":
        appliesTo.append(.präsensIndicativ(.thirdSingular))
      case "a1p":
        appliesTo.append(.präsensIndicativ(.firstPlural))
      case "a2p":
        appliesTo.append(.präsensIndicativ(.secondPlural))
      case "a3p":
        appliesTo.append(.präsensIndicativ(.thirdPlural))
      case "aA":
        PersonNumber.allCases.forEach {
          appliesTo.append(.präsensIndicativ($0))
        }
      case "b1s":
        appliesTo.append(.präteritumIndicativ(.firstSingular))
      case "b2s":
        appliesTo.append(.präteritumIndicativ(.secondSingular))
      case "b3s":
        appliesTo.append(.präteritumIndicativ(.thirdSingular))
      case "b1p":
        appliesTo.append(.präteritumIndicativ(.firstPlural))
      case "b2p":
        appliesTo.append(.präteritumIndicativ(.secondPlural))
      case "b3p":
        appliesTo.append(.präteritumIndicativ(.thirdPlural))
      case "bA":
        PersonNumber.allCases.forEach {
          appliesTo.append(.präteritumIndicativ($0))
        }
      case "c1s":
        appliesTo.append(.präsensKonjunktivI(.firstSingular))
      case "c2s":
        appliesTo.append(.präsensKonjunktivI(.secondSingular))
      case "c3s":
        appliesTo.append(.präsensKonjunktivI(.thirdSingular))
      case "c1p":
        appliesTo.append(.präsensKonjunktivI(.firstPlural))
      case "c2p":
        appliesTo.append(.präsensKonjunktivI(.secondPlural))
      case "c3p":
        appliesTo.append(.präsensKonjunktivI(.thirdPlural))
      case "cA":
        PersonNumber.allCases.forEach {
          appliesTo.append(.präsensKonjunktivI($0))
        }
      case "d1s":
        appliesTo.append(.präteritumKonjunktivII(.firstSingular))
      case "d2s":
        appliesTo.append(.präteritumKonjunktivII(.secondSingular))
      case "d3s":
        appliesTo.append(.präteritumKonjunktivII(.thirdSingular))
      case "d1p":
        appliesTo.append(.präteritumKonjunktivII(.firstPlural))
      case "d2p":
        appliesTo.append(.präteritumKonjunktivII(.secondPlural))
      case "d3p":
        appliesTo.append(.präteritumKonjunktivII(.thirdPlural))
      case "dA":
        PersonNumber.allCases.forEach {
          appliesTo.append(.präteritumKonjunktivII($0))
        }
      case "pp":
        appliesTo.append(.perfektpartizip)
      case "i2s":
        appliesTo.append(.imperativ(.secondSingular))
      case "i1p":
        appliesTo.append(.imperativ(.firstPlural))
      case "i2p":
        appliesTo.append(.imperativ(.secondPlural))
      case "i3p":
        appliesTo.append(.imperativ(.thirdPlural))
      case "iA":
        PersonNumber.imperativPersonNumbers.forEach {
          appliesTo.append(.imperativ($0))
        }
      default:
        Current.fatalError.fatalError("Unrecognized Conjugationgroup \(conjugationgroup) was encountered.")
      }
    }
  }
}
