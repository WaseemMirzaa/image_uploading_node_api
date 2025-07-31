const express = require('express');
const router = express.Router();
const pushNotificationController = require('../controllers/pushNotificationController');

// Send general push notification
router.post('/send', pushNotificationController.sendNotification);

// Send wedding invitation notification
router.post('/wedding-invitation', pushNotificationController.sendWeddingInvitation);

// Send task reminder notification
router.post('/task-reminder', pushNotificationController.sendTaskReminder);

// Send collaboration notification
router.post('/collaboration', pushNotificationController.sendCollaboration);

// Subscribe to topic
router.post('/subscribe', pushNotificationController.subscribeToTopic);

// Unsubscribe from topic
router.post('/unsubscribe', pushNotificationController.unsubscribeFromTopic);

// Test push notification service connection
router.get('/test', pushNotificationController.testConnection);

// Get push notification service status
router.get('/status', pushNotificationController.getStatus);

// Get all sent notifications
router.get('/sent', pushNotificationController.getSentNotifications);

// Get specific notification by ID
router.get('/:id', pushNotificationController.getNotification);

module.exports = router;
