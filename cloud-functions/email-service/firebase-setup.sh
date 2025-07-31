#!/bin/bash
echo "🔥 Setting up Firebase Cloud Functions for 4 Secrets Wedding Email Service"
echo "=========================================================================="

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() { echo -e "${GREEN}✅ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    print_warning "Firebase CLI not found. Installing..."
    npm install -g firebase-tools
fi

print_status "Firebase CLI is available"

# Login to Firebase (if not already logged in)
print_info "Checking Firebase authentication..."
firebase projects:list > /dev/null 2>&1
if [ $? -ne 0 ]; then
    print_warning "Please login to Firebase..."
    firebase login
fi

print_status "Firebase authentication verified"

# Initialize Firebase project
print_info "Initializing Firebase project..."

# Create firebase.json configuration
cat > firebase.json << 'EOF'
{
  "functions": [
    {
      "source": "functions",
      "codebase": "default",
      "ignore": [
        "node_modules",
        ".git",
        "firebase-debug.log",
        "firebase-debug.*.log"
      ],
      "predeploy": [
        "npm --prefix \"$RESOURCE_DIR\" run lint",
        "npm --prefix \"$RESOURCE_DIR\" run build"
      ]
    }
  ]
}
EOF

# Create .firebaserc configuration
cat > .firebaserc << 'EOF'
{
  "projects": {
    "default": "four-secrets-wedding"
  }
}
EOF

# Create functions directory
mkdir -p functions

# Create Firebase functions package.json
cat > functions/package.json << 'EOF'
{
  "name": "four-secrets-wedding-email-functions",
  "version": "1.0.0",
  "description": "4 Secrets Wedding Email Service - Firebase Cloud Functions",
  "main": "index.js",
  "scripts": {
    "lint": "eslint .",
    "build": "echo 'No build step required'",
    "serve": "firebase emulators:start --only functions",
    "shell": "firebase functions:shell",
    "start": "npm run shell",
    "deploy": "firebase deploy --only functions",
    "logs": "firebase functions:log"
  },
  "engines": {
    "node": "18"
  },
  "dependencies": {
    "firebase-admin": "^11.8.0",
    "firebase-functions": "^4.3.1",
    "nodemailer": "^6.9.8",
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "helmet": "^7.1.0",
    "winston": "^3.11.0"
  },
  "devDependencies": {
    "eslint": "^8.15.0",
    "eslint-config-google": "^0.14.0",
    "firebase-functions-test": "^3.1.0"
  },
  "private": true
}
EOF

# Copy our email service files to functions directory
print_info "Copying email service files to Firebase functions..."
cp emailService.js functions/
cp emailTemplates.js functions/

# Create Firebase Cloud Functions index.js
cat > functions/index.js << 'EOF'
const functions = require('firebase-functions');
const admin = require('firebase-admin');
const express = require('express');
const cors = require('cors');

// Initialize Firebase Admin
admin.initializeApp();

// Import our email service
const emailService = require('./emailService');
const emailTemplates = require('./emailTemplates');

const app = express();

// Middleware
app.use(cors({ origin: true }));
app.use(express.json());

// Logging middleware
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
  next();
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    service: '4 Secrets Wedding Email Service - Firebase',
    timestamp: new Date().toISOString(),
    version: '1.0.0'
  });
});

// Email service status
app.get('/api/email/status', async (req, res) => {
  try {
    const isConnected = await emailService.verifyConnection();
    res.json({
      status: 'Email API is working',
      connected: isConnected,
      service: 'Firebase Cloud Functions SMTP',
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.status(500).json({
      error: 'Email service error',
      message: error.message,
      timestamp: new Date().toISOString()
    });
  }
});

// Send wedding invitation email
app.post('/api/email/send-invitation', async (req, res) => {
  try {
    const { email, inviterName } = req.body;

    if (!email || !inviterName) {
      return res.status(400).json({
        error: 'Missing required fields',
        message: 'email and inviterName are required'
      });
    }

    const template = emailTemplates.invitation(inviterName);
    
    const result = await emailService.sendEmail({
      to: email,
      subject: template.subject,
      message: template.message,
      type: 'invitation'
    });

    res.json({
      success: true,
      message: 'Wedding invitation sent successfully',
      messageId: result.messageId,
      previewUrl: result.previewUrl,
      service: result.service,
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('Error sending invitation email:', error);
    res.status(500).json({
      error: 'Failed to send invitation email',
      message: error.message,
      timestamp: new Date().toISOString()
    });
  }
});

// Send declined invitation email
app.post('/api/email/declined-invitation', async (req, res) => {
  try {
    const { email, declinerName } = req.body;

    if (!email || !declinerName) {
      return res.status(400).json({
        error: 'Missing required fields',
        message: 'email and declinerName are required'
      });
    }

    const template = emailTemplates.declined(declinerName);
    
    const result = await emailService.sendEmail({
      to: email,
      subject: template.subject,
      message: template.message,
      type: 'declined'
    });

    res.json({
      success: true,
      message: 'Declined invitation notification sent successfully',
      messageId: result.messageId,
      previewUrl: result.previewUrl,
      service: result.service,
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('Error sending declined invitation email:', error);
    res.status(500).json({
      error: 'Failed to send declined invitation email',
      message: error.message,
      timestamp: new Date().toISOString()
    });
  }
});

// Send revoked access email
app.post('/api/email/revoke-access', async (req, res) => {
  try {
    const { email, inviterName } = req.body;

    if (!email || !inviterName) {
      return res.status(400).json({
        error: 'Missing required fields',
        message: 'email and inviterName are required'
      });
    }

    const template = emailTemplates.revoked(inviterName);
    
    const result = await emailService.sendEmail({
      to: email,
      subject: template.subject,
      message: template.message,
      type: 'revoked'
    });

    res.json({
      success: true,
      message: 'Access revoked notification sent successfully',
      messageId: result.messageId,
      previewUrl: result.previewUrl,
      service: result.service,
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('Error sending access revoked email:', error);
    res.status(500).json({
      error: 'Failed to send access revoked email',
      message: error.message,
      timestamp: new Date().toISOString()
    });
  }
});

// Send custom email
app.post('/api/email/send-custom', async (req, res) => {
  try {
    const { email, subject, message } = req.body;

    if (!email || !subject || !message) {
      return res.status(400).json({
        error: 'Missing required fields',
        message: 'email, subject, and message are required'
      });
    }

    const result = await emailService.sendEmail({
      to: email,
      subject: subject,
      message: message,
      type: 'custom'
    });

    res.json({
      success: true,
      message: 'Custom email sent successfully',
      messageId: result.messageId,
      previewUrl: result.previewUrl,
      service: result.service,
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('Error sending custom email:', error);
    res.status(500).json({
      error: 'Failed to send custom email',
      message: error.message,
      timestamp: new Date().toISOString()
    });
  }
});

// Get all sent emails
app.get('/api/email/sent', (req, res) => {
  try {
    const sentEmails = emailService.getSentEmails();
    res.json({
      success: true,
      count: sentEmails.length,
      emails: sentEmails,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.error('Error retrieving sent emails:', error);
    res.status(500).json({
      error: 'Failed to retrieve sent emails',
      message: error.message,
      timestamp: new Date().toISOString()
    });
  }
});

// Export the Express app as a Firebase Cloud Function
exports.emailService = functions.https.onRequest(app);

// Alternative: Individual function exports (if preferred)
exports.sendInvitation = functions.https.onCall(async (data, context) => {
  const { email, inviterName } = data;
  const template = emailTemplates.invitation(inviterName);
  return await emailService.sendEmail({
    to: email,
    subject: template.subject,
    message: template.message,
    type: 'invitation'
  });
});

exports.sendDeclined = functions.https.onCall(async (data, context) => {
  const { email, declinerName } = data;
  const template = emailTemplates.declined(declinerName);
  return await emailService.sendEmail({
    to: email,
    subject: template.subject,
    message: template.message,
    type: 'declined'
  });
});

exports.revokeAccess = functions.https.onCall(async (data, context) => {
  const { email, inviterName } = data;
  const template = emailTemplates.revoked(inviterName);
  return await emailService.sendEmail({
    to: email,
    subject: template.subject,
    message: template.message,
    type: 'revoked'
  });
});
EOF

# Create .env file for local development
cat > functions/.env << 'EOF'
# SMTP Configuration for Firebase Cloud Functions
SMTP_HOST=smtp.gmail.com
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-app-password
EMAIL_FROM=4secrets-wedding@gmx.de

# Alternative SMTP providers:
# For Mailgun:
# SMTP_HOST=smtp.mailgun.org
# MAILGUN_SMTP_USER=postmaster@your-domain.mailgun.org
# MAILGUN_SMTP_PASS=your-mailgun-smtp-password

# For GMX:
# SMTP_HOST=mail.gmx.net
# SMTP_USER=4secrets-wedding@gmx.de
# SMTP_PASS=4WZQZZ5N2QV3PE7MKR5D
EOF

# Install dependencies
print_info "Installing Firebase functions dependencies..."
cd functions
npm install

print_status "Firebase Cloud Functions setup complete!"

echo ""
echo "🎉 FIREBASE SETUP COMPLETE!"
echo "=========================="
echo ""
print_status "Next steps:"
echo "1. Configure SMTP credentials in functions/.env"
echo "2. Test locally: firebase emulators:start --only functions"
echo "3. Deploy: firebase deploy --only functions"
echo ""
print_status "Local development:"
echo "firebase emulators:start --only functions"
echo ""
print_status "Deploy to Firebase:"
echo "firebase deploy --only functions"
echo ""
print_status "Function URLs will be:"
echo "https://us-central1-four-secrets-wedding.cloudfunctions.net/emailService/health"
echo "https://us-central1-four-secrets-wedding.cloudfunctions.net/emailService/api/email/send-invitation"
EOF
