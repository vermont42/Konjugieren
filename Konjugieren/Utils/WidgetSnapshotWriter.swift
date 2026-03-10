// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

enum WidgetSnapshotWriter {
  private static let referenceDate: Date = {
    Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 1)) ?? Date()
  }()

  @MainActor static func writeSnapshot() {
    guard let snapshot = generateSnapshot() else { return }
    guard let url = WidgetConstants.snapshotURL else { return }
    guard let data = try? JSONEncoder().encode(snapshot) else { return }
    try? data.write(to: url, options: .atomic)
  }

  @MainActor static func generateSnapshot(date: Date = Date()) -> WidgetSnapshot? {
    let eligible = eligibleVerbs()
    guard !eligible.isEmpty else { return nil }

    let debugOffset = WidgetConstants.sharedDefaults?.integer(forKey: WidgetConstants.debugOffsetKey) ?? 0
    let verb = verbOfTheDay(from: eligible, date: date, debugOffset: debugOffset)
    let paradigm = präsensParadigm(for: verb.infinitiv)
    let partizip = Conjugator.conjugate(infinitiv: verb.infinitiv, conjugationgroup: .perfektpartizip)
    let partizipString: String
    switch partizip {
    case .success(let value):
      partizipString = value
    case .failure:
      partizipString = ""
    }

    let examplePair = ExampleSentences.pair(for: verb.infinitiv)
    let etymology = Etymology.text(for: verb.infinitiv)
    let truncatedEtymology = etymology.map { truncateToSentenceBoundary($0, maxLength: 450) }
    let quiz = generateQuizQuestion(verb: verb, date: date, debugOffset: debugOffset)
    let dateString = Self.dateString(for: date)

    return WidgetSnapshot(
      infinitiv: verb.infinitiv,
      translation: verb.translation,
      familyDisplay: verb.family.displayName,
      auxiliary: verb.auxiliary.verb,
      frequency: verb.frequency,
      präsensParadigm: paradigm,
      perfektpartizip: partizipString,
      etymologySnippet: truncatedEtymology,
      exampleGerman: examplePair?.german.sentence,
      exampleEnglish: examplePair?.english.sentence,
      exampleSource: examplePair?.german.source,
      quizQuestion: quiz,
      dateString: dateString,
      debugOffset: debugOffset
    )
  }

  // MARK: - Verb Selection

  @MainActor static func eligibleVerbs() -> [Verb] {
    Verb.verbsSortedAlphabetically.filter { ExampleSentences.pair(for: $0.infinitiv) != nil }
  }

  @MainActor static func verbOfTheDay(from eligible: [Verb], date: Date, debugOffset: Int) -> Verb {
    let daysSinceReference = Calendar.current.dateComponents([.day], from: referenceDate, to: date).day ?? 0
    let index = abs((daysSinceReference + debugOffset) * 127) % eligible.count
    return eligible[index]
  }

  // MARK: - Conjugation Paradigm

  @MainActor private static func präsensParadigm(for infinitiv: String) -> [WidgetConjugation] {
    PersonNumber.allCases.map { pn in
      let result = Conjugator.conjugate(infinitiv: infinitiv, conjugationgroup: .präsensIndicativ(pn))
      let form: String
      switch result {
      case .success(let value):
        form = value
      case .failure:
        form = "?"
      }
      return WidgetConjugation(pronoun: pn.pronoun, mixedCaseForm: form)
    }
  }

  // MARK: - Quiz Question Generation

  @MainActor private static func generateQuizQuestion(verb: Verb, date: Date, debugOffset: Int) -> WidgetQuizQuestion {
    let seed = abs((Calendar.current.dateComponents([.day], from: referenceDate, to: date).day ?? 0) + debugOffset)
    let conjugationgroupOptions = regularConjugationgroups(seed: seed)
    let conjugationgroupIndex = (seed * 31) % conjugationgroupOptions.count
    let conjugationgroup = conjugationgroupOptions[conjugationgroupIndex]

    let correctResult = Conjugator.conjugate(infinitiv: verb.infinitiv, conjugationgroup: conjugationgroup)
    let correctAnswer: String
    switch correctResult {
    case .success(let value):
      correctAnswer = value
    case .failure:
      correctAnswer = "?"
    }

    let wrongAnswers = generateWrongAnswers(
      verb: verb,
      correctConjugationgroup: conjugationgroup,
      correctAnswer: correctAnswer,
      seed: seed
    )

    let pronoun: String?
    switch conjugationgroup {
    case .perfektpartizip, .präsenspartizip:
      pronoun = nil
    case .präsensIndicativ(let pn), .perfektIndikativ(let pn), .futurIndikativ(let pn):
      pronoun = pn.pronounWithSieDisambiguation
    case .imperativ(let pn):
      switch pn {
      case .secondSingular:
        pronoun = "du"
      case .secondPlural:
        pronoun = "ihr"
      case .firstPlural:
        pronoun = "wir"
      case .thirdPlural:
        pronoun = "Sie"
      default:
        pronoun = nil
      }
    default:
      pronoun = nil
    }

    let lang = Current.settings.conjugationgroupLang
    let displayName: String
    switch lang {
    case .german:
      displayName = conjugationgroup.germanDisplayName
    case .english:
      displayName = conjugationgroup.englishDisplayName
    }

    return WidgetQuizQuestion(
      infinitiv: verb.infinitiv,
      conjugationgroupDisplay: displayName,
      pronoun: pronoun,
      correctAnswer: correctAnswer.lowercased(),
      wrongAnswers: wrongAnswers,
      questionID: "\(dateString(for: Date()))-\(verb.infinitiv)"
    )
  }

  @MainActor private static func generateWrongAnswers(
    verb: Verb,
    correctConjugationgroup: Conjugationgroup,
    correctAnswer: String,
    seed: Int
  ) -> [String] {
    var candidates: [String] = []
    let allPersonNumbers = PersonNumber.allCases

    // Wrong 1: same conjugationgroup, different person
    for pn in allPersonNumbers {
      let altGroup = swapPerson(correctConjugationgroup, to: pn)
      guard let altGroup else { continue }
      let result = Conjugator.conjugate(infinitiv: verb.infinitiv, conjugationgroup: altGroup)
      if case .success(let form) = result, form.lowercased() != correctAnswer.lowercased() {
        candidates.append(form.lowercased())
        break
      }
    }

    // Wrong 2: same person, different conjugationgroup from regular pool
    let regularGroups = regularConjugationgroups(seed: seed + 7)
    for group in regularGroups {
      if group == correctConjugationgroup { continue }
      let result = Conjugator.conjugate(infinitiv: verb.infinitiv, conjugationgroup: group)
      if case .success(let form) = result, form.lowercased() != correctAnswer.lowercased(), !candidates.contains(form.lowercased()) {
        candidates.append(form.lowercased())
        break
      }
    }

    // Wrong 3: another person/conjugationgroup combo
    let otherGroups = regularConjugationgroups(seed: seed + 13)
    for group in otherGroups {
      let result = Conjugator.conjugate(infinitiv: verb.infinitiv, conjugationgroup: group)
      if case .success(let form) = result, form.lowercased() != correctAnswer.lowercased(), !candidates.contains(form.lowercased()) {
        candidates.append(form.lowercased())
        break
      }
    }

    // Pad with Perfektpartizip if we still need more
    while candidates.count < 3 {
      let fallback = Conjugator.conjugate(infinitiv: verb.infinitiv, conjugationgroup: .perfektpartizip)
      if case .success(let form) = fallback, form.lowercased() != correctAnswer.lowercased(), !candidates.contains(form.lowercased()) {
        candidates.append(form.lowercased())
      } else {
        candidates.append(correctAnswer.lowercased() + "x")
      }
    }

    return Array(candidates.prefix(3))
  }

  private static func regularConjugationgroups(seed: Int) -> [Conjugationgroup] {
    let persons = PersonNumber.allCases
    let imperativPersons = PersonNumber.imperativPersonNumbers
    let pnIndex = abs(seed) % persons.count
    let impIndex = abs(seed) % imperativPersons.count
    return [
      .präsensIndicativ(persons[pnIndex]),
      .perfektIndikativ(persons[(pnIndex + 1) % persons.count]),
      .futurIndikativ(persons[(pnIndex + 2) % persons.count]),
      .imperativ(imperativPersons[impIndex])
    ]
  }

  private static func swapPerson(_ conjugationgroup: Conjugationgroup, to personNumber: PersonNumber) -> Conjugationgroup? {
    switch conjugationgroup {
    case .präsensIndicativ:
      return .präsensIndicativ(personNumber)
    case .perfektIndikativ:
      return .perfektIndikativ(personNumber)
    case .futurIndikativ:
      return .futurIndikativ(personNumber)
    case .imperativ:
      guard PersonNumber.imperativPersonNumbers.contains(personNumber) else { return nil }
      return .imperativ(personNumber)
    default:
      return nil
    }
  }

  // MARK: - Utilities

  private static func truncateToSentenceBoundary(_ text: String, maxLength: Int) -> String {
    guard text.count > maxLength else { return text }
    let prefix = String(text.prefix(maxLength))
    if let lastPeriod = prefix.lastIndex(of: ".") {
      return String(prefix[...lastPeriod])
    }
    return prefix + "..."
  }

  static func dateString(for date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: date)
  }
}
