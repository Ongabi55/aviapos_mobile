# AviaPOS Frontend - Git Workflow Guide

## Current Situation

Your repository exists but **had no commits yet**. The source code wasn't backed up in git, so it's been lost. However, we can restart with a proper workflow.

---

## 1. How to Know Where You Left Off

### A. Check git status (Daily)
```bash
cd /Users/markmunuhe/StudioProjects/aviapos_mobile
git status
```
This shows:
- **Untracked files** (new files you created)
- **Modified files** (files you changed)
- **Current branch** you're on
- **Commits ahead/behind** remote

### B. Check commit history
```bash
git log --oneline -10
```
Shows your last 10 commits with messages

### C. See what changed in specific commit
```bash
git show <commit-hash>
git diff main..your-branch
```

---

## 2. How to Continue From Where You Left Off

### Step 1: Create a feature branch (NOT on main)
```bash
git checkout -b feature/frontend-structure
```

### Step 2: Work on your features
- Write code
- Test locally
- Save frequently

### Step 3: Check what you changed
```bash
git status                    # See changed files
git diff                      # See line-by-line changes
git add -p                    # Selectively stage changes
```

### Step 4: Make meaningful commits (HOURLY or at END OF DAY)
```bash
git add .                                              # Stage all changes
git commit -m "feat: add presentation layer structure" # Commit with message
```

---

## 3. How to Save Work at End of Day (IMPORTANT!)

### Quick Daily Checkpoint - 3 COMMANDS:

```bash
# 1. Stage all changes
git add .

# 2. Create a checkpoint commit (ALWAYS do this!)
git commit -m "WIP: Daily checkpoint - [describe what you worked on]"

# 3. Push to remote (so it's backed up on GitHub)
git push origin feature/frontend-structure
```

### Example Commit Messages by Task:

```bash
# Starting new feature
git commit -m "feat: initialize domain layer for Sales capability"

# Making progress
git commit -m "feat: add Product entity model with validation"

# Bug fixes
git commit -m "fix: correct Product constructor null safety"

# Documentation
git commit -m "docs: add architectural decision for offline-first"

# Work in progress (for end of day)
git commit -m "WIP: partial implementation of inventory sync logic"
```

---

## 4. Proper Git Workflow for Your Team

### Branch Strategy (Most Important!)

**NEVER commit directly to `main`**

```bash
# 1. Always create a feature branch
git checkout -b feature/sales-domain

# 2. Work, commit frequently
git add .
git commit -m "feat: add Sale entity"

git add .
git commit -m "feat: add SaleRepository interface"

git add .
git commit -m "feat: implement SQLite SaleRepository"

# 3. Push branch to GitHub
git push origin feature/sales-domain

# 4. Create Pull Request (PR) on GitHub for review by co-founder
# 5. After approval, merge to main
```

---

## 5. How to Sync with Co-founder's Work (RailOne)

Since your co-founder is working on RailOne, coordinate like this:

```bash
# Fetch latest from GitHub
git fetch origin

# See what your co-founder pushed
git log origin/main --oneline -5

# Merge latest main into your feature branch
git merge origin/main

# Handle any conflicts (discuss with co-founder)
# Then push resolved version
git push origin feature/frontend-structure
```

---

## 6. Emergency Recovery - If You Lose Work Again

### BEFORE losing work, do this:

```bash
# See all recent commits (even deleted)
git reflog

# Restore a deleted branch
git checkout -b recovered-branch <commit-hash>
```

### Make it IMPOSSIBLE to lose work:

```bash
# Set up auto-push on commit (add to .git/hooks/post-commit)
# OR simply push every time:
git push origin feature/frontend-structure
```

---

## 7. Your Daily Workflow (COPY THIS!)

### Morning - Resume work:
```bash
git status                  # See what you were working on
git log --oneline -5        # Refresh memory on recent commits
```

### During day - Save frequently:
```bash
# Every hour or after completing a task:
git add .
git commit -m "feat: description of what you just did"
git push origin feature/frontend-structure
```

### End of day - ALWAYS commit and push:
```bash
git add .
git commit -m "WIP: Daily checkpoint - [describe current state]"
git push origin feature/frontend-structure
```

### Next day - Pick up where you left off:
```bash
git log --oneline -3     # See what you did yesterday
git status               # See incomplete work
# Continue working...
```

---

## 8. Common Git Commands Reference

```bash
# See all branches
git branch -a

# Switch branches
git checkout feature/sales

# Create and switch to new branch
git checkout -b feature/inventory

# Undo uncommitted changes
git restore <filename>
git restore .              # Undo all

# Delete local branch
git branch -d feature/old

# Delete remote branch
git push origin --delete feature/old

# Combine last 3 commits into one
git rebase -i HEAD~3

# See who changed what
git blame <filename>

# Search commits by message
git log --grep="sale"

# Pretty log visualization
git log --oneline --graph --all
```

---

## 9. GitHub Setup (For Team Collaboration)

### Protect `main` branch on GitHub:

1. Go to GitHub repo → Settings → Branches
2. Add rule for `main`
3. Require pull request reviews (from co-founder)
4. Enable "Dismiss stale PR approvals"
5. Check "Require status checks to pass"

This ensures:
- ✅ No direct commits to `main`
- ✅ Co-founder reviews changes
- ✅ Automated tests pass first

---

## 10. Architecture Alignment - Commit Examples

Based on your frontend blueprint:

```bash
# Presentation Layer
git commit -m "feat: add ProductCard widget for presentation layer"

# Feature Layer
git commit -m "feat: implement CreateProduct feature with state management"

# Domain Layer
git commit -m "feat: add Product entity and Business Rules"

# Data Layer
git commit -m "feat: implement ProductRepository with SQLite backend"

# Service Layer
git commit -m "feat: add SyncService for offline-first synchronization"

# Core Layer
git commit -m "feat: add RoutingConfiguration for app navigation"
```

---

## Quick Start - Getting Started TODAY

```bash
# 1. Initialize fresh
cd /Users/markmunuhe/StudioProjects/aviapos_mobile

# 2. Create initial commit
git add .
git commit -m "Initial: Flutter project structure"

# 3. Create your feature branch
git checkout -b feature/frontend-structure

# 4. Work on your code...

# 5. Commit at end of day
git add .
git commit -m "WIP: Day 1 checkpoint - foundation setup"
git push origin feature/frontend-structure
```

---

## Remember:

🔑 **KEY RULES:**

1. **ALWAYS commit at end of day** - Even if work is incomplete
2. **ALWAYS push to GitHub** - So it's backed up
3. **Use descriptive messages** - So you remember what you did
4. **Never commit directly to main** - Always use feature branches
5. **Sync with co-founder regularly** - Coordinate on GitHub PRs

---

## Questions?

When you next work on the frontend:
1. Run `git status` to see where you left off
2. Read the last 5 commits with `git log --oneline -5`
3. Continue on your feature branch
4. Push at the end of your session

This ensures 100% of your work is saved and recoverable! 🎉

