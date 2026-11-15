// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI

struct ResultsView: View {
  let quiz: Quiz
  private var settings: Settings { Current.settings }
  @State private var displayedScore = 0
  /// The rows whose literary example the learner has opened.
  @State private var shownExamples: Set<UUID> = []

  private var scoreColor: Color {
    // A right second attempt and a right re-ask earn half points, and the credit here follows
    // the points.
    let percentage = Double(quiz.score) / Double(max(quiz.maximumScore, 1))
    if percentage > 0.8 {
      return .green
    } else if percentage >= 0.5 {
      return .customYellow
    } else {
      return .customRed
    }
  }

  var body: some View {
    ZStack {
      Color.customBackground
        .ignoresSafeArea()

      VStack(alignment: .leading, spacing: 0) {
        VStack(spacing: Layout.defaultSpacing) {
          Text(L.Quiz.results)
            .subheadingLabel()
            .accessibilityAddTraits(.isHeader)

          Text("\(displayedScore)")
            .font(.system(size: 48, weight: .bold, design: .rounded))
            .foregroundStyle(scoreColor)
            .contentTransition(.numericText())
            .accessibilityLabel(Text(verbatim: "\(L.Quiz.score) \(quiz.finalScore)"))
            .accessibilityIdentifier("results_score")

          // A flow, since a second try and a re-ask can make five items, more than an iPhone's
          // line holds.
          FlowLayout(spacing: Layout.doubleDefaultSpacing, centersRows: true) {
            Text(label: L.Quiz.correct, value: "\(quiz.correctCount) / \(quiz.questionCount)")
              .font(.caption.monospacedDigit())
            if quiz.secondAttemptCount > 0 {
              Text(label: L.Quiz.secondTry, value: "\(quiz.secondAttemptCount)")
                .font(.caption.monospacedDigit())
                .accessibilityIdentifier("results_second_try")
            }
            if quiz.reaskCount > 0 {
              Text(label: L.Quiz.askedAgainLabel, value: "\(quiz.reaskCorrectCount) / \(quiz.reaskCount)")
                .font(.caption.monospacedDigit())
                .accessibilityIdentifier("results_asked_again")
            }
            // An ablaut group's practice asks the same at every level.
            if quiz.scope.ablautPractice == nil {
              Text(label: L.Quiz.level, value: quiz.level.localizedName)
                .font(.caption)
            }
            if settings.quizClock == .show {
              Text(label: L.Quiz.time, value: TimeFormatter.formatIntTime(quiz.elapsedSeconds))
                .font(.caption.monospacedDigit())
            }
          }
          .accessibilityElement(children: .combine)
        }
        .frame(maxWidth: .infinity)
        .konjCard()
        .padding(.horizontal, Layout.doubleDefaultSpacing)
        .padding(.top, Layout.tripleDefaultSpacing)

        if quiz.canContinue {
          Button {
            quiz.continueSession()
          } label: {
            Label(continueLabel, systemImage: "plus.circle.fill")
          }
          .funButton()
          .frame(maxWidth: .infinity)
          .padding(.top, Layout.doubleDefaultSpacing)
          .accessibilityHint(continueHint)
          .accessibilityIdentifier("results_ten_more")
        }

        GradientDivider()
          .padding(.horizontal, Layout.doubleDefaultSpacing)
          .padding(.top, Layout.defaultSpacing)

        List {
          ForEach(quiz.questions) { question in
            resultRow(for: question)
              .listRowBackground(Color.customBackground)
          }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)

        Spacer()
      }
    }
    .onAppear {
      withAnimation(.easeOut(duration: 0.6)) {
        displayedScore = quiz.finalScore
      }
    }
  }

  // An ablaut group's round is as many verbs as the group and the known groups can give, which
  // may be fewer than five, so its button promises a round rather than a number.
  private var continueLabel: String {
    if quiz.scope.ablautPractice != nil {
      return L.AblautPractice.anotherRound
    }
    return quiz.scope.isVerbEssentials ? L.VerbEssentials.fiveMore : L.Quiz.tenMore
  }

  private var continueHint: String {
    if quiz.scope.ablautPractice != nil {
      return L.Accessibility.ablautPracticeMoreHint
    }
    return quiz.scope.isVerbEssentials ? L.Accessibility.verbEssentialsMoreHint : L.Accessibility.quizTenMoreHint
  }

  /// The rows that offer the verb's literary example: the first right answer of each verb, so
  /// that a Verb Essentials verb's three right blanks offer it once. A reward for a right answer
  /// shown after the quiz, never during it, since the quiz moves on at once after a right answer
  /// (Phase 18 of the pedagogy plan, as Josh decided on 2026-11-13 and 2026-11-15).
  private var exampleRowIDs: Set<UUID> {
    var verbs: Set<String> = []
    var ids: Set<UUID> = []
    for question in quiz.questions where question.isCorrect == true && !verbs.contains(question.verb.infinitiv) {
      verbs.insert(question.verb.infinitiv)
      ids.insert(question.id)
    }
    return ids
  }

  @ViewBuilder
  private func exampleSentence(for question: QuizItem) -> some View {
    if let pair = ExampleSentences.pair(for: question.verb.infinitiv) {
      let isShown = shownExamples.contains(question.id)
      Button {
        if isShown {
          shownExamples.remove(question.id)
        } else {
          shownExamples.insert(question.id)
        }
      } label: {
        // Not a Label, which a List lays out with its icon in a column of its own.
        HStack(spacing: 4) {
          Image(systemName: isShown ? "quote.bubble.fill" : "quote.bubble")
          Text(L.VerbView.exampleSentenceHeading)
        }
        .font(.caption)
        .foregroundStyle(.customYellow)
      }
      // Borderless, so that only the button, not the whole row, takes the tap.
      .buttonStyle(.borderless)
      .accessibilityAddTraits(isShown ? .isSelected : [])
      .accessibilityHint(L.Accessibility.exampleSentenceHint)
      .accessibilityIdentifier("results_example_\(question.verb.infinitiv)")

      if isShown {
        VStack(spacing: 4) {
          Text(pair.german.sentence)
            .italic()
            .germanPronunciation()
          Text(pair.english.sentence)
            .italic()
            .foregroundStyle(.secondary)
            .englishPronunciation()
          Text(verbatim: "— \(pair.german.source)")
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .font(.subheadline)
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: true)
        .padding(.top, 4)
      }
    }
  }

  @ViewBuilder
  private func resultRow(for question: QuizItem) -> some View {
    let titleIsGerman = settings.conjugationgroupLang == .german

    let infinitivDisplay = question.isCorrect == false
      ? "\(question.verb.infinitiv.inUserRegion) \u{2717}"
      : question.verb.infinitiv.inUserRegion

    VStack(alignment: .center, spacing: 4) {
      // Not a Label, which a List lays out with its icon in a column of its own.
      if question.isReask {
        HStack(spacing: 4) {
          Image(systemName: "arrow.counterclockwise")
          Text(L.Quiz.askedAgain)
        }
        .font(.caption)
        .foregroundStyle(.customYellow)
      }

      Text(verbatim: infinitivDisplay)
        .germanPronunciation()

      Text(verbatim: "\(question.displayName(lang: settings.conjugationgroupLang)) - \(question.pronoun ?? "")")
        .font(.caption)
        .foregroundStyle(.secondary)
        .germanPronunciation(forReal: titleIsGerman)

      Text(mixedCaseString: question.correctAnswer)
        .germanPronunciation()
        .accessibilityLabel(Text(verbatim: MixedCaseAccessibility.accessibilityLabel(for: question.correctAnswer)))

      if question.isCorrect == false, let userAnswer = question.userAnswer {
        Text(verbatim: userAnswer)
          .foregroundStyle(.customRed)
          .germanPronunciation()
      }

      if question.state == .correctOnSecondAttempt, let firstAttempt = question.firstAttempt {
        HStack(spacing: 0) {
          Text(L.Quiz.firstTry + " ")
            .foregroundStyle(.customYellow)
          Text(verbatim: firstAttempt)
            .foregroundStyle(QuizItem.State.correctOnSecondAttempt.dotColor)
            .germanPronunciation()
        }
        .font(.caption)
      }

      if exampleRowIDs.contains(question.id) {
        exampleSentence(for: question)
      }
    }
    .frame(maxWidth: .infinity)
  }

}

#Preview {
  let quiz = Quiz()
  quiz.start()
  return ResultsView(quiz: quiz)
}
