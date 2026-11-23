// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

/// Why a wrong quiz answer is wrong, in the cases where the conjugator can say so for certain.
/// Every case is an exact construction from the verb's own tables, never a guess at what the
/// learner meant, because a wrong diagnosis is worse than none. An answer that fits no case gets
/// none.
enum AnswerDiagnosis: Equatable {
  /// aufsteh for steh auf: a separable verb's du or ihr Imperativ puts its prefix at the end.
  case prefixAtEnd(prefix: String)
  /// gestanden auf, or auf gestanden, for aufgestanden.
  case participleIsOneWord(prefix: String)
  /// gegangen for ist gegangen, or gehen for wird gehen.
  case missingAuxiliary(Conjugationgroup)
  /// hat gegangen for ist gegangen, where no region's standard takes haben.
  case wrongAuxiliary(infinitiv: String, expected: Auxiliary, given: Auxiliary)
  /// gangen for gegangen, aufstanden for aufgestanden.
  case missingGe
  /// geverstanden: the prefix nearest the stem is inseparable.
  case geOnInseparable(prefix: String)
  /// gestudiert.
  case geOnIeren
  /// geaufstanden.
  case geBeforeSeparablePrefix(prefix: String)
  /// gehte, gesingt, denkte: a strong or mixed verb conjugated as a weak one.
  case weakConjugation(infinitiv: String, isMixed: Bool)
  /// hängte for hing: the asked cell of the verb's other reading.
  case otherReading(infinitiv: String, translation: String)
  /// kommt for du kommst: another person of the asked conjugationgroup.
  case otherPerson([PersonNumber], isImperativ: Bool)
  /// ging for the Perfekt: another conjugationgroup. Its persons are named only when the asked
  /// person is not among them.
  case otherConjugationgroup(Conjugationgroup, persons: [PersonNumber])

  /// The one line the quiz shows, in the app's language, with conjugationgroups named in the
  /// language the settings choose for them.
  var line: String {
    let lang = Current.settings.conjugationgroupLang
    switch self {
    case .prefixAtEnd(let prefix):
      return L.Diagnosis.prefixAtEnd(Conjugationgroup.imperativ(.secondSingular).displayName(lang: lang), prefix)
    case .participleIsOneWord(let prefix):
      return L.Diagnosis.participleIsOneWord(prefix)
    case .missingAuxiliary(let conjugationgroup):
      return L.Diagnosis.missingAuxiliary(conjugationgroup.displayName(lang: lang))
    case let .wrongAuxiliary(infinitiv, expected, given):
      return L.Diagnosis.wrongAuxiliary(infinitiv.inUserRegion, expected.verb, given.verb)
    case .missingGe:
      return L.Diagnosis.missingGe
    case .geOnInseparable(let prefix):
      return L.Diagnosis.geOnInseparable(prefix)
    case .geOnIeren:
      return L.Diagnosis.geOnIeren
    case .geBeforeSeparablePrefix(let prefix):
      return L.Diagnosis.geBeforeSeparablePrefix(prefix)
    case let .weakConjugation(infinitiv, isMixed):
      return isMixed ? L.Diagnosis.weakConjugationMixed(infinitiv.inUserRegion) : L.Diagnosis.weakConjugationStrong(infinitiv.inUserRegion)
    case let .otherReading(infinitiv, translation):
      return L.Diagnosis.otherReading(infinitiv.inUserRegion, translation)
    case let .otherPerson(persons, isImperativ):
      return L.Diagnosis.otherPerson(Self.names(of: persons, isImperativ: isImperativ))
    case let .otherConjugationgroup(conjugationgroup, persons):
      let name = conjugationgroup.displayName(lang: lang)
      guard !persons.isEmpty else {
        return L.Diagnosis.otherConjugationgroup(name)
      }
      return L.Diagnosis.otherConjugationgroupPersons(name, Self.names(of: persons, isImperativ: conjugationgroup.isImperativ))
    }
  }

  private static func names(of persons: [PersonNumber], isImperativ: Bool) -> String {
    let pronouns = persons.map { person in
      isImperativ ? (person.imperativPronoun ?? person.pronoun) : person.pronounWithSieDisambiguation
    }
    return ListFormatter.localizedString(byJoining: pronouns)
  }
}

extension QuizItem {
  /// The diagnosis of a wrong answer, or nil when it is right or nothing certain can be said.
  /// The checks run from the most specific explanation to the least and stop at the first that
  /// fits, since one answer can fit several: macht for gemacht is both a participle without ge-
  /// and er's Präsens, and the first says more about the learner's error.
  func diagnosis(of answer: String) -> AnswerDiagnosis? {
    guard !accepts(answer) else {
      return nil
    }
    let candidates = Set(AnswerSpelling.candidates(for: answer, in: conjugationgroup).filter { !$0.isEmpty })
    guard !candidates.isEmpty else {
      return nil
    }
    let diagnoser = AnswerDiagnoser(item: self, candidates: candidates)
    return diagnoser.otherReading()
      ?? diagnoser.separablePrefixOrder()
      ?? diagnoser.missingAuxiliary()
      ?? diagnoser.wrongAuxiliary()
      ?? diagnoser.participleGe()
      ?? diagnoser.weakConjugation()
      ?? diagnoser.otherCell()
  }
}

/// The checks behind `QuizItem.diagnosis(of:)`. Each builds the wrong conjugations a particular
/// error would produce, in every region's spelling and with any umlaut written as a digraph, and
/// asks whether the learner's answer is one of them.
private struct AnswerDiagnoser {
  let item: QuizItem
  let candidates: Set<String>
  let reading: Reading
  let matches: [ConjugationMatch]

  init(item: QuizItem, candidates: Set<String>) {
    self.item = item
    self.candidates = candidates
    reading = item.verb.reading(at: item.readingIndex) ?? item.verb.primaryReading
    // A finite part alone (steht for aufstehen) is a missing prefix, which no line names yet.
    matches = candidates.flatMap { item.verb.conjugations(matching: $0) }.filter { !$0.isFinitePart }
  }

  private var conjugationgroup: Conjugationgroup {
    item.conjugationgroup
  }

  private func isAnswer(among wrongConjugations: some Sequence<String>) -> Bool {
    let spellings = wrongConjugations.reduce(into: Set<String>()) { spellings, conjugation in
      spellings.formUnion(AnswerSpelling.digraphSpellings(of: conjugation.lowercased()))
    }
    return !candidates.isDisjoint(with: spellings)
  }

  /// The asked cell of `reading`, which may be hypothetical, in every region and clause.
  private func cell(of reading: Reading, auxiliary: ((Region) -> Auxiliary)? = nil) -> [String] {
    Region.allCases.flatMap { region in
      Clause.allCases.compactMap { clause in
        try? Conjugator.conjugate(
          reading: reading,
          conjugationgroup: conjugationgroup,
          auxiliary: auxiliary?(region) ?? reading.regionalAuxiliary(in: region),
          clause: clause
        ).get().inRegion(region)
      }
    }
  }

  /// The asked reading's Perfektpartizip, lowercased and region-free, for the participle checks
  /// to take apart by position. Region spellings are applied afterward, since Swiss ss would
  /// shift the positions of a prefix such as groß.
  private var participle: String? {
    try? Conjugator.conjugate(reading: reading, conjugationgroup: .perfektpartizip).get().lowercased()
  }

  /// Wrong participles, as the asked cell would hold them: alone for the Perfektpartizip, and
  /// after each region's auxiliary for a Perfekt or Plusquamperfekt. Empty for any other cell.
  private func cellsHolding(participles: [String]) -> [String] {
    switch conjugationgroup {
    case .perfektpartizip:
      return Region.allCases.flatMap { region in participles.map { $0.inRegion(region) } }
    case .perfektIndikativ, .perfektKonjunktivI, .plusquamperfektIndikativ, .plusquamperfektKonjunktivII:
      return Region.allCases.flatMap { region in
        let compound = (try? Conjugator.conjugate(
          reading: reading,
          conjugationgroup: conjugationgroup,
          auxiliary: reading.regionalAuxiliary(in: region)
        ).get()) ?? ""
        guard let auxiliary = compound.split(separator: " ").first else {
          return [String]()
        }
        return participles.map { (auxiliary + " " + $0).inRegion(region) }
      }
    case .präsenspartizip, .präsensIndikativ, .präsensKonjunktivI, .präteritumIndikativ, .präteritumKonjunktivII, .imperativ,
      .futurIndikativ, .futurKonjunktivI, .futurKonjunktivII:
      return []
    }
  }

  func otherReading() -> AnswerDiagnosis? {
    guard let match = matches.first(where: { $0.readingIndex != item.readingIndex && $0.conjugationgroup == conjugationgroup }),
          let other = item.verb.reading(at: match.readingIndex) else {
      return nil
    }
    return .otherReading(infinitiv: item.verb.infinitiv, translation: other.translation)
  }

  func separablePrefixOrder() -> AnswerDiagnosis? {
    let run = reading.prefixes.separableRun.lowercased()
    guard !run.isEmpty else {
      return nil
    }
    switch conjugationgroup {
    case .imperativ(.secondSingular), .imperativ(.secondPlural):
      // The wir and Sie Imperativ are left out: their frame has a blank on each side of the
      // pronoun, which already says where the prefix goes.
      let reversed = cell(of: reading).flatMap { conjugation -> [String] in
        let conjugation = conjugation.lowercased()
        guard conjugation.hasSuffix(" " + run) else {
          return []
        }
        let finite = conjugation.dropLast(run.count + 1)
        return [run + finite, run + " " + finite]
      }
      return isAnswer(among: reversed) ? .prefixAtEnd(prefix: run) : nil
    default:
      guard let participle, participle.hasPrefix(run) else {
        return nil
      }
      let rest = participle.dropFirst(run.count)
      let split = cellsHolding(participles: [rest + " " + run, run + " " + rest])
      return isAnswer(among: split) ? .participleIsOneWord(prefix: run) : nil
    }
  }

  func missingAuxiliary() -> AnswerDiagnosis? {
    let secondParts: [String]
    switch conjugationgroup {
    case .perfektIndikativ, .perfektKonjunktivI, .plusquamperfektIndikativ, .plusquamperfektKonjunktivII:
      guard let participle else {
        return nil
      }
      secondParts = Region.allCases.map { participle.inRegion($0) }
    case .futurIndikativ, .futurKonjunktivI, .futurKonjunktivII:
      secondParts = Region.allCases.map { item.verb.infinitiv.inRegion($0) }
    case .perfektpartizip, .präsenspartizip, .präsensIndikativ, .präsensKonjunktivI, .präteritumIndikativ, .präteritumKonjunktivII, .imperativ:
      return nil
    }
    return isAnswer(among: secondParts) ? .missingAuxiliary(conjugationgroup) : nil
  }

  /// Fires only for an auxiliary that no region's standard allows, since stehen's ist gestanden
  /// is already a right answer in Austria and Switzerland.
  func wrongAuxiliary() -> AnswerDiagnosis? {
    switch conjugationgroup {
    case .perfektIndikativ, .perfektKonjunktivI, .plusquamperfektIndikativ, .plusquamperfektKonjunktivII:
      break
    case .perfektpartizip, .präsenspartizip, .präsensIndikativ, .präsensKonjunktivI, .präteritumIndikativ, .präteritumKonjunktivII, .imperativ,
      .futurIndikativ, .futurKonjunktivI, .futurKonjunktivII:
      return nil
    }
    let allowed = Set(Region.allCases.map { reading.regionalAuxiliary(in: $0) })
    for given in [Auxiliary.haben, .sein] where !allowed.contains(given) {
      if isAnswer(among: cell(of: reading, auxiliary: { _ in given })) {
        return .wrongAuxiliary(infinitiv: item.verb.infinitiv, expected: reading.auxiliary, given: given)
      }
    }
    return nil
  }

  /// The ge- of the participle: missing, before a separable prefix rather than after it, or
  /// added to a verb that takes none. The ge- sits right after the separable prefixes, which is
  /// where `Conjugator` puts it too.
  func participleGe() -> AnswerDiagnosis? {
    guard let participle else {
      return nil
    }
    let prefixes = reading.prefixes
    let run = prefixes.separableRun.lowercased()
    let rest = participle.hasPrefix(run) ? String(participle.dropFirst(run.count)) : participle
    if case .ieren = reading.family {
      return isAnswer(among: cellsHolding(participles: [run + "ge" + rest])) ? .geOnIeren : nil
    }
    guard prefixes.takesGe else {
      guard let inseparable = prefixes.last?.name?.lowercased() else {
        return nil
      }
      let added = cellsHolding(participles: ["ge" + participle, run + "ge" + rest])
      return isAnswer(among: added) ? .geOnInseparable(prefix: inseparable) : nil
    }
    let head = String(participle.prefix(prefixes.totalLength))
    let afterHead = participle.dropFirst(head.count)
    guard afterHead.hasPrefix("ge") else {
      return nil
    }
    let base = afterHead.dropFirst(2)
    if isAnswer(among: cellsHolding(participles: [head + base])) {
      return .missingGe
    }
    if !head.isEmpty, isAnswer(among: cellsHolding(participles: ["ge" + head + base])) {
      return .geBeforeSeparablePrefix(prefix: head)
    }
    return nil
  }

  /// The asked cell as it would be were the reading weak: gehte, gesingt, denkte, and fahrst,
  /// which is fährst without the vowel change that only a strong verb makes.
  func weakConjugation() -> AnswerDiagnosis? {
    let isMixed: Bool
    switch reading.family {
    case .strong:
      isMixed = false
    case .mixed:
      isMixed = true
    case .weak, .ieren:
      return nil
    }
    let weak = Reading(
      infinitiv: reading.infinitiv,
      translation: reading.translation,
      family: .weak,
      auxiliary: reading.auxiliary,
      prefixes: reading.prefixes,
      auxiliaryIsRegional: reading.auxiliaryIsRegional
    )
    return isAnswer(among: cell(of: weak)) ? .weakConjugation(infinitiv: item.verb.infinitiv, isMixed: isMixed) : nil
  }

  /// Another cell of the asked reading. Another person of the asked conjugationgroup is named
  /// first, since it is the nearer error: fahrt for er fährt is ihr's Präsens before it is ihr's
  /// Imperativ.
  func otherCell() -> AnswerDiagnosis? {
    let own = matches.filter { $0.readingIndex == item.readingIndex && $0.conjugationgroup != conjugationgroup }
    let sameGroup = own.filter { $0.conjugationgroup.germanDisplayName == conjugationgroup.germanDisplayName }
    if !sameGroup.isEmpty {
      return .otherPerson(Self.persons(of: sameGroup), isImperativ: conjugationgroup.isImperativ)
    }
    guard let first = own.first else {
      return nil
    }
    var persons = Self.persons(of: own.filter { $0.conjugationgroup.germanDisplayName == first.conjugationgroup.germanDisplayName })
    if let asked = conjugationgroup.personNumber, persons.contains(asked) {
      persons = []
    }
    return .otherConjugationgroup(first.conjugationgroup, persons: persons)
  }

  /// Distinct, in the conjugation table's order.
  private static func persons(of matches: [ConjugationMatch]) -> [PersonNumber] {
    let found = Set(matches.compactMap(\.conjugationgroup.personNumber))
    return PersonNumber.allCases.filter { found.contains($0) }
  }
}
