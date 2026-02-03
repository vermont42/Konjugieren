// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

struct AblautGroupInfo: Identifiable {
  let exemplar: String

  var id: String { exemplar }

  var description: String {
    switch exemplar {
    case "beginnen":
      return L.AblautGroupInfo.beginnen
    case "bieten":
      return L.AblautGroupInfo.bieten
    case "bitten":
      return L.AblautGroupInfo.bitten
    case "bleiben":
      return L.AblautGroupInfo.bleiben
    case "bringen":
      return L.AblautGroupInfo.bringen
    case "dürfen":
      return L.AblautGroupInfo.dürfen
    case "empfehlen":
      return L.AblautGroupInfo.empfehlen
    case "essen":
      return L.AblautGroupInfo.essen
    case "erscheinen":
      return L.AblautGroupInfo.erscheinen
    case "fahren":
      return L.AblautGroupInfo.fahren
    case "fallen":
      return L.AblautGroupInfo.fallen
    case "fangen":
      return L.AblautGroupInfo.fangen
    case "finden":
      return L.AblautGroupInfo.finden
    case "fliegen":
      return L.AblautGroupInfo.fliegen
    case "geben":
      return L.AblautGroupInfo.geben
    case "gebären":
      return L.AblautGroupInfo.gebären
    case "gehen":
      return L.AblautGroupInfo.gehen
    case "greifen":
      return L.AblautGroupInfo.greifen
    case "gelingen":
      return L.AblautGroupInfo.gelingen
    case "gelten":
      return L.AblautGroupInfo.gelten
    case "gewinnen":
      return L.AblautGroupInfo.gewinnen
    case "haben":
      return L.AblautGroupInfo.haben
    case "halten":
      return L.AblautGroupInfo.halten
    case "heben":
      return L.AblautGroupInfo.heben
    case "heißen":
      return L.AblautGroupInfo.heißen
    case "kennen":
      return L.AblautGroupInfo.kennen
    case "kommen":
      return L.AblautGroupInfo.kommen
    case "können":
      return L.AblautGroupInfo.können
    case "laden":
      return L.AblautGroupInfo.laden
    case "lassen":
      return L.AblautGroupInfo.lassen
    case "laufen":
      return L.AblautGroupInfo.laufen
    case "liegen":
      return L.AblautGroupInfo.liegen
    case "mögen":
      return L.AblautGroupInfo.mögen
    case "müssen":
      return L.AblautGroupInfo.müssen
    case "nehmen":
      return L.AblautGroupInfo.nehmen
    case "rufen":
      return L.AblautGroupInfo.rufen
    case "reißen":
      return L.AblautGroupInfo.reißen
    case "schaffen":
      return L.AblautGroupInfo.schaffen
    case "schlagen":
      return L.AblautGroupInfo.schlagen
    case "schlafen":
      return L.AblautGroupInfo.schlafen
    case "schließen":
      return L.AblautGroupInfo.schließen
    case "schreien":
      return L.AblautGroupInfo.schreien
    case "schreiten":
      return L.AblautGroupInfo.schreiten
    case "schneiden":
      return L.AblautGroupInfo.schneiden
    case "sehen":
      return L.AblautGroupInfo.sehen
    case "sein":
      return L.AblautGroupInfo.sein
    case "singen":
      return L.AblautGroupInfo.singen
    case "sitzen":
      return L.AblautGroupInfo.sitzen
    case "sprechen":
      return L.AblautGroupInfo.sprechen
    case "stehen":
      return L.AblautGroupInfo.stehen
    case "steigen":
      return L.AblautGroupInfo.steigen
    case "sterben":
      return L.AblautGroupInfo.sterben
    case "stoßen":
      return L.AblautGroupInfo.stoßen
    case "streichen":
      return L.AblautGroupInfo.streichen
    case "tragen":
      return L.AblautGroupInfo.tragen
    case "treffen":
      return L.AblautGroupInfo.treffen
    case "treten":
      return L.AblautGroupInfo.treten
    case "tun":
      return L.AblautGroupInfo.tun
    case "verlieren":
      return L.AblautGroupInfo.verlieren
    case "wachsen":
      return L.AblautGroupInfo.wachsen
    case "weisen":
      return L.AblautGroupInfo.weisen
    case "werden":
      return L.AblautGroupInfo.werden
    case "werfen":
      return L.AblautGroupInfo.werfen
    case "wissen":
      return L.AblautGroupInfo.wissen
    case "wollen":
      return L.AblautGroupInfo.wollen
    case "ziehen":
      return L.AblautGroupInfo.ziehen
    default:
      return exemplar
    }
  }

  var verbs: [Verb] {
    Verb.verbsSortedAlphabetically.filter { $0.ablautGroup == exemplar }
  }

  var verbCount: Int {
    verbs.count
  }

  static let allGroups: [AblautGroupInfo] = [
    AblautGroupInfo(exemplar: "beginnen"),
    AblautGroupInfo(exemplar: "bieten"),
    AblautGroupInfo(exemplar: "bitten"),
    AblautGroupInfo(exemplar: "bleiben"),
    AblautGroupInfo(exemplar: "bringen"),
    AblautGroupInfo(exemplar: "dürfen"),
    AblautGroupInfo(exemplar: "empfehlen"),
    AblautGroupInfo(exemplar: "essen"),
    AblautGroupInfo(exemplar: "erscheinen"),
    AblautGroupInfo(exemplar: "fahren"),
    AblautGroupInfo(exemplar: "fallen"),
    AblautGroupInfo(exemplar: "fangen"),
    AblautGroupInfo(exemplar: "finden"),
    AblautGroupInfo(exemplar: "fliegen"),
    AblautGroupInfo(exemplar: "geben"),
    AblautGroupInfo(exemplar: "gebären"),
    AblautGroupInfo(exemplar: "gehen"),
    AblautGroupInfo(exemplar: "greifen"),
    AblautGroupInfo(exemplar: "gelingen"),
    AblautGroupInfo(exemplar: "gelten"),
    AblautGroupInfo(exemplar: "gewinnen"),
    AblautGroupInfo(exemplar: "haben"),
    AblautGroupInfo(exemplar: "halten"),
    AblautGroupInfo(exemplar: "heben"),
    AblautGroupInfo(exemplar: "heißen"),
    AblautGroupInfo(exemplar: "kennen"),
    AblautGroupInfo(exemplar: "kommen"),
    AblautGroupInfo(exemplar: "können"),
    AblautGroupInfo(exemplar: "laden"),
    AblautGroupInfo(exemplar: "lassen"),
    AblautGroupInfo(exemplar: "laufen"),
    AblautGroupInfo(exemplar: "liegen"),
    AblautGroupInfo(exemplar: "mögen"),
    AblautGroupInfo(exemplar: "müssen"),
    AblautGroupInfo(exemplar: "nehmen"),
    AblautGroupInfo(exemplar: "rufen"),
    AblautGroupInfo(exemplar: "reißen"),
    AblautGroupInfo(exemplar: "schaffen"),
    AblautGroupInfo(exemplar: "schlagen"),
    AblautGroupInfo(exemplar: "schlafen"),
    AblautGroupInfo(exemplar: "schließen"),
    AblautGroupInfo(exemplar: "schreien"),
    AblautGroupInfo(exemplar: "schreiten"),
    AblautGroupInfo(exemplar: "schneiden"),
    AblautGroupInfo(exemplar: "sehen"),
    AblautGroupInfo(exemplar: "sein"),
    AblautGroupInfo(exemplar: "singen"),
    AblautGroupInfo(exemplar: "sitzen"),
    AblautGroupInfo(exemplar: "sprechen"),
    AblautGroupInfo(exemplar: "stehen"),
    AblautGroupInfo(exemplar: "steigen"),
    AblautGroupInfo(exemplar: "sterben"),
    AblautGroupInfo(exemplar: "stoßen"),
    AblautGroupInfo(exemplar: "streichen"),
    AblautGroupInfo(exemplar: "tragen"),
    AblautGroupInfo(exemplar: "treffen"),
    AblautGroupInfo(exemplar: "treten"),
    AblautGroupInfo(exemplar: "tun"),
    AblautGroupInfo(exemplar: "verlieren"),
    AblautGroupInfo(exemplar: "wachsen"),
    AblautGroupInfo(exemplar: "weisen"),
    AblautGroupInfo(exemplar: "werden"),
    AblautGroupInfo(exemplar: "werfen"),
    AblautGroupInfo(exemplar: "wissen"),
    AblautGroupInfo(exemplar: "wollen"),
    AblautGroupInfo(exemplar: "ziehen")
  ]

  static var sortedAlphabetically: [AblautGroupInfo] {
    allGroups.sorted {
      $0.exemplar.compare($1.exemplar, locale: Locale(identifier: "de")) == .orderedAscending
    }
  }
}
