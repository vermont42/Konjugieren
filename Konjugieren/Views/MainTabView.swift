// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI

struct MainTabView: View {
  @State private var quiz = Quiz()

  var body: some View {
    TabView {
      Tab(L.Navigation.verbs, systemImage: "book.fill") {
        VerbBrowseView()
      }

      Tab(L.Navigation.families, systemImage: "key.fill") {
        FamilyBrowseView()
      }

      Tab(L.Navigation.quiz, systemImage: "pencil.circle.fill") {
        QuizView()
          .environment(quiz)
      }

      Tab(L.Navigation.info, systemImage: "questionmark.diamond.fill") {
        InfoBrowseView()
      }

      Tab(L.Navigation.settings, systemImage: "gearshape.2.fill") {
        SettingsView()
      }
    }
    .tint(.customRed)
  }
}
