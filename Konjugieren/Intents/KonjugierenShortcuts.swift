// Copyright © 2025 Josh Adams. All rights reserved.

import AppIntents

struct KonjugierenShortcuts: AppShortcutsProvider {
  static var appShortcuts: [AppShortcut] {
    AppShortcut(
      intent: ConjugateVerbIntent(),
      phrases: [
        "Conjugate \(\.$verb) with \(.applicationName)",
      ],
      shortTitle: "Conjugate a Verb",
      systemImageName: "textformat.abc"
    )

    AppShortcut(
      intent: OpenVerbIntent(),
      phrases: [
        "Show \(\.$verb) with \(.applicationName)",
        "Open \(\.$verb) with \(.applicationName)",
      ],
      shortTitle: "Open Verb",
      systemImageName: "book"
    )

    AppShortcut(
      intent: OpenQuizIntent(),
      phrases: [
        "Start a quiz with \(.applicationName)",
        "Quiz me with \(.applicationName)",
      ],
      shortTitle: "Start Quiz",
      systemImageName: "questionmark.circle"
    )

    AppShortcut(
      intent: OpenRandomVerbIntent(),
      phrases: [
        "Show a random verb with \(.applicationName)",
        "Random verb with \(.applicationName)",
      ],
      shortTitle: "Random Verb",
      systemImageName: "dice"
    )
  }
}
