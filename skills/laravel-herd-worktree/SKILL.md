---
name: laravel-herd-worktree
description: >
  Use when setting up a Laravel worktree for local development with Laravel Herd,
  or when user asks to work on a feature branch in isolation. Supports Vite and
  Laravel Mix (Webpack) projects.
argument-hint: "[branch-name]"
license: MIT
---

# Laravel Herd Worktree Setup

Sets up a git worktree for Laravel projects served by Laravel Herd, with its own site URL and configured environment. Auto-detects Vite vs Laravel Mix (Webpack).

**Announce at start:** "I'm using the laravel-herd-worktree skill to set up an isolated Laravel workspace with Herd."

## User Interaction

**ALWAYS use the `AskUserQuestion` tool for ALL user interactions.** Never stop and wait for a reply. All question blocks in supporting files use YAML-like format — implement them with AskUserQuestion.

## When to Use

- User wants to work on a feature branch in isolation
- User mentions "worktree" and the project uses Laravel Herd
- Starting work on a task that needs isolation from the main branch
- User invokes `/laravel-herd-worktree`

## Initial Flow

1. Check for existing worktrees: `git worktree list`
2. **If worktrees exist** — AskUserQuestion: set up new, or finish existing (go to Finishing Work)
3. **If no worktrees exist** — proceed with setup
4. If `$ARGUMENTS` is provided, use it as the branch name (skip branch name question)

## Setup Flow

Follow each step in order. Full details, commands, and AskUserQuestion blocks are in [reference/setup-steps.md](reference/setup-steps.md).

0. **Detect build tool** — Run `scripts/detect-build-tool.sh`, confirm with user → `$BUILD_TOOL`
1. **Project & branch names** — Detect `$PROJECT_NAME`, get `$BRANCH_NAME`, ask for `$BASE_BRANCH`, extract `$TICKET_ID` from branch name (`ma-\d+`), construct `$SITE_NAME` as `$TICKET_ID-$PROJECT_NAME`
2. **Create worktree** — `git worktree add .worktrees/$SITE_NAME -b $BRANCH_NAME $BASE_BRANCH`
3. **Link with Herd** — `herd link $SITE_NAME`. Mix: run `herd secure $SITE_NAME` (HTTPS). Vite: HTTP only (do NOT `herd secure`)
4. **Configure .env** — Run `scripts/configure-env.sh` with `$BUILD_TOOL` or manual sed. See [examples/env-config.md](examples/env-config.md)
5. **Install dependencies** — AskUserQuestion for composer flags, then composer/npm install, cache clear
6. **CORS config** — Vite only: add `host: 'localhost'` + `cors: true`. See [examples/vite-config.md](examples/vite-config.md). Skip for Mix.
7. **Start dev server** — Kill existing processes, then `npm run dev` (Vite) or `npm run dev` followed by `npm run watch` (Mix — initial build prevents mix-manifest error)

## Setup Complete

Tell the user:

> Mix: "Your worktree is ready at `https://$SITE_NAME.test`."
> Vite: "Your worktree is ready at `http://$SITE_NAME.test`."
> "All edits should be made in `.worktrees/$SITE_NAME/`. When you're done, run `/laravel-herd-worktree` again and I'll help you integrate or clean up."

## Finishing Work

When the user returns to finish, present three options: Create PR, Transfer to main, or Abandon. Full flows, AskUserQuestion blocks, and cleanup commands are in [reference/finishing-work.md](reference/finishing-work.md).

## Quick Reference

| Variable | Example |
|----------|---------|
| `$PROJECT_NAME` | `appetise-web` |
| `$BRANCH_NAME` | `feature/ma-123-login` |
| `$TICKET_ID` | `ma-123` |
| `$BASE_BRANCH` | `main` |
| `$SITE_NAME` | `ma-123-appetise-web` |
| `$BUILD_TOOL` | `vite` or `mix` |

## CRITICAL: Working Directory

**After setup, ALL file reads, edits, Bash commands, and artisan calls MUST use the worktree path** (`/path/to/project/.worktrees/$SITE_NAME/`), not the main project directory. Remind the user and any subsequent agents.

## Additional Resources

- [reference/setup-steps.md](reference/setup-steps.md) — Detailed setup steps with commands and AskUserQuestion blocks
- [reference/finishing-work.md](reference/finishing-work.md) — PR creation, transfer, and abandon flows
- [reference/troubleshooting.md](reference/troubleshooting.md) — Setup checklist and common issues
- [examples/env-config.md](examples/env-config.md) — Before/after .env examples and key rules
- [examples/vite-config.md](examples/vite-config.md) — Vite CORS configuration snippet
- [scripts/detect-build-tool.sh](scripts/detect-build-tool.sh) — Outputs `vite`, `mix`, or `unknown`
- [scripts/configure-env.sh](scripts/configure-env.sh) — Copy and configure .env for worktree
- [scripts/cleanup-worktree.sh](scripts/cleanup-worktree.sh) — Stop processes, unlink, remove worktree
