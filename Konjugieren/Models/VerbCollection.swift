// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

/// A fixed list of verbs offered as a place to go: something a self-studier can finish and a
/// teacher can assign. Each shows how many of its verbs have been opened, starts a quiz on itself,
/// and is shared as `konjugieren://list/<key>`.
enum VerbCollection: Hashable, Identifiable {
  case ablautGroup(String)
  case modals
  case sein
  case top100

  // Semantic ordering: the order of the Families tab's Collections section.
  static let featured: [VerbCollection] = [.top100, .modals, .sein]

  static let modalInfinitives: Set<String> = ["dürfen", "können", "mögen", "müssen", "sollen", "wollen"]

  private static let ablautKeyPrefix = "ablaut-"

  var id: String {
    key
  }

  /// The deeplink target. A key, once shared, must keep opening the same list.
  var key: String {
    switch self {
    case .ablautGroup(let exemplar):
      return Self.ablautKeyPrefix + exemplar
    case .modals:
      return "modals"
    case .sein:
      return "sein"
    case .top100:
      return "top100"
    }
  }

  init?(key: String) {
    if key.hasPrefix(Self.ablautKeyPrefix) {
      let exemplar = String(key.dropFirst(Self.ablautKeyPrefix.count))
      guard AblautGroupInfo.allGroups.contains(where: { $0.exemplar == exemplar }) else {
        return nil
      }
      self = .ablautGroup(exemplar)
      return
    }
    switch key {
    case Self.modals.key:
      self = .modals
    case Self.sein.key:
      self = .sein
    case Self.top100.key:
      self = .top100
    default:
      return nil
    }
  }

  /// The collection's verbs, alphabetically, as every list's verbs arrive, since
  /// `sorted(by: .alphabetical)` keeps the order it is given.
  func verbs(region: Region = Current.settings.region) -> [Verb] {
    Verb.verbsSortedAlphabetically.filter { contains($0, region: region) }
  }

  func contains(_ verb: Verb, region: Region = Current.settings.region) -> Bool {
    switch self {
    case .ablautGroup(let exemplar):
      return verb.ablautGroup == exemplar
    case .modals:
      return Self.modalInfinitives.contains(verb.infinitiv)
    case .sein:
      // Any reading counts, so fahren is here for "ist gefahren" though "hat das Auto gefahren"
      // takes haben. liegen, sitzen, and stehen take sein in Austria and Switzerland only.
      return verb.readings.contains { $0.regionalAuxiliary(in: region) == .sein }
    case .top100:
      return verb.isIn(.top100)
    }
  }

  var title: String {
    switch self {
    case .ablautGroup(let exemplar):
      return L.VerbCollection.ablautGroupTitle(exemplar)
    case .modals:
      return L.VerbCollection.modalsTitle
    case .sein:
      return L.VerbCollection.seinTitle
    case .top100:
      return L.VerbCollection.top100Title
    }
  }

  /// The ablaut groups' descriptions live on `AblautGroupInfo` and carry markup.
  var shortDescription: String {
    switch self {
    case .ablautGroup(let exemplar):
      return AblautGroupInfo(exemplar: exemplar).description
    case .modals:
      return L.VerbCollection.modalsDescription
    case .sein:
      return L.VerbCollection.seinDescription
    case .top100:
      return L.VerbCollection.top100Description
    }
  }

  var systemImageName: String {
    switch self {
    case .ablautGroup:
      return "waveform.path"
    case .modals:
      return "hand.raised.fill"
    case .sein:
      return "figure.walk.motion"
    case .top100:
      return "chart.bar.fill"
    }
  }

  /// `konjugieren://list/modals?source=sharedLink`.
  var deeplink: URL? {
    URL.listDeeplink(self, source: .sharedLink)
  }

  /// What the share button sends: the title, the count, the first verbs, a link that opens the
  /// list for someone who has the app, and the App Store link for someone who does not.
  func shareText(region: Region = Current.settings.region) -> String {
    let verbs = verbs(region: region).sorted(by: .frequency)
    let sample = verbs.prefix(Self.shareSampleCount).map { $0.infinitiv.inRegion(region) }
    let more = verbs.count > sample.count ? " …" : ""
    return L.VerbCollection.shareText(
      title: title,
      count: verbs.count,
      sample: sample.joined(separator: ", ") + more,
      link: deeplink?.absoluteString ?? "",
      appStoreLink: URL.appStore.absoluteString
    )
  }

  static let shareSampleCount = 6

  /// `viewCollection`, the ideas document's "lists opened".
  func signalView(source: AnalyticsSource) {
    Current.analytics.signal(name: .viewCollection, parameters: [
      ParameterKey.collection.rawValue: key,
      ParameterKey.source.rawValue: source.rawValue,
    ])
  }
}

extension QuizScope {
  static func collection(_ collection: VerbCollection) -> QuizScope {
    QuizScope(
      verbs: collection.verbs(),
      readingIndex: nil,
      questionCount: Quiz.questionCount,
      source: .list,
      title: collection.title,
      collectionKey: collection.key
    )
  }
}
