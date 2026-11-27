// Copyright © 2026 Josh Adams. All rights reserved.

@testable import Konjugieren
import Testing
import UIKit

@MainActor
@Suite(.serialized)
struct VerbSearchArrowKeysTests {
  private final class Moves {
    var a: [Int] = []
    var b: [Int] = []
  }

  private func makeWindow() throws -> UIWindow {
    let scene = try #require(UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first)
    let window = UIWindow(windowScene: scene)
    window.rootViewController = UIViewController()
    return window
  }

  private func arrowCommandCount(on window: UIWindow) -> Int {
    (window.rootViewController?.keyCommands ?? []).filter {
      $0.input == UIKeyCommand.inputDownArrow || $0.input == UIKeyCommand.inputUpArrow
    }.count
  }

  // The order two windows on an iPad produce: the second field takes focus while the first is
  // still focused, and the first never loses it.
  @Test func aSecondWindowGetsItsOwnKeysWhileTheFirstKeepsItsOwn() throws {
    let windowA = try makeWindow()
    let windowB = try makeWindow()
    let moves = Moves()
    VerbSearchArrowKeys.install(in: windowA) { moves.a.append($0) }
    VerbSearchArrowKeys.install(in: windowB) { moves.b.append($0) }
    defer {
      VerbSearchArrowKeys.uninstall(from: windowA)
      VerbSearchArrowKeys.uninstall(from: windowB)
    }

    #expect(arrowCommandCount(on: windowA) == 2)
    #expect(arrowCommandCount(on: windowB) == 2)

    VerbSearchArrowKeys.handle(1, in: windowB)
    VerbSearchArrowKeys.handle(1, in: windowA)
    VerbSearchArrowKeys.handle(-1, in: windowA)
    #expect(moves.a == [1, -1])
    #expect(moves.b == [1])
  }

  @Test func uninstallingOneWindowLeavesTheOther() throws {
    let windowA = try makeWindow()
    let windowB = try makeWindow()
    let moves = Moves()
    VerbSearchArrowKeys.install(in: windowA) { moves.a.append($0) }
    VerbSearchArrowKeys.install(in: windowB) { moves.b.append($0) }
    VerbSearchArrowKeys.uninstall(from: windowA)
    defer {
      VerbSearchArrowKeys.uninstall(from: windowB)
    }

    #expect(arrowCommandCount(on: windowA) == 0)
    #expect(arrowCommandCount(on: windowB) == 2)

    VerbSearchArrowKeys.handle(1, in: windowA)
    VerbSearchArrowKeys.handle(1, in: windowB)
    #expect(moves.a.isEmpty)
    #expect(moves.b == [1])
  }

  @Test func installingTwiceInOneWindowKeepsOneSetOfCommands() throws {
    let window = try makeWindow()
    let moves = Moves()
    VerbSearchArrowKeys.install(in: window) { moves.a.append($0) }
    VerbSearchArrowKeys.install(in: window) { moves.b.append($0) }
    defer {
      VerbSearchArrowKeys.uninstall(from: window)
    }

    #expect(arrowCommandCount(on: window) == 2)
    VerbSearchArrowKeys.handle(1, in: window)
    #expect(moves.a.isEmpty)
    #expect(moves.b == [1])
  }
}
