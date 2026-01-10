// Copyright © 2026 Josh Adams. All rights reserved.

@testable import Konjugieren
import Testing

struct TimeFormatterTests {
  // MARK: - Edge Cases

  @Test func zero() {
    #expect(TimeFormatter.formatIntTime(0) == "0")
  }

  @Test func negativeValues() {
    #expect(TimeFormatter.formatIntTime(-1) == "0")
    #expect(TimeFormatter.formatIntTime(-60) == "0")
    #expect(TimeFormatter.formatIntTime(-3600) == "0")
  }

  // MARK: - Seconds Only (< 60)

  @Test func secondsOnly() {
    #expect(TimeFormatter.formatIntTime(1) == "1")
    #expect(TimeFormatter.formatIntTime(9) == "9")
    #expect(TimeFormatter.formatIntTime(10) == "10")
    #expect(TimeFormatter.formatIntTime(30) == "30")
    #expect(TimeFormatter.formatIntTime(45) == "45")
    #expect(TimeFormatter.formatIntTime(59) == "59")
  }

  // MARK: - Minutes and Seconds (60-3599)

  @Test func exactMinutes() {
    #expect(TimeFormatter.formatIntTime(60) == "1:00")
    #expect(TimeFormatter.formatIntTime(120) == "2:00")
    #expect(TimeFormatter.formatIntTime(300) == "5:00")
    #expect(TimeFormatter.formatIntTime(600) == "10:00")
    #expect(TimeFormatter.formatIntTime(3540) == "59:00")
  }

  @Test func minutesAndSeconds() {
    #expect(TimeFormatter.formatIntTime(61) == "1:01")
    #expect(TimeFormatter.formatIntTime(65) == "1:05")
    #expect(TimeFormatter.formatIntTime(90) == "1:30")
    #expect(TimeFormatter.formatIntTime(125) == "2:05")
    #expect(TimeFormatter.formatIntTime(530) == "8:50")
    #expect(TimeFormatter.formatIntTime(599) == "9:59")
    #expect(TimeFormatter.formatIntTime(3599) == "59:59")
  }

  // MARK: - Hours, Minutes, and Seconds (>= 3600)

  @Test func exactHours() {
    #expect(TimeFormatter.formatIntTime(3600) == "1:00:00")
    #expect(TimeFormatter.formatIntTime(7200) == "2:00:00")
    #expect(TimeFormatter.formatIntTime(36000) == "10:00:00")
  }

  @Test func hoursAndMinutes() {
    #expect(TimeFormatter.formatIntTime(3660) == "1:01:00")
    #expect(TimeFormatter.formatIntTime(3900) == "1:05:00")
    #expect(TimeFormatter.formatIntTime(5400) == "1:30:00")
    #expect(TimeFormatter.formatIntTime(7260) == "2:01:00")
  }

  @Test func hoursMinutesAndSeconds() {
    #expect(TimeFormatter.formatIntTime(3661) == "1:01:01")
    #expect(TimeFormatter.formatIntTime(3723) == "1:02:03")
    #expect(TimeFormatter.formatIntTime(7325) == "2:02:05")
    #expect(TimeFormatter.formatIntTime(45296) == "12:34:56")
  }

  @Test func boundaryValues() {
    // Just under 1 minute
    #expect(TimeFormatter.formatIntTime(59) == "59")
    // Exactly 1 minute
    #expect(TimeFormatter.formatIntTime(60) == "1:00")
    // Just under 1 hour
    #expect(TimeFormatter.formatIntTime(3599) == "59:59")
    // Exactly 1 hour
    #expect(TimeFormatter.formatIntTime(3600) == "1:00:00")
  }

  // MARK: - Large Values

  @Test func largeValues() {
    // 24 hours
    #expect(TimeFormatter.formatIntTime(86400) == "24:00:00")
    // 100 hours
    #expect(TimeFormatter.formatIntTime(360000) == "100:00:00")
    // 999 hours, 59 minutes, 59 seconds
    #expect(TimeFormatter.formatIntTime(3599999) == "999:59:59")
  }
}
