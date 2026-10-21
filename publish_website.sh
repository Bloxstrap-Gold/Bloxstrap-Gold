#!/usr/bin/env bash
# ==============================================================================
# Bloxstrap Gold — 1-Click GitHub Pages Publisher
# Publishes the website/ directory directly to the gh-pages branch of your repo
# ==============================================================================

set -e

REPO_URL="$1"

if [ -z "$REPO_URL" ]; then
  echo "❌ Error: Please provide your GitHub repository URL."
  echo "Usage: ./publish_website.sh https://github.com/<USERNAME>/<REPO_NAME>.git"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WEBSITE_DIR="$SCRIPT_DIR/website"

if [ ! -d "$WEBSITE_DIR" ]; then
  echo "❌ Error: website/ directory not found at $WEBSITE_DIR"
  exit 1
fi

TEMP_DIR=$(mktemp -d)
echo "📦 Preparing website files for deployment in $TEMP_DIR..."

cp -R "$WEBSITE_DIR/"* "$TEMP_DIR/"
cp "$WEBSITE_DIR/.nojekyll" "$TEMP_DIR/" 2>/dev/null || touch "$TEMP_DIR/.nojekyll"

cd "$TEMP_DIR"
git init -b gh-pages
git config user.name "Bloxstrap Gold Publisher"
git config user.email "deploy@bloxstrap-gold.local"
git add .
git commit -m "Deploy Bloxstrap Gold to GitHub Pages"

echo "🚀 Pushing to $REPO_URL (gh-pages branch)..."
git push --force "$REPO_URL" gh-pages

rm -rf "$TEMP_DIR"

echo ""
echo "✅ SUCCESS! Website pushed to gh-pages branch."
echo "👉 Now go to your GitHub repo Settings -> Pages and set Source to 'Deploy from a branch' -> 'gh-pages'."
