# Bug report draft: Claude Code plugin update — stale `gitCommitSha`

**Issue title (use when filing):** `plugin update` does not refresh `gitCommitSha` in `installed_plugins.json`

**Channel:** <https://github.com/anthropics/claude-code/issues>

---

### What's Wrong?

After `claude plugin update`, the `version`, `installPath`, and `lastUpdated` fields in `~/.claude/plugins/installed_plugins.json` correctly reflect the new release, but `gitCommitSha` retains its `plugin install`-time value. The field becomes a false witness — tools or humans inspecting it to determine "what commit is currently extracted in the cache" are misled.

This completes the third leg of an architectural cluster: writes to `installed_plugins.json` are inconsistent across the plugin system's distinct entry points. See Cluster context under Additional Information for the cross-references and unifying diagnosis.

### What Should Happen?

After `claude plugin update`, all of `version`, `installPath`, **and** `gitCommitSha` should reflect the new release. Specifically, `gitCommitSha` should match the marketplaces clone's current HEAD — i.e., the result of `git -C ~/.claude/plugins/marketplaces/<marketplace> rev-parse HEAD`.

### Error Messages/Logs

No errors are emitted; this is a silent metadata-staleness bug. Using this field to capture the observable post-state instead:

```json
{
  "scope": "project",
  "projectPath": "/Users/josh/Desktop/workspace/Konjugieren",
  "installPath": "/Users/josh/.claude/plugins/cache/ios-build-verify/ios-build-verify/0.2.1",
  "version": "0.2.1",
  "installedAt": "2026-05-05T23:44:07.571Z",
  "lastUpdated": "2026-05-06T14:08:33.412Z",
  "gitCommitSha": "f1f79ca56d64a3502fb2986f9dc44c3ffbe09fef"
}
```

The `gitCommitSha` shown is the v0.2.0 commit. The marketplaces clone has since advanced to `52e4d6f` (v0.2.1, which is what's actually extracted in the cache at `installPath`).

### Steps to Reproduce

1. Maintain a plugin in a git repo. `claude plugin install <plugin>@<marketplace> --scope project` from a consumer project. Note `version` and `gitCommitSha` in `installed_plugins.json`.
2. Push commits to the plugin repo, bump `version` in `.claude-plugin/plugin.json`, push.
3. In the consumer project:

   ```
   claude plugin marketplace update <marketplace>
   claude plugin update <plugin>@<marketplace> --scope project
   ```

4. Re-inspect the plugin's entry in `installed_plugins.json`. Observe: `version`, `installPath`, `lastUpdated` advance correctly; `gitCommitSha` is unchanged from step 1.

### Additional Information

#### Cluster context

This report is the **third reported instance of one architectural pattern**: writes to `~/.claude/plugins/installed_plugins.json` are inconsistent across the plugin system's distinct entry points. Three distinct triggers each produce a different incomplete write:

| Trigger | Failure mode | Issue |
|---|---|---|
| Project-local marketplace startup-sync | `installed_plugins.json` not written at all (cache advances; metadata stays at install-time version) | [#43763](https://github.com/anthropics/claude-code/issues/43763) |
| Marketplace `"autoUpdate": true` runtime promotion | `installed_plugins.json` not written at all (UI/skills advance; bundled hooks pinned to old `installPath`) | [#52218](https://github.com/anthropics/claude-code/issues/52218) |
| Explicit `/plugin update` (this report) | `version`, `installPath`, `lastUpdated` all advance correctly; `gitCommitSha` retains install-time value | (this issue) |

**Unifying diagnosis:** the registry-write logic is not centralized. Each entry point either skips the write entirely or implements its own partial version of it. #43763's reporter pinpointed function `zyA` as only checking `scope` and `projectPath`; this report adds that even the path which *does* write most fields (explicit `/plugin update`) misses one of them. A clean fix consolidates the write into a single function called from all three entry points — resolving the cluster atomically rather than incrementally.

**Supporting evidence for fragmentation.** In a sample of 8 installed plugins on the reporting machine:

- 5 entries record `gitCommitSha`, 3 do not (`code-simplifier@claude-plugins-official`, `query@contextify`, `swift-lsp@claude-plugins-official`).
- 1 entry (`playground@claude-plugins-official`) records `version: "unknown"` (literal string).

These divergences are consistent with separate install pipelines emitting different field subsets — the same root cause as the three triggers above, observed in steady-state rather than in transition.

**Adjacent (cache-lifecycle) cluster, for triage context.** [#17361](https://github.com/anthropics/claude-code/issues/17361), [#14061](https://github.com/anthropics/claude-code/issues/14061), [#41922](https://github.com/anthropics/claude-code/issues/41922), and [#51536](https://github.com/anthropics/claude-code/issues/51536) all describe cache content/version/cleanup not converging with marketplace state. Distinct from the metadata-write cluster but reinforces the broader picture: the plugin system has multiple under-coordinated state-management paths.

#### Likely root cause (mechanism specific to this trigger)

The cache directory created by `plugin update` contains **no `.git` subdirectory** — only `plugin install`-created caches do. Update appears to extract via a non-git path (probably copy-from-working-tree of the marketplaces clone) rather than a git clone, so there's no natural git operation in the update flow that would produce a fresh SHA. None of the three referenced issues mentions this — it's a novel data point that explains *why* the explicit-update path drops `gitCommitSha` specifically while #43763 / #52218 drop all fields.

#### Suggested fix

**Architectural (resolves cluster #43763 + #52218 + this issue atomically).** Centralize `installed_plugins.json` writes into a single function. Call it from each of the four entry points that should be updating the registry:

- `/plugin install`
- `/plugin update`
- Project-local marketplace startup sync (#43763's path)
- `autoUpdate` runtime promotion (#52218's path)

The function reads `git -C ~/.claude/plugins/marketplaces/<marketplace> rev-parse HEAD` for `gitCommitSha`, derives `version` from the cache's extracted `plugin.json`, and updates `lastUpdated` from the wall clock.

**Localized (resolves only this issue).** At the end of `/plugin update`, append a single `git rev-parse HEAD` step that refreshes `gitCommitSha`. Doesn't address #43763 or #52218.

#### Impact

- Debugging "is my cache on the latest commit?" by reading `gitCommitSha` misleads any reader (human or AI agent).
- Telemetry / analytics that aggregate by `gitCommitSha` will undercount post-update versions.
- It's the only commit-level identifier in the install record; without correctness here, the only commit check requires independently comparing the cache against the marketplaces clone.

#### Environment

- Claude Code (CLI), macOS 15.x (Darwin 24.6.0)
- Plugin: `ios-build-verify@ios-build-verify` v0.2.0 → v0.2.1
- Date observed: 2026-05-06
- (If the form has separate widgets for Claude Code Version / Platform / Operating System / Terminal/Shell / Is-this-a-regression / Last-Working-Version, fill those at submission time — values not pre-known to this draft.)

---

### Addendum: auto-triage duplicate-flag response (2026-05-06)

After this report was filed as [#56740](https://github.com/anthropics/claude-code/issues/56740), the `github-actions[bot]` AI duplicate-detection workflow commented within minutes flagging three possible duplicates: #14061, #43763, #52218. Per the bot's own anti-auto-close mechanism ("add a comment or 👎 this comment"), the response below was posted with a 👎 on the bot's comment.

The flag is consistent with text-similarity matching on shared keywords (`installed_plugins.json`, `gitCommitSha`, `cache`, `plugin update`) but does not reflect the architectural distinction the body's "Cluster context" table draws between the three triggers. The comment surfaces that distinction explicitly so a human triager sees it without re-deriving:

> Thanks for surfacing the related issues. They are related but **not duplicates**. This issue is the third instance of an architectural cluster the body explicitly frames:
>
> - **#43763** — project-local marketplace startup-sync does not refresh `installed_plugins.json` at all (no fields update).
> - **#52218** — `"autoUpdate": true` runtime promotion does not refresh `installed_plugins.json` at all (UI/skills advance, bundled hooks pinned to old `installPath`).
> - **This issue (#56740)** — explicit `/plugin update` correctly advances `version`, `installPath`, and `lastUpdated`, but leaves `gitCommitSha` stale. Distinct trigger, distinct failure mode (partial write vs. no write).
>
> #14061 sits in an adjacent cluster about cache *content* staleness rather than metadata writes, and is cross-referenced in the body for triage context, not as a duplicate.
>
> The unifying architectural fix — centralize the `installed_plugins.json` write logic into a single function called from all four entry points (`/plugin install`, `/plugin update`, project-local marketplace startup-sync, and `autoUpdate` runtime promotion) — closes all three atomically. See the "Cluster context" table in the body.
>
> 👎 on the auto-close: this is a distinct instance of the cluster, framed and cross-referenced as such, not a duplicate of any of the three.

Lesson worth capturing for future bug reports against this repo: the AI auto-triage bot does text-similarity matching, not architectural reading. Cluster framing in the body protects against duplicate-of-X auto-closure but only if (a) the report names the cluster explicitly and (b) the reporter is ready to repeat the naming in a comment when the bot text-matches anyway. Both halves are needed; either alone is insufficient.
