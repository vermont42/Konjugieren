# How to Regenerate line-counts.md

This document explains how to produce the line-count table at the project root (`line-counts.md`). All commands assume the working directory is `~/Desktop/workspace`.

## Prerequisites

All five app repositories must be cloned as siblings under `~/Desktop/workspace/`:

- `Immigration/`
- `RaceRunner/`
- `Conjugar/`
- `Conjuguer/`
- `Konjugieren/`

## Commands

### Immigration (Objective-C — count `.m` and `.h` files)

```bash
# Non-test lines
find Immigration/Immigration -name "*.m" -o -name "*.h" | grep -vi test | xargs wc -l | tail -1

# Test lines
find Immigration/Immigration -name "*.m" -o -name "*.h" | grep -i test | xargs wc -l | tail -1
```

### RaceRunner (Swift)

```bash
# Non-test lines
find RaceRunner -name "*.swift" -not -path "*Test*" | xargs wc -l | tail -1

# Test lines
find RaceRunner -name "*.swift" -path "*Test*" | xargs wc -l | tail -1
```

### Conjugar (Swift)

```bash
# Non-test lines
find Conjugar -name "*.swift" -not -path "*Test*" | xargs wc -l | tail -1

# Test lines
find Conjugar -name "*.swift" -path "*Test*" | xargs wc -l | tail -1
```

### Conjuguer (Swift)

```bash
# Non-test lines
find Conjuguer -name "*.swift" -not -path "*/Tests/*" -not -path "*Test*" | xargs wc -l | tail -1

# Test lines
find Conjuguer -name "*.swift" -path "*Test*" | xargs wc -l | tail -1
```

### Konjugieren (Swift)

```bash
# Non-test lines
find Konjugieren -name "*.swift" | xargs wc -l | tail -1

# Test lines
find Konjugieren/KonjugierenTests -name "*.swift" | xargs wc -l | tail -1
```

Note: Konjugieren's app target lives entirely under `Konjugieren/` (no test files in that directory), so no exclusion filter is needed for non-test lines.

## Table Format

Sort rows by release year (oldest first). Append the release year to each app name in parentheses. Include a **Total** row summing both columns.
