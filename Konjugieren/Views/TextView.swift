// Copyright © 2025 Josh Adams. All rights reserved.

import SwiftUI
import UIKit

struct TextView: UIViewRepresentable {
  let text: NSAttributedString
  let textViewDelegate = TextViewDelegate()

  func makeUIView(context: Context) -> UITextView {
    let textView = UITextView()
    textView.isEditable = false
    textView.contentOffset = .zero
    return textView
  }

  func updateUIView(_ uiView: UITextView, context: Context) {
    uiView.backgroundColor = UIColor(Color.customBackground)
    uiView.attributedText = text
    uiView.font = UIFont.preferredFont(forTextStyle: .body)
    uiView.contentOffset = .zero
    uiView.delegate = textViewDelegate
  }
}

class TextViewDelegate: NSObject, UITextViewDelegate {
  func textView(_ textView: UITextView, shouldInteractWith url: URL, in characterRange: NSRange) -> Bool {
    let cleansedURLString = firstLetterLowercasedString(parenlessString((url.absoluteString.removingPercentEncoding ?? "")))

    if let infoIndex = Info.headingToIndex(heading: cleansedURLString) {
      let infoDeepLinkURLString = URL.konjugierenURLPrefix + "\(URL.infoHost)/\(infoIndex)"
      URL(string: infoDeepLinkURLString).map {
        UIApplication.shared.open($0)
      }
      return false
    } else if Verb.verbs[cleansedURLString] != nil {
      let verbDeepLinkURLString = URL.konjugierenURLPrefix + "\(URL.verbHost)/\(parenlessString(firstLetterLowercasedString(url.absoluteString)))"
      URL(string: verbDeepLinkURLString).map {
        UIApplication.shared.open($0)
      }
      return false
    } else {
      return true
    }
  }

  private func parenlessString(_ input: String) -> String {
    input
      .replacingOccurrences(of: "(", with: "")
      .replacingOccurrences(of: ")", with: "")
  }

  private func firstLetterLowercasedString(_ input: String) -> String {
    input.prefix(1).lowercased() + input.dropFirst()
  }
}
