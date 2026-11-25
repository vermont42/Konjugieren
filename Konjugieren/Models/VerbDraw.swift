// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

/// Chooses the widget's verb of the day and every random verb. Once My Verbs has entries, it
/// supplies one draw in three: every third day for the widget, and a third of random verbs by
/// chance. The rest come from the most frequent verbs, where a strong or mixed verb counts
/// double, and so does a verb with no prefix.
enum VerbDraw {
  static let myVerbsOdds = 3
  static let frequentBand = FrequencyBand.top1000

  private static let referenceDate = WidgetConstants.gregorianCalendar.date(from: DateComponents(year: 2025, month: 1, day: 1)) ?? .distantPast

  static var frequentVerbs: [Verb] {
    Verb.verbs(in: frequentBand)
  }

  static func randomVerb(myVerbs: [Verb]) -> Verb? {
    var generator = SystemRandomNumberGenerator()
    let goesToMyVerbs = generator.next() % UInt64(myVerbsOdds) == 0
    return draw(goesToMyVerbs: goesToMyVerbs, myVerbs: myVerbs, frequentVerbs: frequentVerbs, using: &generator)
  }

  /// The same verb for the same day, lists, and `lastShown`, in any process. My Verbs gets every
  /// third day rather than a chance of one in three, since chance leaves gaps of two weeks. Those
  /// days take the verb whose last My Verbs day is longest ago, a verb never given one first, and
  /// the infinitive breaks a tie. An index into the list, by turn, cannot serve: a verb opened
  /// between turns changes the list's length, and the index then lands anywhere, often on the
  /// verb just shown.
  static func verbOfTheDay(on date: Date, myVerbs: [Verb], frequentVerbs: [Verb], lastShown: [String: Date] = [:]) -> Verb? {
    if isMyVerbsDay(date), let verb = myVerbs.min(by: { lhs, rhs in
      (lastShown[lhs.infinitiv] ?? .distantPast, lhs.infinitiv) < (lastShown[rhs.infinitiv] ?? .distantPast, rhs.infinitiv)
    }) {
      return verb
    }
    var generator = SeededRNG(seed: UInt64(bitPattern: Int64(dayNumber(of: date))))
    return draw(goesToMyVerbs: false, myVerbs: myVerbs, frequentVerbs: frequentVerbs, using: &generator)
  }

  static func isMyVerbsDay(_ date: Date) -> Bool {
    dayNumber(of: date) % myVerbsOdds == 0
  }

  static func draw(goesToMyVerbs: Bool, myVerbs: [Verb], frequentVerbs: [Verb], using generator: inout some RandomNumberGenerator) -> Verb? {
    if goesToMyVerbs, !myVerbs.isEmpty {
      return myVerbs[Int(generator.next() % UInt64(myVerbs.count))]
    }
    return weightedVerb(from: frequentVerbs, using: &generator) ?? myVerbs.first
  }

  static func weight(of verb: Verb) -> UInt64 {
    let familyWeight: UInt64
    switch verb.family {
    case .mixed, .strong:
      familyWeight = 2
    case .ieren, .weak:
      familyWeight = 1
    }
    let prefixWeight: UInt64 = verb.prefix == .none ? 2 : 1
    return familyWeight * prefixWeight
  }

  // `Int.random(in:using:)` would serve, but its use of the generator is not documented, so a
  // Swift update could change which verb a stored seed names.
  private static func weightedVerb(from verbs: [Verb], using generator: inout some RandomNumberGenerator) -> Verb? {
    let total = verbs.reduce(0) { $0 + weight(of: $1) }
    guard total > 0 else {
      return nil
    }
    var remaining = generator.next() % total
    for verb in verbs {
      let weight = weight(of: verb)
      if remaining < weight {
        return verb
      }
      remaining -= weight
    }
    return verbs.last
  }

  private static func dayNumber(of date: Date) -> Int {
    let calendar = WidgetConstants.gregorianCalendar
    return calendar.dateComponents([.day], from: referenceDate, to: calendar.startOfDay(for: date)).day ?? 0
  }
}
