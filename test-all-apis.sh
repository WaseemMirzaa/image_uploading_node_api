#!/bin/bash

# Complete API Testing Script for 164.92.175.72:3000
# Tests all endpoints and shows detailed responses

SERVER="164.92.175.72:3001"
EMAIL="m.waseemmirzaa@gmail.com"
FCM_TOKEN="eAxrpmKxSBu5ZctRtEcRpt:APA91bHoIGjjAq0mMOl83bjXq3Qw0T5Pe9pFnVacreW1-dhnbdcB5dXZzFdbSU9uUw_nPfNAFOI2tKUkOtPoMLIraN0Y9jew2jh-cqqs99xvEecakqjbbxY"

echo "🧪 4 Secrets Wedding - Complete API Testing"
echo "==========================================="
echo "Server: http://$SERVER"
echo "Email: $EMAIL"
echo "FCM Token: ${FCM_TOKEN:0:50}..."
echo ""

# Function to test API endpoint
test_api() {
    local method=$1
    local endpoint=$2
    local data=$3
    local description=$4
    
    echo "🔍 Testing: $description"
    echo "   $method http://$SERVER$endpoint"
    
    if [ "$method" = "GET" ]; then
        response=$(timeout 10 curl -s -w "\nHTTP_CODE:%{http_code}" "http://$SERVER$endpoint" 2>/dev/null)
    else
        response=$(timeout 10 curl -s -w "\nHTTP_CODE:%{http_code}" -X "$method" "http://$SERVER$endpoint" \
            -H "Content-Type: application/json" \
            -d "$data" 2>/dev/null)
    fi
    
    if [ $? -eq 0 ]; then
        http_code=$(echo "$response" | grep "HTTP_CODE:" | cut -d: -f2)
        body=$(echo "$response" | grep -v "HTTP_CODE:")
        
        if [ "$http_code" = "200" ] || [ "$http_code" = "201" ]; then
            echo "   ✅ SUCCESS ($http_code)"
            echo "   Response: $body"
        else
            echo "   ❌ FAILED ($http_code)"
            echo "   Response: $body"
        fi
    else
        echo "   ❌ CONNECTION TIMEOUT/FAILED"
    fi
    echo ""
}

echo "📋 BASIC HEALTH CHECKS"
echo "======================"

# Test 1: Health Check
test_api "GET" "/health" "" "Health Check"

# Test 2: Email API Status
test_api "GET" "/api/email/status" "" "Email API Status"

# Test 3: Push Notifications Status
test_api "GET" "/api/notifications/status" "" "Push Notifications Status"

# Test 4: Image API
test_api "GET" "/api/images" "" "Image API - Get Images"

echo "📧 EMAIL API TESTS"
echo "=================="

# Test 5: Send Custom Email
test_api "POST" "/api/email/send" "{
    \"email\": \"$EMAIL\",
    \"subject\": \"4 Secrets Wedding - API Test\",
    \"message\": \"Hello! This is a test email from your DigitalOcean server. The API is working!\",
    \"from\": \"4secrets-wedding@gmx.de\"
}" "Send Custom Email"

# Test 6: Send Wedding Invitation Email
test_api "POST" "/api/email/send-invitation" "{
    \"email\": \"$EMAIL\",
    \"inviterName\": \"Sarah & Michael\"
}" "Send Wedding Invitation Email"

# Test 7: Send Declined Invitation Email
test_api "POST" "/api/email/declined-invitation" "{
    \"email\": \"$EMAIL\",
    \"declinerName\": \"Test User\"
}" "Send Declined Invitation Email"

# Test 8: Send Revoke Access Email
test_api "POST" "/api/email/revoke-access" "{
    \"email\": \"$EMAIL\",
    \"inviterName\": \"Admin User\"
}" "Send Revoke Access Email"

# Test 9: Get Sent Emails
test_api "GET" "/api/email/sent" "" "Get Sent Emails History"

echo "🔔 PUSH NOTIFICATION TESTS"
echo "=========================="

# Test 10: Send General Push Notification
test_api "POST" "/api/notifications/send" "{
    \"token\": \"$FCM_TOKEN\",
    \"title\": \"🎉 DigitalOcean API Test\",
    \"body\": \"Your 4 Secrets Wedding API is working perfectly on DigitalOcean!\",
    \"data\": {
        \"type\": \"test\",
        \"server\": \"digitalocean\",
        \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)\"
    }
}" "Send General Push Notification"

# Test 11: Send Wedding Invitation Push
test_api "POST" "/api/notifications/wedding-invitation" "{
    \"token\": \"$FCM_TOKEN\",
    \"inviterName\": \"Sarah & Michael\",
    \"weddingDate\": \"2024-08-15\"
}" "Send Wedding Invitation Push Notification"

# Test 12: Send Task Reminder Push
test_api "POST" "/api/notifications/task-reminder" "{
    \"token\": \"$FCM_TOKEN\",
    \"taskTitle\": \"Blumen für die Hochzeit bestellen\",
    \"dueDate\": \"2024-06-20\"
}" "Send Task Reminder Push Notification"

# Test 13: Send Collaboration Push
test_api "POST" "/api/notifications/collaboration" "{
    \"token\": \"$FCM_TOKEN\",
    \"collaboratorName\": \"Anna Schmidt\",
    \"action\": \"joined\"
}" "Send Collaboration Push Notification"

# Test 14: Subscribe to Topic
test_api "POST" "/api/notifications/subscribe" "{
    \"token\": \"$FCM_TOKEN\",
    \"topic\": \"wedding_updates\"
}" "Subscribe to Topic"

# Test 15: Unsubscribe from Topic
test_api "POST" "/api/notifications/unsubscribe" "{
    \"token\": \"$FCM_TOKEN\",
    \"topic\": \"wedding_updates\"
}" "Unsubscribe from Topic"

# Test 16: Get Push Notifications History
test_api "GET" "/api/notifications/sent" "" "Get Push Notifications History"

echo "🧪 ADVANCED TESTS"
echo "================="

# Test 17: Test Firebase Connection
test_api "GET" "/api/notifications/test" "" "Test Firebase Connection"

# Test 18: Test Email Connection
test_api "GET" "/api/email/test" "" "Test Email Connection"

# Test 19: Get Specific Notification (if any exist)
test_api "GET" "/api/notifications/sent" "" "Check for Notification IDs"

echo "📊 TESTING SUMMARY"
echo "=================="
echo ""
echo "🌐 Server: http://$SERVER"
echo "📧 Test Email: $EMAIL"
echo "🔔 FCM Token: ${FCM_TOKEN:0:50}..."
echo ""
echo "✅ If tests show SUCCESS, your APIs are working!"
echo "❌ If tests show FAILED, check server logs:"
echo "   ssh root@164.92.175.72"
echo "   pm2 logs 4secrets-wedding-api"
echo ""
echo "📱 Mobile App Configuration:"
echo "   const API_BASE_URL = 'http://$SERVER';"
echo ""
echo "🎉 Testing Complete!"
echo ""
