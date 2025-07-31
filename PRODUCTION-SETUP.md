# 🚀 4 Secrets Wedding API - Production Setup

## ⚠️ IMPORTANT: Real Credentials Required

This repository contains template files with placeholder credentials. For production deployment, you need to update these files with your actual credentials.

## 🔧 Setup Instructions

### 1. Update Environment Variables

Edit `.env` file and replace placeholders:

```bash
# Email Configuration - Brevo API (UPDATE WITH REAL CREDENTIALS)
BREVO_API_KEY=your-actual-brevo-api-key-here
EMAIL_FROM=your-verified-sender-email@domain.com

# Firebase Configuration (UPDATE WITH REAL CREDENTIALS)
FIREBASE_PROJECT_ID=your-actual-firebase-project-id
```

### 2. Update Firebase Service Account

Edit `firebase-service-account.json` with your actual Firebase service account credentials:

```json
{
  "type": "service_account",
  "project_id": "your-actual-firebase-project-id",
  "private_key_id": "your-actual-private-key-id",
  "private_key": "-----BEGIN PRIVATE KEY-----\nYOUR_ACTUAL_PRIVATE_KEY_HERE\n-----END PRIVATE KEY-----\n",
  "client_email": "firebase-adminsdk-xxxxx@your-project.iam.gserviceaccount.com",
  "client_id": "your-actual-client-id",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-xxxxx%40your-project.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
}
```

### 3. Quick Deployment Commands

For DigitalOcean deployment:

```bash
# Clone repository
git clone https://github.com/WaseemMirzaa/four_wedding_app_cloud_function.git
cd four_wedding_app_cloud_function

# Install dependencies
npm install

# Update credentials (edit .env and firebase-service-account.json)
nano .env
nano firebase-service-account.json

# Create required directories
mkdir -p src/files logs

# Start with PM2
pm2 start server.js --name "4secrets-wedding-api"
pm2 save
pm2 startup
```

## 🧪 Testing

After updating credentials, test all APIs:

```bash
# Health check
curl http://localhost:3001/health

# Email status
curl http://localhost:3001/api/email/status

# Firebase status
curl http://localhost:3001/api/notifications/status

# File upload test
curl -X POST -F "file=@test.jpg" http://localhost:3001/upload
```

## 📋 Available APIs

### Email APIs
- `POST /api/email/send` - Send generic email
- `POST /api/email/send-invitation` - Send wedding invitation
- `POST /api/email/declined-invitation` - Send declined notification
- `POST /api/email/revoke-access` - Send access revoked notification
- `GET /api/email/status` - Email service status

### Notification APIs
- `POST /api/notifications/send` - Send push notification
- `POST /api/notifications/wedding-invitation` - Send wedding notification
- `POST /api/notifications/task-reminder` - Send task reminder
- `GET /api/notifications/status` - Notification service status
- `GET /api/notifications/test` - Test Firebase connection

### File Upload APIs
- `POST /upload` - Upload any file type
- `GET /files/` - List all files
- `DELETE /files/delete` - Delete file
- `GET /files/status` - File service status

### Legacy Image APIs (backward compatibility)
- `POST /api/images/upload` - Upload image
- `GET /api/images` - List images
- `DELETE /api/images/delete` - Delete image

## 🔐 Security Notes

- Never commit real credentials to version control
- Use environment variables for sensitive data
- The template files are safe to commit
- Real credentials should be configured on the server

## 🚀 Production Ready

Once credentials are updated, your API supports:
- ✅ Email services (German templates)
- ✅ Firebase push notifications
- ✅ Universal file upload (10MB limit)
- ✅ Complete wedding app functionality
- ✅ Health monitoring
- ✅ Error handling
- ✅ Security headers
- ✅ CORS support

Your 4 Secrets Wedding API is ready for production use!
