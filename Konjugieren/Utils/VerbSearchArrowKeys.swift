// Copyright © 2026 Josh Adams. All rights reserved.

import SwiftUI
import UIKit

// Hack: the arrow keys reach a focused search field as cursor movement, which outranks
// .onKeyPress, .keyboardShortcut, and .commands alike. A UIKeyCommand that asks for priority
// over system behavior is the one way to see them. It must sit on a responder above the
// field, so it goes on the window's root view controller, and its action is defined on every
// view controller because SwiftUI's own controllers are the ones the chain reaches. It is
// installed only while the verb search field is focused, so no other text field loses its
// arrow keys.
//
// Each window has its own installation. With two windows on an iPad, a second window's field
// takes focus while the first is still the key window and still focused, so a key finds its
// installation through the window of the controller that received it.
enum VerbSearchArrowKeys {
  private struct Installation {
    weak var window: UIWindow?
    weak var host: UIViewController?
    let commands: [UIKeyCommand]
    let move: (Int) -> Void
  }

  private static var installations: [ObjectIdentifier: Installation] = [:]

  static func install(in window: UIWindow, move: @escaping (Int) -> Void) {
    uninstall(from: window)
    installations = installations.filter { $0.value.window != nil }
    guard let host = window.rootViewController else {
      return
    }
    let commands = makeCommands()
    commands.forEach(host.addKeyCommand)
    installations[ObjectIdentifier(window)] = Installation(window: window, host: host, commands: commands, move: move)
  }

  static func uninstall(from window: UIWindow) {
    guard let installation = installations.removeValue(forKey: ObjectIdentifier(window)) else {
      return
    }
    installation.commands.forEach { installation.host?.removeKeyCommand($0) }
  }

  static func handle(_ offset: Int, in window: UIWindow?) {
    guard let window, let installation = installations[ObjectIdentifier(window)], installation.window === window else {
      return
    }
    installation.move(offset)
  }

  private static func makeCommands() -> [UIKeyCommand] {
    let down = UIKeyCommand(input: UIKeyCommand.inputDownArrow, modifierFlags: [], action: #selector(UIViewController.verbSearchMoveDown(_:)))
    let up = UIKeyCommand(input: UIKeyCommand.inputUpArrow, modifierFlags: [], action: #selector(UIViewController.verbSearchMoveUp(_:)))
    for command in [down, up] {
      command.wantsPriorityOverSystemBehavior = true
    }
    return [down, up]
  }
}

extension UIViewController {
  @objc fileprivate func verbSearchMoveDown(_ sender: UIKeyCommand) {
    VerbSearchArrowKeys.handle(1, in: viewIfLoaded?.window)
  }

  @objc fileprivate func verbSearchMoveUp(_ sender: UIKeyCommand) {
    VerbSearchArrowKeys.handle(-1, in: viewIfLoaded?.window)
  }
}

extension View {
  /// Gives ↑ and ↓ to `move` while `isActive`, in the window that holds this view.
  func verbSearchArrowKeys(isActive: Bool, move: @escaping (Int) -> Void) -> some View {
    modifier(VerbSearchArrowKeysModifier(isActive: isActive, move: move))
  }
}

private struct VerbSearchArrowKeysModifier: ViewModifier {
  let isActive: Bool
  let move: (Int) -> Void
  @State private var window = WeakWindow()

  func body(content: Content) -> some View {
    content
      .background(WindowReader(window: window))
      .onChange(of: isActive) {
        guard let current = window.value else {
          return
        }
        if isActive {
          VerbSearchArrowKeys.install(in: current, move: move)
        } else {
          VerbSearchArrowKeys.uninstall(from: current)
        }
      }
  }
}

private final class WeakWindow {
  weak var value: UIWindow?
}

/// SwiftUI names no window to a view, so a UIKit view reports the one it joins.
private struct WindowReader: UIViewRepresentable {
  let window: WeakWindow

  func makeUIView(context: Context) -> ReportingView {
    let view = ReportingView()
    view.report = { [window] in
      window.value = $0
    }
    view.isUserInteractionEnabled = false
    return view
  }

  func updateUIView(_ uiView: ReportingView, context: Context) {}

  final class ReportingView: UIView {
    var report: ((UIWindow?) -> Void)?

    override func didMoveToWindow() {
      super.didMoveToWindow()
      report?(window)
    }
  }
}
