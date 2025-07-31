const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
require('dotenv').config();

const BrevoEmailService = require('./functions/brevoEmailService');
const emailTemplates = require('./emailTemplates');

// Initialize Brevo email service
const emailService = new BrevoEmailService();

const app = express();
const PORT = process.env.PORT || 3001;

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Logging middleware
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
  next();
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    service: '4 Secrets Wedding Email Service',
    timestamp: new Date().toISOString(),
    version: '1.0.0'
  });
});

// Email service status
app.get('/api/email/status', async (req, res) => {
  try {
    const isConnected = await emailService.verifyConnection();
    res.json({
      status: 'Email API is working',
      connected: isConnected,
      service: 'SMTP Email Service',
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.status(500).json({
      error: 'Email service error',
      message: error.message,
      timestamp: new Date().toISOString()
    });
  }
});

// Send wedding invitation email
app.post('/api/email/send-invitation', async (req, res) => {
  try {
    const { email, inviterName } = req.body;

    if (!email || !inviterName) {
      return res.status(400).json({
        error: 'Missing required fields',
        message: 'email and inviterName are required'
      });
    }

    const template = emailTemplates.invitation(inviterName);
    
    const result = await emailService.sendEmail({
      to: email,
      subject: template.subject,
      message: template.message,
      type: 'invitation'
    });

    res.json({
      success: true,
      message: 'Wedding invitation sent successfully',
      messageId: result.messageId,
      previewUrl: result.previewUrl,
      service: result.service,
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('Error sending invitation email:', error);
    res.status(500).json({
      error: 'Failed to send invitation email',
      message: error.message,
      timestamp: new Date().toISOString()
    });
  }
});

// Send declined invitation email
app.post('/api/email/declined-invitation', async (req, res) => {
  try {
    const { email, declinerName } = req.body;

    if (!email || !declinerName) {
      return res.status(400).json({
        error: 'Missing required fields',
        message: 'email and declinerName are required'
      });
    }

    const template = emailTemplates.declined(declinerName);
    
    const result = await emailService.sendEmail({
      to: email,
      subject: template.subject,
      message: template.message,
      type: 'declined'
    });

    res.json({
      success: true,
      message: 'Declined invitation notification sent successfully',
      messageId: result.messageId,
      previewUrl: result.previewUrl,
      service: result.service,
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('Error sending declined invitation email:', error);
    res.status(500).json({
      error: 'Failed to send declined invitation email',
      message: error.message,
      timestamp: new Date().toISOString()
    });
  }
});

// Send revoked access email
app.post('/api/email/revoke-access', async (req, res) => {
  try {
    const { email, inviterName } = req.body;

    if (!email || !inviterName) {
      return res.status(400).json({
        error: 'Missing required fields',
        message: 'email and inviterName are required'
      });
    }

    const template = emailTemplates.revoked(inviterName);
    
    const result = await emailService.sendEmail({
      to: email,
      subject: template.subject,
      message: template.message,
      type: 'revoked'
    });

    res.json({
      success: true,
      message: 'Access revoked notification sent successfully',
      messageId: result.messageId,
      previewUrl: result.previewUrl,
      service: result.service,
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('Error sending access revoked email:', error);
    res.status(500).json({
      error: 'Failed to send access revoked email',
      message: error.message,
      timestamp: new Date().toISOString()
    });
  }
});

// Send custom email
app.post('/api/email/send-custom', async (req, res) => {
  try {
    const { email, subject, message } = req.body;

    if (!email || !subject || !message) {
      return res.status(400).json({
        error: 'Missing required fields',
        message: 'email, subject, and message are required'
      });
    }

    const result = await emailService.sendEmail({
      to: email,
      subject: subject,
      message: message,
      type: 'custom'
    });

    res.json({
      success: true,
      message: 'Custom email sent successfully',
      messageId: result.messageId,
      previewUrl: result.previewUrl,
      service: result.service,
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('Error sending custom email:', error);
    res.status(500).json({
      error: 'Failed to send custom email',
      message: error.message,
      timestamp: new Date().toISOString()
    });
  }
});

// Send welcome email
app.post('/api/email/send-welcome', async (req, res) => {
  try {
    const { email, userName } = req.body;

    if (!email || !userName) {
      return res.status(400).json({
        error: 'Missing required fields',
        message: 'email and userName are required'
      });
    }

    const template = emailTemplates.welcome(userName);
    
    const result = await emailService.sendEmail({
      to: email,
      subject: template.subject,
      message: template.message,
      type: 'welcome'
    });

    res.json({
      success: true,
      message: 'Welcome email sent successfully',
      messageId: result.messageId,
      previewUrl: result.previewUrl,
      service: result.service,
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('Error sending welcome email:', error);
    res.status(500).json({
      error: 'Failed to send welcome email',
      message: error.message,
      timestamp: new Date().toISOString()
    });
  }
});

// Get all sent emails
app.get('/api/email/sent', (req, res) => {
  try {
    const sentEmails = emailService.getSentEmails();
    res.json({
      success: true,
      count: sentEmails.length,
      emails: sentEmails,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.error('Error retrieving sent emails:', error);
    res.status(500).json({
      error: 'Failed to retrieve sent emails',
      message: error.message,
      timestamp: new Date().toISOString()
    });
  }
});

// Get specific email by ID
app.get('/api/email/:id', (req, res) => {
  try {
    const { id } = req.params;
    const email = emailService.getEmail(id);
    
    if (!email) {
      return res.status(404).json({
        error: 'Email not found',
        message: `Email with ID ${id} not found`,
        timestamp: new Date().toISOString()
      });
    }

    res.json({
      success: true,
      email: email,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.error('Error retrieving email:', error);
    res.status(500).json({
      error: 'Failed to retrieve email',
      message: error.message,
      timestamp: new Date().toISOString()
    });
  }
});

// Error handling middleware
app.use((error, req, res, next) => {
  console.error('Unhandled error:', error);
  res.status(500).json({
    error: 'Internal server error',
    message: error.message,
    timestamp: new Date().toISOString()
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    error: 'Endpoint not found',
    message: `${req.method} ${req.path} not found`,
    timestamp: new Date().toISOString()
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 4 Secrets Wedding Email Service running on port ${PORT}`);
  console.log(`📧 Email API endpoints available at http://localhost:${PORT}/api/email/`);
  console.log(`🔗 Health check: http://localhost:${PORT}/health`);
});

module.exports = app;
