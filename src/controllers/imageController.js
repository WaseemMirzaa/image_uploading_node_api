const imageService = require('../services/imageService');
const logger = require('../utils/logger');

class ImageController {
  async uploadImage(req, res) {
    try {
      if (!req.file) {
        return res.status(400).json({ error: 'No image file provided' });
      }

      const imageData = await imageService.saveImage(req.file);
      logger.info(`Image uploaded: ${imageData.filename}`);
      
      return res.status(201).json({
        message: 'Image uploaded successfully',
        image: imageData
      });
    } catch (error) {
      logger.error('Error in uploadImage controller:', error);
      return res.status(500).json({ error: 'Failed to upload image' });
    }
  }

  async getImages(req, res) {
    try {
      const images = await imageService.getImagesList();
      return res.status(200).json({ images });
    } catch (error) {
      logger.error('Error in getImages controller:', error);
      return res.status(500).json({ error: 'Failed to retrieve images' });
    }
  }
}

module.exports = new ImageController();