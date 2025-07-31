#!/bin/bash

# Firebase Push Notification Test Script
# This script helps test Firebase configuration and notifications

echo "🔥 Firebase Push Notification Setup Test"
echo "========================================"
echo ""

# Test 1: Check current configuration
echo "1. Checking current Firebase configuration..."
echo "--------------------------------------------"
curl -s http://localhost:3000/api/notifications/status | python3 -m json.tool 2>/dev/null || curl -s http://localhost:3000/api/notifications/status
echo ""

# Test 2: Check if server is running
echo "2. Testing server connection..."
echo "-------------------------------"
if curl -s http://localhost:3000/health > /dev/null; then
    echo "✅ Server is running on port 3000"
else
    echo "❌ Server is not running. Please start with: npm start"
    exit 1
fi
echo ""

# Test 3: Send test notification (will be mock until Firebase is configured)
echo "3. Sending test notification..."
echo "-------------------------------"
TEST_TOKEN="eAxrpmKxSBu5ZctRtEcRpt:APA91bHoIGjjAq0mMOl83bjXq3Qw0T5Pe9pFnVacreW1-dhnbdcB5dXZzFdbSU9uUw_nPfNAFOI2tKUkOtPoMLIraN0Y9jew2jh-cqqs99xvEecakqjbbxY"

curl -X POST http://localhost:3000/api/notifications/send \
  -H "Content-Type: application/json" \
  -d "{
    \"token\": \"$TEST_TOKEN\",
    \"title\": \"Firebase Setup Test 🔥\",
    \"body\": \"Testing Firebase push notification configuration\",
    \"data\": {
      \"type\": \"setup_test\",
      \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)\"
    }
  }" | python3 -m json.tool 2>/dev/null || curl -s -X POST http://localhost:3000/api/notifications/send -H "Content-Type: application/json" -d "{\"token\":\"$TEST_TOKEN\",\"title\":\"Test\",\"body\":\"Test\"}"
echo ""

# Test 4: Check notification history
echo "4. Checking notification history..."
echo "-----------------------------------"
curl -s http://localhost:3000/api/notifications/sent | python3 -m json.tool 2>/dev/null || curl -s http://localhost:3000/api/notifications/sent
echo ""

echo "🔍 DIAGNOSIS:"
echo "============="
echo ""

# Check if Firebase is configured
if curl -s http://localhost:3000/api/notifications/status | grep -q '"status":"connected"'; then
    echo "✅ Firebase is properly configured and connected"
    echo "✅ Real push notifications should be working"
    echo ""
    echo "🎯 Next steps:"
    echo "- Test with your mobile app"
    echo "- Check if notifications arrive on your device"
    echo "- Verify FCM token is current and valid"
else
    echo "⚠️ Firebase is NOT configured (running in mock mode)"
    echo "❌ Real push notifications will NOT be delivered"
    echo ""
    echo "🔧 To fix this:"
    echo "1. Go to Firebase Console: https://console.firebase.google.com/"
    echo "2. Select project: secrets-wedding"
    echo "3. Go to Project Settings > Service accounts"
    echo "4. Click 'Generate new private key'"
    echo "5. Download the JSON file"
    echo "6. Add the JSON content to your .env file:"
    echo "   FIREBASE_SERVICE_ACCOUNT_KEY='{\"type\":\"service_account\",...}'"
    echo "7. Restart the server: npm start"
    echo ""
    echo "📖 Detailed instructions: See FIREBASE-SERVICE-ACCOUNT-SETUP.md"
fi

echo ""
echo "🔔 Your FCM Token: $TEST_TOKEN"
echo "📱 Project ID: secrets-wedding"
echo "🌐 Server: http://localhost:3000"
echo ""
echo "📋 Quick Commands:"
echo "- Check status: curl http://localhost:3000/api/notifications/status"
echo "- Send test: curl -X POST http://localhost:3000/api/notifications/send -H 'Content-Type: application/json' -d '{\"token\":\"YOUR_TOKEN\",\"title\":\"Test\",\"body\":\"Test\"}'"
echo "- View history: curl http://localhost:3000/api/notifications/sent"
echo ""
