#!/bin/bash

# Fix Firebase Configuration and Restart Server
# 4 Secrets Wedding API - Firebase Credentials Fix

echo "🔧 Firebase Configuration Fix Script"
echo "===================================="

PROJECT_NAME="4secrets-wedding-api"
PROJECT_DIR="/root/$PROJECT_NAME"

# Navigate to project directory
if [ -d "$PROJECT_DIR" ]; then
    cd "$PROJECT_DIR"
    echo "📁 Working in: $PROJECT_DIR"
else
    echo "❌ Project directory not found: $PROJECT_DIR"
    echo "Please run the main deployment script first!"
    exit 1
fi

echo ""
echo "🔧 Step 1: Update Firebase Service Account"
echo "=========================================="

# Create Firebase service account file with real credentials
echo "📝 Creating Firebase service account file with real credentials..."
cat > firebase-service-account.json << 'FIREBASE_EOF'
{
  "type": "service_account",
  "project_id": "secrets-wedding",
  "private_key_id": "80f5c6b912b41fb7a293dece4338200f16eb7d4a",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDC3FT+We+5ob8s\nlxcteKAgcHVMAo2XFZTSDu+B13qdX4VhWDLs3bgGJcX8wLxlnQ8nHTQ9HjRfV7cn\nAyHxWRNbtIMZS032NexrhwhmxRIX+iRrHzUEPfbbpFW8yB7gMDa1vYummGkXv5m8\nHrlzuBNN9sCSDUajY9vhmPF/cT7WKSlwMeNe3+qOlsBHhlcZMa0Dm0d11ZweFCZM\n73CeYdZ88epFJBi5vFibnw+ctXgf36chkxMQePrEN/6tRGZ5BouJL8ROFNp7IrlT\neDvDeASuJAkBDsu+fPWeVRDHauoh39SEsg4ZWvghm9YFxpayvnvsWIrWNIhne1Q1\n3z6ER+tDAgMBAAECggEAGkNaDUIP5mQfgSIIFK/aXSTrGkiJzuAww7MRot1pAEb8\nkicyDezAPcvfiHZtrgBiJ3JvNQGaK3OGEvMAIyhPTJ/iv4j/w/x2lfOINVnAW4zy\nVaHKIn07hVT73UrXpn25EfuvE9Ac8f939/voIOmhaHOmdsjlSWZPH3PesL+RqYl8\neeAXbFuW4+7493TQV+S6Vw533MjqR2pkiSoM0aWoW0qHpfJsozalv3c2H7m4Wbtg\no6LD2O1kM8JWOnH2FI4IjpLzlm0b8GMntFsTjVAKF/s6UP+Ld63s7kJmlME/34V9\ngoyWa1bY3EtxY8xICny+45bsYtnDohf0zRO+sk0RgQKBgQDmAzqLJL2VryeuSBx9\nhjfT4Y0j2iMk8v+/831xDQ4+PiREL2FN3bsZEl2elWcVHB5YqOHeE4tXrr2k+3Gx\npuo5F9gmDwE6uAYv3nDLZiNqSfLeQ2wlhYYh3SCg1iaRUZ9+Qe+4BENfW2uqNfn4\nfRv+eqcht6wTJf4c2VRzfr7RAwKBgQDY4GLNVMwhlowr3czqvXY7rci6oJKVTNp+\npjsxg0kLicEwK+a2o+p/jfsdEaDeNHtrbJ+3eZLrPsp8kQnm+Vlp0FTNXEyt8vVZ\nrfxIj4ofGbLLuwCCXXD/oOFKuYoAguMhE8avO9zYETbgC5H2cCfxN+hralifkvDq\nliwHGbbIwQKBgAxgBBhUY7bX86SW0KGYRQyrR/Kz28wzHrtvGEKq1ydWJJFekzej\nRFu29z5+/0rNdnyCqZRPLOIMzrs/pABQ4K0tsT1q9T/5gqu0phDrb+BaFi0LJ5hl\nNLBBu22r1+tdnt0mIwWdhRpuSr6fpNFPud/ZLYDM5v8oviFDOB32pcGNAoGBAJkV\nqigt1vlOfxrnsSFxIuf1P18cwNtKKGCFjfrhJMpULl2GX5BEG951pe9a5iZy/TtS\nrVqhIieTZvKOnmK/V3HtcC6VHDsc6DqpKQ8+4swZI6/TDAT5WC3Yra5FUTgTK6fJ\ngdFne/e4DvgOsrU1bbxDLnfD1VKuMggkgGdyqycBAoGBANgHTk34MQaPMvCIEAhk\n0LM7Lx/XUXXsSEx/Z5OmuDU8rAnDCd0xvcZjNt1sMk9Rctl7voQO2BVvCsdY8UVT\njxmMswxhFvZrVewxDcMtaf2qJZem8qm714Gr0U4bK4YRdcveLrcd9T5PsplDitpw\np50mFJ+nBc6n47ewrqkECwcW\n-----END PRIVATE KEY-----\n",
  "client_email": "firebase-adminsdk-fbsvc@secrets-wedding.iam.gserviceaccount.com",
  "client_id": "100124235240975477019",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40secrets-wedding.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
}
FIREBASE_EOF

# Set proper permissions
chmod 600 firebase-service-account.json

echo "✅ Firebase service account file updated with real credentials"

echo ""
echo "🔧 Step 2: Update Environment Variables"
echo "======================================"

# Update .env file to ensure all variables are correct
echo "📝 Updating .env file..."
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

echo "✅ Environment variables updated"

echo ""
echo "🔧 Step 3: Verify File Structure"
echo "==============================="

echo "📁 Checking project structure..."

# Check if notification controller exists
if [ -f "src/controllers/notificationController.js" ]; then
    echo "✅ Notification controller found"
else
    echo "❌ Notification controller missing"
fi

# Check if notification routes exist
if [ -f "src/routes/notifications.js" ]; then
    echo "✅ Notification routes found"
else
    echo "❌ Notification routes missing"
fi

# Check if server.js exists
if [ -f "server.js" ]; then
    echo "✅ Server file found"
else
    echo "❌ Server file missing"
fi

echo ""
echo "🔧 Step 4: Restart Application"
echo "============================="

# Stop the current PM2 process
echo "🛑 Stopping current application..."
pm2 stop $PROJECT_NAME 2>/dev/null || true
pm2 delete $PROJECT_NAME 2>/dev/null || true

# Wait a moment
sleep 3

# Start the application again
echo "🚀 Starting application with updated credentials..."
pm2 start server.js --name "$PROJECT_NAME"

if [ $? -ne 0 ]; then
    echo "❌ Failed to start application"
    echo "📋 Checking for errors..."
    pm2 logs $PROJECT_NAME --lines 20
    exit 1
fi

# Save PM2 configuration
pm2 save

echo "✅ Application restarted successfully"

echo ""
echo "⏳ Step 5: Wait for Initialization"
echo "================================="

echo "⏳ Waiting 10 seconds for server to initialize..."
sleep 10

echo ""
echo "🧪 Step 6: Test Firebase APIs"
echo "============================"

PORT=3001

# Test health check first
echo "🔍 Testing health check..."
HEALTH_RESPONSE=$(curl -s http://localhost:$PORT/health)
if [[ "$HEALTH_RESPONSE" == *"OK"* ]] || [[ "$HEALTH_RESPONSE" == *"healthy"* ]]; then
    echo "✅ Health check: OK"
else
    echo "❌ Health check: Failed"
    echo "   Response: $HEALTH_RESPONSE"
fi

echo ""

# Test notification status
echo "🔍 Testing notification status..."
NOTIF_STATUS=$(curl -s http://localhost:$PORT/api/notifications/status)
if [[ "$NOTIF_STATUS" == *"ready"* ]] || [[ "$NOTIF_STATUS" == *"Firebase"* ]]; then
    echo "✅ Notification status: Working"
    echo "   Response: $NOTIF_STATUS"
else
    echo "❌ Notification status: Failed"
    echo "   Response: $NOTIF_STATUS"
fi

echo ""

# Test Firebase connection
echo "🔍 Testing Firebase connection..."
FIREBASE_TEST=$(curl -s http://localhost:$PORT/api/notifications/test)
if [[ "$FIREBASE_TEST" == *"success"* ]] || [[ "$FIREBASE_TEST" == *"working"* ]]; then
    echo "✅ Firebase connection: Working"
    echo "   Response: $FIREBASE_TEST"
else
    echo "❌ Firebase connection: Failed"
    echo "   Response: $FIREBASE_TEST"
fi

echo ""

# Test notification sending with your real FCM token
echo "🔍 Testing notification sending with real FCM token..."
FCM_TOKEN="fYZUgAHuTX-mAvjjWoLnHk:APA91bGBwjNs0EzbfFYBWffdgD3V86YNWryNg1oP-gpoZ7zEmIdf3CXIWjYZgHqto-3v5uzbYUisUyA8tu5gyJl6fV5S6LowCXhVFG2-lyhOtJwVIHqKHZw"

NOTIF_SEND=$(curl -s -X POST -H "Content-Type: application/json" -d "{\"token\":\"$FCM_TOKEN\",\"title\":\"Server Test\",\"body\":\"Firebase notifications working from server!\"}" http://localhost:$PORT/api/notifications/send)

if [[ "$NOTIF_SEND" == *"success"* ]] || [[ "$NOTIF_SEND" == *"messageId"* ]]; then
    echo "✅ Notification sending: Working"
    echo "   Response: $NOTIF_SEND"
else
    echo "❌ Notification sending: Failed"
    echo "   Response: $NOTIF_SEND"
fi

echo ""

# Test email sending
echo "🔍 Testing email sending..."
EMAIL_TEST=$(curl -s -X POST -H "Content-Type: application/json" -d '{"email":"unicorndev.02.1997@gmail.com","inviterName":"Server Test"}' http://localhost:$PORT/api/email/send-invitation)

if [[ "$EMAIL_TEST" == *"success"* ]] || [[ "$EMAIL_TEST" == *"messageId"* ]]; then
    echo "✅ Email sending: Working"
    echo "   Response: $EMAIL_TEST"
else
    echo "❌ Email sending: Failed"
    echo "   Response: $EMAIL_TEST"
fi

echo ""
echo "📋 Step 7: Show Application Logs"
echo "==============================="

echo "📋 Recent application logs:"
pm2 logs $PROJECT_NAME --lines 15 --nostream

echo ""
echo "🎉 FIREBASE FIX COMPLETE!"
echo "========================"
echo ""
echo "📊 Current PM2 Status:"
pm2 status

echo ""
echo "🌐 Your API Endpoints:"
SERVER_IP=$(curl -s ifconfig.me 2>/dev/null || echo "YOUR_SERVER_IP")
echo "   Health: http://$SERVER_IP:$PORT/health"
echo "   Email Status: http://$SERVER_IP:$PORT/api/email/status"
echo "   Notification Status: http://$SERVER_IP:$PORT/api/notifications/status"
echo "   Firebase Test: http://$SERVER_IP:$PORT/api/notifications/test"
echo ""
echo "🎯 Test Commands:"
echo "   curl http://localhost:$PORT/health"
echo "   curl http://localhost:$PORT/api/notifications/status"
echo "   curl http://localhost:$PORT/api/notifications/test"
echo ""
echo "✅ Firebase credentials updated and server restarted!"
echo "🚀 Your 4 Secrets Wedding API should now be fully working!"
