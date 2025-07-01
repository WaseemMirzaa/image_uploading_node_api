const nodemailer = require('nodemailer');
const logger = require('../utils/logger');

class RealEmailService {
  constructor() {
    this.transporter = null;
    this.emails = []; // Store sent emails for debugging
    this.initializeTransporter();
  }

  async initializeTransporter() {
    try {
      // Try multiple email services in order of preference
      const emailConfigs = [
        {
          name: 'Gmail',
          config: {
            service: 'gmail',
            host: 'smtp.gmail.com',
            port: 587,
            secure: false,
            auth: {
              user: 'unicorndev.02.1997@gmail.com',
              pass: 'your-gmail-app-password' // You need to set this
            },
            tls: { rejectUnauthorized: false }
          }
        },
        {
          name: 'SendGrid',
          config: {
            host: 'smtp.sendgrid.net',
            port: 587,
            secure: false,
            auth: {
              user: 'apikey',
              pass: process.env.SENDGRID_API_KEY || 'your-sendgrid-api-key'
            }
          }
        }
      ];

      // Try each configuration
      for (const emailConfig of emailConfigs) {
        try {
          this.transporter = nodemailer.createTransport(emailConfig.config);
          await this.transporter.verify();
          logger.info(`Real email service initialized with ${emailConfig.name}`);
          return;
        } catch (configError) {
          logger.warn(`Failed to initialize ${emailConfig.name}:`, configError.message);
        }
      }

      // Fallback to Ethereal for testing if all real services fail
      const testAccount = await nodemailer.createTestAccount();
      this.transporter = nodemailer.createTransport({
        host: 'smtp.ethereal.email',
        port: 587,
        secure: false,
        auth: {
          user: testAccount.user,
          pass: testAccount.pass
        }
      });
      logger.info('Using Ethereal test account (emails will be logged only):', testAccount.user);

    } catch (error) {
      logger.error('Failed to initialize any email service:', error);
      throw error;
    }
  }

  async sendEmail(emailData) {
    const { to, subject, message, from } = emailData;

    if (!to || !subject || !message) {
      throw new Error('Missing required fields: to, subject, and message are required');
    }

    // Create email record for debugging
    const emailRecord = {
      id: 'real-' + Date.now() + '-' + Math.random().toString(36).substr(2, 9),
      to: to,
      from: from || '4secrets-wedding@gmx.de',
      subject: subject,
      message: message,
      timestamp: new Date().toISOString(),
      status: 'sending'
    };

    const mailOptions = {
      from: `"4 Secrets Wedding" <4secrets-wedding@gmx.de>`, // Use the wedding email as sender
      to: to,
      subject: subject,
      text: message,
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
          <div style="text-align: center; margin-bottom: 30px;">
            <h1 style="color: #d63384; margin: 0;">💍 4 Secrets Wedding</h1>
          </div>
          <div style="background: #f8f9fa; padding: 20px; border-radius: 10px; margin-bottom: 20px;">
            <h2 style="color: #495057; margin-top: 0;">${subject}</h2>
            <div style="line-height: 1.8; color: #212529; font-size: 16px;">
              ${message.replace(/\n/g, '<br>')}
            </div>
          </div>
          <div style="text-align: center; padding: 20px; border-top: 1px solid #dee2e6;">
            <p style="color: #6c757d; font-size: 14px; margin: 0;">
              📱 Diese E-Mail wurde von der 4 Secrets Wedding App gesendet
            </p>
          </div>
        </div>
      `
    };

    try {
      // Send the actual email
      const info = await this.transporter.sendMail(mailOptions);
      
      emailRecord.status = 'sent';
      emailRecord.messageId = info.messageId;
      this.emails.push(emailRecord);

      logger.info('📧 REAL EMAIL SENT:', {
        messageId: info.messageId,
        to: to,
        subject: subject,
        preview: message.substring(0, 100) + '...'
      });

      // Also log full email content for debugging
      console.log('\n=== REAL EMAIL SENT ===');
      console.log('To:', to);
      console.log('Subject:', subject);
      console.log('Message ID:', info.messageId);
      console.log('Preview URL:', nodemailer.getTestMessageUrl(info) || 'N/A');
      console.log('========================\n');

      return {
        success: true,
        messageId: info.messageId,
        previewUrl: nodemailer.getTestMessageUrl(info) || null
      };
    } catch (error) {
      emailRecord.status = 'failed';
      emailRecord.error = error.message;
      this.emails.push(emailRecord);

      logger.error('Failed to send real email:', error);
      throw new Error(`Failed to send email: ${error.message}`);
    }
  }

  async verifyConnection() {
    try {
      if (!this.transporter) {
        await this.initializeTransporter();
      }
      await this.transporter.verify();
      logger.info('Real email service connection verified');
      return true;
    } catch (error) {
      logger.error('Real email service connection failed:', error);
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

module.exports = new RealEmailService();
