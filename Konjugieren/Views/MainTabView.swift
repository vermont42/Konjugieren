// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI

struct MainTabView: View {
  @Bindable var world = Current
  @State private var quiz = Quiz()

  var body: some View {
    TabView(selection: $world.selectedTab) {
      Tab(L.Navigation.verbs, systemImage: "book.fill", value: .verbs) {
        VerbBrowseView()
      }

      Tab(L.Navigation.families, systemImage: "figure.and.child.holdinghands", value: .families) {
        FamilyBrowseView()
      }

      Tab(L.Navigation.quiz, systemImage: "pencil.circle.fill", value: .quiz) {
        QuizView()
          .environment(quiz)
      }

      Tab(L.Navigation.info, systemImage: "questionmark.diamond.fill", value: .info) {
        InfoBrowseView()
      }

      Tab(L.Navigation.settings, systemImage: "gearshape.2.fill", value: .settings) {
        SettingsView()
      }
    }
    .tint(.customRed)
  }
}
