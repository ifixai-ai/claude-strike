#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SRC_CLAUDE_DIR="$SCRIPT_DIR/.claude"
SRC_CLAUDE_MD="$SCRIPT_DIR/CLAUDE.md"

MODE="global"
DRY_RUN=0
FORCE=0

usage() {
  cat >&2 <<EOF
Usage: $0 [--project] [--dry-run] [--force]

  --project   Install into the current repo's ./.claude/ instead of ~/.claude/
  --dry-run   Print every action without touching the filesystem
  --force     Overwrite CLAUDE.md at the destination even if it already differs
EOF
  exit 2
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project) MODE="project" ;;
    --dry-run) DRY_RUN=1 ;;
    --force)   FORCE=1 ;;
    -h|--help) usage ;;
    *)         echo "unknown option: $1" >&2; usage ;;
  esac
  shift
done

if [[ "$MODE" == "global" ]]; then
  DEST_CLAUDE_DIR="$HOME/.claude"
  CLAUDE_MD_DEST="$HOME/.claude/CLAUDE.md"
else
  DEST_CLAUDE_DIR="$PWD/.claude"
  CLAUDE_MD_DEST="$PWD/CLAUDE.md"
fi

MANIFEST="$DEST_CLAUDE_DIR/.claude-harness-manifest"
TS="$(date +%Y%m%d-%H%M%S)"
TMP_MANIFEST=""

copied_count=0
skipped_count=0
backup_count=0
BACKUPS=()

dry_prefix() {
  if (( DRY_RUN == 1 )); then
    echo "[dry-run] $*"
  fi
}

ensure_dir() {
  local dir="$1"
  if (( DRY_RUN == 1 )); then
    dry_prefix "mkdir -p $dir"
  else
    mkdir -p "$dir"
  fi
}

write_manifest_line() {
  local path="$1"
  if [[ -z "$TMP_MANIFEST" ]]; then
    dry_prefix "manifest += $path"
    return 0
  fi
  echo "$path" >> "$TMP_MANIFEST"
}

install_file() {
  local src="$1" dst="$2"
  if [[ -e "$dst" ]]; then
    if cmp -s "$src" "$dst"; then
      write_manifest_line "$dst"
      return 0
    fi
    local bak="${dst}.bak.${TS}"
    if (( DRY_RUN == 1 )); then
      dry_prefix "cp -p $dst $bak"
    else
      cp -p "$dst" "$bak"
    fi
    BACKUPS+=("$bak")
    backup_count=$((backup_count + 1))
    write_manifest_line "$bak"
  fi
  ensure_dir "$(dirname "$dst")"
  if (( DRY_RUN == 1 )); then
    dry_prefix "cp $src $dst"
  else
    cp "$src" "$dst"
  fi
  copied_count=$((copied_count + 1))
  write_manifest_line "$dst"
}

install_tree() {
  local src="$1" dst="$2"
  [[ -d "$src" ]] || return 0
  while IFS= read -r -d '' f; do
    local rel="${f#"$src"/}"
    install_file "$f" "$dst/$rel"
  done < <(find "$src" -type f -print0)
}

install_claude_md() {
  if [[ -e "$CLAUDE_MD_DEST" ]]; then
    if cmp -s "$SRC_CLAUDE_MD" "$CLAUDE_MD_DEST"; then
      write_manifest_line "$CLAUDE_MD_DEST"
      return 0
    fi
    if (( FORCE == 0 )); then
      echo "skipped: $CLAUDE_MD_DEST already exists with different content"
      echo "  hint: re-run with --force to overwrite, or diff manually:"
      echo "        diff \"$SRC_CLAUDE_MD\" \"$CLAUDE_MD_DEST\""
      skipped_count=$((skipped_count + 1))
      return 0
    fi
    local bak="${CLAUDE_MD_DEST}.bak.${TS}"
    if (( DRY_RUN == 1 )); then
      dry_prefix "cp -p $CLAUDE_MD_DEST $bak"
    else
      cp -p "$CLAUDE_MD_DEST" "$bak"
    fi
    BACKUPS+=("$bak")
    backup_count=$((backup_count + 1))
    write_manifest_line "$bak"
  fi
  ensure_dir "$(dirname "$CLAUDE_MD_DEST")"
  if (( DRY_RUN == 1 )); then
    dry_prefix "cp $SRC_CLAUDE_MD $CLAUDE_MD_DEST"
  else
    cp "$SRC_CLAUDE_MD" "$CLAUDE_MD_DEST"
  fi
  copied_count=$((copied_count + 1))
  write_manifest_line "$CLAUDE_MD_DEST"
}

ensure_dir "$DEST_CLAUDE_DIR"
if (( DRY_RUN == 0 )); then
  TMP_MANIFEST="$(mktemp)"
  trap 'rm -f "$TMP_MANIFEST"' EXIT
fi

install_tree "$SRC_CLAUDE_DIR/agents" "$DEST_CLAUDE_DIR/agents"
install_tree "$SRC_CLAUDE_DIR/rules"  "$DEST_CLAUDE_DIR/rules"
install_claude_md

if (( DRY_RUN == 0 )); then
  sort -u "$TMP_MANIFEST" > "$MANIFEST"
fi

echo ""
if (( DRY_RUN == 1 )); then
  echo "claude-harness DRY RUN (${MODE} mode) — no files written"
else
  echo "claude-harness install complete (${MODE} mode)"
fi
echo "  destination:      $DEST_CLAUDE_DIR"
echo "  files written:    $copied_count"
echo "  files skipped:    $skipped_count"
echo "  files backed up:  $backup_count"
if (( backup_count > 0 )); then
  echo "  backup paths:"
  for b in "${BACKUPS[@]}"; do
    echo "    $b"
  done
fi
if (( DRY_RUN == 0 )); then
  echo "  manifest:         $MANIFEST"
fi
