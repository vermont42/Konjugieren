// Copyright © 2026 Josh Adams. All rights reserved.

/// What the quiz asks, chosen by the learner. Each level adds conjugationgroups to the one before,
/// in the order of the ladder in `plans/pedagogy.md`, and nothing unlocks.
// Semantic ordering: each level adds to the one before.
enum QuizLevel: String, CaseIterable {
  case beginner
  case elementary
  case intermediate
  case advanced

  var localizedName: String {
    switch self {
    case .beginner:
      return L.QuizLevel.beginner
    case .elementary:
      return L.QuizLevel.elementary
    case .intermediate:
      return L.QuizLevel.intermediate
    case .advanced:
      return L.QuizLevel.advanced
    }
  }

  var systemImage: String {
    switch self {
    case .beginner:
      return "gauge.with.dots.needle.0percent"
    case .elementary:
      return "gauge.with.dots.needle.33percent"
    case .intermediate:
      return "gauge.with.dots.needle.67percent"
    case .advanced:
      return "gauge.with.dots.needle.100percent"
    }
  }

  /// The verbs a default quiz draws from, as Josh decided on 2026-11-13. Nil is the whole corpus.
  var band: FrequencyBand? {
    switch self {
    case .beginner:
      return .top100
    case .elementary:
      return .top300
    case .intermediate:
      return .top1000
    case .advanced:
      return nil
    }
  }

  var pool: [QuizPoolEntry] {
    switch self {
    case .beginner:
      return [
        QuizPoolEntry(.präsensIndikativ),
        QuizPoolEntry(.imperativ, persons: [.secondSingular, .secondPlural, .thirdPlural])
      ]
    case .elementary:
      return [
        QuizPoolEntry(.präsensIndikativ),
        QuizPoolEntry(.imperativ),
        QuizPoolEntry(.perfektIndikativ),
        QuizPoolEntry(.perfektpartizip),
        QuizPoolEntry(.präteritumIndikativ, verbs: .seinHabenModals)
      ]
    case .intermediate:
      return [
        QuizPoolEntry(.präsensIndikativ),
        QuizPoolEntry(.imperativ),
        QuizPoolEntry(.perfektIndikativ),
        QuizPoolEntry(.perfektpartizip),
        QuizPoolEntry(.präteritumIndikativ),
        QuizPoolEntry(.plusquamperfektIndikativ),
        QuizPoolEntry(.futurKonjunktivII),
        QuizPoolEntry(.präteritumKonjunktivII, verbs: .seinHabenWerdenModals),
        QuizPoolEntry(.plusquamperfektKonjunktivII),
        QuizPoolEntry(.futurIndikativ)
      ]
    case .advanced:
      return [
        QuizPoolEntry(.präsensIndikativ),
        QuizPoolEntry(.imperativ),
        QuizPoolEntry(.perfektIndikativ),
        QuizPoolEntry(.perfektpartizip),
        QuizPoolEntry(.präteritumIndikativ),
        QuizPoolEntry(.plusquamperfektIndikativ),
        QuizPoolEntry(.futurKonjunktivII),
        // A weak verb's Präteritum Konjunktiv II (machte) repeats its Präteritum Indikativ, so
        // asking it would teach nothing, as Josh decided on 2026-11-13.
        QuizPoolEntry(.präteritumKonjunktivII, verbs: .strongMixedSeinHabenWerdenModals),
        QuizPoolEntry(.plusquamperfektKonjunktivII),
        QuizPoolEntry(.futurIndikativ),
        QuizPoolEntry(.präsensKonjunktivI),
        QuizPoolEntry(.perfektKonjunktivI),
        QuizPoolEntry(.futurKonjunktivI),
        QuizPoolEntry(.präsenspartizip)
      ]
    }
  }
}

/// One kind of question a level asks: a table's cells, the verbs that may be asked them, and how
/// often the kind is drawn.
struct QuizPoolEntry: Equatable {
  let table: ConjugationTable
  let cells: [Conjugationgroup]
  let verbs: QuizVerbs

  init(_ table: ConjugationTable, persons: [PersonNumber]? = nil, verbs: QuizVerbs = .all) {
    self.table = table
    cells = table.cells.filter { cell in
      guard let persons, let personNumber = cell.personNumber else {
        return true
      }
      return persons.contains(personNumber)
    }
    self.verbs = verbs
  }

  // Josh chose these on 2026-11-13. Each kind is weighted as a whole, whatever its number of
  // cells, so a participle's one cell gets the least weight. The three Futurs are light because
  // only their auxiliary varies (T2.6). The weights never change with what the learner has done,
  // since Josh rejected adapting the quiz to the conjugationgroups opened (T2.4).
  var weight: Int {
    switch table {
    case .perfektIndikativ, .präsensIndikativ:
      return 3
    case .futurIndikativ, .futurKonjunktivI, .futurKonjunktivII, .perfektpartizip, .präsenspartizip:
      return 1
    case .imperativ, .perfektKonjunktivI, .plusquamperfektIndikativ, .plusquamperfektKonjunktivII, .präsensKonjunktivI, .präteritumIndikativ, .präteritumKonjunktivII:
      return 2
    }
  }

  var isParticiple: Bool {
    cells.count == 1 && cells.first?.personNumber == nil
  }
}

/// Which verbs a kind of question may be asked of.
enum QuizVerbs: Hashable {
  case all
  case seinHabenModals
  case seinHabenWerdenModals
  case strongMixedSeinHabenWerdenModals

  func admits(_ verb: Verb, reading: Reading) -> Bool {
    switch self {
    case .all:
      return true
    case .seinHabenModals:
      return Self.seinHaben.contains(verb.infinitiv) || VerbCollection.modalInfinitives.contains(verb.infinitiv)
    case .seinHabenWerdenModals:
      return verb.infinitiv == "werden" || Self.seinHabenModals.admits(verb, reading: reading)
    case .strongMixedSeinHabenWerdenModals:
      switch reading.family {
      case .mixed, .strong:
        return true
      case .ieren, .weak:
        return Self.seinHabenWerdenModals.admits(verb, reading: reading)
      }
    }
  }

  private static let seinHaben: Set<String> = ["haben", "sein"]
}
