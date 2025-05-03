const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const path = require('path');
const config = require('./config');
const logger = require('./utils/logger');
const imageRoutes = require('./routes/imageRoutes');

// Initialize express app
const app = express();

// Apply middleware
app.use(helmet());
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(morgan(config.isProduction ? 'combined' : 'dev'));

// Serve static files from the images directory
app.use('/images', express.static(config.upload.absolutePath));

// API routes
app.use('/api/images', imageRoutes);

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok' });
});

// Error handling middleware
app.use((err, req, res, next) => {
  logger.error(err.stack);
  res.status(500).json({
    error: config.isProduction ? 'Internal Server Error' : err.message
  });
});

module.exports = app;