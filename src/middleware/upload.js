const multer = require('multer');
const path = require('path');
const fs = require('fs');
const config = require('../config');

// Ensure upload directory exists
if (!fs.existsSync(config.upload.absolutePath)) {
  fs.mkdirSync(config.upload.absolutePath, { recursive: true });
}

// Configure storage
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, config.upload.absolutePath);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    const ext = path.extname(file.originalname);
    cb(null, file.fieldname + '-' + uniqueSuffix + ext);
  }
});

// File filter
const fileFilter = (req, file, cb) => {
  const allowedTypes = /jpeg|jpg|png|gif|webp/;
  const isValid = allowedTypes.test(path.extname(file.originalname).toLowerCase());
  
  if (isValid) {
    cb(null, true);
  } else {
    cb(new Error('Invalid file type. Only JPEG, JPG, PNG, GIF, and WEBP are allowed.'));
  }
};

// Create multer upload instance
const upload = multer({
  storage,
  limits: { fileSize: config.upload.maxSize },
  fileFilter
});

module.exports = upload;