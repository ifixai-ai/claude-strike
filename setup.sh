#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
set -euo pipefail

# Users can override with CLAUDE_HARNESS_REPO=... or --repo-url=... at invocation.
DEFAULT_REPO_URL="https://github.com/n-papaioannou/claude-harness.git"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd)" || SCRIPT_DIR=""

MODE="global"
SKIP_SPEC_KIT=0
REPO_URL="${CLAUDE_HARNESS_REPO:-$DEFAULT_REPO_URL}"
REPO_REF="${CLAUDE_HARNESS_REF:-}"
CACHE_DIR="${CLAUDE_HARNESS_CACHE:-$HOME/.cache/claude-harness}"
INSTALL_ARGS=()

usage() {
  cat >&2 <<EOF
Usage: setup.sh [--project] [--no-spec-kit] [--dry-run] [--force] [--repo-url=URL] [--ref=REF]

  --project         Install into the current repo instead of ~/.claude/.
                    Project installs also run \`specify init\` in the current
                    directory unless --no-spec-kit is passed.
  --no-spec-kit     Skip the \`specify init\` step on project installs.
  --dry-run         Pass-through to install.sh (no filesystem writes)
  --force           Pass-through to install.sh (overwrite existing CLAUDE.md)
  --repo-url=URL    Override the clone URL (defaults to $DEFAULT_REPO_URL,
                    or CLAUDE_HARNESS_REPO if set)
  --ref=REF         Check out REF (tag, branch, or commit SHA) after cloning,
                    and re-check out on subsequent runs. Defaults to the
                    remote default branch, or CLAUDE_HARNESS_REF if set.
EOF
  exit 2
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project)      MODE="project" ;;
    --no-spec-kit)  SKIP_SPEC_KIT=1 ;;
    --dry-run)      INSTALL_ARGS+=("--dry-run") ;;
    --force)        INSTALL_ARGS+=("--force") ;;
    --repo-url=*)   REPO_URL="${1#--repo-url=}" ;;
    --ref=*)        REPO_REF="${1#--ref=}" ;;
    -h|--help)      usage ;;
    *)              echo "unknown option: $1" >&2; usage ;;
  esac
  shift
done

WITH_SPEC_KIT=0
if [[ "$MODE" == "project" && $SKIP_SPEC_KIT -eq 0 ]]; then
  WITH_SPEC_KIT=1
fi

if [[ -z "$SCRIPT_DIR" || ! -x "$SCRIPT_DIR/install.sh" ]]; then
  if [[ -z "$REPO_URL" ]]; then
    echo "error: not running from a claude-harness clone and no repo URL available" >&2
    echo "       either clone the repo first or pass --repo-url=URL" >&2
    exit 1
  fi
  echo "fetching claude-harness from $REPO_URL${REPO_REF:+ at $REPO_REF} into $CACHE_DIR"
  if [[ -d "$CACHE_DIR/.git" ]]; then
    if [[ -n "$(git -C "$CACHE_DIR" status --porcelain 2>/dev/null)" ]]; then
      echo "error: $CACHE_DIR has local modifications — refusing to overwrite." >&2
      echo "       commit/stash them, or remove the directory and re-run." >&2
      exit 1
    fi
    git -C "$CACHE_DIR" fetch --tags --prune origin
    if [[ -n "$REPO_REF" ]]; then
      git -C "$CACHE_DIR" -c advice.detachedHead=false checkout --detach "$REPO_REF"
    else
      git -C "$CACHE_DIR" pull --ff-only
    fi
  else
    mkdir -p "$(dirname "$CACHE_DIR")"
    if [[ -n "$REPO_REF" ]]; then
      git clone "$REPO_URL" "$CACHE_DIR"
      git -C "$CACHE_DIR" -c advice.detachedHead=false checkout --detach "$REPO_REF"
    else
      git clone --depth 1 "$REPO_URL" "$CACHE_DIR"
    fi
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
    echo "         install uv (https://docs.astral.sh/uv/) and re-run, or pass --no-spec-kit to silence this" >&2
  else
    uvx --from git+https://github.com/github/spec-kit.git specify init --here --ai claude
  fi
fi

echo ""
echo "setup complete. open Claude Code in this repo to use it."
