// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI

/// Command-F for iPad and Mac keyboards. The arrow keys through results are in
/// `VerbSearchArrowKeys`, because a menu command cannot take an arrow key from a text field.
struct VerbSearchCommands: Commands {
  var body: some Commands {
    CommandMenu(L.Navigation.verbs) {
      Button(L.VerbBrowse.findVerb) {
        Current.focusVerbSearch()
      }
      .keyboardShortcut("f")
    }
  }
}
