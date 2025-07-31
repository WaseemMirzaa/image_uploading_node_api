#!/bin/bash

# Complete Email Testing Script for 4 Secrets Wedding API
# Tests all email types and endpoints

SERVER="164.92.175.72:3001"
TEST_EMAIL="m.waseemmirzaa@gmail.com"
BACKUP_EMAIL="unicorndev.02.1997@gmail.com"

echo "📧 4 Secrets Wedding - Complete Email Testing"
echo "============================================="
echo "Server: http://$SERVER"
echo "Primary Test Email: $TEST_EMAIL"
echo "Backup Test Email: $BACKUP_EMAIL"
echo "Date: $(date)"
echo ""

# Function to test email endpoint
test_email() {
    local endpoint=$1
    local data=$2
    local description=$3
    local email_type=$4
    
    echo "📨 Testing: $description"
    echo "   POST http://$SERVER$endpoint"
    echo "   Email Type: $email_type"
    
    response=$(timeout 15 curl -s -w "\nHTTP_CODE:%{http_code}" -X POST "http://$SERVER$endpoint" \
        -H "Content-Type: application/json" \
        -d "$data" 2>/dev/null)
    
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
    
    # Wait between requests to avoid rate limiting
    sleep 2
}

# Function to test GET endpoint
test_get_endpoint() {
    local endpoint=$1
    local description=$2
    
    echo "🔍 Testing: $description"
    echo "   GET http://$SERVER$endpoint"
    
    response=$(timeout 10 curl -s -w "\nHTTP_CODE:%{http_code}" "http://$SERVER$endpoint" 2>/dev/null)
    
    if [ $? -eq 0 ]; then
        http_code=$(echo "$response" | grep "HTTP_CODE:" | cut -d: -f2)
        body=$(echo "$response" | grep -v "HTTP_CODE:")
        
        if [ "$http_code" = "200" ]; then
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

echo "📋 STEP 1: Basic Health Checks"
echo "==============================="

# Test 1: Health Check
test_get_endpoint "/health" "Health Check"

# Test 2: Email API Status
test_get_endpoint "/api/email/status" "Email API Status"

echo "📧 STEP 2: Custom Email Tests"
echo "============================="

# Test 3: Send Custom Email - General Test
test_email "/api/email/send" "{
    \"email\": \"$TEST_EMAIL\",
    \"subject\": \"4 Secrets Wedding - API Test Email\",
    \"message\": \"Hello! This is a test email from your 4 Secrets Wedding API deployed on DigitalOcean. The email service is working perfectly! This email was sent on $(date).\",
    \"from\": \"4secrets-wedding@gmx.de\"
}" "Send Custom Email - General Test" "Custom Email"

# Test 4: Send Custom Email - HTML Content
test_email "/api/email/send" "{
    \"email\": \"$TEST_EMAIL\",
    \"subject\": \"4 Secrets Wedding - HTML Test Email\",
    \"message\": \"<h2>🎉 HTML Email Test</h2><p>This is an <strong>HTML formatted</strong> email from your 4 Secrets Wedding API.</p><ul><li>✅ Email service working</li><li>✅ HTML formatting supported</li><li>✅ Server deployed successfully</li></ul><p>Sent on: $(date)</p>\",
    \"from\": \"4secrets-wedding@gmx.de\"
}" "Send Custom Email - HTML Content" "HTML Email"

# Test 5: Send Custom Email - Long Content
test_email "/api/email/send" "{
    \"email\": \"$TEST_EMAIL\",
    \"subject\": \"4 Secrets Wedding - Long Content Test\",
    \"message\": \"This is a test email with longer content to verify that the email service can handle larger messages. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Your 4 Secrets Wedding API is working perfectly!\",
    \"from\": \"4secrets-wedding@gmx.de\"
}" "Send Custom Email - Long Content" "Long Content Email"

echo "💍 STEP 3: Wedding-Specific Email Tests"
echo "======================================="

# Test 6: Send Wedding Invitation Email
test_email "/api/email/send-invitation" "{
    \"email\": \"$TEST_EMAIL\",
    \"inviterName\": \"Sarah & Michael\"
}" "Send Wedding Invitation Email" "Wedding Invitation"

# Test 7: Send Wedding Invitation Email - Different Names
test_email "/api/email/send-invitation" "{
    \"email\": \"$TEST_EMAIL\",
    \"inviterName\": \"Anna & Thomas\"
}" "Send Wedding Invitation Email - Different Names" "Wedding Invitation"

# Test 8: Send Wedding Invitation to Backup Email
test_email "/api/email/send-invitation" "{
    \"email\": \"$BACKUP_EMAIL\",
    \"inviterName\": \"Lisa & David\"
}" "Send Wedding Invitation to Backup Email" "Wedding Invitation"

echo "❌ STEP 4: Declined Invitation Email Tests"
echo "=========================================="

# Test 9: Send Declined Invitation Email
test_email "/api/email/declined-invitation" "{
    \"email\": \"$TEST_EMAIL\",
    \"declinerName\": \"Test User\"
}" "Send Declined Invitation Email" "Declined Invitation"

# Test 10: Send Declined Invitation Email - Different Name
test_email "/api/email/declined-invitation" "{
    \"email\": \"$TEST_EMAIL\",
    \"declinerName\": \"Maria Schmidt\"
}" "Send Declined Invitation Email - Different Name" "Declined Invitation"

# Test 11: Send Declined Invitation to Backup Email
test_email "/api/email/declined-invitation" "{
    \"email\": \"$BACKUP_EMAIL\",
    \"declinerName\": \"John Doe\"
}" "Send Declined Invitation to Backup Email" "Declined Invitation"

echo "🔒 STEP 5: Access Management Email Tests"
echo "========================================"

# Test 12: Send Revoke Access Email
test_email "/api/email/revoke-access" "{
    \"email\": \"$TEST_EMAIL\",
    \"inviterName\": \"Admin User\"
}" "Send Revoke Access Email" "Revoke Access"

# Test 13: Send Revoke Access Email - Different Admin
test_email "/api/email/revoke-access" "{
    \"email\": \"$TEST_EMAIL\",
    \"inviterName\": \"Wedding Coordinator\"
}" "Send Revoke Access Email - Different Admin" "Revoke Access"

# Test 14: Send Revoke Access to Backup Email
test_email "/api/email/revoke-access" "{
    \"email\": \"$BACKUP_EMAIL\",
    \"inviterName\": \"System Administrator\"
}" "Send Revoke Access to Backup Email" "Revoke Access"

echo "📊 STEP 6: Email History and Status Tests"
echo "========================================="

# Test 15: Get Sent Emails History
test_get_endpoint "/api/email/sent" "Get Sent Emails History"

# Test 16: Test Email Connection
test_get_endpoint "/api/email/test" "Test Email Connection"

echo "🧪 STEP 7: Error Handling Tests"
echo "==============================="

# Test 17: Send Email with Missing Fields
test_email "/api/email/send" "{
    \"subject\": \"Missing Email Field Test\"
}" "Send Email with Missing Email Field" "Error Test"

# Test 18: Send Email with Invalid Email
test_email "/api/email/send" "{
    \"email\": \"invalid-email\",
    \"subject\": \"Invalid Email Test\",
    \"message\": \"This should fail\"
}" "Send Email with Invalid Email Address" "Error Test"

# Test 19: Send Wedding Invitation with Missing Name
test_email "/api/email/send-invitation" "{
    \"email\": \"$TEST_EMAIL\"
}" "Send Wedding Invitation with Missing Name" "Error Test"

echo "🔄 STEP 8: Bulk Email Tests"
echo "==========================="

# Test 20: Multiple Emails in Sequence
for i in {1..3}; do
    test_email "/api/email/send" "{
        \"email\": \"$TEST_EMAIL\",
        \"subject\": \"4 Secrets Wedding - Bulk Test Email #$i\",
        \"message\": \"This is bulk test email number $i of 3. Testing multiple email sending capability. Sent at $(date).\",
        \"from\": \"4secrets-wedding@gmx.de\"
    }" "Bulk Email Test #$i" "Bulk Email"
done

echo "📱 STEP 9: Special Character Tests"
echo "=================================="

# Test 21: Email with German Characters
test_email "/api/email/send" "{
    \"email\": \"$TEST_EMAIL\",
    \"subject\": \"4 Secrets Wedding - Umlaute Test (ÄÖÜäöüß)\",
    \"message\": \"Hallo! Dies ist ein Test mit deutschen Umlauten: ÄÖÜäöüß. Die E-Mail-Funktion unterstützt Sonderzeichen. Herzliche Grüße von Ihrer 4 Secrets Wedding API!\",
    \"from\": \"4secrets-wedding@gmx.de\"
}" "Email with German Characters" "Special Characters"

# Test 22: Email with Emojis
test_email "/api/email/send" "{
    \"email\": \"$TEST_EMAIL\",
    \"subject\": \"4 Secrets Wedding - Emoji Test 🎉💍❤️\",
    \"message\": \"Hello! 👋 This is an emoji test email 📧 from your 4 Secrets Wedding API 💒. Testing various emojis: 🎉🎊💍💒❤️💕👰🤵💐🌹🥂🍾. All working perfectly! ✅\",
    \"from\": \"4secrets-wedding@gmx.de\"
}" "Email with Emojis" "Emoji Test"

echo "📊 TESTING SUMMARY"
echo "=================="
echo ""
echo "🌐 Server: http://$SERVER"
echo "📧 Primary Test Email: $TEST_EMAIL"
echo "📧 Backup Test Email: $BACKUP_EMAIL"
echo "📅 Test Date: $(date)"
echo ""
echo "📋 Email Types Tested:"
echo "   ✅ Custom emails (general, HTML, long content)"
echo "   ✅ Wedding invitation emails"
echo "   ✅ Declined invitation emails"
echo "   ✅ Revoke access emails"
echo "   ✅ Bulk email sending"
echo "   ✅ Special characters (German umlauts)"
echo "   ✅ Emoji support"
echo "   ✅ Error handling"
echo ""
echo "🔍 Check Your Email Inbox:"
echo "   📧 $TEST_EMAIL"
echo "   📧 $BACKUP_EMAIL"
echo ""
echo "🔧 If emails are not received:"
echo "   1. Check spam/junk folder"
echo "   2. Verify Brevo API configuration"
echo "   3. Check server logs: pm2 logs 4secrets-wedding-api"
echo "   4. Test email status: curl http://$SERVER/api/email/status"
echo ""
echo "🎉 Email Testing Complete!"
echo ""
echo "📱 Next: Test push notifications with:"
echo "curl -X POST http://$SERVER/api/notifications/send \\"
echo "  -H 'Content-Type: application/json' \\"
echo "  -d '{\"token\":\"YOUR_FCM_TOKEN\",\"title\":\"Test\",\"body\":\"Hello!\"}'"
echo ""
