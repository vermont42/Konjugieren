// Copyright © 2026 Josh Adams. All rights reserved.

/// Where a finite verb stands, which decides whether a separable prefix travels with it.
///
/// In a main clause the finite verb takes second place and leaves its separable prefix at the
/// end: ich stehe um sechs auf. In a subordinate clause the verb goes to the end and rejoins
/// its prefix: weil ich um sechs aufstehe. Only the four finite simple conjugationgroups
/// differ. A compound conjugationgroup is already written in main-clause order (bin
/// aufgestanden), a participle never splits, and the Imperativ has no subordinate clause, so
/// it always splits.
enum Clause: CaseIterable {
  case main
  case subordinate
}
