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

# Remove the worktree
cd "$PROJECT_ROOT"
git worktree remove ".worktrees/$SITE_NAME" 2>/dev/null || true

# Optionally delete the branch
if [ -n "$DELETE_BRANCH" ]; then
  git branch -D "$DELETE_BRANCH" 2>/dev/null || true
fi

echo "Cleaned up worktree: $SITE_NAME"
