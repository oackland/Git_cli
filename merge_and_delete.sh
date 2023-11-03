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
    local repo_identifier=$(echo $secondary_repo_url | sed -E 's|https://github.com/||g' | sed -E 's/.git//g')
    local sanitized_repo_identifier=$(echo $repo_identifier | tr '/:' '__')

    # Add a remote for the secondary repository
    git remote add secondary_repo $secondary_repo_url

    # Fetch all the branches and commits from the secondary repository
    git fetch secondary_repo

    read -p "Choose a merge method: (1) Merge into new directory (2) Merge into new branch and then into main: " merge_choice

    if [[ "$merge_choice" == "1" ]]; then
        # Create a folder name based on the secondary repo
        local folder_name=$(echo $repo_identifier | sed -E 's|/|_|g')

        # Use git subtree to add content of secondary repo into a new folder
        git subtree add --prefix=$folder_name secondary_repo/main

        # Commit the changes
        git add .
        git commit -m "Added $repo_identifier to folder $folder_name"
        git add .
        # Push the changes to the primary repo
        git push origin main
    elif [[ "$merge_choice" == "2" ]]; then
        # Create and checkout a new branch named based on the secondary repo
        local branch_name="merge_$sanitized_repo_identifier"
        git checkout -b $branch_name

        # Merge the secondary repository's branch into this new branch
        git merge secondary_repo/main --allow-unrelated-histories

        if [ $? -eq 0 ]; then
            echo "Merge successful."
            git commit -m "Merged $repo_identifier into $branch_name"
            git push origin $branch_name

            # Checkout the primary branch (assuming it's named "main")
            git checkout main

            # Merge the branch with content from the secondary repository into the primary branch
            git merge $branch_name
            if [ $? -eq 0 ]; then
                echo "Merged $branch_name into main successfully."
            else
                echo "Merge of $branch_name into main failed. Please resolve conflicts manually."
                exit 1
            fi

            # Push the merged changes to the primary repository
            git push origin main
        else
            echo "Merge failed. Please resolve conflicts manually."
            exit 1
        fi
    else
        echo "Invalid choice. Exiting..."
        exit 1
    fi

    # Cleanup: Remove the secondary repo remote and (optionally) the local branch
    git remote remove secondary_repo

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
