import swc from 'unplugin-swc';
import { defineConfig } from 'vitest/config';

export default defineConfig({
  // esbuild does not emit decorator metadata; NestJS DI needs it, so test
  // files are transformed by SWC instead.
  esbuild: false,
  plugins: [
    swc.vite({
      jsc: {
        parser: { syntax: 'typescript', decorators: true },
        transform: { legacyDecorator: true, decoratorMetadata: true },
        target: 'es2022',
      },
      module: { type: 'es6' },
    }),
  ],
  test: {
    globals: true,
    include: ['test/**/*.spec.ts'],
    coverage: {
      provider: 'v8',
      include: ['src/**/*.ts'],
      // Section 4.4: >= 95% on the domain; wiring/bootstrap files that
      // require live Redis/Postgres/HTTP are exercised by compose smoke
      // tests, not unit tests.
      exclude: [
        'src/main.ts',
        'src/modules/analysis/bullmq-analysis-executor.ts',
        'src/modules/analysis/redis-analysis-cache.ts',
        'src/modules/auth/prisma-repositories.ts',
        'src/modules/analysis/analysis.module.ts',
        // Same reason as analysis.module.ts: DI wiring that branches on
        // env vars, whose real behaviour is which store credentials the
        // deployment has — not something a unit test can assert.
        'src/modules/billing/billing.module.ts',
        'src/app.module.ts',
      ],
      thresholds: {
        lines: 95,
        functions: 95,
        branches: 90,
        statements: 95,
      },
    },
  },
});
