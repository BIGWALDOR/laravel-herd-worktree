# Vite Configuration for Worktrees

## Required `server` Config

Add or update the `server` key in `vite.config.js` (or `vite.config.ts`):

```javascript
export default defineConfig(() => {
    return {
        server: {
            host: 'localhost',  // Must be 'localhost', NOT '0.0.0.0'
            cors: true,         // Allow cross-origin requests from *.test domain
        },
        plugins: [
            // ... existing plugins
        ],
    };
});
```

## Why Each Setting Matters

- **`host: 'localhost'`** — Vite defaults to `localhost`, but some configs override to `0.0.0.0`. When Vite binds to `0.0.0.0`, the browser sees a different origin than `*.test`, triggering CORS blocks. Using `localhost` keeps the dev server origin consistent.
- **`cors: true`** — The Herd site (`*.test`) loads Vite assets from `localhost:5173`. Without CORS enabled, the browser blocks these cross-origin requests, resulting in a white page.

## Note

This configuration applies **only to Vite projects**. Laravel Mix (Webpack) projects do not need CORS configuration — Mix compiles assets to `public/` which are served directly by Herd.
