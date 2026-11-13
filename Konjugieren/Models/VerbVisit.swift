// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

/// A verb page to push, with the way the learner reached it.
struct VerbDestination: Hashable {
  let verb: Verb
  let source: AnalyticsSource
  let marks: MarkedConjugations?

  init(verb: Verb, source: AnalyticsSource, marks: MarkedConjugations? = nil) {
    self.verb = verb
    self.source = source
    self.marks = marks
  }
}

/// The cells of a verb page that a search matched. The page opens on their reading, scrolls to
/// the first of them, and marks them.
struct MarkedConjugations: Hashable {
  let readingIndex: Int
  let conjugationgroups: Set<Conjugationgroup>
}

/// One stretch of time during which a verb page is on screen with the app in the foreground.
/// It begins with `viewVerbView` and ends with exactly one `leaveVerbView`. A page that leaves
/// the screen or the foreground and then returns begins a new visit whose source is `resume`,
/// because the alternatives either count time spent in another app as reading or send a
/// `leaveVerbView` that no `viewVerbView` preceded.
struct VerbVisit {
  let source: AnalyticsSource
  let start: Date
  private(set) var deepestSection: VerbPageSection

  init(source: AnalyticsSource, start: Date, visibleSections: Set<VerbPageSection> = []) {
    self.source = source
    self.start = start
    deepestSection = visibleSections.max() ?? .header
  }

  mutating func reach(_ section: VerbPageSection) {
    deepestSection = max(deepestSection, section)
  }

  var viewParameters: [String: String] {
    [ParameterKey.source.rawValue: source.rawValue]
  }

  func leaveParameters(end: Date) -> [String: String] {
    [
      ParameterKey.deepestSection.rawValue: deepestSection.rawValue,
      ParameterKey.dwell.rawValue: AnalyticsBand.dwell(end.timeIntervalSince(start)),
    ]
  }
}
