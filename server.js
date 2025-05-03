const app = require('./src/app');
const config = require('./src/config');
const logger = require('./src/utils/logger');

// Start the server
app.listen(config.port, () => {
  logger.info(`Server running in ${config.env} mode on port ${config.port}`);
  logger.info(`Images will be stored in: ${config.upload.absolutePath}`);
});