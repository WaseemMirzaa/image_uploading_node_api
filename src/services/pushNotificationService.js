const admin = require('firebase-admin');
const logger = require('../utils/logger');

class PushNotificationService {
  constructor() {
    this.isInitialized = false;
    this.sentNotifications = [];
    this.initializeFirebase();
  }

  async initializeFirebase() {
    try {
      // Check if Firebase is already initialized
      if (admin.apps.length === 0) {
        // Initialize Firebase Admin SDK
        const serviceAccount = this.getServiceAccountConfig();

        console.log('🔍 Firebase Configuration Debug:');
        console.log('- FIREBASE_PROJECT_ID:', process.env.FIREBASE_PROJECT_ID || 'NOT SET');
        console.log('- FIREBASE_SERVICE_ACCOUNT_KEY:', process.env.FIREBASE_SERVICE_ACCOUNT_KEY ? 'SET (length: ' + process.env.FIREBASE_SERVICE_ACCOUNT_KEY.length + ')' : 'NOT SET');
        console.log('- FIREBASE_CLIENT_EMAIL:', process.env.FIREBASE_CLIENT_EMAIL || 'NOT SET');
        console.log('- Service Account Config:', serviceAccount ? 'VALID' : 'INVALID');

        if (serviceAccount) {
          admin.initializeApp({
            credential: admin.credential.cert(serviceAccount),
            projectId: process.env.FIREBASE_PROJECT_ID || 'secrets-wedding'
          });

          console.log('✅ Firebase Admin SDK initialized successfully');
          console.log('🔥 Project ID:', process.env.FIREBASE_PROJECT_ID || 'secrets-wedding');
          console.log('📧 Service Account Email:', serviceAccount.client_email);
          logger.info('Firebase Admin SDK initialized for push notifications');
          this.isInitialized = true;
        } else {
          console.log('⚠️ Firebase service account not configured - using mock mode');
          console.log('💡 To enable real notifications:');
          console.log('   1. Get service account key from Firebase Console');
          console.log('   2. Add FIREBASE_SERVICE_ACCOUNT_KEY to .env file');
          console.log('   3. Restart the server');
          logger.warn('Firebase service account not configured - using mock mode');
          this.isInitialized = false;
        }
      } else {
        console.log('✅ Firebase Admin SDK already initialized');
        this.isInitialized = true;
      }
    } catch (error) {
      console.error('❌ Failed to initialize Firebase Admin SDK:', error.message);
      console.error('🔍 Error details:', error);
      logger.error('Failed to initialize Firebase Admin SDK:', error);
      this.isInitialized = false;
    }
  }

  getServiceAccountConfig() {
    // Try to get service account from environment variables
    if (process.env.FIREBASE_SERVICE_ACCOUNT_KEY) {
      try {
        return JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT_KEY);
      } catch (error) {
        logger.error('Invalid FIREBASE_SERVICE_ACCOUNT_KEY JSON:', error);
        return null;
      }
    }

    // Try to get individual service account fields
    if (process.env.FIREBASE_PROJECT_ID && 
        process.env.FIREBASE_PRIVATE_KEY && 
        process.env.FIREBASE_CLIENT_EMAIL) {
      return {
        type: 'service_account',
        project_id: process.env.FIREBASE_PROJECT_ID,
        private_key_id: process.env.FIREBASE_PRIVATE_KEY_ID,
        private_key: process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n'),
        client_email: process.env.FIREBASE_CLIENT_EMAIL,
        client_id: process.env.FIREBASE_CLIENT_ID,
        auth_uri: 'https://accounts.google.com/o/oauth2/auth',
        token_uri: 'https://oauth2.googleapis.com/token',
        auth_provider_x509_cert_url: 'https://www.googleapis.com/oauth2/v1/certs',
        client_x509_cert_url: `https://www.googleapis.com/robot/v1/metadata/x509/${encodeURIComponent(process.env.FIREBASE_CLIENT_EMAIL)}`
      };
    }

    return null;
  }

  async sendNotification(notificationData) {
    const { token, tokens, topic, title, body, data, imageUrl, sound, badge } = notificationData;

    if (!this.isInitialized) {
      return this.sendMockNotification(notificationData);
    }

    try {
      // Prepare the message payload
      const message = {
        notification: {
          title: title || 'Neue Nachricht',
          body: body || 'Sie haben eine neue Nachricht erhalten',
          ...(imageUrl && { imageUrl })
        },
        data: {
          ...data,
          timestamp: new Date().toISOString(),
          type: data?.type || 'general'
        },
        android: {
          notification: {
            icon: 'ic_notification',
            color: '#6B456A',
            sound: sound || 'default',
            channelId: 'wedding_notifications',
            priority: 'high'
          },
          data: {
            click_action: 'FLUTTER_NOTIFICATION_CLICK',
            ...data
          }
        },
        apns: {
          payload: {
            aps: {
              alert: {
                title: title || 'Neue Nachricht',
                body: body || 'Sie haben eine neue Nachricht erhalten'
              },
              sound: sound || 'default',
              badge: badge || 1,
              'content-available': 1
            }
          },
          fcmOptions: {
            ...(imageUrl && { imageUrl })
          }
        }
      };

      let result;
      
      if (token) {
        // Send to single device
        message.token = token;
        result = await admin.messaging().send(message);
        
        const notificationRecord = this.createNotificationRecord({
          ...notificationData,
          messageId: result,
          recipients: 1,
          status: 'sent'
        });
        
        this.sentNotifications.push(notificationRecord);
        
        console.log('\n' + '='.repeat(60));
        console.log('🔔 PUSH NOTIFICATION SENT SUCCESSFULLY');
        console.log('='.repeat(60));
        console.log('📱 Target: Single Device');
        console.log('🆔 Message ID:', result);
        console.log('📝 Title:', title);
        console.log('💬 Body:', body);
        console.log('📅 Timestamp:', notificationRecord.timestamp);
        console.log('✅ Status: DELIVERED');
        console.log('='.repeat(60));
        console.log('');
        
        logger.info('Push notification sent to single device:', {
          messageId: result,
          title,
          body,
          token: token.substring(0, 20) + '...'
        });
        
        return {
          success: true,
          messageId: result,
          recipients: 1,
          service: 'Firebase Cloud Messaging'
        };
        
      } else if (tokens && tokens.length > 0) {
        // Send to multiple devices
        message.tokens = tokens;
        result = await admin.messaging().sendEachForMulticast(message);
        
        const notificationRecord = this.createNotificationRecord({
          ...notificationData,
          messageId: `multicast-${Date.now()}`,
          recipients: result.successCount,
          failed: result.failureCount,
          status: result.successCount > 0 ? 'sent' : 'failed'
        });
        
        this.sentNotifications.push(notificationRecord);
        
        console.log('\n' + '='.repeat(60));
        console.log('🔔 MULTICAST PUSH NOTIFICATION SENT');
        console.log('='.repeat(60));
        console.log('📱 Target: Multiple Devices');
        console.log('📊 Total Recipients:', tokens.length);
        console.log('✅ Successful:', result.successCount);
        console.log('❌ Failed:', result.failureCount);
        console.log('📝 Title:', title);
        console.log('💬 Body:', body);
        console.log('📅 Timestamp:', notificationRecord.timestamp);
        console.log('='.repeat(60));
        console.log('');
        
        logger.info('Multicast push notification sent:', {
          totalRecipients: tokens.length,
          successCount: result.successCount,
          failureCount: result.failureCount,
          title,
          body
        });
        
        return {
          success: true,
          messageId: notificationRecord.messageId,
          recipients: result.successCount,
          failed: result.failureCount,
          service: 'Firebase Cloud Messaging'
        };
        
      } else if (topic) {
        // Send to topic
        message.topic = topic;
        result = await admin.messaging().send(message);
        
        const notificationRecord = this.createNotificationRecord({
          ...notificationData,
          messageId: result,
          recipients: 'topic',
          status: 'sent'
        });
        
        this.sentNotifications.push(notificationRecord);
        
        console.log('\n' + '='.repeat(60));
        console.log('🔔 TOPIC PUSH NOTIFICATION SENT');
        console.log('='.repeat(60));
        console.log('📱 Target: Topic Subscribers');
        console.log('🏷️ Topic:', topic);
        console.log('🆔 Message ID:', result);
        console.log('📝 Title:', title);
        console.log('💬 Body:', body);
        console.log('📅 Timestamp:', notificationRecord.timestamp);
        console.log('✅ Status: DELIVERED');
        console.log('='.repeat(60));
        console.log('');
        
        logger.info('Push notification sent to topic:', {
          messageId: result,
          topic,
          title,
          body
        });
        
        return {
          success: true,
          messageId: result,
          topic: topic,
          service: 'Firebase Cloud Messaging'
        };
      } else {
        throw new Error('No target specified: provide token, tokens, or topic');
      }
      
    } catch (error) {
      logger.error('Failed to send push notification:', error);
      
      const notificationRecord = this.createNotificationRecord({
        ...notificationData,
        messageId: null,
        status: 'failed',
        error: error.message
      });
      
      this.sentNotifications.push(notificationRecord);
      
      throw new Error(`Failed to send push notification: ${error.message}`);
    }
  }

  sendMockNotification(notificationData) {
    const { title, body, token, tokens, topic } = notificationData;

    const notificationRecord = this.createNotificationRecord({
      ...notificationData,
      messageId: `mock-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
      recipients: tokens ? tokens.length : (topic ? 'topic' : 1),
      status: 'sent',
      service: 'Mock Service'
    });

    this.sentNotifications.push(notificationRecord);

    console.log('\n' + '='.repeat(60));
    console.log('🔔 MOCK PUSH NOTIFICATION SENT');
    console.log('='.repeat(60));
    console.log('📱 Target:', token ? 'Single Device' : tokens ? 'Multiple Devices' : 'Topic');
    console.log('🆔 Message ID:', notificationRecord.messageId);
    console.log('📝 Title:', title);
    console.log('💬 Body:', body);
    console.log('📅 Timestamp:', notificationRecord.timestamp);
    console.log('⚠️ Note: Configure Firebase credentials for real notifications');
    console.log('✅ Status: MOCK DELIVERED');
    console.log('='.repeat(60));
    console.log('');

    logger.info('Mock push notification sent:', {
      messageId: notificationRecord.messageId,
      title,
      body,
      target: token ? 'single' : tokens ? 'multiple' : 'topic'
    });

    return {
      success: true,
      messageId: notificationRecord.messageId,
      recipients: notificationRecord.recipients,
      service: 'Mock Service',
      note: 'Configure Firebase credentials for real push notifications'
    };
  }

  createNotificationRecord(data) {
    return {
      id: `notification-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
      messageId: data.messageId,
      title: data.title,
      body: data.body,
      data: data.data || {},
      recipients: data.recipients,
      failed: data.failed || 0,
      status: data.status,
      service: data.service || 'Firebase Cloud Messaging',
      timestamp: new Date().toISOString(),
      error: data.error || null
    };
  }

  async sendWeddingInvitationNotification(notificationData) {
    const { token, tokens, topic, inviterName, weddingDate } = notificationData;

    const title = 'Neue Hochzeitseinladung! 💍';
    const body = `${inviterName} hat Sie zur Hochzeitsplanung eingeladen. Tippen Sie hier, um die Einladung anzunehmen.`;

    return this.sendNotification({
      token,
      tokens,
      topic,
      title,
      body,
      data: {
        type: 'wedding_invitation',
        inviterName,
        weddingDate: weddingDate || null,
        action: 'open_invitation'
      },
      sound: 'wedding_bell.mp3',
      badge: 1
    });
  }

  async sendTaskReminderNotification(notificationData) {
    const { token, tokens, topic, taskTitle, dueDate } = notificationData;

    const title = 'Hochzeitsaufgabe fällig! 📋';
    const body = `Erinnerung: "${taskTitle}" ist ${dueDate ? `am ${dueDate} ` : ''}fällig.`;

    return this.sendNotification({
      token,
      tokens,
      topic,
      title,
      body,
      data: {
        type: 'task_reminder',
        taskTitle,
        dueDate: dueDate || null,
        action: 'open_tasks'
      },
      sound: 'reminder.mp3',
      badge: 1
    });
  }

  async sendCollaborationNotification(notificationData) {
    const { token, tokens, topic, collaboratorName, action } = notificationData;

    let title, body;

    switch (action) {
      case 'joined':
        title = 'Neuer Mitarbeiter! 👥';
        body = `${collaboratorName} ist der Hochzeitsplanung beigetreten.`;
        break;
      case 'left':
        title = 'Mitarbeiter verlassen 👋';
        body = `${collaboratorName} hat die Hochzeitsplanung verlassen.`;
        break;
      case 'completed_task':
        title = 'Aufgabe erledigt! ✅';
        body = `${collaboratorName} hat eine Aufgabe abgeschlossen.`;
        break;
      default:
        title = 'Hochzeitsplanung Update 💒';
        body = `${collaboratorName} hat Änderungen vorgenommen.`;
    }

    return this.sendNotification({
      token,
      tokens,
      topic,
      title,
      body,
      data: {
        type: 'collaboration',
        collaboratorName,
        action,
        action_target: 'open_wedding_kit'
      },
      sound: 'collaboration.mp3',
      badge: 1
    });
  }

  async sendGeneralNotification(notificationData) {
    const { token, tokens, topic, title, body, data, imageUrl } = notificationData;

    return this.sendNotification({
      token,
      tokens,
      topic,
      title: title || 'Neue Nachricht',
      body: body || 'Sie haben eine neue Nachricht erhalten',
      data: {
        type: 'general',
        ...data
      },
      imageUrl,
      sound: 'default',
      badge: 1
    });
  }

  async subscribeToTopic(token, topic) {
    if (!this.isInitialized) {
      logger.warn('Firebase not initialized - cannot subscribe to topic');
      return {
        success: false,
        message: 'Firebase not initialized',
        service: 'Mock Service'
      };
    }

    try {
      await admin.messaging().subscribeToTopic(token, topic);

      logger.info('Device subscribed to topic:', { token: token.substring(0, 20) + '...', topic });

      return {
        success: true,
        message: `Successfully subscribed to topic: ${topic}`,
        service: 'Firebase Cloud Messaging'
      };
    } catch (error) {
      logger.error('Failed to subscribe to topic:', error);
      throw new Error(`Failed to subscribe to topic: ${error.message}`);
    }
  }

  async unsubscribeFromTopic(token, topic) {
    if (!this.isInitialized) {
      logger.warn('Firebase not initialized - cannot unsubscribe from topic');
      return {
        success: false,
        message: 'Firebase not initialized',
        service: 'Mock Service'
      };
    }

    try {
      await admin.messaging().unsubscribeFromTopic(token, topic);

      logger.info('Device unsubscribed from topic:', { token: token.substring(0, 20) + '...', topic });

      return {
        success: true,
        message: `Successfully unsubscribed from topic: ${topic}`,
        service: 'Firebase Cloud Messaging'
      };
    } catch (error) {
      logger.error('Failed to unsubscribe from topic:', error);
      throw new Error(`Failed to unsubscribe from topic: ${error.message}`);
    }
  }

  async verifyConnection() {
    try {
      if (!this.isInitialized) {
        return false;
      }

      // Try to access Firebase messaging service
      const messaging = admin.messaging();
      return !!messaging;
    } catch (error) {
      logger.error('Firebase connection verification failed:', error);
      return false;
    }
  }

  getSentNotifications() {
    return this.sentNotifications;
  }

  getNotification(id) {
    return this.sentNotifications.find(notification => notification.id === id);
  }

  getNotificationStats() {
    const total = this.sentNotifications.length;
    const sent = this.sentNotifications.filter(n => n.status === 'sent').length;
    const failed = this.sentNotifications.filter(n => n.status === 'failed').length;

    return {
      total,
      sent,
      failed,
      successRate: total > 0 ? ((sent / total) * 100).toFixed(2) + '%' : '0%'
    };
  }
}

module.exports = new PushNotificationService();
