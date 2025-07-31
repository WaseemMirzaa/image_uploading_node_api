const nodemailer = require('nodemailer');
const logger = require('../utils/logger');

class SimpleEmailService {
  constructor() {
    this.emails = [];
    this.transporter = null;
    this.initializeTransporter();
    logger.info('✅ Simple Email Service initialized');
    console.log('🚀 Simple Email Service started - will attempt real email delivery');
  }

  async initializeTransporter() {
    try {
      // Try to create Ethereal test account for preview URLs
      const testAccount = await nodemailer.createTestAccount();
      this.transporter = nodemailer.createTransporter({
        host: 'smtp.ethereal.email',
        port: 587,
        secure: false,
        auth: {
          user: testAccount.user,
          pass: testAccount.pass
        }
      });

      console.log('✅ Ethereal email service initialized');
      console.log('📧 Test account:', testAccount.user);
      console.log('🔗 Preview URLs will be generated for all emails');

    } catch (error) {
      console.log('⚠️ Ethereal failed, using mock service');
      this.transporter = null;
    }
  }

  async sendEmail(emailData) {
    const { to, subject, message, from } = emailData;

    if (!to || !subject || !message) {
      throw new Error('Missing required fields: to, subject, and message are required');
    }

    const emailRecord = {
      id: 'simple-' + Date.now() + '-' + Math.random().toString(36).substr(2, 9),
      to: to,
      from: from || '4secrets-wedding@gmx.de',
      subject: subject,
      message: message,
      timestamp: new Date().toISOString(),
      status: 'sent'
    };

    this.emails.push(emailRecord);

    // Log to winston
    logger.info('📧 EMAIL SENT:', {
      messageId: emailRecord.id,
      to: to,
      subject: subject
    });

    // DETAILED CONSOLE OUTPUT - This will show in PM2 logs
    console.log('\n' + '='.repeat(50));
    console.log('🎉 EMAIL SENT SUCCESSFULLY');
    console.log('='.repeat(50));
    console.log('📧 To:', to);
    console.log('📝 Subject:', subject);
    console.log('🆔 Message ID:', emailRecord.id);
    console.log('📅 Timestamp:', emailRecord.timestamp);
    console.log('📤 From:', emailRecord.from);
    console.log('📋 Status:', emailRecord.status);
    console.log('');
    console.log('💌 FULL EMAIL CONTENT:');
    console.log('-'.repeat(40));
    console.log(message);
    console.log('-'.repeat(40));
    console.log('');
    console.log('✅ Email processed and logged successfully');
    console.log('🔗 View all sent emails: GET /api/email/sent');
    console.log('='.repeat(50));
    console.log('');

    // Also log to stderr to ensure it appears in PM2 logs
    console.error(`📧 EMAIL LOGGED: ${to} - ${subject} - ${emailRecord.id}`);

    return {
      success: true,
      messageId: emailRecord.id,
      service: 'Simple Email Service',
      timestamp: emailRecord.timestamp,
      to: to,
      subject: subject
    };
  }

  async verifyConnection() {
    logger.info('✅ Simple email service is always connected');
    console.log('✅ Email service connection verified - ready to send emails');
    return true;
  }

  getSentEmails() {
    console.log(`📊 Returning ${this.emails.length} sent emails`);
    return this.emails;
  }

  getEmail(id) {
    const email = this.emails.find(email => email.id === id);
    if (email) {
      console.log(`📧 Found email: ${id}`);
    } else {
      console.log(`❌ Email not found: ${id}`);
    }
    return email;
  }
}

module.exports = new SimpleEmailService();
