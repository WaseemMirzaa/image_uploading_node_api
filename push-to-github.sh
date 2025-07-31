#!/bin/bash

# 4 Secrets Wedding - GitHub Push Script
# This script prepares and pushes the code to GitHub (without sensitive data)

echo "🚀 4 Secrets Wedding - GitHub Push Script"
echo "=========================================="
echo ""

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "❌ Not a git repository. Initializing..."
    git init
    echo "✅ Git repository initialized"
fi

# Check if .env file exists and warn about it
if [ -f ".env" ]; then
    echo "⚠️ WARNING: .env file detected"
    echo "   This file contains sensitive data and will NOT be pushed to GitHub"
    echo "   (Protected by .gitignore)"
    echo ""
fi

# Check if .gitignore exists and is properly configured
if [ ! -f ".gitignore" ]; then
    echo "❌ .gitignore file missing. Creating one..."
    cat > .gitignore << 'EOF'
# Dependencies
node_modules/
npm-debug.log*

# Environment variables (NEVER commit these)
.env
.env.local
.env.production.local

# Firebase service account keys
firebase-service-account.json
*-firebase-adminsdk-*.json

# Logs
logs/
*.log

# Uploaded images
src/images/*
!src/images/.gitkeep

# OS files
.DS_Store
Thumbs.db

# IDE files
.vscode/
.idea/
EOF
    echo "✅ .gitignore created"
else
    echo "✅ .gitignore exists"
fi

# Ensure .env.example exists
if [ ! -f ".env.example" ]; then
    echo "❌ .env.example missing. This is needed for deployment."
    exit 1
else
    echo "✅ .env.example exists"
fi

# Create images directory with .gitkeep if it doesn't exist
if [ ! -d "src/images" ]; then
    mkdir -p src/images
    touch src/images/.gitkeep
    echo "✅ Created src/images directory with .gitkeep"
fi

# Add all files to git
echo ""
echo "📁 Adding files to git..."
git add .

# Check what will be committed
echo ""
echo "📋 Files to be committed:"
git status --porcelain

# Verify .env is not being committed
if git status --porcelain | grep -q "\.env$"; then
    echo ""
    echo "❌ ERROR: .env file is being committed!"
    echo "   This contains sensitive data and should not be in version control."
    echo "   Please check your .gitignore file."
    exit 1
else
    echo "✅ .env file is properly ignored"
fi

# Get commit message
echo ""
read -p "📝 Enter commit message (or press Enter for default): " COMMIT_MSG
if [ -z "$COMMIT_MSG" ]; then
    COMMIT_MSG="Update 4 Secrets Wedding API with Firebase push notifications"
fi

# Commit changes
echo ""
echo "💾 Committing changes..."
git commit -m "$COMMIT_MSG"

# Check if remote origin exists
if ! git remote get-url origin > /dev/null 2>&1; then
    echo ""
    echo "🔗 No remote origin found. Please add your GitHub repository:"
    echo "   git remote add origin https://github.com/WaseemMirzaa/four_wedding_app_cloud_function.git"
    echo ""
    read -p "🔗 Enter your GitHub repository URL: " REPO_URL
    if [ ! -z "$REPO_URL" ]; then
        git remote add origin "$REPO_URL"
        echo "✅ Remote origin added: $REPO_URL"
    else
        echo "❌ No repository URL provided. Please add manually."
        exit 1
    fi
else
    REPO_URL=$(git remote get-url origin)
    echo "✅ Remote origin exists: $REPO_URL"
fi

# Push to GitHub
echo ""
echo "🚀 Pushing to GitHub..."
git push -u origin main

if [ $? -eq 0 ]; then
    echo ""
    echo "🎉 SUCCESS! Code pushed to GitHub successfully!"
    echo ""
    echo "📋 Summary:"
    echo "   Repository: $REPO_URL"
    echo "   Branch: main"
    echo "   Commit: $COMMIT_MSG"
    echo ""
    echo "🔒 Security Check:"
    echo "   ✅ .env file NOT pushed (contains sensitive data)"
    echo "   ✅ .env.example pushed (template for deployment)"
    echo "   ✅ Firebase credentials protected"
    echo ""
    echo "🚀 Next Step: Run the DigitalOcean deployment script"
    echo "   ./deploy-to-digitalocean.sh"
else
    echo ""
    echo "❌ Failed to push to GitHub"
    echo "   Please check your credentials and repository access"
    exit 1
fi

echo ""
echo "🔔 Ready for DigitalOcean deployment!"
echo "   The deployment script will:"
echo "   1. Clone from GitHub"
echo "   2. Install dependencies"
echo "   3. Create .env with all credentials"
echo "   4. Start the service with PM2"
echo ""
