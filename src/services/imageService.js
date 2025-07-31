const fs = require('fs');
const path = require('path');
const config = require('../config');
const logger = require('../utils/logger');
const chokidar = require('chokidar');

class ImageService {
  constructor() {
    this.imageCache = [];
    this.setupWatcher();
  }

  setupWatcher() {
    // Only set up watcher in production to avoid development issues
    if (config.isProduction) {
      const watcher = chokidar.watch(config.upload.absolutePath, {
        ignored: /(^|[\/\\])\../, // ignore dotfiles
        persistent: true,
        usePolling: true, // Important for network drives or some server environments
        ignorePermissionErrors: true // Ignore permission errors
      });
      
      watcher
        .on('add', path => {
          logger.info(`File ${path} has been added`);
          this.refreshImageCache();
        })
        .on('unlink', path => {
          logger.info(`File ${path} has been removed`);
          this.refreshImageCache();
        });
        
      logger.info('File watcher initialized for images directory');
    }
  }

  async refreshImageCache() {
    try {
      const files = await fs.promises.readdir(config.upload.absolutePath);
      this.imageCache = files.filter(file => !file.startsWith('.'));
    } catch (error) {
      logger.error('Error refreshing image cache:', error);
    }
  }

  async deleteImageByUrl(imageUrl) {
    try {
      if (!imageUrl) {
        return { success: false, message: 'No image URL provided' };
      }

      // Extract filename from URL
      const filename = path.basename(imageUrl);
      const imagePath = path.join(config.upload.absolutePath, filename);

      // Check if file exists
      if (!fs.existsSync(imagePath)) {
        return { success: false, message: 'Image not found' };
      }

      // Delete the file
      await fs.promises.unlink(imagePath);
      logger.info(`Image deleted: ${filename}`);
      
      // Refresh the cache
      await this.refreshImageCache();
      
      return { success: true, message: 'Image deleted successfully' };
    } catch (error) {
      logger.error('Error deleting image:', error);
      return { success: false, message: error.message };
    }
  }

  async saveImage(file, previousImageUrl) {
    try {
      // Delete previous image if URL is provided
      if (previousImageUrl) {
        await this.deleteImageByUrl(previousImageUrl);
      }

      // File is already saved by multer, just return the details
      const result = {
        filename: file.filename,
        originalname: file.originalname,
        mimetype: file.mimetype,
        size: file.size,
        path: file.path,
        url: `/images/${file.filename}`
      };
      
      // Refresh the cache
      await this.refreshImageCache();
      
      return result;
    } catch (error) {
      logger.error('Error saving image:', error);
      throw error;
    }
  }

  async getImagesList() {
    try {
      // Refresh cache if empty
      if (this.imageCache.length === 0) {
        await this.refreshImageCache();
      }
      
      return this.imageCache.map(filename => ({
        filename,
        url: `/images/${filename}`
      }));
    } catch (error) {
      logger.error('Error getting images list:', error);
      throw error;
    }
  }
}

module.exports = new ImageService();
