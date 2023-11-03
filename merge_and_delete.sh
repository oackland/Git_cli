#!/bin/bash

# Ensure current directory is a Git repository
if [ ! -d .git ]; then
    echo "This directory is not a Git repository. Exiting..."
    exit 1
fi

# Ensure GitHub CLI (`gh`) is installed
if ! command -v gh &> /dev/null; then
    echo "GitHub CLI (gh) is not installed. Please install it first."
    exit
fi

handle_secondary_repo() {
    local secondary_repo_url=$1
    local repo_identifier=$(echo $secondary_repo_url | sed -E 's|git@github.com:||g' | sed -E 's/.git//g')
    local sanitized_repo_identifier=$(echo $repo_identifier | tr '/:' '__')
    git remote add secondary_repo $secondary_repo_url
    git fetch secondary_repo
    git pull origin main  # Pull the latest changes from main
    git status  # Display status before merge
    
    read -p "Choose a merge method: (1) Merge into new directory (2) Merge into new branch and then into main: " merge_choice

    if [[ "$merge_choice" == "1" ]]; then
        local folder_name=$(echo $repo_identifier | sed -E 's|/|_|g')
        git subtree add --prefix=$folder_name secondary_repo/main
    elif [[ "$merge_choice" == "2" ]]; then
        local branch_name="merge_$sanitized_repo_identifier"
        git checkout -b $branch_name
        git merge secondary_repo/main --allow-unrelated-histories

        if [ $? -ne 0 ]; then
            echo "Merge failed. Please resolve conflicts manually."
            exit 1
        fi

        git checkout main
        git merge $branch_name

        if [ $? -ne 0 ]; then
            echo "Merge of $branch_name into main failed. Please resolve conflicts manually."
            exit 1
        fi
    else
        echo "Invalid choice. Exiting..."
        exit 1
    fi

    git status  # Display status after merge
    git add .  # Add all files, including newly merged ones
    git commit -m "Merged $repo_identifier"
    git push origin main  # Push the changes to main

    git remote remove secondary_repo

    read -p "Do you want to delete the secondary repository $secondary_repo_url? (yes/no): " response        
    if [[ "$response" == "yes" ]]; then
        gh repo delete $repo_identifier --confirm
        echo "Secondary repository $secondary_repo_url deleted."
    else
        echo "Skipped deleting the secondary repository $secondary_repo_url."
    fi
}

read -p "How many secondary repositories do you want to process? " num_repos

if ! [[ $num_repos =~ ^[0-9]+$ ]]; then
    echo "Please enter a valid number."
    exit 1
fi

for ((i=1; i<=$num_repos; i++)); do
    echo "Enter the URL of secondary repository #$i (e.g., git@github.com:username/repo.git):"
    read secondary_repo_url
    handle_secondary_repo $secondary_repo_url
done

echo "Script finished!"
