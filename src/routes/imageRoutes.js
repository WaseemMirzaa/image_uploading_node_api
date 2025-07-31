const express = require('express');
const router = express.Router();
const imageController = require('../controllers/imageController');
const upload = require('../middleware/upload');

// Upload a single image (legacy endpoint)
router.post('/upload', upload.single('image'), imageController.uploadImage);

// Get list of all images (legacy endpoint)
router.get('/', imageController.getImages);

// Delete an image (legacy endpoint)
router.delete('/delete', imageController.deleteImage);

// Get image upload status
router.get('/status', imageController.getStatus);

module.exports = router;
