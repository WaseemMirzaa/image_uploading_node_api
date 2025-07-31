# 4 Secrets Wedding Email Service - Cloud Function

This is the email service cloud function for the 4 Secrets Wedding app. It handles all email functionality using SMTP/Nodemailer.

## 📧 Features

- **Wedding Invitation Emails** - Send collaboration invitations
- **Declined Invitation Notifications** - Notify when invitations are declined
- **Access Revoked Emails** - Notify when access is removed
- **Custom Emails** - Send custom messages
- **Welcome Emails** - Welcome new users
- **Beautiful HTML Templates** - German language with wedding branding
- **Multiple SMTP Fallbacks** - Gmail, Mailgun, Ethereal
- **Email Tracking** - Track sent emails and status

## 🚀 API Endpoints

### Health & Status
- `GET /health` - Health check
- `GET /api/email/status` - Email service status

### Email Sending
- `POST /api/email/send-invitation` - Send wedding invitation
- `POST /api/email/declined-invitation` - Send declined notification
- `POST /api/email/revoke-access` - Send access revoked notification
- `POST /api/email/send-custom` - Send custom email
- `POST /api/email/send-welcome` - Send welcome email

### Email Management
- `GET /api/email/sent` - Get all sent emails
- `GET /api/email/:id` - Get specific email by ID

## 📋 Request Examples

### Send Wedding Invitation
```bash
curl -X POST http://localhost:3001/api/email/send-invitation \
  -H "Content-Type: application/json" \
  -d '{"email": "user@example.com", "inviterName": "John Doe"}'
```

### Send Declined Notification
```bash
curl -X POST http://localhost:3001/api/email/declined-invitation \
  -H "Content-Type: application/json" \
  -d '{"email": "admin@example.com", "declinerName": "Jane Smith"}'
```

### Send Access Revoked
```bash
curl -X POST http://localhost:3001/api/email/revoke-access \
  -H "Content-Type: application/json" \
  -d '{"email": "user@example.com", "inviterName": "Admin"}'
```

### Send Custom Email
```bash
curl -X POST http://localhost:3001/api/email/send-custom \
  -H "Content-Type: application/json" \
  -d '{"email": "user@example.com", "subject": "Custom Subject", "message": "Custom message content"}'
```

## ⚙️ Configuration

### Environment Variables

Copy `.env.example` to `.env` and configure:

```env
# Server Configuration
PORT=3001
NODE_ENV=development

# Primary SMTP Configuration
SMTP_HOST=smtp.gmail.com
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-app-password

# Email Settings
EMAIL_FROM=4secrets-wedding@gmx.de
```

### SMTP Providers Supported

1. **Gmail** (Recommended)
   - Host: `smtp.gmail.com`
   - Port: 587 (STARTTLS) or 465 (SSL)
   - Requires app password

2. **Mailgun**
   - Host: `smtp.mailgun.org`
   - Port: 587
   - Use SMTP credentials from Mailgun

3. **GMX**
   - Host: `mail.gmx.net`
   - Port: 587 or 465

4. **Ethereal** (Testing)
   - Automatic fallback for testing
   - Provides preview URLs

## 🛠️ Development

### Install Dependencies
```bash
cd cloud-functions/email-service
npm install
```

### Run Locally
```bash
npm run dev
```

### Run Tests
```bash
npm test
```

### Production Start
```bash
npm start
```

## 📧 Email Templates

All emails include:
- Beautiful HTML formatting
- Wedding-themed branding
- German language content
- App download links
- Responsive design
- Professional styling

### Template Types
- `invitation` - Wedding collaboration invitations
- `declined` - Invitation decline notifications
- `revoked` - Access revocation notices
- `welcome` - Welcome new users
- `custom` - Custom messages

## 🔧 Deployment

### Local Testing
1. Copy `.env.example` to `.env`
2. Configure SMTP credentials
3. Run `npm install`
4. Run `npm run dev`
5. Test endpoints

### Cloud Function Deployment
1. Configure environment variables in cloud platform
2. Deploy the entire `email-service` folder
3. Set entry point to `index.js`
4. Configure memory and timeout settings

### Environment Variables for Production
```env
SMTP_HOST=smtp.gmail.com
SMTP_USER=unicorndev.02.1997@gmail.com
SMTP_PASS=your-gmail-app-password
EMAIL_FROM=4secrets-wedding@gmx.de
NODE_ENV=production
```

## 📊 Response Format

### Success Response
```json
{
  "success": true,
  "message": "Email sent successfully",
  "messageId": "email-id-123",
  "previewUrl": "https://ethereal.email/message/...",
  "service": "SMTP Email Service",
  "timestamp": "2025-07-02T14:30:00.000Z"
}
```

### Error Response
```json
{
  "error": "Failed to send email",
  "message": "SMTP connection failed",
  "timestamp": "2025-07-02T14:30:00.000Z"
}
```

## 🔍 Monitoring

- All emails are logged with Winston
- Email status tracking
- Preview URLs for testing
- Error handling and reporting
- Connection verification

## 📱 Integration

This cloud function is designed to replace the email functionality in the main API. The main API will call these cloud function endpoints for all email operations.

## 🎯 Next Steps

1. Deploy as cloud function
2. Update main API to call cloud function endpoints
3. Configure production SMTP credentials
4. Test email delivery
5. Monitor email performance
