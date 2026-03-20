// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

enum RatingsFetcher {
  nonisolated static let iTunesID = "6758258747"

  nonisolated static var iTunesURL: URL {
    URL(string: "https://itunes.apple.com/lookup?id=\(iTunesID)")!
  }

  nonisolated static var reviewURL: URL {
    URL(string: "https://itunes.apple.com/app/id\(iTunesID)?action=write-review")!
  }

  static func fetchRatingsDescription(session: URLSession) async -> String? {
    do {
      let (data, _) = try await session.data(from: iTunesURL)
      return ratingsDescription(data: data)
    } catch {
      return nil
    }
  }

  static func ratingsDescription(data: Data) -> String? {
    guard
      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
      let results = json["results"] as? [[String: Any]],
      let result = results.first,
      let ratingsCount = result["userRatingCountForCurrentVersion"] as? Int
    else {
      return nil
    }

    let description: String
    switch ratingsCount {
    case 0:
      description = L.RatingsFetcher.noRating
    case 1:
      description = L.RatingsFetcher.oneRating
    default:
      description = L.RatingsFetcher.multipleRatings(count: ratingsCount)
    }
    return description + " Füge deine hinzu."
  }

  nonisolated static func stubData(ratingsCount: Int) -> Data {
    """
    {"resultCount":1,"results":[{"userRatingCountForCurrentVersion":\(ratingsCount)}]}
    """.data(using: .utf8)!
  }
}
