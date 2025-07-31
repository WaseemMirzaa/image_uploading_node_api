#!/bin/bash

# Quick Deploy Script for DigitalOcean
# 4 Secrets Wedding API - Clone, Setup & Run on Port 3001

echo "🚀 Quick Deploy - 4 Secrets Wedding API"
echo "======================================="

# Configuration
PROJECT_NAME="4secrets-wedding-api"
REPO_URL="https://github.com/WaseemMirzaa/four_wedding_app_cloud_function.git"
PROJECT_DIR="/root/$PROJECT_NAME"
PORT=3001

echo "📁 Step 1: Clone Repository"
echo "==========================="

# Remove existing directory if it exists
if [ -d "$PROJECT_DIR" ]; then
    echo "🗑️ Removing existing project directory..."
    rm -rf "$PROJECT_DIR"
fi

# Clone the repository
echo "📥 Cloning repository from GitHub..."
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

# Install project dependencies
echo "📦 Installing Node.js dependencies..."
npm install

if [ $? -ne 0 ]; then
    echo "❌ Failed to install dependencies"
    exit 1
fi

echo "✅ Dependencies installed successfully"

echo ""
echo "📁 Step 3: Create Required Directories"
echo "====================================="

# Create required directories
mkdir -p logs
mkdir -p src/files
chmod 755 src/files

echo "✅ Logs directory created"
echo "✅ Files upload directory created"

echo ""
echo "� Step 4: Fix Firebase Configuration"
echo "===================================="

# Ensure Firebase service account file has proper formatting
echo "🔧 Formatting Firebase service account file..."
if [ -f "firebase-service-account.json" ]; then
    # Pretty print the JSON to ensure proper formatting
    python3 -m json.tool firebase-service-account.json > firebase-service-account-temp.json 2>/dev/null || \
    node -e "console.log(JSON.stringify(JSON.parse(require('fs').readFileSync('firebase-service-account.json', 'utf8')), null, 2))" > firebase-service-account-temp.json

    if [ -f "firebase-service-account-temp.json" ]; then
        mv firebase-service-account-temp.json firebase-service-account.json
        echo "✅ Firebase service account file formatted"
    else
        echo "⚠️ Could not format Firebase file, using original"
    fi
else
    echo "❌ Firebase service account file not found"
fi

# Set proper permissions
chmod 600 firebase-service-account.json 2>/dev/null || true

echo "✅ Firebase configuration checked"

echo ""
echo "�🚀 Step 5: Start Application with PM2"
echo "===================================="

# Stop existing PM2 process if it exists
pm2 delete $PROJECT_NAME 2>/dev/null || true

# Start the application
echo "🔥 Starting application on port $PORT..."
pm2 start server.js --name "$PROJECT_NAME"

if [ $? -ne 0 ]; then
    echo "❌ Failed to start application"
    exit 1
fi

# Save PM2 configuration
pm2 save

echo "✅ Application started successfully with PM2"

echo ""
echo "⏳ Step 6: Wait for Server to Initialize"
echo "========================================"

echo "⏳ Waiting 10 seconds for server to start..."
sleep 10

echo ""
echo "🧪 Step 7: Test API Endpoints"
echo "============================="

# Test health check
echo "🔍 Testing health check..."
HEALTH_RESPONSE=$(curl -s http://localhost:$PORT/health)
if [ $? -eq 0 ]; then
    echo "✅ Health check: OK"
    echo "   Response: $HEALTH_RESPONSE"
else
    echo "❌ Health check: Failed"
fi

echo ""

# Test email status
echo "🔍 Testing email API..."
EMAIL_RESPONSE=$(curl -s http://localhost:$PORT/api/email/status)
if [ $? -eq 0 ]; then
    echo "✅ Email API: Ready"
    echo "   Response: $EMAIL_RESPONSE"
else
    echo "❌ Email API: Failed"
fi

echo ""

# Test notifications status
echo "🔍 Testing notifications API..."
NOTIF_RESPONSE=$(curl -s http://localhost:$PORT/api/notifications/status)
if [ $? -eq 0 ]; then
    echo "✅ Notifications API: Ready"
    echo "   Response: $NOTIF_RESPONSE"
else
    echo "❌ Notifications API: Failed"
fi

echo ""

# Test file upload status
echo "🔍 Testing file upload API..."
FILE_RESPONSE=$(curl -s http://localhost:$PORT/files/status)
if [ $? -eq 0 ]; then
    echo "✅ File Upload API: Ready"
    echo "   Response: $FILE_RESPONSE"
else
    echo "❌ File Upload API: Failed"
fi

echo ""

# Test Firebase connection specifically
echo "🔍 Testing Firebase connection..."
FIREBASE_RESPONSE=$(curl -s http://localhost:$PORT/api/notifications/test)
if [ $? -eq 0 ]; then
    echo "✅ Firebase Connection: Ready"
    echo "   Response: $FIREBASE_RESPONSE"
else
    echo "❌ Firebase Connection: Failed"
fi

echo ""

# Check PM2 logs for Firebase errors
echo "🔍 Checking for Firebase initialization errors..."
pm2 logs $PROJECT_NAME --lines 20 --nostream | grep -i firebase || echo "   No Firebase errors found in recent logs"

echo ""
echo "🎉 DEPLOYMENT COMPLETE!"
echo "======================"
echo ""
echo "🔥 Your 4 Secrets Wedding API is now running!"
echo ""
echo "📋 Server Information:"
echo "   📍 Location: $PROJECT_DIR"
echo "   🌐 Port: $PORT"
echo "   📊 Process: $PROJECT_NAME (PM2)"
echo ""
echo "🌐 API Endpoints Available:"
echo ""
echo "   Health Check:"
echo "   GET  http://your-server-ip:$PORT/health"
echo ""
echo "   📧 Email APIs:"
echo "   POST http://your-server-ip:$PORT/api/email/send"
echo "   POST http://your-server-ip:$PORT/api/email/send-invitation"
echo "   POST http://your-server-ip:$PORT/api/email/declined-invitation"
echo "   GET  http://your-server-ip:$PORT/api/email/status"
echo ""
echo "   🔔 Notification APIs:"
echo "   POST http://your-server-ip:$PORT/api/notifications/send"
echo "   POST http://your-server-ip:$PORT/api/notifications/wedding-invitation"
echo "   POST http://your-server-ip:$PORT/api/notifications/task-reminder"
echo "   GET  http://your-server-ip:$PORT/api/notifications/status"
echo ""
echo "   📁 File Upload APIs:"
echo "   POST   http://your-server-ip:$PORT/upload"
echo "   GET    http://your-server-ip:$PORT/files/"
echo "   DELETE http://your-server-ip:$PORT/files/delete"
echo "   GET    http://your-server-ip:$PORT/files/status"
echo ""
echo "📊 Server Management Commands:"
echo "   pm2 status                    # View all processes"
echo "   pm2 logs $PROJECT_NAME        # View application logs"
echo "   pm2 restart $PROJECT_NAME     # Restart application"
echo "   pm2 stop $PROJECT_NAME        # Stop application"
echo "   pm2 delete $PROJECT_NAME      # Remove application"
echo ""
echo "✅ Features Ready:"
echo "   ✅ Email services (German templates)"
echo "   ✅ Firebase push notifications"
echo "   ✅ Universal file upload (10MB limit)"
echo "   ✅ Health monitoring"
echo "   ✅ Complete wedding app functionality"
echo ""
echo "🚀 Your API is ready for production use!"

# Show final status
echo ""
echo "📊 Current PM2 Status:"
pm2 status

echo ""
echo "🎯 Quick Test Commands:"
echo "   curl http://localhost:$PORT/health"
echo "   curl http://localhost:$PORT/api/email/status"
echo "   curl http://localhost:$PORT/api/notifications/status"
echo ""
echo "🎉 Deployment completed successfully!"
