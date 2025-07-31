require('dotenv').config();
const path = require('path');

const config = {
  env: process.env.NODE_ENV || 'development',
  port: process.env.PORT || 3001,
  upload: {
    path: process.env.UPLOAD_PATH || 'src/files',
    maxSize: parseInt(process.env.MAX_FILE_SIZE || 10485760) // 10MB default for all file types
  },
  isProduction: process.env.NODE_ENV === 'production'
};

// Ensure upload path is absolute
config.upload.absolutePath = path.resolve(config.upload.path);

module.exports = config;