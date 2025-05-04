#!/bin/bash

# Define repository names and artifact names
TODO_REPO="TeleriRanger/todo-app"           # Replace with your GitHub username and repo name
# DASHBOARD_REPO="username/dashboard-repo" # Replace with your GitHub username and repo name
TODO_ARTIFACT="todo-build"               # Replace with the actual artifact name
STRETCH_HELPER_REPO="TeleriRanger/stretch-helper-app" 
STRETCH_HELPER_ARTIFACT="stretch-helper-build"
# DASHBOARD_ARTIFACT="dashboard-build"     # Replace with the actual artifact name
PUBLIC_DIR="./build"                    # The directory Cloudflare Pages uses to serve the app

rm -rf $PUBLIC_DIR
mkdir -p $PUBLIC_DIR/todo
# mkdir -p $PUBLIC_DIR/dashboard
cp ./_redirects $PUBLIC_DIR/_redirects

# Get the latest successful workflow run for each repository
TODO_RUN_ID=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
  "https://api.github.com/repos/$TODO_REPO/actions/runs?status=success&per_page=1" | \
  grep -o '"id": [0-9]*' | head -n 1 | awk '{print $2}')

# DASHBOARD_RUN_ID=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
#   "https://api.github.com/repos/$DASHBOARD_REPO/actions/runs?status=success&per_page=1" | jq -r '.workflow_runs[0].id')

# Fetch the artifact from todo-repo
TODO_ARTIFACT_URL="https://api.github.com/repos/$TODO_REPO/actions/runs/$TODO_RUN_ID/artifacts"
TODO_ARTIFACT_ID=$(curl -s -H "Authorization: token $GITHUB_TOKEN" $TODO_ARTIFACT_URL | \
  grep -o '"id": [0-9]*' | head -n 1 | awk '{print $2}')

# curl -H "Authorization: token $GITHUB_TOKEN" \
#   -L "https://api.github.com/repos/$TODO_REPO/actions/artifacts/$TODO_ARTIFACT_ID/contents" \
#   -o todo-artifact.zip

curl -s -L \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  -o todo-artifact.zip \
  https://api.github.com/repos/$TODO_REPO/actions/artifacts/$TODO_ARTIFACT_ID/zip

# Fetch the artifact from dashboard-repo
# DASHBOARD_ARTIFACT_URL="https://api.github.com/repos/$DASHBOARD_REPO/actions/runs/$DASHBOARD_RUN_ID/artifacts"
# DASHBOARD_ARTIFACT_ID=$(curl -s -H "Authorization: token $GITHUB_TOKEN" $DASHBOARD_ARTIFACT_URL | jq -r ".artifacts[] | select(.name==\"$DASHBOARD_ARTIFACT\") | .id")


# Unzip the downloaded artifacts into their respective directories
unzip -q todo-artifact.zip -d $PUBLIC_DIR/todo
# unzip -q dashboard-artifact.zip -d $PUBLIC_DIR/dashboard

# Clean up the artifact zip files
rm todo-artifact.zip
# rm dashboard-artifact.zip

mkdir -p $PUBLIC_DIR/stretch-helper

# Get the latest successful workflow run for stretch-helper-app
STRETCH_HELPER_RUN_ID=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
  "https://api.github.com/repos/$STRETCH_HELPER_REPO/actions/runs?status=success&per_page=1" | \
  grep -o '"id": [0-9]*' | head -n 1 | awk '{print $2}')

# Get artifact ID for stretch-helper
STRETCH_HELPER_ARTIFACT_URL="https://api.github.com/repos/$STRETCH_HELPER_REPO/actions/runs/$STRETCH_HELPER_RUN_ID/artifacts"
STRETCH_HELPER_ARTIFACT_ID=$(curl -s -H "Authorization: token $GITHUB_TOKEN" $STRETCH_HELPER_ARTIFACT_URL | \
  grep -o '"id": [0-9]*' | head -n 1 | awk '{print $2}')

# Download the artifact
curl -s -L \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  -o stretch-helper-artifact.zip \
  https://api.github.com/repos/$STRETCH_HELPER_REPO/actions/artifacts/$STRETCH_HELPER_ARTIFACT_ID/zip

# Unzip into the correct folder
unzip -q stretch-helper-artifact.zip -d $PUBLIC_DIR/stretch-helper

# Clean up
rm stretch-helper-artifact.zip


echo "Artifacts have been extracted and placed in the public directory."
