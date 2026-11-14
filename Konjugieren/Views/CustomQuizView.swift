// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI

/// The pages a custom quiz's choice pushes onto the Quiz tab.
enum CustomQuizDestination: Hashable {
  case ablautGroups
  case editor
}

/// Where the learner chooses a custom quiz's conjugationgroups and verbs. Each tap is kept at once,
/// so the choice survives leaving the page and relaunching.
struct CustomQuizEditor: View {
  private var settings: Settings { Current.settings }

  private var custom: CustomQuiz {
    settings.customQuiz
  }

  private var level: QuizLevel {
    settings.quizLevel
  }

  private var myVerbs: [Verb] {
    Current.learnerVerbs.myVerbs
  }

  private var lang: ConjugationgroupLang {
    settings.conjugationgroupLang
  }

  var body: some View {
    List {
      Section {
        CustomQuizChoiceRow(title: L.CustomQuiz.byLevel, detail: level.localizedName, isSelected: custom.tables.isEmpty) {
          Current.settings.customQuiz.tables = []
        }
        .accessibilityIdentifier("custom_quiz_groups_by_level")

        ForEach(ConjugationTable.allCases, id: \.self) { table in
          CustomQuizChoiceRow(
            title: table.displayName(lang: lang),
            titleIsGerman: lang == .german,
            detail: table.secondName(lang: lang).text,
            detailIsGerman: table.secondName(lang: lang).isGerman,
            isSelected: custom.tables.contains(table)
          ) {
            Current.settings.customQuiz.tables.formSymmetricDifference([table])
          }
          .accessibilityIdentifier("custom_quiz_group_\(table.articleKey)")
        }
      } header: {
        Text(L.CustomQuiz.conjugationgroups)
      } footer: {
        Text(L.CustomQuiz.conjugationgroupsFooter)
      }

      Section {
        CustomQuizChoiceRow(title: L.CustomQuiz.byLevel, detail: CustomQuiz.levelVerbsDescription(level), isSelected: custom.verbSet == nil) {
          Current.settings.customQuiz.verbSet = nil
        }
        .accessibilityIdentifier("custom_quiz_verbs_by_level")

        ForEach(Self.verbSets(showsMyVerbs: !myVerbs.isEmpty || custom.verbSet == .myVerbs, keptList: custom.verbSet), id: \.self) { verbSet in
          CustomQuizChoiceRow(
            title: verbSet.title,
            detail: verbSet.detail(myVerbCount: myVerbs.count),
            isSelected: custom.verbSet == verbSet
          ) {
            Current.settings.customQuiz.verbSet = verbSet
          }
          .accessibilityIdentifier("custom_quiz_verbs_\(verbSet.key)")
        }

        NavigationLink(value: CustomQuizDestination.ablautGroups) {
          HStack {
            Text(L.CustomQuiz.ablautGroups)
              .foregroundStyle(.customForeground)
            Spacer()
            if case .collection(.ablautGroup(let exemplar)) = custom.verbSet {
              Text(verbatim: exemplar)
                .foregroundStyle(.customYellow)
                .germanPronunciation()
            }
          }
        }
        .accessibilityAddTraits(custom.verbSet?.isAblautGroup == true ? .isSelected : [])
        .accessibilityIdentifier("custom_quiz_verbs_ablaut")
      } header: {
        Text(L.CustomQuiz.verbs)
      }
    }
    .scrollContentBackground(.hidden)
    .background(Color.customBackground)
    .navigationTitle(L.CustomQuiz.title)
    .navigationBarTitleDisplayMode(.inline)
  }

  // Semantic ordering: narrowest first, then the lists. A practice set's list, once kept, is
  // offered only while it is the choice, since nothing in the editor can build one.
  private static func verbSets(showsMyVerbs: Bool, keptList: QuizVerbSet?) -> [QuizVerbSet] {
    var list: [QuizVerbSet] = []
    if case .list = keptList, let keptList {
      list = [keptList]
    }
    return FrequencyBand.allCases.map(QuizVerbSet.band) + [.all] + (showsMyVerbs ? [.myVerbs] : []) + list + [.collection(.modals), .collection(.sein)]
  }
}

/// The ablaut groups, one of which a custom quiz may ask. Choosing one returns to the choice.
struct CustomQuizAblautGroupList: View {
  @Environment(\.dismiss) private var dismiss

  private static let verbCounts: [String: Int] = Verb.verbs.values.reduce(into: [:]) { counts, verb in
    if let group = verb.ablautGroup {
      counts[group, default: 0] += 1
    }
  }

  var body: some View {
    List {
      ForEach(AblautGroupInfo.allGroups.filter { Self.verbCounts[$0.exemplar, default: 0] > 0 }) { group in
        let verbSet = QuizVerbSet.collection(.ablautGroup(group.exemplar))
        CustomQuizChoiceRow(
          title: group.exemplar,
          titleIsGerman: true,
          detail: L.VerbCollection.verbCount(Self.verbCounts[group.exemplar, default: 0]),
          isSelected: Current.settings.customQuiz.verbSet == verbSet
        ) {
          Current.settings.customQuiz.verbSet = verbSet
          dismiss()
        }
      }
    }
    .scrollContentBackground(.hidden)
    .background(Color.customBackground)
    .navigationTitle(L.CustomQuiz.ablautGroups)
    .navigationBarTitleDisplayMode(.inline)
  }
}

private struct CustomQuizChoiceRow: View {
  let title: String
  var titleIsGerman = false
  var detail: String?
  var detailIsGerman = false
  let isSelected: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      HStack {
        VStack(alignment: .leading, spacing: 2) {
          Text(verbatim: title)
            .foregroundStyle(.customForeground)
            .germanPronunciation(forReal: titleIsGerman)
          if let detail {
            // Color.secondary, since a button's .secondary derives from its tint, the app's red.
            Text(verbatim: detail)
              .font(.caption)
              .foregroundStyle(Color.secondary)
              .germanPronunciation(forReal: detailIsGerman)
          }
        }
        Spacer()
        Image(systemName: "checkmark")
          .fontWeight(.semibold)
          .foregroundStyle(.customYellow)
          .opacity(isSelected ? 1 : 0)
          .accessibilityHidden(true)
      }
      .contentShape(Rectangle())
    }
    .accessibilityElement(children: .combine)
    .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
  }
}

extension QuizVerbSet {
  /// A row's second line: how many My Verbs there are, or a list's first verbs.
  func detail(myVerbCount: Int) -> String? {
    switch self {
    case .myVerbs:
      return L.VerbCollection.verbCount(myVerbCount)
    case .list(let infinitives):
      let shown = infinitives.prefix(Self.listPreviewCount).map(\.inUserRegion)
      return shown.joined(separator: ", ") + (infinitives.count > shown.count ? " …" : "")
    case .all, .band, .collection:
      return nil
    }
  }

  static let listPreviewCount = 6

  var isAblautGroup: Bool {
    if case .collection(.ablautGroup) = self {
      return true
    }
    return false
  }
}

extension CustomQuiz {
  /// "Elementary · 300 Most Frequent Verbs": the verbs a level's default quiz asks.
  static func levelVerbsDescription(_ level: QuizLevel) -> String {
    let verbs = level.band.map { QuizVerbSet.band($0).title } ?? QuizVerbSet.all.title
    return "\(level.localizedName) · \(verbs)"
  }
}

/// What a custom quiz or a practice set asks: its conjugationgroups and its verbs, each the
/// level's when left unchosen.
struct CustomQuizSummaryCard: View {
  let custom: CustomQuiz
  let level: QuizLevel
  /// "Set by Your Level" for the learner's own quiz, "Set by Level" for a practice set's.
  let byLevelLabel: String
  var isLarge = false
  private var lang: ConjugationgroupLang { Current.settings.conjugationgroupLang }

  var body: some View {
    VStack(alignment: .leading, spacing: Layout.defaultSpacing) {
      row(
        L.CustomQuiz.conjugationgroups,
        value: custom.tables.isEmpty
          ? "\(byLevelLabel): \(level.localizedName)"
          : custom.orderedTables.map { $0.displayName(lang: lang) }.joined(separator: ", "),
        valueIsGerman: !custom.tables.isEmpty && lang == .german
      )
      row(
        L.CustomQuiz.verbs,
        value: custom.verbSet?.title ?? "\(byLevelLabel): \(CustomQuiz.levelVerbsDescription(level))"
      )
    }
    .font(isLarge ? .title3 : .body)
    .frame(maxWidth: .infinity, alignment: .leading)
    .konjCard()
    .accessibilityElement(children: .combine)
  }

  private func row(_ label: String, value: String, valueIsGerman: Bool = false) -> some View {
    VStack(alignment: .leading, spacing: 2) {
      Text(label)
        .font(.caption.bold())
        .foregroundStyle(.customYellow)
        .textCase(.uppercase)
      Text(verbatim: value)
        .foregroundStyle(.customForeground)
        .fixedSize(horizontal: false, vertical: true)
        .germanPronunciation(forReal: valueIsGerman)
    }
  }
}
