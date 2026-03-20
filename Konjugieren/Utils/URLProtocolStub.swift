// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation

nonisolated class URLProtocolStub: URLProtocol {
  nonisolated(unsafe) static var testURLs = [URL: Data]()

  override class func canInit(with request: URLRequest) -> Bool {
    true
  }

  override class func canonicalRequest(for request: URLRequest) -> URLRequest {
    request
  }

  override func startLoading() {
    if let url = request.url, let data = URLProtocolStub.testURLs[url] {
      client?.urlProtocol(self, didLoad: data)
    }
    client?.urlProtocol(self, didReceive: URLResponse(), cacheStoragePolicy: .notAllowed)
    client?.urlProtocolDidFinishLoading(self)
  }

  override func stopLoading() {}
}
