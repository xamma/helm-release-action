#!/bin/bash

set -e

# Check if Helm working
if ! command -v helm &> /dev/null; then
    echo "Helm is not installed. Exiting."
    exit 1
fi

# Get inputs from workflow args
CHART_PATH="$1"        # Path to the chart directory where this workflow runs
GITHUB_TOKEN="$2"      # PAT
HELM_REPO="$3"         # user/name format
HELM_REPO_FOLDER="$4"  # in which folder to put the release
BRANCH_NAME="$5"       # Branch name of Hlem repo e.g. main, master

echo "Chart Path: $CHART_PATH"
echo "Helm Repo: $HELM_REPO"
echo "Helm Repo Folder: $HELM_REPO_FOLDER"

# Build chart URL
CHART_URL="https://$HELM_REPO.git"

# Packaging the chart
echo "Packaging Helm chart at $CHART_PATH"
helm package "$CHART_PATH" --destination ./charts/

# Store the packaged file name
PACKAGE_NAME=$(ls ./charts | grep -E '.*\.tgz$')

if [ -z "$PACKAGE_NAME" ]; then
    echo "No packaged chart found. Exiting."
    exit 1
fi

echo "Packaged chart: $PACKAGE_NAME"

# Checkout the remote Helm charts repo
echo "Checking out Helm charts repo: $HELM_REPO"
git clone "https://$GITHUB_TOKEN@github.com/$HELM_REPO.git" helm-charts
cd helm-charts

# Move the packagege to the right folder in the helm-chart repo
echo "Moving the packaged chart to $HELM_REPO_FOLDER"
mv "../charts/$PACKAGE_NAME" $HELM_REPO_FOLDER

# Helm repo index
echo "Updating Helm repo index..."
helm repo index $HELM_REPO_FOLDER --url "$CHART_URL"

# Commit and push changes
git config --local user.email "action@github.com"
git config --local user.name "GitHub Action"
git add .
if git commit -m "Updating Helm charts at $CHART_URL"; then
    echo "Changes committed successfully."
else
    echo "No changes to commit. Exiting."
    exit 0
fi

# Using PAT for the remote push
git remote set-url origin "https://$GITHUB_TOKEN@github.com/$HELM_REPO.git"

if git push origin $BRANCH_NAME; then
    echo "Successfully pushed to the Helm repository."
else
    echo "Failed to push to the Helm repository. Exiting."
    exit 1
fi
