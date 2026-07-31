/**
 * Application bootstrap: Swagger, CORS restritivo e shutdown hooks.
 */
import 'reflect-metadata';
import { NestFactory } from '@nestjs/core';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { AppModule } from './app.module.js';
import { loadEnv } from './config/env.js';

async function bootstrap(): Promise<void> {
  const env = loadEnv();
  const app = await NestFactory.create(AppModule);

  // Restrictive CORS: explicit browser origins only, never a wildcard.
  const corsOrigin =
    env.NODE_ENV === 'production'
      ? env.CORS_ORIGINS!.split(',')
          .map((origin) => origin.trim())
          .filter(Boolean)
      : true;
  app.enableCors({
    origin: corsOrigin,
    methods: ['GET', 'POST'],
    maxAge: 3600,
  });
  app.enableShutdownHooks();

  const config = new DocumentBuilder()
    .setTitle('Vidora API')
    .setDescription(
      'API do Vidora â€” anÃ¡lise de elegibilidade e autenticaÃ§Ã£o. ' +
        'Downloads sÃ³ sÃ£o autorizados por API oficial, licenÃ§a aberta, ' +
        'conteÃºdo do prÃ³prio usuÃ¡rio ou arquivo pÃºblico de acesso direto.',
    )
    .setVersion('0.2.0')
    .addBearerAuth()
    .build();
  SwaggerModule.setup('docs', app, SwaggerModule.createDocument(app, config));

  await app.listen(env.PORT);
}

void bootstrap();
