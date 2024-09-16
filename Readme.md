# Helm Chart Release GitHub Action

This GitHub Action packages a Helm chart and uploads it to a specified Helm repository.  

***The repos need to be accessible from the same PAT otherwise it wont work.***  

## Inputs

- `chart-path`: Path to the Helm chart directory **(required)**.
- `chart-name`: Name of the Helm chart **(required)**.
- `github-token`: GitHub token for pushing the Helm chart to the repository **(required)**.
- `helm-repo`: The GitHub repository where Helm charts are stored **(required)**.

## Example Usage

```yaml
name: Create Helm Release

on:
  workflow_dispatch:
  push:
    branches:
      - master

jobs:
  create-release:
    runs-on: ubuntu-latest

    steps:
      # Step 1: Checkout the repository with Helm manifests
      - name: Checkout Helm Manifests
        uses: actions/checkout@v4

      # Step 2: Use Custom Helm Chart Release Action
      - name: Create Helm Chart Release
        uses: xamma/helm-release-action@v1.0.0
        with:
          chart-path: './charts/my-chart'  # Path to your chart directory where your helmfiles are
          chart-name: 'my-chart'  # Name of the Helm chart to build
          github-token: ${{ secrets.MY_PAT }}  # GitHub PAT token for authentication
          helm-repo: '<your-username>/<helm-charts-repo>'  # Repo for Helm charts (format: user/repo)
```