// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI

/// The segmented choice between frequency and alphabetical order that heads every list of verbs
/// but the Verbs tab's, whose picker also offers My Verbs.
struct SortOrderPicker: View {
  @Binding var selection: SortOrder

  var body: some View {
    Picker(L.VerbBrowse.sortOrder, selection: $selection) {
      ForEach(SortOrder.allCases, id: \.self) { order in
        Text(order.displayName)
          .tag(order)
      }
    }
    .pickerStyle(.segmented)
    .sensoryFeedback(.selection, trigger: selection)
  }
}
