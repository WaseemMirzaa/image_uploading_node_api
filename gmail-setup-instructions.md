# 📧 Gmail SMTP Setup for Real Email Delivery

## **Step 1: Enable Gmail App Passwords**

1. **Go to Google Account Settings:**
   - Visit: https://myaccount.google.com/
   - Sign in with: `unicorndev.02.1997@gmail.com`

2. **Enable 2-Factor Authentication:**
   - Go to "Security" → "2-Step Verification"
   - Follow the setup process if not already enabled

3. **Generate App Password:**
   - Go to "Security" → "App passwords"
   - Select "Mail" and "Other (custom name)"
   - Enter: "4 Secrets Wedding API"
   - Copy the 16-character password (e.g., `abcd efgh ijkl mnop`)

## **Step 2: Update Environment Variables**

Update your `.env` file:

```env
# Gmail SMTP Configuration for Real Email Delivery
GMAIL_USER=unicorndev.02.1997@gmail.com
GMAIL_APP_PASSWORD=your-16-character-app-password
EMAIL_FROM=unicorndev.02.1997@gmail.com

# Keep existing settings
PORT=3000
NODE_ENV=development
UPLOAD_PATH=src/images
MAX_FILE_SIZE=5242880
```

## **Step 3: Test Real Email Delivery**

```bash
# Start the application
npm run dev

# Test invitation email (will be sent to your Gmail)
curl -X POST http://localhost:3000/api/email/send-invitation \
  -H "Content-Type: application/json" \
  -d '{"email": "unicorndev.02.1997@gmail.com", "inviterName": "Real Email Test"}'

# Check your Gmail inbox for the email!
```

## **Step 4: Alternative - Use Ethereal for Testing**

If you don't want to set up Gmail app passwords, the service will automatically fall back to Ethereal which provides preview URLs:

```bash
# Test with Ethereal (no Gmail setup needed)
curl -X POST http://localhost:3000/api/email/send-invitation \
  -H "Content-Type: application/json" \
  -d '{"email": "test@example.com", "inviterName": "Preview Test"}'

# Check console output for preview URL
```

## **Expected Results:**

### **With Gmail App Password:**
- ✅ Real email delivered to Gmail inbox
- ✅ Beautiful HTML formatting
- ✅ German content with emojis
- ✅ App download links

### **Without Gmail App Password (Ethereal fallback):**
- ✅ Preview URL generated
- ✅ Same beautiful HTML formatting
- ✅ Can view email in browser
- ✅ No actual email delivery

## **Security Notes:**

- App passwords are safer than using your main Gmail password
- App passwords can be revoked anytime
- Only use app passwords for trusted applications
- Never share your app password

## **Troubleshooting:**

1. **"Invalid credentials" error:**
   - Make sure 2FA is enabled
   - Generate a new app password
   - Use the exact 16-character password (no spaces)

2. **"Less secure app access" error:**
   - Use app passwords instead of main password
   - Don't enable "less secure apps" (deprecated)

3. **Connection timeout:**
   - Check internet connection
   - Verify Gmail SMTP settings
   - Try Ethereal fallback

## **Production Deployment:**

For production server, update the server's `.env` file with the same Gmail credentials and the emails will be delivered to real inboxes!
