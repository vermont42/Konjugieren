// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI

/// What the Quiz tab's hub pushes for its Mastery row.
struct MasteryDestination: Hashable {}

/// What the practice record has made secure at the learner's level: the weak verbs'
/// patterns, then the key conjugations of the 50 most frequent strong and mixed verbs. It only
/// shows. A verb here links to nothing, since opening a verb page is a lookup, which would send
/// the verb's key conjugations back to the first box.
struct MasteryView: View {
  var body: some View {
    let mastery = Mastery(level: Current.settings.quizLevel, record: Current.practice.record)
    let lang = Current.settings.conjugationgroupLang

    ZStack {
      Color.customBackground
        .ignoresSafeArea()

      ScrollView {
        LazyVStack(alignment: .leading, spacing: Layout.defaultSpacing) {
          Text(L.Mastery.intro(mastery.level.localizedName))
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)

          legend
            .padding(.bottom, Layout.defaultSpacing)

          sectionHeader(L.Mastery.patterns, count: L.Mastery.count(mastery.masteredPatternCount, mastery.patternCount), description: L.Mastery.patternsDescription)

          ForEach(mastery.patterns) { row in
            MasteryPatternRowView(row: row, lang: lang)
          }

          sectionHeader(L.Mastery.verbs, count: L.Mastery.count(mastery.masteredVerbCount, mastery.verbCount), description: L.Mastery.verbsDescription)
            .padding(.top, Layout.doubleDefaultSpacing)

          ForEach(mastery.verbs) { row in
            MasteryVerbRowView(row: row)
            Divider()
          }
        }
        .padding(.horizontal, Layout.doubleDefaultSpacing)
        .padding(.vertical, Layout.doubleDefaultSpacing)
        .frame(maxWidth: 680)
        .frame(maxWidth: .infinity)
      }
    }
    .navigationTitle(L.Mastery.title)
    .navigationBarTitleDisplayMode(.inline)
    .onAppear {
      Current.analytics.signal(name: .viewMastery)
    }
  }

  private var legend: some View {
    FlowLayout(spacing: Layout.doubleDefaultSpacing) {
      ForEach([MasteryState.mastered, .learning, .notPracticed], id: \.self) { state in
        HStack(spacing: 4) {
          MasteryMark(state: state)
            .accessibilityHidden(true)
          Text(state.label)
            .font(.subheadline)
            .foregroundStyle(.customForeground)
        }
        .accessibilityElement(children: .combine)
      }
    }
  }

  private func sectionHeader(_ title: String, count: String, description: String) -> some View {
    VStack(alignment: .leading, spacing: 4) {
      HStack(alignment: .firstTextBaseline) {
        Text(title)
          .font(.title3.bold())
          .foregroundStyle(.customForeground)
        Spacer()
        Text(verbatim: count)
          .font(.subheadline.monospacedDigit())
          .foregroundStyle(.secondary)
      }
      .accessibilityElement(children: .combine)
      .accessibilityAddTraits(.isHeader)

      Text(description)
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .fixedSize(horizontal: false, vertical: true)
    }
  }
}

/// A conjugationgroup's patterns: a mark under each person, or one mark for a participle.
private struct MasteryPatternRowView: View {
  let row: Mastery.PatternRow
  let lang: ConjugationgroupLang

  var body: some View {
    VStack(alignment: .leading, spacing: Layout.defaultSpacing) {
      HStack(alignment: .firstTextBaseline) {
        Text(verbatim: row.table.displayName(lang: lang))
          .font(.headline)
          .foregroundStyle(.customForeground)
          .germanPronunciation(forReal: lang == .german)

        if row.servesEveryVerb {
          Text(L.Mastery.everyVerb)
            .font(.caption)
            .foregroundStyle(.customYellow)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(Color.customYellow.opacity(0.12), in: Capsule())
        }

        Spacer(minLength: 0)

        if row.cells.count == 1, let cell = row.cells.first {
          MasteryMark(state: cell.state)
            .font(.title3)
        }
      }

      if row.cells.count > 1 {
        HStack(spacing: 0) {
          ForEach(row.cells) { cell in
            VStack(spacing: 4) {
              Text(verbatim: Self.pronoun(of: cell.conjugationgroup))
                .font(.caption)
                .foregroundStyle(.secondary)
                .germanPronunciation()
              MasteryMark(state: cell.state)
                .font(.title3)
            }
            .frame(maxWidth: .infinity)
          }
        }
      }
    }
    .padding(Layout.doubleDefaultSpacing)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(Color.customYellow.opacity(0.06), in: RoundedRectangle(cornerRadius: 16))
    .overlay {
      RoundedRectangle(cornerRadius: 16)
        .strokeBorder(Color.customYellow.opacity(0.25), lineWidth: 1)
    }
    .accessibilityIdentifier("mastery_pattern_\(row.table.articleKey)")
  }

  private static func pronoun(of conjugationgroup: Conjugationgroup) -> String {
    guard let personNumber = conjugationgroup.personNumber else {
      return ""
    }
    if conjugationgroup.table == .imperativ {
      return personNumber.imperativPronoun ?? personNumber.pronoun
    }
    return personNumber.pronoun
  }
}

/// A strong or mixed reading: the infinitive, its gloss, and a mark beside each key conjugation
/// the level asks.
private struct MasteryVerbRowView: View {
  let row: Mastery.VerbRow

  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      HStack(alignment: .firstTextBaseline, spacing: Layout.defaultSpacing) {
        Text(verbatim: row.verb.infinitiv.inUserRegion)
          .font(.headline)
          .foregroundStyle(.customYellow)
          .germanPronunciation()
        Text(verbatim: row.verb.reading(at: row.readingIndex)?.translation ?? row.verb.translation)
          .font(.subheadline)
          .foregroundStyle(.secondary)
          .englishPronunciation()
      }

      FlowLayout(spacing: Layout.doubleDefaultSpacing) {
        ForEach(row.keyConjugations) { keyConjugation in
          let conjugation = keyConjugation.conjugation()
          HStack(spacing: 4) {
            MasteryMark(state: keyConjugation.state)
            Text(mixedCaseString: conjugation)
              .font(.body)
              .accessibilityLabel(Text(verbatim: conjugation.lowercased()))
              .germanPronunciation()
          }
        }
      }
    }
    .padding(.vertical, 6)
    .accessibilityIdentifier("mastery_verb_\(row.id)")
  }
}

/// ● mastered, ◐ learning, ○ not yet practiced. Each state has its own shape, not only its own
/// color, and VoiceOver reads its name.
private struct MasteryMark: View {
  let state: MasteryState

  var body: some View {
    Image(systemName: state.systemImage)
      .foregroundStyle(state == .notPracticed ? Color.secondary : Color.customYellow)
      .accessibilityLabel(state.label)
  }
}

extension MasteryState {
  var label: String {
    switch self {
    case .learning:
      return L.Mastery.learning
    case .mastered:
      return L.Mastery.mastered
    case .notPracticed:
      return L.Mastery.notPracticed
    }
  }

  var systemImage: String {
    switch self {
    case .learning:
      return "circle.lefthalf.filled"
    case .mastered:
      return "circle.fill"
    case .notPracticed:
      return "circle"
    }
  }
}
