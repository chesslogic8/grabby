#!/bin/bash

USERNAME="aileda"
PER_PAGE=100
PAGE=1

echo "Downloading all repositories for $USERNAME as ZIP files..."

while :; do
  # Get the full repo objects so we can extract name + default_branch
  RESPONSE=$(curl -s "https://api.github.com/users/$USERNAME/repos?per_page=$PER_PAGE&page=$PAGE")

  # Extract repo names and default branches
  REPOS=$(echo "$RESPONSE" | grep -oP '"name": "\K[^"]+')
  DEFAULT_BRANCHES=$(echo "$RESPONSE" | grep -oP '"default_branch": "\K[^"]+')

  # Break if no more repositories
  if [ -z "$REPOS" ]; then
    break
  fi

  # Convert to arrays (one entry per repo)
  mapfile -t REPO_ARRAY <<< "$REPOS"
  mapfile -t BRANCH_ARRAY <<< "$DEFAULT_BRANCHES"

  for i in "${!REPO_ARRAY[@]}"; do
    REPO="${REPO_ARRAY[i]}"
    BRANCH="${BRANCH_ARRAY[i]}"

    ZIP_URL="https://github.com/$USERNAME/$REPO/archive/refs/heads/$BRANCH.zip"
    ZIP_FILE="${REPO}-${BRANCH}.zip"

    echo "Downloading $REPO ($BRANCH) → $ZIP_FILE"
    curl -L -o "$ZIP_FILE" "$ZIP_URL"
  done

  PAGE=$((PAGE + 1))
done

echo "All repositories downloaded as ZIP files."
