#!/usr/bin/env bash
# Detect the frontend build tool used by a Laravel project.
# Usage: ./detect-build-tool.sh [project-root]
# Outputs: "vite", "mix", or "unknown"

PROJECT_ROOT="${1:-.}"

if [ -f "$PROJECT_ROOT/vite.config.js" ] || [ -f "$PROJECT_ROOT/vite.config.ts" ]; then
  echo "vite"
elif [ -f "$PROJECT_ROOT/webpack.mix.js" ]; then
  echo "mix"
else
  echo "unknown"
fi
