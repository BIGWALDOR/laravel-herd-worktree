# Laravel Herd Worktree

<p align="center">
  <img src="art/logo.png" alt="Laravel Herd Worktree" width="400">
</p>

A Claude Code skill that automates setting up git worktrees for Laravel projects served by Laravel Herd.

## What It Does

When you need to work on a feature branch in isolation, this skill:

1. **Detects build tool** — auto-detects Vite or Laravel Mix (Webpack) and adjusts setup accordingly
2. **Creates a git worktree** in `.worktrees/<ticket-id>-<project-name>` (e.g., `ma-123-appetise-web`)
3. **Links with Laravel Herd** — serves the worktree at `http://` (Vite) or `https://` (Mix, via `herd secure`)
4. **Configures environment** — copies and updates `.env` with correct APP_URL, session domain, Sanctum domains, and secure cookie settings
5. **Installs dependencies** — runs `composer install` and `npm install`
6. **Starts development** — kills stale dev server processes and starts fresh (`npm run dev` for Vite, `npm run dev` + `npm run watch` for Mix)

When you're done, re-invoke the skill to create a PR, transfer changes back to the main directory, or abandon the worktree.

**Site naming convention:** The skill extracts a Linear ticket ID (e.g., `ma-123`) from the branch name and combines it with the project name to create the site URL: `ma-123-appetise-web.test`. If no ticket ID is found, it falls back to `<project-name>-<branch-name>`.

## Prerequisites

- **Laravel Herd** installed and running on macOS
- **Git** for version control
- **Vite or Laravel Mix (Webpack)** as the frontend build tool (auto-detected)
- **npm** as package manager (adjust commands if using yarn/pnpm)
- **Laravel Sanctum** if using API authentication (optional - skill handles this if present)

## Installation

### Via Claude Code CLI

1. Add the marketplace:
   ```bash
   claude plugin marketplace add BIGWALDOR/laravel-herd-worktree
   ```

2. Install the plugin:
   ```bash
   claude plugin install laravel-herd-worktree@bigwaldor-laravel-tools
   ```

### Via Claude Code Slash Commands

From within a Claude Code session:

1. Add the marketplace:
   ```
   /plugin marketplace add BIGWALDOR/laravel-herd-worktree
   ```

2. Install the plugin:
   ```
   /plugin install laravel-herd-worktree@bigwaldor-laravel-tools
   ```

## Usage

The skill is automatically invoked when you mention worktrees with Laravel Herd projects. Example prompts:

- "Set up a worktree for feature-login"
- "Create an isolated workspace for this branch"
- "I need to work on a feature branch in isolation"

### Manual Invocation

```
/laravel-herd-worktree
```

## Configuration

### Base Branch

The skill detects available branches (`main`, `master`, `develop`, `staging`) and asks you to choose which one to create the worktree from. For PRs, it auto-detects the repository's default branch via `git symbolic-ref refs/remotes/origin/HEAD`.

### Build Tool

The skill auto-detects whether your project uses Vite (`vite.config.js`/`.ts`) or Laravel Mix (`webpack.mix.js`) and confirms with you before proceeding. This affects:
- **Protocol** — Vite uses HTTP, Mix uses HTTPS (via `herd secure`)
- **Dev server** — Vite runs `npm run dev`, Mix runs `npm run dev` then `npm run watch`
- **CORS** — Vite needs `host: 'localhost'` and `cors: true` in vite.config; Mix doesn't need CORS config

### Package Manager

The skill assumes npm. If you use yarn or pnpm, the skill will ask before running install commands.

### Composer Flags

If your project requires specific composer flags (like `--ignore-platform-reqs`), the skill will ask during setup.

## What Gets Created

```
your-project/
├── .worktrees/
│   └── ma-123-your-project/          # Your isolated worktree
│       ├── .env             # Configured for the worktree URL
│       ├── vendor/          # Fresh composer install
│       └── node_modules/    # Fresh npm install
```

Plus a Herd site:
- Vite: `http://ma-123-your-project.test`
- Mix: `https://ma-123-your-project.test` (secured with `herd secure`)

## Finishing Work

When you're done working, invoke `/laravel-herd-worktree` again. The skill presents three options:

- **Create PR** — commits changes, pushes the branch, runs `gh pr create`, and cleans up the worktree
- **Transfer to main** — merges changes back into your main directory (with `--no-commit --no-ff`) for you to stage and commit manually
- **Abandon** — discards changes and cleans up the worktree

Cleanup automatically kills dev server processes, runs `herd unlink` (and `herd unsecure` for Mix), removes the worktree, and optionally deletes the branch.

## Common Issues

### 401 Unauthorized on API routes
- Add worktree domain to `SANCTUM_STATEFUL_DOMAINS` in `.env`
- Run `php artisan config:clear`

### Cookie rejected for invalid domain
- Update `SESSION_DOMAIN` in `.env` to match worktree domain
- Add `SESSION_SECURE_COOKIE=false` for HTTP sites

### CORS Errors / White page (Vite)
- Ensure `vite.config.js` has `host: 'localhost'` and `cors: true`
- Restart Vite from the worktree directory

### Mixed Content Error (Vite)
- Don't secure the Herd site (use HTTP, not HTTPS)
- Keep `APP_URL` as `http://` not `https://`

### Assets not loading (Vite)
- Kill all Vite processes: `pkill -f "node.*vite"`
- Remove hot file: `rm -f public/hot`
- Restart Vite from worktree

### "The Mix manifest does not exist" (Mix)
- Run `npm run dev` from the worktree directory to generate `public/mix-manifest.json`
- Then restart `npm run watch`

### Session not persisting (Mix)
- Set `SESSION_SECURE_COOKIE=true` in `.env` (Mix uses HTTPS)
- Run `php artisan config:clear` and clear browser cookies

### Assets not loading (Mix)
- Kill webpack processes: `pkill -f "node.*webpack"`
- Run `npm run watch` from the **worktree** directory (not the main project)

## Updating

To update an already installed plugin:

```bash
claude plugin update laravel-herd-worktree@bigwaldor-laravel-tools
```

## Attribution

This project is a fork of [harris21/laravel-herd-worktree](https://github.com/harris21/laravel-herd-worktree), which provided the original Vite-only, prompt-based skill. This fork extends it with:

- **Laravel Mix (Webpack) support** alongside Vite
- **Deterministic execution** via shell scripts (replacing the purely prompt-driven flow)
- **Ticket-ID-based site naming** (e.g., `ma-123-project.test`) extracted from branch names
- **Structured reference docs and examples** to guide the skill more reliably

## License

MIT - see [LICENSE](LICENSE)
