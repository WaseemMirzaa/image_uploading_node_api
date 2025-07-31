const pushNotificationService = require('../services/pushNotificationService');
const logger = require('../utils/logger');

class PushNotificationController {
  /**
   * Send a general push notification
   * POST /api/notifications/send
   * Body: { token?, tokens?, topic?, title, body, data?, imageUrl?, sound?, badge? }
   */
  async sendNotification(req, res) {
    try {
      const { token, tokens, topic, title, body, data, imageUrl, sound, badge } = req.body;

      // Validate required fields
      if (!title || !body) {
        return res.status(400).json({
          error: 'Missing required fields',
          required: ['title', 'body'],
          received: Object.keys(req.body)
        });
      }

      // Validate target (at least one must be provided)
      if (!token && !tokens && !topic) {
        return res.status(400).json({
          error: 'Missing target',
          message: 'At least one target must be provided: token, tokens, or topic'
        });
      }

      // Validate tokens array if provided
      if (tokens && (!Array.isArray(tokens) || tokens.length === 0)) {
        return res.status(400).json({
          error: 'Invalid tokens',
          message: 'tokens must be a non-empty array'
        });
      }

      // Send the notification
      const result = await pushNotificationService.sendNotification({
        token,
        tokens,
        topic,
        title,
        body,
        data,
        imageUrl,
        sound,
        badge
      });

      logger.info('Push notification sent via API:', {
        messageId: result.messageId,
        title,
        body,
        recipients: result.recipients
      });

      // Return success response
      res.status(200).json({
        success: true,
        message: 'Push notification sent successfully',
        data: {
          messageId: result.messageId,
          recipients: result.recipients,
          failed: result.failed || 0,
          service: result.service,
          title,
          body
        }
      });

    } catch (error) {
      logger.error('Error sending push notification:', error);
      
      res.status(500).json({
        error: 'Failed to send push notification',
        message: error.message
      });
    }
  }

  /**
   * Send wedding invitation notification
   * POST /api/notifications/wedding-invitation
   * Body: { token?, tokens?, topic?, inviterName, weddingDate? }
   */
  async sendWeddingInvitation(req, res) {
    try {
      const { token, tokens, topic, inviterName, weddingDate } = req.body;

      // Validate required fields
      if (!inviterName) {
        return res.status(400).json({
          error: 'Missing required fields',
          required: ['inviterName'],
          received: Object.keys(req.body)
        });
      }

      // Validate target
      if (!token && !tokens && !topic) {
        return res.status(400).json({
          error: 'Missing target',
          message: 'At least one target must be provided: token, tokens, or topic'
        });
      }

      // Send the wedding invitation notification
      const result = await pushNotificationService.sendWeddingInvitationNotification({
        token,
        tokens,
        topic,
        inviterName,
        weddingDate
      });

      logger.info('Wedding invitation notification sent via API:', {
        messageId: result.messageId,
        inviterName,
        recipients: result.recipients
      });

      res.status(200).json({
        success: true,
        message: 'Wedding invitation notification sent successfully',
        data: {
          messageId: result.messageId,
          recipients: result.recipients,
          failed: result.failed || 0,
          service: result.service,
          inviterName,
          weddingDate
        }
      });

    } catch (error) {
      logger.error('Error sending wedding invitation notification:', error);
      
      res.status(500).json({
        error: 'Failed to send wedding invitation notification',
        message: error.message
      });
    }
  }

  /**
   * Send task reminder notification
   * POST /api/notifications/task-reminder
   * Body: { token?, tokens?, topic?, taskTitle, dueDate? }
   */
  async sendTaskReminder(req, res) {
    try {
      const { token, tokens, topic, taskTitle, dueDate } = req.body;

      // Validate required fields
      if (!taskTitle) {
        return res.status(400).json({
          error: 'Missing required fields',
          required: ['taskTitle'],
          received: Object.keys(req.body)
        });
      }

      // Validate target
      if (!token && !tokens && !topic) {
        return res.status(400).json({
          error: 'Missing target',
          message: 'At least one target must be provided: token, tokens, or topic'
        });
      }

      // Send the task reminder notification
      const result = await pushNotificationService.sendTaskReminderNotification({
        token,
        tokens,
        topic,
        taskTitle,
        dueDate
      });

      logger.info('Task reminder notification sent via API:', {
        messageId: result.messageId,
        taskTitle,
        recipients: result.recipients
      });

      res.status(200).json({
        success: true,
        message: 'Task reminder notification sent successfully',
        data: {
          messageId: result.messageId,
          recipients: result.recipients,
          failed: result.failed || 0,
          service: result.service,
          taskTitle,
          dueDate
        }
      });

    } catch (error) {
      logger.error('Error sending task reminder notification:', error);
      
      res.status(500).json({
        error: 'Failed to send task reminder notification',
        message: error.message
      });
    }
  }

  /**
   * Send collaboration notification
   * POST /api/notifications/collaboration
   * Body: { token?, tokens?, topic?, collaboratorName, action }
   */
  async sendCollaboration(req, res) {
    try {
      const { token, tokens, topic, collaboratorName, action } = req.body;

      // Validate required fields
      if (!collaboratorName || !action) {
        return res.status(400).json({
          error: 'Missing required fields',
          required: ['collaboratorName', 'action'],
          received: Object.keys(req.body)
        });
      }

      // Validate action
      const validActions = ['joined', 'left', 'completed_task', 'updated'];
      if (!validActions.includes(action)) {
        return res.status(400).json({
          error: 'Invalid action',
          message: `Action must be one of: ${validActions.join(', ')}`
        });
      }

      // Validate target
      if (!token && !tokens && !topic) {
        return res.status(400).json({
          error: 'Missing target',
          message: 'At least one target must be provided: token, tokens, or topic'
        });
      }

      // Send the collaboration notification
      const result = await pushNotificationService.sendCollaborationNotification({
        token,
        tokens,
        topic,
        collaboratorName,
        action
      });

      logger.info('Collaboration notification sent via API:', {
        messageId: result.messageId,
        collaboratorName,
        action,
        recipients: result.recipients
      });

      res.status(200).json({
        success: true,
        message: 'Collaboration notification sent successfully',
        data: {
          messageId: result.messageId,
          recipients: result.recipients,
          failed: result.failed || 0,
          service: result.service,
          collaboratorName,
          action
        }
      });

    } catch (error) {
      logger.error('Error sending collaboration notification:', error);
      
      res.status(500).json({
        error: 'Failed to send collaboration notification',
        message: error.message
      });
    }
  }

  /**
   * Subscribe device to topic
   * POST /api/notifications/subscribe
   * Body: { token, topic }
   */
  async subscribeToTopic(req, res) {
    try {
      const { token, topic } = req.body;

      // Validate required fields
      if (!token || !topic) {
        return res.status(400).json({
          error: 'Missing required fields',
          required: ['token', 'topic'],
          received: Object.keys(req.body)
        });
      }

      // Subscribe to topic
      const result = await pushNotificationService.subscribeToTopic(token, topic);

      logger.info('Device subscribed to topic via API:', {
        token: token.substring(0, 20) + '...',
        topic
      });

      res.status(200).json({
        success: true,
        message: result.message,
        data: {
          topic,
          service: result.service
        }
      });

    } catch (error) {
      logger.error('Error subscribing to topic:', error);
      
      res.status(500).json({
        error: 'Failed to subscribe to topic',
        message: error.message
      });
    }
  }

  /**
   * Unsubscribe device from topic
   * POST /api/notifications/unsubscribe
   * Body: { token, topic }
   */
  async unsubscribeFromTopic(req, res) {
    try {
      const { token, topic } = req.body;

      // Validate required fields
      if (!token || !topic) {
        return res.status(400).json({
          error: 'Missing required fields',
          required: ['token', 'topic'],
          received: Object.keys(req.body)
        });
      }

      // Unsubscribe from topic
      const result = await pushNotificationService.unsubscribeFromTopic(token, topic);

      logger.info('Device unsubscribed from topic via API:', {
        token: token.substring(0, 20) + '...',
        topic
      });

      res.status(200).json({
        success: true,
        message: result.message,
        data: {
          topic,
          service: result.service
        }
      });

    } catch (error) {
      logger.error('Error unsubscribing from topic:', error);
      
      res.status(500).json({
        error: 'Failed to unsubscribe from topic',
        message: error.message
      });
    }
  }

  /**
   * Test push notification service connection
   * GET /api/notifications/test
   */
  async testConnection(req, res) {
    try {
      const isConnected = await pushNotificationService.verifyConnection();

      if (isConnected) {
        res.status(200).json({
          success: true,
          message: 'Push notification service connection is working',
          service: 'Firebase Cloud Messaging'
        });
      } else {
        res.status(503).json({
          success: false,
          message: 'Push notification service connection failed',
          service: 'Mock Service'
        });
      }
    } catch (error) {
      logger.error('Error testing push notification connection:', error);

      res.status(500).json({
        error: 'Failed to test push notification connection',
        message: error.message
      });
    }
  }

  /**
   * Get push notification service status
   * GET /api/notifications/status
   */
  async getStatus(req, res) {
    try {
      const isConnected = await pushNotificationService.verifyConnection();
      const stats = pushNotificationService.getNotificationStats();

      res.status(200).json({
        service: 'Push Notification API',
        status: isConnected ? 'connected' : 'disconnected',
        environment: process.env.NODE_ENV || 'development',
        configured: {
          firebaseProjectId: !!process.env.FIREBASE_PROJECT_ID,
          firebaseServiceAccount: !!(process.env.FIREBASE_SERVICE_ACCOUNT_KEY ||
                                     (process.env.FIREBASE_PRIVATE_KEY && process.env.FIREBASE_CLIENT_EMAIL))
        },
        stats
      });
    } catch (error) {
      logger.error('Error getting push notification status:', error);

      res.status(500).json({
        error: 'Failed to get push notification status',
        message: error.message
      });
    }
  }

  /**
   * Get all sent notifications
   * GET /api/notifications/sent
   */
  async getSentNotifications(req, res) {
    try {
      const notifications = pushNotificationService.getSentNotifications();
      const stats = pushNotificationService.getNotificationStats();

      res.status(200).json({
        success: true,
        count: notifications.length,
        stats,
        notifications: notifications
      });
    } catch (error) {
      logger.error('Error getting sent notifications:', error);
      res.status(500).json({
        error: 'Failed to get sent notifications',
        message: error.message
      });
    }
  }

  /**
   * Get specific notification by ID
   * GET /api/notifications/:id
   */
  async getNotification(req, res) {
    try {
      const { id } = req.params;
      const notification = pushNotificationService.getNotification(id);

      if (!notification) {
        return res.status(404).json({
          error: 'Notification not found',
          id: id
        });
      }

      res.status(200).json({
        success: true,
        notification: notification
      });
    } catch (error) {
      logger.error('Error getting notification:', error);
      res.status(500).json({
        error: 'Failed to get notification',
        message: error.message
      });
    }
  }
}

module.exports = new PushNotificationController();
