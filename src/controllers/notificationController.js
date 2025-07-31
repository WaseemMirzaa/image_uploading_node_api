const admin = require('firebase-admin');
const logger = require('../utils/logger');

// Initialize Firebase Admin SDK
let firebaseInitialized = false;
let firebaseError = null;
let useMockFirebase = false;

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
  useMockFirebase = true;
  logger.error('❌ Firebase initialization failed, using mock service:', error.message);
  logger.info('🔧 Mock Firebase service enabled for testing');
}

// Store sent notifications for debugging
const sentNotifications = [];

// Send a generic push notification
const sendNotification = async (req, res) => {
  try {
    if (!firebaseInitialized) {
      return res.status(500).json({
        success: false,
        error: 'Firebase not initialized',
        details: firebaseError
      });
    }

    const { token, title, body, data } = req.body;

    if (!token || !title || !body) {
      return res.status(400).json({
        success: false,
        error: 'Missing required fields: token, title, body'
      });
    }

    const message = {
      notification: {
        title,
        body
      },
      data: data || {},
      token
    };

    const response = await admin.messaging().send(message);
    
    // Store for debugging
    sentNotifications.push({
      id: response,
      timestamp: new Date().toISOString(),
      type: 'generic',
      message,
      response
    });

    logger.info(`🔔 Notification sent successfully: ${response}`);

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
};

// Send wedding invitation notification
const sendWeddingInvitation = async (req, res) => {
  try {
    if (!firebaseInitialized) {
      return res.status(500).json({
        success: false,
        error: 'Firebase not initialized',
        details: firebaseError
      });
    }

    const { token, inviterName, weddingDate, venue } = req.body;

    if (!token || !inviterName) {
      return res.status(400).json({
        success: false,
        error: 'Missing required fields: token, inviterName'
      });
    }

    const message = {
      notification: {
        title: 'Hochzeitseinladung 💒',
        body: `${inviterName} hat Sie zu ihrer Hochzeit eingeladen!`
      },
      data: {
        type: 'wedding_invitation',
        inviterName,
        weddingDate: weddingDate || '',
        venue: venue || ''
      },
      token
    };

    const response = await admin.messaging().send(message);
    
    // Store for debugging
    sentNotifications.push({
      id: response,
      timestamp: new Date().toISOString(),
      type: 'wedding_invitation',
      message,
      response
    });

    logger.info(`💒 Wedding invitation sent successfully: ${response}`);

    res.status(200).json({
      success: true,
      message: 'Wedding invitation notification sent successfully',
      messageId: response
    });

  } catch (error) {
    logger.error('Error sending wedding invitation:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to send wedding invitation',
      details: error.message
    });
  }
};

// Send task reminder notification
const sendTaskReminder = async (req, res) => {
  try {
    if (!firebaseInitialized) {
      return res.status(500).json({
        success: false,
        error: 'Firebase not initialized',
        details: firebaseError
      });
    }

    const { token, taskTitle, dueDate, priority } = req.body;

    if (!token || !taskTitle) {
      return res.status(400).json({
        success: false,
        error: 'Missing required fields: token, taskTitle'
      });
    }

    const priorityEmoji = priority === 'high' ? '🔴' : priority === 'medium' ? '🟡' : '🟢';

    const message = {
      notification: {
        title: `${priorityEmoji} Aufgabenerinnerung`,
        body: `Vergessen Sie nicht: ${taskTitle}`
      },
      data: {
        type: 'task_reminder',
        taskTitle,
        dueDate: dueDate || '',
        priority: priority || 'normal'
      },
      token
    };

    const response = await admin.messaging().send(message);
    
    // Store for debugging
    sentNotifications.push({
      id: response,
      timestamp: new Date().toISOString(),
      type: 'task_reminder',
      message,
      response
    });

    logger.info(`📋 Task reminder sent successfully: ${response}`);

    res.status(200).json({
      success: true,
      message: 'Task reminder notification sent successfully',
      messageId: response
    });

  } catch (error) {
    logger.error('Error sending task reminder:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to send task reminder',
      details: error.message
    });
  }
};

// Test Firebase connection
const testConnection = async (req, res) => {
  try {
    if (!firebaseInitialized) {
      return res.status(500).json({
        success: false,
        error: 'Firebase not initialized',
        details: firebaseError
      });
    }

    // Try to get the Firebase app instance
    const app = admin.app();
    
    res.status(200).json({
      success: true,
      message: 'Firebase connection is working',
      projectId: app.options.projectId,
      initialized: firebaseInitialized
    });

  } catch (error) {
    logger.error('Firebase test failed:', error);
    res.status(500).json({
      success: false,
      error: 'Firebase test failed',
      details: error.message
    });
  }
};

// Get notification service status
const getStatus = (req, res) => {
  res.status(200).json({
    service: 'Firebase Push Notifications',
    status: firebaseInitialized ? 'ready' : 'error',
    initialized: firebaseInitialized,
    error: firebaseError,
    projectId: process.env.FIREBASE_PROJECT_ID || 'secrets-wedding',
    totalNotificationsSent: sentNotifications.length
  });
};

// Get all sent notifications (for debugging)
const getSentNotifications = (req, res) => {
  res.status(200).json({
    success: true,
    total: sentNotifications.length,
    notifications: sentNotifications.slice(-10) // Return last 10 notifications
  });
};

module.exports = {
  sendNotification,
  sendWeddingInvitation,
  sendTaskReminder,
  testConnection,
  getStatus,
  getSentNotifications
};
