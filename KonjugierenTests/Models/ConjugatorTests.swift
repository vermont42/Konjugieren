// Copyright © 2025 Josh Adams. All rights reserved.

import Testing
@testable import Konjugieren

struct ConjugatorTests {
  @Test func perfektpartizip() {
    // Weak verb
    expectConjugation(infinitiv: "machen", conjugationGroup: .perfektpartizip, expected: "gemacht")

    // -ieren verb (no ge- prefix)
    expectConjugation(infinitiv: "studieren", conjugationGroup: .perfektpartizip, expected: "studiert")

    // Strong verbs (uppercase indicates ablaut changes)
    expectConjugation(infinitiv: "singen", conjugationGroup: .perfektpartizip, expected: "gesUngen")
    expectConjugation(infinitiv: "gehen", conjugationGroup: .perfektpartizip, expected: "gegANGen")
    expectConjugation(infinitiv: "finden", conjugationGroup: .perfektpartizip, expected: "gefUnden")
    expectConjugation(infinitiv: "nehmen", conjugationGroup: .perfektpartizip, expected: "genOMMen")
    expectConjugation(infinitiv: "sitzen", conjugationGroup: .perfektpartizip, expected: "gesESSen")

    // Mixed verbs
    expectConjugation(infinitiv: "bringen", conjugationGroup: .perfektpartizip, expected: "gebrACHt")
    expectConjugation(infinitiv: "haben", conjugationGroup: .perfektpartizip, expected: "gehabt")

    // Separable prefix verb (prefix + ge + stamm + ending)
    expectConjugation(infinitiv: "ankommen", conjugationGroup: .perfektpartizip, expected: "angekommen")

    // Inseparable prefix verb (no ge- prefix)
    expectConjugation(infinitiv: "verstehen", conjugationGroup: .perfektpartizip, expected: "verstANDen")
  }

  @Test func imperativ() {
    // MARK: - du form (secondSingular)

    // Weak verb - basic stem
    expectConjugation(infinitiv: "machen", conjugationGroup: .imperativ(.secondSingular), expected: "mach")

    // Strong verb with e→i change - should apply (uppercase indicates ablaut)
    expectConjugation(infinitiv: "geben", conjugationGroup: .imperativ(.secondSingular), expected: "gIb")
    expectConjugation(infinitiv: "nehmen", conjugationGroup: .imperativ(.secondSingular), expected: "nIMM")

    // Strong verb with e→ie change - should apply
    expectConjugation(infinitiv: "sehen", conjugationGroup: .imperativ(.secondSingular), expected: "sIEh")

    // Strong verb with a→ä change - should NOT apply (use base stem)
    expectConjugation(infinitiv: "lassen", conjugationGroup: .imperativ(.secondSingular), expected: "lass")

    // Verb ending in -d needs -e for pronunciation
    expectConjugation(infinitiv: "werden", conjugationGroup: .imperativ(.secondSingular), expected: "werde")

    // Irregular sein (full override, all uppercase)
    expectConjugation(infinitiv: "sein", conjugationGroup: .imperativ(.secondSingular), expected: "SEI")

    // Separable prefix verb - prefix goes to end
    expectConjugation(infinitiv: "ankommen", conjugationGroup: .imperativ(.secondSingular), expected: "komm an")

    // MARK: - ihr form (secondPlural)

    expectConjugation(infinitiv: "machen", conjugationGroup: .imperativ(.secondPlural), expected: "macht")
    expectConjugation(infinitiv: "geben", conjugationGroup: .imperativ(.secondPlural), expected: "gebt")
    expectConjugation(infinitiv: "sein", conjugationGroup: .imperativ(.secondPlural), expected: "SEID")
    expectConjugation(infinitiv: "ankommen", conjugationGroup: .imperativ(.secondPlural), expected: "kommt an")

    // MARK: - wir form (firstPlural)

    expectConjugation(infinitiv: "machen", conjugationGroup: .imperativ(.firstPlural), expected: "machen wir")
    expectConjugation(infinitiv: "gehen", conjugationGroup: .imperativ(.firstPlural), expected: "gehen wir")
    expectConjugation(infinitiv: "sein", conjugationGroup: .imperativ(.firstPlural), expected: "SEIEN wir")
    expectConjugation(infinitiv: "ankommen", conjugationGroup: .imperativ(.firstPlural), expected: "kommen wir an")

    // MARK: - Sie form (thirdPlural)

    expectConjugation(infinitiv: "machen", conjugationGroup: .imperativ(.thirdPlural), expected: "machen Sie")
    expectConjugation(infinitiv: "gehen", conjugationGroup: .imperativ(.thirdPlural), expected: "gehen Sie")
    expectConjugation(infinitiv: "sein", conjugationGroup: .imperativ(.thirdPlural), expected: "SEIEN Sie")
    expectConjugation(infinitiv: "ankommen", conjugationGroup: .imperativ(.thirdPlural), expected: "kommen Sie an")
  }

  private func expectConjugation(infinitiv: String, conjugationGroup: ConjugationGroup, expected: String) {
    let result = Conjugator.conjugate(infinitiv: infinitiv, conjugationGroup: conjugationGroup)
    switch result {
    case .success(let conjugation):
      #expect(conjugation == expected, "Expected \(infinitiv) → \(expected), got \(conjugation)")
    case .failure(let err):
      Issue.record("Failed to conjugate \(infinitiv): \(err)")
    }
  }
}
