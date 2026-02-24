# .env Configuration for Worktrees

## Example: Project `appetise-web`, Branch `feature/login`

Site name: `appetise-web-feature-login`

### Before (copied from main project)

```dotenv
APP_URL=https://appetise-web.test
SESSION_DOMAIN=appetise-web.test
SANCTUM_STATEFUL_DOMAINS=appetise-web.test,localhost
```

### After (configured for worktree)

```dotenv
APP_URL=http://appetise-web-feature-login.test
SESSION_DOMAIN=appetise-web-feature-login.test
SANCTUM_STATEFUL_DOMAINS=appetise-web.test,localhost,appetise-web-feature-login.test
SESSION_SECURE_COOKIE=false
```

## Key Rules

1. **Use HTTP, not HTTPS** — Do NOT run `herd secure`. The dev server (Vite/Mix) serves assets over HTTP; mixing HTTPS site + HTTP assets causes mixed content errors.
2. **Append to SANCTUM_STATEFUL_DOMAINS** — Don't replace existing domains. Add the worktree domain to the comma-separated list so both main and worktree can authenticate.
3. **Set SESSION_SECURE_COOKIE=false** — Required when serving over HTTP. Without this, the browser won't send the session cookie and API requests return 401.
4. **SESSION_DOMAIN must match** — Must be the exact worktree site domain (no scheme, no port). Mismatches cause "cookie rejected for invalid domain" errors.
5. **Always clear config cache** after changes — Run `php artisan config:clear` in the worktree.
