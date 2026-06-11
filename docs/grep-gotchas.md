# Grep gotcha: silent truncation on long-line files

**Tracking issue:** [anthropics/claude-code #56751](https://github.com/anthropics/claude-code/issues/56751). The report draft from which this was filed lives at `docs/bug-report-grep-silent-truncation.md`.

> **Resolved on this machine, 2026-06-11.** Root cause found: the Bash tool's `grep` was
> not `/usr/bin/grep` — Claude Code's shell snapshot shadowed `grep`/`find`/`rg` with
> functions that re-exec the Claude binary as embedded ugrep/bfs/ripgrep, and long matched
> lines were dropped in that pipeline (related: anthropics/claude-code#62642, #65166; full
> analysis in `~/Desktop/claude-code-bug-report.md`). After de-shadowing (real ripgrep
> installed; `--allowedTools Grep,Glob` launch flag; global PreToolUse hook running
> `unset -f grep find rg`), matched lines of 300/1,000/5,000 characters render intact.
> Everything below is retained as history and as the recovery recipe should the symptom
> ever recur.

## The failure mode

When the Bash tool runs `grep` on a file with long lines, matches whose displayed line exceeds an internal rendering threshold (~250 columns observed) are **silently** omitted from the rendered output. No truncation marker, no error — just nothing where a match should appear. `grep` itself found the match; the agent doesn't see it.

A separate, related symptom documented for some Anthropic tool surfaces is `[Omitted long matching line]` — labeled truncation, at least visible. The Bash-tool variant in this project's session evidence emitted no marker at all. Whichever surface you're invoking `grep` through, the workaround discipline below applies.

**Why it matters.** Silent failure mimics absence. An agent's mental model becomes "the match isn't there" when the truth is "the match is there and the rendering layer hid it." Downstream actions follow from a false negative with no signal prompting verification.

## The diagnostic

The most reliable signal is the asymmetry between `grep -c` and `grep -n` on the same file and pattern:

- `grep -c "<pattern>" <file>` returns the correct match count (output is short, so it renders).
- `grep -n "<pattern>" <file>` returns no displayed output (matched line is long, so it gets dropped).

If `-c` says ≥1 and `-n` says nothing, the rendering layer is hiding content. The match is real.

## Recovery paths

In priority order, lowest-cost first:

1. **Use a structurally-aware tool when the file format permits.** `jq` for `.json` / `.xcstrings`. `yq` for `.yaml`. `Read`-with-offset on a suspected line range for any file. The "Searching Within Localizable.xcstrings" subsection in CLAUDE.md is the canonical recipe for this project's most-affected file.

2. **If you must use `grep`,** verify with `grep -c` first to confirm whether matches exist, then extract just line numbers (`grep -n "<pattern>" <file> | cut -d: -f1`) — those are short and render reliably — and `Read` with offset to inspect the matched content. Do not try to read content directly out of `grep -n`'s rendered output on a long-line file.

3. **Never treat `grep -n`'s silence as evidence of absence.** When the match's presence matters to a downstream decision — e.g., verifying a string was successfully written by an `Edit`, or confirming a TODO has been removed — always confirm via `grep -c` or `Read`-with-offset before acting.

## Files in this project known to trigger this

- `Konjugieren/Assets/Localizable.xcstrings` — single-line JSON entries up to several KB. CLAUDE.md's "Searching Within Localizable.xcstrings" subsection has a file-specific recipe.
- Markdown files in `docs/` with long paragraphs — e.g., `docs/ui-audit-2.md`, and the bug-report drafts (`docs/bug-report-gitcommitsha.md`, `docs/bug-report-grep-silent-truncation.md`).
- External project documentation referenced during work — e.g., `ios-build-verify`'s SKILL.md when its tables or code-block paragraphs exceed the rendering threshold.

Rule of thumb: any file whose lines can exceed ~250 characters is at risk. When the file is structured (JSON, YAML, etc.), reach for the structural tool first regardless of line length — fewer surprises and more correctness.
