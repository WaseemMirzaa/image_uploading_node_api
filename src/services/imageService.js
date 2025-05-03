const fs = require('fs');
const path = require('path');
const config = require('../config');
const logger = require('../utils/logger');

class ImageService {
  async saveImage(file) {
    try {
      // File is already saved by multer, just return the details
      return {
        filename: file.filename,
        originalname: file.originalname,
        mimetype: file.mimetype,
        size: file.size,
        path: file.path,
        url: `/images/${file.filename}`
      };
    } catch (error) {
      logger.error('Error saving image:', error);
      throw error;
    }
  }

  async getImagesList() {
    try {
      const files = await fs.promises.readdir(config.upload.absolutePath);
      return files.filter(file => !file.startsWith('.'));
    } catch (error) {
      logger.error('Error getting images list:', error);
      throw error;
    }
  }
}

module.exports = new ImageService();