const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const axios = require('axios');
const winston = require('winston');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Brevo API Configuration
const BREVO_API_KEY = process.env.BREVO_API_KEY || 'your_brevo_api_key_here';
const BREVO_API_URL = 'https://api.brevo.com/v3/smtp/email';
const EMAIL_FROM = 'support@brevo.4secrets-wedding-planner.de';

const app = express();
const PORT = process.env.PORT || 3001;

// Create files directory for images and PDFs
const FILES_DIR = path.join(__dirname, 'uploads');
if (!fs.existsSync(FILES_DIR)) {
  fs.mkdirSync(FILES_DIR, { recursive: true });
}

// Configure logger
const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.simple()
  ),
  transports: [
    new winston.transports.Console(),
    new winston.transports.File({ filename: 'email-service.log' })
  ]
});

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Serve static files
app.use('/files', express.static(FILES_DIR));

// Logging middleware
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
  next();
});

// Storage for emails and files
let sentEmails = [];
let uploadedFiles = [];

// Configure multer for file uploads (images and PDFs)
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, FILES_DIR);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    const ext = path.extname(file.originalname);
    cb(null, file.fieldname + '-' + uniqueSuffix + ext);
  }
});

const fileFilter = (req, file, cb) => {
  // Allow all file types
  cb(null, true);
};

const upload = multer({
  storage,
  limits: { fileSize: 52428800 }, // 50MB limit for all file types
  fileFilter
});

// Email templates (German)
const emailTemplates = {
  invitation: (inviterName) => ({
    subject: 'Du wurdest eingeladen, bei einer Hochzeits-Checkliste mitzuarbeiten 💍',
    message: `Hallo,

${inviterName} hat dich eingeladen, bei einer Hochzeits-Checkliste in der 4 Secrets Wedding App mitzuarbeiten! 👰🤵

So kannst du starten:
• Erstelle ein Konto oder melde dich in der App an
• Öffne das Seitenmenü
• Navigiere zum Hochzeitskit-Bildschirm
• Tippe auf die Titelleiste oben, um zur Seite Erhaltene Einladungen zu gelangen
• Nimm die Einladung an
• Kehre zur Hochzeitskit-Seite zurück, um mit der Zusammenarbeit zu beginnen

Viel Spaß beim Kommentieren und Abhaken von Checklistenpunkten!

Lade die App herunter und starte mit der Hochzeitsplanung:

Viel Spaß bei der Hochzeitsplanung! 💖

Liebe Grüße,
Dein 4 Secrets Wedding Team`
  }),

  declined: (declinerName) => ({
    subject: 'Einladung zur Hochzeits-Checkliste wurde abgelehnt',
    message: `Hallo,

${declinerName} hat die Einladung zur Zusammenarbeit bei der Hochzeits-Checkliste abgelehnt.

Du kannst jederzeit eine neue Einladung senden oder andere Personen zur Zusammenarbeit einladen.

Liebe Grüße,
Dein 4 Secrets Wedding Team`
  }),

  revoked: (inviterName) => ({
    subject: 'Zugriff auf Hochzeits-Checkliste wurde entfernt',
    message: `Hallo,

${inviterName} hat deinen Zugriff auf die Hochzeits-Checkliste entfernt.

Falls du denkst, dass dies ein Fehler ist, wende dich bitte an die Person, die dich ursprünglich eingeladen hat.

Liebe Grüße,
Dein 4 Secrets Wedding Team`
  }),

  welcome: (userName) => ({
    subject: 'Willkommen bei 4 Secrets Wedding! 💍',
    message: `Hallo ${userName},

Willkommen bei 4 Secrets Wedding! Wir freuen uns, dass du dabei bist.

Mit unserer App kannst du:
✅ Hochzeitsaufgaben planen und verwalten
💒 Wichtige Termine koordinieren
📝 Checklisten erstellen und abhaken
💌 Ideen und Notizen teilen

Viel Spaß bei der Hochzeitsplanung! 💖

Liebe Grüße,
Dein 4 Secrets Wedding Team`
  })
};

// Create HTML email template
function createEmailTemplate(subject, message) {
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

// Send email via Brevo API
async function sendEmailViaBrevo(to, subject, message, type = 'general') {
  try {
    const htmlContent = createEmailTemplate(subject, message);
    
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

    const emailRecord = {
      id: Date.now().toString(),
      to: to,
      from: EMAIL_FROM,
      subject: subject,
      type: type,
      messageId: response.data.messageId || `brevo-${Date.now()}`,
      timestamp: new Date().toISOString(),
      status: 'sent'
    };
    
    sentEmails.push(emailRecord);

    console.log(`✅ EMAIL SENT: ${subject} to ${to}`);
    logger.info('📧 EMAIL SENT VIA BREVO:', emailRecord);

    return {
      success: true,
      messageId: emailRecord.messageId,
      service: 'Brevo API Email Service',
      timestamp: emailRecord.timestamp
    };

  } catch (error) {
    console.log('❌ Failed to send email:', error.message);
    logger.error('❌ Failed to send email:', error);
    throw new Error(`Failed to send email: ${error.message}`);
  }
}

// ================================================================================
// API ENDPOINTS
// ================================================================================

// Health check
app.get('/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    service: '4 Secrets Wedding Email + File Service (All File Types)',
    port: PORT,
    timestamp: new Date().toISOString(),
    version: '1.0.0'
  });
});

// Email service status
app.get('/api/email/status', (req, res) => {
  res.json({
    status: 'Brevo Email API is working',
    connected: true,
    service: 'DigitalOcean Brevo Email Service',
    port: PORT,
    timestamp: new Date().toISOString()
  });
});

// Send wedding invitation
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
    const result = await sendEmailViaBrevo(email, template.subject, template.message, 'invitation');
    
    res.json({
      success: true,
      message: 'Wedding invitation sent successfully',
      ...result
    });
  } catch (error) {
    res.status(500).json({
      error: 'Failed to send invitation email',
      message: error.message,
      timestamp: new Date().toISOString()
    });
  }
});

// Send declined invitation notification
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
    const result = await sendEmailViaBrevo(email, template.subject, template.message, 'declined');
    
    res.json({
      success: true,
      message: 'Declined invitation notification sent successfully',
      ...result
    });
  } catch (error) {
    res.status(500).json({
      error: 'Failed to send declined notification',
      message: error.message,
      timestamp: new Date().toISOString()
    });
  }
});

// Send access revoked notification
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
    const result = await sendEmailViaBrevo(email, template.subject, template.message, 'revoked');
    
    res.json({
      success: true,
      message: 'Access revoked notification sent successfully',
      ...result
    });
  } catch (error) {
    res.status(500).json({
      error: 'Failed to send revoked notification',
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

    const result = await sendEmailViaBrevo(email, subject, message, 'custom');
    
    res.json({
      success: true,
      message: 'Custom email sent successfully',
      ...result
    });
  } catch (error) {
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
    const result = await sendEmailViaBrevo(email, template.subject, template.message, 'welcome');
    
    res.json({
      success: true,
      message: 'Welcome email sent successfully',
      ...result
    });
  } catch (error) {
    res.status(500).json({
      error: 'Failed to send welcome email',
      message: error.message,
      timestamp: new Date().toISOString()
    });
  }
});

// Get all sent emails
app.get('/api/email/sent', (req, res) => {
  res.json({
    success: true,
    count: sentEmails.length,
    emails: sentEmails,
    timestamp: new Date().toISOString()
  });
});

// Get specific email by ID
app.get('/api/email/:id', (req, res) => {
  const email = sentEmails.find(e => e.id === req.params.id);
  if (!email) {
    return res.status(404).json({
      error: 'Email not found',
      message: `No email found with ID: ${req.params.id}`
    });
  }
  res.json(email);
});

// Upload file (all file types allowed)
app.post('/api/images/upload', upload.single('image'), (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'No file provided' });
    }

    // Delete previous file if URL provided
    const previousImageUrl = req.body.previous_image_url;
    if (previousImageUrl) {
      const filename = path.basename(previousImageUrl);
      const filePath = path.join(FILES_DIR, filename);
      if (fs.existsSync(filePath)) {
        fs.unlinkSync(filePath);
        console.log(`🗑️ Deleted previous file: ${filename}`);
      }
    }

    const fileData = {
      id: Date.now().toString(),
      filename: req.file.filename,
      originalname: req.file.originalname,
      mimetype: req.file.mimetype,
      size: req.file.size,
      path: req.file.path,
      url: `/files/${req.file.filename}`,
      timestamp: new Date().toISOString()
    };

    uploadedFiles.push(fileData);

    // Determine file type for logging
    let fileType = 'File';
    if (req.file.mimetype.startsWith('image/')) {
      fileType = 'Image';
    } else if (req.file.mimetype === 'application/pdf') {
      fileType = 'PDF';
    } else if (req.file.mimetype.startsWith('video/')) {
      fileType = 'Video';
    } else if (req.file.mimetype.startsWith('audio/')) {
      fileType = 'Audio';
    } else if (req.file.mimetype.includes('document') || req.file.mimetype.includes('text')) {
      fileType = 'Document';
    }

    console.log(`📄 ${fileType} uploaded: ${fileData.filename} (${req.file.mimetype})`);
    logger.info(`📄 ${fileType} uploaded:`, fileData);

    res.status(201).json({
      message: `${fileType} uploaded successfully`,
      image: fileData
    });
  } catch (error) {
    console.log('❌ Failed to upload file:', error.message);
    logger.error('❌ Failed to upload file:', error);
    res.status(500).json({ error: 'Failed to upload file' });
  }
});

// Get all files
app.get('/api/images', (req, res) => {
  try {
    const files = fs.readdirSync(FILES_DIR).filter(file => !file.startsWith('.'));
    const filesList = files.map(filename => ({
      filename,
      url: `/files/${filename}`,
      path: path.join(FILES_DIR, filename)
    }));

    res.json({
      success: true,
      count: filesList.length,
      images: filesList,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.log('❌ Failed to get files:', error.message);
    logger.error('❌ Failed to get files:', error);
    res.status(500).json({ error: 'Failed to get files list' });
  }
});

// Delete file
app.delete('/api/images/delete', (req, res) => {
  try {
    const { imageUrl } = req.body;
    
    if (!imageUrl) {
      return res.status(400).json({
        error: 'Missing required field',
        message: 'imageUrl is required'
      });
    }

    const filename = path.basename(imageUrl);
    const filePath = path.join(FILES_DIR, filename);

    if (!fs.existsSync(filePath)) {
      return res.status(404).json({
        error: 'File not found',
        message: `No file found with URL: ${imageUrl}`
      });
    }

    fs.unlinkSync(filePath);
    
    // Remove from uploaded files array
    uploadedFiles = uploadedFiles.filter(file => file.url !== imageUrl);

    console.log(`🗑️ File deleted: ${filename}`);
    logger.info(`🗑️ File deleted: ${filename}`);

    res.json({
      success: true,
      message: 'File deleted successfully',
      deletedImage: imageUrl,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.log('❌ Failed to delete file:', error.message);
    logger.error('❌ Failed to delete file:', error);
    res.status(500).json({ error: 'Failed to delete file' });
  }
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 4 Secrets Wedding - Email + File Service running on port ${PORT}`);
  console.log(`📧 Brevo API configured and ready!`);
  console.log(`📄 File upload configured and ready! (All file types allowed)`);
  console.log(`🔗 Health check: http://localhost:${PORT}/health`);
  console.log(`📡 Email API: http://localhost:${PORT}/api/email/`);
  console.log(`📄 File API: http://localhost:${PORT}/api/images/`);
  console.log(`📁 Files served at: http://localhost:${PORT}/files/`);
  console.log(`📁 Files stored in: ${FILES_DIR}`);
  
  logger.info('✅ Email + File Service started successfully', {
    port: PORT,
    emailService: 'Brevo API',
    fileService: 'Multer File Upload',
    filesDir: FILES_DIR,
    timestamp: new Date().toISOString()
  });
});
