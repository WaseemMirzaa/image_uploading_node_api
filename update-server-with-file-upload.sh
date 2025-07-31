#!/bin/bash

# Update DigitalOcean Server with Complete File Upload API
# This script adds file upload functionality to your existing server

echo "🚀 Updating DigitalOcean Server with File Upload API"
echo "=================================================="

# Check if we're on the server
if [ ! -f "digitalocean-server.js" ]; then
    echo "❌ digitalocean-server.js not found. Please run this script in your project directory."
    exit 1
fi

echo "📦 Installing required dependencies..."
npm install multer

echo "📁 Creating files directory..."
mkdir -p src/files
chmod 755 src/files

echo "🔧 Updating environment configuration..."
# Update .env file
if [ -f ".env" ]; then
    # Update upload path and file size
    sed -i 's/UPLOAD_PATH=src\/images/UPLOAD_PATH=src\/files/g' .env
    sed -i 's/MAX_FILE_SIZE=5242880/MAX_FILE_SIZE=10485760/g' .env
    echo "✅ Environment file updated"
else
    echo "⚠️ .env file not found, creating one..."
    cat > .env << 'EOF'
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
EOF
fi

echo "🔄 Backing up current server file..."
cp digitalocean-server.js digitalocean-server.js.backup

echo "📝 Downloading updated server file..."
curl -fsSL https://raw.githubusercontent.com/WaseemMirzaa/four_wedding_app_cloud_function/main/digitalocean-server.js -o digitalocean-server-new.js

if [ $? -eq 0 ]; then
    echo "✅ New server file downloaded"
    mv digitalocean-server-new.js digitalocean-server.js
    echo "✅ Server file updated"
else
    echo "❌ Failed to download new server file"
    echo "🔄 Restoring backup..."
    mv digitalocean-server.js.backup digitalocean-server.js
    exit 1
fi

echo "🔄 Restarting server with PM2..."
pm2 restart 4secrets-wedding-api || pm2 start digitalocean-server.js --name "4secrets-wedding-api"

echo "⏳ Waiting for server to start..."
sleep 5

echo "🧪 Testing server endpoints..."

# Test health check
echo "Testing health check..."
HEALTH_RESPONSE=$(curl -s http://localhost:3001/health)
if [ $? -eq 0 ]; then
    echo "✅ Health check: OK"
else
    echo "❌ Health check: Failed"
fi

# Test file upload status
echo "Testing file upload status..."
FILE_STATUS=$(curl -s http://localhost:3001/api/files/status)
if [ $? -eq 0 ]; then
    echo "✅ File upload API: Ready"
    echo "Response: $FILE_STATUS"
else
    echo "❌ File upload API: Failed"
fi

# Test email status
echo "Testing email status..."
EMAIL_STATUS=$(curl -s http://localhost:3001/api/email/status)
if [ $? -eq 0 ]; then
    echo "✅ Email API: Ready"
else
    echo "❌ Email API: Failed"
fi

# Test notifications status
echo "Testing notifications status..."
NOTIF_STATUS=$(curl -s http://localhost:3001/api/notifications/status)
if [ $? -eq 0 ]; then
    echo "✅ Notifications API: Ready"
else
    echo "❌ Notifications API: Failed"
fi

echo ""
echo "🎉 Server Update Complete!"
echo "========================"
echo ""
echo "📋 Available Endpoints:"
echo "Health Check:"
echo "  GET  http://your-server:3001/health"
echo ""
echo "File Upload API:"
echo "  POST   http://your-server:3001/upload"
echo "  GET    http://your-server:3001/files"
echo "  DELETE http://your-server:3001/files/delete"
echo "  GET    http://your-server:3001/api/files/status"
echo ""
echo "Legacy Image API (backward compatibility):"
echo "  POST   http://your-server:3001/upload-image"
echo "  GET    http://your-server:3001/images"
echo "  DELETE http://your-server:3001/images/delete"
echo "  GET    http://your-server:3001/api/images/status"
echo ""
echo "Email API:"
echo "  POST http://your-server:3001/api/email/send-invitation"
echo "  POST http://your-server:3001/api/email/declined-invitation"
echo "  POST http://your-server:3001/api/email/revoke-access"
echo "  GET  http://your-server:3001/api/email/status"
echo ""
echo "Notifications API:"
echo "  POST http://your-server:3001/api/notifications/send"
echo "  POST http://your-server:3001/api/notifications/wedding-invitation"
echo "  POST http://your-server:3001/api/notifications/task-reminder"
echo "  GET  http://your-server:3001/api/notifications/status"
echo ""
echo "📁 File Access:"
echo "  Files: http://your-server:3001/files/[filename]"
echo "  Images: http://your-server:3001/images/[filename] (legacy)"
echo ""
echo "📊 Supported File Types:"
echo "  - Images: JPEG, PNG, GIF, WEBP"
echo "  - Documents: PDF, DOC, DOCX, TXT, XLS, XLSX, PPT, PPTX"
echo "  - Archives: ZIP, RAR"
echo "  - Media: MP4, MP3, AVI, MOV"
echo "  - Max file size: 10MB"
echo ""
echo "🔧 Configuration:"
echo "  - Upload directory: src/files"
echo "  - Backup created: digitalocean-server.js.backup"
echo ""
echo "✅ Your server now supports complete file upload functionality!"

# Clean up
rm -f digitalocean-server.js.backup

echo ""
echo "🧪 To test file upload, you can use:"
echo "curl -X POST -F \"file=@your-file.pdf\" http://your-server:3001/upload"
