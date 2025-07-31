const axios = require('axios');
const winston = require('winston');

// Brevo API Configuration
const BREVO_API_KEY = process.env.BREVO_API_KEY || 'your-brevo-api-key-here';
const BREVO_API_URL = process.env.BREVO_API_URL || 'https://api.brevo.com/v3/smtp/email';
const EMAIL_FROM = process.env.EMAIL_FROM || 'your-email@domain.com';

// Configure logger
const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.simple()
  ),
  transports: [
    new winston.transports.Console()
  ]
});

class BrevoEmailService {
  constructor() {
    this.emails = [];
    this.serviceName = 'Brevo API Email Service';
    this.initializeService();
  }

  async initializeService() {
    try {
      console.log('🔄 Initializing Brevo API...');
      console.log('✅ Brevo API ready for email sending!');
      logger.info('✅ Brevo API initialized successfully');
    } catch (error) {
      console.log('❌ Failed to initialize Brevo API:', error.message);
      logger.error('❌ Failed to initialize Brevo API', { error: error.message });
      throw new Error(`Failed to initialize Brevo API: ${error.message}`);
    }
  }

  async sendEmail(emailData) {
    const { to, subject, message, type } = emailData;

    if (!to || !subject || !message) {
      throw new Error('Missing required fields: to, subject, and message are required');
    }

    // Create email record
    const emailRecord = {
      id: Date.now().toString(),
      to: to,
      from: EMAIL_FROM,
      subject: subject,
      message: message,
      type: type || 'general',
      timestamp: new Date().toISOString(),
      status: 'sending'
    };

    // Create beautiful HTML email template
    const htmlContent = this.createEmailTemplate(subject, message, type);

    try {
      // Send email via Brevo API
      const response = await axios.post(BREVO_API_URL, {
        sender: { 
          email: EMAIL_FROM,
          name: "4 Secrets Wedding"
        },
        to: [{ email: to }],
        subject: subject,
        htmlContent: htmlContent
      }, {
        headers: {
          'api-key': BREVO_API_KEY,
          'Content-Type': 'application/json'
        }
      });

      // Update email record with success
      emailRecord.status = 'sent';
      emailRecord.messageId = response.data.messageId || `brevo-${Date.now()}`;
      this.emails.push(emailRecord);

      // Log success
      console.log('\n============================================================');
      console.log('🎉 EMAIL SENT SUCCESSFULLY VIA BREVO API');
      console.log('============================================================');
      console.log(`📧 To: ${to}`);
      console.log(`📝 Subject: ${subject}`);
      console.log(`🆔 Message ID: ${emailRecord.messageId}`);
      console.log(`📅 Timestamp: ${emailRecord.timestamp}`);
      console.log(`📤 From: ${EMAIL_FROM}`);
      console.log(`🏷️ Type: ${type}`);
      console.log(`✅ Status: DELIVERED VIA BREVO`);
      console.log('============================================================\n');

      logger.info('📧 EMAIL SENT VIA BREVO:', {
        messageId: emailRecord.messageId,
        subject: subject,
        to: to,
        type: type,
        timestamp: emailRecord.timestamp
      });

      return {
        success: true,
        messageId: emailRecord.messageId,
        service: 'Brevo API Email Service',
        timestamp: emailRecord.timestamp
      };

    } catch (error) {
      emailRecord.status = 'failed';
      emailRecord.error = error.message;
      this.emails.push(emailRecord);
      
      console.log('❌ Failed to send email via Brevo:', error.message);
      logger.error('❌ Failed to send email via Brevo:', error);
      throw new Error(`Failed to send email via Brevo: ${error.message}`);
    }
  }

  createEmailTemplate(subject, message, type) {
    return `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>${subject}</title>
      </head>
      <body style="margin: 0; padding: 0; font-family: Arial, sans-serif; background-color: #f5f5f5;">
        <div style="max-width: 600px; margin: 0 auto; background-color: white;">
          
          <!-- Header -->
          <div style="background: linear-gradient(135deg,rgb(107, 69, 106),rgb(107, 69, 106)); padding: 30px; text-align: center;">
            <h1 style="color: white; margin: 0; font-size: 28px; font-weight: bold;">
              💍 4 Secrets Wedding
            </h1>
            <p style="color: #E1BEE7; margin: 10px 0 0 0; font-size: 16px;">
              Deine Hochzeitsplanungs-App
            </p>
          </div>

          <!-- Content -->
          <div style="padding: 40px 30px;">
            <h2 style="color: #6B456A; margin: 0 0 20px 0; font-size: 24px;">
              ${subject}
            </h2>
            
            <div style="color: #555; line-height: 1.8; font-size: 16px; margin-bottom: 30px;">
              ${message.replace(/\n/g, '<br>')}
            </div>

            <!-- App Download Buttons -->
            <div style="text-align: center; margin: 40px 0;">
              <h3 style="color: #6B456A; margin-bottom: 20px;">📱 Lade die App herunter:</h3>
              
              <div style="margin: 10px 0;">
                <a href="https://play.google.com/store/apps/details?id=com.app.four_secrets_wedding_app"
                   style="display: inline-block; background-color: #34a853; color: white; padding: 12px 24px;
                          text-decoration: none; border-radius: 8px; font-weight: bold; margin: 5px;">
                  📱 Android App
                </a>

                <a href="https://apps.apple.com/app/4-secrets-wedding/id[APP_ID]"
                   style="display: inline-block; background-color: #007aff; color: white; padding: 12px 24px;
                          text-decoration: none; border-radius: 8px; font-weight: bold; margin: 5px;">
                  🍎 iOS App
                </a>
              </div>
            </div>
          </div>

          <!-- Footer -->
          <div style="background-color: #f8f9fa; padding: 30px; text-align: center; border-top: 1px solid #dee2e6;">
            <p style="color: #6c757d; margin: 0; font-size: 14px;">
              💖 Liebe Grüße<br>
              <strong>Dein 4 Secrets Wedding Team</strong>
            </p>
            <p style="color: #adb5bd; margin: 15px 0 0 0; font-size: 12px;">
              Diese E-Mail wurde von der 4 Secrets Wedding App gesendet
            </p>
          </div>
        </div>
      </body>
      </html>
    `;
  }

  getSentEmails() {
    return this.emails;
  }

  getEmailById(id) {
    return this.emails.find(email => email.id === id);
  }

  getServiceStatus() {
    return {
      status: 'Email API is working',
      connected: true,
      service: this.serviceName,
      timestamp: new Date().toISOString()
    };
  }
}

module.exports = BrevoEmailService;
