// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI

struct InfoView: View {
  let info: Info

  /// Where the article's links to other articles and to verbs go. Nil hands them to
  /// `Current.handleURL`, which opens an article in the Info tab and a verb in the Verbs tab.
  /// An article opened from a verb page passes its own, so that the learner stays there.
  var openLink: ((URL) -> Void)?

  var body: some View {
    ZStack {
      Color.customBackground
        .ignoresSafeArea()

      ScrollView {
        VStack(alignment: .leading, spacing: 0) {
          Text(info.heading)
            .font(.largeTitle.bold())
            .fontDesign(.serif)
            .foregroundStyle(.customYellow)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.bottom, 8)
            .accessibilityAddTraits(.isHeader)
            .germanPronunciation(forReal: info.alwaysUsesGermanPronunciation)

          switch info.media {
          case .photo(let filename, let accessibilityLabel):
            Image(filename)
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(width: 270)
              .frame(maxWidth: .infinity)
              .accessibilityLabel(accessibilityLabel)
              .scrollTransition { content, phase in
                content.scaleEffect(1 + phase.value * 0.05)
              }
              .padding(.bottom, 4)
          case .sfSymbol(let name):
            Image(systemName: name)
              .font(.system(size: 60))
              .foregroundStyle(.customYellow)
              .frame(maxWidth: .infinity)
              .accessibilityHidden(true)
              .padding(.bottom, 4)
          }

          HStack(spacing: 6) {
            Circle().fill(.black).frame(width: 4, height: 4)
            Circle().fill(.customRed).frame(width: 4, height: 4)
            Circle().fill(.customYellow).frame(width: 4, height: 4)
          }
          .frame(maxWidth: .infinity)
          .padding(.bottom, 12)
          .accessibilityHidden(true)

          RichTextView(blocks: info.richTextBlocks)
            .frame(minWidth: 0, maxWidth: 680, alignment: .leading)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.leading, Layout.doubleDefaultSpacing)
        .padding(.trailing, Layout.doubleDefaultSpacing)
      }
      .navigationBarTitleDisplayMode(.inline)
    }
    .onAppear { Current.analytics.signal(name: .viewInfoView) }
    .environment(\.openURL, OpenURLAction { url in
      handleInfoLink(url)
    })
  }

  private func handleInfoLink(_ url: URL) -> OpenURLAction.Result {
    let cleaned = cleanURLString(url.absoluteString)

    if let infoIndex = Info.headingToIndex(heading: cleaned) {
      if let infoURL = URL(string: "\(URL.konjugierenURLPrefix)\(URL.infoHost)/\(infoIndex)") {
        open(infoURL)
      }
      return .handled
    }

    if Verb.verbs[cleaned] != nil {
      if let verbURL = URL.verbDeeplink(cleaned, source: .infoLink) {
        open(verbURL)
      }
      return .handled
    }

    return .systemAction
  }

  private func open(_ url: URL) {
    if let openLink {
      openLink(url)
    } else {
      Current.handleURL(url)
    }
  }

  private func cleanURLString(_ input: String) -> String {
    let decoded = input.removingPercentEncoding ?? input
    let parenless = decoded
      .replacingOccurrences(of: "(", with: "")
      .replacingOccurrences(of: ")", with: "")
    return parenless.prefix(1).lowercased() + parenless.dropFirst()
  }
}
