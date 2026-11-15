// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation
import Testing
@testable import Konjugieren

@MainActor
@Suite("Mastery")
struct MasteryTests {
  private let calendar = Calendar.current
  private let now = Date(timeIntervalSince1970: 1_800_000_000)

  private func verb(_ infinitiv: String) throws -> Verb {
    try #require(Verb.verbs[infinitiv])
  }

  /// A new item answered right enters the second box, due in three days, and answered right
  /// again then, the third: mastered.
  private func master(_ items: [PracticeItem], in record: inout PracticeRecord) {
    let later = now.addingTimeInterval(4 * 86_400)
    for item in items {
      record.recordAnswer(item, isCorrect: true, at: now, calendar: calendar)
      record.recordAnswer(item, isCorrect: true, at: later, calendar: calendar)
    }
  }

  private func keyConjugation(_ infinitiv: String, _ stem: PracticeItem.Stem, reading: Int = 0) -> PracticeItem {
    .keyConjugation(infinitiv: infinitiv, readingIndex: reading, stem: stem)
  }

  @Test func theStateFollowsTheBox() {
    let item = PracticeItem.pattern(of: .präsensIndikativ(.firstSingular))
    var record = PracticeRecord()
    #expect(record.masteryState(of: item) == .notPracticed)

    record.recordAnswer(item, isCorrect: false, at: now, calendar: calendar)
    #expect(record.masteryState(of: item) == .learning)

    record.recordAnswer(item, isCorrect: true, at: now.addingTimeInterval(86_400), calendar: calendar)
    #expect(record.entry(for: item)?.schedule.box == 1)
    #expect(record.masteryState(of: item) == .learning)

    record.recordAnswer(item, isCorrect: true, at: now.addingTimeInterval(5 * 86_400), calendar: calendar)
    #expect(record.entry(for: item)?.schedule.box == MasteryState.masteredBox)
    #expect(record.masteryState(of: item) == .mastered)

    record.recordAnswer(item, isCorrect: false, at: now.addingTimeInterval(6 * 86_400), calendar: calendar)
    #expect(record.masteryState(of: item) == .learning)
  }

  @Test func aLookupIsLearningNotMastered() throws {
    var record = PracticeRecord()
    record.recordLookup(PracticeItem.keyConjugations(of: try verb("kommen")), at: now, calendar: calendar)

    #expect(record.masteryState(of: keyConjugation("kommen", .präsens)) == .learning)
  }

  @Test(arguments: zip(QuizLevel.allCases, [9, 17, 47, 66]))
  func eachLevelShowsItsWeakPatterns(level: QuizLevel, count: Int) {
    #expect(Mastery(level: level, record: PracticeRecord()).patternCount == count)
  }

  /// A conjugationgroup that asks only sein, haben, werden, the modals, or strong verbs asks no
  /// weak verb, so it has no pattern to show.
  @Test func restrictedConjugationgroupsHaveNoPatterns() {
    let elementary = Mastery.patternTables(at: .elementary).map(\.table)
    let intermediate = Mastery.patternTables(at: .intermediate).map(\.table)
    let advanced = Mastery.patternTables(at: .advanced).map(\.table)

    #expect(elementary == [.präsensIndikativ, .imperativ, .perfektIndikativ, .perfektpartizip])
    #expect(!intermediate.contains(.präteritumKonjunktivII))
    #expect(intermediate.contains(.präteritumIndikativ))
    #expect(!advanced.contains(.präteritumKonjunktivII))
  }

  @Test func beginnersImperativPatternsAreItsThreePersons() throws {
    let mastery = Mastery(level: .beginner, record: PracticeRecord())
    let imperativ = try #require(mastery.patterns.first { $0.table == .imperativ })

    #expect(imperativ.cells.map(\.conjugationgroup.personNumber) == [.secondSingular, .secondPlural, .thirdPlural])
  }

  @Test func onlyTheFutursServeEveryVerb() {
    let mastery = Mastery(level: .advanced, record: PracticeRecord())
    let everyVerb = mastery.patterns.filter(\.servesEveryVerb).map(\.table)

    #expect(everyVerb == [.futurKonjunktivII, .futurIndikativ, .futurKonjunktivI])
  }

  @Test func theCoreVerbsAreTheFiftyMostFrequentStrongAndMixedVerbs() throws {
    let core = Mastery.coreVerbs

    #expect(core.count == Mastery.coreVerbCount)
    #expect(core.first?.infinitiv == "sein")
    #expect(core.map(\.frequency) == core.map(\.frequency).sorted())
    #expect(core.allSatisfy { verb in verb.readings.contains(where: QuizDraw.isStrong) })
    #expect(!core.contains { $0.infinitiv == "machen" })
    let lastFrequency = try #require(core.last?.frequency)
    let skipped = Verb.verbsSortedByFrequency.filter { $0.frequency < lastFrequency && !core.contains($0) }
    #expect(skipped.allSatisfy { verb in !verb.readings.contains(where: QuizDraw.isStrong) })
  }

  /// Every core verb is within Beginner's band, so the list is the same at every level.
  @Test func theCoreVerbsAreWithinEveryBand() {
    #expect(Mastery.coreVerbs.allSatisfy { $0.isIn(.top100) })
  }

  @Test func aVerbWithTwoStrongReadingsHasARowForEach() {
    let mastery = Mastery(level: .intermediate, record: PracticeRecord())
    let fahren = mastery.verbs.filter { $0.verb.infinitiv == "fahren" }

    #expect(fahren.map(\.readingIndex) == [0, 1])
    #expect(mastery.verbCount == Mastery.coreVerbCount)
    #expect(mastery.verbs.count > Mastery.coreVerbCount)
  }

  @Test func eachLevelShowsTheStemsItAsks() throws {
    let kommen = try verb("kommen")
    let sein = try verb("sein")
    let werden = try verb("werden")
    let können = try verb("können")

    #expect(Mastery.stems(askedAt: .beginner, of: kommen, readingIndex: 0) == [.präsens])
    #expect(Mastery.stems(askedAt: .beginner, of: sein, readingIndex: 0) == [.präsens])
    #expect(Mastery.stems(askedAt: .elementary, of: kommen, readingIndex: 0) == [.präsens, .perfekt])
    #expect(Mastery.stems(askedAt: .elementary, of: sein, readingIndex: 0) == [.präsens, .präteritum, .perfekt])
    #expect(Mastery.stems(askedAt: .elementary, of: können, readingIndex: 0) == [.präsens, .präteritum, .perfekt])
    #expect(Mastery.stems(askedAt: .elementary, of: werden, readingIndex: 0) == [.präsens, .perfekt])
    #expect(Mastery.stems(askedAt: .intermediate, of: kommen, readingIndex: 0) == PracticeItem.Stem.allCases)
  }

  @Test func aVerbRowShowsItsKeyConjugations() throws {
    let mastery = Mastery(level: .intermediate, record: PracticeRecord())
    let kommen = try #require(mastery.verbs.first { $0.verb.infinitiv == "kommen" })

    #expect(kommen.keyConjugations.map { $0.conjugation(region: .north).lowercased() } == ["kommt", "kam", "ist gekommen"])
  }

  @Test func theDisplayReflectsTheRecord() throws {
    var record = PracticeRecord()
    master([keyConjugation("kommen", .präsens)], in: &record)
    record.recordAnswer(keyConjugation("kommen", .perfekt), isCorrect: true, at: now, calendar: calendar)
    master(PersonNumber.allCases.map { PracticeItem.pattern(of: .präsensIndikativ($0)) }, in: &record)
    record.recordAnswer(PracticeItem.pattern(of: .perfektpartizip), isCorrect: false, at: now, calendar: calendar)

    let elementary = Mastery(level: .elementary, record: record)
    let kommen = try #require(elementary.verbs.first { $0.verb.infinitiv == "kommen" })
    let präsens = try #require(elementary.patterns.first { $0.table == .präsensIndikativ })
    let partizip = try #require(elementary.patterns.first { $0.table == .perfektpartizip })

    #expect(kommen.keyConjugations.map(\.state) == [.mastered, .learning])
    #expect(präsens.cells.allSatisfy { $0.state == .mastered })
    #expect(partizip.cells.map(\.state) == [.learning])
    #expect(elementary.masteredPatternCount == 6)
    #expect(elementary.masteredVerbCount == 0)
  }

  /// kommen's Präsens is all that Beginner asks of it, so mastering it masters the verb there,
  /// and not at Elementary, which also asks its Perfekt.
  @Test func aVerbIsMasteredWhenEveryStemItsLevelAsksIs() {
    var record = PracticeRecord()
    master([keyConjugation("kommen", .präsens)], in: &record)

    #expect(Mastery(level: .beginner, record: record).masteredVerbCount == 1)
    #expect(Mastery(level: .elementary, record: record).masteredVerbCount == 0)

    master([keyConjugation("kommen", .perfekt)], in: &record)
    #expect(Mastery(level: .elementary, record: record).masteredVerbCount == 1)
  }

  /// fahren counts once both strong readings are mastered.
  @Test func aVerbWithTwoReadingsNeedsBoth() {
    var record = PracticeRecord()
    master([keyConjugation("fahren", .präsens, reading: 0)], in: &record)
    #expect(Mastery(level: .beginner, record: record).masteredVerbCount == 0)

    master([keyConjugation("fahren", .präsens, reading: 1)], in: &record)
    #expect(Mastery(level: .beginner, record: record).masteredVerbCount == 1)
  }

  /// A pattern the level does not ask is not counted, though the record keeps it.
  @Test func aPatternBeyondTheLevelIsNotCounted() {
    var record = PracticeRecord()
    master([PracticeItem.pattern(of: .präteritumIndikativ(.firstSingular))], in: &record)

    #expect(Mastery(level: .elementary, record: record).masteredPatternCount == 0)
    #expect(Mastery(level: .intermediate, record: record).masteredPatternCount == 1)
  }

  /// The mapping decides where an answer lands: a weak verb's answer fills a pattern, and a
  /// strong verb's Futur does too.
  @Test func answersLandWhereTheMappingSendsThem() throws {
    let sagen = try verb("sagen")
    let geben = try verb("geben")
    var record = PracticeRecord()
    master([PracticeItem.exercised(by: .präteritumIndikativ(.thirdSingular), of: sagen, readingIndex: 0)], in: &record)
    master([PracticeItem.exercised(by: .futurIndikativ(.firstPlural), of: geben, readingIndex: 0)], in: &record)

    let mastery = Mastery(level: .intermediate, record: record)
    let präteritum = try #require(mastery.patterns.first { $0.table == .präteritumIndikativ })
    let futur = try #require(mastery.patterns.first { $0.table == .futurIndikativ })

    #expect(präteritum.cells.first { $0.conjugationgroup == .präteritumIndikativ(.thirdSingular) }?.state == .mastered)
    #expect(futur.cells.first { $0.conjugationgroup == .futurIndikativ(.firstPlural) }?.state == .mastered)
    #expect(mastery.masteredPatternCount == 2)
  }
}
