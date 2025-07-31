const logger = require('../utils/logger');

class MockEmailService {
  constructor() {
    this.emails = []; // Store sent emails in memory
  }

  async sendEmail(emailData) {
    const { to, subject, message, from } = emailData;

    if (!to || !subject || !message) {
      throw new Error('Missing required fields: to, subject, and message are required');
    }

    // Create email record
    const emailRecord = {
      id: 'mock-' + Date.now() + '-' + Math.random().toString(36).substr(2, 9),
      to: to,
      from: from || '4secrets-wedding@gmx.de',
      subject: subject,
      message: message,
      timestamp: new Date().toISOString(),
      status: 'sent'
    };

    // Store email
    this.emails.push(emailRecord);

    // Log the email (this will appear in PM2 logs)
    logger.info('📧 MOCK EMAIL SENT:', {
      messageId: emailRecord.id,
      to: to,
      subject: subject,
      preview: message.substring(0, 100) + '...'
    });

    // Also log full email content for debugging
    console.log('\n=== EMAIL SENT ===');
    console.log('To:', to);
    console.log('Subject:', subject);
    console.log('Message:', message);
    console.log('Message ID:', emailRecord.id);
    console.log('==================\n');

    return {
      success: true,
      messageId: emailRecord.id,
      previewUrl: `http://localhost:3000/api/email/preview/${emailRecord.id}`
    };
  }

  async verifyConnection() {
    logger.info('Mock email service is always connected');
    return true;
  }

  // Get sent emails (for debugging)
  getSentEmails() {
    return this.emails;
  }

  // Get specific email
  getEmail(id) {
    return this.emails.find(email => email.id === id);
  }
}

module.exports = new MockEmailService();
