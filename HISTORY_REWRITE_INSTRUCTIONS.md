# Git History Rewrite Instructions

## Overview

This document provides instructions for rewriting the git history of this repository to convert merge commits into squash commits, creating a linear history.

## Current State

The repository currently has **2 merge commits** in its history:

1. **Commit `b2982c1`**: Merge pull request #1 (Ofelia orchestrator)
   - Merged 8 commits from the feature branch
   
2. **Commit `746c8d9`**: Merge pull request #3 (Borgmatic passphrase)
   - Merged 4 commits from the feature branch

## Goal

Convert these merge commits into regular squashed commits, creating a linear history while preserving all changes.

## Solution

An automated script (`rewrite-history.sh`) is provided to rewrite the git history and create a linear commit history without merge commits.

## How to Apply the Rewritten History

### Prerequisites

⚠️ **WARNING**: This operation will rewrite public git history!

Before proceeding:
1. **Backup your repository**
2. **Coordinate with all collaborators** - they will need to re-clone or reset their local repositories
3. **Understand the implications** - this cannot be easily undone once pushed

### Steps

#### Option 1: Automated Script (Recommended)

The provided `rewrite-history.sh` script automates the entire process:

```bash
chmod +x rewrite-history.sh
./rewrite-history.sh
```

The script will:
- Create a new branch `rewritten-history` with squashed commits
- Verify that no merge commits exist in the new history
- Confirm that the final state matches the original (no data loss)
- Provide instructions for applying the changes to your main branch

After the script completes successfully, apply the changes to main:

```bash
# Backup your current main branch
git branch main-backup main

# Replace main with the rewritten history
git checkout main
git reset --hard rewritten-history

# Force push to GitHub
git push --force-with-lease origin main
```

#### Option 2: Manual Steps

If you prefer to perform the steps manually:

1. **Backup your current main branch**:
   ```bash
   git branch main-backup main
   ```

2. **Create a new branch from before the first merge**:
   ```bash
   git checkout -b rewritten-history 726230d
   ```

3. **Squash the first merge (PR #1)**:
   ```bash
   git merge --squash 5c30c5c
   git commit -m "Add Ofelia orchestrator for automated Borgmatic backups and MCASelector chunk cleanup (#1)

* Add Ofelia orchestrator with Borgmatic and MCASelector integration
* Fix schedule times and grammar in configuration files
* Add architecture documentation with system diagrams
* Add getting started guide for orchestrator

Co-authored-by: AbbyNode <AbbyNode@users.noreply.github.com>"
   ```

4. **Squash the second merge (PR #3)**:
   ```bash
   git merge --squash 19667b0
   # Resolve any merge conflicts in docker-compose.yml if needed
   git add .
   git commit -m "Merge pull request #3 from AbbyNode/copilot/fix-borgmatic-repository-issue

Add BORG_PASSPHRASE environment variable for borgmatic repository initialization"
   ```

5. **Cherry-pick the final commit**:
   ```bash
   git cherry-pick a5d7c42
   ```

6. **Verify the rewritten history**:
   ```bash
   # Check for merge commits (should return empty)
   git log --merges --oneline rewritten-history
   
   # Verify final state matches (should return no output)
   git diff main rewritten-history
   ```

7. **Apply to main branch**:
   ```bash
   git checkout main
   git reset --hard rewritten-history
   ```

8. **Force push to GitHub**:
   ```bash
   git push --force-with-lease origin main
   ```

### After Rewriting History

All collaborators will need to update their local repositories:

```bash
# Backup any local changes first!
git fetch origin
git checkout main
git reset --hard origin/main
```

## Technical Details

### What Changed

**Before**:
```
* a5d7c42 Add support for CurseForge modpack URLs (#5)
*   746c8d9 Merge pull request #3  (MERGE COMMIT)
|\  
| * 19667b0 Remove redundant environment section
| * 07a9f62 Improve default passphrase placeholder
| * 74a111a Fix borgmatic passphrase issue
| * 0cb8fdc Initial plan
|/  
*   b2982c1 Add Ofelia orchestrator (#1)  (MERGE COMMIT)
|\  
| * 5c30c5c Clean up docs and configs
| * 79c47f2 Address PR feedback
| * ... (6 more commits)
|/  
* 726230d mcaselector filter doc
```

**After**:
```
* 902f0ce Add support for CurseForge modpack URLs (#5)
* a9cafd0 Merge pull request #3 (SQUASHED COMMIT)
* 5cc1e58 Add Ofelia orchestrator (#1) (SQUASHED COMMIT)
* 726230d mcaselector filter doc
```

### Commits Breakdown

Each former merge commit is now a single squashed commit containing all the changes from its branch:

1. **5cc1e58**: Squashed all 8 commits from PR #1 into one
   - Contains all Ofelia orchestrator changes
   - Preserves co-author attribution
   
2. **a9cafd0**: Squashed all 4 commits from PR #3 into one
   - Contains all Borgmatic passphrase changes
   
3. **902f0ce**: Cherry-picked the final commit
   - CurseForge modpack URL support

## Questions?

If you have questions or concerns about this process, please review the git history carefully before proceeding. The rewritten history is available for inspection on the `rewritten-history` branch.
