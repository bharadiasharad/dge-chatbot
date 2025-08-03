import { registerAs } from '@nestjs/config';

export const appConfig = registerAs('app', () => ({
  // Application Configuration
  port: parseInt(process.env.APP_PORT, 10) || 8000,
  host: process.env.APP_HOST || '0.0.0.0',
  name: process.env.APP_NAME || 'RAG Chat Storage Microservice',
  version: process.env.APP_VERSION || '1.0.0',
  environment: process.env.NODE_ENV || 'development',

  // Logging Configuration
  logLevel: process.env.LOG_LEVEL || 'debug',
  logFormat: process.env.LOG_FORMAT || 'json',
  logFilePath: process.env.LOG_FILE_PATH || 'logs',
  logMaxSize: process.env.LOG_MAX_SIZE || '10m',
  logMaxFiles: parseInt(process.env.LOG_MAX_FILES, 10) || 5,

  // CORS Configuration
  corsOrigin: process.env.CORS_ORIGIN || 'http://localhost:8000,http://localhost:3001,http://localhost:8080,http://localhost:3000',
  corsMethods: process.env.CORS_METHODS || 'GET,HEAD,PUT,PATCH,POST,DELETE,OPTIONS',
  corsCredentials: process.env.CORS_CREDENTIALS === 'true' || true,
  corsAllowedHeaders: process.env.CORS_ALLOWED_HEADERS || 'Content-Type,Authorization,X-API-Key',

  // Security Configuration
  helmetEnabled: process.env.HELMET_ENABLED === 'true' || true,
  compressionEnabled: process.env.COMPRESSION_ENABLED === 'true' || true,
  requestTimeout: parseInt(process.env.REQUEST_TIMEOUT, 10) || 30000,
  responseTimeout: parseInt(process.env.RESPONSE_TIMEOUT, 10) || 30000,

  // Health Check Configuration
  healthCheckInterval: parseInt(process.env.HEALTH_CHECK_INTERVAL, 10) || 30,
  healthCheckTimeout: parseInt(process.env.HEALTH_CHECK_TIMEOUT, 10) || 3,
  healthCheckRetries: parseInt(process.env.HEALTH_CHECK_RETRIES, 10) || 3,

  // File Upload Configuration
  uploadMaxFileSize: parseInt(process.env.UPLOAD_MAX_FILE_SIZE, 10) || 10485760,
  uploadAllowedTypes: process.env.UPLOAD_ALLOWED_TYPES || 'txt,pdf',
  uploadDestination: process.env.UPLOAD_DESTINATION || 'uploads',
  uploadTempDir: process.env.UPLOAD_TEMP_DIR || 'temp',

  // Vector Storage Configuration
  vectorDimension: parseInt(process.env.VECTOR_DIMENSION, 10) || 1536,
  vectorSimilarityThreshold: parseFloat(process.env.VECTOR_SIMILARITY_THRESHOLD) || 0.7,
  vectorMaxResults: parseInt(process.env.VECTOR_MAX_RESULTS, 10) || 10,

  // RAG Configuration
  ragChunkSize: parseInt(process.env.RAG_CHUNK_SIZE, 10) || 1000,
  ragChunkOverlap: parseInt(process.env.RAG_CHUNK_OVERLAP, 10) || 200,
  ragMaxContextLength: parseInt(process.env.RAG_MAX_CONTEXT_LENGTH, 10) || 3000,
  ragTemperature: parseFloat(process.env.RAG_TEMPERATURE) || 0.7,
  ragTopP: parseFloat(process.env.RAG_TOP_P) || 0.9,

  // Monitoring Configuration
  metricsEnabled: process.env.METRICS_ENABLED === 'true' || true,
  metricsPort: parseInt(process.env.METRICS_PORT, 10) || 9090,
  metricsPath: process.env.METRICS_PATH || '/metrics',

  // Swagger Configuration
  swaggerEnabled: process.env.SWAGGER_ENABLED === 'true' || true,
  swaggerTitle: process.env.SWAGGER_TITLE || 'RAG Chat Storage API',
  swaggerDescription: process.env.SWAGGER_DESCRIPTION || 'API documentation for RAG Chat Storage Microservice',
  swaggerVersion: process.env.SWAGGER_VERSION || '1.0.0',
  swaggerContactName: process.env.SWAGGER_CONTACT_NAME || 'Development Team',
  swaggerContactEmail: process.env.SWAGGER_CONTACT_EMAIL || 'dev@example.com',

  // Rate Limiting Configuration
  rateLimitTtl: parseInt(process.env.RATE_LIMIT_TTL, 10) || 60,
  rateLimitMax: parseInt(process.env.RATE_LIMIT_MAX, 10) || 100,
  rateLimitMaxPerUser: parseInt(process.env.RATE_LIMIT_MAX_PER_USER, 10) || 50,
  rateLimitMaxPerApiKey: parseInt(process.env.RATE_LIMIT_MAX_PER_API_KEY, 10) || 200,

  // Pagination Configuration
  defaultPageSize: parseInt(process.env.DEFAULT_PAGE_SIZE, 10) || 20,
  maxPageSize: parseInt(process.env.MAX_PAGE_SIZE, 10) || 100,
})); 