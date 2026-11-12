#!/usr/bin/env bash
# Copyright © 2026 Josh Adams. All rights reserved.
#
# Writes corpus/working/forms.json, the conjugation → infinitive map that the Python pipelines
# read (corpus/working/build_corpus_index.py, verbdata/authored/check_forms.py,
# verbdata/authored/build_review_shards.py), shaped
#
#   { "fängt": [{"contiguous": true, "verb": "fangen"},
#               {"contiguous": false, "particle": "an", "verb": "anfangen"}], … }
#
# It builds ConjugationMapTool, the macOS target that also writes the app's bundled
# ConjugationMap.lzfse, and runs it with --forms-json. One tool, one Conjugator, so the
# pipelines and the app's search cannot disagree about what a conjugation is.
#
# Run from anywhere:   scripts/write_forms_json.sh [output path]
# The default output is corpus/working/forms.json, which is gitignored.
#
# Until 2026-11-12 this file came from KonjugierenTests/Utils/CorpusFormsDumpTests, a test
# harness gated on TEST_RUNNER_KONJUGIEREN_FORMS_OUT. Its last output and this script's first
# were byte-identical. The harness had three ways to report success while writing nothing (two
# filter spellings and the TEST_RUNNER_ prefix); this script fails loudly instead.

set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
output="${1:-$repo/corpus/working/forms.json}"

# A bare `xcodebuild -target` build writes ./build into the repository unless SYMROOT and
# OBJROOT point elsewhere. A scratch directory under TMPDIR keeps the tree clean, and reusing it
# across runs keeps rebuilds incremental.
build_root="${TMPDIR:-/tmp}/ConjugationMapTool-build"

xcodebuild -project "$repo/Konjugieren.xcodeproj" -target ConjugationMapTool -configuration Release \
  SYMROOT="$build_root/Products" OBJROOT="$build_root/Intermediates" -quiet build

"$build_root/Products/Release/ConjugationMapTool" \
  --verbs "$repo/Konjugieren/Models/Verbs.xml" \
  --ablaut-groups "$repo/Konjugieren/Models/AblautGroups.xml" \
  --forms-json "$output"

echo "Wrote $output"
