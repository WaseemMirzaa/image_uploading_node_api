const express = require('express');
const router = express.Router();
const imageController = require('../controllers/imageController');
const upload = require('../middleware/upload');

// Upload a single image
router.post('/upload', upload.single('image'), imageController.uploadImage);

// Get list of all images
router.get('/', imageController.getImages);

// Delete an image
router.delete('/delete', imageController.deleteImage);

module.exports = router;
