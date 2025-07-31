const fs = require('fs');
const path = require('path');
const config = require('../config');
const logger = require('../utils/logger');

// Upload a file
const uploadFile = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        error: 'No file provided'
      });
    }

    const fileData = {
      filename: req.file.filename,
      originalname: req.file.originalname,
      mimetype: req.file.mimetype,
      size: req.file.size,
      url: `/files/${req.file.filename}`,
      // Keep backward compatibility for images
      imageUrl: `/images/${req.file.filename}`
    };

    logger.info(`📁 File uploaded: ${req.file.filename} (${req.file.mimetype})`);

    res.status(201).json({
      success: true,
      message: 'File uploaded successfully',
      file: fileData
    });

  } catch (error) {
    logger.error('Error uploading file:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to upload file',
      details: error.message
    });
  }
};

// Get list of all files
const getFiles = async (req, res) => {
  try {
    const files = fs.readdirSync(config.upload.absolutePath)
      .filter(file => !file.startsWith('.'));

    const fileList = files.map(filename => {
      const ext = path.extname(filename).toLowerCase();
      const isImage = /\.(jpg|jpeg|png|gif|webp)$/i.test(filename);
      const isPdf = ext === '.pdf';
      const isDocument = /\.(doc|docx|txt|xls|xlsx|ppt|pptx)$/i.test(filename);
      const isVideo = /\.(mp4|avi|mov)$/i.test(filename);
      const isAudio = /\.(mp3|wav|m4a)$/i.test(filename);

      return {
        filename,
        url: `/files/${filename}`,
        imageUrl: `/images/${filename}`, // Backward compatibility
        type: isImage ? 'image' : isPdf ? 'pdf' : isDocument ? 'document' : isVideo ? 'video' : isAudio ? 'audio' : 'other',
        extension: ext
      };
    });

    res.status(200).json({
      success: true,
      total: fileList.length,
      files: fileList
    });

  } catch (error) {
    logger.error('Error retrieving files:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to retrieve files',
      details: error.message
    });
  }
};

// Delete a file
const deleteFile = async (req, res) => {
  try {
    const { file_url } = req.body;

    if (!file_url) {
      return res.status(400).json({
        success: false,
        error: 'File URL is required'
      });
    }

    // Extract filename from URL (handle both /files/ and /images/ paths)
    const filename = path.basename(file_url);
    const filePath = path.join(config.upload.absolutePath, filename);

    // Check if file exists
    if (!fs.existsSync(filePath)) {
      return res.status(404).json({
        success: false,
        error: 'File not found'
      });
    }

    // Delete the file
    fs.unlinkSync(filePath);
    logger.info(`🗑️ File deleted: ${filename}`);

    res.status(200).json({
      success: true,
      message: 'File deleted successfully'
    });

  } catch (error) {
    logger.error('Error deleting file:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to delete file',
      details: error.message
    });
  }
};

// Get file upload status
const getStatus = (req, res) => {
  try {
    const files = fs.readdirSync(config.upload.absolutePath)
      .filter(file => !file.startsWith('.'));

    res.status(200).json({
      service: 'File Upload API',
      status: 'ready',
      uploadPath: config.upload.path,
      absolutePath: config.upload.absolutePath,
      maxFileSize: config.upload.maxSize,
      allowedTypes: ['Images (JPEG, PNG, GIF, WEBP)', 'Documents (PDF, DOC, DOCX, TXT, XLS, XLSX, PPT, PPTX)', 'Archives (ZIP, RAR)', 'Media (MP4, MP3, AVI, MOV)'],
      totalFiles: files.length
    });

  } catch (error) {
    res.status(200).json({
      service: 'File Upload API',
      status: 'ready',
      uploadPath: config.upload.path,
      absolutePath: config.upload.absolutePath,
      maxFileSize: config.upload.maxSize,
      allowedTypes: ['Images (JPEG, PNG, GIF, WEBP)', 'Documents (PDF, DOC, DOCX, TXT, XLS, XLSX, PPT, PPTX)', 'Archives (ZIP, RAR)', 'Media (MP4, MP3, AVI, MOV)'],
      totalFiles: 0,
      error: error.message
    });
  }
};

module.exports = {
  uploadFile,
  getFiles,
  deleteFile,
  getStatus
};
