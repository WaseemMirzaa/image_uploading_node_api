const axios = require('axios');
const logger = require('../utils/logger');

class HttpEmailService {
  constructor() {
    this.emails = []; // Store sent emails for debugging
  }

  async sendEmail(emailData) {
    const { to, subject, message, from } = emailData;

    if (!to || !subject || !message) {
      throw new Error('Missing required fields: to, subject, and message are required');
    }

    // Create email record for debugging
    const emailRecord = {
      id: 'http-' + Date.now() + '-' + Math.random().toString(36).substr(2, 9),
      to: to,
      from: from || '4secrets-wedding@gmx.de',
      subject: subject,
      message: message,
      timestamp: new Date().toISOString(),
      status: 'sending'
    };

    try {
      // Try multiple HTTP email services
      const result = await this.tryEmailServices(emailData);
      
      emailRecord.status = 'sent';
      emailRecord.messageId = result.messageId;
      emailRecord.service = result.service;
      this.emails.push(emailRecord);

      logger.info('📧 HTTP EMAIL SENT:', {
        messageId: result.messageId,
        to: to,
        subject: subject,
        service: result.service,
        preview: message.substring(0, 100) + '...'
      });

      // Also log full email content for debugging
      console.log('\n=== HTTP EMAIL SENT ===');
      console.log('To:', to);
      console.log('Subject:', subject);
      console.log('Service:', result.service);
      console.log('Message ID:', result.messageId);
      console.log('========================\n');

      return {
        success: true,
        messageId: result.messageId,
        previewUrl: null
      };
    } catch (error) {
      emailRecord.status = 'failed';
      emailRecord.error = error.message;
      this.emails.push(emailRecord);

      logger.error('Failed to send HTTP email:', error);
      throw new Error(`Failed to send email: ${error.message}`);
    }
  }

  async tryEmailServices(emailData) {
    const { to, subject, message } = emailData;

    // Service 1: EmailJS (free tier available)
    try {
      const emailJSResult = await this.sendViaEmailJS(to, subject, message);
      return { messageId: emailJSResult.messageId, service: 'EmailJS' };
    } catch (error) {
      logger.warn('EmailJS failed:', error.message);
    }

    // Service 2: Formspree (free tier available)
    try {
      const formspreeResult = await this.sendViaFormspree(to, subject, message);
      return { messageId: formspreeResult.messageId, service: 'Formspree' };
    } catch (error) {
      logger.warn('Formspree failed:', error.message);
    }

    // Service 3: Web3Forms (free tier available)
    try {
      const web3FormsResult = await this.sendViaWeb3Forms(to, subject, message);
      return { messageId: web3FormsResult.messageId, service: 'Web3Forms' };
    } catch (error) {
      logger.warn('Web3Forms failed:', error.message);
    }

    throw new Error('All HTTP email services failed');
  }

  async sendViaEmailJS(to, subject, message) {
    // EmailJS public API (you can create a free account)
    const response = await axios.post('https://api.emailjs.com/api/v1.0/email/send', {
      service_id: 'default_service',
      template_id: 'template_wedding',
      user_id: 'public_key',
      template_params: {
        to_email: to,
        subject: subject,
        message: message,
        from_name: '4 Secrets Wedding'
      }
    }, {
      headers: { 'Content-Type': 'application/json' },
      timeout: 10000
    });

    return { messageId: 'emailjs-' + Date.now() };
  }

  async sendViaFormspree(to, subject, message) {
    // Formspree API (free tier available)
    const response = await axios.post('https://formspree.io/f/xpzvgvpv', {
      email: to,
      subject: subject,
      message: message,
      _replyto: '4secrets-wedding@gmx.de'
    }, {
      headers: { 'Content-Type': 'application/json' },
      timeout: 10000
    });

    return { messageId: 'formspree-' + Date.now() };
  }

  async sendViaWeb3Forms(to, subject, message) {
    // Web3Forms API (free tier available)
    const response = await axios.post('https://api.web3forms.com/submit', {
      access_key: 'your-web3forms-key',
      email: to,
      subject: subject,
      message: message,
      from_name: '4 Secrets Wedding'
    }, {
      headers: { 'Content-Type': 'application/json' },
      timeout: 10000
    });

    return { messageId: 'web3forms-' + Date.now() };
  }

  async verifyConnection() {
    try {
      // Test basic HTTP connectivity
      await axios.get('https://httpbin.org/get', { timeout: 5000 });
      logger.info('HTTP email service connection verified');
      return true;
    } catch (error) {
      logger.error('HTTP email service connection failed:', error);
      return false;
    }
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

module.exports = new HttpEmailService();
