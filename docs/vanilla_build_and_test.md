# Vanilla Build and Test

By default, Konjugieren's `CLAUDE.md` directs Claude Code to build and run tests through the [`ios-build-verify`](https://github.com/vermont42/ios-build-verify) plugin, which wraps `xcodebuild` with `xcbeautify` for concise output and adds an `AXe`-driven verification surface (launch the app, tap by accessibility identifier, screenshot, audit views).

Developers who prefer not to take on the `ios-build-verify` dependency can swap the commands below into `CLAUDE.md` in place of the current `ios-build-verify` reference. They reproduce the build-and-test half of the plugin using stock `xcodebuild`. The verification half — interactive simulator operations — has no direct stock equivalent and would simply be unavailable.

```bash
# Build the app
xcodebuild -project Konjugieren.xcodeproj -scheme Konjugieren -destination 'platform=iOS Simulator,name=iPhone 17' build

# Run all tests (disable parallel testing to avoid simulator flakiness)
xcodebuild -project Konjugieren.xcodeproj -scheme Konjugieren -destination 'platform=iOS Simulator,name=iPhone 17' -parallel-testing-enabled NO test

# Run a single test suite
xcodebuild -project Konjugieren.xcodeproj -scheme Konjugieren -destination 'platform=iOS Simulator,name=iPhone 17' -parallel-testing-enabled NO test -only-testing:KonjugierenTests/ConjugatorTests

# Run a single test method
xcodebuild -project Konjugieren.xcodeproj -scheme Konjugieren -destination 'platform=iOS Simulator,name=iPhone 17' -parallel-testing-enabled NO test -only-testing:KonjugierenTests/ConjugatorTests/perfektpartizip()
```

> **`-only-testing:` format for Swift Testing:** The path is `Target/Suite/method()`. Do not include filesystem subdirectories (`Models/`, `Utils/`), and always append `()` to method names. Omitting either causes xcodebuild to silently run zero tests.
