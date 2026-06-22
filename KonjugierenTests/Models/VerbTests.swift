// Copyright © 2026 Josh Adams. All rights reserved.

import Testing
@testable import Konjugieren

@MainActor
@Suite("Verb")
struct VerbTests {
  @Test func stammDropsEnSuffix() {
    #expect(Verb.verbs["machen"]?.stamm == "mach")
    #expect(Verb.verbs["singen"]?.stamm == "sing")
  }

  @Test func stammKeepsSeparablePrefix() {
    #expect(Verb.verbs["ankommen"]?.stamm == "ankomm")
  }

  @Test func stammDropsSingleCharacterForNonEnSuffix() {
    // "ändern" ends in "rn", not "en", so stamm drops only the trailing "n".
    #expect(Verb.verbs["ändern"]?.stamm == "änder")
  }

  @Test(arguments: ["machen", "ändern", "segeln", "tun", "sein"])
  func endingIsValidForRecognizedSuffixes(infinitiv: String) {
    #expect(Verb.endingIsValid(infinitiv: infinitiv))
  }

  @Test(arguments: ["xyzzy", "blorf", "auto", "haus"])
  func endingIsInvalidForUnrecognizedSuffixes(infinitiv: String) {
    #expect(!Verb.endingIsValid(infinitiv: infinitiv))
  }
}
