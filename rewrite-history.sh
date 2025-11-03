#!/bin/bash

# Script to rewrite git history and convert merge commits to squash commits
# WARNING: This script will rewrite git history. Make sure you have backups!
# 
# This script will:
# 1. Create a new branch with rewritten history
# 2. Convert merge commits from PRs #1 and #3 into squashed commits
# 3. Preserve all changes while creating a linear history

set -e

# Ensure git is configured
if ! git config user.email > /dev/null 2>&1; then
    echo "Git user not configured. Setting default identity for this operation..."
    git config user.name "Git History Rewriter"
    git config user.email "noreply@localhost"
fi

echo "=== Git History Rewrite Script ==="
echo "This script will rewrite git history to convert merge commits to squash commits"
echo ""
echo "WARNING: This is a destructive operation!"
echo "Make sure you have:"
echo "  1. Backed up your repository"
echo "  2. Coordinated with all collaborators"
echo "  3. Understood the implications"
echo ""
read -p "Do you want to continue? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Aborted."
    exit 1
fi

echo ""
echo "Step 1: Creating rewritten-history branch from commit before first merge..."
git checkout -b rewritten-history 726230d

echo ""
echo "Step 2: Squashing first merge (PR #1: Ofelia orchestrator)..."
git merge --squash 5c30c5c
git commit -m "Add Ofelia orchestrator for automated Borgmatic backups and MCASelector chunk cleanup (#1)

* Add Ofelia orchestrator with Borgmatic and MCASelector integration
* Fix schedule times and grammar in configuration files
* Add architecture documentation with system diagrams
* Add getting started guide for orchestrator

Co-authored-by: AbbyNode <AbbyNode@users.noreply.github.com>"

echo ""
echo "Step 3: Squashing second merge (PR #3: Borgmatic passphrase)..."
git merge --squash 19667b0

# Check if there are merge conflicts
if git diff --cached --quiet; then
    echo "No changes to commit (possible conflict or already applied)"
    git reset --hard
else
    # Resolve any merge conflicts in docker-compose.yml
    if [ -f "docker-compose.yml" ] && grep -q "<<<<<<< HEAD" docker-compose.yml; then
        echo "Resolving merge conflict in docker-compose.yml..."
        # Auto-resolve by keeping the version with env_file added
        sed -i '/<<<<<<< HEAD/,/=======/{//!d}; /=======/d; />>>>>>> 19667b0/d' docker-compose.yml
        git add docker-compose.yml
    fi
    
    git commit -m "Merge pull request #3 from AbbyNode/copilot/fix-borgmatic-repository-issue

Add BORG_PASSPHRASE environment variable for borgmatic repository initialization"
fi

echo ""
echo "Step 4: Cherry-picking final commit..."
git cherry-pick a5d7c42

echo ""
echo "Step 5: Verifying the rewritten history..."
echo ""
echo "Checking for merge commits in rewritten history:"
MERGE_COUNT=$(git log --merges --oneline rewritten-history | wc -l)
if [ "$MERGE_COUNT" -eq 0 ]; then
    echo "✓ No merge commits found - history successfully rewritten!"
else
    echo "✗ Warning: Found $MERGE_COUNT merge commits"
fi

echo ""
echo "Comparing final state with main branch:"
git diff main rewritten-history > /tmp/history-diff.txt
if [ -s /tmp/history-diff.txt ]; then
    echo "✗ Warning: Final states differ!"
    echo "Differences saved to /tmp/history-diff.txt"
else
    echo "✓ Final states are identical - no data lost!"
fi

echo ""
echo "=== Rewrite Complete ==="
echo ""
echo "New branch 'rewritten-history' has been created with:"
echo "  - No merge commits"
echo "  - All changes preserved"
echo "  - Linear history"
echo ""
echo "To apply this to your main branch:"
echo "  1. Review the new history: git log --graph --oneline rewritten-history"
echo "  2. Backup current main: git branch main-backup main"
echo "  3. Update main: git checkout main && git reset --hard rewritten-history"
echo "  4. Force push: git push --force-with-lease origin main"
echo ""
echo "NOTE: Force pushing will rewrite public history. Coordinate with all collaborators!"
