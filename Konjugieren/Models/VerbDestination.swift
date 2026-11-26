// Copyright © 2026 Josh Adams. All rights reserved.

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
