#!/bin/bash

<<<<<<< HEAD
# Ensure current directory is a Git repository
if [ ! -d .git ]; then
    echo "This directory is not a Git repository. Exiting..."
    exit 1
fi
=======
# Function to prompt the user before proceeding
start_prompt() {
    read -p "This script will merge secondary repositories into the main one. Continue? (yes/no): " response
    if [[ "$response" != "" ]]; then
        exit 1
    fi
}

# Ensure the current directory is a Git repository
check_git_directory() {
    if [ ! -d .git ]; then
        echo "This directory is not a Git repository. Exiting."
        exit 1
    fi
}
>>>>>>> merge_test

# Ensure GitHub CLI (`gh`) is installed
check_github_cli() {
    if ! command -v gh &> /dev/null; then
        echo "GitHub CLI (gh) is not installed. Please install it first."
        exit 1
    fi
}

handle_secondary_repo() {
    local secondary_repo_url=$1
<<<<<<< HEAD
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

=======
    local repo_name=$(basename $secondary_repo_url .git)  # Extract repo name from URL

    # Remove existing secondary_repo remote if it exists
    git remote | grep -q secondary_repo && git remote remove secondary_repo

    # Add secondary repo as a remote and fetch its content
    git remote add secondary_repo $secondary_repo_url
    git fetch secondary_repo

    # Create a new directory for the secondary repository and read its content into the directory
    mkdir $repo_name
    git read-tree --prefix=$repo_name/ -u secondary_repo/main

    # Commit the changes
    git commit -m "Merged $repo_name into its own directory"

    # Cleanup
    git remote remove secondary_repo

    # Prompt for deletion of the secondary repo
>>>>>>> merge_test
    read -p "Do you want to delete the secondary repository $secondary_repo_url? (yes/no): " response        
    if [[ "$response" == "yes" ]]; then
        gh repo delete $repo_name --confirm
    fi
}

<<<<<<< HEAD
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
=======
# Main script execution
main() {
    start_prompt
    check_git_directory
    check_github_cli

    read -p "Enter the number of secondary repositories to merge: " num_repos
    if ! [[ $num_repos =~ ^[0-9]+$ ]]; then
        echo "Invalid input. Exiting."
        exit 1
    fi
>>>>>>> merge_test

    for ((i=1; i<=$num_repos; i++)); do
        echo "Enter the URL of secondary repository #$i:"
        read secondary_repo_url
        handle_secondary_repo $secondary_repo_url
    done

    echo "All done!"
}

main
