import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { WinstonModule } from 'nest-winston';
import { ThrottlerGuard } from '@nestjs/throttler';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import * as helmet from 'helmet';
import * as compression from 'compression';

import { AppModule } from './app.module';
import { GlobalExceptionFilter } from './common/filters/global-exception.filter';
import { LoggingInterceptor } from './common/interceptors/logging.interceptor';
import { TransformInterceptor } from './common/interceptors/transform.interceptor';

async function bootstrap() {
  const app = await NestFactory.create(AppModule, {
    logger: WinstonModule.createLogger({
      transports: [
        new (require('winston')).transports.Console({
          format: require('winston').format.combine(
            require('winston').format.timestamp(),
            require('winston').format.errors({ stack: true }),
            require('winston').format.json()
          ),
        }),
      ],
    }),
  });

  const configService = app.get(ConfigService);

  // Global prefix
  app.setGlobalPrefix('api/v1');

  // Global pipes
  app.useGlobalPipes(new ValidationPipe({
    whitelist: true,
    forbidNonWhitelisted: true,
    transform: true,
  }));

  // Global filters
  app.useGlobalFilters(new GlobalExceptionFilter());

  // Global interceptors
  app.useGlobalInterceptors(
    new LoggingInterceptor(),
    new TransformInterceptor()
  );

  // Global guards
  app.useGlobalGuards(new ThrottlerGuard());

  // Security middleware
  if (configService.get('app.helmetEnabled')) {
    app.use(helmet());
  }

  // Compression middleware
  if (configService.get('app.compressionEnabled')) {
    app.use(compression());
  }

  // CORS configuration
  app.enableCors({
    origin: configService.get('app.corsOrigin')?.split(',') || ['http://localhost:3001'],
    methods: configService.get('app.corsMethods')?.split(',') || ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
    credentials: configService.get('app.corsCredentials') || true,
    allowedHeaders: configService.get('app.corsAllowedHeaders')?.split(',') || ['Content-Type', 'Authorization', 'X-API-Key'],
  });

  // Swagger documentation
  if (configService.get('app.swaggerEnabled')) {
    const config = new DocumentBuilder()
      .setTitle(configService.get('app.swaggerTitle') || 'RAG Chat Storage API')
      .setDescription(configService.get('app.swaggerDescription') || 'API documentation for RAG Chat Storage Microservice')
      .setVersion(configService.get('app.swaggerVersion') || '1.0.0')
      .addBearerAuth()
      .addApiKey({ type: 'apiKey', name: 'X-API-Key', in: 'header' }, 'api-key')
      .addContact(
        configService.get('app.swaggerContactName') || 'Development Team',
        '',
        configService.get('app.swaggerContactEmail') || 'dev@example.com'
      )
      .build();
    
    const document = SwaggerModule.createDocument(app, config);
    SwaggerModule.setup('api/docs', app, document);
  }

  const port = configService.get('app.port') || 8000;
  const host = configService.get('app.host') || '0.0.0.0';

  await app.listen(port, host);
  
  console.log(`🚀 Application is running on: http://${host}:${port}`);
  console.log(`📚 API Documentation: http://${host}:${port}/api/docs`);
  console.log(`🔍 Health Check: http://${host}:${port}/api/v1/health/live`);
}

bootstrap(); 