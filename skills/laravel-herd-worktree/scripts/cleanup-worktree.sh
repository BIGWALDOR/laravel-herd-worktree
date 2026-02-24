#!/usr/bin/env bash
# Clean up a Laravel Herd worktree: stop processes, unlink, remove worktree.
# Usage: ./cleanup-worktree.sh <project-root> <site-name> [--delete-branch <branch-name>]

set -euo pipefail

PROJECT_ROOT="$1"
SITE_NAME="$2"
DELETE_BRANCH=""

if [ "${3:-}" = "--delete-branch" ] && [ -n "${4:-}" ]; then
  DELETE_BRANCH="$4"
fi

# Kill Vite and Webpack dev processes
pkill -f "node.*vite" 2>/dev/null || true
pkill -f "node.*webpack" 2>/dev/null || true

# Unlink from Laravel Herd
herd unlink "$SITE_NAME" 2>/dev/null || true

# Remove the worktree (--force handles uncommitted/untracked changes)
cd "$PROJECT_ROOT"
if git worktree remove --force ".worktrees/$SITE_NAME" 2>/dev/null; then
  echo "Removed worktree: .worktrees/$SITE_NAME"
else
  echo "WARNING: Failed to remove worktree .worktrees/$SITE_NAME — it may not exist or require manual removal." >&2
fi

# Optionally delete the branch (only possible after worktree is removed)
if [ -n "$DELETE_BRANCH" ]; then
  if git branch -D "$DELETE_BRANCH" 2>/dev/null; then
    echo "Deleted branch: $DELETE_BRANCH"
  else
    echo "WARNING: Failed to delete branch '$DELETE_BRANCH' — it may not exist or is still linked to a worktree." >&2
  fi
fi

echo "Cleanup complete for: $SITE_NAME"
