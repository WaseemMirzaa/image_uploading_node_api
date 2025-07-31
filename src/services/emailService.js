const nodemailer = require('nodemailer');
const axios = require('axios');
const logger = require('../utils/logger');

class EmailService {
  constructor() {
    this.transporter = null;
    this.initializeTransporter();
  }

  initializeTransporter() {
    // Configure the email transporter
    // Check if SMTP configuration is provided
    if (process.env.SMTP_HOST && process.env.EMAIL_USER && process.env.EMAIL_PASS) {
      // GMX configuration matching Elena's working Python code
      this.transporter = nodemailer.createTransport({
        host: process.env.SMTP_HOST,
        port: parseInt(process.env.SMTP_PORT) || 587,
        secure: false, // false for 587 (STARTTLS), true for 465 (SSL)
        requireTLS: true, // Force STARTTLS for port 587
        auth: {
          user: process.env.EMAIL_USER, // Full email address as username
          pass: process.env.EMAIL_PASS
        },
        tls: {
          // Do not fail on invalid certs (for development)
          rejectUnauthorized: false
        }
      });
    } else {
      // Fallback to Gmail configuration
      this.transporter = nodemailer.createTransport({
        service: 'gmail',
        auth: {
          user: process.env.EMAIL_USER,
          pass: process.env.EMAIL_PASS
        }
      });
    }



    // For development/testing, you can use Ethereal Email (creates test accounts)
    if (process.env.NODE_ENV === 'development' && !process.env.EMAIL_USER) {
      this.createTestAccount();
    }
  }

  async createTestAccount() {
    try {
      // Create a test account for development
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

      logger.info('Test email account created:');
      logger.info(`User: ${testAccount.user}`);
      logger.info(`Pass: ${testAccount.pass}`);
    } catch (error) {
      logger.error('Failed to create test email account:', error);
    }
  }

  async sendEmail(emailData) {
    const { to, subject, message, from } = emailData;

    // Validate required fields
    if (!to || !subject || !message) {
      throw new Error('Missing required fields: to, subject, and message are required');
    }

    // Check if Brevo API is configured
    if (process.env.BREVO_API_KEY && process.env.BREVO_API_URL) {
      return await this.sendEmailViaBrevo(emailData);
    }

    // Fallback to SMTP/Nodemailer
    return await this.sendEmailViaSMTP(emailData);
  }

  async sendEmailViaBrevo(emailData) {
    const { to, subject, message, from } = emailData;

    try {
      const brevoData = {
        sender: {
          name: "4 Secrets Wedding",
          email: from || process.env.EMAIL_FROM || 'support@brevo.4secrets-wedding-planner.de'
        },
        to: [
          {
            email: to,
            name: to.split('@')[0] // Use email prefix as name
          }
        ],
        subject: subject,
        htmlContent: `<p>${message.replace(/\n/g, '<br>')}</p>`,
        textContent: message
      };

      const response = await axios.post(process.env.BREVO_API_URL, brevoData, {
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'api-key': process.env.BREVO_API_KEY
        }
      });

      logger.info('Email sent via Brevo API:', {
        messageId: response.data.messageId,
        to: to,
        subject: subject
      });

      return {
        success: true,
        messageId: response.data.messageId || `brevo-${Date.now()}`,
        service: 'brevo'
      };

    } catch (error) {
      logger.error('Failed to send email via Brevo:', error.response?.data || error.message);
      throw new Error(`Failed to send email via Brevo: ${error.response?.data?.message || error.message}`);
    }
  }

  async sendEmailViaSMTP(emailData) {
    const { to, subject, message, from } = emailData;

    // Email options
    const mailOptions = {
      from: from || process.env.EMAIL_FROM || 'noreply@example.com',
      to: to,
      subject: subject,
      text: message, // Plain text body
      html: `<p>${message.replace(/\n/g, '<br>')}</p>` // HTML body (simple conversion)
    };

    try {
      // Send the email
      const info = await this.transporter.sendMail(mailOptions);

      logger.info('Email sent via SMTP:', {
        messageId: info.messageId,
        to: to,
        subject: subject
      });

      // For development with Ethereal, provide preview URL
      if (process.env.NODE_ENV === 'development' && nodemailer.getTestMessageUrl(info)) {
        logger.info('Preview URL: ' + nodemailer.getTestMessageUrl(info));
      }

      return {
        success: true,
        messageId: info.messageId,
        previewUrl: nodemailer.getTestMessageUrl(info) || null,
        service: 'smtp'
      };
    } catch (error) {
      logger.error('Failed to send email via SMTP:', error);
      throw new Error(`Failed to send email via SMTP: ${error.message}`);
    }
  }

  async verifyConnection() {
    try {
      await this.transporter.verify();
      logger.info('Email service connection verified');
      return true;
    } catch (error) {
      logger.error('Email service connection failed:', error);
      return false;
    }
  }
}

module.exports = new EmailService();
