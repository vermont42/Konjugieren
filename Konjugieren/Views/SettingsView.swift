// Copyright © 2025 Josh Adams. All rights reserved.

import SwiftUI

struct SettingsView: View {
  var body: some View {
    @Bindable var settings = Current.settings

    ZStack {
      Color.customBackground
        .ignoresSafeArea()

      VStack(alignment: .leading) {
        ScrollView(.vertical) {
          Spacer(minLength: Layout.tripleDefaultSpacing)

          Text(L.Settings.conjugationgroupLangHeading)
            .settingsSubheadingLabel()

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
            .settingsSubheadingLabel()

          Picker("", selection: $settings.thirdPersonPronounGender) {
            ForEach(ThirdPersonPronounGender.allCases, id: \.self) { thirdPersonPronounGender in
              Text(thirdPersonPronounGender.localizedThirdPersonPronounGender).tag(thirdPersonPronounGender)
            }
          }
          .segmentedPicker()

          Text(L.Settings.thirdPersonPronounGenderDescription)
            .settingsLabel()

          Spacer(minLength: Layout.tripleDefaultSpacing)
        }
      }
      .onAppear {
        // TODO: Fire analytic and fetch ratings.
      }
    }
  }
}
