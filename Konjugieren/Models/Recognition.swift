// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

/// Name the Conjugation: the quiz shows a conjugation, such
/// as käme, and the learner types its infinitive and chooses its conjugationgroup and person. This
/// is the direction a reader needs, and practice develops in the direction practiced.
extension QuizScope {
  static func recognition() -> QuizScope {
    QuizScope(verbs: nil, readingIndex: nil, questionCount: Quiz.questionCount, source: .recognition, isRecognition: true)
  }
}

/// One cell of one verb whose conjugation is a recognition question's prompt.
struct RecognitionCell: Hashable {
  let infinitiv: String
  let readingIndex: Int
  let conjugationgroup: Conjugationgroup
}

/// The three parts of a recognition answer.
enum RecognitionPart: CaseIterable {
  case conjugationgroup
  case infinitive
  case person
}

/// A learner's answer: a typed infinitive, a chosen table, and, unless the table is a participle,
/// a chosen person.
struct RecognitionAnswer: Equatable {
  let infinitiv: String
  let table: ConjugationTable
  let personNumber: PersonNumber?

  /// The cell the table and person name, or nil while a finite table lacks its person.
  var conjugationgroup: Conjugationgroup? {
    table.cells.first { $0.personNumber == personNumber }
  }

  /// "kommen · Präteritum Konjunktiv II · ich", for the results and the correction.
  func summary(lang: ConjugationgroupLang) -> String {
    let infinitiv = AnswerSpelling.normalized(self.infinitiv)
    let person = personNumber.map { RecognitionQuestion.personLabel($0, in: table) }
    return [infinitiv, table.representative.displayName(lang: lang), person].compactMap { $0 }.joined(separator: " · ")
  }
}

/// How a recognition answer fared: which parts are wrong, and whether any part was right, which
/// earns one more try at half points, as a slip does (Josh, 2026-11-15).
struct RecognitionGrade: Equatable {
  let wrongParts: Set<RecognitionPart>
  let hasRightPart: Bool

  var isCorrect: Bool {
    wrongParts.isEmpty
  }

  var earnsSecondAttempt: Bool {
    !isCorrect && hasRightPart
  }

  /// What to check, in the order the parts are read: "Check the conjugationgroup and the person."
  var line: String {
    let wrong = wrongParts
    switch (wrong.contains(.infinitive), wrong.contains(.conjugationgroup), wrong.contains(.person)) {
    case (true, false, false):
      return L.Recognition.checkInfinitive
    case (false, true, false):
      return L.Recognition.checkConjugationgroup
    case (false, false, true):
      return L.Recognition.checkPerson
    case (true, true, false):
      return L.Recognition.checkInfinitiveAndConjugationgroup
    case (true, false, true):
      return L.Recognition.checkInfinitiveAndPerson
    case (false, true, true):
      return L.Recognition.checkConjugationgroupAndPerson
    case (false, false, false), (true, true, true):
      return ""
    }
  }
}

/// A recognition question: the prompt, every cell of every verb that writes it, and the tables
/// the learner chooses among.
///
/// A conjugation often belongs to several cells (kommen is the Präsens and the Konjunktiv I of wir
/// and sie), to both readings of a verb (fuhr), or to two verbs (weiß, wissen's and weißen's).
/// Every one is a right answer, since the prompt gives no context to choose between them, and
/// none is avoided, since deciding which cells a text can be is the skill being practiced. Only
/// cells of the offered tables count, since the learner cannot choose any other.
struct RecognitionQuestion: Equatable {
  /// As the conjugator writes it in the user's region, ablaut in capitals: kÄme, kAm an.
  let prompt: String
  let cells: [RecognitionCell]
  /// The level's tables, in the verb page's order.
  let tables: [ConjugationTable]

  init(prompt: String, cells: [RecognitionCell], tables: [ConjugationTable]) {
    self.prompt = prompt
    self.cells = cells
    self.tables = tables
  }

  init(verb: Verb, conjugationgroup: Conjugationgroup, readingIndex: Int, tables: [ConjugationTable], map: ConjugationMap = .bundled) {
    let prompt = RegionalConjugator.conjugateUnsafely(infinitiv: verb.infinitiv, conjugationgroup: conjugationgroup, readingIndex: readingIndex)
    let asked = RecognitionCell(infinitiv: verb.infinitiv, readingIndex: readingIndex, conjugationgroup: conjugationgroup)
    let cells = Self.cells(writing: prompt, asked: asked, map: map).filter { tables.contains($0.conjugationgroup.table) }
    self.init(prompt: prompt, cells: cells, tables: tables)
  }

  /// The tables a level asks, in the verb page's order.
  static func tables(for pool: [QuizPoolEntry]) -> [ConjugationTable] {
    let asked = Set(pool.map(\.table))
    return ConjugationTable.allCases.filter(asked.contains)
  }

  /// Every cell of every verb that writes `prompt`, the asked verb's first.
  ///
  /// The conjugation map names the verbs to try: those with an entry for a word of the prompt,
  /// whole (gekommen in ist gekommen) or as a finite part whose particle the prompt also holds
  /// (kam in kam an). Each is then matched cell by cell. A finite part alone is not the verb: kam
  /// is ankommen's only in a sentence that ends with an, so the prompt kam does not accept it.
  static func cells(writing prompt: String, asked: RecognitionCell, map: ConjugationMap) -> [RecognitionCell] {
    let words = AnswerSpelling.normalized(prompt).split(separator: " ").map(String.init)
    var infinitives = [asked.infinitiv]
    for word in words {
      for entry in map.entries(for: word) where entry.particle.map(words.contains) ?? true {
        if !infinitives.contains(entry.infinitiv) {
          infinitives.append(entry.infinitiv)
        }
      }
    }
    var cells = infinitives.flatMap { infinitiv in
      (Verb.verbs[infinitiv]?.conjugations(matching: prompt) ?? [])
        .filter { !$0.isFinitePart }
        .map { RecognitionCell(infinitiv: infinitiv, readingIndex: $0.readingIndex, conjugationgroup: $0.conjugationgroup) }
    }
    if !cells.contains(asked) {
      cells.insert(asked, at: 0)
    }
    return cells
  }

  /// The persons a table's chips offer: none for a participle, four for the Imperativ.
  static func persons(of table: ConjugationTable) -> [PersonNumber] {
    table.cells.compactMap(\.personNumber)
  }

  /// "er", "sie (3p)", or for the Imperativ's formal address, "Sie".
  static func personLabel(_ personNumber: PersonNumber, in table: ConjugationTable) -> String {
    if table == .imperativ, let pronoun = personNumber.imperativPronoun {
      return pronoun
    }
    return personNumber.pronounWithSieDisambiguation
  }

  /// Whether a typed infinitive is this one, as the quiz grades: case and spacing aside, with an
  /// umlaut writable as a digraph and ß as ss.
  static func spells(_ typed: String, _ infinitiv: String) -> Bool {
    let typed = AnswerSpelling.normalized(typed)
    let lowered = infinitiv.lowercased()
    return AnswerSpelling.digraphSpellings(of: lowered).contains(typed)
      || AnswerSpelling.digraphSpellings(of: lowered.replacingOccurrences(of: "ß", with: "ss")).contains(typed)
  }

  /// Which parts of an answer are wrong, judged against the cells of the typed verb when it is
  /// one of them, and against every cell otherwise. A part is called wrong only when changing it
  /// alone, or with the other parts called wrong, can make the answer right, so a repair prompt
  /// never sends the learner to change something that was right.
  func grade(_ answer: RecognitionAnswer) -> RecognitionGrade {
    let ofInfinitive = cells.filter { Self.spells(answer.infinitiv, $0.infinitiv) }
    let infinitiveIsRight = !ofInfinitive.isEmpty
    let candidates = infinitiveIsRight ? ofInfinitive : cells
    var wrong: Set<RecognitionPart> = infinitiveIsRight ? [] : [.infinitive]

    if let chosen = answer.conjugationgroup, candidates.contains(where: { $0.conjugationgroup == chosen }) {
      return RecognitionGrade(wrongParts: wrong, hasRightPart: true)
    }
    if candidates.contains(where: { $0.conjugationgroup.table == answer.table }) {
      wrong.insert(.person)
      return RecognitionGrade(wrongParts: wrong, hasRightPart: true)
    }
    wrong.insert(.conjugationgroup)
    // A person is judged only between tables that have persons. Between a participle and a
    // finite table, the conjugationgroup alone is wrong, and the person follows from it.
    let personIsRight = answer.personNumber.map { person in
      candidates.contains { $0.conjugationgroup.personNumber == person }
    } ?? false
    if answer.personNumber != nil, !personIsRight, candidates.contains(where: { $0.conjugationgroup.personNumber != nil }) {
      wrong.insert(.person)
    }
    return RecognitionGrade(wrongParts: wrong, hasRightPart: infinitiveIsRight || personIsRight)
  }

  /// The right answers as the correction lists them, one line per verb and table, the persons
  /// together: "kommen · Präteritum Konjunktiv II · ich, er".
  func answerLines(lang: ConjugationgroupLang) -> [String] {
    var lines: [(key: String, infinitiv: String, table: ConjugationTable, persons: [PersonNumber])] = []
    for cell in cells {
      let table = cell.conjugationgroup.table
      let key = "\(cell.infinitiv)|\(table)"
      if let index = lines.firstIndex(where: { $0.key == key }) {
        if let person = cell.conjugationgroup.personNumber, !lines[index].persons.contains(person) {
          lines[index].persons.append(person)
        }
      } else {
        lines.append((key, cell.infinitiv, table, cell.conjugationgroup.personNumber.map { [$0] } ?? []))
      }
    }
    return lines.map { line in
      let persons = line.persons.map { Self.personLabel($0, in: line.table) }.joined(separator: ", ")
      return [line.infinitiv.inUserRegion, line.table.representative.displayName(lang: lang), persons.isEmpty ? nil : persons]
        .compactMap { $0 }
        .joined(separator: " · ")
    }
  }

  /// The right infinitive nearest a typed one, for marking the letters that differ.
  func nearestInfinitive(to typed: String) -> String {
    let typed = Array(AnswerSpelling.normalized(typed))
    let distance: (String) -> Int = { VerbSearch.editDistance(typed, Array($0.lowercased())) }
    return cells.map(\.infinitiv).min { distance($0) < distance($1) }?.inUserRegion ?? ""
  }

  /// The infinitive's own spelling, when a right answer wrote it another way, as uebernehmen for
  /// übernehmen. Nil when the answer is wrong or already spelled so.
  func preferredSpelling(of typed: String) -> String? {
    let normalized = AnswerSpelling.normalized(typed)
    guard let infinitiv = cells.map(\.infinitiv).first(where: { Self.spells(typed, $0) }) else {
      return nil
    }
    let spelling = infinitiv.inUserRegion
    return spelling.lowercased() == normalized ? nil : spelling
  }
}
