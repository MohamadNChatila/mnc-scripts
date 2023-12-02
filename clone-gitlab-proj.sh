#!/bin/bash

PRIVATE_TOKEN="<INSERT_YOUR_PRIVATE_TOKEN>"
GROUP_ID="<INSERT_GROUP_ID>"
GITLAB_URL="<INSERT_URL>"
API_ENDPOINT="/api/v4/groups/$GROUP_ID/projects"

#To be Updated: Fetch the number of pages automatically
# Loop through pages
for page in {1..4}; do
    # Fetch projects for the current page
    response=$(curl --header "PRIVATE-TOKEN: $PRIVATE_TOKEN" "$GITLAB_URL$API_ENDPOINT?page=$page&recursive=true")

    # Extract project names and clone repositories
    for project_url in $(echo "$response" | jq -r '.[] | .ssh_url_to_repo'); do
        git clone "$project_url"
        # To be updated: You might be asked for the passphrase everytime, should add a workaround here to pass the passphrase once
    done
done

# Getting all the available branches and skipping RM branches
# Access all directories in the current path - ignoring "." directory
directories=($(find . -maxdepth 1 -type d -not -name '.' -exec basename {} \;))

# Iterate through directories
for dir in "${directories[@]}"; do
    # Move to the directory
    cd "$dir" || continue
    # Print the name of the directory
    echo "Current directory: $dir"

    # Iterate through branches
    for branch in $(git branch -r | grep -vE "HEAD|main"); do
        # You can modify the condition below to skip any unneeded set of branches. In this case branches that start with RM- are ignored.
        if [[ $branch == origin/RM-* ]]; then
             echo "$branch skipped"
            continue
        fi
        git checkout --track ${branch}
        echo "$branch checked out"
    done

    # Move back to the original directory
    cd ..
done
