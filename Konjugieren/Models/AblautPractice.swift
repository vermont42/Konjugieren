// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

/// An ablaut group as its practice sees it: Verb Essentials
/// over one group alone, then mixed with the groups already known. Practicing a pattern alone
/// before mixing it did better in Pan et al. (2019); for ablaut groups as such there is no study,
/// so this is a bet.
struct AblautPracticeGroup: Identifiable {
  /// A verb of the group and its readings that inflect by the group's pattern, which are the ones
  /// a step may ask. hängen's weak reading (hängte) is not the hängen pattern.
  struct Member {
    let verb: Verb
    let readingIndices: [Int]
  }

  /// A group is its ten most frequent verbs, at every level (Josh, 2026-11-15). Counted over
  /// every verb, bleiben's 125 would need 188 right answers to be known, nearly all of them to
  /// rare prefixed verbs that repeat the pattern of the first ten.
  static let verbLimit = 10

  let exemplar: String
  /// The most frequent first.
  let members: [Member]

  var id: String {
    exemplar
  }

  var verbs: [Verb] {
    members.map(\.verb)
  }

  /// One verb is not a pattern, so a single-verb group is not practiced alone. It joins other
  /// groups' mixes once it is known (Josh, 2026-11-13).
  var offersPracticeAlone: Bool {
    members.count > 1
  }

  /// The group's key conjugations, three to a verb, each with the practice record's item for
  /// every asked reading. fahren drives with haben and travels with sein, and the record keeps
  /// fährt once for each, but a round asks one reading, and the vowel is the same in both. Counted
  /// by reading, a group of ten verbs with one such verb would have 33 items, and a perfect round's
  /// 15 would fall short of half.
  var keyConjugations: [[PracticeItem]] {
    members.flatMap { member in
      PracticeItem.Stem.allCases.map { stem in
        member.readingIndices.map { readingIndex in
          PracticeItem.keyConjugation(infinitiv: member.verb.infinitiv, readingIndex: readingIndex, stem: stem)
        }
      }
    }
  }

  /// A group is known once at least half of its key conjugations have moved past the first box,
  /// in any asked reading (Josh, 2026-11-13). For a group of ten verbs that is one round of five
  /// answered right. A wrong answer sends an item back to the first box, so a group can stop being
  /// known.
  func isKnown(in record: PracticeRecord) -> Bool {
    let keyConjugations = keyConjugations
    guard !keyConjugations.isEmpty else {
      return false
    }
    let climbed = keyConjugations.filter { $0.contains(where: record.isPastFirstBox) }.count
    return 2 * climbed >= keyConjugations.count
  }

  /// Every group with a verb, in the Ablaut page's order. Built once, since the corpus does not
  /// change after launch and the Ablaut page asks for every group as it scrolls.
  static let all: [AblautPracticeGroup] = {
    var membersByExemplar: [String: [Member]] = [:]
    for verb in Verb.verbsSortedByFrequency {
      guard let exemplar = verb.ablautGroup, membersByExemplar[exemplar, default: []].count < verbLimit else {
        continue
      }
      let readingIndices = verb.readings.indices.filter { verb.readings[$0].ablautGroup == exemplar }
      membersByExemplar[exemplar, default: []].append(Member(verb: verb, readingIndices: readingIndices))
    }
    return AblautGroupInfo.allGroups.compactMap { info in
      membersByExemplar[info.exemplar].map { AblautPracticeGroup(exemplar: info.exemplar, members: $0) }
    }
  }()

  /// The groups with a pattern to practice, the most used first, by each group's most frequent
  /// verb: kommen and stehen before backen. This is the hub's list, in the order of use that the
  /// levels follow.
  static let practicedAloneByUse: [AblautPracticeGroup] = all
    .filter(\.offersPracticeAlone)
    .sorted { ($0.members.first?.verb.frequency ?? .max) < ($1.members.first?.verb.frequency ?? .max) }

  private static let groupsByExemplar = Dictionary(all.map { ($0.exemplar, $0) }, uniquingKeysWith: { first, _ in first })

  static func group(_ exemplar: String) -> AblautPracticeGroup? {
    groupsByExemplar[exemplar]
  }

  /// The known groups, single-verb groups among them, in the Ablaut page's order.
  static func known(in record: PracticeRecord) -> [AblautPracticeGroup] {
    all.filter { $0.isKnown(in: record) }
  }

  /// The groups a mix adds to this one: every other known group. Mixed opens for a group once
  /// there is one, whether or not the group itself is known, since nothing here is earned (Josh,
  /// 2026-11-15).
  func mixPartners(in record: PracticeRecord) -> [AblautPracticeGroup] {
    Self.known(in: record).filter { $0.exemplar != exemplar }
  }
}

extension PracticeRecord {
  /// An item enters the first box and leaves it by a right answer given when it is due.
  func isPastFirstBox(_ item: PracticeItem) -> Bool {
    (entry(for: item)?.schedule.box ?? 0) > 0
  }
}

/// One of the two sessions a group offers.
struct AblautPracticeSession: Hashable, Identifiable {
  // Semantic ordering: alone comes before mixed.
  enum Mode: String {
    case alone
    case mixed
  }

  let exemplar: String
  let mode: Mode

  var id: String {
    "\(exemplar)-\(mode.rawValue)"
  }

  var collection: VerbCollection {
    .ablautGroup(exemplar)
  }

  var title: String {
    switch mode {
    case .alone:
      return collection.title
    case .mixed:
      return L.AblautPractice.mixedTitle(exemplar.inUserRegion)
    }
  }

  var source: AnalyticsSource {
    switch mode {
    case .alone:
      return .ablautAlone
    case .mixed:
      return .ablautMixed
    }
  }
}

extension QuizScope {
  /// Verb Essentials over an ablaut group, alone or mixed with the known groups. The draw reads
  /// the group and the record itself, so `verbs` is only the group's.
  static func ablautPractice(_ session: AblautPracticeSession) -> QuizScope {
    QuizScope(
      verbs: AblautPracticeGroup.group(session.exemplar)?.verbs ?? [],
      readingIndex: nil,
      questionCount: verbEssentialsVerbCount * PracticeItem.Stem.allCases.count,
      source: session.source,
      title: session.title,
      collectionKey: session.collection.key,
      isVerbEssentials: true,
      ablautPractice: session
    )
  }
}

extension QuizDraw {
  /// How many of a mixed round's five verbs are the group's own (Josh, 2026-11-15). The rest are
  /// the known groups'. The session stays mostly about the group the learner chose, and the two
  /// known verbs make them pick the pattern rather than repeat it.
  static let ablautMixGroupVerbCount = 3

  /// A round of a group's practice. Alone, it is Verb Essentials over the group's verbs. Mixed,
  /// `ablautMixGroupVerbCount` of the verbs are the group's and the rest the known groups', in a
  /// shuffled order, so that the learner has to tell the patterns apart.
  static func ablautPracticeSteps(
    for session: AblautPracticeSession,
    record: PracticeRecord,
    count: Int = QuizScope.verbEssentialsVerbCount,
    excluded: Set<String> = [],
    using generator: inout some RandomNumberGenerator
  ) -> [[QuizDrawnQuestion]] {
    guard let group = AblautPracticeGroup.group(session.exemplar) else {
      return []
    }
    switch session.mode {
    case .alone:
      return verbEssentialsSteps(members: group.members, count: count, excluded: excluded, using: &generator)
    case .mixed:
      return ablautMixSteps(
        group: group,
        partners: group.mixPartners(in: record),
        count: count,
        groupCount: ablautMixGroupVerbCount,
        excluded: excluded,
        using: &generator
      )
    }
  }

  /// A mixed round: `groupCount` verbs of `group`, and the rest drawn from `partners` one group at
  /// a time, so that a partner of ten verbs does not crowd out a partner of one. Whichever side
  /// cannot fill its share leaves the rest to the other. Verbs the session has asked wait until
  /// every other has been asked, on each side.
  static func ablautMixSteps(
    group: AblautPracticeGroup,
    partners: [AblautPracticeGroup],
    count: Int,
    groupCount: Int,
    excluded: Set<String> = [],
    using generator: inout some RandomNumberGenerator
  ) -> [[QuizDrawnQuestion]] {
    let asked = askedInfinitives(excluded)
    let own = freshFirst(group.members, asked: asked, using: &generator)
    let queues = partners.shuffled(using: &generator).map { freshFirst($0.members, asked: asked, using: &generator) }
    let longest = queues.map(\.count).max() ?? 0
    let inTurn = (0..<longest).flatMap { turn in
      queues.compactMap { $0.indices.contains(turn) ? $0[turn] : nil }
    }
    // Taking one from each partner in turn can put an asked verb before another partner's fresh
    // one. Fresh verbs come first, each side keeping its turn order.
    let others = inTurn.filter { !asked.contains($0.verb.infinitiv) } + inTurn.filter { asked.contains($0.verb.infinitiv) }

    let otherCount = min(max(count - min(groupCount, own.count), 0), others.count)
    let ownCount = min(count - otherCount, own.count)
    let chosen = (own.prefix(ownCount) + others.prefix(otherCount)).shuffled(using: &generator)
    return chosen.compactMap { step(for: $0, using: &generator) }
  }
}
