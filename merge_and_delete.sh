#!/bin/bash

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

# Ensure GitHub CLI (`gh`) is installed
check_github_cli() {
    if ! command -v gh &> /dev/null; then
        echo "GitHub CLI (gh) is not installed. Please install it first."
        exit 1
    fi
}

# Function to handle merging and deleting a single secondary repo
handle_secondary_repo() {
    local secondary_repo_url=$1
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
    read -p "Do you want to delete the secondary repository $secondary_repo_url? (yes/no): " response        
    if [[ "$response" == "yes" ]]; then
        gh repo delete $repo_name --confirm
    fi
}

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

    for ((i=1; i<=$num_repos; i++)); do
        echo "Enter the URL of secondary repository #$i:"
        read secondary_repo_url
        handle_secondary_repo $secondary_repo_url
    done

    echo "All done!"
}

main
