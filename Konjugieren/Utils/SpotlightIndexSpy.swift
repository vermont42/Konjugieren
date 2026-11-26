// Copyright © 2026 Josh Adams. All rights reserved.

final class SpotlightIndexSpy: SpotlightIndex {
  enum Call: Equatable {
    case deleteEveryVerb
    case deleteVerbs([String])
    case indexVerbs([String])
  }

  struct Failure: Error {}

  private(set) var calls: [Call] = []
  var deletesFail = false
  var indexingFails = false

  func deleteEveryVerb() async throws {
    calls.append(.deleteEveryVerb)
    if deletesFail {
      throw Failure()
    }
  }

  func deleteVerbs(_ infinitivs: [String]) async throws {
    calls.append(.deleteVerbs(infinitivs))
    if deletesFail {
      throw Failure()
    }
  }

  func indexVerbs(_ entities: [VerbEntity]) async throws {
    calls.append(.indexVerbs(entities.map(\.id)))
    if indexingFails {
      throw Failure()
    }
  }
}
