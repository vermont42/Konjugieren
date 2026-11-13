// Copyright © 2026 Josh Adams. All rights reserved.

/// One table of the verb page: a conjugationgroup without its person.
///
/// The simple conjugationgroups come first and the compound ones after them, and each block is
/// ordered by how often its conjugationgroup occurs in a sample of the text corpus, with one
/// exception: the two participles, one conjugation each, close the simple block rather than
/// sitting between the six-row tables, as Josh chose for the page's look.
/// docs/conjugationgroup-frequency.md gives the counts, and scripts/count_conjugationgroups.py
/// reproduces them. Change the order there before changing it here.
// Semantic ordering: the verb page's order, top to bottom.
enum ConjugationTable: CaseIterable {
  case präsensIndikativ
  case präteritumIndikativ
  case präteritumKonjunktivII
  case präsensKonjunktivI
  case imperativ
  case perfektpartizip
  case präsenspartizip
  case perfektIndikativ
  case futurIndikativ
  case plusquamperfektIndikativ
  case futurKonjunktivII
  case plusquamperfektKonjunktivII
  case perfektKonjunktivI
  case futurKonjunktivI

  /// The cells, in the order the table shows them.
  var cells: [Conjugationgroup] {
    switch self {
    case .perfektpartizip:
      return [.perfektpartizip]
    case .präsenspartizip:
      return [.präsenspartizip]
    case .imperativ:
      return PersonNumber.imperativPersonNumbers.map(Conjugationgroup.imperativ)
    case .präsensIndikativ:
      return PersonNumber.allCases.map(Conjugationgroup.präsensIndikativ)
    case .präteritumIndikativ:
      return PersonNumber.allCases.map(Conjugationgroup.präteritumIndikativ)
    case .präteritumKonjunktivII:
      return PersonNumber.allCases.map(Conjugationgroup.präteritumKonjunktivII)
    case .präsensKonjunktivI:
      return PersonNumber.allCases.map(Conjugationgroup.präsensKonjunktivI)
    case .perfektIndikativ:
      return PersonNumber.allCases.map(Conjugationgroup.perfektIndikativ)
    case .futurIndikativ:
      return PersonNumber.allCases.map(Conjugationgroup.futurIndikativ)
    case .plusquamperfektIndikativ:
      return PersonNumber.allCases.map(Conjugationgroup.plusquamperfektIndikativ)
    case .futurKonjunktivII:
      return PersonNumber.allCases.map(Conjugationgroup.futurKonjunktivII)
    case .plusquamperfektKonjunktivII:
      return PersonNumber.allCases.map(Conjugationgroup.plusquamperfektKonjunktivII)
    case .perfektKonjunktivI:
      return PersonNumber.allCases.map(Conjugationgroup.perfektKonjunktivI)
    case .futurKonjunktivI:
      return PersonNumber.allCases.map(Conjugationgroup.futurKonjunktivI)
    }
  }

  /// The tables grouped as the iPad's two-column grid shows them, one group to a cell. A
  /// participle, one conjugation tall, joins the group above it: the Imperativ's cell holds both
  /// participles beneath it, as an iPhone shows them, rather than a participle sitting alone
  /// beside a six-row table.
  static let stacks: [[ConjugationTable]] = allCases.reduce(into: []) { stacks, table in
    if table.cells.count == 1, !stacks.isEmpty {
      stacks[stacks.count - 1].append(table)
    } else {
      stacks.append([table])
    }
  }

  /// A cell that stands for the whole table, for its name.
  var representative: Conjugationgroup {
    cells.first ?? .perfektpartizip
  }

  var isCompound: Bool {
    switch self {
    case .präsensIndikativ, .präteritumIndikativ, .präteritumKonjunktivII, .präsensKonjunktivI, .imperativ, .perfektpartizip, .präsenspartizip:
      return false
    case .perfektIndikativ, .futurIndikativ, .plusquamperfektIndikativ, .futurKonjunktivII, .plusquamperfektKonjunktivII, .perfektKonjunktivI, .futurKonjunktivI:
      return true
    }
  }

  /// The identifier the verb page scrolls to.
  var scrollID: String {
    representative.germanDisplayName
  }

  /// The `Info.stableKey` of the article about this conjugationgroup.
  var articleKey: String {
    switch self {
    case .perfektpartizip:
      return "perfektpartizip"
    case .präsenspartizip:
      return "praesenspartizip"
    case .präsensIndikativ:
      return "praesens_indikativ"
    case .präteritumIndikativ:
      return "praeteritum_indikativ"
    case .präsensKonjunktivI:
      return "praesens_konjunktiv_i"
    case .präteritumKonjunktivII:
      return "praeteritum_konjunktiv_ii"
    case .imperativ:
      return "imperativ"
    case .perfektIndikativ:
      return "perfekt_indikativ"
    case .perfektKonjunktivI:
      return "perfekt_konjunktiv_i"
    case .plusquamperfektIndikativ:
      return "plusquamperfekt_indikativ"
    case .plusquamperfektKonjunktivII:
      return "plusquamperfekt_konjunktiv_ii"
    case .futurIndikativ:
      return "futur_indikativ"
    case .futurKonjunktivI:
      return "futur_konjunktiv_i"
    case .futurKonjunktivII:
      return "futur_konjunktiv_ii"
    }
  }

  var article: Info? {
    Info.infos.first { $0.stableKey == articleKey }
  }

  func displayName(lang: ConjugationgroupLang) -> String {
    representative.displayName(lang: lang)
  }

  /// The name a textbook uses, shown under the heading as "also Partizip II". Each list belongs
  /// to its heading language rather than to the learner's locale, as the headings themselves
  /// do: a learner who reads German headings meets the German textbook names.
  func secondName(lang: ConjugationgroupLang) -> SecondName {
    switch lang {
    case .german:
      return SecondName(text: germanSecondName, isGerman: true)
    case .english:
      return englishSecondName
    }
  }

  struct SecondName: Equatable {
    let text: String

    /// Whether VoiceOver should speak it with a German voice: Partizip II is German even
    /// beside English headings.
    let isGerman: Bool
  }

  private var germanSecondName: String {
    switch self {
    case .perfektpartizip:
      return "Partizip II"
    case .präsenspartizip:
      return "Partizip I"
    case .präsensIndikativ:
      return "Gegenwart"
    case .präteritumIndikativ:
      return "Imperfekt"
    case .präsensKonjunktivI:
      return "Konjunktiv I"
    case .präteritumKonjunktivII:
      return "Konjunktiv II"
    case .imperativ:
      return "Befehlsform"
    case .perfektIndikativ:
      return "vollendete Gegenwart"
    case .perfektKonjunktivI:
      return "Konjunktiv I der Vergangenheit"
    case .plusquamperfektIndikativ:
      return "vollendete Vergangenheit"
    case .plusquamperfektKonjunktivII:
      return "Konjunktiv II der Vergangenheit"
    case .futurIndikativ:
      return "Futur I"
    case .futurKonjunktivI:
      return "Konjunktiv I des Futurs"
    case .futurKonjunktivII:
      return "würde-Form"
    }
  }

  private var englishSecondName: SecondName {
    switch self {
    case .perfektpartizip:
      return SecondName(text: "Partizip II", isGerman: true)
    case .präsenspartizip:
      return SecondName(text: "Partizip I", isGerman: true)
    case .präsensIndikativ:
      return SecondName(text: "Present Tense", isGerman: false)
    case .präteritumIndikativ:
      return SecondName(text: "Simple Past", isGerman: false)
    case .präsensKonjunktivI:
      return SecondName(text: "Subjunctive I", isGerman: false)
    case .präteritumKonjunktivII:
      return SecondName(text: "Subjunctive II", isGerman: false)
    case .imperativ:
      return SecondName(text: "Command Form", isGerman: false)
    case .perfektIndikativ:
      return SecondName(text: "Conversational Past", isGerman: false)
    case .perfektKonjunktivI:
      return SecondName(text: "Past Subjunctive I", isGerman: false)
    case .plusquamperfektIndikativ:
      return SecondName(text: "Past Perfect", isGerman: false)
    case .plusquamperfektKonjunktivII:
      return SecondName(text: "Past Subjunctive II", isGerman: false)
    case .futurIndikativ:
      return SecondName(text: "Futur I", isGerman: true)
    case .futurKonjunktivI:
      return SecondName(text: "Future Subjunctive I", isGerman: false)
    case .futurKonjunktivII:
      return SecondName(text: "würde + Infinitive", isGerman: true)
    }
  }
}

extension Conjugationgroup {
  /// Every cell of a verb's tables, in the verb page's order.
  static let allCells: [Conjugationgroup] = ConjugationTable.allCases.flatMap(\.cells)

  /// The verb-page table this cell belongs to.
  var table: ConjugationTable {
    switch self {
    case .perfektpartizip:
      return .perfektpartizip
    case .präsenspartizip:
      return .präsenspartizip
    case .präsensIndikativ:
      return .präsensIndikativ
    case .präsensKonjunktivI:
      return .präsensKonjunktivI
    case .präteritumIndikativ:
      return .präteritumIndikativ
    case .präteritumKonjunktivII:
      return .präteritumKonjunktivII
    case .imperativ:
      return .imperativ
    case .perfektIndikativ:
      return .perfektIndikativ
    case .perfektKonjunktivI:
      return .perfektKonjunktivI
    case .plusquamperfektIndikativ:
      return .plusquamperfektIndikativ
    case .plusquamperfektKonjunktivII:
      return .plusquamperfektKonjunktivII
    case .futurIndikativ:
      return .futurIndikativ
    case .futurKonjunktivI:
      return .futurKonjunktivI
    case .futurKonjunktivII:
      return .futurKonjunktivII
    }
  }
}
