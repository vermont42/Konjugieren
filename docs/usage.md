# Checking the five-hour usage window

A session can read its own usage while running, which is what makes a wave of subagents pace-able:
the orchestrator can stop at a clean checkpoint with headroom instead of being cut off mid-shard, or
tipping over into paid API pricing without meaning to.

## The command

```bash
claude -p "/usage" 2>/dev/null | grep -m1 'Current session'
# Current session: 42% used · resets Jul 26 at 11:10am (America/Los_Angeles)
```

Read the `Current session` line. The two weekly lines are a separate, slower pool. The panel's own
figures are approximate and cover only local sessions on this machine, so they miss other devices
and claude.ai. Treat them as a gauge, keep headroom, and remember that the panel reports what is
*consumed*, not whether the next batch *fits*.

## What it costs, and who pays

**The command itself uses zero tokens.** Measured 2026-07-26 on CLI 2.1.220 via
`claude -p "/usage" --output-format json`:

```
message types: ['system/init', 'assistant/None', 'result/success']
num_turns: 0
input=0  cache_write=0  cache_read=0  output=0
total_cost_usd: 0
duration: 1,023 ms
```

The `assistant` message is the panel synthesized by the CLI client, not a model response. Slash
commands are resolved inside the harness: the headless child boots, prints, and exits without ever
sending a request. The result is identical when launched from a directory with no `CLAUDE.md`, so
there is nothing to gain by running the probe from elsewhere.

**The cost is one turn of the *calling* session**, which re-reads its whole context in order to run
the Bash call and read the answer back. From a large orchestrator that came to roughly one point of
the five-hour window, about what a 25-verb authoring shard costs, fitted across six waves on
2026-07-25 (see [`prompts/example_generation.md`](../prompts/example_generation.md)). Josh accepts
that cost.

Two rules follow from the payer being the calling session rather than the child:

- **Poll every few shards, never in a loop.** The cost scales with the number of orchestrator turns
  spent probing, not with how much work each wave did, so wide waves amortize the probe and narrow
  ones do not. Expect the probe to grow more expensive as a run proceeds, since the orchestrator's
  context only grows.
- **Keep the `grep`.** The full panel is about 1,110 characters, and anything added to a
  long-running session's context is paid for again on every later turn. Ten unfiltered polls across
  a hundred later turns is not 2,800 tokens of context; it is 280,000.

### The attribution this corrects

`prompts/example_generation.md` and `prompts/uses_etymologies.md` both originally blamed the child:
one said every headless child pays ~23k cache-creation input regardless of how little it does, the
other called the call "about one request, negligible." They also contradicted each other, since the
first had measured the probe at a whole shard's worth of window. Both are now corrected in place.

The measured ≈1.0 point per probe was never in doubt, and one detail in that measurement is the
tell: the fitted cost held at ~1.0 across waves of 4, 6, 8, and 9 shards. A per-child cost would
have scaled with wave width. A per-orchestrator-turn cost does not.

## Related: what a headless child that *does* make a model turn costs

The zero above is specific to bare slash commands. A `claude -p` child given a real prompt pays full
startup, which matters because the authoring and mining pipelines spawn dozens of them. Measured the
same day with `Reply with exactly the word OK. Use no tools.` on `claude-opus-5[1m]`:

| Config | cache_write (novel prefix) | total input | cost |
|---|---|---|---|
| This repo (40.9 KB `CLAUDE.md`, cupertino MCP, project skills) | 24,254 | 39,544 | $0.2503 |
| Empty dir (only the 1.6 KB global `CLAUDE.md`) | 6,471 | 21,746 | $0.0730 |
| Empty dir plus `--safe-mode` | 2,705 | 20,152 | $0.0365 |

The ~15–17k of `cache_read` common to all three is the fixed harness system prompt and core tool
schemas, already warm; `cache_write` is the part each configuration adds.

Project context therefore adds about **17,800 tokens** and nearly doubles a child's startup, but it
does not dominate: the irreducible harness base is still the larger half. Launching from an empty
directory is roughly a 45% cut, not a 95% one. `CLAUDE.md` is only ~10k of that 17,800; the rest is
the cupertino MCP server's ten tool schemas, the skill roster, and the agent definitions, all of
which travel with the working directory too.

If a child genuinely needs none of that, `--safe-mode` drops `CLAUDE.md`, skills, plugins, hooks,
and MCP while leaving OAuth authentication intact. Do **not** reach for `--bare`, which looks
similar but forces `ANTHROPIC_API_KEY` authentication and would bill at API rates, which is the
outcome all of this pacing exists to avoid.
