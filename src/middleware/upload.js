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

// File filter for all file types (images, PDFs, documents, etc.)
const fileFilter = (req, file, cb) => {
  // Allow all common file types
  const allowedTypes = /jpeg|jpg|png|gif|webp|pdf|doc|docx|txt|xls|xlsx|ppt|pptx|zip|rar|mp4|mp3|avi|mov/;
  const ext = path.extname(file.originalname).toLowerCase();
  const isValidType = allowedTypes.test(ext);

  // Also check MIME types for additional security
  const allowedMimeTypes = [
    'image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp',
    'application/pdf',
    'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'text/plain',
    'application/vnd.ms-excel', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'application/vnd.ms-powerpoint', 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
    'application/zip', 'application/x-rar-compressed',
    'video/mp4', 'video/avi', 'video/quicktime',
    'audio/mpeg', 'audio/mp3'
  ];

  const isValidMime = allowedMimeTypes.includes(file.mimetype);

  if (isValidType || isValidMime) {
    cb(null, true);
  } else {
    cb(new Error(`Invalid file type. File: ${file.originalname}, Type: ${file.mimetype}. Allowed types: images, PDFs, documents, videos, audio files.`));
  }
};

// Create multer upload instance
const upload = multer({
  storage,
  limits: { fileSize: config.upload.maxSize },
  fileFilter
});

module.exports = upload;