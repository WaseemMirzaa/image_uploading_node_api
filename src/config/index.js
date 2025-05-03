require('dotenv').config();
const path = require('path');

const config = {
  env: process.env.NODE_ENV || 'development',
  port: process.env.PORT || 3000,
  upload: {
    path: process.env.UPLOAD_PATH || 'src/images',
    maxSize: parseInt(process.env.MAX_FILE_SIZE || 5242880) // 5MB default
  },
  isProduction: process.env.NODE_ENV === 'production'
};

// Ensure upload path is absolute
config.upload.absolutePath = path.resolve(config.upload.path);

module.exports = config;