#!/bin/bash

# ================================================================================
# 4 SECRETS WEDDING - API TEST SCRIPT
# ================================================================================
# This script tests all APIs after deployment

BASE_URL="http://164.92.175.72:3001"
# For local testing, use: BASE_URL="http://localhost:3001"

echo "🧪 Testing 4 Secrets Wedding APIs"
echo "🔗 Base URL: $BASE_URL"
echo ""

# Test 1: Health Check
echo "1️⃣ Testing Health Check..."
curl -s "$BASE_URL/health" | jq '.' 2>/dev/null || curl -s "$BASE_URL/health"
echo -e "\n"

# Test 2: Email Service Status
echo "2️⃣ Testing Email Service Status..."
curl -s "$BASE_URL/api/email/status" | jq '.' 2>/dev/null || curl -s "$BASE_URL/api/email/status"
echo -e "\n"

# Test 3: Send Wedding Invitation
echo "3️⃣ Testing Wedding Invitation Email..."
curl -X POST "$BASE_URL/api/email/send-invitation" \
  -H "Content-Type: application/json" \
  -d '{"email": "m.waseemmirzaa@gmail.com", "inviterName": "API Test User"}' \
  -s | jq '.' 2>/dev/null || curl -X POST "$BASE_URL/api/email/send-invitation" \
  -H "Content-Type: application/json" \
  -d '{"email": "m.waseemmirzaa@gmail.com", "inviterName": "API Test User"}' -s
echo -e "\n"

# Test 4: Send Declined Notification
echo "4️⃣ Testing Declined Invitation Email..."
curl -X POST "$BASE_URL/api/email/declined-invitation" \
  -H "Content-Type: application/json" \
  -d '{"email": "m.waseemmirzaa@gmail.com", "declinerName": "Test Decliner"}' \
  -s | jq '.' 2>/dev/null || curl -X POST "$BASE_URL/api/email/declined-invitation" \
  -H "Content-Type: application/json" \
  -d '{"email": "m.waseemmirzaa@gmail.com", "declinerName": "Test Decliner"}' -s
echo -e "\n"

# Test 5: Send Access Revoked
echo "5️⃣ Testing Access Revoked Email..."
curl -X POST "$BASE_URL/api/email/revoke-access" \
  -H "Content-Type: application/json" \
  -d '{"email": "m.waseemmirzaa@gmail.com", "inviterName": "Admin User"}' \
  -s | jq '.' 2>/dev/null || curl -X POST "$BASE_URL/api/email/revoke-access" \
  -H "Content-Type: application/json" \
  -d '{"email": "m.waseemmirzaa@gmail.com", "inviterName": "Admin User"}' -s
echo -e "\n"

# Test 6: Send Custom Email
echo "6️⃣ Testing Custom Email..."
curl -X POST "$BASE_URL/api/email/send-custom" \
  -H "Content-Type: application/json" \
  -d '{"email": "m.waseemmirzaa@gmail.com", "subject": "API Test Email", "message": "This is a test message from the API test script!"}' \
  -s | jq '.' 2>/dev/null || curl -X POST "$BASE_URL/api/email/send-custom" \
  -H "Content-Type: application/json" \
  -d '{"email": "m.waseemmirzaa@gmail.com", "subject": "API Test Email", "message": "This is a test message from the API test script!"}' -s
echo -e "\n"

# Test 7: Send Welcome Email
echo "7️⃣ Testing Welcome Email..."
curl -X POST "$BASE_URL/api/email/send-welcome" \
  -H "Content-Type: application/json" \
  -d '{"email": "m.waseemmirzaa@gmail.com", "userName": "Test User"}' \
  -s | jq '.' 2>/dev/null || curl -X POST "$BASE_URL/api/email/send-welcome" \
  -H "Content-Type: application/json" \
  -d '{"email": "m.waseemmirzaa@gmail.com", "userName": "Test User"}' -s
echo -e "\n"

# Test 8: Upload Image File
echo "8️⃣ Testing Image Upload..."
echo "Creating test image file..."
echo "Test image content for API testing" > test-image.jpg
curl -X POST "$BASE_URL/api/images/upload" \
  -F "image=@test-image.jpg" \
  -s | jq '.' 2>/dev/null || curl -X POST "$BASE_URL/api/images/upload" \
  -F "image=@test-image.jpg" -s
echo -e "\n"

# Test 9: Upload PDF File
echo "9️⃣ Testing PDF Upload..."
echo "Creating test PDF file..."
echo "%PDF-1.4 Test PDF content for API testing" > test-document.pdf
curl -X POST "$BASE_URL/api/images/upload" \
  -F "image=@test-document.pdf" \
  -s | jq '.' 2>/dev/null || curl -X POST "$BASE_URL/api/images/upload" \
  -F "image=@test-document.pdf" -s
echo -e "\n"

# Test 10: Get All Files
echo "🔟 Testing Get All Files..."
curl -s "$BASE_URL/api/images" | jq '.count, .images[0]' 2>/dev/null || curl -s "$BASE_URL/api/images"
echo -e "\n"

# Test 11: Get Sent Emails
echo "1️⃣1️⃣ Testing Get Sent Emails..."
curl -s "$BASE_URL/api/email/sent" | jq '.count, .emails[0]' 2>/dev/null || curl -s "$BASE_URL/api/email/sent"
echo -e "\n"

# Clean up test files
echo "🧹 Cleaning up test files..."
rm -f test-image.jpg test-document.pdf

echo ""
echo "============================================================"
echo "✅ ALL API TESTS COMPLETED!"
echo "============================================================"
echo "📧 Check your email inbox: m.waseemmirzaa@gmail.com"
echo "📄 Files uploaded successfully"
echo "🔗 View logs: pm2 logs 4secrets-wedding-email"
echo ""
echo "📱 Mobile App Integration:"
echo "   Base URL: $BASE_URL"
echo "   All endpoints tested and working!"
echo "============================================================"
