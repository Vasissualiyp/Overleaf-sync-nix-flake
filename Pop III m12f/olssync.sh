#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status (except for handled ones)
set -e

echo "=== Stashing local changes and pulling from Overleaf ==="
git stash

# Run ols -r (wrapped to allow stash re-application even if ols fails)
if ! ols -r; then
    echo "Error: 'ols -r' failed. Restoring stash and aborting."
    git stash pop
    exit 1
fi

echo "=== Syncing ignore files and applying local changes ==="
cp .gitignore .olignore

# Temporarily disable 'set -e' to handle the potential merge conflict
set +e
git stash apply
STASH_STATUS=$?
set -e

cp .olignore .gitignore

if [ $STASH_STATUS -ne 0 ]; then
    echo -e "\n\033[0;31m[CONFLICT] Merge conflicts detected during git stash apply!\033[0m"
    echo "Opening a temporary subshell so you can fix them."
    echo "Instructions:"
    echo "  1. Open the conflicting files and resolve the markers (<<<<<<<, =======, >>>>>>>)."
    echo "  2. Use 'git add <file>' on resolved files."
    echo "  3. Type 'exit' or hit Ctrl+D when you are done to resume the script."
    
    # Launch an interactive shell in the current directory for the user to fix issues
    ${SHELL:-bash}
    
    echo -e "\n=== Resuming script after manual conflict resolution ==="
    # Drop the stash manually since 'stash apply' won't do it if there were conflicts
    git stash drop
fi

echo "=== Committing and pushing to Overleaf ==="
git add -u
git commit -m "Changes from $(date '+%Y-%m-%d %H:%M:%S')"
ols -l

echo "=== Sync complete ==="
