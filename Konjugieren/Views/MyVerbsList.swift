// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI

/// The starred verbs, then the recent ones not starred. Search ignores this choice, as it ignores
/// the sort order. A swipe forgets a verb's star and last open, so it leaves the list; a starred
/// verb asks first, since its star was put there on purpose. Neither a swipe nor Clear costs a
/// collection's progress, which counts verbs ever opened.
/// A List of its own, because only a List's rows can be swiped to delete.
struct MyVerbsList: View {
  let open: (VerbDestination) -> Void
  @State private var verbToUnstar: Verb?

  private var learnerVerbs: LearnerVerbStore { Current.learnerVerbs }

  var body: some View {
    let starred = learnerVerbs.starredVerbs
    let recent = learnerVerbs.recentUnstarredVerbs
    if starred.isEmpty, recent.isEmpty {
      ContentUnavailableView(L.MyVerbs.emptyTitle, systemImage: "star", description: Text(L.MyVerbs.emptyDescription))
        .frame(maxHeight: .infinity)
        .accessibilityIdentifier("my_verbs_empty")
    } else {
      List {
        if !starred.isEmpty {
          Section {
            ForEach(starred) { verb in
              row(verb)
                .swipeActions(edge: .trailing) {
                  // Not .destructive: that role removes the row at once, before the learner answers.
                  Button {
                    verbToUnstar = verb
                  } label: {
                    Label(L.MyVerbs.delete, systemImage: "star.slash")
                  }
                  .tint(.customRed)
                }
            }
          } header: {
            heading(L.MyVerbs.starred)
              .accessibilityIdentifier("my_verbs_starred_heading")
          }
        }
        if !recent.isEmpty {
          Section {
            ForEach(recent) { verb in
              row(verb)
                .swipeActions(edge: .trailing) {
                  Button(role: .destructive) {
                    withAnimation {
                      learnerVerbs.remove(verb)
                    }
                  } label: {
                    Label(L.MyVerbs.delete, systemImage: "trash")
                  }
                }
            }
          } header: {
            HStack(alignment: .firstTextBaseline) {
              heading(L.MyVerbs.recent)
              Spacer()
              Button(L.MyVerbs.clearRecent) {
                withAnimation {
                  learnerVerbs.clearRecents()
                }
              }
              .font(.caption)
              .buttonStyle(.borderless)
              .accessibilityIdentifier("my_verbs_clear_recent")
            }
          }
        }
      }
      .listStyle(.plain)
      .accessibilityIdentifier("my_verbs_list")
      .alert(
        L.MyVerbs.unstarTitle(verbToUnstar?.infinitiv.inUserRegion ?? ""),
        isPresented: Binding(get: { verbToUnstar != nil }, set: { if !$0 { verbToUnstar = nil } }),
        presenting: verbToUnstar
      ) { verb in
        Button(L.MyVerbs.unstarConfirm, role: .destructive) {
          withAnimation {
            learnerVerbs.remove(verb)
          }
        }
        Button(role: .cancel) {}
      } message: { _ in
        Text(L.MyVerbs.unstarMessage)
      }
    }
  }

  private func heading(_ text: String) -> some View {
    Text(text)
      .font(.caption.smallCaps())
      .foregroundStyle(.secondary)
      .accessibilityAddTraits(.isHeader)
  }

  private func row(_ verb: Verb) -> some View {
    VerbRowView(verb: verb) {
      open(VerbDestination(verb: verb, source: .myVerbs))
    }
    .listRowInsets(EdgeInsets())
  }
}
