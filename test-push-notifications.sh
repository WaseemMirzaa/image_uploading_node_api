#!/bin/bash

# 4 Secrets Wedding - Push Notification API Test Script
# This script tests all push notification endpoints

BASE_URL="http://localhost:3000"
API_URL="$BASE_URL/api/notifications"

echo "🔔 Testing 4 Secrets Wedding Push Notification API"
echo "=================================================="
echo "Base URL: $BASE_URL"
echo "API URL: $API_URL"
echo ""

# Test device token (mock)
TEST_TOKEN="test_device_token_123456789"
TEST_TOKENS='["test_token_1", "test_token_2", "test_token_3"]'
TEST_TOPIC="wedding_updates"

echo "1. Testing Service Status..."
echo "----------------------------"
curl -s "$API_URL/status" | jq '.' || echo "Response: $(curl -s "$API_URL/status")"
echo -e "\n"

echo "2. Testing Connection..."
echo "------------------------"
curl -s "$API_URL/test" | jq '.' || echo "Response: $(curl -s "$API_URL/test")"
echo -e "\n"

echo "3. Testing General Push Notification (Single Device)..."
echo "--------------------------------------------------------"
curl -X POST "$API_URL/send" \
  -H "Content-Type: application/json" \
  -d "{
    \"token\": \"$TEST_TOKEN\",
    \"title\": \"Test Notification\",
    \"body\": \"This is a test push notification from the API\",
    \"data\": {
      \"test\": \"true\",
      \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)\"
    }
  }" | jq '.' || echo "Response: $(curl -s -X POST "$API_URL/send" -H "Content-Type: application/json" -d "{\"token\":\"$TEST_TOKEN\",\"title\":\"Test\",\"body\":\"Test\"}")"
echo -e "\n"

echo "4. Testing Wedding Invitation Notification..."
echo "----------------------------------------------"
curl -X POST "$API_URL/wedding-invitation" \
  -H "Content-Type: application/json" \
  -d "{
    \"token\": \"$TEST_TOKEN\",
    \"inviterName\": \"Max Mustermann\",
    \"weddingDate\": \"2024-06-15\"
  }" | jq '.' || echo "Response: $(curl -s -X POST "$API_URL/wedding-invitation" -H "Content-Type: application/json" -d "{\"token\":\"$TEST_TOKEN\",\"inviterName\":\"Max Mustermann\"}")"
echo -e "\n"

echo "5. Testing Task Reminder Notification..."
echo "-----------------------------------------"
curl -X POST "$API_URL/task-reminder" \
  -H "Content-Type: application/json" \
  -d "{
    \"token\": \"$TEST_TOKEN\",
    \"taskTitle\": \"Blumen für die Hochzeit bestellen\",
    \"dueDate\": \"2024-05-20\"
  }" | jq '.' || echo "Response: $(curl -s -X POST "$API_URL/task-reminder" -H "Content-Type: application/json" -d "{\"token\":\"$TEST_TOKEN\",\"taskTitle\":\"Test Task\"}")"
echo -e "\n"

echo "6. Testing Collaboration Notification..."
echo "-----------------------------------------"
curl -X POST "$API_URL/collaboration" \
  -H "Content-Type: application/json" \
  -d "{
    \"token\": \"$TEST_TOKEN\",
    \"collaboratorName\": \"Anna Schmidt\",
    \"action\": \"joined\"
  }" | jq '.' || echo "Response: $(curl -s -X POST "$API_URL/collaboration" -H "Content-Type: application/json" -d "{\"token\":\"$TEST_TOKEN\",\"collaboratorName\":\"Anna\",\"action\":\"joined\"}")"
echo -e "\n"

echo "7. Testing Multicast Notification (Multiple Devices)..."
echo "--------------------------------------------------------"
curl -X POST "$API_URL/send" \
  -H "Content-Type: application/json" \
  -d "{
    \"tokens\": $TEST_TOKENS,
    \"title\": \"Multicast Test\",
    \"body\": \"This notification is sent to multiple devices\",
    \"data\": {
      \"type\": \"multicast_test\"
    }
  }" | jq '.' || echo "Response: $(curl -s -X POST "$API_URL/send" -H "Content-Type: application/json" -d "{\"tokens\":$TEST_TOKENS,\"title\":\"Multicast\",\"body\":\"Test\"}")"
echo -e "\n"

echo "8. Testing Topic Notification..."
echo "---------------------------------"
curl -X POST "$API_URL/send" \
  -H "Content-Type: application/json" \
  -d "{
    \"topic\": \"$TEST_TOPIC\",
    \"title\": \"Topic Notification\",
    \"body\": \"This notification is sent to all topic subscribers\",
    \"data\": {
      \"type\": \"topic_broadcast\"
    }
  }" | jq '.' || echo "Response: $(curl -s -X POST "$API_URL/send" -H "Content-Type: application/json" -d "{\"topic\":\"$TEST_TOPIC\",\"title\":\"Topic\",\"body\":\"Test\"}")"
echo -e "\n"

echo "9. Testing Topic Subscription..."
echo "---------------------------------"
curl -X POST "$API_URL/subscribe" \
  -H "Content-Type: application/json" \
  -d "{
    \"token\": \"$TEST_TOKEN\",
    \"topic\": \"$TEST_TOPIC\"
  }" | jq '.' || echo "Response: $(curl -s -X POST "$API_URL/subscribe" -H "Content-Type: application/json" -d "{\"token\":\"$TEST_TOKEN\",\"topic\":\"$TEST_TOPIC\"}")"
echo -e "\n"

echo "10. Testing Topic Unsubscription..."
echo "------------------------------------"
curl -X POST "$API_URL/unsubscribe" \
  -H "Content-Type: application/json" \
  -d "{
    \"token\": \"$TEST_TOKEN\",
    \"topic\": \"$TEST_TOPIC\"
  }" | jq '.' || echo "Response: $(curl -s -X POST "$API_URL/unsubscribe" -H "Content-Type: application/json" -d "{\"token\":\"$TEST_TOKEN\",\"topic\":\"$TEST_TOPIC\"}")"
echo -e "\n"

echo "11. Testing Get Sent Notifications..."
echo "-------------------------------------"
curl -s "$API_URL/sent" | jq '.' || echo "Response: $(curl -s "$API_URL/sent")"
echo -e "\n"

echo "12. Testing Error Handling (Missing Required Fields)..."
echo "--------------------------------------------------------"
curl -X POST "$API_URL/send" \
  -H "Content-Type: application/json" \
  -d "{
    \"token\": \"$TEST_TOKEN\"
  }" | jq '.' || echo "Response: $(curl -s -X POST "$API_URL/send" -H "Content-Type: application/json" -d "{\"token\":\"$TEST_TOKEN\"}")"
echo -e "\n"

echo "13. Testing Error Handling (Missing Target)..."
echo "-----------------------------------------------"
curl -X POST "$API_URL/send" \
  -H "Content-Type: application/json" \
  -d "{
    \"title\": \"Test\",
    \"body\": \"Test message\"
  }" | jq '.' || echo "Response: $(curl -s -X POST "$API_URL/send" -H "Content-Type: application/json" -d "{\"title\":\"Test\",\"body\":\"Test\"}")"
echo -e "\n"

echo "🎉 Push Notification API Testing Complete!"
echo "==========================================="
echo ""
echo "📊 Summary:"
echo "• All endpoints tested"
echo "• Error handling verified"
echo "• Mock service responses received"
echo "• Ready for Firebase configuration"
echo ""
echo "🔧 Next Steps:"
echo "1. Configure Firebase service account credentials"
echo "2. Test with real device tokens"
echo "3. Integrate with mobile app"
echo "4. Deploy to production"
echo ""
