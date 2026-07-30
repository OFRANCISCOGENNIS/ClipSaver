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

  // Restrictive CORS (section 13): explicit origins only, no wildcard.
  app.enableCors({
    origin: env.NODE_ENV === 'production' ? ['https://app.vidora.example'] : true,
    methods: ['GET', 'POST'],
    maxAge: 3600,
  });
  app.enableShutdownHooks();

  const config = new DocumentBuilder()
    .setTitle('Vidora API')
    .setDescription(
      'API do Vidora — análise de elegibilidade e autenticação. ' +
        'Downloads só são autorizados por API oficial, licença aberta, ' +
        'conteúdo do próprio usuário ou arquivo público de acesso direto.',
    )
    .setVersion('0.2.0')
    .addBearerAuth()
    .build();
  SwaggerModule.setup('docs', app, SwaggerModule.createDocument(app, config));

  await app.listen(env.PORT);
}

void bootstrap();
