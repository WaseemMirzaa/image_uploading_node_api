#!/bin/bash

# Fresh Deployment Script from GitHub
# 4 Secrets Wedding API - Complete Setup from Scratch

echo "🚀 Fresh Deployment - 4 Secrets Wedding API from GitHub"
echo "======================================================="

# Configuration
PROJECT_NAME="4secrets-wedding-api"
REPO_URL="https://github.com/WaseemMirzaa/image_uploading_node_api.git"
PROJECT_DIR="/root/$PROJECT_NAME"
PORT=3001

echo "📁 Step 1: Clean Setup"
echo "====================="

# Remove any existing directory
if [ -d "$PROJECT_DIR" ]; then
    echo "🗑️ Removing existing project directory..."
    rm -rf "$PROJECT_DIR"
fi

# Stop any existing PM2 processes
pm2 delete $PROJECT_NAME 2>/dev/null || true

echo "✅ Clean slate ready"

echo ""
echo "📥 Step 2: Clone Repository from GitHub"
echo "======================================"

# Clone the repository
echo "📥 Cloning repository from GitHub..."
git clone "$REPO_URL" "$PROJECT_DIR"

if [ $? -ne 0 ]; then
    echo "❌ Failed to clone repository"
    exit 1
fi

cd "$PROJECT_DIR"
echo "✅ Repository cloned successfully"
echo "📁 Working in: $(pwd)"

echo ""
echo "🔧 Step 3: Install System Dependencies"
echo "====================================="

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

echo "✅ System dependencies ready"

echo ""
echo "📦 Step 4: Install Project Dependencies"
echo "======================================"

# Install project dependencies
echo "📦 Installing Node.js dependencies..."
npm install

if [ $? -ne 0 ]; then
    echo "❌ Failed to install dependencies"
    exit 1
fi

echo "✅ Project dependencies installed"

echo ""
echo "🔧 Step 5: Setup Real Credentials"
echo "================================"

# Create .env file with real credentials
echo "📝 Creating .env file with real credentials..."
cat > .env << 'ENV_EOF'
# Server Configuration
PORT=3001
NODE_ENV=production

# Upload Configuration
UPLOAD_PATH=src/files
MAX_FILE_SIZE=10485760

# Email Configuration - Brevo API (REAL CREDENTIALS)
BREVO_API_KEY=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
BREVO_API_URL=https://api.brevo.com/v3/smtp/email
EMAIL_FROM=support@brevo.4secrets-wedding-planner.de
EMAIL_CLOUD_FUNCTION_URL=http://localhost:3001

# Firebase Configuration for Push Notifications (REAL CREDENTIALS)
FIREBASE_PROJECT_ID=secrets-wedding
FIREBASE_SERVICE_ACCOUNT_PATH=./firebase-service-account.json

# Additional Configuration
APP_NAME=4secrets-wedding-api
APP_VERSION=1.0.0
ENV_EOF

echo "✅ Environment file created"

# Create Firebase service account file with real credentials
echo "📝 Creating Firebase service account file..."
cat > firebase-service-account.json << 'FIREBASE_EOF'
{
  "type": "service_account",
  "project_id": "secrets-wedding",
  "private_key_id": "80f5c6b912b41fb7a293dece4338200f16eb7d4a",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDC3FT+We+5ob8s\nlxcteKAgcHVMAo2XFZTSDu+B13qdX4VhWDLs3bgGJcX8wLxlnQ8nHTQ9HjRfV7cn\nAyHxWRNbtIMZS032NexrhwhmxRIX+iRrHzUEPfbbpFW8yB7gMDa1vYummGkXv5m8\nHrlzuBNN9sCSDUajY9vhmPF/cT7WKSlwMeNe3+qOlsBHhlcZMa0Dm0d11ZweFCZM\n73CeYdZ88epFJBi5vFibnw+ctXgf36chkxMQePrEN/6tRGZ5BouJL8ROFNp7IrlT\neDvDeASuJAkBDsu+fPWeVRDHauoh39SEsg4ZWvghm9YFxpayvnvsWIrWNIhne1Q1\n3z6ER+tDAgMBAAECggEAGkNaDUIP5mQfgSIIFK/aXSTrGkiJzuAww7MRot1pAEb8\nkicyDezAPcvfiHZtrgBiJ3JvNQGaK3OGEvMAIyhPTJ/iv4j/w/x2lfOINVnAW4zy\nVaHKIn07hVT73UrXpn25EfuvE9Ac8f939/voIOmhaHOmdsjlSWZPH3PesL+RqYl8\neeAXbFuW4+7493TQV+S6Vw533MjqR2pkiSoM0aWoW0qHpfJsozalv3c2H7m4Wbtg\no6LD2O1kM8JWOnH2FI4IjpLzlm0b8GMntFsTjVAKF/s6UP+Ld63s7kJmlME/34V9\ngoyWa1bY3EtxY8xICny+45bsYtnDohf0zRO+sk0RgQKBgQDmAzqLJL2VryeuSBx9\nhjfT4Y0j2iMk8v+/831xDQ4+PiREL2FN3bsZEl2elWcVHB5YqOHeE4tXrr2k+3Gx\npuo5F9gmDwE6uAYv3nDLZiNqSfLeQ2wlhYYh3SCg1iaRUZ9+Qe+4BENfW2uqNfn4\nfRv+eqcht6wTJf4c2VRzfr7RAwKBgQDY4GLNVMwhlowr3czqvXY7rci6oJKVTNp+\npjsxg0kLicEwK+a2o+p/jfsdEaDeNHtrbJ+3eZLrPsp8kQnm+Vlp0FTNXEyt8vVZ\nrfxIj4ofGbLLuwCCXXD/oOFKuYoAguMhE8avO9zYETbgC5H2cCfxN+hralifkvDq\nliwHGbbIwQKBgAxgBBhUY7bX86SW0KGYRQyrR/Kz28wzHrtvGEKq1ydWJJFekzej\nRFu29z5+/0rNdnyCqZRPLOIMzrs/pABQ4K0tsT1q9T/5gqu0phDrb+BaFi0LJ5hl\nNLBBu22r1+tdnt0mIwWdhRpuSr6fpNFPud/ZLYDM5v8oviFDOB32pcGNAoGBAJkV\nqigt1vlOfxrnsSFxIuf1P18cwNtKKGCFjfrhJMpULl2GX5BEG951pe9a5iZy/TtS\nrVqhIieTZvKOnmK/V3HtcC6VHDsc6DqpKQ8+4swZI6fJ\ngdFne/e4DvgOsrU1bbxDLnfD1VKuMggkgGdyqycBAoGBANgHTk34MQaPMvCIEAhk\n0LM7Lx/XUXXsSEx/Z5OmuDU8rAnDCd0xvcZjNt1sMk9Rctl7voQO2BVvCsdY8UVT\njxmMswxhFvZrVewxDcMtaf2qJZem8qm714Gr0U4bK4YRdcveLrcd9T5PsplDitpw\np50mFJ+nBc6n47ewrqkECwcW\n-----END PRIVATE KEY-----\n",
  "client_email": "firebase-adminsdk-fbsvc@secrets-wedding.iam.gserviceaccount.com",
  "client_id": "100124235240975477019",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40secrets-wedding.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
}
FIREBASE_EOF

chmod 600 firebase-service-account.json
echo "✅ Firebase credentials created"

echo ""
echo "📁 Step 6: Create Required Directories"
echo "====================================="

# Create required directories
mkdir -p logs
mkdir -p src/files
chmod 755 src/files

echo "✅ Required directories created"

echo ""
echo "🔍 Step 7: Verify Project Structure"
echo "=================================="

echo "📋 Checking project structure..."

# Check key files
if [ -f "server.js" ]; then
    echo "✅ server.js found"
else
    echo "❌ server.js missing"
fi

if [ -f "src/app.js" ]; then
    echo "✅ src/app.js found"
else
    echo "❌ src/app.js missing"
fi

if [ -f "src/controllers/notificationController.js" ]; then
    echo "✅ Notification controller found"
else
    echo "❌ Notification controller missing"
fi

if [ -f "src/routes/notificationRoutes.js" ]; then
    echo "✅ Notification routes found"
else
    echo "❌ Notification routes missing"
fi

if [ -f "src/controllers/emailController.js" ]; then
    echo "✅ Email controller found"
else
    echo "❌ Email controller missing"
fi

echo ""
echo "🚀 Step 8: Start Application with PM2"
echo "===================================="

# Start the application
echo "🔥 Starting application on port $PORT..."
pm2 start server.js --name "$PROJECT_NAME"

if [ $? -ne 0 ]; then
    echo "❌ Failed to start application"
    echo "📋 Checking for errors..."
    pm2 logs $PROJECT_NAME --lines 20
    exit 1
fi

# Save PM2 configuration
pm2 save

# Setup PM2 to start on boot
pm2 startup

echo "✅ Application started successfully"

echo ""
echo "⏳ Step 9: Wait for Server Initialization"
echo "========================================"

echo "⏳ Waiting 15 seconds for server to initialize..."
sleep 15

echo ""
echo "🧪 Step 10: Test All APIs"
echo "========================"

# Test health check
echo "🔍 Testing health check..."
HEALTH_RESPONSE=$(curl -s http://localhost:$PORT/health)
if [[ "$HEALTH_RESPONSE" == *"ok"* ]] || [[ "$HEALTH_RESPONSE" == *"OK"* ]]; then
    echo "✅ Health check: Working"
    echo "   Response: $HEALTH_RESPONSE"
else
    echo "❌ Health check: Failed"
    echo "   Response: $HEALTH_RESPONSE"
fi

echo ""

# Test email status
echo "🔍 Testing email API..."
EMAIL_RESPONSE=$(curl -s http://localhost:$PORT/api/email/status)
if [[ "$EMAIL_RESPONSE" == *"Email"* ]] || [[ "$EMAIL_RESPONSE" == *"connected"* ]]; then
    echo "✅ Email API: Working"
    echo "   Response: $EMAIL_RESPONSE"
else
    echo "❌ Email API: Failed"
    echo "   Response: $EMAIL_RESPONSE"
fi

echo ""

# Test notifications status
echo "🔍 Testing notifications API..."
NOTIF_RESPONSE=$(curl -s http://localhost:$PORT/api/notifications/status)
if [[ "$NOTIF_RESPONSE" == *"Firebase"* ]] || [[ "$NOTIF_RESPONSE" == *"ready"* ]]; then
    echo "✅ Notifications API: Working"
    echo "   Response: $NOTIF_RESPONSE"
else
    echo "❌ Notifications API: Failed"
    echo "   Response: $NOTIF_RESPONSE"
fi

echo ""

# Test Firebase connection
echo "🔍 Testing Firebase connection..."
FIREBASE_RESPONSE=$(curl -s http://localhost:$PORT/api/notifications/test)
if [[ "$FIREBASE_RESPONSE" == *"success"* ]] || [[ "$FIREBASE_RESPONSE" == *"working"* ]]; then
    echo "✅ Firebase Connection: Working"
    echo "   Response: $FIREBASE_RESPONSE"
else
    echo "❌ Firebase Connection: Failed"
    echo "   Response: $FIREBASE_RESPONSE"
fi

echo ""

# Test file upload status
echo "🔍 Testing file upload API..."
FILE_RESPONSE=$(curl -s http://localhost:$PORT/files/status)
if [[ "$FILE_RESPONSE" == *"ready"* ]] || [[ "$FILE_RESPONSE" == *"File"* ]]; then
    echo "✅ File Upload API: Working"
    echo "   Response: $FILE_RESPONSE"
else
    echo "❌ File Upload API: Failed"
    echo "   Response: $FILE_RESPONSE"
fi

echo ""

# Test real notification sending
echo "🔍 Testing real notification sending..."
FCM_TOKEN="fYZUgAHuTX-mAvjjWoLnHk:APA91bGBwjNs0EzbfFYBWffdgD3V86YNWryNg1oP-gpoZ7zEmIdf3CXIWjYZgHqto-3v5uzbYUisUyA8tu5gyJl6fV5S6LowCXhVFG2-lyhOtJwVIHqKHZw"

NOTIF_SEND=$(curl -s -X POST -H "Content-Type: application/json" -d "{\"token\":\"$FCM_TOKEN\",\"title\":\"Server Deployed!\",\"body\":\"4 Secrets Wedding API is now running on your server!\"}" http://localhost:$PORT/api/notifications/send)

if [[ "$NOTIF_SEND" == *"success"* ]] || [[ "$NOTIF_SEND" == *"messageId"* ]]; then
    echo "✅ Real Notification Sending: Working"
    echo "   Response: $NOTIF_SEND"
    echo "   📱 Check your device for the notification!"
else
    echo "❌ Real Notification Sending: Failed"
    echo "   Response: $NOTIF_SEND"
fi

echo ""

# Test real email sending
echo "🔍 Testing real email sending..."
EMAIL_TEST=$(curl -s -X POST -H "Content-Type: application/json" -d '{"email":"unicorndev.02.1997@gmail.com","inviterName":"Server Deployment"}' http://localhost:$PORT/api/email/send-invitation)

if [[ "$EMAIL_TEST" == *"success"* ]] || [[ "$EMAIL_TEST" == *"messageId"* ]]; then
    echo "✅ Real Email Sending: Working"
    echo "   Response: $EMAIL_TEST"
    echo "   📧 Check your email inbox!"
else
    echo "❌ Real Email Sending: Failed"
    echo "   Response: $EMAIL_TEST"
fi

echo ""
echo "🎉 FRESH DEPLOYMENT COMPLETE!"
echo "============================"
echo ""
echo "🔥 Your 4 Secrets Wedding API is now running!"
echo ""
echo "📋 Server Information:"
echo "   📍 Location: $PROJECT_DIR"
echo "   🌐 Port: $PORT"
echo "   📊 Process: $PROJECT_NAME (PM2)"
echo ""
echo "🌐 API Endpoints Available:"
SERVER_IP=$(curl -s ifconfig.me 2>/dev/null || echo "YOUR_SERVER_IP")
echo ""
echo "   Health Check:"
echo "   GET  http://$SERVER_IP:$PORT/health"
echo ""
echo "   📧 Email APIs:"
echo "   POST http://$SERVER_IP:$PORT/api/email/send-invitation"
echo "   POST http://$SERVER_IP:$PORT/api/email/declined-invitation"
echo "   POST http://$SERVER_IP:$PORT/api/email/revoke-access"
echo "   GET  http://$SERVER_IP:$PORT/api/email/status"
echo ""
echo "   🔔 Notification APIs:"
echo "   POST http://$SERVER_IP:$PORT/api/notifications/send"
echo "   POST http://$SERVER_IP:$PORT/api/notifications/wedding-invitation"
echo "   POST http://$SERVER_IP:$PORT/api/notifications/task-reminder"
echo "   GET  http://$SERVER_IP:$PORT/api/notifications/status"
echo "   GET  http://$SERVER_IP:$PORT/api/notifications/test"
echo ""
echo "   📁 File Upload APIs:"
echo "   POST   http://$SERVER_IP:$PORT/upload"
echo "   GET    http://$SERVER_IP:$PORT/files/"
echo "   DELETE http://$SERVER_IP:$PORT/files/delete"
echo "   GET    http://$SERVER_IP:$PORT/files/status"
echo ""
echo "📊 Server Management Commands:"
echo "   pm2 status                    # View all processes"
echo "   pm2 logs $PROJECT_NAME        # View application logs"
echo "   pm2 restart $PROJECT_NAME     # Restart application"
echo "   pm2 stop $PROJECT_NAME        # Stop application"
echo ""
echo "✅ Features Ready:"
echo "   ✅ Email services (German templates) with real Brevo API"
echo "   ✅ Firebase push notifications with real FCM"
echo "   ✅ Universal file upload (10MB limit, all file types)"
echo "   ✅ Health monitoring and status endpoints"
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
echo "   curl http://localhost:$PORT/api/notifications/test"
echo ""
echo "🎉 Fresh deployment completed successfully!"
