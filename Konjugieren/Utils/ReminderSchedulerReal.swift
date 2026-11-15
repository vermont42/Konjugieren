// Copyright © 2026 Josh Adams. All rights reserved.

import Foundation
import UserNotifications

/// Schedules the daily reminders as local notifications. Each carries the deeplink that starts a
/// daily session, which `ReminderNotificationDelegate` opens when the reminder is tapped.
final class ReminderSchedulerReal: ReminderScheduler {
  nonisolated static let deeplinkKey = "deeplink"

  func requestAuthorization() async -> Bool {
    (try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])) ?? false
  }

  func isAuthorized() async -> Bool {
    let settings = await UNUserNotificationCenter.current().notificationSettings()
    switch settings.authorizationStatus {
    case .authorized, .ephemeral, .provisional:
      return true
    case .denied, .notDetermined:
      return false
    @unknown default:
      return false
    }
  }

  func schedule(_ reminders: [ScheduledReminder]) {
    let requests = reminders.map { reminder in
      let content = UNMutableNotificationContent()
      content.title = reminder.title
      content.body = reminder.body
      content.sound = .default
      content.userInfo = [Self.deeplinkKey: URL.dailySessionDeeplink(source: .reminder)?.absoluteString ?? ""]
      let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminder.date)
      return UNNotificationRequest(
        identifier: reminder.identifier,
        content: content,
        trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
      )
    }
    Task {
      let center = UNUserNotificationCenter.current()
      let pending = await center.pendingNotificationRequests()
        .map(\.identifier)
        .filter { $0.hasPrefix(DailyReminderPlan.identifierPrefix) }
      center.removePendingNotificationRequests(withIdentifiers: pending)
      for request in requests {
        try? await center.add(request)
      }
    }
  }
}

/// Opens a tapped reminder's deeplink. A reminder due while the app is open shows nothing, since
/// the hub already offers the session.
final class ReminderNotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
  static let shared = ReminderNotificationDelegate()

  nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
    guard let link = response.notification.request.content.userInfo[ReminderSchedulerReal.deeplinkKey] as? String,
          let url = URL(string: link) else {
      return
    }
    await MainActor.run {
      Current.handleURL(url)
    }
  }

  nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
    []
  }
}
