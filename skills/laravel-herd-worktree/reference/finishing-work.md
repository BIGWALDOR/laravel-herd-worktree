# Finishing Work (Integrating Back to Main Tree)

When development is complete, **use AskUserQuestion** to ask how to proceed:

```
AskUserQuestion:
  question: "How would you like to finish your worktree changes?"
  header: "Finish Work"
  options:
    - label: "Create PR from worktree (Recommended)"
      description: "Commit, push, and create a PR directly from the worktree branch"
    - label: "Transfer to main directory"
      description: "Merge changes into the main project directory, then clean up the worktree"
    - label: "Abandon changes"
      description: "Discard all changes and remove the worktree"
```

---

## Option A: Create PR from Worktree

### A.0. Gather Information

```
AskUserQuestion:
  questions:
    - question: "Do you have a task/issue number for this work?"
      header: "Task ID"
      options:
        - label: "No task number"
          description: "Skip adding a task identifier"
        - label: "Enter task number"
          description: "I'll provide a task/issue number"
    - question: "How would you like to handle the PR description?"
      header: "PR Body"
      options:
        - label: "I'll write it"
          description: "Create PR with empty body"
        - label: "Generate for me"
          description: "Analyze changes and generate a description automatically"
        - label: "Leave empty"
          description: "Create PR with no description"
```

### A.1. Commit All Changes

```bash
cd /path/to/project/.worktrees/$SITE_NAME
git add -A
git commit -m "Your commit message (#TASK_NUMBER)"
```

### A.2. Push and Create PR

```bash
# Detect default branch
DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')

git push -u origin $BRANCH_NAME

gh pr create --base $DEFAULT_BRANCH --title "Description (#TASK_NUMBER)" --body "$BODY"
```

### A.3. Cleanup After PR

Run the cleanup script from the main project directory:

```bash
bash scripts/cleanup-worktree.sh "$PROJECT_ROOT" "$SITE_NAME" --delete-branch "$BRANCH_NAME"
```

Or manually:

```bash
pkill -f "node.*vite" 2>/dev/null || true    # or "node.*webpack" for Mix
pkill -f "node.*webpack" 2>/dev/null || true
herd unlink $SITE_NAME
git worktree remove .worktrees/$SITE_NAME
git branch -d $BRANCH_NAME
```

---

## Option B: Transfer Changes to Main Directory

### B.1. Confirm Transfer

```
AskUserQuestion:
  question: "This will merge your worktree branch into the main directory. Continue?"
  header: "Confirm"
  options:
    - label: "Yes, transfer changes"
      description: "Merge the worktree branch and clean up"
    - label: "Cancel"
      description: "Go back without transferring"
```

### B.2. Stop Dev Process and Merge

```bash
pkill -f "node.*vite" 2>/dev/null || true
pkill -f "node.*webpack" 2>/dev/null || true

cd /path/to/main/project
git merge $BRANCH_NAME --no-commit --no-ff
```

If merge conflicts occur, list the conflicting files and ask the user how to proceed.

### B.3. Clean Up Worktree

```bash
bash scripts/cleanup-worktree.sh "$PROJECT_ROOT" "$SITE_NAME" --delete-branch "$BRANCH_NAME"
```

Or manually:

```bash
herd unlink $SITE_NAME
git worktree remove .worktrees/$SITE_NAME
git branch -D $BRANCH_NAME
```

**Tell the user:** "Changes are staged for commit. Review with `git status` and `git diff --cached`, then commit when ready."

---

## Option C: Abandon Changes

```bash
bash scripts/cleanup-worktree.sh "$PROJECT_ROOT" "$SITE_NAME" --delete-branch "$BRANCH_NAME"
```

Or manually:

```bash
pkill -f "node.*vite" 2>/dev/null || true
pkill -f "node.*webpack" 2>/dev/null || true
herd unlink $SITE_NAME
git worktree remove .worktrees/$SITE_NAME
git branch -D $BRANCH_NAME
```
