#!/usr/bin/env bash
set -euo pipefail

# Users can override with CLAUDE_HARNESS_REPO=... or --repo-url=... at invocation.
DEFAULT_REPO_URL="https://github.com/n-papaioannou/claude-harness.git"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd)" || SCRIPT_DIR=""

MODE="global"
WITH_SPEC_KIT=0
REPO_URL="${CLAUDE_HARNESS_REPO:-$DEFAULT_REPO_URL}"
CACHE_DIR="${CLAUDE_HARNESS_CACHE:-$HOME/.cache/claude-harness}"
INSTALL_ARGS=()

usage() {
  cat >&2 <<EOF
Usage: setup.sh [--project] [--spec-kit] [--dry-run] [--force] [--repo-url=URL]

  --project         Install into the current repo instead of ~/.claude/
  --spec-kit        Also run \`specify init\` in the current directory (needs uv)
  --dry-run         Pass-through to install.sh (no filesystem writes)
  --force           Pass-through to install.sh (overwrite existing CLAUDE.md)
  --repo-url=URL    Override the clone URL (defaults to $DEFAULT_REPO_URL,
                    or CLAUDE_HARNESS_REPO if set)
EOF
  exit 2
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project)    MODE="project" ;;
    --spec-kit)   WITH_SPEC_KIT=1 ;;
    --dry-run)    INSTALL_ARGS+=("--dry-run") ;;
    --force)      INSTALL_ARGS+=("--force") ;;
    --repo-url=*) REPO_URL="${1#--repo-url=}" ;;
    -h|--help)    usage ;;
    *)            echo "unknown option: $1" >&2; usage ;;
  esac
  shift
done

if [[ -z "$SCRIPT_DIR" || ! -x "$SCRIPT_DIR/install.sh" ]]; then
  if [[ -z "$REPO_URL" ]]; then
    echo "error: not running from a claude-harness clone and no repo URL available" >&2
    echo "       either clone the repo first or pass --repo-url=URL" >&2
    exit 1
  fi
  echo "fetching claude-harness from $REPO_URL into $CACHE_DIR"
  if [[ -d "$CACHE_DIR/.git" ]]; then
    git -C "$CACHE_DIR" pull --ff-only
  else
    mkdir -p "$(dirname "$CACHE_DIR")"
    git clone --depth 1 "$REPO_URL" "$CACHE_DIR"
  fi
  SCRIPT_DIR="$CACHE_DIR"
fi

if [[ "$MODE" == "project" ]]; then
  "$SCRIPT_DIR/install.sh" --project "${INSTALL_ARGS[@]}"
else
  "$SCRIPT_DIR/install.sh" "${INSTALL_ARGS[@]}"
fi

if (( WITH_SPEC_KIT == 1 )); then
  if ! command -v uvx >/dev/null 2>&1; then
    echo "warning: uvx not found on PATH — skipping spec-kit init" >&2
    echo "         install uv (https://docs.astral.sh/uv/) and re-run with --spec-kit" >&2
  else
    uvx --from git+https://github.com/github/spec-kit.git specify init --here --ai claude
  fi
fi

echo ""
echo "setup complete. open Claude Code in this repo to use it."
