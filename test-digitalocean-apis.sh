#!/bin/bash

# 4 Secrets Wedding - DigitalOcean API Testing Script
# Server IP: 164.92.175.72
# Port: 3000

SERVER_IP="164.92.175.72"
PORT="3000"
BASE_URL="http://$SERVER_IP:$PORT"
TEST_EMAIL="m.waseemmirzaa@gmail.com"
TEST_FCM_TOKEN="eAxrpmKxSBu5ZctRtEcRpt:APA91bHoIGjjAq0mMOl83bjXq3Qw0T5Pe9pFnVacreW1-dhnbdcB5dXZzFdbSU9uUw_nPfNAFOI2tKUkOtPoMLIraN0Y9jew2jh-cqqs99xvEecakqjbbxY"

echo "🧪 4 Secrets Wedding - DigitalOcean API Testing"
echo "==============================================="
echo "Server: $BASE_URL"
echo "Test Email: $TEST_EMAIL"
echo "Test FCM Token: ${TEST_FCM_TOKEN:0:50}..."
echo ""

# Function to test API endpoint
test_endpoint() {
    local method=$1
    local endpoint=$2
    local data=$3
    local description=$4
    
    echo "🔍 Testing: $description"
    echo "   $method $BASE_URL$endpoint"
    
    if [ "$method" = "GET" ]; then
        response=$(curl -s -w "\n%{http_code}" "$BASE_URL$endpoint" 2>/dev/null)
    else
        response=$(curl -s -w "\n%{http_code}" -X "$method" "$BASE_URL$endpoint" \
            -H "Content-Type: application/json" \
            -d "$data" 2>/dev/null)
    fi
    
    if [ $? -eq 0 ]; then
        http_code=$(echo "$response" | tail -n1)
        body=$(echo "$response" | head -n -1)
        
        if [ "$http_code" = "200" ] || [ "$http_code" = "201" ]; then
            echo "   ✅ SUCCESS ($http_code)"
            echo "   Response: $body" | head -c 200
            if [ ${#body} -gt 200 ]; then echo "..."; fi
        else
            echo "   ❌ FAILED ($http_code)"
            echo "   Response: $body"
        fi
    else
        echo "   ❌ CONNECTION FAILED"
    fi
    echo ""
}

echo "📋 STEP 1: Basic Health Checks"
echo "==============================="

# Test 1: Health Check
test_endpoint "GET" "/health" "" "Health Check"

# Test 2: Email API Status
test_endpoint "GET" "/api/email/status" "" "Email API Status"

# Test 3: Push Notifications Status
test_endpoint "GET" "/api/notifications/status" "" "Push Notifications Status"

# Test 4: Image API Status
test_endpoint "GET" "/api/images" "" "Image API Status"

echo "📧 STEP 2: Email API Testing"
echo "============================"

# Test 5: Send Custom Email
test_endpoint "POST" "/api/email/send" "{
    \"email\": \"$TEST_EMAIL\",
    \"subject\": \"4 Secrets Wedding - API Test Email\",
    \"message\": \"Hello! This is a test email from your 4 Secrets Wedding API deployed on DigitalOcean. The email service is working perfectly!\",
    \"from\": \"4secrets-wedding@gmx.de\"
}" "Send Custom Email"

# Test 6: Send Wedding Invitation Email
test_endpoint "POST" "/api/email/send-invitation" "{
    \"email\": \"$TEST_EMAIL\",
    \"inviterName\": \"Sarah & Michael\"
}" "Send Wedding Invitation Email"

# Test 7: Send Declined Invitation Email
test_endpoint "POST" "/api/email/declined-invitation" "{
    \"email\": \"$TEST_EMAIL\",
    \"declinerName\": \"Test User\"
}" "Send Declined Invitation Email"

# Test 8: Send Revoke Access Email
test_endpoint "POST" "/api/email/revoke-access" "{
    \"email\": \"$TEST_EMAIL\",
    \"inviterName\": \"Test Admin\"
}" "Send Revoke Access Email"

# Test 9: Get Sent Emails
test_endpoint "GET" "/api/email/sent" "" "Get Sent Emails History"

echo "🔔 STEP 3: Push Notifications Testing"
echo "====================================="

# Test 10: Send General Push Notification
test_endpoint "POST" "/api/notifications/send" "{
    \"token\": \"$TEST_FCM_TOKEN\",
    \"title\": \"🎉 DigitalOcean Test\",
    \"body\": \"Your 4 Secrets Wedding API is live on DigitalOcean! Push notifications are working perfectly.\",
    \"data\": {
        \"type\": \"test\",
        \"server\": \"digitalocean\",
        \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)\"
    }
}" "Send General Push Notification"

# Test 11: Send Wedding Invitation Push Notification
test_endpoint "POST" "/api/notifications/wedding-invitation" "{
    \"token\": \"$TEST_FCM_TOKEN\",
    \"inviterName\": \"Sarah & Michael\",
    \"weddingDate\": \"2024-08-15\"
}" "Send Wedding Invitation Push Notification"

# Test 12: Send Task Reminder Push Notification
test_endpoint "POST" "/api/notifications/task-reminder" "{
    \"token\": \"$TEST_FCM_TOKEN\",
    \"taskTitle\": \"Blumen für die Hochzeit bestellen\",
    \"dueDate\": \"2024-06-20\"
}" "Send Task Reminder Push Notification"

# Test 13: Send Collaboration Push Notification
test_endpoint "POST" "/api/notifications/collaboration" "{
    \"token\": \"$TEST_FCM_TOKEN\",
    \"collaboratorName\": \"Anna Schmidt\",
    \"action\": \"joined\"
}" "Send Collaboration Push Notification"

# Test 14: Get Push Notifications History
test_endpoint "GET" "/api/notifications/sent" "" "Get Push Notifications History"

echo "📸 STEP 4: Image API Testing"
echo "============================"

# Test 15: Get Images List
test_endpoint "GET" "/api/images" "" "Get Images List"

echo "🧪 STEP 5: Advanced Testing"
echo "==========================="

# Test 16: Test Firebase Connection
test_endpoint "GET" "/api/notifications/test" "" "Test Firebase Connection"

# Test 17: Test Email Connection
test_endpoint "GET" "/api/email/test" "" "Test Email Connection"

echo "📊 TESTING SUMMARY"
echo "=================="
echo ""
echo "🌐 Server: $BASE_URL"
echo "📧 Test Email: $TEST_EMAIL"
echo "🔔 FCM Token: ${TEST_FCM_TOKEN:0:50}..."
echo ""
echo "✅ If all tests show SUCCESS, your APIs are working perfectly!"
echo "❌ If any tests show FAILED, check the server logs:"
echo "   ssh root@$SERVER_IP"
echo "   pm2 logs 4secrets-wedding-api"
echo ""
echo "📱 Mobile App Configuration:"
echo "   const API_BASE_URL = '$BASE_URL';"
echo ""
echo "🔧 Management Commands:"
echo "   pm2 status"
echo "   pm2 logs 4secrets-wedding-api"
echo "   pm2 restart 4secrets-wedding-api"
echo ""
echo "🎉 Your 4 Secrets Wedding API is ready for production!"
echo ""
