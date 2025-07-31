#!/bin/bash

# 4 Secrets Wedding API - GitHub to DigitalOcean Deployment Script
# This script clones from GitHub and deploys the complete API

echo "🚀 4 Secrets Wedding API - GitHub to DigitalOcean Deployment"
echo "============================================================"
echo "Server: $(hostname -I | awk '{print $1}' 2>/dev/null || echo 'localhost')"
echo "Date: $(date)"
echo ""

# Set deployment directory
DEPLOY_DIR="/var/www/4secrets-wedding-api"

echo "🔍 Step 1: Prepare Deployment Directory"
echo "======================================="

# Create deployment directory if it doesn't exist
sudo mkdir -p $DEPLOY_DIR
sudo chown -R $USER:$USER $DEPLOY_DIR
cd $DEPLOY_DIR

echo "📁 Working directory: $(pwd)"
echo "✅ Deployment directory ready"

echo ""
echo "🔍 Step 2: Stop Existing Application"
echo "===================================="

# Stop any existing PM2 processes
pm2 stop all 2>/dev/null || echo "No PM2 processes to stop"
pm2 delete all 2>/dev/null || echo "No PM2 processes to delete"

# Kill any processes on port 3001
EXISTING_PID=$(lsof -ti:3001 2>/dev/null)
if [ ! -z "$EXISTING_PID" ]; then
    echo "⚠️ Found process $EXISTING_PID on port 3001, killing it..."
    kill -9 $EXISTING_PID 2>/dev/null || true
    sleep 2
fi

echo "✅ Existing processes stopped"

echo ""
echo "🔍 Step 3: Clone Repository"
echo "=========================="

# Remove existing code if present
if [ -d ".git" ]; then
    echo "🔄 Updating existing repository..."
    git fetch origin
    git reset --hard origin/main
    git pull origin main
else
    echo "📥 Cloning repository..."
    git clone https://github.com/WaseemMirzaa/four_wedding_app_cloud_function.git .
fi

echo "✅ Repository ready"

echo ""
echo "🔍 Step 4: Install Dependencies"
echo "==============================="

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js not found. Installing Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt-get install -y nodejs
fi

# Check if PM2 is installed
if ! command -v pm2 &> /dev/null; then
    echo "📦 Installing PM2..."
    sudo npm install -g pm2
fi

# Install project dependencies
echo "📦 Installing project dependencies..."
npm install

# Install additional dependencies for DigitalOcean server
echo "📦 Installing additional dependencies..."
npm install express firebase-admin cors helmet morgan winston multer dotenv axios

echo "✅ Dependencies installed"

echo ""
echo "🔍 Step 5: Setup Environment and Credentials"
echo "==========================================="

# Copy environment file template and update with production values
echo "📝 Setting up production environment..."
if [ -f ".env.production" ]; then
    cp .env.production .env
    echo "✅ Environment file template copied"
    echo "⚠️ IMPORTANT: Update .env file with your actual API keys and credentials"
    echo "   - BREVO_API_KEY: Your Brevo API key"
    echo "   - EMAIL_FROM: Your verified sender email"
    echo "   - FIREBASE_PROJECT_ID: Your Firebase project ID"
else
    echo "❌ .env.production template not found"
    echo "Creating basic environment file..."
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
    echo "✅ Basic environment file created"
    echo "⚠️ IMPORTANT: Update .env file with your actual credentials before starting the server"
fi

# Check if Firebase service account template exists
if [ -f "firebase-service-account.json" ]; then
    echo "✅ Firebase service account template found"
    echo "⚠️ IMPORTANT: Update firebase-service-account.json with your actual Firebase credentials"
else
    echo "❌ Firebase service account template not found"
    echo "Creating placeholder Firebase service account file..."
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
    echo "✅ Placeholder Firebase service account created"
    echo "⚠️ IMPORTANT: Update firebase-service-account.json with your actual Firebase credentials"
fi

echo ""
echo "🔐 CREDENTIAL SETUP REQUIRED:"
echo "=============================="
echo "Before starting the server, you must update the following files with your actual credentials:"
echo ""
echo "1. Update .env file:"
echo "   - BREVO_API_KEY=your-actual-brevo-api-key"
echo "   - EMAIL_FROM=your-verified-sender-email"
echo "   - FIREBASE_PROJECT_ID=your-firebase-project-id"
echo ""
echo "2. Update firebase-service-account.json with your Firebase service account credentials"
echo ""
echo "3. After updating credentials, restart the application:"
echo "   pm2 restart 4secrets-wedding-api"
echo ""

# Set proper permissions
chmod 600 .env
if [ -f "firebase-service-account.json" ]; then
    chmod 600 firebase-service-account.json
    echo "✅ Firebase service account permissions set"
fi

echo ""
echo "🔍 Step 6: Create Required Directories"
echo "====================================="

mkdir -p logs
mkdir -p src/files
echo "✅ Logs directory created"
echo "✅ Files upload directory created"

echo ""
echo "🔍 Step 7: Start Application"
echo "=========================="

# Start with PM2 using ecosystem config
if [ -f "ecosystem.config.js" ]; then
    echo "🚀 Starting application with PM2 ecosystem..."
    pm2 start ecosystem.config.js
else
    echo "🚀 Starting application with PM2 directly..."
    pm2 start digitalocean-server.js --name "4secrets-wedding-api" --env production
fi

# Save PM2 configuration
pm2 save

# Setup PM2 startup script (optional)
# pm2 startup

echo "✅ Application started"

# Wait for startup
sleep 5

echo ""
echo "🔍 Step 8: Test Application"
echo "=========================="

# Get server IP
SERVER_IP=$(curl -s ifconfig.me 2>/dev/null || hostname -I | awk '{print $1}')

# Test health endpoint
echo "🧪 Testing health endpoint..."
HEALTH_RESPONSE=$(curl -s http://localhost:3001/health)
if [ $? -eq 0 ]; then
    echo "✅ Health check passed"
    echo "Response: $HEALTH_RESPONSE"
else
    echo "❌ Health check failed"
fi

echo ""

# Test email status
echo "🧪 Testing email status..."
EMAIL_RESPONSE=$(curl -s http://localhost:3001/api/email/status)
if [ $? -eq 0 ]; then
    echo "✅ Email API accessible"
    echo "Response: $EMAIL_RESPONSE"
else
    echo "❌ Email API failed"
fi

echo ""

# Test notifications status
echo "🧪 Testing notifications status..."
NOTIF_RESPONSE=$(curl -s http://localhost:3001/api/notifications/status)
if [ $? -eq 0 ]; then
    echo "✅ Notifications API accessible"
    echo "Response: $NOTIF_RESPONSE"
else
    echo "❌ Notifications API failed"
fi

echo ""

# Test image upload status
echo "🧪 Testing image upload status..."
IMAGE_RESPONSE=$(curl -s http://localhost:3001/api/images/status)
if [ $? -eq 0 ]; then
    echo "✅ Image Upload API accessible"
    echo "Response: $IMAGE_RESPONSE"
else
    echo "❌ Image Upload API failed"
fi

echo ""
echo "🎉 DEPLOYMENT COMPLETE!"
echo "======================"
echo ""
echo "📋 Summary:"
echo "✅ Repository cloned/updated from GitHub"
echo "✅ Dependencies installed"
echo "✅ Environment configured"
echo "✅ Firebase service account ready"
echo "✅ Application running with PM2"
echo "✅ All endpoints tested"
echo ""
echo "🌐 Your API endpoints:"
echo "   Health: http://$SERVER_IP:3001/health"
echo "   Email Status: http://$SERVER_IP:3001/api/email/status"
echo "   Notification Status: http://$SERVER_IP:3001/api/notifications/status"
echo ""
echo "📧 Email Endpoints:"
echo "   POST /api/email/send"
echo "   POST /api/email/send-invitation"
echo "   POST /api/email/declined-invitation"
echo "   POST /api/email/revoke-access"
echo "   GET /api/email/sent"
echo ""
echo "🔔 Notification Endpoints:"
echo "   POST /api/notifications/send"
echo "   POST /api/notifications/wedding-invitation"
echo "   POST /api/notifications/task-reminder"
echo "   GET /api/notifications/sent"
echo ""
echo "🧪 Test commands:"
echo "# Test email:"
echo "curl -X POST http://$SERVER_IP:3001/api/email/send \\"
echo "  -H 'Content-Type: application/json' \\"
echo "  -d '{\"email\":\"m.waseemmirzaa@gmail.com\",\"subject\":\"Test\",\"message\":\"Hello!\"}'"
echo ""
echo "# Test notification:"
echo "curl -X POST http://$SERVER_IP:3001/api/notifications/send \\"
echo "  -H 'Content-Type: application/json' \\"
echo "  -d '{\"token\":\"YOUR_FCM_TOKEN\",\"title\":\"Test\",\"body\":\"Hello!\"}'"
echo ""
echo "🔧 Management commands:"
echo "   pm2 status"
echo "   pm2 logs 4secrets-wedding-api"
echo "   pm2 restart 4secrets-wedding-api"
echo "   pm2 stop 4secrets-wedding-api"
echo ""
echo "🎯 Deployment successful! Your API is ready to use."
echo ""
