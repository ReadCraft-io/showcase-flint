#!/bin/bash
set -e

# GitHub Pages Deployment Script
# Builds Sphinx docs and deploys to gh-pages branch

echo "🔨 Building documentation..."
cd doc
make clean
make html SPHINXOPTS="-W -j auto"
cd ..

# Check if there are uncommitted changes
if [[ -n $(git status -s) ]]; then
    echo "⚠️  Warning: You have uncommitted changes in your working directory."
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Deployment cancelled."
        exit 1
    fi
fi

# Get current branch to return to it later
CURRENT_BRANCH=$(git branch --show-current)
echo "📍 Current branch: $CURRENT_BRANCH"

# Create or switch to gh-pages branch
if git show-ref --verify --quiet refs/heads/gh-pages; then
    echo "📂 Switching to gh-pages branch..."
    git checkout gh-pages
else
    echo "📂 Creating new gh-pages branch..."
    git checkout --orphan gh-pages
    git rm -rf .
fi

# Copy built documentation to root
echo "📋 Copying documentation files..."
cp -r doc/build/html/* .

# Create .nojekyll file to prevent GitHub from processing with Jekyll
touch .nojekyll

# Add and commit changes
echo "💾 Committing changes..."
git add .
if git diff --staged --quiet; then
    echo "✅ No changes to commit - documentation is up to date!"
else
    git commit -m "Deploy documentation - $(date '+%Y-%m-%d %H:%M:%S')"
    echo "✅ Changes committed!"
    
    # Push to remote
    read -p "🚀 Push to remote? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git push origin gh-pages
        echo "✅ Documentation deployed to GitHub Pages!"
        echo "📖 Your docs will be available at: https://[username].github.io/showcase-flint/"
    else
        echo "⏸️  Skipped push. Run 'git push origin gh-pages' manually when ready."
    fi
fi

# Return to original branch
echo "🔄 Returning to $CURRENT_BRANCH branch..."
git checkout "$CURRENT_BRANCH"

echo "✨ Done!"
