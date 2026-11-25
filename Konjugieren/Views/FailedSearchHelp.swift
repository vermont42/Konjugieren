// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI

/// What the verb list shows when a search finds nothing: "No verbs found", the guess once it
/// arrives, and a link to ask for the verb by mail.
struct FailedSearchHelp: View {
  let query: String
  let guess: VerbSearchResults.Hit?
  let guessIsSelected: Bool
  let conjugationgroupLang: ConjugationgroupLang
  let openGuess: () -> Void
  @State private var addressWasCopied = false

  var body: some View {
    ContentUnavailableView(L.VerbBrowse.noVerbsFound, systemImage: "magnifyingglass")

    VStack(alignment: .leading, spacing: Layout.defaultSpacing) {
      if let guess {
        Text(L.VerbBrowse.guessIntro)
          .font(.subheadline)
          .foregroundStyle(.secondary)
          .padding(.horizontal)
          .accessibilityIdentifier("search_guess_intro")

        VerbRowView(verb: guess.verb, match: guess.conjugation, conjugationgroupLang: conjugationgroupLang) { openGuess() }
          .background(guessIsSelected ? Color.customRed.opacity(0.2) : Color.clear)

        Divider()
          .padding(.leading)
      }

      Text(verbRequestText)
        .font(.footnote)
        .foregroundStyle(.secondary)
        .padding(.horizontal)
        .padding(.top, Layout.defaultSpacing)
        .accessibilityIdentifier("verb_request_link")
        .environment(\.openURL, OpenURLAction { url in
          Task {
            await openVerbRequest(url)
          }
          return .handled
        })

      if addressWasCopied {
        Text(L.VerbBrowse.addressCopied)
          .font(.footnote)
          .foregroundStyle(Color.customYellow)
          .padding(.horizontal)
          .transition(.opacity)
          .accessibilityIdentifier("address_copied_note")
      }
    }
    .animation(.easeInOut, value: guess)
  }

  private var verbRequestText: AttributedString {
    let address = URL.developerEmail
    var text = AttributedString(L.VerbBrowse.verbRequest(query: query, address: address))
    if
      let range = text.range(of: address, options: .backwards),
      let url = URL.mailto(address, subject: L.VerbBrowse.verbRequestSubject(query: query), body: L.VerbBrowse.verbRequestBody(query: query)) {
      text[range].link = url
    }
    return text
  }

  /// A device with no email app, such as the simulator, cannot open the link, so the address
  /// goes to the clipboard instead of nowhere.
  private func openVerbRequest(_ url: URL) async {
    guard !(await UIApplication.shared.open(url)) else {
      return
    }
    UIPasteboard.general.string = URL.developerEmail
    AccessibilityNotification.Announcement(L.VerbBrowse.addressCopied).post()
    withAnimation {
      addressWasCopied = true
    }
    try? await Task.sleep(for: .seconds(4))
    withAnimation {
      addressWasCopied = false
    }
  }
}
