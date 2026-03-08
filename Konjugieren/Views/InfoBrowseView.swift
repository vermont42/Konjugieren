// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI

struct InfoBrowseView: View {
  @Bindable var world = Current
  @State private var navigationPath = NavigationPath()

  var body: some View {
    NavigationStack(path: $navigationPath) {
      ScrollView {
        LazyVStack(spacing: 0) {
          ForEach(Array(Info.infos.enumerated()), id: \.element.heading) { index, info in
            InfoRowView(info: info) { navigationPath.append(info) }

            Divider()
              .padding(.leading)

            if index == 0, Current.languageModelService.isAvailable {
              TutorRowView { navigationPath.append("tutor") }

              Divider()
                .padding(.leading)
            }
          }
        }
      }
      .onAppear { Current.analytics.signal(name: .viewInfoBrowseView) }
      .navigationTitle(L.Navigation.info)
      .navigationDestination(for: String.self) { destination in
        if destination == "tutor" {
          TutorView()
        }
      }
      .navigationDestination(for: Info.self) { info in
        InfoView(info: info)
      }
      .task(id: world.shouldNavigateToTutor) {
        guard world.shouldNavigateToTutor else { return }
        try? await Task.sleep(for: .milliseconds(500))
        world.shouldNavigateToTutor = false
        navigationPath.append("tutor")
      }
      .sheet(item: $world.info) { info in
        NavigationStack {
          InfoView(info: info, shouldShowInfoHeading: true)
            .toolbar {
              ToolbarItem(placement: .cancellationAction) {
                Button(L.Navigation.dismiss) {
                  Current.info = nil
                }
              }
            }
        }
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

      switch info.media {
      case .photo(let filename, let accessibilityLabel):
        Image(filename)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 60, height: 60)
          .clipShape(RoundedRectangle(cornerRadius: 8))
          .accessibilityLabel(accessibilityLabel)
          .accessibilityAddTraits(.isButton)
          .accessibilityAction { navigate() }
      case .sfSymbol(let name):
        Image(systemName: name)
          .font(.title)
          .foregroundStyle(.customYellow)
          .accessibilityHidden(true)
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

struct TutorRowView: View {
  let navigate: () -> Void

  var body: some View {
    HStack(alignment: .top) {
      VStack(alignment: .leading, spacing: 4) {
        Text(L.Tutor.heading)
          .tableText()
          .accessibilityAddTraits(.isButton)
          .accessibilityAction { navigate() }

        Text(L.Tutor.description)
          .font(.subheadline)
          .foregroundStyle(.customForeground)
          .lineLimit(2)
          .accessibilityAddTraits(.isButton)
          .accessibilityAction { navigate() }
      }

      Spacer()

      Image(systemName: "brain.head.profile.fill")
        .font(.title)
        .foregroundStyle(.customYellow)
        .accessibilityHidden(true)
    }
    .padding(.horizontal)
    .padding(.vertical, 12)
    .contentShape(Rectangle())
    .onTapGesture { navigate() }
  }
}

#Preview {
  InfoBrowseView()
}
