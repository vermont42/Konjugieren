// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI
import WidgetKit

struct VerbDesTagesEntry: TimelineEntry {
  let date: Date
  let snapshot: WidgetSnapshot
}

struct VerbDesTagesProvider: TimelineProvider {
  func placeholder(in context: Context) -> VerbDesTagesEntry {
    VerbDesTagesEntry(date: Date(), snapshot: SnapshotReader.placeholder)
  }

  func getSnapshot(in context: Context, completion: @escaping (VerbDesTagesEntry) -> Void) {
    let now = Date()
    let snapshot = SnapshotReader.currentSnapshot(now: now, pageOffset: pageOffset)
    completion(VerbDesTagesEntry(date: now, snapshot: snapshot))
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<VerbDesTagesEntry>) -> Void) {
    let entries = SnapshotReader.dailyEntries(now: Date(), pageOffset: pageOffset)
      .map { VerbDesTagesEntry(date: $0.date, snapshot: $0.snapshot) }
    let refreshDate = (entries.last?.date ?? Date()).addingTimeInterval(86400)
    completion(Timeline(entries: entries, policy: .after(refreshDate)))
  }

  private var pageOffset: Int {
    WidgetConstants.sharedDefaults?.integer(forKey: WidgetConstants.debugOffsetKey) ?? 0
  }
}

struct VerbDesTagesWidget: Widget {
  let kind = "VerbDesTagesWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: VerbDesTagesProvider()) { entry in
      VerbDesTagesWidgetEntryView(entry: entry)
        .containerBackground(.fill.tertiary, for: .widget)
    }
    .configurationDisplayName(WidgetL.VerbDesTages.configDisplayName)
    .description(WidgetL.VerbDesTages.configDescription)
    .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .accessoryRectangular, .accessoryInline])
  }
}

struct VerbDesTagesWidgetEntryView: View {
  var entry: VerbDesTagesEntry
  @Environment(\.widgetFamily) var family

  var body: some View {
    switch family {
    case .systemSmall:
      SmallWidgetView(snapshot: entry.snapshot)
    case .systemMedium:
      MediumWidgetView(snapshot: entry.snapshot)
    case .systemLarge:
      LargeWidgetView(snapshot: entry.snapshot)
    case .accessoryRectangular:
      AccessoryRectangularView(snapshot: entry.snapshot)
    case .accessoryInline:
      AccessoryInlineView(snapshot: entry.snapshot)
    default:
      SmallWidgetView(snapshot: entry.snapshot)
    }
  }
}
