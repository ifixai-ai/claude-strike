#!/usr/bin/env bash
set -euo pipefail

MODE="global"
if [[ "${1:-}" == "--project" ]]; then
  MODE="project"
elif [[ -n "${1:-}" ]]; then
  echo "Usage: $0 [--project]" >&2
  exit 2
fi

if [[ "$MODE" == "global" ]]; then
  DEST_CLAUDE_DIR="$HOME/.claude"
else
  DEST_CLAUDE_DIR="$PWD/.claude"
fi

MANIFEST="$DEST_CLAUDE_DIR/.claude-harness-manifest"

if [[ ! -f "$MANIFEST" ]]; then
  echo "no manifest found at $MANIFEST — nothing to uninstall" >&2
  exit 0
fi

removed=0
while IFS= read -r path; do
  [[ -z "$path" ]] && continue
  if [[ -f "$path" ]]; then
    rm -f "$path"
    removed=$((removed + 1))
  fi
done < "$MANIFEST"

for sub in agents rules; do
  target="$DEST_CLAUDE_DIR/$sub"
  [[ -d "$target" ]] && find "$target" -type d -empty -delete 2>/dev/null || true
done

rm -f "$MANIFEST"

echo "claude-harness uninstall complete (${MODE} mode)"
echo "  files removed: $removed"
echo "  root:          $DEST_CLAUDE_DIR"
