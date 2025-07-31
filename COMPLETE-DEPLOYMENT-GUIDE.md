# 🚀 Complete Deployment Guide - 4 Secrets Wedding API

## 📋 Overview
This guide will help you deploy the 4 Secrets Wedding API with Firebase push notifications to DigitalOcean using GitHub as the source.

## 🔐 Security Features
- ✅ `.env` file never pushed to GitHub
- ✅ Firebase credentials protected
- ✅ Automatic environment setup on server
- ✅ PM2 process management
- ✅ Firewall configuration

## 📦 What's Included
- **Email API**: Send wedding emails
- **Image API**: Upload and manage images
- **Push Notifications**: Firebase Cloud Messaging
- **German Templates**: Wedding-specific notifications
- **Health Monitoring**: Status endpoints

---

## 🚀 STEP 1: Push to GitHub

### 1.1 Prepare Local Environment
```bash
# Make scripts executable
chmod +x push-to-github.sh
chmod +x deploy-to-digitalocean.sh

# Verify .env is protected
cat .gitignore | grep .env
```

### 1.2 Push to GitHub
```bash
# Run the GitHub push script
./push-to-github.sh
```

**What this script does:**
- ✅ Checks git repository status
- ✅ Verifies `.env` is ignored (not pushed)
- ✅ Ensures `.env.example` exists
- ✅ Commits and pushes code to GitHub
- ✅ Protects sensitive Firebase credentials

**Expected Output:**
```
🎉 SUCCESS! Code pushed to GitHub successfully!

📋 Summary:
   Repository: https://github.com/WaseemMirzaa/four_wedding_app_cloud_function.git
   Branch: main
   Commit: Update 4 Secrets Wedding API with Firebase push notifications

🔒 Security Check:
   ✅ .env file NOT pushed (contains sensitive data)
   ✅ .env.example pushed (template for deployment)
   ✅ Firebase credentials protected
```

---

## 🌊 STEP 2: Deploy to DigitalOcean

### 2.1 Connect to Your DigitalOcean Server
```bash
# SSH into your DigitalOcean droplet
ssh root@YOUR_SERVER_IP
```

### 2.2 Download and Run Deployment Script
```bash
# Download the deployment script
curl -O https://raw.githubusercontent.com/WaseemMirzaa/four_wedding_app_cloud_function/main/deploy-to-digitalocean.sh

# Make it executable
chmod +x deploy-to-digitalocean.sh

# Run the deployment
sudo ./deploy-to-digitalocean.sh
```

**What this script does:**
- 🔧 Updates system and installs Node.js 18
- 📦 Installs PM2 process manager
- 📥 Clones repository from GitHub
- 📦 Installs npm dependencies
- 🔐 Creates `.env` with all Firebase credentials
- 🔥 Configures Firebase Admin SDK
- 🚀 Starts application with PM2
- 🛡️ Configures firewall (port 8080)
- 🧪 Tests deployment

### 2.3 Expected Deployment Output
```
🎉 DEPLOYMENT COMPLETE!
======================

📋 Deployment Summary:
   Application: 4secrets-wedding-api
   Directory: /var/www/4secrets-wedding-api
   Port: 3000
   Process Manager: PM2
   Environment: Production

🌐 Access URLs (Direct Port Access - No Nginx):
   Health Check: http://YOUR_SERVER_IP:3000/health
   API Status: http://YOUR_SERVER_IP:3000/api/notifications/status
   Email API: http://YOUR_SERVER_IP:3000/api/email/status
   Image API: http://YOUR_SERVER_IP:3000/api/images

🔔 Firebase Push Notifications:
   ✅ Firebase Admin SDK configured
   ✅ Project ID: secrets-wedding
   ✅ Service Account: firebase-adminsdk-fbsvc@secrets-wedding.iam.gserviceaccount.com
   ✅ Real push notifications enabled
```

---

## 🧪 STEP 3: Test Your Deployment

### 3.1 Health Check
```bash
curl http://YOUR_SERVER_IP:3000/health
# Expected: {"status":"ok"}
```

### 3.2 Firebase Status Check
```bash
curl http://YOUR_SERVER_IP:3000/api/notifications/status
```

**Expected Response:**
```json
{
  "service": "Push Notification API",
  "status": "connected",
  "environment": "production",
  "configured": {
    "firebaseProjectId": true,
    "firebaseServiceAccount": true
  }
}
```

### 3.3 Send Test Push Notification
```bash
curl -X POST http://YOUR_SERVER_IP:3000/api/notifications/send \
  -H 'Content-Type: application/json' \
  -d '{
    "token": "YOUR_FCM_TOKEN",
    "title": "🎉 Production Test",
    "body": "Your 4 Secrets Wedding API is live on DigitalOcean!"
  }'
```

### 3.4 Test Wedding Invitation
```bash
curl -X POST http://YOUR_SERVER_IP:3000/api/notifications/wedding-invitation \
  -H 'Content-Type: application/json' \
  -d '{
    "token": "YOUR_FCM_TOKEN",
    "inviterName": "Sarah & Michael",
    "weddingDate": "2024-08-15"
  }'
```

---

## 🔧 STEP 4: Server Management

### 4.1 PM2 Commands
```bash
# View application status
pm2 status

# View logs
pm2 logs 4secrets-wedding-api

# Restart application
pm2 restart 4secrets-wedding-api

# Stop application
pm2 stop 4secrets-wedding-api

# Monitor in real-time
pm2 monit
```

### 4.2 Update Deployment
```bash
# To update with new code from GitHub
cd /var/www/4secrets-wedding-api
git pull origin main
npm install
pm2 restart 4secrets-wedding-api
```

### 4.3 View Application Logs
```bash
# Real-time logs
pm2 logs 4secrets-wedding-api --lines 50

# Error logs only
pm2 logs 4secrets-wedding-api --err

# Application directory logs
tail -f /var/www/4secrets-wedding-api/logs/combined.log
```

---

## 📱 STEP 5: Mobile App Integration

### 5.1 Update Mobile App Configuration
Update your mobile app to use the production server:

```dart
// Flutter configuration
const String API_BASE_URL = 'http://YOUR_SERVER_IP:3000';

// Test notification
final response = await http.post(
  Uri.parse('$API_BASE_URL/api/notifications/wedding-invitation'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({
    'token': deviceToken,
    'inviterName': 'Test User',
    'weddingDate': '2024-08-15'
  }),
);
```

### 5.2 FCM Token Management
```dart
// Get FCM token in your Flutter app
String? token = await FirebaseMessaging.instance.getToken();
print('FCM Token: $token');

// Send to your API for testing
```

---

## 🔍 STEP 6: Troubleshooting

### 6.1 Common Issues

**Issue: Firebase not connected**
```bash
# Check Firebase configuration
cd /var/www/4secrets-wedding-api
cat .env | grep FIREBASE
pm2 logs 4secrets-wedding-api | grep Firebase
```

**Issue: Port not accessible**
```bash
# Check firewall
ufw status
# Check if application is running
pm2 status
# Check port binding
netstat -tlnp | grep 3000
```

**Issue: Application crashes**
```bash
# Check logs
pm2 logs 4secrets-wedding-api --err
# Restart application
pm2 restart 4secrets-wedding-api
```

### 6.2 Debug Commands
```bash
# Test local connectivity
curl http://localhost:3000/health

# Check process status
ps aux | grep node

# Check disk space
df -h

# Check memory usage
free -h
```

---

## 🎯 STEP 7: Production Checklist

### 7.1 Security Checklist
- ✅ `.env` file has proper permissions (600)
- ✅ Firebase credentials are secure
- ✅ Firewall is configured
- ✅ Application runs as www-data user
- ✅ PM2 auto-restart enabled

### 7.2 Performance Checklist
- ✅ PM2 process management active
- ✅ Application logs rotating
- ✅ Memory limits configured
- ✅ Auto-restart on crashes
- ✅ Health monitoring endpoints

### 7.3 Functionality Checklist
- ✅ Health endpoint responding
- ✅ Firebase push notifications working
- ✅ Email API functional
- ✅ Image upload working
- ✅ German notification templates active

---

## 🎉 SUCCESS!

Your 4 Secrets Wedding API is now deployed and running on DigitalOcean with:

- 🔔 **Real Firebase Push Notifications**
- 📧 **Email API**
- 📸 **Image Upload API**
- 🇩🇪 **German Wedding Templates**
- 🚀 **Production-Ready Infrastructure**

**Your API is accessible at:** `http://YOUR_SERVER_IP:3000`

**Ready for mobile app integration!** 💍✨
