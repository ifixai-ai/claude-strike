#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
set -euo pipefail

REPO="${CLAUDE_STRIKE_REPO:-https://github.com/n-papaioannou/claude-strike.git}"
CACHE="${CLAUDE_STRIKE_CACHE:-$HOME/.cache/claude-strike}"
TARGET="$PWD"

SCRIPT_PATH="${BASH_SOURCE[0]:-}"
if [[ -n "$SCRIPT_PATH" && -f "$SCRIPT_PATH" ]]; then
  SCRIPT_DIR="$(cd -- "$(dirname -- "$SCRIPT_PATH")" && pwd)"
else
  SCRIPT_DIR=""
fi

if [[ -n "$SCRIPT_DIR" && -f "$SCRIPT_DIR/CLAUDE.md" && -d "$SCRIPT_DIR/.claude/agents" ]]; then
  SOURCE_DIR="$SCRIPT_DIR"
else
  case "$CACHE" in
    /|"$HOME"|"$HOME"/)
      echo "error: CLAUDE_STRIKE_CACHE must be a dedicated subdirectory, not '$CACHE'." >&2
      exit 1
      ;;
  esac
  if [[ -d "$CACHE/.git" ]]; then
    if [[ -n "$(git -C "$CACHE" status --porcelain)" ]]; then
      echo "error: $CACHE has local modifications — refusing to overwrite." >&2
      echo "       commit/stash or remove the directory and re-run." >&2
      exit 1
    fi
    git -C "$CACHE" fetch --prune origin
    git -C "$CACHE" pull --ff-only
  else
    mkdir -p "$(dirname "$CACHE")"
    git clone --depth 1 "$REPO" "$CACHE"
  fi
  SOURCE_DIR="$CACHE"
fi

if [[ "$SOURCE_DIR" == "$TARGET" ]]; then
  echo "error: run bootstrap.sh from your target repo, not from the claude-strike checkout itself" >&2
  exit 1
fi

SRC_CLAUDE_DIR="$SOURCE_DIR/.claude"
SRC_CLAUDE_MD="$SOURCE_DIR/CLAUDE.md"
DEST_CLAUDE_DIR="$TARGET/.claude"
CLAUDE_MD_DEST="$TARGET/CLAUDE.md"
TS="$(date +%Y%m%d-%H%M%S)"

copied_count=0
backup_count=0
BACKUPS=()

mkdir -p "$DEST_CLAUDE_DIR"

install_file() {
  local src="$1" dst="$2"
  if [[ -e "$dst" ]]; then
    if cmp -s "$src" "$dst"; then
      return 0
    fi
    local bak="${dst}.bak.${TS}"
    cp -p "$dst" "$bak" || { echo "error: could not back up $dst to $bak" >&2; exit 1; }
    BACKUPS+=("$bak")
    backup_count=$((backup_count + 1))
  fi
  mkdir -p "$(dirname "$dst")"
  cp "$src" "$dst"
  copied_count=$((copied_count + 1))
}

install_tree() {
  local src="$1" dst="$2"
  [[ -d "$src" ]] || return 0
  while IFS= read -r -d '' f; do
    local rel="${f#"$src"/}"
    install_file "$f" "$dst/$rel"
  done < <(find "$src" -type f ! -type l -print0)
}

install_tree "$SRC_CLAUDE_DIR/agents" "$DEST_CLAUDE_DIR/agents"
install_tree "$SRC_CLAUDE_DIR/rules"  "$DEST_CLAUDE_DIR/rules"
install_file "$SRC_CLAUDE_MD" "$CLAUDE_MD_DEST"

echo ""
echo "claude-strike files installed in $TARGET"
echo "  files written:    $copied_count"
echo "  files backed up:  $backup_count"
if (( backup_count > 0 )); then
  echo "  backup paths:"
  for b in "${BACKUPS[@]}"; do
    echo "    $b"
  done
fi

echo ""
if [[ -n "${CLAUDE_STRIKE_SKIP_SPEC_KIT:-}" ]]; then
  echo "spec-kit init skipped (CLAUDE_STRIKE_SKIP_SPEC_KIT is set)"
elif [[ ! -d "$TARGET/.git" ]]; then
  echo "warning: $TARGET is not a git repo — skipping spec-kit init" >&2
  echo "         run 'git init' and re-run, or set CLAUDE_STRIKE_SKIP_SPEC_KIT=1" >&2
elif command -v uvx >/dev/null 2>&1; then
  SPEC_KIT_REF="${CLAUDE_STRIKE_SPEC_KIT_REF:-main}"
  if [[ ! "$SPEC_KIT_REF" =~ ^[A-Za-z0-9._/-]+$ ]]; then
    echo "error: CLAUDE_STRIKE_SPEC_KIT_REF contains unsupported characters: $SPEC_KIT_REF" >&2
    exit 1
  fi
  echo "running: specify init --here --ai claude  (spec-kit @ $SPEC_KIT_REF)"
  if ! uvx --from "git+https://github.com/github/spec-kit.git@$SPEC_KIT_REF" specify init --here --ai claude; then
    echo "warning: spec-kit init failed — the files are installed, spec-kit is not" >&2
    echo "         (existing .specify/ is preserved; delete it to re-init)" >&2
  fi
else
  echo "warning: uvx not found on PATH — skipping spec-kit init" >&2
  echo "         install uv (https://docs.astral.sh/uv/) and re-run to add spec-kit" >&2
fi
