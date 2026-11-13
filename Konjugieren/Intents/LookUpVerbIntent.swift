// Copyright © 2026 Josh Adams. All rights reserved.

import AppIntents

/// Says which verb a word belongs to ("ging: Präteritum Indikativ (ich, er) of gehen"), then
/// opens the app: on that verb's page when the word settles one verb, and otherwise on the verb
/// list searched for the word. Answering before opening means the answer arrives even when the
/// learner only wanted to hear it.
struct LookUpVerbIntent: AppIntent {
  static let title = LocalizedStringResource("Intent.lookUpVerbTitle")
  static let description = IntentDescription(LocalizedStringResource("Intent.lookUpVerbDescription"))

  // An English keyboard's autocorrection turned ging into Going before the intent saw it, and
  // the default keyboard type, ASCII, offers no umlauts.
  @Parameter(
    title: "Intent.lookUpVerbWord",
    inputOptions: String.IntentInputOptions(keyboardType: .default, capitalizationType: .none, autocorrect: false),
    requestValueDialog: IntentDialog("Intent.lookUpVerbWordPrompt")
  )
  var word: String

  func perform() async throws -> some IntentResult & OpensIntent & ProvidesDialog {
    let word = word
    let (answer, destination) = await MainActor.run {
      let settings = Current.settings
      let lookup = VerbLookup(word: word, verbs: Verb.verbsSortedByFrequency, includeGlosses: settings.searchScope == .infinitiveAndTranslation)
      return (lookup.answer(lang: settings.conjugationgroupLang, region: settings.region), lookup.destination)
    }
    let open = OpenLookupResultIntent()
    open.url = destination
    return .result(opensIntent: open, dialog: "\(answer)")
  }
}

/// What Look Up a Verb opens once it has answered. An intent's result can open the app only by
/// naming another intent, so this one exists only to be named there.
struct OpenLookupResultIntent: AppIntent {
  static let title = LocalizedStringResource("Intent.openLookupResultTitle")
  static let openAppWhenRun = true
  static let isDiscoverable = false

  @Parameter(title: "Intent.openLookupResultURL")
  var url: URL?

  func perform() async throws -> some IntentResult {
    let url = url
    await MainActor.run {
      if let url {
        Current.handleURL(url)
      }
    }
    return .result()
  }
}
