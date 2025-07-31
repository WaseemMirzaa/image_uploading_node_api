let logger;

try {
  const winston = require('winston');
  logger = winston.createLogger({
    level: 'info',
    format: winston.format.combine(
      winston.format.timestamp(),
      winston.format.simple()
    ),
    transports: [
      new winston.transports.Console()
    ]
  });
  console.log('✅ Winston logger initialized');
} catch (error) {
  console.log('⚠️ Winston failed, using console logger');
  logger = {
    info: (msg, meta) => console.log(`INFO: ${msg}`, meta || ''),
    error: (msg, meta) => console.error(`ERROR: ${msg}`, meta || ''),
    warn: (msg, meta) => console.warn(`WARN: ${msg}`, meta || '')
  };
}

module.exports = logger;