/**
 * Global provider of the validated environment (ENV token).
 * Global on purpose: configuration is cross-cutting, and re-importing it
 * in every feature module would only add noise.
 */
import { Global, Module } from '@nestjs/common';
import { ENV, loadEnv } from './env.js';

@Global()
@Module({
  providers: [{ provide: ENV, useFactory: () => loadEnv() }],
  exports: [ENV],
})
export class EnvModule {}
