// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

struct AblautGroupInfo: Identifiable {
  let exemplar: String

  var id: String { exemplar }

  var description: String {
    NSLocalizedString("AblautGroupInfo.\(exemplar)", comment: "")
  }

  var verbs: [Verb] {
    Verb.verbsSortedAlphabetically.filter { $0.ablautGroup == exemplar }
  }

  var verbCount: Int {
    verbs.count
  }

  // Alphabetical per German locale (umlauts sort as base vowel, ß as ss)
  private static let exemplars = [
    "beginnen", "bieten", "bitten", "bleiben", "bringen",
    "dürfen", "empfehlen", "erscheinen", "essen",
    "fahren", "fallen", "fangen", "finden", "fliegen",
    "gebären", "geben", "gehen", "gelingen", "gelten", "gewinnen", "greifen",
    "haben", "halten", "heben", "heißen",
    "kennen", "kommen", "können",
    "laden", "lassen", "laufen", "liegen",
    "mögen", "müssen", "nehmen",
    "reißen", "rufen",
    "schaffen", "schlafen", "schlagen", "schließen", "schneiden", "schreien", "schreiten",
    "sehen", "sein", "singen", "sitzen", "sprechen", "stehen", "steigen", "sterben", "stoßen", "streichen",
    "tragen", "treffen", "treten", "tun",
    "verlieren", "wachsen", "weisen", "werden", "werfen", "wissen", "wollen",
    "ziehen"
  ]

  static let allGroups: [AblautGroupInfo] = exemplars.map { AblautGroupInfo(exemplar: $0) }
}
