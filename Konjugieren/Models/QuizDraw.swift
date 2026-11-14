// Copyright © 2026 Josh Adams. All rights reserved.

/// A question as drawn, before it is conjugated.
struct QuizDrawnQuestion: Equatable {
  let verb: Verb
  let conjugationgroup: Conjugationgroup
  let readingIndex: Int
}

/// Chooses a quiz's questions from a level's pool. Each question draws a kind by its weight, then
/// a verb that fits the kind, then one of its cells, so that a cell restricted to a few verbs, such
/// as the Präteritum of sein, haben, and the modals, is never asked of another verb. A kind that
/// no verb of the scope fits is left out.
enum QuizDraw {
  /// Half of a mixed quiz's questions, rounded down, ask a strong or mixed reading.
  static let strongShareDivisor = 2
  static let minimumCoreQuestions = 2
  static let rareDerivativeRange = 1...3
  /// A prefixed verb in this band draws as freely as a base verb. Josh chose this reading of
  /// T2.2 on 2026-11-13: bekommen and verstehen are as basic as kommen and stehen.
  static let frequentDerivativeBand = FrequencyBand.top300

  /// With `distinctCells`, for a quiz as short as three questions on a verb's page, no cell is
  /// asked twice and no participle is asked, since every Perfekt among the questions tests the
  /// participle anyway.
  ///
  /// With `mixesVerbs`, for the default quiz, whose verbs the learner did not choose, the
  /// questions are balanced: half ask a strong or mixed reading, at least two ask sein, haben,
  /// werden, or a modal, and at least one asks a prefixed verb. Where `verbs` reaches past
  /// `frequentDerivativeBand`, one to three questions ask a prefixed verb from beyond it, and no
  /// other question does.
  static func questions(
    level: QuizLevel,
    verbs: [Verb],
    readingIndex: Int?,
    count: Int,
    distinctCells: Bool,
    mixesVerbs: Bool = false,
    using generator: inout some RandomNumberGenerator
  ) -> [QuizDrawnQuestion] {
    var candidatesByVerbs: [QuizVerbs: [Candidate]] = [:]
    let kinds: [Kind] = level.pool.compactMap { entry in
      if distinctCells, entry.isParticiple {
        return nil
      }
      let candidates = candidatesByVerbs[entry.verbs] ?? candidates(of: verbs, admittedBy: entry.verbs, readingIndex: readingIndex)
      candidatesByVerbs[entry.verbs] = candidates
      return candidates.isEmpty ? nil : Kind(entry: entry, candidates: candidates)
    }
    guard !kinds.isEmpty, count > 0 else {
      return []
    }

    if mixesVerbs {
      return mixedQuestions(from: kinds, count: count, using: &generator)
    }

    guard distinctCells else {
      return (0..<count).compactMap { _ in
        kindIndex(from: kinds, using: &generator).flatMap { question(from: kinds[$0], using: &generator) }
      }
    }

    var questions: [QuizDrawnQuestion] = []
    var attempts = 0
    while questions.count < count, attempts < count * 20 {
      if let index = kindIndex(from: kinds, using: &generator),
         let question = question(from: kinds[index], using: &generator),
         !questions.contains(where: { $0.conjugationgroup == question.conjugationgroup }) {
        questions.append(question)
      }
      attempts += 1
    }
    return questions
  }

  /// Whether a question asks a reading that `mixesVerbs` counts as strong.
  static func isStrong(_ reading: Reading) -> Bool {
    switch reading.family {
    case .mixed, .strong:
      return true
    case .ieren, .weak:
      return false
    }
  }

  static func isCore(_ verb: Verb) -> Bool {
    QuizVerbs.seinHabenWerdenModals.admits(verb, reading: verb.primaryReading)
  }

  static func isDerivative(_ reading: Reading) -> Bool {
    reading.prefix != .none
  }

  static func isRareDerivative(_ verb: Verb, reading: Reading) -> Bool {
    isDerivative(reading) && !verb.isIn(frequentDerivativeBand)
  }

  private struct Candidate {
    let verb: Verb
    let readings: [(index: Int, reading: Reading)]
  }

  private struct Kind {
    let entry: QuizPoolEntry
    let candidates: [Candidate]

    func hasCandidate(where predicate: (Verb, Reading) -> Bool) -> Bool {
      candidates.contains { candidate in
        candidate.readings.contains { predicate(candidate.verb, $0.reading) }
      }
    }
  }

  // Alphabetical, but `mixedQuestions` assigns them in a fixed order of its own.
  private enum Role {
    case core
    case derivative
    case free
    case rareDerivative
  }

  private struct Slot: Hashable {
    let kindIndex: Int
    var role = Role.free
    var isStrong: Bool?
  }

  private static func candidates(of verbs: [Verb], admittedBy quizVerbs: QuizVerbs, readingIndex: Int?) -> [Candidate] {
    verbs.compactMap { verb in
      let readings: [(index: Int, reading: Reading)] = (readingIndex.map { [$0] } ?? Array(verb.readings.indices)).compactMap { index in
        guard let reading = verb.reading(at: index), quizVerbs.admits(verb, reading: reading) else {
          return nil
        }
        return (index, reading)
      }
      return readings.isEmpty ? nil : Candidate(verb: verb, readings: readings)
    }
  }

  private static func kindIndex(from kinds: [Kind], using generator: inout some RandomNumberGenerator) -> Int? {
    let totalWeight = kinds.reduce(0) { $0 + $1.entry.weight }
    guard totalWeight > 0 else {
      return nil
    }
    var roll = Int.random(in: 0..<totalWeight, using: &generator)
    return kinds.firstIndex { kind in
      if roll < kind.entry.weight {
        return true
      }
      roll -= kind.entry.weight
      return false
    }
  }

  private typealias Match = (verb: Verb, readingIndices: [Int])

  private static func question(from kind: Kind, using generator: inout some RandomNumberGenerator) -> QuizDrawnQuestion? {
    question(from: kind, choosingFrom: kind.candidates.randomElement(using: &generator).map { ($0.verb, $0.readings.map(\.index)) }, using: &generator)
  }

  private static func question(from kind: Kind, choosingFrom match: Match?, using generator: inout some RandomNumberGenerator) -> QuizDrawnQuestion? {
    guard let match,
          let readingIndex = match.readingIndices.randomElement(using: &generator),
          let conjugationgroup = kind.entry.cells.randomElement(using: &generator) else {
      return nil
    }
    return QuizDrawnQuestion(verb: match.verb, conjugationgroup: conjugationgroup, readingIndex: readingIndex)
  }

  private static func matches(of kind: Kind, where predicate: (Verb, Reading) -> Bool) -> [Match] {
    kind.candidates.compactMap { candidate in
      let indices = candidate.readings.filter { predicate(candidate.verb, $0.reading) }.map(\.index)
      return indices.isEmpty ? nil : (candidate.verb, indices)
    }
  }

  /// Draws every slot's kind first, then gives the slots their roles and their strong-or-weak
  /// share, and only then a verb that fits all three, so that the counts come out exact rather
  /// than about right. A kind whose verbs are all core, such as Elementary's Präteritum, already
  /// counts toward the core questions.
  private static func mixedQuestions(from kinds: [Kind], count: Int, using generator: inout some RandomNumberGenerator) -> [QuizDrawnQuestion] {
    var slots = (0..<count).compactMap { _ in
      kindIndex(from: kinds, using: &generator).map { Slot(kindIndex: $0) }
    }
    let reachesRareDerivatives = kinds.contains { $0.hasCandidate(where: isRareDerivative) }

    func fits(_ role: Role) -> (Verb, Reading) -> Bool {
      switch role {
      case .core:
        return { verb, _ in isCore(verb) }
      case .derivative:
        return { _, reading in isDerivative(reading) }
      case .free:
        return { verb, reading in !reachesRareDerivatives || !isRareDerivative(verb, reading: reading) }
      case .rareDerivative:
        return isRareDerivative
      }
    }

    // A core-only slot takes no role: it is a core question already, and giving it the core
    // role would count it twice.
    let coreOnly = slots.indices.filter { !kinds[slots[$0].kindIndex].hasCandidate(where: { verb, _ in !isCore(verb) }) }
    var roleNeeds: [(role: Role, count: Int)] = [(.core, max(0, minimumCoreQuestions - coreOnly.count))]
    if reachesRareDerivatives {
      roleNeeds.append((.rareDerivative, Int.random(in: rareDerivativeRange, using: &generator)))
    } else {
      roleNeeds.append((.derivative, 1))
    }
    var unassigned = slots.indices.filter { !coreOnly.contains($0) }.shuffled(using: &generator)
    for (role, needed) in roleNeeds {
      for _ in 0..<needed {
        guard let position = unassigned.firstIndex(where: { kinds[slots[$0].kindIndex].hasCandidate(where: fits(role)) }) else {
          break
        }
        slots[unassigned.remove(at: position)].role = role
      }
    }

    var flexible: [Int] = []
    for index in slots.indices {
      let roleFits = fits(slots[index].role)
      let admitsStrong = kinds[slots[index].kindIndex].hasCandidate { roleFits($0, $1) && isStrong($1) }
      let admitsWeak = kinds[slots[index].kindIndex].hasCandidate { roleFits($0, $1) && !isStrong($1) }
      if admitsStrong, admitsWeak {
        flexible.append(index)
      } else {
        slots[index].isStrong = admitsStrong
      }
    }
    let strongNeeded = count / strongShareDivisor - slots.filter { $0.isStrong == true }.count
    for (offset, index) in flexible.shuffled(using: &generator).enumerated() {
      slots[index].isStrong = offset < strongNeeded
    }

    // Slots alike in kind, role, and strength share one filtering pass over the band.
    var matchesBySlot: [Slot: [Match]] = [:]
    return slots.compactMap { slot in
      let kind = kinds[slot.kindIndex]
      let roleFits = fits(slot.role)
      let strongFits: (Reading) -> Bool = { reading in slot.isStrong.map { $0 == isStrong(reading) } ?? true }
      let matches = matchesBySlot[slot] ?? Self.matches(of: kind) { roleFits($0, $1) && strongFits($1) }
      matchesBySlot[slot] = matches
      if let match = matches.randomElement(using: &generator) {
        return question(from: kind, choosingFrom: match, using: &generator)
      }
      return question(from: kind, choosingFrom: Self.matches(of: kind, where: roleFits).randomElement(using: &generator), using: &generator)
        ?? question(from: kind, using: &generator)
    }
  }
}

/// Lets `Quiz` hold either the system's generator or a seeded one for tests.
struct AnyRandomNumberGenerator: RandomNumberGenerator {
  private var base: any RandomNumberGenerator

  init(_ base: any RandomNumberGenerator) {
    self.base = base
  }

  mutating func next() -> UInt64 {
    base.next()
  }
}
