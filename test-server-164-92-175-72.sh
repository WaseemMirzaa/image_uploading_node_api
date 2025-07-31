#!/bin/bash

# Quick Test Script for DigitalOcean Server
# IP: 164.92.175.72:3000

echo "🧪 Testing 4 Secrets Wedding API on DigitalOcean"
echo "Server: http://164.92.175.72:3000"
echo "Email: m.waseemmirzaa@gmail.com"
echo "================================================"
echo ""

# Test 1: Health Check
echo "1. Health Check..."
curl -s -w "Status: %{http_code}\n" http://164.92.175.72:3000/health
echo ""

# Test 2: Firebase Status
echo "2. Firebase Push Notifications Status..."
curl -s -w "Status: %{http_code}\n" http://164.92.175.72:3000/api/notifications/status
echo ""

# Test 3: Email Status
echo "3. Email API Status..."
curl -s -w "Status: %{http_code}\n" http://164.92.175.72:3000/api/email/status
echo ""

# Test 4: Send Test Email
echo "4. Sending Test Email to m.waseemmirzaa@gmail.com..."
curl -s -w "Status: %{http_code}\n" -X POST http://164.92.175.72:3000/api/email/send \
  -H 'Content-Type: application/json' \
  -d '{
    "email": "m.waseemmirzaa@gmail.com",
    "subject": "4 Secrets Wedding - DigitalOcean Test",
    "message": "Hello! Your 4 Secrets Wedding API is working perfectly on DigitalOcean! This email was sent from your production server.",
    "from": "4secrets-wedding@gmx.de"
  }'
echo ""

# Test 5: Send Wedding Invitation Email
echo "5. Sending Wedding Invitation Email..."
curl -s -w "Status: %{http_code}\n" -X POST http://164.92.175.72:3000/api/email/send-invitation \
  -H 'Content-Type: application/json' \
  -d '{
    "email": "m.waseemmirzaa@gmail.com",
    "inviterName": "Sarah & Michael"
  }'
echo ""

# Test 6: Send Push Notification
echo "6. Sending Push Notification..."
curl -s -w "Status: %{http_code}\n" -X POST http://164.92.175.72:3000/api/notifications/send \
  -H 'Content-Type: application/json' \
  -d '{
    "token": "eAxrpmKxSBu5ZctRtEcRpt:APA91bHoIGjjAq0mMOl83bjXq3Qw0T5Pe9pFnVacreW1-dhnbdcB5dXZzFdbSU9uUw_nPfNAFOI2tKUkOtPoMLIraN0Y9jew2jh-cqqs99xvEecakqjbbxY",
    "title": "🎉 DigitalOcean Test",
    "body": "Your 4 Secrets Wedding API is live on DigitalOcean! Push notifications working perfectly.",
    "data": {
      "type": "test",
      "server": "digitalocean",
      "ip": "164.92.175.72"
    }
  }'
echo ""

# Test 7: Send Wedding Invitation Push Notification
echo "7. Sending Wedding Invitation Push Notification..."
curl -s -w "Status: %{http_code}\n" -X POST http://164.92.175.72:3000/api/notifications/wedding-invitation \
  -H 'Content-Type: application/json' \
  -d '{
    "token": "eAxrpmKxSBu5ZctRtEcRpt:APA91bHoIGjjAq0mMOl83bjXq3Qw0T5Pe9pFnVacreW1-dhnbdcB5dXZzFdbSU9uUw_nPfNAFOI2tKUkOtPoMLIraN0Y9jew2jh-cqqs99xvEecakqjbbxY",
    "inviterName": "Sarah & Michael",
    "weddingDate": "2024-08-15"
  }'
echo ""

# Test 8: Get Sent Notifications
echo "8. Getting Sent Notifications History..."
curl -s -w "Status: %{http_code}\n" http://164.92.175.72:3000/api/notifications/sent
echo ""

# Test 9: Get Sent Emails
echo "9. Getting Sent Emails History..."
curl -s -w "Status: %{http_code}\n" http://164.92.175.72:3000/api/email/sent
echo ""

echo "🎉 Testing Complete!"
echo "==================="
echo ""
echo "✅ If all tests show Status: 200, your APIs are working!"
echo "📧 Check m.waseemmirzaa@gmail.com for test emails"
echo "🔔 Check your mobile device for push notifications"
echo ""
echo "🔧 Server Management:"
echo "ssh root@164.92.175.72"
echo "pm2 logs 4secrets-wedding-api"
echo "pm2 status"
echo ""
