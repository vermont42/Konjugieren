// Copyright © 2026 Josh Adams. All rights reserved.

/// One sense of a verb, together with everything that inflects with that sense.
///
/// German verbs frequently differ across readings in more than the auxiliary: *schmelzen*
/// takes sein when something becomes liquid and haben when someone makes it so; *hängen*
/// additionally inflects strong in the first reading and weak in the second; *übersetzen*
/// differs in prefix separability. The unit that varies is therefore the reading, not the
/// auxiliary, and a verb owns an ordered list of them. See `prompts/dual_auxiliary.md`.
///
/// Variation by *where the speaker lives* is deliberately not modeled here; two readings
/// differing only in an auxiliary would tell every user both forms are available to them
/// personally, which is false for any one speaker. That is `auxiliaryIsRegional`.
struct Reading: Hashable {
  /// Marker-free, and always equal to the parent verb's key. A reading may respell `in`
  /// to change prefix separability or the ablaut region, but never to name a different verb.
  let infinitiv: String
  let translation: String
  let family: Family
  let auxiliary: Auxiliary

  /// Ordered outermost to innermost: *an+ge\*hören* is `[.separable("an"), .inseparable("ge")]`.
  let prefixes: [Prefix]

  /// True for the handful of verbs whose Perfekt auxiliary depends on where the speaker
  /// lives rather than on what the verb means: stehen, sitzen, liegen take haben in the
  /// northern standard and sein in Austria and Switzerland.
  let auxiliaryIsRegional: Bool

  var stamm: String {
    if infinitiv.hasSuffix("en") {
      return String(infinitiv.dropLast(2))
    } else {
      return String(infinitiv.dropLast())
    }
  }

  var ablautGroup: String? {
    switch family {
    case .strong(let group, _, _), .mixed(let group, _, _):
      return group
    case .weak, .ieren:
      return nil
    }
  }

  /// The outermost prefix, which is the one the browse screens group and label by.
  var prefix: Prefix {
    prefixes.first ?? .none
  }

  func regionalAuxiliary(in region: Region) -> Auxiliary {
    auxiliaryIsRegional ? region.regionalAuxiliary : auxiliary
  }
}

extension [Prefix] {
  /// The characters every prefix contributes to the front of the stem, so that the bare
  /// base can be recovered by dropping them.
  var totalLength: Int {
    reduce(0) { total, prefix in
      switch prefix {
      case .separable(let value), .inseparable(let value):
        return total + value.count
      case .none:
        return total
      }
    }
  }

  /// The leading run of separable prefixes, which is what detaches in the Imperativ:
  /// *nach+voll\*ziehen* yields "nach", giving *vollzieht nach*. A separable prefix sitting
  /// inside an inseparable one does not detach, so the run stops at the first inseparable.
  var separableRun: String {
    var run = ""
    for prefix in self {
      guard case .separable(let value) = prefix else {
        break
      }
      run += value
    }
    return run
  }

  /// Whether the Perfektpartizip infixes *ge-*.
  ///
  /// The rule is positional rather than a count: *ge-* sits immediately before the base
  /// stem, and appears only when the prefix closest to that stem is separable or absent.
  /// So *ab+bauen* keeps it (*abgebaut*) and *an+ge\*hören* suppresses it (*angehört*),
  /// even though both begin with a separable prefix.
  var takesGe: Bool {
    // Unwrapped before the switch because Prefix has a case named `none`, which a switch
    // over the Optional `last` would silently bind to Optional.none instead.
    guard let innermost = last else {
      return true
    }
    switch innermost {
    case .inseparable:
      return false
    case .separable, .none:
      return true
    }
  }
}
