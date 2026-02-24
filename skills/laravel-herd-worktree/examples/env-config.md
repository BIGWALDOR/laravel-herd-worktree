# .env Configuration for Worktrees

## Example: Mix Project — `appetise-web`, Ticket `ma-123`

Site name: `ma-123-appetise-web` (HTTPS — Mix compiles to `public/`)

### Before (copied from main project)

```dotenv
APP_URL=https://appetise-web.test
SESSION_DOMAIN=appetise-web.test
SANCTUM_STATEFUL_DOMAINS=appetise-web.test,localhost
```

### After (configured for worktree)

```dotenv
APP_URL=https://ma-123-appetise-web.test
SESSION_DOMAIN=ma-123-appetise-web.test
SANCTUM_STATEFUL_DOMAINS=appetise-web.test,localhost,ma-123-appetise-web.test
SESSION_SECURE_COOKIE=true
```

---

## Example: Vite Project — `appetise-web`, Ticket `ma-456`

Site name: `ma-456-appetise-web` (HTTP — Vite dev server requires HTTP to avoid mixed content)

### Before (copied from main project)

```dotenv
APP_URL=https://appetise-web.test
SESSION_DOMAIN=appetise-web.test
SANCTUM_STATEFUL_DOMAINS=appetise-web.test,localhost
```

### After (configured for worktree)

```dotenv
APP_URL=http://ma-456-appetise-web.test
SESSION_DOMAIN=ma-456-appetise-web.test
SANCTUM_STATEFUL_DOMAINS=appetise-web.test,localhost,ma-456-appetise-web.test
SESSION_SECURE_COOKIE=false
```

---

## Key Rules

1. **Protocol depends on build tool** — Mix projects use HTTPS (`herd secure`), Vite projects use HTTP (no `herd secure`). The dev server for Vite serves assets over HTTP; mixing HTTPS site + HTTP assets causes mixed content errors. Mix compiles to `public/`, so HTTPS is safe.
2. **Append to SANCTUM_STATEFUL_DOMAINS** — Don't replace existing domains. Add the worktree domain to the comma-separated list so both main and worktree can authenticate.
3. **SESSION_SECURE_COOKIE matches protocol** — `true` for HTTPS (Mix), `false` for HTTP (Vite). Mismatching causes the browser to reject/ignore the session cookie.
4. **SESSION_DOMAIN must match** — Must be the exact worktree site domain (no scheme, no port). Mismatches cause "cookie rejected for invalid domain" errors.
5. **Always clear config cache** after changes — Run `php artisan config:clear` in the worktree.
