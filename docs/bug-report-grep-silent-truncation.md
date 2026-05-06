# Bug report draft: Claude Code Bash tool — long-line `grep` matches silently disappear

**Issue title (use when filing):** Long-line `grep` matches silently disappear from Bash tool output

**Channel:** <https://github.com/anthropics/claude-code/issues>

---

### What's Wrong?

When the Bash tool runs `grep` on a file with very long lines, matches whose displayed line exceeds an internal output-rendering threshold are silently omitted from the rendered output. No truncation marker appears in the Bash tool result — compare [#26954](https://github.com/anthropics/claude-code/issues/26954)'s row-count truncation, which at least surfaces `+N lines (ctrl+o to expand)`. `grep` itself found the match; the agent simply does not see it.

The most diagnostic symptom is the asymmetry between `grep -c` and `grep -n` on the same file and pattern: `-c` returns the correct match count (because the count's output is short), while `-n` returns nothing (because the matched line is long enough to be dropped). Same shell, same file, same pattern, same session — only the output shape differs, and one shape gets rendered while the other vanishes.

Silent truncation is the worst possible failure mode for an agent's epistemic state. When `grep -n` returns nothing, the agent's working assumption is "no match." Downstream decisions follow from a false negative, with nothing in the tool result to prompt verification.

### What Should Happen?

Either of the following would resolve the agent-trust issue:

1. **Emit an explicit truncation marker** when a line is dropped due to rendering-length thresholds, parallel to the existing row-count `+N lines (ctrl+o to expand)` indicator. The agent gets a clear signal to retry with a structurally-aware tool.
2. **Route `grep` invocations through tools that don't have this failure mode** — the dedicated `Grep` tool (which is also affected per project documentation, but at least labels truncation; see Cluster context below), or structurally-aware tools dispatched by file extension (`jq` for `.json` / `.xcstrings`, `yq` for `.yaml`, `ast-grep` for source code).

Either resolution path would address the silent-failure character. (1) is the smaller change; (2) is the broader architectural shift adjacent to [#19649](https://github.com/anthropics/claude-code/issues/19649).

### Error Messages/Logs

No error is emitted; this is a silent-failure bug, and the absence of error is the bug. Using this field to capture the diagnostic asymmetry from a real session (Claude Code 2.1.131, macOS Darwin 24.6.0, 2026-05-06):

```
$ grep -c '<scripts>/' /path/to/SKILL.md
43

$ grep -n '<scripts>/' /path/to/SKILL.md | head -5
(no output displayed)
```

Same shell, same file, same pattern. The match count is correct; the matched lines themselves are dropped from the rendered output. Each row of the affected file's tables exceeds ~250 columns.

A second repro from the same session, searching a 1,700-character Markdown paragraph for a 5-digit string:

```
$ grep -n "56740" /path/to/blog-post.md
(no output displayed, despite the string being present at line 187)
```

`Read`-with-offset to inspect line 187 directly confirmed the match exists in the file. The matching paragraph is one line in the Markdown source.

### Steps to Reproduce

1. Open a file containing at least one line longer than ~250 characters. Common examples: Markdown files with long paragraphs, JSON catalogs (e.g., `.xcstrings`, minified `.json`), HTML with inlined styles, single-line YAML values.
2. Pick a unique short string that appears within one of the long lines.
3. In the Bash tool, run:

   ```
   grep -c "<unique-string>" <file>
   ```

   Observe: returns the correct match count (e.g., `1`).

4. In the Bash tool, run:

   ```
   grep -n "<unique-string>" <file>
   ```

   Observe: returns no displayed output, despite the count above confirming a match exists.

5. Confirm the match is real by `Read`-ing the relevant line range directly. The match is there; only the rendering layer is dropping it.

### Additional Information

#### Cluster context

This bug is one axis of a broader pattern: **agent tools silently truncate content without explicit markers**. Three related instances:

| Surface | Failure mode | Marker visible? | Issue |
|---|---|---|---|
| Bash tool output, row count | `+N lines (ctrl+o to expand)` shown, but `ctrl+o` does not actually expand | Partial (count shown, expand broken) | [#26954](https://github.com/anthropics/claude-code/issues/26954) |
| Bash tool output, line length (this report) | Long matched lines dropped from rendered output | None | (this issue) |
| `Read` tool, file size in sub-agents | Files truncated past read limit; sub-agent reports based on partial input as authoritative | None visible to sub-agent | [#53994](https://github.com/anthropics/claude-code/issues/53994) |

**Adjacent issues worth cross-referencing.** Two existing issues address the model-side preference for using tools other than Bash-`grep`:

- [#19649](https://github.com/anthropics/claude-code/issues/19649) — "Model frequently uses Bash tools (sed/grep/etc) when use-case is well aligned to other builtin tools (Read/Grep/etc)" — argues that the model should prefer the dedicated `Grep` tool over invoking `grep` via Bash.
- [#54800](https://github.com/anthropics/claude-code/issues/54800) — "Make tools like ripgrep and fdfind a first class citizen" — argues that when Bash is the path, the model should prefer `rg` and `fd` over POSIX `grep` and `find`.

Both are **complementary** to this report rather than duplicate: they address tool selection, while this report addresses what happens when the selected tool's output gets truncated at the rendering layer. Adopting either preference alone would not by itself eliminate this bug. Both the dedicated `Grep` tool (which consumer-project `CLAUDE.md` files document as emitting `[Omitted long matching line]` — a labeled truncation, at least visible to the agent) and `rg --max-columns 0` would presumably hit the same Bash-tool rendering threshold when output lines are very long, unless the rendering threshold itself is fixed. This report's fix #1 (truncation marker) addresses the rendering layer directly and is orthogonal to either tool-selection preference; the cleanest outcome would be to ship #54800's tool-selection change *and* this report's marker fix together.

**Unifying diagnosis.** Render-layer truncation in agent tooling needs to be either explicitly marked or eliminated. Truncation that mimics absence (no error, no marker, no count discrepancy in the obvious place) is the worst kind of failure for an agent's epistemic state, because the agent's mental model becomes "the data isn't there" when in fact "the data is there and the rendering layer hid it." A marker — even just `[N matches in this file have been truncated due to line length]` — would convert silent failure into actionable retry.

#### Likely root cause (mechanism specific to this trigger)

The asymmetry between `grep -c` (returns correct count) and `grep -n` (returns no displayed lines) on the same file/pattern strongly suggests the truncation lives at the **Bash tool's output-rendering layer**, not in `grep`'s matching logic or in the OS pipe buffer. `grep` is finding the matches and emitting them on stdout; the rendering layer is dropping the long lines before they reach the agent's view.

The threshold appears to be approximately 250–300 columns based on the repros observed, but I don't have privileged access to the rendering source to confirm exact values. The trigger is per-line length, not total output size — the second repro above had only one matching line in the file, far below any plausible byte-count truncation threshold.

#### Suggested fix

In priority order, lowest-cost first:

1. **Emit a truncation marker** when a Bash tool output line exceeds the rendering threshold and gets dropped. Parallel to the existing row-count `+N lines (ctrl+o to expand)` indicator, but for line-length truncation. Smallest change to the rendering layer; biggest agent-trust win because silent failure becomes signaled failure.
2. **Route `grep` invocations through structurally-aware tools by file extension.** When the file is `.json` / `.xcstrings`, dispatch to `jq`. When `.yaml`, `yq`. When source code, `ast-grep`. Avoids the long-line problem entirely on files where structure is what's actually being searched, and incidentally addresses [#19649](https://github.com/anthropics/claude-code/issues/19649)'s discipline issue at the tool layer rather than the model layer.
3. **Adopt ripgrep semantics by default for Bash-`grep`-shaped invocations.** This overlaps with the broader feature request in [#54800](https://github.com/anthropics/claude-code/issues/54800) ("make tools like ripgrep and fdfind a first class citizen"). Note that `rg --max-columns 0` only avoids the silent-drop pattern if the Bash tool's rendering threshold is also raised or eliminated. Without #1's marker fix in place, even ripgrep's output would be rendered-truncated identically when matched lines are long enough. So #1 and #3 are best implemented together, not as substitutes — and #54800's tool-selection change is best landed alongside both.

#### Impact

- Agents with a "grep returned no match" mental model take downstream actions based on false negatives. Concrete example from the originating session: a verification grep for a string just written to a file returned no output, prompting initial suspicion that the edit had not landed. Only `Read`-with-offset confirmed otherwise. A less-experienced agent or this one in a more rotted context might have re-applied the edit, producing duplicate or corrupt state.
- The failure is invisible. Nothing flags the truncation, so agents do not know to retry with an alternative tool. The known workaround — `grep -c` to confirm match count, then `Read`-with-offset for content — requires the agent to suspect the bug exists. `CLAUDE.md` prescriptions of this workaround exist in some projects but are not propagated as default agent discipline.
- The asymmetry between `grep -c` (works) and `grep -n` (fails) is itself a teachable diagnostic — but only if it surfaces, which requires the agent to check both before trusting either. Most agents will not check both.

#### Environment

- Claude Code (CLI) version 2.1.131
- macOS 15.x (Darwin 24.6.0)
- Shell: bash via `/bin/bash`
- Files where reproduced (all in this same session): a SwiftUI project's `SKILL.md` (with markdown tables and inline-code paragraphs), a Jekyll blog post (with long-paragraph prose), and JSON catalogs (`Localizable.xcstrings` with single-line entries exceeding 2KB).
- Date observed: 2026-05-06
