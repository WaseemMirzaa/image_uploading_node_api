const imageService = require('../services/imageService');
const logger = require('../utils/logger');

class ImageController {
  async uploadImage(req, res) {
    try {
      if (!req.file) {
        return res.status(400).json({ error: 'No image file provided' });
      }

      // Get previous image URL from request body if it exists
      const previousImageUrl = req.body.previous_image_url;
      
      const imageData = await imageService.saveImage(req.file, previousImageUrl);
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

  async deleteImage(req, res) {
    try {
      const { image_url } = req.body;

      if (!image_url) {
        return res.status(400).json({ error: 'Image URL is required' });
      }

      const result = await imageService.deleteImageByUrl(image_url);

      if (result.success) {
        return res.status(200).json({ message: result.message });
      } else {
        return res.status(404).json({ error: result.message });
      }
    } catch (error) {
      logger.error('Error in deleteImage controller:', error);
      return res.status(500).json({ error: 'Failed to delete image' });
    }
  }

  async getStatus(req, res) {
    try {
      const status = await imageService.getStatus();
      return res.status(200).json(status);
    } catch (error) {
      logger.error('Error in getStatus controller:', error);
      return res.status(500).json({
        service: 'Image Upload API (Legacy)',
        status: 'error',
        error: 'Failed to get status'
      });
    }
  }
}

module.exports = new ImageController();
