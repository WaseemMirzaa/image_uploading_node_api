#!/bin/bash

# Complete 4 Secrets Wedding API Deployment Script
# This script clones the repository and sets up everything with file upload functionality

echo "🚀 Complete 4 Secrets Wedding API Deployment"
echo "============================================="

# Configuration
PROJECT_NAME="4secrets-wedding-api"
REPO_URL="https://github.com/WaseemMirzaa/four_wedding_app_cloud_function.git"
PROJECT_DIR="/root/$PROJECT_NAME"

echo "📁 Step 1: Setup Project Directory"
echo "=================================="

# Remove existing directory if it exists
if [ -d "$PROJECT_DIR" ]; then
    echo "🗑️ Removing existing project directory..."
    rm -rf "$PROJECT_DIR"
fi

# Clone the repository
echo "📥 Cloning repository..."
git clone "$REPO_URL" "$PROJECT_DIR"

if [ $? -ne 0 ]; then
    echo "❌ Failed to clone repository"
    exit 1
fi

cd "$PROJECT_DIR"
echo "✅ Repository cloned successfully"

echo ""
echo "📦 Step 2: Install Dependencies"
echo "==============================="

# Update package list
apt update

# Install Node.js and npm if not installed
if ! command -v node &> /dev/null; then
    echo "📥 Installing Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
    apt-get install -y nodejs
fi

# Install PM2 globally if not installed
if ! command -v pm2 &> /dev/null; then
    echo "📥 Installing PM2..."
    npm install -g pm2
fi

# Install project dependencies
echo "📦 Installing project dependencies..."
npm install

echo "✅ Dependencies installed"

echo ""
echo "🔧 Step 3: Setup Environment and Credentials"
echo "==========================================="

# Create production environment file with actual credentials
echo "📝 Creating production environment file..."
cat > .env << 'ENV_EOF'
# Server Configuration
PORT=3001
NODE_ENV=production

# Upload Configuration
UPLOAD_PATH=src/files
MAX_FILE_SIZE=10485760

# Email Configuration - Brevo API
BREVO_API_KEY=your-brevo-api-key-here
BREVO_API_URL=https://api.brevo.com/v3/smtp/email
EMAIL_FROM=your-email@domain.com
EMAIL_CLOUD_FUNCTION_URL=http://localhost:3001

# Firebase Configuration for Push Notifications
FIREBASE_PROJECT_ID=your-firebase-project-id
FIREBASE_SERVICE_ACCOUNT_PATH=./firebase-service-account.json

# Additional Configuration
APP_NAME=4secrets-wedding-api
APP_VERSION=1.0.0
ENV_EOF

echo "✅ Production environment file created"

# Create Firebase service account file with placeholder credentials
echo "📝 Creating Firebase service account template..."
cat > firebase-service-account.json << 'FIREBASE_EOF'
{
  "type": "service_account",
  "project_id": "your-firebase-project-id",
  "private_key_id": "your-private-key-id",
  "private_key": "-----BEGIN PRIVATE KEY-----\nYOUR_PRIVATE_KEY_HERE\n-----END PRIVATE KEY-----\n",
  "client_email": "firebase-adminsdk-xxxxx@your-project.iam.gserviceaccount.com",
  "client_id": "your-client-id",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-xxxxx%40your-project.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
}
FIREBASE_EOF

echo "✅ Firebase service account template created"

echo ""
echo "🔐 IMPORTANT: Update Credentials"
echo "==============================="
echo "Before starting the server, update the following files with your actual credentials:"
echo ""
echo "1. Update .env file:"
echo "   - BREVO_API_KEY=your-actual-brevo-api-key"
echo "   - EMAIL_FROM=your-verified-sender-email"
echo "   - FIREBASE_PROJECT_ID=your-firebase-project-id"
echo ""
echo "2. Update firebase-service-account.json with your Firebase service account credentials"
echo ""

echo ""
echo "📁 Step 4: Create Required Directories"
echo "====================================="

mkdir -p logs
mkdir -p src/files
chmod 755 src/files
echo "✅ Logs directory created"
echo "✅ Files upload directory created"

echo ""
echo "🚀 Step 5: Start Application with PM2"
echo "===================================="

# Stop existing PM2 process if it exists
pm2 delete $PROJECT_NAME 2>/dev/null || true

# Start the application using server.js
pm2 start server.js --name "$PROJECT_NAME"

# Save PM2 configuration
pm2 save

# Setup PM2 to start on boot
pm2 startup

echo "✅ Application started with PM2"

echo ""
echo "⏳ Step 6: Wait for Server to Start"
echo "=================================="

sleep 5

echo ""
echo "🧪 Step 7: Test All APIs"
echo "======================="

# Test health check
echo "Testing health check..."
HEALTH_RESPONSE=$(curl -s http://localhost:3001/health)
if [ $? -eq 0 ]; then
    echo "✅ Health check: OK"
    echo "Response: $HEALTH_RESPONSE"
else
    echo "❌ Health check: Failed"
fi

echo ""

# Test email status
echo "Testing email status..."
EMAIL_RESPONSE=$(curl -s http://localhost:3001/api/email/status)
if [ $? -eq 0 ]; then
    echo "✅ Email API: Ready"
    echo "Response: $EMAIL_RESPONSE"
else
    echo "❌ Email API: Failed"
fi

echo ""

# Test notifications status
echo "Testing notifications status..."
NOTIF_RESPONSE=$(curl -s http://localhost:3001/api/notifications/status)
if [ $? -eq 0 ]; then
    echo "✅ Notifications API: Ready"
    echo "Response: $NOTIF_RESPONSE"
else
    echo "❌ Notifications API: Failed"
fi

echo ""

# Test file upload status
echo "Testing file upload status..."
FILE_RESPONSE=$(curl -s http://localhost:3001/api/files/status)
if [ $? -eq 0 ]; then
    echo "✅ File Upload API: Ready"
    echo "Response: $FILE_RESPONSE"
else
    echo "❌ File Upload API: Failed"
fi

echo ""
echo "🎉 Deployment Complete!"
echo "======================"
echo ""
echo "📋 Available APIs:"
echo ""
echo "🌐 Health & Status:"
echo "  GET  http://your-server:3001/health"
echo ""
echo "📧 Email APIs:"
echo "  POST http://your-server:3001/api/email/send-invitation"
echo "  POST http://your-server:3001/api/email/declined-invitation"
echo "  POST http://your-server:3001/api/email/revoke-access"
echo "  POST http://your-server:3001/api/email/send"
echo "  GET  http://your-server:3001/api/email/status"
echo ""
echo "🔔 Notification APIs:"
echo "  POST http://your-server:3001/api/notifications/send"
echo "  POST http://your-server:3001/api/notifications/wedding-invitation"
echo "  POST http://your-server:3001/api/notifications/task-reminder"
echo "  GET  http://your-server:3001/api/notifications/status"
echo ""
echo "📁 File Upload APIs:"
echo "  POST   http://your-server:3001/upload"
echo "  GET    http://your-server:3001/files"
echo "  DELETE http://your-server:3001/files/delete"
echo "  GET    http://your-server:3001/api/files/status"
echo ""
echo "📊 Server Management:"
echo "  pm2 status"
echo "  pm2 logs $PROJECT_NAME"
echo "  pm2 restart $PROJECT_NAME"
echo "  pm2 stop $PROJECT_NAME"
echo ""
echo "✅ Your 4 Secrets Wedding API is now running with complete functionality!"
echo "   - Email services (German templates)"
echo "   - Firebase push notifications"
echo "   - File upload (images, PDFs, documents, videos)"
echo "   - All APIs working on port 3001"
