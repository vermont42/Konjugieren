// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI

struct SettingsView: View {
  var body: some View {
    @Bindable var settings = Current.settings

    NavigationStack {
      ZStack {
        Color.customBackground
          .ignoresSafeArea()

        VStack(alignment: .leading) {
          ScrollView(.vertical) {
            Text(L.Settings.conjugationgroupLangHeading)
              .subheadingLabel()

            Picker("", selection: $settings.conjugationgroupLang) {
              ForEach(ConjugationgroupLang.allCases, id: \.self) { conjugationgroupLang in
                Text(conjugationgroupLang.localizedConjugationgroupLang).tag(conjugationgroupLang)
              }
            }
            .segmentedPicker()

            Text(L.Settings.conjugationgroupLangDescription)
              .settingsLabel()

            Spacer(minLength: Layout.tripleDefaultSpacing)

            Text(L.Settings.thirdPersonPronounGenderHeading)
              .subheadingLabel()

            Picker("", selection: $settings.thirdPersonPronounGender) {
              ForEach(ThirdPersonPronounGender.allCases, id: \.self) { thirdPersonPronounGender in
                Text(thirdPersonPronounGender.localizedThirdPersonPronounGender).tag(thirdPersonPronounGender)
              }
            }
            .segmentedPicker()

            Text(L.Settings.thirdPersonPronounGenderDescription)
              .settingsLabel()

            Spacer(minLength: Layout.tripleDefaultSpacing)

            Text(L.Settings.quizDifficultyHeading)
              .subheadingLabel()

            Picker("", selection: $settings.quizDifficulty) {
              ForEach(QuizDifficulty.allCases, id: \.self) { quizDifficulty in
                Text(quizDifficulty.localizedQuizDifficulty).tag(quizDifficulty)
              }
            }
            .segmentedPicker()

            Text(L.Settings.quizDifficultyDescription)
              .settingsLabel()

            Spacer(minLength: Layout.tripleDefaultSpacing)

            Text(L.Settings.audioFeedbackHeading)
              .subheadingLabel()

            Picker("", selection: $settings.audioFeedback) {
              ForEach(AudioFeedback.allCases, id: \.self) { audioFeedback in
                Text(audioFeedback.localizedAudioFeedback).tag(audioFeedback)
              }
            }
            .segmentedPicker()

            Text(L.Settings.audioFeedbackDescription)
              .settingsLabel()

            Spacer(minLength: Layout.tripleDefaultSpacing)
          }
        }
        .onAppear {
          // TODO: Fire analytic and fetch ratings.
        }
      }
      .navigationTitle(L.Navigation.settings)
    }
  }
}
