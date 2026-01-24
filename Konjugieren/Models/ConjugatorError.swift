// Copyright © 2026 Josh Adams. All rights reserved.

enum ConjugatorError: String, Error {
  case verbNotRecognized
  case personNumberNotSupported
  case verbTooShort
  case infinitivEndingInvalid
  case conjugationFailed
}
