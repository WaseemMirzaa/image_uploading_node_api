const express = require('express');
const router = express.Router();
const notificationController = require('../controllers/notificationController');

// Send a push notification
router.post('/send', notificationController.sendNotification);

// Send wedding invitation notification
router.post('/wedding-invitation', notificationController.sendWeddingInvitation);

// Send task reminder notification
router.post('/task-reminder', notificationController.sendTaskReminder);

// Test Firebase connection
router.get('/test', notificationController.testConnection);

// Get notification service status
router.get('/status', notificationController.getStatus);

// Get all sent notifications (for debugging)
router.get('/sent', notificationController.getSentNotifications);

module.exports = router;
