// Copyright © 2026 Josh Adams. All rights reserved.

// The tool's stand-in for the app's World. The conjugation core reaches `Current` for one
// thing only, `Current.fatalError`, which the parsers call on malformed XML. The app's World
// would drag in Settings, analytics, Game Center, and the rest of the app, none of which a
// macOS command-line tool can or should compile.
//
// If a build of this target fails with "cannot find 'Current'" or "value of type 'ToolWorld'
// has no member …", a file the tool compiles has started reaching another part of the app.
// Move that member out to an extension in a file the tool does not compile, as
// Konjugieren/Models/ConjugationLabels.swift does for the pronoun and the display names,
// rather than growing this stand-in.

struct ToolWorld {
  let fatalError: FatalError = FatalErrorReal()
}

let Current = ToolWorld()
