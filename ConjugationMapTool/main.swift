// Copyright © 2026 Josh Adams. All rights reserved.

// ConjugationMapTool: the build-time writer of the conjugation map, and the writer of the
// corpus pipelines' forms.json.
//
// Consumes: Verbs.xml and AblautGroups.xml, given as paths.
// Produces: the app's ConjugationMap.lzfse (see Konjugieren/Models/ConjugationMap.swift for
//           the format) and, when asked, corpus/working/forms.json for the Python pipelines.
//
// Run:      ConjugationMapTool --verbs <Verbs.xml> --ablaut-groups <AblautGroups.xml> \
//             [--map <out.lzfse>] [--forms-json <out.json>]
//
// The app target's "Generate Conjugation Map" build phase runs this with --map, writing
// straight into the app bundle. Xcode runs that phase only when one of its declared inputs is
// newer than its output: the two XML files and this tool's executable. The executable stands
// in for every Conjugator source, because Xcode relinks it whenever one of the files it
// compiles changes, and leaves it untouched otherwise.
//
// For forms.json, run scripts/write_forms_json.sh, which builds this target and calls it with
// the right paths. Until 2026-11-12 the file came from a gated test harness,
// CorpusFormsDumpTests, which this tool replaced; its output was confirmed identical.
//
// The tool compiles the app's own conjugation sources (the target membership exceptions in
// project.pbxproj list them) plus ConjugationMap.swift, so the map, the app's display, and
// forms.json all come from one Conjugator. ToolWorld.swift explains what to do when one of
// those sources starts reaching app-only code.

import Foundation

/// The command line, as a dictionary of flag to path. Every flag takes exactly one value.
private func parseArguments() -> [String: String] {
  var values: [String: String] = [:]
  var remaining = CommandLine.arguments.dropFirst()
  while let flag = remaining.popFirst() {
    guard flag.hasPrefix("--"), let value = remaining.popFirst() else {
      fail("Expected --flag value pairs, got \(flag).")
    }
    values[flag] = value
  }
  return values
}

private func fail(_ message: String) -> Never {
  FileHandle.standardError.write(Data("error: ConjugationMapTool: \(message)\n".utf8))
  exit(1)
}

/// The shape the Python pipelines read: form → [{verb, contiguous, particle?}]. `contiguous`
/// is false exactly when the form is the finite part of a split separable verb, so it is
/// redundant with `particle`, but the pipelines test it and the field stays.
private struct FormsJSONEntry: Encodable {
  let verb: String
  let contiguous: Bool
  /// Omitted for contiguous forms, since JSONEncoder drops nil optionals.
  let particle: String?
}

let arguments = parseArguments()
guard let verbsPath = arguments["--verbs"], let ablautGroupsPath = arguments["--ablaut-groups"] else {
  fail("--verbs and --ablaut-groups are required.")
}
let mapPath = arguments["--map"]
let formsJSONPath = arguments["--forms-json"]
if mapPath == nil && formsJSONPath == nil {
  fail("Nothing to write. Pass --map, --forms-json, or both.")
}

// Order matters for nothing here, since the Conjugator reads both tables only when called, but
// the app loads them in this order too (AppLauncher).
Verb.verbs = VerbParser(contentsOf: URL(fileURLWithPath: verbsPath)).parse()
AblautGroup.ablautGroups = AblautGroupParser(contentsOf: URL(fileURLWithPath: ablautGroupsPath)).parse()
if Verb.verbs.isEmpty || AblautGroup.ablautGroups.isEmpty {
  fail("Parsed \(Verb.verbs.count) verbs and \(AblautGroup.ablautGroups.count) ablaut groups. Check the paths.")
}

let map = ConjugationMap.build()
let finitePartCount = map.entriesByConjugation.values.filter { $0.contains { $0.particle != nil } }.count

do {
  if let mapPath {
    // Not .atomic: an atomic write creates a temporary file beside the output, and Xcode's
    // script sandbox (ENABLE_USER_SCRIPT_SANDBOXING) permits writing only the declared output.
    try map.compressed().write(to: URL(fileURLWithPath: mapPath))
  }
  if let formsJSONPath {
    let forms = map.entriesByConjugation.mapValues { entries in
      entries.map { FormsJSONEntry(verb: $0.infinitiv, contiguous: $0.particle == nil, particle: $0.particle) }
    }
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
    try encoder.encode(forms).write(to: URL(fileURLWithPath: formsJSONPath))
  }
} catch {
  fail("Could not write: \(error)")
}

print("ConjugationMapTool: \(map.entriesByConjugation.count) conjugations (\(finitePartCount) with a finite part) from \(Verb.verbs.count) verbs")
