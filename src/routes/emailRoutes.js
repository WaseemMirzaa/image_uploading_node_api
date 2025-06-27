const express = require('express');
const router = express.Router();
const emailController = require('../controllers/emailController');

// Send an email
router.post('/send', emailController.sendEmail);

// Send invitation email
router.post('/send-invitation', emailController.sendInvitation);

// Send revoked access email
router.post('/revoke-access', emailController.revokeAccess);

// Test email service connection
router.get('/test', emailController.testConnection);

// Get email service status
router.get('/status', emailController.getStatus);

module.exports = router;
