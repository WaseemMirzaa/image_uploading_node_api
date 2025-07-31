const express = require('express');
const router = express.Router();
const fileController = require('../controllers/fileController');
const upload = require('../middleware/upload');

// Upload any file type (new universal endpoint)
router.post('/upload', upload.single('file'), fileController.uploadFile);

// Get list of all files
router.get('/', fileController.getFiles);

// Delete a file
router.delete('/delete', fileController.deleteFile);

// Get file upload status
router.get('/status', fileController.getStatus);

module.exports = router;
