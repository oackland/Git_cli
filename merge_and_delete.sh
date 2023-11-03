#!/bin/bash

if [ -d .git ]; then
    echo "This directory is already a Git repository."
else
    echo ".git directory not found. Initializing a new Git repository..."
    git init
fi

# Ensure GitHub CLI (`gh`) is installed
if ! command -v gh &> /dev/null
then
    echo "GitHub CLI (gh) is not installed. Please install it first."
    exit
fi

# Ask for the secondary repository URL
echo "Enter the URL of the secondary repository (e.g., https://github.com/username/repo.git):"
read secondary_repo_url

# Extract repo details from URL for `gh` command
repo_identifier=$(echo $secondary_repo_url | sed -E 's|https://github.com/||g' | sed -E 's/.git//g')

# Navigate to the main repository (assumed to be the current directory)
current_dir=$(pwd)

# Add a remote for the secondary repository
git remote add secondary_repo $secondary_repo_url

# Fetch all the branches and commits from the secondary repository
git fetch secondary_repo

# Create and checkout a new branch
git checkout -b merge_secondary

# Merge the secondary repository's branch into this new branch
git merge secondary_repo/main --allow-unrelated-histories

echo "If there are any merge conflicts, resolve them and then commit the changes."
echo "After that, you can proceed to delete the secondary repository."

# Prompt for deletion
read -p "Do you want to delete the secondary repository? (yes/no): " response

if [[ "$response" == "yes" ]]; then
    gh repo delete $repo_identifier --confirm
    echo "Secondary repository deleted."
else
    echo "Skipped deleting the secondary repository."
fi

# Cleanup: Remove the secondary repo remote
git remote remove secondary_repo

echo "Script finished!"



