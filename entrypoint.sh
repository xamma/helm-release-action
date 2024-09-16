#!/bin/bash

set -e

# Check if Helm is working and installed
if ! command -v helm &> /dev/null; then
    echo "Helm is not installed. Exiting."
    exit 1
fi

# Get inputs from workflow
CHART_PATH="${{ inputs.chart-path }}"
CHART_NAME="${{ inputs.chart-name }}"
GITHUB_TOKEN="${{ inputs.github-token }}"
HELM_REPO="${{ inputs.helm-repo }}"

# BUild chart URL
HELM_CHARTS_REPO="$HELM_REPO"
CHART_URL="https://$HELM_REPO.git"

# Packaging the chart
echo "Packaging Helm chart at $CHART_PATH"
helm package "$CHART_PATH" --destination charts/

# Checkout the remote Helm charts repo
echo "Checking out Helm charts repo: $HELM_CHARTS_REPO"
git clone "https://$GITHUB_TOKEN@github.com/$HELM_CHARTS_REPO.git" helm-charts
cd helm-charts

# Copy the built package to the remote repo
echo "Moving the packaged chart to helm-charts"
mv ../charts/"$CHART_NAME"-*.tgz docs/

# Helm repo index
echo "Helm repo index..."
helm repo index . --url "$CHART_URL"

# Commit and push
git config --local user.email "action@github.com"
git config --local user.name "GitHub Action"
git add .
git commit -m "Update Helm charts found at $CHART_URL with new release: $CHART_NAME"

# Set up GitHub authentication using the token
git remote set-url origin "https://$GITHUB_TOKEN@github.com/$HELM_REPO.git"

# Push to remote helm repository
git push origin master