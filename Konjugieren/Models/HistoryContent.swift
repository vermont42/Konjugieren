// Copyright © 2025 Josh Adams. All rights reserved.

import Foundation

struct HistorySection: Identifiable {
  let id = UUID()
  let title: String
  let content: String
}

enum HistoryContent {
  static let sections: [HistorySection] = [
    HistorySection(
      title: L.History.stardustTitle,
      content: L.History.stardustContent
    ),
    HistorySection(
      title: L.History.longRoadTitle,
      content: L.History.longRoadContent
    ),
    HistorySection(
      title: L.History.yamnayaTitle,
      content: L.History.yamnayaContent
    ),
    HistorySection(
      title: L.History.pieVerbSystemTitle,
      content: L.History.pieVerbSystemContent
    ),
    HistorySection(
      title: L.History.ablautTitle,
      content: L.History.ablautContent
    ),
    HistorySection(
      title: L.History.migrationTitle,
      content: L.History.migrationContent
    ),
    HistorySection(
      title: L.History.teutoburgTitle,
      content: L.History.teutoburgContent
    ),
    HistorySection(
      title: L.History.germanicLifewaysTitle,
      content: L.History.germanicLifewaysContent
    ),
    HistorySection(
      title: L.History.germanicVerbSystemTitle,
      content: L.History.germanicVerbSystemContent
    ),
    HistorySection(
      title: L.History.weakVerbsTitle,
      content: L.History.weakVerbsContent
    ),
    HistorySection(
      title: L.History.oldHighGermanTitle,
      content: L.History.oldHighGermanContent
    ),
    HistorySection(
      title: L.History.perfectTenseTitle,
      content: L.History.perfectTenseContent
    ),
    HistorySection(
      title: L.History.futureTenseTitle,
      content: L.History.futureTenseContent
    ),
    HistorySection(
      title: L.History.subjunctiveTitle,
      content: L.History.subjunctiveContent
    ),
    HistorySection(
      title: L.History.verbSystemTodayTitle,
      content: L.History.verbSystemTodayContent
    )
  ]
}
