// Copyright © 2026 Josh Adams. All rights reserved.

enum ThirdPersonPronounGender: String, CaseIterable {
  case er
  case sie
  case es

  var localizedThirdPersonPronounGender: String {
    switch self {
    case .er:
      return L.ThirdPersonPronounGender.er
    case .sie:
      return L.ThirdPersonPronounGender.sie
    case .es:
      return L.ThirdPersonPronounGender.es
    }
  }

  var pronoun: String {
    rawValue
  }
}
