// Copyright © 2026 Josh Adams. All rights reserved.

@testable import Konjugieren
import Testing

@Suite("TimeFormatter")
struct TimeFormatterTests {
  @Test("Negative and zero values return \"0\"", arguments: zip(
    [-3600, -60, -1, 0],
    ["0", "0", "0", "0"]
  ))
  func negativeAndZero(input: Int, expected: String) {
    #expect(TimeFormatter.formatIntTime(input) == expected)
  }

  @Test("Seconds only (1–59)", arguments: zip(
    [1, 9, 10, 30, 45, 59],
    ["1", "9", "10", "30", "45", "59"]
  ))
  func secondsOnly(input: Int, expected: String) {
    #expect(TimeFormatter.formatIntTime(input) == expected)
  }

  @Test("Minutes and seconds (60–3599)", arguments: zip(
    [60, 61, 65, 90, 120, 125, 300, 530, 599, 600, 3540, 3599],
    ["1:00", "1:01", "1:05", "1:30", "2:00", "2:05", "5:00", "8:50", "9:59", "10:00", "59:00", "59:59"]
  ))
  func minutesAndSeconds(input: Int, expected: String) {
    #expect(TimeFormatter.formatIntTime(input) == expected)
  }

  @Test("Hours, minutes, and seconds (≥ 3600)", arguments: zip(
    [3600, 3660, 3661, 3723, 3900, 5400, 7200, 7260, 7325, 36000, 45296, 86400, 360000, 3599999],
    ["1:00:00", "1:01:00", "1:01:01", "1:02:03", "1:05:00", "1:30:00", "2:00:00", "2:01:00", "2:02:05", "10:00:00", "12:34:56", "24:00:00", "100:00:00", "999:59:59"]
  ))
  func hoursMinutesSeconds(input: Int, expected: String) {
    #expect(TimeFormatter.formatIntTime(input) == expected)
  }
}
