// Copyright © 2026 Josh Adams. All rights reserved.

enum ConjugatorError: String, Error {
  case conjugationFailed
  case infinitivEndingInvalid
  case personNumberNotSupported
  case verbNotRecognized
  case verbTooShort
}
