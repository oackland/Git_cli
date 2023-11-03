#!/bin/bash

# Check for .git directory
if [ -d .git ]; then
    echo "This directory is already a Git repository."
else
    echo ".git directory not found. Initializing a new Git repository..."
    git init
fi

# Ensure GitHub CLI (`gh`) is installed
if ! command -v gh &> /dev/null; then
    echo "GitHub CLI (gh) is not installed. Please install it first."
    exit
fi

# Function to handle merging and deleting a single secondary repo
handle_secondary_repo() {
    local secondary_repo_url=$1

    # Extract repo details from URL for `gh` command
    local repo_identifier=$(echo $secondary_repo_url | sed -E 's|https://github.com/||g' | sed -E 's/.git//g' | sed -E 's|:|/|g')
    local sanitized_repo_identifier=$(echo $repo_identifier | tr '/:' '__')

    # Add a remote for the secondary repository
    git remote add secondary_repo $secondary_repo_url

    # Fetch all the branches and commits from the secondary repository
    git fetch secondary_repo

    # Create and checkout a new branch named based on the secondary repo
    local branch_name="merge_$sanitized_repo_identifier"
    git checkout -b $branch_name

    # Merge the secondary repository's branch into this new branch
    git merge secondary_repo/main --allow-unrelated-histories

    # Check if the merge was successful
    if [ $? -eq 0 ]; then
        echo "Merge successful."
        git add .
        git commit -m "Merged $repo_identifier into $branch_name"
        git add .
        git push -u origin $branch_name
    else
        echo "Merge failed. Please resolve conflicts manually."
        exit 1
    fi

    # Cleanup: Remove the secondary repo remote and (optionally) the local branch
    git remote remove secondary_repo
    # Uncomment the next line if you wish to delete the local branch after merge
    # git branch -d $branch_name

    # Prompt for deletion
    read -p "Do you want to delete the secondary repository $secondary_repo_url? (yes/no): " response
    if [[ "$response" == "yes" ]]; then
        gh repo delete $repo_identifier --confirm
        echo "Secondary repository $secondary_repo_url deleted."
    else
        echo "Skipped deleting the secondary repository $secondary_repo_url."
    fi
}

# Main script execution
read -p "How many secondary repositories do you want to process? " num_repos
for ((i=1; i<=$num_repos; i++)); do
    echo "Enter the URL of secondary repository #$i (e.g., https://github.com/username/repo.git):"
    read secondary_repo_url
    handle_secondary_repo $secondary_repo_url
done

echo "Script finished!"
