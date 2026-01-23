// Copyright © 2025 Josh Adams. All rights reserved.

import SwiftUI

struct InfoBrowseView: View {
  @State private var isPresentingInfo = false
  @State private var isPresentingVerb = false

  var body: some View {
    NavigationView {
      ScrollView {
        LazyVStack(spacing: 0) {
          ForEach(Info.infos, id: \.heading) { info in
            NavigationLink(destination: InfoView(info: info)) {
              InfoRowView(info: info)
            }
            .buttonStyle(.plain)
            .germanPronunciation(forReal: info.alwaysUsesGermanPronunciation)

            Divider()
              .padding(.leading)
          }
        }
      }
      .navigationBarTitle(L.Navigation.info)
      .navigationViewStyle(.stack) // https://stackoverflow.com/a/66024249
      .onChange(of: Current.info) { _, newInfo in
        if newInfo == nil {
          isPresentingInfo = false
        } else {
          isPresentingInfo = true
        }
      }
      .onChange(of: Current.verb) { _, newVerb in
        if newVerb == nil {
          isPresentingVerb = false
        } else {
          isPresentingVerb = true
        }
      }
      .sheet(
        isPresented: $isPresentingInfo,
        onDismiss: {
          Current.info = nil
          isPresentingInfo = false
        },
        content: {
          Current.info.map {
            InfoView(info: $0, shouldShowInfoHeading: true)
          }
        }
      )
      .sheet(
        isPresented: $isPresentingVerb,
        onDismiss: {
          Current.verb = nil
          isPresentingVerb = false
        },
        content: {
          Current.verb.map {
            VerbView(verb: $0)
          }
        }
      )
//      .onAppear {
//        Current.analytics.recordViewAppeared("\(InfoBrowseView.self)")
//      }
    }
  }
}

struct InfoRowView: View {
  let info: Info

  var body: some View {
    HStack(alignment: .top) {
      VStack(alignment: .leading, spacing: info.hasPreview ? 4 : 0) {
        Text(info.heading)
          .tableText()
        if info.hasPreview {
          formattedPreviewText()
            .lineLimit(2)
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
      }
    }
    .padding(.horizontal)
    .padding(.vertical, 12)
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
      .foregroundColor(.customForeground)
  }
}

#Preview {
  InfoBrowseView()
}
