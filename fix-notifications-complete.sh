#!/bin/bash

# Complete Notification Fix Script
# 4 Secrets Wedding API - Add Missing Notification Files

echo "🔧 Complete Notification Fix Script"
echo "==================================="

PROJECT_NAME="4secrets-wedding-api"
PROJECT_DIR="/root/$PROJECT_NAME"

# Navigate to project directory
if [ -d "$PROJECT_DIR" ]; then
    cd "$PROJECT_DIR"
    echo "📁 Working in: $PROJECT_DIR"
else
    echo "❌ Project directory not found: $PROJECT_DIR"
    echo "Please run the main deployment script first!"
    exit 1
fi

echo ""
echo "🔧 Step 1: Create Missing Notification Controller"
echo "=============================================="

# Create the notification controller directory if it doesn't exist
mkdir -p src/controllers

echo "📝 Creating notification controller..."
cat > src/controllers/notificationController.js << 'CONTROLLER_EOF'
const admin = require('firebase-admin');
const logger = require('../utils/logger');

// Initialize Firebase Admin SDK
let firebaseInitialized = false;
let firebaseError = null;

try {
  const serviceAccount = require('../../firebase-service-account.json');
  
  if (!admin.apps.length) {
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
      projectId: process.env.FIREBASE_PROJECT_ID || 'secrets-wedding'
    });
  }
  
  firebaseInitialized = true;
  logger.info('🔥 Firebase Admin SDK initialized successfully');
} catch (error) {
  firebaseError = error.message;
  logger.error('❌ Firebase initialization failed:', error);
}

// Notification counter
let totalNotificationsSent = 0;

class NotificationController {
  /**
   * Get notification service status
   * GET /api/notifications/status
   */
  async getStatus(req, res) {
    try {
      res.status(200).json({
        service: 'Firebase Push Notifications',
        status: firebaseInitialized ? 'ready' : 'error',
        initialized: firebaseInitialized,
        error: firebaseError,
        projectId: process.env.FIREBASE_PROJECT_ID || 'secrets-wedding',
        totalNotificationsSent: totalNotificationsSent
      });
    } catch (error) {
      logger.error('Error getting notification status:', error);
      res.status(500).json({
        error: 'Failed to get notification status',
        details: error.message
      });
    }
  }

  /**
   * Test Firebase connection
   * GET /api/notifications/test
   */
  async testConnection(req, res) {
    try {
      if (!firebaseInitialized) {
        return res.status(500).json({
          success: false,
          message: 'Firebase not initialized',
          error: firebaseError
        });
      }

      res.status(200).json({
        success: true,
        message: 'Firebase connection is working',
        projectId: process.env.FIREBASE_PROJECT_ID || 'secrets-wedding',
        initialized: firebaseInitialized
      });
    } catch (error) {
      logger.error('Error testing Firebase connection:', error);
      res.status(500).json({
        success: false,
        error: 'Failed to test Firebase connection',
        details: error.message
      });
    }
  }

  /**
   * Send push notification
   * POST /api/notifications/send
   * Body: { token, title, body, data? }
   */
  async sendNotification(req, res) {
    try {
      const { token, title, body, data } = req.body;

      // Validate required fields
      if (!token || !title || !body) {
        return res.status(400).json({
          error: 'Missing required fields',
          required: ['token', 'title', 'body'],
          received: Object.keys(req.body)
        });
      }

      if (!firebaseInitialized) {
        return res.status(500).json({
          success: false,
          error: 'Firebase not initialized',
          details: firebaseError
        });
      }

      // Prepare notification message
      const message = {
        notification: {
          title: title,
          body: body
        },
        data: data || {},
        token: token
      };

      // Send the notification
      const response = await admin.messaging().send(message);
      totalNotificationsSent++;

      logger.info('Notification sent successfully:', {
        messageId: response,
        to: token,
        title: title
      });

      res.status(200).json({
        success: true,
        message: 'Notification sent successfully',
        messageId: response
      });

    } catch (error) {
      logger.error('Error sending notification:', error);
      res.status(500).json({
        success: false,
        error: 'Failed to send notification',
        details: error.message
      });
    }
  }

  /**
   * Send wedding invitation notification
   * POST /api/notifications/wedding-invitation
   * Body: { token, inviterName, weddingDate?, venue? }
   */
  async sendWeddingInvitation(req, res) {
    try {
      const { token, inviterName, weddingDate, venue } = req.body;

      // Validate required fields
      if (!token || !inviterName) {
        return res.status(400).json({
          error: 'Missing required fields',
          required: ['token', 'inviterName'],
          received: Object.keys(req.body)
        });
      }

      if (!firebaseInitialized) {
        return res.status(500).json({
          success: false,
          error: 'Firebase not initialized',
          details: firebaseError
        });
      }

      // Prepare wedding invitation notification
      const title = 'Hochzeits-Einladung 💍';
      const body = `${inviterName} hat dich zur Hochzeitsplanung eingeladen!`;

      const message = {
        notification: {
          title: title,
          body: body
        },
        data: {
          type: 'wedding_invitation',
          inviterName: inviterName,
          weddingDate: weddingDate || '',
          venue: venue || ''
        },
        token: token
      };

      // Send the notification
      const response = await admin.messaging().send(message);
      totalNotificationsSent++;

      logger.info('Wedding invitation sent successfully:', {
        messageId: response,
        to: token,
        inviterName: inviterName
      });

      res.status(200).json({
        success: true,
        message: 'Wedding invitation notification sent successfully',
        messageId: response,
        data: {
          inviterName: inviterName,
          weddingDate: weddingDate,
          venue: venue
        }
      });

    } catch (error) {
      logger.error('Error sending wedding invitation:', error);
      res.status(500).json({
        success: false,
        error: 'Failed to send wedding invitation',
        details: error.message
      });
    }
  }

  /**
   * Send task reminder notification
   * POST /api/notifications/task-reminder
   * Body: { token, taskTitle, dueDate?, priority? }
   */
  async sendTaskReminder(req, res) {
    try {
      const { token, taskTitle, dueDate, priority } = req.body;

      // Validate required fields
      if (!token || !taskTitle) {
        return res.status(400).json({
          error: 'Missing required fields',
          required: ['token', 'taskTitle'],
          received: Object.keys(req.body)
        });
      }

      if (!firebaseInitialized) {
        return res.status(500).json({
          success: false,
          error: 'Firebase not initialized',
          details: firebaseError
        });
      }

      // Prepare task reminder notification
      const title = 'Aufgaben-Erinnerung 📋';
      const body = `Vergiss nicht: ${taskTitle}`;

      const message = {
        notification: {
          title: title,
          body: body
        },
        data: {
          type: 'task_reminder',
          taskTitle: taskTitle,
          dueDate: dueDate || '',
          priority: priority || 'normal'
        },
        token: token
      };

      // Send the notification
      const response = await admin.messaging().send(message);
      totalNotificationsSent++;

      logger.info('Task reminder sent successfully:', {
        messageId: response,
        to: token,
        taskTitle: taskTitle
      });

      res.status(200).json({
        success: true,
        message: 'Task reminder notification sent successfully',
        messageId: response,
        data: {
          taskTitle: taskTitle,
          dueDate: dueDate,
          priority: priority
        }
      });

    } catch (error) {
      logger.error('Error sending task reminder:', error);
      res.status(500).json({
        success: false,
        error: 'Failed to send task reminder',
        details: error.message
      });
    }
  }
}

module.exports = new NotificationController();
CONTROLLER_EOF

echo "✅ Notification controller created"

echo ""
echo "🔧 Step 2: Create Missing Notification Routes"
echo "==========================================="

# Create the routes directory if it doesn't exist
mkdir -p src/routes

echo "📝 Creating notification routes..."
cat > src/routes/notifications.js << 'ROUTES_EOF'
const express = require('express');
const router = express.Router();
const notificationController = require('../controllers/notificationController');

// Get notification service status
router.get('/status', notificationController.getStatus);

// Test Firebase connection
router.get('/test', notificationController.testConnection);

// Send push notification
router.post('/send', notificationController.sendNotification);

// Send wedding invitation notification
router.post('/wedding-invitation', notificationController.sendWeddingInvitation);

// Send task reminder notification
router.post('/task-reminder', notificationController.sendTaskReminder);

module.exports = router;
ROUTES_EOF

echo "✅ Notification routes created"

echo ""
echo "🔧 Step 3: Update Server.js to Include Notification Routes"
echo "========================================================"

# Check if server.js exists and backup
if [ -f "server.js" ]; then
    cp server.js server.js.backup
    echo "📝 Backed up existing server.js"
fi

# Update server.js to include notification routes
echo "📝 Updating server.js to include notification routes..."

# Add notification routes to server.js if not already present
if ! grep -q "notifications" server.js; then
    # Find the line with email routes and add notification routes after it
    sed -i '/app\.use.*email/a app.use("/api/notifications", require("./src/routes/notifications"));' server.js
    echo "✅ Added notification routes to server.js"
else
    echo "✅ Notification routes already present in server.js"
fi

echo ""
echo "🔧 Step 4: Update Firebase Credentials"
echo "====================================="

# Create Firebase service account file with real credentials
echo "📝 Creating Firebase service account file with real credentials..."
cat > firebase-service-account.json << 'FIREBASE_EOF'
{
  "type": "service_account",
  "project_id": "secrets-wedding",
  "private_key_id": "80f5c6b912b41fb7a293dece4338200f16eb7d4a",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDC3FT+We+5ob8s\nlxcteKAgcHVMAo2XFZTSDu+B13qdX4VhWDLs3bgGJcX8wLxlnQ8nHTQ9HjRfV7cn\nAyHxWRNbtIMZS032NexrhwhmxRIX+iRrHzUEPfbbpFW8yB7gMDa1vYummGkXv5m8\nHrlzuBNN9sCSDUajY9vhmPF/cT7WKSlwMeNe3+qOlsBHhlcZMa0Dm0d11ZweFCZM\n73CeYdZ88epFJBi5vFibnw+ctXgf36chkxMQePrEN/6tRGZ5BouJL8ROFNp7IrlT\neDvDeASuJAkBDsu+fPWeVRDHauoh39SEsg4ZWvghm9YFxpayvnvsWIrWNIhne1Q1\n3z6ER+tDAgMBAAECggEAGkNaDUIP5mQfgSIIFK/aXSTrGkiJzuAww7MRot1pAEb8\nkicyDezAPcvfiHZtrgBiJ3JvNQGaK3OGEvMAIyhPTJ/iv4j/w/x2lfOINVnAW4zy\nVaHKIn07hVT73UrXpn25EfuvE9Ac8f939/voIOmhaHOmdsjlSWZPH3PesL+RqYl8\neeAXbFuW4+7493TQV+S6Vw533MjqR2pkiSoM0aWoW0qHpfJsozalv3c2H7m4Wbtg\no6LD2O1kM8JWOnH2FI4IjpLzlm0b8GMntFsTjVAKF/s6UP+Ld63s7kJmlME/34V9\ngoyWa1bY3EtxY8xICny+45bsYtnDohf0zRO+sk0RgQKBgQDmAzqLJL2VryeuSBx9\nhjfT4Y0j2iMk8v+/831xDQ4+PiREL2FN3bsZEl2elWcVHB5YqOHeE4tXrr2k+3Gx\npuo5F9gmDwE6uAYv3nDLZiNqSfLeQ2wlhYYh3SCg1iaRUZ9+Qe+4BENfW2uqNfn4\nfRv+eqcht6wTJf4c2VRzfr7RAwKBgQDY4GLNVMwhlowr3czqvXY7rci6oJKVTNp+\npjsxg0kLicEwK+a2o+p/jfsdEaDeNHtrbJ+3eZLrPsp8kQnm+Vlp0FTNXEyt8vVZ\nrfxIj4ofGbLLuwCCXXD/oOFKuYoAguMhE8avO9zYETbgC5H2cCfxN+hralifkvDq\nliwHGbbIwQKBgAxgBBhUY7bX86SW0KGYRQyrR/Kz28wzHrtvGEKq1ydWJJFekzej\nRFu29z5+/0rNdnyCqZRPLOIMzrs/pABQ4K0tsT1q9T/5gqu0phDrb+BaFi0LJ5hl\nNLBBu22r1+tdnt0mIwWdhRpuSr6fpNFPud/ZLYDM5v8oviFDOB32pcGNAoGBAJkV\nqigt1vlOfxrnsSFxIuf1P18cwNtKKGCFjfrhJMpULl2GX5BEG951pe9a5iZy/TtS\nrVqhIieTZvKOnmK/V3HtcC6VHDsc6DqpKQ8+4swZI6/TDAT5WC3Yra5FUTgTK6fJ\ngdFne/e4DvgOsrU1bbxDLnfD1VKuMggkgGdyqycBAoGBANgHTk34MQaPMvCIEAhk\n0LM7Lx/XUXXsSEx/Z5OmuDU8rAnDCd0xvcZjNt1sMk9Rctl7voQO2BVvCsdY8UVT\njxmMswxhFvZrVewxDcMtaf2qJZem8qm714Gr0U4bK4YRdcveLrcd9T5PsplDitpw\np50mFJ+nBc6n47ewrqkECwcW\n-----END PRIVATE KEY-----\n",
  "client_email": "firebase-adminsdk-fbsvc@secrets-wedding.iam.gserviceaccount.com",
  "client_id": "100124235240975477019",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40secrets-wedding.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
}
FIREBASE_EOF

chmod 600 firebase-service-account.json
echo "✅ Firebase credentials updated"

echo ""
echo "🔧 Step 5: Restart Application"
echo "============================="

# Stop the current PM2 process
echo "🛑 Stopping current application..."
pm2 stop $PROJECT_NAME 2>/dev/null || true
pm2 delete $PROJECT_NAME 2>/dev/null || true

# Wait a moment
sleep 3

# Start the application again
echo "🚀 Starting application with notification support..."
pm2 start server.js --name "$PROJECT_NAME"

if [ $? -ne 0 ]; then
    echo "❌ Failed to start application"
    echo "📋 Checking for errors..."
    pm2 logs $PROJECT_NAME --lines 20
    exit 1
fi

# Save PM2 configuration
pm2 save

echo "✅ Application restarted successfully"

echo ""
echo "⏳ Step 6: Wait for Initialization"
echo "================================="

echo "⏳ Waiting 15 seconds for server to initialize..."
sleep 15

echo ""
echo "🧪 Step 7: Test All APIs"
echo "======================="

PORT=3001

# Test notification status
echo "🔍 Testing notification status..."
NOTIF_STATUS=$(curl -s http://localhost:$PORT/api/notifications/status)
echo "   Response: $NOTIF_STATUS"

echo ""

# Test Firebase connection
echo "🔍 Testing Firebase connection..."
FIREBASE_TEST=$(curl -s http://localhost:$PORT/api/notifications/test)
echo "   Response: $FIREBASE_TEST"

echo ""

# Test notification sending with your real FCM token
echo "🔍 Testing notification sending with real FCM token..."
FCM_TOKEN="fYZUgAHuTX-mAvjjWoLnHk:APA91bGBwjNs0EzbfFYBWffdgD3V86YNWryNg1oP-gpoZ7zEmIdf3CXIWjYZgHqto-3v5uzbYUisUyA8tu5gyJl6fV5S6LowCXhVFG2-lyhOtJwVIHqKHZw"

NOTIF_SEND=$(curl -s -X POST -H "Content-Type: application/json" -d "{\"token\":\"$FCM_TOKEN\",\"title\":\"Server Test\",\"body\":\"Firebase notifications working from server!\"}" http://localhost:$PORT/api/notifications/send)
echo "   Response: $NOTIF_SEND"

echo ""
echo "🎉 NOTIFICATION FIX COMPLETE!"
echo "============================"
echo ""
echo "📊 Current PM2 Status:"
pm2 status

echo ""
echo "🌐 Your API Endpoints:"
SERVER_IP=$(curl -s ifconfig.me 2>/dev/null || echo "YOUR_SERVER_IP")
echo "   Notification Status: http://$SERVER_IP:$PORT/api/notifications/status"
echo "   Firebase Test: http://$SERVER_IP:$PORT/api/notifications/test"
echo "   Send Notification: http://$SERVER_IP:$PORT/api/notifications/send"
echo ""
echo "✅ Notification controller and routes created!"
echo "✅ Firebase credentials updated!"
echo "✅ Server restarted with notification support!"
echo "🚀 Your notification APIs should now be working!"
