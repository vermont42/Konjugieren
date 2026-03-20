// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

extension URLSession {
  static func stubSession(ratingsCount: Int) -> URLSession {
    URLProtocolStub.testURLs[RatingsFetcher.iTunesURL] = RatingsFetcher.stubData(ratingsCount: ratingsCount)
    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [URLProtocolStub.self]
    return URLSession(configuration: configuration)
  }
}
