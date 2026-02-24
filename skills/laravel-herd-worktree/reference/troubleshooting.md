# Troubleshooting

## Setup Verification Checklist

Before considering setup complete, verify:

- [ ] Build tool detected and confirmed (`$BUILD_TOOL = vite` or `mix`)
- [ ] Worktree created at `.worktrees/$SITE_NAME`
- [ ] Herd link created (`herd link $SITE_NAME`)
- [ ] **(Mix only)** Site secured (`herd secure $SITE_NAME`) — HTTPS
- [ ] **(Vite only)** Site is **NOT** secured — HTTP only
- [ ] `.env` copied with `APP_URL`, `SESSION_DOMAIN`, and `SESSION_SECURE_COOKIE` updated
- [ ] **(Mix)** `APP_URL=https://...`, `SESSION_SECURE_COOKIE=true`
- [ ] **(Vite)** `APP_URL=http://...`, `SESSION_SECURE_COOKIE=false`
- [ ] `SANCTUM_STATEFUL_DOMAINS` includes the worktree domain (if key exists)
- [ ] `composer install` completed successfully
- [ ] `npm install` completed successfully
- [ ] **(Vite only)** `vite.config.js` has `host: 'localhost'` and `cors: true`
- [ ] **(Vite only)** `npm run dev` running from worktree directory
- [ ] **(Mix only)** `npm run watch` running from worktree directory
- [ ] **(Mix)** Site accessible at `https://$SITE_NAME.test`
- [ ] **(Vite)** Site accessible at `http://$SITE_NAME.test`

---

## Common Issues

### 401 Unauthorized on API Routes

- **Cause:** `SANCTUM_STATEFUL_DOMAINS` missing the worktree domain
- **Fix:** Add `$SITE_NAME.test` to `SANCTUM_STATEFUL_DOMAINS`, then `php artisan config:clear`

### Cookie Rejected for Invalid Domain

- **Cause:** `SESSION_DOMAIN` doesn't match the worktree site
- **Fix:** Update `SESSION_DOMAIN=$SITE_NAME.test`, set `SESSION_SECURE_COOKIE` to match protocol, run `php artisan config:clear`, clear browser cookies

### Session Not Persisting on Mix HTTPS Site

- **Cause:** `SESSION_SECURE_COOKIE=false` on an HTTPS site — the browser sends the cookie but it may not be set correctly when the secure flag doesn't match
- **Fix:** Set `SESSION_SECURE_COOKIE=true` in `.env`, run `php artisan config:clear`, clear browser cookies

### White Page / CORS Errors (Vite Only)

- **Cause:** Vite using `host: '0.0.0.0'` instead of `localhost`
- **Fix:** Update `vite.config.js` to `host: 'localhost'` and `cors: true`, restart `npm run dev`
- See [examples/vite-config.md](../examples/vite-config.md)

### Assets Not Loading (Mix)

- **Cause:** Mix watcher not running or ran from wrong directory
- **Fix:** `pkill -f "node.*webpack"`, then run `npm run watch` from the **worktree** directory

### Mixed Content Error (Vite Only)

- **Cause:** HTTPS site trying to load HTTP Vite dev server assets
- **Fix:** Run `herd unsecure $SITE_NAME`, update `APP_URL` to `http://`, set `SESSION_SECURE_COOKIE=false`, `php artisan config:clear`, restart dev server
- **Note:** Mix projects are intentionally secured with `herd secure` and don't have this issue since assets are compiled to `public/`

### Missing vendor or node_modules

- **Cause:** Worktrees do not share `vendor/` or `node_modules/` with the main project
- **Fix:** Run `composer install` and `npm install` in the worktree directory

### Port 5173 Already in Use (Vite Only)

- **Cause:** Another Vite instance running (e.g., from main project)
- **Fix:** `pkill -f "node.*vite"`, then restart `npm run dev`

### Port in Use for Webpack (Mix Only)

- **Cause:** Another webpack-dev-server instance running
- **Fix:** `pkill -f "node.*webpack"`, then restart `npm run watch`
