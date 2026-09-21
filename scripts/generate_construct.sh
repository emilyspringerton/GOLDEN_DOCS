#!/usr/bin/env bash
set -euo pipefail

# Generate a deterministic, plain-text GOLDEN_DOCS source construct from the repository's tracked
# files. The same git tree produces byte-for-byte identical output regardless of runner,
# timestamp, or filesystem ordering -- same convention as every other repo's own construct script
# in this monorepo (see the root CLAUDE.md's "Principle 21: CONSTRUCT Files"; modeled directly on
# IDUNA/scripts/generate_iduna_construct.sh).

export LC_ALL=C

OUT="${1:-GOLDEN_DOCS_CONSTRUCT.txt}"
MANIFEST="${2:-GOLDEN_DOCS_MANIFEST.txt}"

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$REPO_ROOT"

TREE_SHA="$(git rev-parse --verify HEAD^{tree} 2>/dev/null || printf 'unknown')"
TMP_FILES="$(mktemp)"
trap 'rm -f "$TMP_FILES"' EXIT

# Use tracked files only so untracked local artifacts cannot perturb the output. Excludes this
# repo's own generated construct/manifest outputs (this repo's real MANIFEST.md, the per-doc-set
# hash file described in README.md, is a different, unrelated artifact and stays included).
git ls-files -z \
  ':(exclude)GOLDEN_DOCS_CONSTRUCT*.txt' \
  ':(exclude)GOLDEN_DOCS_MANIFEST*.txt' \
  ':(exclude).git/**' \
  | sort -z > "$TMP_FILES"

{
  printf 'GOLDEN_DOCS MANIFEST\n'
  printf 'schema_version: 1\n'
  printf 'tree_sha: %s\n' "$TREE_SHA"
  printf 'source: git ls-files\n'
  printf '\n'
  printf 'files:\n'
} > "$MANIFEST"

COUNT=0
while IFS= read -r -d '' file; do
  [ -f "$file" ] || continue
  SHA="$(sha256sum "$file" | awk '{print $1}')"
  SIZE="$(wc -c < "$file" | tr -d ' ')"
  MODE="$(git ls-files -s -- "$file" | awk '{print $1}')"
  printf '%s  %s  %s  %s\n' "$SHA" "$SIZE" "$MODE" "$file" >> "$MANIFEST"
  COUNT=$((COUNT + 1))
done < "$TMP_FILES"

{
  printf '\n'
  printf 'total_files: %s\n' "$COUNT"
} >> "$MANIFEST"

{
  printf 'GOLDEN_DOCS CONSTRUCT\n'
  printf 'schema_version: 1\n'
  printf 'tree_sha: %s\n' "$TREE_SHA"
  printf 'source: git ls-files\n'
  printf 'total_files: %s\n' "$COUNT"
  printf '\n'
} > "$OUT"

while IFS= read -r -d '' file; do
  [ -f "$file" ] || continue
  SHA="$(sha256sum "$file" | awk '{print $1}')"
  SIZE="$(wc -c < "$file" | tr -d ' ')"
  MODE="$(git ls-files -s -- "$file" | awk '{print $1}')"

  {
    printf -- '--- FILE START: %s ---\n' "$file"
    printf 'sha256: %s\n' "$SHA"
    printf 'size_bytes: %s\n' "$SIZE"
    printf 'git_mode: %s\n' "$MODE"
  } >> "$OUT"

  if [ -s "$file" ] && ! grep -Iq . "$file"; then
    {
      printf 'encoding: base64\n'
      printf -- '--- CONTENT START ---\n'
      base64 "$file"
      printf '\n'
      printf -- '--- CONTENT END ---\n'
      printf -- '--- FILE END: %s ---\n' "$file"
      printf '\n'
    } >> "$OUT"
  else
    {
      printf 'encoding: text\n'
      printf -- '--- CONTENT START ---\n'
      cat "$file"
      # Normalize the delimiter onto a fresh line even if a source file lacks a
      # trailing newline. This keeps file boundaries unambiguous and stable.
      printf '\n'
      printf -- '--- CONTENT END ---\n'
      printf -- '--- FILE END: %s ---\n' "$file"
      printf '\n'
    } >> "$OUT"
  fi
done < "$TMP_FILES"
