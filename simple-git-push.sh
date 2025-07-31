#!/bin/bash

echo "🚀 Simple Git Push Script"
echo "========================"

# Initialize git if not already done
if [ ! -d ".git" ]; then
    echo "Initializing git repository..."
    git init
    git remote add origin https://github.com/WaseemMirzaa/four_wedding_app_cloud_function.git
fi

# Add all files
echo "Adding files..."
git add .

# Commit with message
echo "Committing changes..."
git commit -m "Add Firebase push notifications API with complete deployment scripts

- Added Firebase Admin SDK integration for real push notifications
- Created comprehensive push notification service with German templates
- Added wedding invitation, task reminder, and collaboration notifications
- Implemented secure deployment scripts for GitHub and DigitalOcean
- Protected sensitive Firebase credentials from version control
- Added complete API documentation and deployment guides
- Ready for production deployment with PM2 and firewall configuration"

# Push to GitHub
echo "Pushing to GitHub..."
git push -u origin main

echo "✅ Code pushed to GitHub successfully!"
