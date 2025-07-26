# 4 Secrets Wedding - Email + File Upload Service

## 🚀 Features

- ✅ **Email Service** - Brevo API with German templates
- ✅ **File Upload** - All file types (50MB limit)
- ✅ **No SMTP Issues** - Uses HTTP API instead of SMTP ports
- ✅ **Production Ready** - PM2, logging, security, error handling
- ✅ **Mobile App Ready** - RESTful API for mobile integration

## 📧 Email APIs

- Send Wedding Invitations (German)
- Send Declined Notifications (German)
- Send Access Revoked Alerts (German)
- Send Custom Emails
- Send Welcome Emails (German)
- Get Email History

## 📄 File Upload APIs

- Upload Any File Type (50MB limit)
- Get All Files
- Delete Files
- Previous File Replacement

## 🛠️ Installation

```bash
# Clone repository
git clone https://github.com/WaseemMirzaa/four_wedding_app_cloud_function.git
cd four_wedding_app_cloud_function

# Install dependencies
npm install

# Start server
npm start

# For development
npm run dev
```

## 🧪 Testing

```bash
# Health check
curl http://localhost:3001/health

# Send test email
curl -X POST http://localhost:3001/api/email/send-invitation \
  -H "Content-Type: application/json" \
  -d '{"email": "test@example.com", "inviterName": "Test User"}'

# Upload test file
curl -X POST http://localhost:3001/api/images/upload \
  -F "image=@test-image.jpg"

# Get all files
curl http://localhost:3001/api/images
```

## 🌐 API Endpoints

### Email APIs
- `POST /api/email/send-invitation` - Send wedding invitation
- `POST /api/email/declined-invitation` - Send declined notification
- `POST /api/email/revoke-access` - Send access revoked notification
- `POST /api/email/send-custom` - Send custom email
- `POST /api/email/send-welcome` - Send welcome email
- `GET /api/email/sent` - Get all sent emails
- `GET /api/email/:id` - Get specific email

### File APIs
- `POST /api/images/upload` - Upload image/PDF
- `GET /api/images` - Get all files
- `DELETE /api/images/delete` - Delete file
- `GET /images/:filename` - View/download file

### System APIs
- `GET /health` - Health check
- `GET /api/email/status` - Email service status

## 🔧 Configuration

- **Port:** 3001 (configurable via PORT env var)
- **File Storage:** `./uploads/` directory
- **Max File Size:** 50MB
- **Supported Files:** All file types
- **Email Service:** Brevo API

## 📱 Mobile App Integration

```javascript
const API_BASE_URL = 'http://YOUR_SERVER_IP:3001';

// Send invitation
const response = await fetch(`${API_BASE_URL}/api/email/send-invitation`, {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    email: 'user@example.com',
    inviterName: 'John Doe'
  })
});

// Upload file
const formData = new FormData();
formData.append('image', fileObject);
const uploadResponse = await fetch(`${API_BASE_URL}/api/images/upload`, {
  method: 'POST',
  body: formData
});
```

## 🚀 DigitalOcean Deployment

Use the provided deployment script:

```bash
# On your DigitalOcean server
wget https://raw.githubusercontent.com/WaseemMirzaa/four_wedding_app_cloud_function/main/deploy.sh
chmod +x deploy.sh
sudo ./deploy.sh
```

## 📊 Response Formats

### Success Response
```json
{
  "success": true,
  "message": "Operation completed successfully",
  "timestamp": "2025-07-09T19:15:30.123Z"
}
```

### Error Response
```json
{
  "error": "Error type",
  "message": "Detailed error message",
  "timestamp": "2025-07-09T19:15:30.123Z"
}
```

## 🔒 Security

- Helmet.js security headers
- CORS enabled
- File type validation
- File size limits
- Input validation
- Error handling

## 📝 License

MIT License - see LICENSE file for details

## 🤝 Contributing

1. Fork the repository
2. Create feature branch
3. Commit changes
4. Push to branch
5. Create Pull Request

## 📞 Support

For issues or questions, check the server logs:
```bash
pm2 logs 4secrets-wedding-email
```
