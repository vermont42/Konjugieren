// Copyright © 2026 Josh Adams. All rights reserved.

import Testing
@testable import Konjugieren

@Suite(.serialized)
@MainActor
struct PersonNumberTests {
  init() {
    Current.settings.thirdPersonPronounGender = .er
  }

  @Test func imperativPronounMapping() {
    #expect(PersonNumber.secondSingular.imperativPronoun == "du")
    #expect(PersonNumber.secondPlural.imperativPronoun == "ihr")
    #expect(PersonNumber.firstPlural.imperativPronoun == "wir")
    #expect(PersonNumber.thirdPlural.imperativPronoun == "Sie")
    #expect(PersonNumber.firstSingular.imperativPronoun == nil)
    #expect(PersonNumber.thirdSingular.imperativPronoun == nil)
  }

  @Test func sieDisambiguationLeavesNonSiePronounsUntouched() {
    #expect(PersonNumber.firstSingular.pronounWithSieDisambiguation == "ich")
    #expect(PersonNumber.secondSingular.pronounWithSieDisambiguation == "du")
    #expect(PersonNumber.firstPlural.pronounWithSieDisambiguation == "wir")
    #expect(PersonNumber.secondPlural.pronounWithSieDisambiguation == "ihr")
  }

  @Test func sieDisambiguationTagsThirdPlural() {
    #expect(PersonNumber.thirdPlural.pronounWithSieDisambiguation == "sie (3p)")
  }

  @Test func sieDisambiguationTagsThirdSingularOnlyWhenGenderIsSie() {
    // With an er/es gender, third-singular is not "sie", so no tag is added.
    Current.settings.thirdPersonPronounGender = .er
    #expect(PersonNumber.thirdSingular.pronounWithSieDisambiguation == "er")

    Current.settings.thirdPersonPronounGender = .es
    #expect(PersonNumber.thirdSingular.pronounWithSieDisambiguation == "es")

    // With the sie gender, third-singular collides with third-plural, so it is tagged.
    Current.settings.thirdPersonPronounGender = .sie
    #expect(PersonNumber.thirdSingular.pronounWithSieDisambiguation == "sie (3s)")
  }
}
