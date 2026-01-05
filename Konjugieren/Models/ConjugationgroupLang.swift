// Copyright © 2025 Josh Adams. All rights reserved.

enum ConjugationgroupLang: String, CaseIterable {
  case english
  case german

  var localizedConjugationgroupLang: String {
    switch self {
    case .english:
      return L.ConjugationgroupLang.english
    case .german:
      return L.ConjugationgroupLang.german
    }
  }
}
