# Four Wedding Functions Node API

A Node.js Express API server providing image upload and email sending functionality.

## Features

- **Image Upload API**: Upload, list, and delete images
- **Email API**: Send emails with customizable content
- **Health Check**: Monitor server status
- **Security**: Helmet middleware for security headers
- **CORS**: Cross-origin resource sharing enabled
- **Logging**: Winston logger for comprehensive logging

## Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   npm install
   ```
3. Copy the environment configuration:
   ```bash
   cp .env.example .env
   ```
4. Configure your environment variables in `.env`
5. Start the server:
   ```bash
   # Development mode with auto-restart
   npm run dev
   
   # Production mode
   npm start
   ```

## Environment Configuration

### Required Variables
- `PORT`: Server port (default: 3000)
- `NODE_ENV`: Environment mode (development/production)

### Image Upload Configuration
- `UPLOAD_PATH`: Directory for uploaded images (default: src/images)
- `MAX_FILE_SIZE`: Maximum file size in bytes (default: 5MB)

### Email Configuration
For Gmail:
- `EMAIL_USER`: Your Gmail address
- `EMAIL_PASS`: App-specific password (not your regular password)
- `EMAIL_FROM`: From email address

For other SMTP providers:
- `SMTP_HOST`: SMTP server hostname
- `SMTP_PORT`: SMTP server port (default: 587)
- `EMAIL_USER`: SMTP username
- `EMAIL_PASS`: SMTP password
- `EMAIL_FROM`: From email address

## API Endpoints

### Health Check
- **GET** `/health` - Check server status

### Image API
- **POST** `/api/images/upload` - Upload an image
- **GET** `/api/images` - List all images
- **DELETE** `/api/images/delete` - Delete an image

### Email API
- **POST** `/api/email/send` - Send a custom email
- **POST** `/api/email/send-invitation` - Send invitation email (German)
- **POST** `/api/email/revoke-access` - Send access revoked email (German)
- **GET** `/api/email/test` - Test email service connection
- **GET** `/api/email/status` - Get email service status

## Email API Usage

### Send Custom Email
**POST** `/api/email/send`

**Request Body:**
```json
{
  "email": "recipient@example.com",
  "subject": "Your Subject Here",
  "message": "Your message content here",
  "from": "sender@example.com" // Optional, uses EMAIL_FROM if not provided
}
```

### Send Invitation Email
**POST** `/api/email/send-invitation`

Sends a pre-formatted German wedding invitation email for 4 Secrets Wedding App collaboration.

**Request Body:**
```json
{
  "email": "recipient@example.com",
  "name": "Recipient Name"
}
```

**Email Content:**
- **Subject:** "Du wurdest eingeladen, bei einer Hochzeits-Checkliste mitzuarbeiten 💍"
- **Message:** Wedding-themed German invitation message with emojis and app download instructions

### Send Access Revoked Email
**POST** `/api/email/revoke-access`

Sends a pre-formatted German email notifying that collaboration access has been removed.

**Request Body:**
```json
{
  "email": "recipient@example.com",
  "name": "Recipient Name"
}
```

**Email Content:**
- **Subject:** "4 Secrets - Zugriff auf Zusammenarbeit wurde entfernt"
- **Message:** Professional German message explaining that access has been revoked

### Response Format (All Email Endpoints)

**Success Response:**
```json
{
  "success": true,
  "message": "Email sent successfully",
  "data": {
    "to": "recipient@example.com",
    "subject": "Email Subject",
    "messageId": "<unique-message-id>",
    "previewUrl": null
  }
}
```

**Error Response:**
```json
{
  "error": "Missing required fields",
  "required": ["email", "name"],
  "received": ["email"]
}
```

### Test Email Connection
**GET** `/api/email/test`

**Response:**
```json
{
  "success": true,
  "message": "Email service connection is working"
}
```

### Email Service Status
**GET** `/api/email/status`

**Response:**
```json
{
  "service": "Email API",
  "status": "connected",
  "environment": "development",
  "configured": {
    "emailUser": true,
    "emailFrom": true
  }
}
```

## Development

### Test Email Setup
In development mode, if no email credentials are configured, the API will automatically create a test account using Ethereal Email. Check the console logs for the test account credentials and preview URLs.

### Gmail Setup
1. Enable 2-factor authentication on your Gmail account
2. Generate an app-specific password:
   - Go to Google Account settings
   - Security → 2-Step Verification → App passwords
   - Generate a password for "Mail"
3. Use the app-specific password in your `.env` file

## Error Handling

The API includes comprehensive error handling:
- Input validation for required fields
- Email format validation
- SMTP connection error handling
- Detailed error messages in development mode
- Sanitized error messages in production mode

## Logging

All email operations are logged using Winston:
- Successful email sends
- Failed email attempts
- Connection status changes
- API requests and responses

## Security

- Helmet middleware for security headers
- Input validation and sanitization
- Environment-based error message disclosure
- CORS configuration for cross-origin requests
