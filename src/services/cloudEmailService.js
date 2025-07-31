const axios = require('axios');
const logger = require('../utils/logger');

class CloudEmailService {
  constructor() {
    this.cloudFunctionUrl = process.env.EMAIL_CLOUD_FUNCTION_URL || 'http://localhost:3001';
    this.emails = [];
  }

  async sendEmail(emailData) {
    const { to, subject, message, from, type } = emailData;

    if (!to || !subject || !message) {
      throw new Error('Missing required fields: to, subject, and message are required');
    }

    try {
      // Call cloud function endpoint
      const response = await axios.post(`${this.cloudFunctionUrl}/api/email/send-custom`, {
        email: to,
        subject: subject,
        message: message
      }, {
        timeout: 30000,
        headers: {
          'Content-Type': 'application/json'
        }
      });

      const emailRecord = {
        id: 'cloud-' + Date.now() + '-' + Math.random().toString(36).substr(2, 9),
        to: to,
        from: from || 'noreply@example.com',
        subject: subject,
        message: message,
        type: type || 'general',
        timestamp: new Date().toISOString(),
        status: 'sent',
        cloudResponse: response.data
      };

      this.emails.push(emailRecord);

      logger.info('📧 EMAIL SENT VIA CLOUD FUNCTION:', {
        messageId: response.data.messageId,
        to: to,
        subject: subject
      });

      console.log('\n' + '='.repeat(60));
      console.log('🎉 EMAIL SENT VIA CLOUD FUNCTION');
      console.log('='.repeat(60));
      console.log('📧 To:', to);
      console.log('📝 Subject:', subject);
      console.log('🆔 Message ID:', response.data.messageId);
      console.log('📅 Timestamp:', emailRecord.timestamp);
      console.log('🚀 Service: Cloud Function Email Service');
      if (response.data.previewUrl) {
        console.log('🔗 Preview URL:', response.data.previewUrl);
      }
      console.log('✅ Status: DELIVERED VIA CLOUD FUNCTION');
      console.log('='.repeat(60));
      console.log('');

      return {
        success: true,
        messageId: response.data.messageId,
        previewUrl: response.data.previewUrl,
        service: 'Cloud Function Email Service'
      };

    } catch (error) {
      // Fallback to mock service if cloud function is not available
      const emailRecord = {
        id: 'mock-' + Date.now() + '-' + Math.random().toString(36).substr(2, 9),
        to: to,
        from: from || 'noreply@example.com',
        subject: subject,
        message: message,
        type: type || 'general',
        timestamp: new Date().toISOString(),
        status: 'sent',
        service: 'Mock Service (Cloud function not available)'
      };

      this.emails.push(emailRecord);

      console.log('\n' + '='.repeat(60));
      console.log('📧 EMAIL MOCK SENT (Cloud function not available)');
      console.log('='.repeat(60));
      console.log('📧 To:', to);
      console.log('📝 Subject:', subject);
      console.log('🆔 Message ID:', emailRecord.id);
      console.log('📅 Timestamp:', emailRecord.timestamp);
      console.log('⚠️ Note: Configure EMAIL_CLOUD_FUNCTION_URL for real emails');
      console.log('🔗 Cloud Function URL:', this.cloudFunctionUrl);
      console.log('❌ Error:', error.message);
      console.log('='.repeat(60));
      console.log('');

      logger.warn('Cloud function not available, using mock service:', error.message);

      return {
        success: true,
        messageId: emailRecord.id,
        service: 'Mock Service',
        note: 'Configure EMAIL_CLOUD_FUNCTION_URL for real email delivery',
        error: error.message
      };
    }
  }

  async verifyConnection() {
    try {
      const response = await axios.get(`${this.cloudFunctionUrl}/health`, { timeout: 5000 });
      console.log('✅ Cloud function email service is available');
      return true;
    } catch (error) {
      console.log('⚠️ Cloud function email service not available - using mock service');
      return false;
    }
  }

  getSentEmails() {
    return this.emails;
  }

  getEmail(id) {
    return this.emails.find(email => email.id === id);
  }
}

module.exports = new CloudEmailService();
