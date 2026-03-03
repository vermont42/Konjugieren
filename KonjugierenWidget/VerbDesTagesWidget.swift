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
    let snapshot = SnapshotReader.read() ?? SnapshotReader.placeholder
    completion(VerbDesTagesEntry(date: Date(), snapshot: snapshot))
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<VerbDesTagesEntry>) -> Void) {
    let snapshot = SnapshotReader.read() ?? SnapshotReader.placeholder
    let entry = VerbDesTagesEntry(date: Date(), snapshot: snapshot)

    let nextMidnight = Calendar.current.startOfDay(for: Date()).addingTimeInterval(86400)
    let timeline = Timeline(entries: [entry], policy: .after(nextMidnight))
    completion(timeline)
  }
}

struct VerbDesTagesWidget: Widget {
  let kind = "VerbDesTagesWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: VerbDesTagesProvider()) { entry in
      VerbDesTagesWidgetEntryView(entry: entry)
        .containerBackground(.fill.tertiary, for: .widget)
    }
    .configurationDisplayName("Verb des Tages")
    .description("A daily German verb with conjugations.")
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
