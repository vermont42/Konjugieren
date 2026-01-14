// Copyright © 2025 Josh Adams. All rights reserved.

import SwiftUI
import UIKit

let bodyFont = Font.system(size: 20.0)
let headingFont = Font.system(size: 24.0, weight: .bold)
let subheadingFont = Font.system(size: 18.0, weight: .bold)
let boldBodyFont = Font.system(size: 16.0, weight: .bold)

enum Fonts {
  static let heading = UIFont.systemFont(ofSize: 24.0, weight: .bold)
  static let subheading = UIFont.systemFont(ofSize: 18.0, weight: .bold)
  static let body = UIFont.systemFont(ofSize: 16.0)
  static let boldBody = UIFont.systemFont(ofSize: 16.0, weight: .bold)
}
