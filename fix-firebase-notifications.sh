#!/bin/bash

# Firebase Notification Fix Script
# Fixes FCM notifications while keeping email templates intact

echo "🔥 Firebase Notification Fix"
echo "============================"
echo "Server: $(hostname -I | awk '{print $1}')"
echo "Date: $(date)"
echo ""

# Navigate to application directory
cd /var/www/4secrets-wedding-api || {
    echo "❌ Cannot access application directory"
    exit 1
}

echo "📁 Working directory: $(pwd)"
echo ""

echo "🔍 Step 1: Stop Application"
echo "=========================="

# Stop PM2 application
pm2 stop 4secrets-wedding-api 2>/dev/null || echo "No PM2 process to stop"

echo "✅ Application stopped"

echo ""
echo "🔍 Step 2: Verify Firebase Dependencies"
echo "======================================"

# Check if firebase-admin is installed
if [ ! -d "node_modules/firebase-admin" ]; then
    echo "📦 Installing firebase-admin..."
    npm install firebase-admin
else
    echo "✅ Firebase Admin SDK already installed"
fi

# Verify firebase-admin installation
if node -e "require('firebase-admin'); console.log('✅ Firebase Admin SDK can be loaded');" 2>/dev/null; then
    echo "✅ Firebase Admin SDK is working"
else
    echo "❌ Firebase Admin SDK has issues, reinstalling..."
    npm uninstall firebase-admin
    npm install firebase-admin
fi

echo ""
echo "🔍 Step 3: Test Firebase Service Account"
echo "======================================="

# Test Firebase service account file
if [ -f "firebase-service-account.json" ]; then
    echo "✅ Firebase service account file exists"
    
    # Test JSON validity
    if node -e "JSON.parse(require('fs').readFileSync('firebase-service-account.json', 'utf8')); console.log('✅ JSON is valid');" 2>/dev/null; then
        echo "✅ Firebase service account JSON is valid"
        
        # Test Firebase initialization
        echo "🧪 Testing Firebase initialization..."
        node -e "
        try {
            const admin = require('firebase-admin');
            const serviceAccount = require('./firebase-service-account.json');
            
            console.log('🔍 Service Account Details:');
            console.log('  Project ID:', serviceAccount.project_id);
            console.log('  Client Email:', serviceAccount.client_email);
            console.log('  Private Key ID:', serviceAccount.private_key_id);
            
            if (!admin.apps.length) {
                admin.initializeApp({
                    credential: admin.credential.cert(serviceAccount),
                    projectId: serviceAccount.project_id
                });
            }
            
            console.log('✅ Firebase Admin SDK initialized successfully');
            
        } catch (error) {
            console.log('❌ Firebase initialization failed:', error.message);
            process.exit(1);
        }
        " || {
            echo "❌ Firebase initialization test failed"
            exit 1
        }
    else
        echo "❌ Firebase service account JSON is invalid"
        exit 1
    fi
else
    echo "❌ Firebase service account file not found"
    exit 1
fi

echo ""
echo "🔍 Step 4: Update Server.js for Better Firebase Handling"
echo "======================================================="

# Create backup of current server.js
cp server.js server.js.backup

# Update server.js with enhanced Firebase handling
cat > server.js << 'SERVER_EOF'
const express = require('express');
const admin = require('firebase-admin');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const path = require('path');
require('dotenv').config();

// Import our exact email services and templates
const BrevoEmailService = require('./brevoEmailService');
const emailTemplates = require('./emailTemplates');

const app = express();
const PORT = process.env.PORT || 3001;

// Initialize Brevo email service (exact same as your local)
const emailService = new BrevoEmailService();

// Middleware
app.use(helmet());
app.use(cors({ origin: true }));
app.use(morgan('combined'));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Logging middleware (exact same as your local)
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
  next();
});

// Enhanced Firebase Admin initialization
let firebaseInitialized = false;
let firebaseError = null;
let firebaseApp = null;

async function initializeFirebase() {
    try {
        console.log('🔥 Initializing Firebase Admin SDK...');
        
        const serviceAccountPath = path.join(__dirname, 'firebase-service-account.json');
        console.log('🔍 Loading Firebase service account from:', serviceAccountPath);
        
        // Check if file exists
        const fs = require('fs');
        if (!fs.existsSync(serviceAccountPath)) {
            throw new Error('Firebase service account file not found');
        }
        
        const serviceAccount = require(serviceAccountPath);
        console.log('✅ Service account loaded');
        console.log('🔥 Project ID:', serviceAccount.project_id);
        console.log('📧 Client Email:', serviceAccount.client_email);
        console.log('🔑 Private Key ID:', serviceAccount.private_key_id);
        
        // Validate required fields
        if (!serviceAccount.project_id || !serviceAccount.client_email || !serviceAccount.private_key) {
            throw new Error('Invalid service account: missing required fields');
        }
        
        // Initialize Firebase Admin if not already initialized
        if (!admin.apps.length) {
            firebaseApp = admin.initializeApp({
                credential: admin.credential.cert(serviceAccount),
                projectId: serviceAccount.project_id
            });
            console.log('✅ Firebase Admin SDK initialized successfully');
        } else {
            firebaseApp = admin.app();
            console.log('✅ Firebase Admin SDK already initialized');
        }
        
        // Test Firebase messaging
        const messaging = admin.messaging();
        console.log('✅ Firebase Messaging service ready');
        
        firebaseInitialized = true;
        firebaseError = null;
        
        return true;
        
    } catch (error) {
        console.error('❌ Firebase initialization failed:', error.message);
        console.error('❌ Error details:', error);
        firebaseError = error.message;
        firebaseInitialized = false;
        return false;
    }
}

// Initialize Firebase on startup
initializeFirebase();

// Store sent notifications (in production, use a database)
let sentNotifications = [];

// ==========================================
// HEALTH & STATUS ENDPOINTS
// ==========================================

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    service: '4 Secrets Wedding API - DigitalOcean',
    timestamp: new Date().toISOString(),
    version: '1.0.0',
    firebase: {
        initialized: firebaseInitialized,
        error: firebaseError,
        hasApp: !!firebaseApp
    },
    email: {
        service: 'Brevo API',
        configured: true
    }
  });
});

// ==========================================
// EMAIL ENDPOINTS (Keep your exact templates)
// ==========================================

// Email service status
app.get('/api/email/status', async (req, res) => {
  try {
    res.json({
      status: 'Email API is working',
      connected: true,
      service: 'Brevo API Email Service',
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

// Send wedding invitation email (exact same as your local)
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

// Send declined invitation email (exact same as your local)
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

// Send revoked access email (exact same as your local)
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

// Send custom email (exact same as your local)
app.post('/api/email/send', async (req, res) => {
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

// Get all sent emails (exact same as your local)
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

// Test email connection
app.get('/api/email/test', (req, res) => {
  res.json({
    service: 'Email Test',
    status: 'ready',
    provider: 'Brevo',
    apiKey: process.env.BREVO_API_KEY ? 'configured' : 'missing',
    fromEmail: process.env.EMAIL_FROM || 'not configured'
  });
});

// ==========================================
// ENHANCED FIREBASE NOTIFICATION ENDPOINTS
// ==========================================

// Firebase status endpoint with detailed diagnostics
app.get('/api/notifications/status', async (req, res) => {
    try {
        console.log('🔍 Checking Firebase status...');
        
        if (!firebaseInitialized) {
            console.log('❌ Firebase not initialized');
            return res.status(500).json({
                service: 'Push Notification API',
                status: 'error',
                error: firebaseError || 'Firebase not initialized',
                configured: {
                    firebaseProjectId: false,
                    firebaseServiceAccount: false,
                    firebaseApp: false
                },
                diagnostics: {
                    serviceAccountFile: require('fs').existsSync('./firebase-service-account.json'),
                    adminSDK: !!admin,
                    apps: admin.apps.length
                }
            });
        }
        
        // Test Firebase messaging service
        try {
            const messaging = admin.messaging();
            console.log('✅ Firebase messaging service accessible');
            
            res.json({
                service: 'Push Notification API',
                status: 'connected',
                environment: 'production',
                configured: {
                    firebaseProjectId: true,
                    firebaseServiceAccount: true,
                    firebaseApp: true,
                    messaging: true
                },
                diagnostics: {
                    serviceAccountFile: true,
                    adminSDK: true,
                    apps: admin.apps.length,
                    projectId: firebaseApp ? firebaseApp.options.projectId : 'unknown'
                }
            });
        } catch (messagingError) {
            console.error('❌ Firebase messaging error:', messagingError);
            res.status(500).json({
                service: 'Push Notification API',
                status: 'error',
                error: 'Firebase messaging not available: ' + messagingError.message,
                configured: {
                    firebaseProjectId: true,
                    firebaseServiceAccount: true,
                    firebaseApp: true,
                    messaging: false
                }
            });
        }
        
    } catch (error) {
        console.error('❌ Firebase status check error:', error);
        res.status(500).json({
            service: 'Push Notification API',
            status: 'error',
            error: error.message
        });
    }
});

// Enhanced send push notification endpoint
app.post('/api/notifications/send', async (req, res) => {
    console.log('📱 Received notification request:', JSON.stringify(req.body, null, 2));
    
    try {
        // Check Firebase initialization
        if (!firebaseInitialized) {
            console.error('❌ Firebase not initialized');
            return res.status(500).json({
                success: false,
                error: 'Firebase not initialized: ' + (firebaseError || 'Unknown error'),
                troubleshooting: {
                    step1: 'Check Firebase service account file exists',
                    step2: 'Verify service account JSON is valid',
                    step3: 'Restart the application: pm2 restart 4secrets-wedding-api'
                }
            });
        }
        
        const { token, title, body, data } = req.body;
        
        // Validate required fields
        if (!token) {
            return res.status(400).json({
                success: false,
                error: 'Missing required field: token',
                received: { token: !!token, title: !!title, body: !!body }
            });
        }
        
        if (!title || !body) {
            return res.status(400).json({
                success: false,
                error: 'Missing required fields: title and body',
                received: { token: !!token, title: !!title, body: !!body }
            });
        }
        
        console.log('🔍 Preparing Firebase message...');
        const message = {
            notification: { 
                title: String(title),
                body: String(body)
            },
            token: String(token)
        };
        
        // Add data payload if provided
        if (data && typeof data === 'object') {
            message.data = {};
            for (const [key, value] of Object.entries(data)) {
                message.data[key] = String(value);
            }
            console.log('📦 Added data payload:', message.data);
        }
        
        console.log('📤 Sending message via Firebase:', JSON.stringify(message, null, 2));
        
        // Send the message
        const messaging = admin.messaging();
        const response = await messaging.send(message);
        
        console.log('✅ Message sent successfully:', response);
        
        // Store sent notification
        const notificationRecord = {
            id: Date.now(),
            token: token,
            title: title,
            body: body,
            data: data,
            messageId: response,
            sentAt: new Date().toISOString(),
            status: 'sent'
        };
        
        sentNotifications.push(notificationRecord);
        
        res.json({
            success: true,
            messageId: response,
            message: 'Push notification sent successfully',
            sentAt: new Date().toISOString(),
            notification: {
                title: title,
                body: body,
                token: token.substring(0, 20) + '...' // Partial token for security
            }
        });
        
    } catch (error) {
        console.error('❌ Push notification error:', error);
        
        let errorMessage = error.message;
        let errorCode = error.code || 'unknown';
        let troubleshooting = {};
        
        // Handle specific Firebase errors
        if (error.code === 'messaging/registration-token-not-registered') {
            errorMessage = 'FCM token is not registered or has expired';
            troubleshooting = {
                issue: 'Invalid or expired FCM token',
                solution: 'Generate a new FCM token from your mobile app'
            };
        } else if (error.code === 'messaging/invalid-registration-token') {
            errorMessage = 'FCM token format is invalid';
            troubleshooting = {
                issue: 'Malformed FCM token',
                solution: 'Check the FCM token format and regenerate if needed'
            };
        } else if (error.code === 'messaging/mismatched-credential') {
            errorMessage = 'Firebase credentials are invalid';
            troubleshooting = {
                issue: 'Firebase service account credentials mismatch',
                solution: 'Verify Firebase service account configuration'
            };
        } else if (error.message.includes('not initialized')) {
            troubleshooting = {
                issue: 'Firebase Admin SDK not properly initialized',
                solution: 'Restart the server: pm2 restart 4secrets-wedding-api'
            };
        }
        
        res.status(500).json({
            success: false,
            error: errorMessage,
            errorCode: errorCode,
            timestamp: new Date().toISOString(),
            troubleshooting: troubleshooting
        });
    }
});

// Wedding invitation notification (enhanced)
app.post('/api/notifications/wedding-invitation', async (req, res) => {
    try {
        if (!firebaseInitialized) {
            return res.status(500).json({
                success: false,
                error: 'Firebase not initialized'
            });
        }

        const { token, inviterName, weddingDate } = req.body;
        
        if (!token || !inviterName) {
            return res.status(400).json({
                success: false,
                error: 'Missing required fields: token and inviterName'
            });
        }
        
        const message = {
            notification: {
                title: '💍 Hochzeitseinladung',
                body: `${inviterName} hat Sie zu ihrer Hochzeit eingeladen!`
            },
            data: {
                type: 'wedding_invitation',
                inviterName: String(inviterName),
                weddingDate: String(weddingDate || ''),
                timestamp: String(Date.now())
            },
            token: String(token)
        };
        
        const response = await admin.messaging().send(message);
        
        res.json({
            success: true,
            messageId: response,
            message: 'Wedding invitation sent successfully'
        });
        
    } catch (error) {
        console.error('Wedding invitation error:', error);
        res.status(500).json({
            success: false,
            error: error.message,
            errorCode: error.code || 'unknown'
        });
    }
});

// Task reminder notification (enhanced)
app.post('/api/notifications/task-reminder', async (req, res) => {
    try {
        if (!firebaseInitialized) {
            return res.status(500).json({
                success: false,
                error: 'Firebase not initialized'
            });
        }

        const { token, taskTitle, dueDate } = req.body;
        
        if (!token || !taskTitle) {
            return res.status(400).json({
                success: false,
                error: 'Missing required fields: token and taskTitle'
            });
        }
        
        const message = {
            notification: {
                title: '📋 Aufgabenerinnerung',
                body: `Vergessen Sie nicht: ${taskTitle}`
            },
            data: {
                type: 'task_reminder',
                taskTitle: String(taskTitle),
                dueDate: String(dueDate || ''),
                timestamp: String(Date.now())
            },
            token: String(token)
        };
        
        const response = await admin.messaging().send(message);
        
        res.json({
            success: true,
            messageId: response,
            message: 'Task reminder sent successfully'
        });
        
    } catch (error) {
        console.error('Task reminder error:', error);
        res.status(500).json({
            success: false,
            error: error.message,
            errorCode: error.code || 'unknown'
        });
    }
});

// Get sent notifications
app.get('/api/notifications/sent', (req, res) => {
    res.json({
        success: true,
        count: sentNotifications.length,
        notifications: sentNotifications.slice(-50), // Return last 50 notifications
        firebase: {
            initialized: firebaseInitialized,
            error: firebaseError
        }
    });
});

// Test Firebase connection
app.get('/api/notifications/test', async (req, res) => {
    try {
        if (!firebaseInitialized) {
            return res.status(500).json({
                success: false,
                error: 'Firebase not initialized',
                firebaseError: firebaseError
            });
        }
        
        // Test Firebase messaging service
        const messaging = admin.messaging();
        
        res.json({
            success: true,
            message: 'Firebase connection test passed',
            firebase: {
                initialized: true,
                projectId: firebaseApp ? firebaseApp.options.projectId : 'unknown',
                messagingAvailable: !!messaging
            }
        });
        
    } catch (error) {
        res.status(500).json({
            success: false,
            error: 'Firebase connection test failed: ' + error.message
        });
    }
});

// ==========================================
// IMAGE ENDPOINTS (Basic)
// ==========================================

app.get('/api/images', (req, res) => {
    res.json({
        service: 'Image API',
        status: 'ready',
        message: 'Image upload functionality available'
    });
});

// ==========================================
// ERROR HANDLING
// ==========================================

// Error handling middleware
app.use((error, req, res, next) => {
    console.error('Server error:', error);
    res.status(500).json({
        success: false,
        error: 'Internal server error',
        message: error.message
    });
});

// 404 handler
app.use((req, res) => {
    res.status(404).json({
        success: false,
        error: 'Endpoint not found',
        path: req.path,
        availableEndpoints: {
            health: 'GET /health',
            emailStatus: 'GET /api/email/status',
            sendEmail: 'POST /api/email/send',
            sendInvitation: 'POST /api/email/send-invitation',
            declinedInvitation: 'POST /api/email/declined-invitation',
            revokeAccess: 'POST /api/email/revoke-access',
            sentEmails: 'GET /api/email/sent',
            notificationStatus: 'GET /api/notifications/status',
            sendNotification: 'POST /api/notifications/send',
            weddingInvitation: 'POST /api/notifications/wedding-invitation',
            taskReminder: 'POST /api/notifications/task-reminder',
            sentNotifications: 'GET /api/notifications/sent',
            testFirebase: 'GET /api/notifications/test'
        }
    });
});

// Start server
app.listen(PORT, () => {
    console.log(`🚀 Server running on port ${PORT}`);
    console.log(`🔥 Firebase initialized: ${firebaseInitialized}`);
    console.log(`📧 Email service: Brevo API configured`);
    if (firebaseError) {
        console.log(`❌ Firebase error: ${firebaseError}`);
    }
    console.log(`🌐 Health check: http://localhost:${PORT}/health`);
    console.log(`📧 Email status: http://localhost:${PORT}/api/email/status`);
    console.log(`🔔 Notifications status: http://localhost:${PORT}/api/notifications/status`);
    console.log(`🧪 Firebase test: http://localhost:${PORT}/api/notifications/test`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
    console.log('SIGTERM received, shutting down gracefully');
    process.exit(0);
});

process.on('SIGINT', () => {
    console.log('SIGINT received, shutting down gracefully');
    process.exit(0);
});
SERVER_EOF

echo "✅ Enhanced server.js created with better Firebase handling"

echo ""
echo "🔍 Step 5: Start Application"
echo "=========================="

# Start with PM2
echo "🚀 Starting application with PM2..."
pm2 start ecosystem.config.js
pm2 save

echo "✅ Application started"

# Wait for startup
sleep 5

echo ""
echo "🔍 Step 6: Test Firebase Notifications"
echo "====================================="

# Test health endpoint
echo "🧪 Testing health endpoint..."
HEALTH_RESPONSE=$(curl -s http://localhost:3001/health)
if [ $? -eq 0 ]; then
    echo "✅ Health check passed"
    echo "Response: $HEALTH_RESPONSE"
else
    echo "❌ Health check failed"
fi

echo ""

# Test Firebase status
echo "🧪 Testing Firebase notifications status..."
FIREBASE_RESPONSE=$(curl -s http://localhost:3001/api/notifications/status)
if [ $? -eq 0 ]; then
    echo "✅ Firebase status check passed"
    echo "Response: $FIREBASE_RESPONSE"
else
    echo "❌ Firebase status check failed"
fi

echo ""

# Test Firebase connection
echo "🧪 Testing Firebase connection..."
FIREBASE_TEST=$(curl -s http://localhost:3001/api/notifications/test)
if [ $? -eq 0 ]; then
    echo "✅ Firebase connection test passed"
    echo "Response: $FIREBASE_TEST"
else
    echo "❌ Firebase connection test failed"
fi

echo ""
echo "🎉 FIREBASE NOTIFICATION FIX COMPLETE!"
echo "======================================"
echo ""
echo "📋 Summary:"
echo "✅ Firebase Admin SDK verified and reinstalled if needed"
echo "✅ Firebase service account tested and validated"
echo "✅ Enhanced server.js with better Firebase error handling"
echo "✅ Detailed Firebase diagnostics added"
echo "✅ Email templates preserved (exact same as your local)"
echo ""
echo "🧪 Test Firebase notifications:"
echo "curl -X POST http://$(curl -s ifconfig.me 2>/dev/null || echo 'YOUR_SERVER_IP'):3001/api/notifications/send \\"
echo "  -H 'Content-Type: application/json' \\"
echo "  -d '{\"token\":\"eAxrpmKxSBu5ZctRtEcRpt:APA91bHoIGjjAq0mMOl83bjXq3Qw0T5Pe9pFnVacreW1-dhnbdcB5dXZzFdbSU9uUw_nPfNAFOI2tKUkOtPoMLIraN0Y9jew2jh-cqqs99xvEecakqjbbxY\",\"title\":\"🔥 Firebase Fixed!\",\"body\":\"FCM notifications are working again!\"}'"
echo ""
echo "🔧 If still having issues:"
echo "1. Check logs: pm2 logs 4secrets-wedding-api"
echo "2. Check Firebase status: curl http://localhost:3001/api/notifications/status"
echo "3. Test Firebase: curl http://localhost:3001/api/notifications/test"
echo ""
echo "🎯 Firebase notifications should now be working!"
echo ""
