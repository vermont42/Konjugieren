// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI

struct InfoBrowseView: View {
  @Bindable var world = Current
  @State private var navigationPath = NavigationPath()

  var body: some View {
    NavigationStack(path: $navigationPath) {
      ScrollView {
        LazyVStack(spacing: 0) {
          ForEach(Info.infos, id: \.heading) { info in
            InfoRowView(info: info) { navigationPath.append(info) }

            Divider()
              .padding(.leading)
          }
        }
      }
      .onAppear { Current.analytics.signal(name: .viewInfoBrowseView) }
      .navigationTitle(L.Navigation.info)
      .navigationDestination(for: Info.self) { info in
        InfoView(info: info)
      }
      .sheet(item: $world.info) { info in
        InfoView(info: info, shouldShowInfoHeading: true)
      }
      .sheet(item: $world.verb) { verb in
        VerbView(verb: verb)
      }
    }
  }
}

struct InfoRowView: View {
  let info: Info
  let navigate: () -> Void

  private var showHeadingButtonTrait: Bool {
    !info.alwaysUsesGermanPronunciation || UserLocale.isGerman
  }

  var body: some View {
    HStack(alignment: .top) {
      VStack(alignment: .leading, spacing: info.hasPreview ? 4 : 0) {
        Text(info.heading)
          .tableText()
          .germanPronunciation(forReal: info.alwaysUsesGermanPronunciation)
          .accessibilityAddTraits(showHeadingButtonTrait ? .isButton : [])
          .accessibilityRemoveTraits(showHeadingButtonTrait ? [] : .isButton)
          .accessibilityAction { navigate() }
        if info.hasPreview {
          formattedPreviewText()
            .lineLimit(2)
            .accessibilityAddTraits(.isButton)
            .accessibilityAction { navigate() }
        }
      }

      Spacer()

      if let imageInfo = info.imageInfo {
        Image(imageInfo.filename)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 60, height: 60)
          .clipShape(RoundedRectangle(cornerRadius: 8))
          .accessibilityLabel(imageInfo.accessibilityLabel)
          .accessibilityAddTraits(.isButton)
          .accessibilityAction { navigate() }
      }
    }
    .padding(.horizontal)
    .padding(.vertical, 12)
    .contentShape(Rectangle())
    .onTapGesture { navigate() }
  }

  private func formattedPreviewText() -> some View {
    var result = AttributedString()

    for segment in info.previewSegments {
      switch segment {
      case .plain(let text):
        result.append(AttributedString(text))

      case .bold(let text):
        var attributed = AttributedString(text)
        attributed.inlinePresentationIntent = .stronglyEmphasized
        result.append(attributed)

      case .link(let text, _):
        result.append(AttributedString(text))

      case .conjugation(let parts):
        for part in parts {
          switch part {
          case .regular(let text):
            result.append(AttributedString(text))
          case .irregular(let text):
            var irregularAttr = AttributedString(text)
            irregularAttr.foregroundColor = Color.customRed
            result.append(irregularAttr)
          }
        }
      }
    }

    return Text(result)
      .font(.subheadline)
      .foregroundStyle(.customForeground)
  }
}

#Preview {
  InfoBrowseView()
}
