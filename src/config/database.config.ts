import { registerAs } from '@nestjs/config';

export const databaseConfig = registerAs('database', () => ({
  host: process.env.DATABASE_HOST || 'localhost',
  port: parseInt(process.env.DATABASE_PORT, 10) || 5432,
  username: process.env.DATABASE_USERNAME || 'postgres',
  password: process.env.DATABASE_PASSWORD || 'postgres',
  name: process.env.DATABASE_NAME || 'rag_chat_storage',
  ssl: process.env.DATABASE_SSL === 'true' || false,
  synchronize: process.env.DATABASE_SYNCHRONIZE === 'true' || true,
  logging: process.env.DATABASE_LOGGING === 'true' || false,
  maxConnections: parseInt(process.env.DATABASE_MAX_CONNECTIONS, 10) || 20,
  connectionTimeout: parseInt(process.env.DATABASE_CONNECTION_TIMEOUT, 10) || 5000,
  idleTimeout: parseInt(process.env.DATABASE_IDLE_TIMEOUT, 10) || 30000,
})); 