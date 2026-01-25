// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI

struct MainTabView: View {
  @State private var quiz = Quiz()

  var body: some View {
    TabView {
      VerbBrowseView()
        .tabItem {
          Image(systemName: "book.fill")
          Text(L.Navigation.verbs)
        }
        .tag(0)

      FamilyBrowseView()
        .tabItem {
          Image(systemName: "key.fill")
          Text(L.Navigation.families)
        }
        .tag(1)

      QuizView()
        .environment(quiz)
        .tabItem {
          Image(systemName: "pencil.circle.fill")
          Text(L.Navigation.quiz)
        }
        .tag(2)

      InfoBrowseView()
        .tabItem {
          Image(systemName: "questionmark.diamond.fill")
          Text(L.Navigation.info)
        }
        .tag(3)

      SettingsView()
        .tabItem {
          Image(systemName: "gearshape.2.fill")
          Text(L.Navigation.settings)
        }
        .tag(4)
    }
    .tint(.customRed)
  }
}
