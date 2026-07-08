// Copyright © 2026 Josh Adams. All rights reserved.

@testable import Konjugieren
import Testing

@Suite("Refusal detection")
struct RefusalDetectionTests {
  @Test("Legitimate answers are not refusals", arguments: [
    "ich sang, du sangst, er sang",
    "Ablaut ist der Vokalwechsel bei starken Verben.",
    // "null" is the German word for zero; a sentence using it must survive.
    "Die Stunde Null bezeichnet den Neubeginn nach 1945.",
    "Zähle von null bis zehn: null, eins, zwei.",
    // English "nullify" contains the substring "null" but is a real word.
    "This rule does not nullify the ablaut pattern.",
  ])
  func legitimateAnswers(_ response: String) {
    #expect(LanguageModelServiceReal.refusalPhrase(in: response) == nil)
  }

  @Test("A bare literal null is still caught", arguments: [
    "null",
    "  null  ",
    "NULL",
    "\nnull\n",
  ])
  func literalNull(_ response: String) {
    #expect(LanguageModelServiceReal.refusalPhrase(in: response) == "null")
  }

  @Test("Known refusal phrases are caught and reported", arguments: zip(
    [
      "I can't assist with that request.",
      "That's outside the scope of what I do.",
      "Ich kann dir keine Prognosen geben.",
      "Ich bin ein Sprachmodell und kann das nicht.",
    ],
    [
      "can't assist",
      "outside the scope",
      "ich kann dir keine",
      "ich bin ein sprachmodell",
    ]
  ))
  func knownRefusals(_ response: String, _ expectedPhrase: String) {
    #expect(LanguageModelServiceReal.refusalPhrase(in: response) == expectedPhrase)
  }
}
