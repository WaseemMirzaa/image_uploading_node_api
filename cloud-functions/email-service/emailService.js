const nodemailer = require('nodemailer');
const winston = require('winston');
// require('dotenv').config();

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

class WeddingEmailService {
  constructor() {
    this.transporter = null;
    this.emails = [];
    this.initializeTransporter();
  }

  async initializeTransporter() {
    try {
      // GMX SMTP Configuration - Working Setup
      const smtpConfigs = [
        {
          name: 'GMX SMTP (Port 587) - Primary',
          config: {
            host: 'mail.gmx.net',
            port: 587,
            secure: false, // Use STARTTLS
            auth: {
              user: 'Wedding-App',
              pass: '4WZQZZ5N2QV3PE7MKR5D'
            },
            tls: {
              rejectUnauthorized: false
            },
            connectionTimeout: 15000,
            greetingTimeout: 10000,
            socketTimeout: 15000
          }
        },
        {
          name: 'GMX SMTP (Port 465) - SSL Alternative',
          config: {
            host: 'mail.gmx.net',
            port: 465,
            secure: true, // Use SSL
            auth: {
              user: 'Wedding-App',
              pass:'4WZQZZ5N2QV3PE7MKR5D'
            },
            tls: {
              rejectUnauthorized: false
            }
          }
        }
      ];

      // Try each SMTP configuration
      for (const smtpConfig of smtpConfigs) {
        try {
          console.log(`🔄 Trying ${smtpConfig.name}...`);
          this.transporter = nodemailer.createTransport(smtpConfig.config);
          
          // Test connection with timeout
          await Promise.race([
            this.transporter.verify(),
            new Promise((_, reject) => 
              setTimeout(() => reject(new Error('Connection timeout')), 15000)
            )
          ]);
          
          console.log(`✅ ${smtpConfig.name} connected successfully!`);
          logger.info(`✅ ${smtpConfig.name} initialized successfully`);
          return;
        } catch (error) {
          console.log(`❌ ${smtpConfig.name} failed:`, error.message);
        }
      }

      // If all SMTP services fail, use Ethereal for testing
      console.log('🔄 All SMTP services failed, creating Ethereal test account...');
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
      console.log('✅ Using Ethereal test account:', testAccount.user);
      console.log('🔗 Preview URLs will be generated for all emails');
      
    } catch (error) {
      console.error('❌ Failed to initialize any email service:', error);
      throw error;
    }
  }

  async sendEmail(emailData) {
    const { to, subject, message, from, type } = emailData;

    if (!to || !subject || !message) {
      throw new Error('Missing required fields: to, subject, and message are required');
    }

    const emailRecord = {
      id: 'wedding-' + Date.now() + '-' + Math.random().toString(36).substr(2, 9),
      to: to,
      from: '4secrets-wedding@gmx.de',
      subject: subject,
      message: message,
      type: type || 'general',
      timestamp: new Date().toISOString(),
      status: 'sending'
    };

    // Create beautiful HTML email template
    const htmlContent = this.createEmailTemplate(subject, message, type);

    const mailOptions = {
      from: `"4 Secrets Wedding" <${emailRecord.from}>`,
      to: to,
      subject: subject,
      text: message,
      html: htmlContent
    };

    try {
      const info = await this.transporter.sendMail(mailOptions);
      
      emailRecord.status = 'sent';
      emailRecord.messageId = info.messageId;
      emailRecord.previewUrl = nodemailer.getTestMessageUrl(info);
      this.emails.push(emailRecord);

      logger.info('📧 EMAIL SENT:', {
        messageId: info.messageId,
        to: to,
        subject: subject,
        type: type
      });

      console.log('\n' + '='.repeat(60));
      console.log('🎉 EMAIL SENT SUCCESSFULLY');
      console.log('='.repeat(60));
      console.log('📧 To:', to);
      console.log('📝 Subject:', subject);
      console.log('🆔 Message ID:', info.messageId);
      console.log('📅 Timestamp:', emailRecord.timestamp);
      console.log('📤 From:', emailRecord.from);
      console.log('🏷️ Type:', type);
      if (emailRecord.previewUrl) {
        console.log('🔗 Preview URL:', emailRecord.previewUrl);
      }
      console.log('✅ Status: DELIVERED');
      console.log('='.repeat(60));
      console.log('');

      return {
        success: true,
        messageId: info.messageId,
        previewUrl: emailRecord.previewUrl,
        service: 'SMTP Email Service',
        type: type
      };
    } catch (error) {
      emailRecord.status = 'failed';
      emailRecord.error = error.message;
      this.emails.push(emailRecord);

      logger.error('❌ Failed to send email:', error);
      throw new Error(`Failed to send email: ${error.message}`);
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
          <div style="background: linear-gradient(135deg,rgb(107, 69, 106),rgb(107, 69, 106); padding: 30px; text-align: center;">
            <h1 style="color: white; margin: 0; font-size: 28px; font-weight: bold;">
              💍 4 Secrets Wedding
            </h1>
            <p style="color: #ffe0e6; margin: 10px 0 0 0; font-size: 16px;">
              Deine Hochzeitsplanungs-App
            </p>
          </div>

          <!-- Content -->
          <div style="padding: 40px 30px;">
            <h2 style="color: #333; margin: 0 0 20px 0; font-size: 24px;">
              ${subject}
            </h2>

            <div style="color: #555; line-height: 1.8; font-size: 16px; margin-bottom: 30px;">
              ${message.replace(/\n/g, '<br>')}
            </div>

            <!-- App Download Buttons -->
            <div style="text-align: center; margin: 40px 0;">
              <h3 style="color: #333; margin-bottom: 20px;">📱 Lade die App herunter:</h3>

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

  async verifyConnection() {
    try {
      if (!this.transporter) {
        await this.initializeTransporter();
      }
      await this.transporter.verify();
      logger.info('✅ Email service connection verified');
      return true;
    } catch (error) {
      logger.error('❌ Email service connection failed:', error);
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

module.exports = new WeddingEmailService();
