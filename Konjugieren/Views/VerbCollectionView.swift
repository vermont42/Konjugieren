// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI

/// A featured collection's page: its description, how many of its verbs have been looked up, a
/// quiz on it, a share button, and its verbs, the most frequent first. An ablaut group's
/// collection shows inside the Ablaut page instead, as `VerbCollectionBar` in its expanded group.
struct VerbCollectionView: View {
  let collection: VerbCollection
  let source: AnalyticsSource
  let navigateToVerb: (Verb) -> Void
  @State private var sortOrder = SortOrder.frequency
  @State private var hasSignaledView = false

  var body: some View {
    let verbs = collection.verbs()

    ZStack {
      Color.customBackground
        .ignoresSafeArea()

      ScrollView {
        VStack(alignment: .leading, spacing: 0) {
          HStack {
            Image(systemName: collection.systemImageName)
              .font(.largeTitle)
              .foregroundStyle(.customYellow)
            Text(collection.title)
              .font(.largeTitle.bold())
              .foregroundStyle(.customYellow)
              .multilineTextAlignment(.center)
          }
          .frame(maxWidth: .infinity, alignment: .center)
          .padding(.bottom, Layout.doubleDefaultSpacing)
          .accessibilityElement(children: .combine)
          .accessibilityAddTraits(.isHeader)
          .germanPronunciation(forReal: UserLocale.isGerman)

          Text(collection.shortDescription)
            .foregroundStyle(.customForeground)
            .frame(maxWidth: .infinity, alignment: .leading)
            .konjCard()

          VerbCollectionBar(collection: collection, verbs: verbs)
            .padding(.top, Layout.doubleDefaultSpacing)

          Picker(L.VerbBrowse.sortOrder, selection: $sortOrder) {
            ForEach(SortOrder.allCases, id: \.self) { order in
              Text(order.displayName)
                .tag(order)
            }
          }
          .pickerStyle(.segmented)
          .padding(.top, Layout.doubleDefaultSpacing)
          .sensoryFeedback(.selection, trigger: sortOrder)
          .accessibilityIdentifier("collection_sort_order")

          VerbListSection(verbs: verbs.sorted(by: sortOrder), showsLookedUp: true, navigateToVerb: navigateToVerb)
        }
        .padding(.horizontal, Layout.doubleDefaultSpacing)
      }
    }
    .navigationBarTitleDisplayMode(.inline)
    .onAppear {
      // A return from one of the list's verb pages is not another opening of the list.
      guard !hasSignaledView else {
        return
      }
      hasSignaledView = true
      collection.signalView(source: source)
    }
  }
}

/// How many of a collection's verbs have been looked up, with a quiz on them and a share button.
struct VerbCollectionBar: View {
  let collection: VerbCollection
  let verbs: [Verb]
  @State private var isQuizzing = false
  @State private var shareButtonFrame = CGRect.zero
  @Environment(\.isBeneathQuiz) private var isBeneathQuiz
  private var settings: Settings { Current.settings }

  var body: some View {
    let openedCount = Current.learnerVerbs.openedCount(of: verbs)

    VStack(alignment: .leading, spacing: Layout.defaultSpacing) {
      HStack(spacing: Layout.defaultSpacing) {
        Text(L.VerbCollection.progress(opened: openedCount, total: verbs.count))
          .font(.subheadline)
          .foregroundStyle(.customForeground)

        Spacer()

        // Opened from a quiz's held correction, a collection starts no second quiz over the first.
        if !isBeneathQuiz {
          Button {
            isQuizzing = true
          } label: {
            Label(L.Navigation.quiz, systemImage: "pencil.and.list.clipboard")
          }
          .accessibilityHint(L.VerbCollection.quizHint(questionCount: Quiz.questionCount))
          .accessibilityIdentifier("collection_quiz_button")
        }

        Button {
          share()
        } label: {
          Label(L.VerbView.share, systemImage: "square.and.arrow.up")
            .labelStyle(.iconOnly)
        }
        .onGeometryChange(for: CGRect.self) { proxy in
          proxy.frame(in: .global)
        } action: { frame in
          shareButtonFrame = frame
        }
        .accessibilityIdentifier("collection_share_button")
      }
      .buttonStyle(.bordered)
      .tint(.customYellow)

      ProgressView(value: Double(openedCount), total: Double(max(verbs.count, 1)))
        .tint(.customYellow)
        .accessibilityHidden(true)
    }
    .konjCard()
    .sheet(isPresented: $isQuizzing) {
      QuizSheet(scope: .collection(collection))
    }
  }

  private func share() {
    Current.analytics.signal(name: .tapShareCollection, parameters: [
      ParameterKey.collection.rawValue: collection.key
    ])
    ShareSheet.present(
      text: collection.shareText(),
      title: collection.title,
      icon: UIImage(named: settings.appIcon.previewAssetName),
      anchorLabel: L.VerbView.share,
      anchorRect: shareButtonFrame == .zero ? nil : shareButtonFrame
    )
  }
}

/// A featured collection's row on the Families tab.
struct VerbCollectionRow: View {
  let collection: VerbCollection

  var body: some View {
    let verbs = collection.verbs()
    let openedCount = Current.learnerVerbs.openedCount(of: verbs)

    HStack(alignment: .top, spacing: 12) {
      Image(systemName: collection.systemImageName)
        .font(.title2)
        .foregroundStyle(.customYellow)
        .frame(width: 32)

      VStack(alignment: .leading, spacing: 4) {
        Text(collection.title)
          .tableText()
        Text(collection.shortDescription)
          .tableSubtext()
      }

      Spacer()

      Text(verbatim: "\(openedCount)/\(verbs.count)")
        .font(.caption)
        .foregroundStyle(.secondary)
        .accessibilityLabel(L.VerbCollection.progress(opened: openedCount, total: verbs.count))
    }
    .contentShape(Rectangle())
    .padding(.horizontal)
    .padding(.vertical, 12)
    .accessibilityElement(children: .combine)
  }
}

/// A featured collection's card on the Families tab on iPad: three side by side.
struct VerbCollectionCard: View {
  let collection: VerbCollection

  var body: some View {
    let verbs = collection.verbs()
    let openedCount = Current.learnerVerbs.openedCount(of: verbs)

    VStack(alignment: .leading, spacing: Layout.defaultSpacing) {
      HStack {
        Image(systemName: collection.systemImageName)
          .font(.title2)
          .foregroundStyle(.customYellow)

        Spacer()

        Text(verbatim: "\(openedCount)/\(verbs.count)")
          .font(.caption)
          .foregroundStyle(.secondary)
          .accessibilityLabel(L.VerbCollection.progress(opened: openedCount, total: verbs.count))
      }

      Text(collection.title)
        .tableText()
      Text(collection.shortDescription)
        .tableSubtext()
        .fixedSize(horizontal: false, vertical: true)

      Spacer(minLength: 0)

      ProgressView(value: Double(openedCount), total: Double(max(verbs.count, 1)))
        .tint(.customYellow)
        .accessibilityHidden(true)
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    .background(LinearGradient(colors: [.customYellow.opacity(0.05), .clear], startPoint: .topLeading, endPoint: .bottomTrailing))
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .contentShape(Rectangle())
    .accessibilityElement(children: .combine)
  }
}

#Preview {
  @Previewable @State var navigationPath = NavigationPath()
  NavigationStack(path: $navigationPath) {
    VerbCollectionView(collection: .modals, source: .family) { verb in
      navigationPath.append(VerbDestination(verb: verb, source: .list))
    }
    .navigationDestination(for: VerbDestination.self) { destination in
      VerbView(verb: destination.verb, source: destination.source)
    }
  }
}
