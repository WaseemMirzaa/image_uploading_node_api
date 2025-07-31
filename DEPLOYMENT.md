# 4 Secrets Wedding API - Deployment Guide

This guide explains how to deploy the 4 Secrets Wedding API to DigitalOcean using the GitHub repository.

## 🚀 Quick Deployment

### Prerequisites
- DigitalOcean droplet with Ubuntu 20.04+
- SSH access to your server
- Git installed on the server

### One-Command Deployment

1. **SSH into your DigitalOcean server:**
   ```bash
   ssh root@YOUR_SERVER_IP
   ```

2. **Run the deployment script:**
   ```bash
   curl -fsSL https://raw.githubusercontent.com/WaseemMirzaa/four_wedding_app_cloud_function/main/deploy-github-to-digitalocean.sh | bash
   ```

   Or manually:
   ```bash
   wget https://raw.githubusercontent.com/WaseemMirzaa/four_wedding_app_cloud_function/main/deploy-github-to-digitalocean.sh
   chmod +x deploy-github-to-digitalocean.sh
   ./deploy-github-to-digitalocean.sh
   ```

## 📋 What the Deployment Script Does

1. **Prepares deployment directory** (`/var/www/4secrets-wedding-api`)
2. **Stops existing applications** (PM2 processes, port conflicts)
3. **Clones/updates repository** from GitHub
4. **Installs dependencies** (Node.js, PM2, npm packages)
5. **Sets up environment** (`.env` file, permissions)
6. **Starts application** with PM2
7. **Tests all endpoints** (health, email, notifications)

## 🌐 API Endpoints

After deployment, your API will be available at:

### Health & Status
- `GET /health` - Application health check
- `GET /api/email/status` - Email service status
- `GET /api/notifications/status` - Firebase notifications status

### Email Endpoints
- `POST /api/email/send` - Send custom email
- `POST /api/email/send-invitation` - Send wedding invitation
- `POST /api/email/declined-invitation` - Send declined invitation notification
- `POST /api/email/revoke-access` - Send access revoked notification
- `GET /api/email/sent` - Get sent emails history

### Notification Endpoints
- `POST /api/notifications/send` - Send push notification
- `POST /api/notifications/wedding-invitation` - Send wedding invitation notification
- `POST /api/notifications/task-reminder` - Send task reminder notification
- `GET /api/notifications/sent` - Get sent notifications history

## 🧪 Testing Your Deployment

### Test Email Service
```bash
curl -X POST http://YOUR_SERVER_IP:3001/api/email/send \
  -H 'Content-Type: application/json' \
  -d '{
    "email": "test@example.com",
    "subject": "Test Email",
    "message": "Hello from 4 Secrets Wedding API!"
  }'
```

### Test Wedding Invitation Email
```bash
curl -X POST http://YOUR_SERVER_IP:3001/api/email/send-invitation \
  -H 'Content-Type: application/json' \
  -d '{
    "email": "guest@example.com",
    "inviterName": "Sarah & Michael"
  }'
```

### Test Push Notification
```bash
curl -X POST http://YOUR_SERVER_IP:3001/api/notifications/send \
  -H 'Content-Type: application/json' \
  -d '{
    "token": "YOUR_FCM_TOKEN",
    "title": "Test Notification",
    "body": "Hello from 4 Secrets Wedding API!"
  }'
```

## 🔧 Management Commands

### PM2 Process Management
```bash
# Check application status
pm2 status

# View logs
pm2 logs 4secrets-wedding-api

# Restart application
pm2 restart 4secrets-wedding-api

# Stop application
pm2 stop 4secrets-wedding-api

# Start application
pm2 start 4secrets-wedding-api
```

### Update Deployment
To update your deployment with latest changes from GitHub:
```bash
cd /var/www/4secrets-wedding-api
git pull origin main
npm install
pm2 restart 4secrets-wedding-api
```

## 📁 File Structure

```
/var/www/4secrets-wedding-api/
├── digitalocean-server.js          # Main server file for DigitalOcean
├── cloud-functions/
│   └── email-service/
│       └── functions/
│           ├── emailTemplates.js    # Email templates (German)
│           ├── brevoEmailService.js # Brevo email service
│           └── index.js             # Firebase Functions version
├── firebase-service-account.json   # Firebase credentials
├── .env                            # Environment variables
├── ecosystem.config.js             # PM2 configuration
├── package.json                    # Dependencies
└── logs/                           # Application logs
```

## 🔐 Environment Variables

The deployment automatically creates a `.env` file with:

```env
PORT=3001
NODE_ENV=production
BREVO_API_KEY=your-brevo-api-key
EMAIL_FROM=support@brevo.4secrets-wedding-planner.de
FIREBASE_PROJECT_ID=secrets-wedding
```

## 🔥 Firebase Configuration

The deployment includes Firebase service account credentials for push notifications. The Firebase project is already configured for the `secrets-wedding` project.

## 📧 Email Configuration

Emails are sent using Brevo API with the following configuration:
- **Provider:** Brevo (formerly Sendinblue)
- **From Email:** support@brevo.4secrets-wedding-planner.de
- **Templates:** German language wedding-specific templates

## 🚨 Troubleshooting

### Application Won't Start
```bash
# Check PM2 logs
pm2 logs 4secrets-wedding-api

# Check if port 3001 is available
lsof -i :3001

# Restart PM2
pm2 restart 4secrets-wedding-api
```

### Firebase Notifications Not Working
```bash
# Test Firebase status
curl http://localhost:3001/api/notifications/status

# Check Firebase service account file
ls -la firebase-service-account.json

# Restart application
pm2 restart 4secrets-wedding-api
```

### Email Service Issues
```bash
# Test email status
curl http://localhost:3001/api/email/status

# Check environment variables
cat .env | grep BREVO
```

## 🔄 Continuous Deployment

For automatic deployments when you push to GitHub, you can set up a webhook or use GitHub Actions. The deployment script is designed to be idempotent and can be run multiple times safely.

## 📞 Support

If you encounter any issues during deployment, check:
1. Server logs: `pm2 logs 4secrets-wedding-api`
2. Application health: `curl http://localhost:3001/health`
3. Port availability: `lsof -i :3001`
4. Environment configuration: `cat .env`

The deployment script provides detailed output and error messages to help troubleshoot any issues.
