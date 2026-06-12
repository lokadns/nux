#!/bin/bash

# Git directory 
DIR_GIT="[your-working-git-directory]"
total_added=0

# Move to GIT_DIR 
cd "$DIR_GIT" || exit 1
git pull origin main #you can disable it if you are sure there are no changes on Github.

# Git status --porcelain
GIT_STATUS=$(git status --porcelain)

# 1. New file or untracked 
NEW_FILES=$(echo "$GIT_STATUS" | grep "^??")

if [ -n "$NEW_FILES" ]; then
    # Extract file name and add it 
    echo "$NEW_FILES" | awk '{print $2}' | while read -r file; do
        if [ -f "$file" ]; then
            git add "$file" -q
            ((total_added++))
            echo "-> [Add new file] $file"
        fi
    done
fi

# 2. Modified file 
MODIFIED_FILES=$(echo "$GIT_STATUS" | grep "^.M")

if [ -n "$MODIFIED_FILES" ]; then
    # Extract file name and add it 
    echo "$MODIFIED_FILES" | awk '{print $2}' | while read -r file; do
        if [ -f "$file" ]; then
            git add "$file" -q
            ((total_added++))
            echo "-> [Add modified file] $file"
        fi
    done
fi

# Eksekusi commit dan push HANYA jika ada file yang ditambahkan
if [ "$total_added" -gt 0 ]; then 
    git commit -q -m "Added $total_added file(s) into git"
    git push -q origin main
    echo "Successfully updated GitHub."
else
    echo "No data changes."
fi
