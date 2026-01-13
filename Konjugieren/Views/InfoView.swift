// Copyright © 2025 Josh Adams. All rights reserved.

import SwiftUI

struct InfoView: View {
  let info: Info
  let shouldShowInfoHeading: Bool

  init(info: Info, shouldShowInfoHeading: Bool = false) {
    self.info = info
    self.shouldShowInfoHeading = shouldShowInfoHeading
  }

  var body: some View {
    ZStack {
      Color.customBackground
        .ignoresSafeArea()

      VStack {
        if let imageInfo = info.imageInfo {
          Image(imageInfo.filename)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 270)
            .accessibilityLabel(imageInfo.accessibilityLabel)
        }

        if shouldShowInfoHeading {
          Text(info.heading)
            .headingLabel()
          Spacer()
        }

        TextView(text: info.attributedText)
          .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
          .navigationTitle(info.heading)
      }
      .padding(.leading, Layout.doubleDefaultSpacing)
      .padding(.trailing, Layout.doubleDefaultSpacing)
      .onAppear {
//        Current.analytics.recordViewAppeared("\(InfoView.self)")
      }
    }
  }
}
