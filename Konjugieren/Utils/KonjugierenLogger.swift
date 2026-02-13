// Copyright © 2026 Josh Adams. All rights reserved.

import os

enum KonjugierenLogger {
  nonisolated static func logger(category: String) -> Logger {
    Logger(subsystem: "biz.racecondition.Konjugieren", category: category)
  }
}
