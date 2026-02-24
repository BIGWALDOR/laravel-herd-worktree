# Setup Steps

Detailed instructions for each step of worktree setup. Referenced from SKILL.md.

---

## Step 0: Detect Build Tool

Run the detection script from the project root:

```bash
bash scripts/detect-build-tool.sh "$PROJECT_ROOT"
```

This checks for `vite.config.js`, `vite.config.ts`, or `webpack.mix.js` and outputs `vite`, `mix`, or `unknown`.

**Use AskUserQuestion to confirm the result:**

```
AskUserQuestion:
  question: "I detected your project uses [Vite / Laravel Mix]. Is that correct?"
  header: "Build Tool"
  options:
    - label: "Yes, [Vite / Laravel Mix] (Detected)"
      description: "Proceed with the detected build tool"
    - label: "Vite"
      description: "This project uses Vite as the build tool"
    - label: "Laravel Mix (Webpack)"
      description: "This project uses Laravel Mix with Webpack"
```

If the script outputs `unknown`, present the question without a pre-selection.

Store the confirmed value as `$BUILD_TOOL` (`vite` or `mix`).

---

## Step 1: Project Name and Branch Name

**Detect the project name:**

```bash
PROJECT_NAME=$(basename "$PWD")
```

**Use AskUserQuestion to confirm:**

```
AskUserQuestion:
  question: "Project name detected as '$PROJECT_NAME'. This will be used for the Herd URL (e.g., projectname-branchname.test). Is this correct?"
  header: "Project"
  options:
    - label: "Yes, use '$PROJECT_NAME'"
      description: "Use the detected project name"
    - label: "Use a different name"
      description: "I'll provide a custom project name"
```

**Use AskUserQuestion for the branch name** (or use `$ARGUMENTS` if provided):

```
AskUserQuestion:
  question: "What branch name would you like to use for this worktree?"
  header: "Branch Name"
  options:
    - label: "feature/new-feature"
      description: "Generic feature branch - you can provide a custom name"
    - label: "bugfix/fix-issue"
      description: "Bugfix branch pattern"
    - label: "experiment/test"
      description: "Experimental/testing branch"
```

**Detect available branches and ask which base branch to create from:**

```bash
# Get the current branch
CURRENT_BRANCH=$(git branch --show-current)

# Get common base branch candidates that exist locally
BASE_CANDIDATES=$(git branch --list main master develop staging | sed 's/^[* ]*//')
```

```
AskUserQuestion:
  question: "Which branch should the worktree be created from? (Currently on '$CURRENT_BRANCH')"
  header: "Base Branch"
  options:
    - label: "$CURRENT_BRANCH (Current)"
      description: "Create the worktree from the branch you're currently on"
    - label: "main"
      description: "Create from the main branch"
    - label: "Other"
      description: "I'll type a different branch name"
```

Dynamically populate the options with branches from `$BASE_CANDIDATES`, marking the current branch. If the user selects "Other", ask them to type the branch name.

Store the confirmed value as `$BASE_BRANCH`.

**Construct the site name:**

```bash
SANITIZED_BRANCH_NAME=$(echo "$BRANCH_NAME" | tr '/' '-')
SITE_NAME="$PROJECT_NAME-$SANITIZED_BRANCH_NAME"
```

Example: project `appetise-web` + branch `feature/login` -> `appetise-web-feature-login.test`

---

## Step 2: Create Worktree

```bash
# Check if worktree already exists
git worktree list | grep "$BRANCH_NAME"

# If not, create it from the chosen base branch
git worktree add .worktrees/$SITE_NAME -b $BRANCH_NAME $BASE_BRANCH
```

The worktree is created inside `.worktrees/` in the main project directory.

---

## Step 3: Link with Laravel Herd

```bash
cd /path/to/project/.worktrees/$SITE_NAME
herd link $SITE_NAME
```

This creates a site at `http://$SITE_NAME.test`.

**Do NOT run `herd secure`** — keep the site on HTTP to avoid mixed content issues with the dev process.

---

## Step 4: Copy and Configure .env

Run the configuration script:

```bash
bash scripts/configure-env.sh /path/to/main/project/.env /path/to/worktree $SITE_NAME
```

Or manually:

```bash
cp /path/to/main/project/.env /path/to/worktree/.env

sed -i '' "s|APP_URL=.*|APP_URL=http://$SITE_NAME.test|" .env
sed -i '' "s|SESSION_DOMAIN=.*|SESSION_DOMAIN=$SITE_NAME.test|" .env

# Append to SANCTUM_STATEFUL_DOMAINS (if present)
if grep -q "SANCTUM_STATEFUL_DOMAINS" .env; then
  sed -i '' "s|SANCTUM_STATEFUL_DOMAINS=\(.*\)|SANCTUM_STATEFUL_DOMAINS=\1,$SITE_NAME.test|" .env
fi

echo "SESSION_SECURE_COOKIE=false" >> .env
```

See [examples/env-config.md](../examples/env-config.md) for detailed before/after examples and key rules.

---

## Step 5: Install Dependencies

**Use AskUserQuestion before running composer install:**

```
AskUserQuestion:
  question: "Would you like to add any flags to composer install?"
  header: "Composer"
  options:
    - label: "No flags needed (Recommended)"
      description: "Run 'composer install --no-interaction' with no additional flags"
    - label: "Add --ignore-platform-req=ext-mailparse"
      description: "Ignore the mailparse extension requirement (common issue)"
    - label: "Add custom flags"
      description: "I'll provide specific flags"
```

Then run:

```bash
composer install --no-interaction   # Append user's custom flags if provided
npm install
php artisan config:clear
php artisan cache:clear
```

---

## Step 6: CORS Configuration (Vite Only)

**If `$BUILD_TOOL = "vite"`:** Ensure `vite.config.js` (or `.ts`) includes the `server` block. See [examples/vite-config.md](../examples/vite-config.md) for the exact snippet and explanation.

**If `$BUILD_TOOL = "mix"`:** Skip this step entirely. Mix compiles to `public/` and doesn't need CORS.

---

## Step 7: Kill Existing Processes and Start Dev

**If `$BUILD_TOOL = "vite"`:**

```bash
pkill -f "node.*vite" 2>/dev/null || true
rm -f public/hot
npm run dev
```

**If `$BUILD_TOOL = "mix"`:**

```bash
pkill -f "node.*webpack" 2>/dev/null || true
rm -f public/hot
npm run watch
```

For Mix projects, inform the user: "Assets are being compiled. For hot module replacement, you can stop this and run `npm run hot` instead."
