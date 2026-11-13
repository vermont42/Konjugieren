// Copyright © 2026 Josh Adams. All rights reserved.

enum ReviewCardSuppression: String, CaseIterable {
  case off
  case on

  var localizedReviewCardSuppression: String {
    switch self {
    case .off:
      return L.ReviewCardSuppression.off
    case .on:
      return L.ReviewCardSuppression.on
    }
  }
}
