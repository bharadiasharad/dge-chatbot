import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ThrottlerModule } from '@nestjs/throttler';
import { WinstonModule } from 'nest-winston';

import { AuthModule } from './modules/auth/auth.module';
import { SessionsModule } from './modules/sessions/sessions.module';
import { MessagesModule } from './modules/messages/messages.module';
import { HealthModule } from './modules/health/health.module';
import { RagModule } from './modules/rag/rag.module';

import { appConfig } from './config/app.config';
import { databaseConfig } from './config/database.config';
import { redisConfig } from './config/redis.config';
import { jwtConfig } from './config/jwt.config';
import { ollamaConfig } from './config/ollama.config';

@Module({
  imports: [
    // Configuration
    ConfigModule.forRoot({
      isGlobal: true,
      load: [appConfig, databaseConfig, redisConfig, jwtConfig, ollamaConfig],
      envFilePath: ['.env.local', '.env'],
    }),

    // Database
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      useFactory: (configService: ConfigService) => ({
        type: 'postgres',
        host: configService.get('database.host'),
        port: configService.get('database.port'),
        username: configService.get('database.username'),
        password: configService.get('database.password'),
        database: configService.get('database.name'),
        entities: [__dirname + '/**/*.entity{.ts,.js}'],
        synchronize: configService.get('database.synchronize'),
        logging: configService.get('database.logging'),
        ssl: configService.get('database.ssl') === 'true',
        extra: {
          max: configService.get('database.maxConnections'),
          connectionTimeoutMillis: configService.get('database.connectionTimeout'),
          idleTimeoutMillis: configService.get('database.idleTimeout'),
        },
      }),
      inject: [ConfigService],
    }),

    // Logging
    WinstonModule.forRootAsync({
      imports: [ConfigModule],
      useFactory: (configService: ConfigService) => ({
        level: configService.get('app.logLevel'),
        format: require('winston').format.combine(
          require('winston').format.timestamp(),
          require('winston').format.errors({ stack: true }),
          require('winston').format.json()
        ),
        transports: [
          new require('winston').transports.Console(),
          new require('winston').transports.File({
            filename: configService.get('app.logFilePath') + '/error.log',
            level: 'error',
            maxsize: configService.get('app.logMaxSize'),
            maxFiles: configService.get('app.logMaxFiles'),
          }),
          new require('winston').transports.File({
            filename: configService.get('app.logFilePath') + '/combined.log',
            maxsize: configService.get('app.logMaxSize'),
            maxFiles: configService.get('app.logMaxFiles'),
          }),
        ],
      }),
      inject: [ConfigService],
    }),

    // Rate limiting
    ThrottlerModule.forRootAsync({
      imports: [ConfigModule],
      useFactory: (configService: ConfigService) => ({
        ttl: configService.get('app.rateLimitTtl'),
        limit: configService.get('app.rateLimitMax'),
      }),
      inject: [ConfigService],
    }),

    // Feature modules
    AuthModule,
    SessionsModule,
    MessagesModule,
    HealthModule,
    RagModule,
  ],
})
export class AppModule {} 