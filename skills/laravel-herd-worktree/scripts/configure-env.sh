#!/usr/bin/env bash
# Copy and configure .env for a Laravel worktree.
# Usage: ./configure-env.sh <source-env> <worktree-path> <site-name> <build-tool>

set -euo pipefail

SOURCE_ENV="$1"
WORKTREE_PATH="$2"
SITE_NAME="$3"
BUILD_TOOL="${4:-vite}"

if [ ! -f "$SOURCE_ENV" ]; then
  echo "Error: Source .env not found at $SOURCE_ENV" >&2
  exit 1
fi

# Copy .env to worktree
cp "$SOURCE_ENV" "$WORKTREE_PATH/.env"

ENV_FILE="$WORKTREE_PATH/.env"

# Update APP_URL — HTTPS for Mix (assets compiled to public/), HTTP for Vite (dev server)
if [ "$BUILD_TOOL" = "mix" ]; then
  sed -i '' "s|APP_URL=.*|APP_URL=https://$SITE_NAME.test|" "$ENV_FILE"
else
  sed -i '' "s|APP_URL=.*|APP_URL=http://$SITE_NAME.test|" "$ENV_FILE"
fi

# Update SESSION_DOMAIN
sed -i '' "s|SESSION_DOMAIN=.*|SESSION_DOMAIN=$SITE_NAME.test|" "$ENV_FILE"

# Append worktree domain to SANCTUM_STATEFUL_DOMAINS if the key exists
if grep -q "SANCTUM_STATEFUL_DOMAINS" "$ENV_FILE"; then
  sed -i '' "s|SANCTUM_STATEFUL_DOMAINS=\(.*\)|SANCTUM_STATEFUL_DOMAINS=\1,$SITE_NAME.test|" "$ENV_FILE"
fi

# Set secure cookie to match protocol — true for HTTPS (Mix), false for HTTP (Vite)
if [ "$BUILD_TOOL" = "mix" ]; then
  echo "SESSION_SECURE_COOKIE=true" >> "$ENV_FILE"
else
  echo "SESSION_SECURE_COOKIE=false" >> "$ENV_FILE"
fi

echo "Configured $ENV_FILE for $SITE_NAME.test ($BUILD_TOOL)"
