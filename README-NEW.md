# 4 Secrets Wedding API

A comprehensive API for the 4 Secrets Wedding mobile application, providing email services and Firebase push notifications with German language support.

## 🌟 Features

- **Email Services** - Wedding invitation emails using Brevo API
- **Push Notifications** - Firebase Cloud Messaging integration
- **German Language** - All email templates in German
- **Image Upload** - File upload functionality
- **Multi-Environment** - Firebase Functions and DigitalOcean deployment
- **Real-time Logging** - Comprehensive logging and monitoring

## 🚀 Quick Start

### Local Development

1. **Clone the repository:**
```bash
git clone https://github.com/WaseemMirzaa/four_wedding_app_cloud_function.git
cd four_wedding_app_cloud_function
```

2. **Install dependencies:**
```bash
npm install
```

3. **Start the development server:**
```bash
npm run dev:digitalocean
```

### DigitalOcean Deployment

**One-command deployment:**
```bash
curl -fsSL https://raw.githubusercontent.com/WaseemMirzaa/four_wedding_app_cloud_function/main/deploy-github-to-digitalocean.sh | bash
```

See [DEPLOYMENT.md](DEPLOYMENT.md) for detailed deployment instructions.

## 📧 Email API Endpoints

### Send Wedding Invitation
```bash
POST /api/email/send-invitation
Content-Type: application/json

{
  "email": "guest@example.com",
  "inviterName": "Sarah & Michael"
}
```

### Send Declined Invitation Notification
```bash
POST /api/email/declined-invitation
Content-Type: application/json

{
  "email": "host@example.com",
  "declinerName": "John Doe"
}
```

### Send Access Revoked Notification
```bash
POST /api/email/revoke-access
Content-Type: application/json

{
  "email": "user@example.com",
  "inviterName": "Sarah & Michael"
}
```

### Send Custom Email
```bash
POST /api/email/send
Content-Type: application/json

{
  "email": "recipient@example.com",
  "subject": "Custom Subject",
  "message": "Your custom message"
}
```

## 🔔 Notification API Endpoints

### Send Push Notification
```bash
POST /api/notifications/send
Content-Type: application/json

{
  "token": "FCM_DEVICE_TOKEN",
  "title": "Notification Title",
  "body": "Notification message",
  "data": {
    "key": "value"
  }
}
```

### Send Wedding Invitation Notification
```bash
POST /api/notifications/wedding-invitation
Content-Type: application/json

{
  "token": "FCM_DEVICE_TOKEN",
  "inviterName": "Sarah & Michael",
  "weddingDate": "2024-06-15"
}
```

## 🏗️ Project Structure

```
├── cloud-functions/
│   └── email-service/
│       └── functions/
│           ├── emailTemplates.js    # German email templates
│           ├── brevoEmailService.js # Brevo email integration
│           └── index.js             # Firebase Functions
├── src/                             # Original image upload API
├── digitalocean-server.js           # DigitalOcean deployment server
├── firebase-service-account.json    # Firebase credentials
├── .env.production                  # Production environment
├── ecosystem.config.js              # PM2 configuration
└── deploy-github-to-digitalocean.sh # Deployment script
```

## 🔧 Configuration

### Environment Variables
```env
PORT=3001
NODE_ENV=production
BREVO_API_KEY=your-brevo-api-key
EMAIL_FROM=support@brevo.4secrets-wedding-planner.de
FIREBASE_PROJECT_ID=secrets-wedding
```

### Firebase Configuration
- Project: `secrets-wedding`
- Service account included for push notifications
- Supports FCM token-based messaging

### Email Configuration
- Provider: Brevo (formerly Sendinblue)
- Language: German
- Templates: Wedding-specific (invitation, declined, revoked)

## 🧪 Testing

### Test Email Service
```bash
curl -X POST http://localhost:3001/api/email/send \
  -H 'Content-Type: application/json' \
  -d '{
    "email": "test@example.com",
    "subject": "Test Email",
    "message": "Hello from 4 Secrets Wedding!"
  }'
```

### Test Push Notifications
```bash
curl -X POST http://localhost:3001/api/notifications/send \
  -H 'Content-Type: application/json' \
  -d '{
    "token": "YOUR_FCM_TOKEN",
    "title": "Test Notification",
    "body": "Hello from 4 Secrets Wedding!"
  }'
```

## 📱 Mobile App Integration

This API is designed for the **4 Secrets Wedding** mobile application:
- **Android:** `com.app.four_secrets_wedding_app`
- **iOS:** Available on App Store

## 🔄 Development Workflow

1. **Make changes locally**
2. **Test with local server:** `npm run dev:digitalocean`
3. **Commit and push to GitHub**
4. **Deploy to DigitalOcean:** Run deployment script
5. **Test production endpoints**

## 📊 Monitoring

### Health Checks
- `GET /health` - Application status
- `GET /api/email/status` - Email service status
- `GET /api/notifications/status` - Firebase status

### Logs
```bash
# PM2 logs (production)
pm2 logs 4secrets-wedding-api

# Application logs
tail -f logs/combined.log
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test locally
5. Submit a pull request

## 📄 License

ISC License - See LICENSE file for details

## 🆘 Support

For deployment issues, see [DEPLOYMENT.md](DEPLOYMENT.md) or check:
- Application logs: `pm2 logs 4secrets-wedding-api`
- Health endpoint: `curl http://localhost:3001/health`
- Firebase status: `curl http://localhost:3001/api/notifications/status`
