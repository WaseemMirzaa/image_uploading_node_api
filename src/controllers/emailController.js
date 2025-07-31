const emailService = require('../services/emailService');
const logger = require('../utils/logger');

class EmailController {
  /**
   * Send an email
   * POST /api/email/send
   * Body: { email, subject, message, from? }
   */
  async sendEmail(req, res) {
    try {
      const { email, subject, message, from } = req.body;

      // Validate required fields
      if (!email || !subject || !message) {
        return res.status(400).json({
          error: 'Missing required fields',
          required: ['email', 'subject', 'message'],
          received: Object.keys(req.body)
        });
      }

      // Validate email format (basic validation)
      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
      if (!emailRegex.test(email)) {
        return res.status(400).json({
          error: 'Invalid email format',
          email: email
        });
      }

      // Prepare email data
      const emailData = {
        to: email,
        subject: subject,
        message: message,
        from: from
      };

      // Send the email
      const result = await emailService.sendEmail(emailData);

      logger.info('Email sent via API:', {
        to: email,
        subject: subject,
        messageId: result.messageId
      });

      // Return success response
      res.status(200).json({
        success: true,
        message: 'Email sent successfully',
        data: {
          to: email,
          subject: subject,
          messageId: result.messageId,
          previewUrl: result.previewUrl
        }
      });

    } catch (error) {
      logger.error('Error sending email:', error);
      
      res.status(500).json({
        error: 'Failed to send email',
        message: error.message
      });
    }
  }

  /**
   * Test email service connection
   * GET /api/email/test
   */
  async testConnection(req, res) {
    try {
      const isConnected = await emailService.verifyConnection();
      
      if (isConnected) {
        res.status(200).json({
          success: true,
          message: 'Email service connection is working'
        });
      } else {
        res.status(503).json({
          success: false,
          message: 'Email service connection failed'
        });
      }
    } catch (error) {
      logger.error('Error testing email connection:', error);
      
      res.status(500).json({
        error: 'Failed to test email connection',
        message: error.message
      });
    }
  }

  /**
   * Send invitation email
   * POST /api/email/send-invitation
   * Body: { email, inviterName }
   */
  async sendInvitation(req, res) {
    try {
      const { email, inviterName } = req.body;

      // Validate required fields
      if (!email || !inviterName) {
        return res.status(400).json({
          error: 'Missing required fields',
          required: ['email', 'inviterName'],
          received: Object.keys(req.body)
        });
      }

      // Validate email format
      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
      if (!emailRegex.test(email)) {
        return res.status(400).json({
          error: 'Invalid email format',
          email: email
        });
      }

      // Prepare invitation email data
      const subject = `Du wurdest eingeladen, bei einer Hochzeits-Checkliste mitzuarbeiten 💍`;
      const message = `Hi,

${inviterName} hat dich eingeladen, bei einer Hochzeits-Checkliste in der 4 Secrets Wedding App mitzuarbeiten! 👰🤵

So kannst du die Einladung annehmen und gemeinsam an der To-do-Liste arbeiten:

📲 Lade die App herunter:
– Für Android: https://play.google.com/store/apps/details?id=com.app.four_secrets_wedding_app
– Für iOS: https://apps.apple.com/app/4-secrets-wedding/id[APP_ID]

🔐 Registriere dich oder melde dich an.

📋 Gehe in der App zu "Hochzeits-Checklisten"

✅ Dort findest du die Einladung von ${inviterName} – einfach annehmen und loslegen!

Gemeinsam macht die Hochzeitsplanung noch mehr Spaß. 🌸

Bei Fragen stehen wir dir jederzeit zur Verfügung!

Liebe Grüße
Dein 4 Secrets Wedding Team`;

      const emailData = {
        to: email,
        subject: subject,
        message: message
      };

      // Send the email
      const result = await emailService.sendEmail(emailData);

      logger.info('Invitation email sent via API:', {
        to: email,
        messageId: result.messageId
      });

      res.status(200).json({
        success: true,
        message: 'Invitation email sent successfully',
        data: {
          to: email,
          subject: subject,
          messageId: result.messageId,
          previewUrl: result.previewUrl
        }
      });

    } catch (error) {
      logger.error('Error sending invitation email:', error);

      res.status(500).json({
        error: 'Failed to send invitation email',
        message: error.message
      });
    }
  }

  /**
   * Send declined invitation email
   * POST /api/email/declined-invitation
   * Body: { email, declinerName }
   */
  async declinedInvitation(req, res) {
    try {
      const { email, declinerName } = req.body;

      // Validate required fields
      if (!email || !declinerName) {
        return res.status(400).json({
          error: 'Missing required fields',
          required: ['email', 'declinerName'],
          received: Object.keys(req.body)
        });
      }

      // Validate email format
      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
      if (!emailRegex.test(email)) {
        return res.status(400).json({
          error: 'Invalid email format',
          email: email
        });
      }

      // Prepare declined invitation email data
      const subject = `Einladung zur Hochzeits-Checkliste wurde abgelehnt 💔`;
      const message = `Hi,

${declinerName} hat die Einladung zur Zusammenarbeit an der Hochzeits-Checkliste in der 4 Secrets Wedding App abgelehnt.

Die Einladung zur gemeinsamen Hochzeitsplanung wurde nicht angenommen. Du kannst jederzeit eine neue Einladung senden, falls sich die Situation ändert.

📲 Die 4 Secrets Wedding App findest du hier:
– Für Android: https://play.google.com/store/apps/details?id=com.app.four_secrets_wedding_app
– Für iOS: https://apps.apple.com/app/4-secrets-wedding/id[APP_ID]

Bei Fragen stehen wir dir jederzeit zur Verfügung!

Liebe Grüße
Dein 4 Secrets Wedding Team`;

      const emailData = {
        to: email,
        subject: subject,
        message: message
      };

      // Send the email
      const result = await emailService.sendEmail(emailData);

      logger.info('Declined invitation email sent via API:', {
        to: email,
        declinerName: declinerName,
        messageId: result.messageId
      });

      res.status(200).json({
        success: true,
        message: 'Declined invitation email sent successfully',
        data: {
          to: email,
          declinerName: declinerName,
          subject: subject,
          messageId: result.messageId,
          previewUrl: result.previewUrl
        }
      });

    } catch (error) {
      logger.error('Error sending declined invitation email:', error);

      res.status(500).json({
        error: 'Failed to send declined invitation email',
        message: error.message
      });
    }
  }

  /**
   * Send revoked access email
   * POST /api/email/revoke-access
   * Body: { email, inviterName }
   */
  async revokeAccess(req, res) {
    try {
      const { email, inviterName } = req.body;

      // Validate required fields
      if (!email || !inviterName) {
        return res.status(400).json({
          error: 'Missing required fields',
          required: ['email', 'inviterName'],
          received: Object.keys(req.body)
        });
      }

      // Validate email format
      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
      if (!emailRegex.test(email)) {
        return res.status(400).json({
          error: 'Invalid email format',
          email: email
        });
      }

      // Prepare revoked access email data
      const subject = `Deine Mitarbeit an der Hochzeits-Checkliste wurde beendet 💐`;
      const message = `Hi,

${inviterName} hat deine Mitarbeit an der gemeinsamen Hochzeits-Checkliste in der 4 Secrets Wedding App beendet. 📝

Du kannst die Checkliste ab sofort nicht mehr bearbeiten oder einsehen.

Falls du Rückfragen hast, wende dich gerne direkt an ${inviterName}.

Natürlich stehen wir dir auch bei allgemeinen Fragen zur App jederzeit zur Verfügung.

📲 Die 4 Secrets Wedding App findest du hier:
– Für Android: https://play.google.com/store/apps/details?id=com.app.four_secrets_wedding_app
– Für iOS: https://apps.apple.com/app/4-secrets-wedding/id[APP_ID]

Vielen Dank für dein bisheriges Mitwirken und alles Gute für dich! 💖

Liebe Grüße
Dein 4 Secrets Wedding Team`;

      const emailData = {
        to: email,
        subject: subject,
        message: message
      };

      // Send the email
      const result = await emailService.sendEmail(emailData);

      logger.info('Access revoked email sent via API:', {
        to: email,
        messageId: result.messageId
      });

      res.status(200).json({
        success: true,
        message: 'Access revoked email sent successfully',
        data: {
          to: email,
          subject: subject,
          messageId: result.messageId,
          previewUrl: result.previewUrl
        }
      });

    } catch (error) {
      logger.error('Error sending access revoked email:', error);

      res.status(500).json({
        error: 'Failed to send access revoked email',
        message: error.message
      });
    }
  }

  /**
   * Get email service status and configuration info
   * GET /api/email/status
   */
  async getStatus(req, res) {
    try {
      const isConnected = await emailService.verifyConnection();

      res.status(200).json({
        service: 'Email API',
        status: isConnected ? 'connected' : 'disconnected',
        environment: process.env.NODE_ENV || 'development',
        configured: {
          emailUser: !!process.env.EMAIL_USER,
          emailFrom: !!process.env.EMAIL_FROM
        }
      });
    } catch (error) {
      logger.error('Error getting email status:', error);

      res.status(500).json({
        error: 'Failed to get email status',
        message: error.message
      });
    }
  }

  /**
   * Preview sent email (for mock service)
   * GET /api/email/preview/:id
   */
  async previewEmail(req, res) {
    try {
      const { id } = req.params;
      const email = emailService.getEmail ? emailService.getEmail(id) : null;

      if (!email) {
        return res.status(404).json({
          error: 'Email not found',
          id: id
        });
      }

      res.status(200).json({
        success: true,
        email: email
      });
    } catch (error) {
      logger.error('Error getting email preview:', error);
      res.status(500).json({
        error: 'Failed to get email preview',
        message: error.message
      });
    }
  }

  /**
   * Get all sent emails (for debugging)
   * GET /api/email/sent
   */
  async getSentEmails(req, res) {
    try {
      const emails = emailService.getSentEmails ? emailService.getSentEmails() : [];

      res.status(200).json({
        success: true,
        count: emails.length,
        emails: emails
      });
    } catch (error) {
      logger.error('Error getting sent emails:', error);
      res.status(500).json({
        error: 'Failed to get sent emails',
        message: error.message
      });
    }
  }
}

module.exports = new EmailController();
