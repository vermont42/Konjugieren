# Claude Code Skill Recommendations for Konjugieren

Curated list of third-party Claude Code skills worth installing for Konjugieren-related work. Two community repositories carry essentially all of the iOS-relevant skills as of May 2026:

- [`vabole/apple-skills`](https://github.com/vabole/apple-skills) — ~35 skills, single-purpose each
- [`rshankras/claude-code-apple-skills`](https://github.com/rshankras/claude-code-apple-skills) — ~149 skills, organized into thematic sub-skills

Anthropic's official [`anthropics/skills`](https://github.com/anthropics/skills) repo currently ships no iOS-development skills.

---

## App Store Optimization (boost Konjugieren's ranking)

Two complementary options. Start with **vabole/apple-aso** as the dense single-shot reference; reach for the **rshankras/app-store** sub-skills when working on a specific surface (screenshots, paid Search Ads, review responses).

### vabole/apple-aso — recommended starting point

Lives at `vabole/apple-skills/skills/apple-aso/SKILL.md`. A single comprehensive SKILL.md covering:

- Apple's character limits with ranking weight per field (Title 30 / Subtitle 30 / Keywords 100 / Description 4,000)
- Keyword field rules: comma-separated with no spaces after commas, no plurals if singular exists, no duplicates from title/subtitle (Apple already indexes those), no generic terms ("app", "free", "best")
- Localization guidance — directly applicable to Konjugieren given its German/English content
- **Cross-localization** — Apple indexes keywords from multiple locales per territory. For Konjugieren this is high-leverage:
  - US territory indexes English (US) + Spanish (Mexico)
  - UK territory indexes English (UK) + English (US)
  - Effectively 200 characters of indexed keyword space in some markets
- Step-by-step optimization workflow (analyze → research → optimize → measure)

Notable rules with direct Konjugieren application:
- Include English keywords in `de-DE` locale (German users often search in English)
- Remove diacritics for keyword matching (users skip umlauts when typing)
- Add regional terms (e.g., German verb terminology variants across DE / AT / CH)

### rshankras/app-store — granular sub-skills

Lives at `rshankras/claude-code-apple-skills/skills/app-store/`. Seven sub-skills:

| Sub-skill | When to use |
|-----------|-------------|
| `keyword-optimizer` | Second-pass keyword work after the vabole reference |
| `app-description-writer` | Rewriting the long description for clarity and conversion |
| `screenshot-planner` | Planning the screenshot sequence for the App Store listing |
| `apple-search-ads` | Setting up paid Search Ads campaigns |
| `marketing-strategy` | Broader go-to-market thinking |
| `review-response-writer` | Drafting replies to App Store user reviews |
| `rejection-handler` | Responding to App Review rejections |

---

## Other skills worth installing given Konjugieren's feature set

### From vabole/apple-skills

- **widgetkit** — Konjugieren ships six widgets (home-screen verb-of-the-day and quiz, lock-screen Live Activities for quiz and game progress, two Control Center controls). Widget-specific Claude guidance is rare and worth having.
- **ios-liquid-glass** — Konjugieren's Foundation Models features require iOS 26, which puts the app on the Liquid Glass design surface. The skill covers the new visual APIs.
- **guide-swiftui-animations** — Relevant to the 80s-arcade game (fifteen mechanics: power-ups, shields, wave progression).
- **guide-swiftui-performance-audit** — A structured audit pass on a SwiftUI app of Konjugieren's size (14,900 LOC) usually surfaces real wins.
- **swift-testing** — Konjugieren has 118 Swift Testing tests; the skill helps keep patterns idiomatic as the suite grows.

### From rshankras/claude-code-apple-skills

- **apple-intelligence** / **foundation** — Foundation Models guidance, including the tool-calling pattern Konjugieren's conjugation tutor uses. Likely the single most relevant non-ASO skill on either repo.

---

## Installation

### vabole/apple-skills (Claude Code plugin marketplace)

```
claude plugin marketplace add vabole/apple-skills
claude plugin install apple-skills@apple-skills
```

This installs the entire pack (~35 skills); Claude auto-selects the right one based on context.

### Single-skill alternative

If you don't want the whole pack, copy a single SKILL.md into your local skills directory:

```
mkdir -p ~/.claude/skills/apple-aso
curl -L -o ~/.claude/skills/apple-aso/SKILL.md \
  https://raw.githubusercontent.com/vabole/apple-skills/main/skills/apple-aso/SKILL.md
```

### rshankras/claude-code-apple-skills

Check the repo's README for the current install command. If no plugin distribution is offered, clone and copy individual sub-skills into `~/.claude/skills/` as needed.

---

## Verifying skill activation

After installation, the skill should appear in Claude Code's skill list. To confirm a skill is active for a given conversation, ask Claude what skills it sees, or invoke the skill explicitly by topic ("help me optimize Konjugieren's App Store keywords") and watch for it to be loaded.
