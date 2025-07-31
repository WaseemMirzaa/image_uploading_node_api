#!/bin/bash

# Update Server Structure Script
# Sync local project structure to deployed server

echo "🔄 Update Server Structure - 4 Secrets Wedding API"
echo "=================================================="

PROJECT_NAME="4secrets-wedding-api"
PROJECT_DIR="/root/$PROJECT_NAME"

# Navigate to project directory
if [ -d "$PROJECT_DIR" ]; then
    cd "$PROJECT_DIR"
    echo "📁 Working in: $PROJECT_DIR"
else
    echo "❌ Project directory not found: $PROJECT_DIR"
    exit 1
fi

echo ""
echo "🔄 Step 1: Pull Latest Code from GitHub"
echo "======================================"

# Stop the application first
echo "🛑 Stopping application..."
pm2 stop $PROJECT_NAME 2>/dev/null || true

# Pull latest code
echo "📥 Pulling latest code from GitHub..."
git pull origin master

if [ $? -ne 0 ]; then
    echo "❌ Failed to pull latest code"
    exit 1
fi

echo "✅ Latest code pulled successfully"

echo ""
echo "🔧 Step 2: Verify Project Structure"
echo "=================================="

# Check if src/app.js exists (new structure)
if [ -f "src/app.js" ]; then
    echo "✅ src/app.js found - using modern project structure"
    
    # Check if server.js is the simple version
    if grep -q "require('./src/app')" server.js; then
        echo "✅ server.js is correctly configured to use src/app.js"
    else
        echo "🔧 Updating server.js to use src/app.js..."
        
        # Backup current server.js
        cp server.js server.js.backup
        
        # Create simple server.js that uses src/app.js
        cat > server.js << 'SERVER_EOF'
const app = require('./src/app');
const config = require('./src/config');
const logger = require('./src/utils/logger');

const PORT = process.env.PORT || config.server.port || 3001;

app.listen(PORT, () => {
  logger.info(`Server running in ${process.env.NODE_ENV || 'development'} mode on port ${PORT}`);
  logger.info(`Images will be stored in: ${config.upload.absolutePath}`);
});
SERVER_EOF
        
        echo "✅ server.js updated to use src/app.js"
    fi
else
    echo "❌ src/app.js not found - using old structure"
fi

# Check notification files
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

echo ""
echo "🔧 Step 3: Update Firebase Credentials"
echo "====================================="

# Update Firebase credentials
echo "📝 Updating Firebase service account..."
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

chmod 600 firebase-service-account.json
echo "✅ Firebase credentials updated"

echo ""
echo "🔧 Step 4: Install Dependencies"
echo "=============================="

# Install any new dependencies
echo "📦 Installing dependencies..."
npm install

echo "✅ Dependencies installed"

echo ""
echo "🚀 Step 5: Restart Application"
echo "============================="

# Start the application
echo "🔥 Starting application..."
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
echo "⏳ Step 6: Wait for Initialization"
echo "================================="

echo "⏳ Waiting 10 seconds for server to initialize..."
sleep 10

echo ""
echo "🧪 Step 7: Test All APIs"
echo "======================="

PORT=3001

# Test health check
echo "🔍 Testing health check..."
HEALTH_RESPONSE=$(curl -s http://localhost:$PORT/health)
echo "   Response: $HEALTH_RESPONSE"

echo ""

# Test notification status
echo "🔍 Testing notification status..."
NOTIF_STATUS=$(curl -s http://localhost:$PORT/api/notifications/status)
echo "   Response: $NOTIF_STATUS"

echo ""

# Test Firebase connection
echo "🔍 Testing Firebase connection..."
FIREBASE_TEST=$(curl -s http://localhost:$PORT/api/notifications/test)
echo "   Response: $FIREBASE_TEST"

echo ""

# Test email status
echo "🔍 Testing email status..."
EMAIL_STATUS=$(curl -s http://localhost:$PORT/api/email/status)
echo "   Response: $EMAIL_STATUS"

echo ""
echo "🎉 SERVER UPDATE COMPLETE!"
echo "========================="
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
echo "✅ Server updated with latest code and correct project structure!"
echo "🚀 All APIs should now be working with JSON responses!"
